# ext4 Root Filesystem Corruption — Diagnosis, Repair & Prevention

**Host:** `shinobu` (NixOS 25.11, Linux 6.12.93)
**Date:** 2026-08-11
**Affected device:** `/dev/nvme0n1p4` — also `/dev/disk/by-partlabel/disk-main-root`
**Outcome:** Repaired offline with `e2fsck`. No data lost, nothing orphaned to `/lost+found`.

---

## 1. Summary

Stage 1 of the NixOS boot process runs an automatic `fsck` on the root filesystem before
mounting it. That check found an inconsistency it was not permitted to repair
automatically, refused to continue, and dropped to a prompt.

The actual damage was a **single corrupted HTree directory index** on Firefox's disk cache
directory. The fix was to run `e2fsck` against the **unmounted** filesystem from an initrd
shell. Total repair time: under five minutes.

---

## 2. Symptoms

Stage 1 boot failure:

```
/dev/disk/by-partlabel/disk-main-root: Problem in HTREE directory inode 4460691:
    block #335 has bad max hash
/dev/disk/by-partlabel/disk-main-root: Invalid HTREE directory inode 4460691
    (/home/kokoro/.cache/mozilla/firefox/2obn688n.default/cache2/entries)

/dev/disk/by-partlabel/disk-main-root: UNEXPECTED INCONSISTENCY; RUN fsck MANUALLY.
        (i.e., without -a or -p options)
/dev/disk/by-partlabel/disk-main-root has unrepaired errors, please fix them manually.

An error occurred in stage 1 of the boot process, which must mount the
root filesystem on `/mnt-root' and then start stage 2.
```

Secondary symptom: after choosing `*` (ignore and continue), the **tuigreet password was
rejected several times before eventually being accepted**. This was not a separate problem
— see §7.

---

## 3. Reading the output

### The noise: "extent tree could be narrower"

Hundreds of these lines scrolled past:

```
Inode 51642728 extent tree (at level 1) could be narrower.  IGNORED.
```

**These are not corruption.** They are `e2fsck` noting that an inode's extent tree could be
stored more compactly — a pure optimization. In `-p` (preen) mode they are reported and
skipped, hence `IGNORED`. They can be safely disregarded as a diagnostic signal.

### The actual problem: the HTree index

ext4 stores large directories using a hashed B-tree index (**HTree**) so that name lookups
don't require a linear scan. Each index block carries a maximum-hash value delimiting the
range of entries beneath it. Block #335 of inode 4460691 had a **bad max hash** — its value
no longer matched the entries it was supposed to describe.

Consequence: lookups in that directory can silently miss files that are physically present.
The file data itself was never at risk; only the lookup structure was broken.

The affected directory was `~/.cache/mozilla/firefox/2obn688n.default/cache2/entries` —
Firefox's disk cache, which is entirely disposable.

---

## 4. Why you cannot run fsck on a mounted filesystem

The first instinct was to run `fsck` from the running session. It refused:

```
/dev/nvme0n1p4 is mounted.
WARNING!!!  The filesystem is mounted.  If you continue you ***WILL***
cause ***SEVERE*** filesystem damage.
```

This warning is literal, not defensive boilerplate. The reason:

- `e2fsck` writes **directly to the block device**, bypassing the kernel entirely.
- The kernel simultaneously holds its **own cached copy** of the same metadata (inode
  tables, block bitmaps, directory blocks) and flushes it on its own schedule.
- You therefore have two independent writers with divergent views of the same structures,
  each overwriting the other's work at unpredictable times.

The failure mode is not "the repair didn't apply." It is a filesystem substantially more
damaged than the one you started with, frequently beyond recovery.

Remounting read-only does not rescue this: you cannot remount `/` read-only while a session
is using it, and the stale-cache problem persists regardless.

**The filesystem must genuinely be unmounted.** There is no shortcut.

---

## 5. The repair — step by step

### Step 0 — Back up first

Repair is routine but not risk-free; `e2fsck` can truncate or relocate files. Before
starting:

- Push any dirty state in `~/.nixos-dotfiles` (the rebuild had been warning the tree was
  dirty).
- Copy irreplaceable secrets off the machine — in this case the sops-nix age keys at
  `/var/lib/sops-nix/.ssh/kokoro` and `/var/lib/sops-nix/.ssh/homelab`.
- Anything under `~` not tracked in git.

### Step 1 — Verify the Nix store (optional, do it again afterwards)

```bash
sudo nix-store --verify --check-contents --repair
```

This re-hashes every store path and re-fetches damaged ones from your substituters. It came
back clean, which was useful evidence: the corruption had not touched `/nix/store`.

> Note: this run happened *before* the fsck, so it wrote into a still-inconsistent
> filesystem. The run that counts is the one after the repair.

### Step 2 — Reboot and edit the kernel command line

At the systemd-boot menu:

1. Arrow to the newest generation (do **not** land on *Reboot Into Firmware Interface*).
2. Press **`e`** to edit the kernel parameters.
3. Append — do not replace — a space followed by:

   ```
   boot.shell_on_fail
   ```

4. Press **Enter** to boot.

Under GRUB the equivalent is `e`, then navigate to the `linux` line, append, and boot with
**Ctrl-X**.

This edit is **one-shot** and does not persist across reboots.

### Step 3 — Take the initrd shell

Boot fails at the same fsck, but the prompt now offers additional options:

```
i) to launch an interactive shell
f) to start an interactive shell having pid 1
r) to reboot immediately
*) to ignore the error and continue
```

Press **`i`**.

Without `boot.shell_on_fail`, only `r` and `*` are offered — which is why the first attempt
at the error screen looked like a dead end.

You land in a minimal initrd shell. It is not a NixOS environment, but `e2fsck` is present
because stage 1 needs it to check ext4 in the first place.

### Step 4 — Confirm root is unmounted

```sh
cat /proc/mounts | grep mnt-root
```

Expect **no output**. If `/mnt-root` does appear:

```sh
umount /mnt-root
```

and re-check. This verification is the entire point of being in the initrd — skipping it
defeats the exercise.

### Step 5 — Run the repair

```sh
e2fsck -f -y /dev/disk/by-partlabel/disk-main-root
```

**Flag rationale:**

| Flag | Purpose |
|---|---|
| `-f` | Force a full check even if the superblock is marked clean. Without it, `e2fsck` frequently exits immediately reporting "clean" on a filesystem that is broken but not flagged. **Not optional.** |
| `-y` | Assume "yes" to every prompt. Otherwise you answer hundreds of extent-tree questions by hand. |

Using the `by-partlabel` path rather than `/dev/nvme0n1p4` is safer — it cannot drift if
device enumeration changes.

Observed output:

```
Pass 1: Checking inodes, blocks, and sizes
Pass 1E: Optimizing extent trees
Pass 2: Checking directory structure
Problem in HTREE directory inode 4460691: block #335 has bad max hash
Invalid HTREE directory inode 4460691 (...cache2/entries). Clear HTree index? yes
Pass 3: Checking directory connectivity
Pass 3A: Optimizing directories
Pass 4: Checking reference counts
Pass 5: Checking group summary information

