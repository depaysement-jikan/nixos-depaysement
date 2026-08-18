# Handoff: random freezes on NixOS host `shinobu`

You're picking up a debugging investigation that has run for about a week. Everything below is
established from logs unless marked as a hypothesis. Please read section 8 — several confident
diagnoses were made and later overturned, and I'd rather you not repeat them.

---

## 1. The machine

|         |                                                                                           |
| ------- | ----------------------------------------------------------------------------------------- |
| Host    | `shinobu`, user `kokoro`                                                                  |
| OS      | NixOS 25.11, flake-based, tracking **nixpkgs-unstable**                                   |
| Repo    | `~/.nixos-dotfiles` — github.com/depaysement-jikan/nixos-depaysement, branch `develop`    |
| Rebuild | `nh os switch .#shinobu`                                                                  |
| Kernel  | **7.1.8** (was 6.18.44; no `boot.kernelPackages` set anywhere, so it floats with nixpkgs) |
| CPU     | AMD Ryzen 7 9700X (8C/16T, Zen 5)                                                         |
| Board   | ASUS ROG STRIX B850-G GAMING WIFI, **BIOS 1681 (2026/06/18)**, AGESA ComboAM5 PI 1.3.0.1b |
| RAM     | 2×16GB Corsair CMH32GX5M2E6000C36 at **JEDEC 4800** — EXPO has never been enabled         |
| dGPU    | XFX SWIFT **RX 9060 XT** 16GB (Navi 44 / RDNA4), PCI 03:00.0                              |
| iGPU    | 9700X Granite Ridge, 0d:00.0, also bound to amdgpu                                        |
| Storage | Samsung SSD 9100 PRO 1TB, single NVMe, disko-managed, ext4 root                           |
| Desktop | Hyprland + greetd/tuigreet, waybar, foot/ghostty                                          |

Current kernel cmdline includes memory debugging (added deliberately):

```
page_poison=1 slub_debug=FZP page_owner=on
```

`dmesg` is restricted on this box — use `journalctl -k`. During a freeze `sudo` also hangs
(pam_systemd waits on logind, which waits on PID 1), so only unprivileged commands work.

---

## 2. The symptom

Random freezes, ongoing for months. Not an instant lock-up — a progressive collapse:

1. A browser/Electron process segfaults in userspace.
2. Seconds later the kernel takes a GPF.
3. Applications wedge one at a time; some UI (Hyprland bar, clock) keeps updating.
4. `systemctl` times out, `sudo` hangs, new sessions can't start.
5. Machine must be power-cycled. **A reboot always restores it fully** — the fault is
   per-session, not persistent.

SMART recorded 59 unsafe shutdowns out of 85 power cycles. One ext4 corruption event resulted
(Aug 11, HTREE index under `~/.cache/mozilla`), repaired with offline `e2fsck`.

---

## 3. Mechanism — established, not hypothesis

Something corrupts kernel memory. A corrupted pointer causes:

```
Oops: general protection fault, probably for non-canonical address 0x…
```

The fault happens while the task holds `rcu_read_lock` (page-table walks and similar hold it).
The task then dies without releasing it:

```
note: <thread>[<pid>] exited with preempt_count 1
Fixing recursive fault but reboot is needed!
WARNING: … Voluntary context switch within RCU read-side critical section!
  rcu_note_context_switch   (kernel/rcu/tree_plugin.h:332)
```

The RCU grace period can then never complete. Everything calling `synchronize_rcu()` blocks
forever — confirmed via `/proc/1/status` showing systemd in `State: D`, plus kworkers for
netns, inode_switch_wbs, ipv6_addrconf and events_unbound all in D state. That's the cascade.

### Fault sites observed so far

Across several crashes and two kernel series:

- `lookup_swap_cgroup_id+0x3e` via `swap_pte_batch → unmap_page_range → unmap_vmas → exit_mmap → __mmput → do_exit` — many times
- `eventpoll_release_file+0x2f`
- `lock_next_vma+0x40`
- `__d_lookup+0x58`, `___d_drop+0x36`
- `pid_task+0x18`
- `amdgpu_ttm_tt_unpopulate` (the very first crash, Aug 12)
- `vma_interval_tree_remove+0x19a`
- `rcu_note_context_switch+0x3cb`

Also recurring across multiple separate crashes:
`WARNING: io_uring/io_uring.c:… at io_ring_exit_work` on `kworker/u64:0`.

### Recurring values

Two garbage values keep reappearing across different boots, kernels and BIOS versions:

- `0x0100000001000000` (and `…018`, `…0000`) — appears both as a faulting address and as
  register contents (RBP/R08/R12/R13) in multiple crashes
- `0xfeff…` addresses — valid `0xffff…` kernel pointers with **bit 56 cleared**
  (e.g. `0xfeff896f7ab62ac0` should be `0xffff896f7ab62ac0`)

Both anomalies involve bit 56. Several other registers have been byte-identical across crashes
days apart (`RDX 0001bfffffffbfff`, `R14 0100000000fffe00`).

The most recent crash raised a **new taint flag**: `Tainted: [B]=BAD_PAGE, [D]=DIE, [W]=WARN`.
`BAD_PAGE` means the kernel's own page-release path found a page in an impossible state.

---

## 4. Ruled out — please don't re-litigate these

