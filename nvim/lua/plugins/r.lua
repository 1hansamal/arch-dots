return {
  {
    "R-nvim/R.nvim",
    lazy = false,
    config = function()
      ---@type RConfigUserOpts
      local opts = {
        R_args = { "--quiet", "--no-save" },
        min_editor_width = 72,
        rconsole_width = 78,
        objbr_auto_start = true,
        objbr_place = "RIGHT",
        ["R-language-server"] = {
          enabled = true,
        },
        hook = {
          on_filetype = function()
            vim.api.nvim_buf_set_keymap(0, "n", "<Enter>", "<Plug>RDSendLine", {})
            vim.api.nvim_buf_set_keymap(0, "v", "<Enter>", "<Plug>RSendSelection", {})

            -- Insert dput() output of the word under cursor
            vim.keymap.set("n", "<LocalLeader>dp", function()
              local word = vim.fn.expand("<cword>")
              if word == "" then
                vim.notify("No word under cursor", vim.log.levels.WARN)
                return
              end
              vim.cmd("RInsert dput(" .. word .. ")")
            end, { buffer = true, desc = "RInsert dput() of word under cursor" })
          end,
        },
      }
      require("r").setup(opts)
    end,
  },
}