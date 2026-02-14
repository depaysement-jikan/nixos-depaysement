return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
  },
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    local on_attach = function(client, bufnr)
      -- Enable completion triggered by <c-x><c-o>
      vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

      -- Mappings.
      -- See `:help vim.lsp.*` for documentation on any of the below functions
      local bufopts = { noremap = true, silent = true, buffer = bufnr }
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
      vim.keymap.set("n", "<leader>k", vim.lsp.buf.signature_help, bufopts)
      vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
      vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
      vim.keymap.set("n", "<leader>wl", function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, bufopts)
      vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, bufopts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
      vim.keymap.set("n", "<leader>f", function()
        vim.lsp.buf.format({ async = true })
      end, bufopts)
    end

    -- TypeScript
    lspconfig.tsserver.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Angular
    lspconfig.angularls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Lua
    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        Lua = {
          runtime = {
            version = "LuaJIT",
          },
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
          },
        },
      },
    })

    -- Go
    lspconfig.gopls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        gopls = {
          completeUnimported = true,
          usePlaceholders = true,
          analyses = {
            unusedparams = true,
          },
        },
      },
    })

    -- Bash
    lspconfig.bashls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Python
    lspconfig.pyright.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            diagnosticMode = "workspace",
            useLibraryCodeForTypes = true,
          },
        },
      },
    })

    -- CSS
    lspconfig.cssls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- HTML
    lspconfig.html.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- JSON
    lspconfig.jsonls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Docker
    lspconfig.dockerls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- Marksman
    lspconfig.marksman.setup({
      capabilities = capabilities,
      on_attach = on_attach,
    })

    -- graphql
    lspconfig.graphql.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "graphql", "typescriptreact", "javascriptreact", "gql", "*.gql" },
    })

    -- nix
    lspconfig.nixd.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "nix" },
    })
  end,
}
