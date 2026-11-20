-- nvim の設定。chezmoi が ~/.config/nvim をこのディレクトリにリンクする
-- （chezmoi/dot_config/symlink_nvim.tmpl）。プラグインの版は lazy-lock.json で固定する。
-- 必要な外部コマンドは、Homebrew（mac/Brewfile）、mise（config/mise/config.toml）、
-- npm（chezmoi/.chezmoidata/packages.yaml）で入れる。

vim.g.mapleader = " "

local o = vim.o
o.number = true
o.ignorecase = true
o.smartcase = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.termguicolors = true
o.clipboard = "unnamedplus"
o.updatetime = 300
o.signcolumn = "yes"

-- lazy.nvim の取得。stable ブランチを使う
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("lazy.nvim の取得に失敗した:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- snacks.nvim は iTerm を端末として認識しない（対応は kitty、ghostty、wezterm のみ。
-- 2026-11-19 にソースで確認）。iTerm 3.7.7 は kitty graphics protocol に対応しているので、
-- iTerm のときだけ kitty として扱わせる。tmux の中では強制しない。
-- 実機の iTerm でインライン表示できるかは未確認
if vim.env.TERM_PROGRAM == "iTerm.app" and vim.env.SNACKS_KITTY == nil
  and vim.env.TMUX == nil then
  vim.env.SNACKS_KITTY = "true"
end

-- Treesitter で入れる言語。go と typescript の分と、Markdown の表示に要る分
local parsers = {
  "go", "gomod", "gosum", "gowork",
  "typescript", "tsx", "javascript", "json", "yaml", "html",
  "markdown", "markdown_inline", "latex",
}

require("lazy").setup({
  { "morhetz/gruvbox", priority = 1000,
    config = function() vim.cmd.colorscheme("gruvbox") end },
  "tpope/vim-fugitive",

  -- 構文ハイライトと Markdown の解析
  { "nvim-treesitter/nvim-treesitter", branch = "main", lazy = false, build = ":TSUpdate",
    config = function()
      require("nvim-treesitter").install(parsers)
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          -- パーサがないファイルタイプでは何もしない
          pcall(vim.treesitter.start, args.buf)
        end,
      })
    end },

  -- Go（gopls）と TypeScript（tsc --lsp）。gopls は mise、typescript は npm で入れる。
  -- tsc の LSP は TypeScript 7 以降にしかない。typescript-language-server は
  -- TypeScript 7 の lib に tsserver.js がなく動かなかったので使わない（2026-11-19 確認）
  { "neovim/nvim-lspconfig",
    config = function()
      vim.lsp.enable({ "gopls", "tsc" })
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local function map(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("gd", vim.lsp.buf.definition, "定義へ")
          -- VS Code と同じ。Mac では fn+F12。戻るのは Ctrl+o
          map("<F12>", vim.lsp.buf.definition, "定義へ")
          map("<S-F12>", vim.lsp.buf.references, "参照一覧")
          map("gD", vim.lsp.buf.declaration, "宣言へ")
          map("gi", vim.lsp.buf.implementation, "実装へ")
          map("gr", vim.lsp.buf.references, "参照一覧")
          map("<leader>rn", vim.lsp.buf.rename, "リネーム")
          map("<leader>f", function() vim.lsp.buf.format({ async = true }) end, "整形")
          map("<leader>e", vim.diagnostic.open_float, "診断を表示")
        end,
      })
    end },

  -- Mermaid や画像をインラインで表示する。mermaid は mmdc で画像に変換する。
  -- Markdown 本体は整形せず、そのまま表示する（整形表示は見にくかったため外した）
  --
  -- picker は git grep のためだけに有効にする。git grep は追跡しているファイルだけを見るので、
  -- node_modules や生成物が混ざらない。LSP が効かない言語や、文字列として探すときに使う
  { "folke/snacks.nvim", priority = 1000, lazy = false,
    opts = { image = { enabled = true }, picker = { enabled = true } },
    -- ":" から呼ぶ短いコマンド。:Gg は引数なしなら入力しながら検索する
    init = function()
      vim.api.nvim_create_user_command("Gg", function(c)
        Snacks.picker.git_grep(c.args ~= "" and { search = c.args } or {})
      end, { nargs = "*", desc = "git grep" })
      vim.api.nvim_create_user_command("Gf", function() Snacks.picker.git_files() end,
        { desc = "追跡ファイルを探す" })
      vim.api.nvim_create_user_command("Gb", function() Snacks.picker.buffers() end,
        { desc = "開いているバッファ" })
    end,
    keys = {
      { "<leader>/", function() Snacks.picker.git_grep() end, desc = "git grep（入力しながら検索）" },
      { "<leader>p", function() Snacks.picker.git_files() end, desc = "追跡ファイルを探す" },
      { "<leader>b", function() Snacks.picker.buffers() end, desc = "開いているバッファ" },
      { "<leader>*", function() Snacks.picker.git_grep({ search = vim.fn.expand("<cword>") }) end,
        desc = "git grep（カーソル下の単語）" },
    } },
}, {
  lockfile = vim.fn.stdpath("config") .. "/lazy-lock.json",
})