***** FILE SYSTEM WAS MODIFIED *****
1649423/60727296 files (0.4% non-contiguous), 91780968/242879232 blocks
```

All five passes completed. **No "unattached inode" or "unconnected directory" lines** — so
nothing was orphaned into `/lost+found` and no data was lost.

### Step 6 — Check the exit code

```sh
echo $?
```

Returned `1`.

| Code | Meaning |
|---|---|
| `0` | No errors |
| `1` | Errors corrected |
| `2` | Errors corrected, reboot required |
| `4` | **Errors left uncorrected** — stop and investigate |
| `8` | Operational error |
| `16` | Usage/syntax error |

Bit 2 (value 4) set in any combination means uncorrected errors remain.

### Step 7 — Confirmation pass

Run the identical command again:

```sh
e2fsck -f -y /dev/disk/by-partlabel/disk-main-root
```

The second pass completed in seconds with:

- no `Problem in HTREE` line
- no extent-tree prompts
- **no** `FILE SYSTEM WAS MODIFIED`
- identical file and block counts

That is the definition of a consistent filesystem. If a second pass still finds errors, do
**not** simply run a third — that is the point to suspect hardware.

### Step 8 — Reboot normally

```sh
reboot -f
```

Boot the normal generation. Do **not** press `e` — the `boot.shell_on_fail` parameter was
never persisted.

### Step 9 — Post-repair cleanup

```bash
# Clear the directory whose index was rebuilt (Firefox regenerates it)
rm -rf ~/.cache/mozilla/firefox/2obn688n.default/cache2

