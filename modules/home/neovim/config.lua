-- Plugin Installation
require("packer").startup(function(use)
	-- Themeing
	use("flazz/vim-colorschemes")
	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
	})

	-- Tim Pope's STDLIB
	use("tpope/vim-fugitive")
	use("tpope/vim-abolish")
	use("tpope/vim-surround")
	use("tpope/vim-repeat")
	use("tpope/vim-eunuch")
	use("tpope/vim-endwise")

	-- Extended STDLIB
	use("machakann/vim-swap")
	use("scrooloose/nerdtree")
	use("airblade/vim-gitgutter")
	use("easymotion/vim-easymotion")

	-- NVIM Lua sucks at key rebinding
	use("folke/which-key.nvim")

	-- Neovim LSP
	use("mhartington/formatter.nvim")
	use({ "jose-elias-alvarez/null-ls.nvim", run = "vale sync" })
	use({
		"nvim-treesitter/nvim-treesitter",
		run = function()
			require("nvim-treesitter.install").update({ with_sync = true })
		end,
	})

	use({
		"VonHeikemen/lsp-zero.nvim",
		requires = {
			-- Core Modules
			{ "neovim/nvim-lspconfig" },
			{ "williamboman/nvim-lsp-installer" },

			-- Auto Complete
			{ "hrsh7th/nvim-cmp" },
			{ "hrsh7th/cmp-buffer" },
			{ "hrsh7th/cmp-path" },
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "hrsh7th/cmp-nvim-lua" },

			-- Snippets
			{ "L3MON4D3/LuaSnip" },
			{ "rafamadriz/friendly-snippets" },
		},
	})

	-- File Tree
	use({
		"kyazdani42/nvim-tree.lua",
		requires = { "kyazdani42/nvim-web-devicons" },
	})

	-- Fuzzy Finder
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
end)

-- Globals
local lsp = require("lsp-zero")
local null_ls = require("null-ls")
local null_opts = lsp.build_options("null-ls", {})
local tree = require("nvim-tree")
local treesitter = require("nvim-treesitter.configs")
local rebind = require("which-key")
local formatter = require("formatter")
local lualine = require("lualine")

-- Defaults
vim.g.mapleader = " "

vim.opt.hidden = true
vim.opt.lazyredraw = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.cursorline = true

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true

vim.opt.signcolumn = "yes"
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 8

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

vim.opt.showmatch = true
vim.opt.incsearch = true
vim.opt.hlsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Default Completions
vim.opt.completeopt = "menuone,noinsert,noselect"
vim.opt.shortmess = vim.o.shortmess .. "c"

-- Init Colorscheme
pcall(vim.cmd, "colorscheme monokain")
pcall(vim.cmd, "highlight Normal ctermbg=None")

-- Trailing Whitespace is bad
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
	pattern = { "*" },
	command = [[%s/\s\+$//e]],
})

-- Return to last position in previously opened file
vim.api.nvim_create_autocmd(
	"BufReadPost",
	{ command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]] }
)

-- Init LSP
null_ls.setup({
	on_attach = null_opts.on_attach,
	sources = {
		null_ls.builtins.completion.spell,
		null_ls.builtins.diagnostics.vale,
	},
})

lsp.preset("recommended")
lsp.nvim_workspace()
lsp.setup()
vim.diagnostic.config({ virtual_text = true })

-- Init TreeSitter
treesitter.setup({
	ensure_installed = "all",
	highlight = {
		enable = true,
	},
})

-- Misc Setup & Rebinds
lualine.setup()
tree.setup()
rebind.register({
	["<C-n>"] = { "<Cmd>NvimTreeToggle<CR>", "Toggle Tree" },
	["s"] = { "<Plug>(easymotion-overwin-f)", "Easymotion" },
	["<C-p>"] = { "<cmd>lua require('telescope.builtin').find_files()<cr>", "Find Files" },
	["<C-f>"] = { "<cmd>lua require('telescope.builtin').live_grep()<cr>", "Search Files" },
})

formatter.setup({
	filetype = {
		css = { require("formatter.filetypes.css").prettier },
		html = { require("formatter.filetypes.html").prettier },
		graphql = { require("formatter.filetypes.graphql").prettier },
		json = { require("formatter.filetypes.json").prettier },
		javascript = { require("formatter.filetypes.javascript").prettier },
		javascriptreact = { require("formatter.filetypes.javascriptreact").prettier },
		typescript = { require("formatter.filetypes.typescript").prettier },
		typescriptreact = { require("formatter.filetypes.typescriptreact").prettier },
		markdown = { require("formatter.filetypes.markdown").prettier },
		lua = { require("formatter.filetypes.lua").stylua },
		elixir = { require("formatter.filetypes.elixir").mixformat },
		yaml = { require("formatter.filetypes.yaml").prettier },
		toml = { require("formatter.filetypes.toml").prettier },
		["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace },
	},
})

vim.api.nvim_exec(
	[[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost * FormatWrite
augroup END
]],
	true
)
