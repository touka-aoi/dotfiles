-- ---- 表示 ----
vim.opt.number = true          -- 行番号
vim.opt.cursorline = true      -- カーソルのある行を強調
vim.opt.signcolumn = "yes"     -- 左端の記号欄を常に表示（表示がずれないように）
vim.opt.scrolloff = 5          -- カーソルの上下に最低5行を残してスクロール
vim.opt.termguicolors = true   -- 24bit カラー
vim.opt.list = true            -- タブと行末の空白を見えるようにする
vim.opt.listchars = { tab = "» ", trail = "·" }

-- ---- インデント（2スペース） ----
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true       -- タブの代わりにスペースを入れる
vim.opt.smartindent = true

-- ---- 検索 ----
vim.opt.ignorecase = true      -- 大文字・小文字を区別しない
vim.opt.smartcase = true       -- ただし大文字を含めたときは区別する

-- ---- 操作 ----
vim.opt.mouse = "a"            -- マウスを使えるようにする
vim.opt.undofile = true        -- 閉じても undo の履歴を残す
vim.opt.splitright = true      -- 縦分割は右に開く
vim.opt.splitbelow = true      -- 横分割は下に開く

-- ---- クリップボード ----
-- ヤンク（y）とペースト（p）を OS のクリップボードと共有する
vim.opt.clipboard = "unnamedplus"

-- WSL では Windows のクリップボードとやり取りする（Mac は設定不要）
if vim.fn.has("wsl") == 1 then
  local osc52 = require("vim.ui.clipboard.osc52")
  -- PowerShell から UTF-8 で受け取り、Windows の改行（\r）を取り除く
  local paste = {
    "powershell.exe", "-NoLogo", "-NoProfile", "-Command",
    "[Console]::OutputEncoding = [Text.Encoding]::UTF8; "
      .. "$c = Get-Clipboard -Raw; "
      .. "if ($c) { [Console]::Out.Write($c.Replace(\"`r\", \"\")) }",
  }
  vim.g.clipboard = {
    name = "WSL",
    -- コピーは端末の OSC 52 を使う（日本語が文字化けせず、高速）
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
    cache_enabled = 0,
  }
end

-- ---- キー割り当て ----
vim.g.mapleader = " "
-- 挿入モードで jj を押すとノーマルモードに戻る
vim.keymap.set("i", "jj", "<Esc>")
-- Esc で検索結果のハイライトを消す
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
-- 折り返された行でも見た目どおりに上下移動する
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")