# Confirm nothing was orphaned
sudo ls /lost+found

# Re-verify the Nix store against a now-clean filesystem
sudo nix-store --verify --check-contents --repair
```

---

## 6. Root cause investigation

### Drive health — clean

`nvme-cli` is not in `systemPackages`, so it was run ad hoc. Note the `--` separator, which
is required to pass flags through to the wrapped program:

```bash
sudo nix run nixpkgs#nvme-cli -- smart-log /dev/nvme0n1
# or
sudo nix-shell -p nvme-cli --run "nvme smart-log /dev/nvme0n1"
```

Results:

| Field | Value | Reading |
|---|---|---|
| `critical_warning` | 0 | No warnings |
| `media_errors` | 0 | **No unrecoverable read/write errors** |
| `num_err_log_entries` | 0 | No logged controller errors |
| `percentage_used` | 0% | Essentially no wear |
| `available_spare` | 100% | Full spare block pool |
| Temperature | 95–100 °F | Cool; zero thermal throttle events |
| `power_cycles` | 81 | — |
| `unsafe_shutdowns` | 58 | See below |
| `power_on_hours` | 5 | **Implausible** — see below |

**Conclusion: the SSD is healthy and did not cause this.**

### On `unsafe_shutdowns: 58`

58 of 81 power cycles looks alarming, but it is very likely benign. On **reboot** (as
opposed to full poweroff), the kernel often does not send the NVMe controller its shutdown
notification (CC.SHN), so the drive increments `unsafe_shutdowns` even though Linux shut
down perfectly. Frequent `nixos-rebuild` + reboot cycles inflate this counter harmlessly.

Corroborating evidence: `power_on_hours: 5` is impossible alongside 419 GB written and 81
power cycles, confirming this drive's firmware misreports at least one counter. Treat these
statistics as indicative, not authoritative.

### Shutdown log — clean

```bash
journalctl --list-boots | tail -20
journalctl -b -1 -n 40
```

The previous shutdown was textbook: swap deactivated, `/boot` unmounted, *Reached target
Unmount All Filesystems*, filesystems and block devices synced, journal stopped in order.
No evidence of a hard cut.

### Remaining suspects

**1. The hardware watchdog** — flagged in the shutdown log:

```
watchdog: watchdog0: watchdog did not stop!
systemd-shutdown[1]: Using hardware watchdog /dev/watchdog0: 'SP5100 TCO timer', version 0.
systemd-shutdown[1]: Watchdog running with a hardware timeout of 10min.
```

The SP5100 TCO watchdog refuses to disarm at shutdown. Ordinarily harmless — but a hardware
watchdog that *fires* performs an immediate reset with **no sync and no journal flush**,
which is exactly the mechanism that produces this class of corruption. If the machine ever
hung for ten minutes, this watchdog reset it.

**2. Hibernation** — the disko config sets `resumeDevice = true` on a 4 GB swap partition.
A botched or partial resume restores in-memory filesystem state that no longer matches
what is on disk, and is a classic cause of ext4 corruption. 4 GB is also almost certainly
smaller than system RAM, which makes hibernation unreliable to begin with.

**3. An unclean boot earlier in the timeline.** The boot list shows boot `-3` ending
2026-08-10 23:44:40, with the failure surfacing on boot `-2`. Worth checking:

```bash
journalctl -b -3 -n 40
journalctl -k -p err --since "2026-08-08" | grep -iE 'panic|oops|BUG|hung task|EXT4-fs error|I/O error'
```

---

## 7. Why the tuigreet password failed intermittently

After pressing `*` to ignore the error and continue, the password was rejected several
times before working. This was the same corruption, not a second fault.

PAM authentication reads shadow and nsswitch data through ordinary directory lookups. When
a directory index is inconsistent — or when the kernel's cached view diverges from what is
on disk — those lookups can fail nondeterministically. The result is exactly the observed
"fails a few times, then randomly succeeds" pattern.

It resolved once the filesystem was consistent. Had it persisted after a clean `e2fsck`,
that would have been a genuinely separate problem worth chasing.

---

## 8. Prevention

### Never press `*` at that prompt

`*` (ignore and continue) mounts a known-damaged ext4 **read-write**. Every subsequent write
compounds the damage. When stage 1 reports an inconsistency, the only safe responses are
`r` (reboot and fix it properly) or `i` (fix it now).

### Investigate the watchdog

Check whether `systemd.watchdog.*` options are set in the config. If nothing depends on the
hardware watchdog, consider disabling it:

```nix
boot.blacklistedKernelModules = [ "sp5100_tco" ];
```

Or set an explicit runtime watchdog policy rather than leaving the firmware default in
place. Verify whether `watchdog did not stop!` appears on every shutdown or only some.

### Resolve the hibernation question

If hibernation is not actually used, drop it:

```nix
swap = {
  name = "swap";
  size = "4G";
  content = {
    type = "swap";
    # resumeDevice = true;   # remove unless hibernate is genuinely used
  };
};
```

If it *is* used, the swap partition must be **at least as large as physical RAM** —
ideally RAM + a margin. 4 GB is too small for any modern desktop.

### Force periodic full checks

NixOS runs `fsck -a` (preen) at every boot, which only performs repairs it considers
unambiguously safe — which is why this problem was reported rather than fixed. A periodic
forced full check catches drift earlier:

```bash
# Full check every 30 mounts or every month, whichever comes first
sudo tune2fs -c 30 -i 1m /dev/disk/by-partlabel/disk-main-root

