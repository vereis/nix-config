-- Plugin Installation
require("packer").startup(function(use)
	-- Themeing
	use({ "catppuccin/nvim", as = "catppuccin" })
	use({ "nvim-lualine/lualine.nvim", requires = { "kyazdani42/nvim-web-devicons", opt = true } })
	use({ "kyazdani42/nvim-tree.lua", requires = { "kyazdani42/nvim-web-devicons" } })
	use({ "nanozuki/tabby.nvim", requires = { "kyazdani42/nvim-web-devicons" } })

	-- Tim Pope's STDLIB
	use("tpope/vim-fugitive")
	use("tpope/vim-abolish")
	use("tpope/vim-surround")
	use("tpope/vim-repeat")
	use("tpope/vim-eunuch")
	use("tpope/vim-endwise")

	-- Extended STDLIB
	use("machakann/vim-swap")
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
			{ "williamboman/mason.nvim" },
			{ "williamboman/mason-lspconfig.nvim" },

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

	-- Fuzzy Finder
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.0",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
end)

-- Globals
local lsp = require("lsp-zero")
local cmp = require("cmp")
local null_ls = require("null-ls")
local tree = require("nvim-tree")
local treesitter = require("nvim-treesitter.configs")
local rebind = require("which-key")
local formatter = require("formatter")
local lualine = require("lualine")
local tabbar = require("tabby.tabline")
local catppuccin = require("catppuccin")

-- Defaults
vim.g.mapleader = " "
vim.opt.termguicolors = true

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

-- Always show tabbar
vim.opt.showtabline = 2

-- Init Colorscheme
catppuccin.setup({
	color_overrides = {
		all = {
			base = "#030303",
			mantle = "#030303",
			crust = "#030303",
		},
	},
})

vim.cmd("colorscheme catppuccin")

-- Return to last position in previously opened file
vim.api.nvim_create_autocmd(
	"BufReadPost",
	{ command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]] }
)

-- Init LSP
lsp.preset("recommended")
lsp.nvim_workspace()

---- By default, LSP Zero uses up and down arrow keys to move through suggestions.
---- Restore to Vim's default (C-n and C-p)
local cmp_select = { behavior = cmp.SelectBehavior.Select }
local cmp_mappings = lsp.defaults.cmp_mappings({
	["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
	["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
})
cmp_mappings["<Tab>"] = nil -- Delete the tab key mapping for LSP since I prefer C-n

lsp.setup_nvim_cmp({
	mapping = cmp_mappings,
	-- Override completion so nothing is selected by default, meaning I have to opt into it
	-- with C-n or C-p
	completion = { completeopt = "menu,menuone,noinsert,noselect" },
})

lsp.setup()
vim.diagnostic.config({ virtual_text = true })

require("lspconfig").grammarly.setup({
	init_options = { clientId = "client_BaDkMgx4X19X9UxxYRCXZo" },
})

null_ls.setup({
	on_attach = lsp.build_options("null-ls", {}).on_attach,
	sources = {
		null_ls.builtins.completion.spell,
		null_ls.builtins.diagnostics.vale,
	},
})

-- Init TreeSitter
treesitter.setup({
	ensure_installed = "all",
	highlight = {
		enable = true,
	},
})

-- Misc Setup & Rebinds
lualine.setup()

tree.setup({
	view = {
		mappings = {
			list = {
				{ key = "u", action = "dir_up" },
			},
		},
	},
})

rebind.register({
	["<C-n>"] = { "<Cmd>NvimTreeFindFileToggle<CR>", "Toggle Tree" },
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

tabbar.set(function(line)
	local theme = {
		fill = "TabLineFill",
		head = "TabLine",
		current_tab = "TabLineSel",
		tab = "TabLine",
		win = "TabLine",
		tail = "TabLine",
	}

	return {
		{
			{ "  ", hl = theme.tead },
			line.sep("", theme.head, theme.fill),
		},
		line.tabs().foreach(function(tab)
			local hl = tab.is_current() and theme.current_tab or theme.tab

			return {
				line.sep("", hl, theme.fill),
				tab.current_win().file_icon(),
				tab.name(),
				tab.close_btn(""),
				line.sep("", hl, theme.fill),
				hl = hl,
				margin = " ",
			}
		end),
		hl = theme.fill,
	}
end)

vim.api.nvim_exec(
	[[
augroup FormatAutogroup
  autocmd!
  autocmd BufWritePost * FormatWrite
augroup END
]],
	true
)
