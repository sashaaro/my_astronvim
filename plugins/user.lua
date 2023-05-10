return {
  -- You can also add new plugins here as well:
  -- Add plugins, the lazy syntax
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function()
  --     require("lsp_signature").setup()
  --   end,
  -- },
     {
          "phaazon/hop.nvim",
          event = {"BufEnter"},
          config = function()
               require("hop").setup()
          end,
     },
     {
          "christoomey/vim-tmux-navigator",
          lazy = false
     },
     {
          dir = "/home/sasha/.config/nvim/lua/user/plugins/my-plugin",
          lazy = false,
          config = function()
               require('my-plugin').setup()
          end
     },
}