| Suspect                | How it was eliminated                                                                    |
| ---------------------- | ---------------------------------------------------------------------------------------- |
| RAM                    | memtest86+ v8.00, **34 passes / 32h02m at 4800, zero errors**                            |
| Memory overclock       | EXPO/DOCP never enabled; all crashes at stock JEDEC                                      |
| NVMe                   | `nvme error-log` entirely zeroed, `media_errors 0`, no controller resets or I/O timeouts |
| Memory exhaustion      | 23 GiB available and 0 B swap used _during_ a hang                                       |
| Kernel version         | Crashes on both 6.18.44 and 7.1.8 (different series)                                     |
| Browser engine         | Crashed on Firefox (Gecko) and helium (Chromium fork) alike                              |
| Swap                   | `USED 0B`, so these aren't real swap entries — corrupted PTEs misread as such            |
| Memory Context Restore | Disabled in BIOS — no change                                                             |
| BIOS/AGESA             | 1078 (1.2.0.3f) → 1681 (1.3.0.1b) — no change                                            |
| OpenLinkHub            | Logged nothing at all during crash boots (still enabled though — see §7)                 |

---

## 5. Leading hypothesis

**A kernel use-after-free, triggered by Chromium/Electron's unusual syscall surface.**

Evidence for:

- **Every** crash's faulting `comm` has been a browser or Electron thread: `StyleThread#4`,
  `Chrome_ChildIOT`, `ThreadPoolForeg`, `ThreadPoolSingl`, `DedicatedWorker`, `HangWatcher`,
  `MainThread`, `helium_crashpad`, `electron`.
- Hyprland `exec-once` launches **four** of them every boot: helium (ws2), discord (ws3),
  whatsapp-electron (ws4), spotify (ws5), plus foot on ws1.
- `BAD_PAGE` is a textbook use-after-free signature.
- A UAF explains the scattered fault sites naturally: **one trigger path, but the freed page
  gets recycled to whoever asks next**, so damage lands in epoll one time, dcache the next.
- The same garbage values recurring across boots fits recycled memory better than random flips.
- `io_ring_exit_work` warnings keep appearing — io_uring is young code that most desktop
  software never touches.

Chromium apps use kernel surface almost nothing else on this system does: user namespaces and
seccomp-BPF sandboxing per tab, aggressive `MADV_FREE`/`MADV_DONTNEED`, memfd and dma-buf
sharing with the compositor, the zygote/forkserver clone model, and io_uring.

**Counter-evidence worth holding:** the bit-56 pattern is odd for a UAF — a partially
overwritten pointer wouldn't normally differ by exactly one bit. Hardware isn't fully excluded.

---

## 6. Next steps

**A. After the next freeze**, the debug params should produce a far better report:

```bash
journalctl -b -1 -k --no-pager > ~/crash.log
grep -nE 'BUG |Redzone|Poison|padding overwritten|page dumped|page_owner|Oops|BAD_PAGE|Call Trace' ~/crash.log
```

A `slub_debug` report names the exact slab cache, and with `page_owner` you get the allocation
stack. That would identify the bug directly.

**B. Disable io_uring** — one rebuild, reversible, targets the recurring warning:

```nix
boot.kernel.sysctl."kernel.io_uring_disabled" = 2;
```

**C. A day with no Electron.** Comment helium/discord/whatsapp-electron out of `exec-once`, use
Firefox and terminal tools. Quiet for a day, then a crash within an hour of relaunching them,
would confirm the trigger without any hardware work.

### Untested, rough priority order

- `iommu.strict=1` — the box runs IOMMU in lazy mode; strict turns silent DMA corruption into a
  named `AMD-Vi: IO_PAGE_FAULT` identifying the guilty device
- Pull the RX 9060 XT, run on the iGPU for a day (first crash was in amdgpu TTM; RDNA4 driver
  paths are new)
- Single-DIMM isolation, one stick at a time, with cold boots

---

## 7. Loose ends in the config

- **`openLinkHub.enable` is still `true`** at both layers —
  `hosts/shinobu/config/nixos-config/default.nix:11` and
  `hosts/shinobu/users/kokoro/config/home-manager-config/default.nix:93`. Disabling it was
  agreed several times and never actually done. Runs as root with `WorkingDirectory` in a
  user-writable git clone.
- Swap mitigation has **failed to stick three times** — check `swapon --show` before trusting
  any swap-related conclusion. systemd's gpt-auto generator rediscovers the partition by GPT
  type GUID and creates 14 alias units; `systemd.suppressedSystemUnits` masks only one.
- `systemd.gpt_auto=0` was proposed but never appeared in `/proc/cmdline`.
- `overlays/default.nix:18` imports a deleted `nixpkgs-unstable` flake input (inert).
- `hosts/shinobu/hardware-configuration.nix` is still the placeholder stub.
- SysRq doesn't work during freezes — the Logitech Unifying wireless receiver doesn't deliver
  it (same reason the keyboard was dead in memtest). A wired keyboard would be needed.

---

## 8. What went wrong in this investigation

Five confident diagnoses were made and each was overturned. Please don't repeat them:

1. **"OpenLinkHub is the cause"** — it was a victim of the lock leak; logged nothing.
2. **"systemd-coredump memory exhaustion"** — disproven by `free -h` showing 23 GiB available.
3. **"Swap-entry corruption is the root cause"** — swap usage was 0 B, and swap was never
   successfully disabled anyway.
4. **"Definitely a kernel bug, nothing config-related"** — the fault survived two kernel series.
5. **"Definitely hardware / bad RAM"** — memtest passed 34×, and the Electron correlation
   points back at software.

The recurring error was treating a single strong signal as proof and moving on. The user
noticed the Electron correlation before I did and was right to push on it.

Two asks from the user:

- **They prefer declarative changes** — NixOS config over one-off imperative commands.
- **Back up the ext4 root** before further hardware testing; corruption has already hit it once.