# Inspect current settings
sudo tune2fs -l /dev/disk/by-partlabel/disk-main-root | grep -i 'mount count\|check interval\|state'
```

### Keep recovery tools installed

```nix
environment.systemPackages = with pkgs; [
  nvme-cli
  smartmontools
  e2fsprogs
];
```

Diagnosing a disk problem is harder when the diagnostic tools require a working network.

### Keep a NixOS installer USB on hand

The initrd shell worked here, but it is not guaranteed to be available. An installer ISO is
the fallback for every scenario in this document and costs nothing to prepare in advance.

### Back up what Nix cannot rebuild

The Nix store is reproducible — `nix-store --verify --repair` demonstrated exactly that.
`/home`, `/var/lib/sops-nix`, and any unpushed config work are not. Consider `restic` or
`borgbackup` on a timer.

### Consider `boot.shell_on_fail` permanently — with caveats

Adding it to `boot.kernelParams` means the recovery shell is always available without
editing the boot entry under pressure. The trade-off is that anyone with physical access
can obtain a root shell by inducing a stage-1 failure. Reasonable on a trusted personal
desktop; not on a laptop that travels.

---

## 9. Quick reference

```bash
# --- Diagnose ---
sudo nix run nixpkgs#nvme-cli -- smart-log /dev/nvme0n1
sudo nix run nixpkgs#smartmontools -- smartctl -a /dev/nvme0n1
journalctl --list-boots | tail -20
journalctl -b -1 -n 40
journalctl -k -p err | grep -iE 'panic|oops|BUG|hung task|EXT4-fs error|I/O error'
sudo tune2fs -l /dev/disk/by-partlabel/disk-main-root | grep -i state

# --- Repair (initrd shell only, filesystem UNMOUNTED) ---
cat /proc/mounts | grep mnt-root        # must return nothing
e2fsck -f -y /dev/disk/by-partlabel/disk-main-root
echo $?                                  # 0 or 1 good; 4 = uncorrected errors
e2fsck -f -y /dev/disk/by-partlabel/disk-main-root   # confirmation pass

# --- After repair ---
sudo ls /lost+found
sudo nix-store --verify --check-contents --repair
```

---

## 10. Unrelated config note

The disko config declares the BIOS boot partition with a filesystem:

```nix
boot = {
  name = "boot";
  size = "1M";
  type = "EF02";
  content = {
    type = "filesystem";     # <-- should not be here
    format = "vfat";
  };
};
```

An `EF02` BIOS boot partition holds GRUB's raw `core.img` and **must not** carry a
filesystem. On a UEFI system (systemd-boot, as confirmed by the boot menu) this partition is
vestigial and the mistake is harmless, but the `content` block should simply be omitted:

```nix
boot = {
  name = "boot";
  size = "1M";
  type = "EF02";
};
```

Entirely unrelated to the corruption — worth tidying while in the area.

---

## 11. Filesystem state after repair

```
1649423 / 60727296 files      (0.4% non-contiguous)
91780968 / 242879232 blocks   (~38% full)
e2fsck 1.47.3 (8-Jul-2025)
```

Healthy fragmentation, comfortable free space, clean check.
