-- Plugin Installation
require("packer").startup(function(use)
	-- Themeing
	use({ "rose-pine/neovim", as = "rose-pine" })
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
	use("mbbill/undotree")

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
	use("nvim-treesitter/nvim-treesitter-context")

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
	use("github/copilot.vim")

	-- Fuzzy Finder
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.4",
		requires = { { "nvim-lua/plenary.nvim" } },
	})
end)

-- Globals
local lsp = require("lsp-zero")
local cmp = require("cmp")
local null_ls = require("null-ls")
local tree = require("nvim-tree")
local treesitter = require("nvim-treesitter.configs")
local context = require("treesitter-context")
local rebind = require("which-key")
local formatter = require("formatter")
local lualine = require("lualine")
local tabbar = require("tabby.tabline")
local rosepine = require("rose-pine")

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

rosepine.setup({
	--- @usage 'auto'|'main'|'moon'|'dawn'
	variant = "main",
	--- @usage 'main'|'moon'|'dawn'
	dark_variant = "main",
	bold_vert_split = true,
	dim_nc_background = false,
	disable_background = true,
	disable_float_background = true,
	disable_italics = false,

	--- @usage string hex value or named color from rosepinetheme.com/palette
	groups = {
		background = "base",
		background_nc = "_experimental_nc",
		panel = "surface",
		panel_nc = "base",
		border = "highlight_med",
		comment = "muted",
		link = "iris",
		punctuation = "subtle",

		error = "love",
		hint = "iris",
		info = "foam",
		warn = "gold",

		headings = {
			h1 = "iris",
			h2 = "foam",
			h3 = "rose",
			h4 = "gold",
			h5 = "pine",
			h6 = "foam",
		},
		-- or set all headings at once
		-- headings = 'subtle'
	},

	-- Change specific vim highlight groups
	-- https://github.com/rose-pine/neovim/wiki/Recipes
	highlight_groups = {
		ColorColumn = { bg = "rose" },

		-- Blend colours against the "base" background
		CursorLine = { bg = "foam", blend = 10 },
		StatusLine = { fg = "love", bg = "love", blend = 10 },

		-- By default each group adds to the existing config.
		-- If you only want to set what is written in this config exactly,
		-- you can set the inherit option:
		Search = { bg = "gold", inherit = false },
	},
})

-- vim.cmd("set fillchars+=vert:\\ ") -- fixes weird pixel border when trans.
vim.cmd("au ColorScheme * hi Normal ctermbg=none guibg=none")
vim.cmd("au ColorScheme myspecialcolors hi Normal ctermbg=red guibg=red")
vim.cmd("colorscheme rose-pine")

-- Return to last position in previously opened file
vim.api.nvim_create_autocmd(
	"BufReadPost",
	{ command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]] }
)

-- Init LSP
lsp.on_attach(function(client, bufnr)
	-- see :help lsp-zero-keybindings
	-- to learn the available actions
	lsp.default_keymaps({ buffer = bufnr })
end)

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = {},
	handlers = {
		lsp.default_setup,
	},
})

---- By default, LSP Zero uses up and down arrow keys to move through suggestions.
---- Restore to Vim's default (C-n and C-p)
local cmp_action = lsp.cmp_action()
cmp.setup({
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

context.setup({
	enable = true,
	max_lines = 0,
	min_window_height = 0,
	line_numbers = true,
	multiline_threshold = 20,
	trim_scope = "outer",
	mode = "cursor",
	separator = nil,
	zindex = 20,
})

-- Misc Setup & Rebinds
lualine.setup({
	options = {
		theme = "auto",
		component_separators = { left = "|", right = "|" },
		section_separators = { left = "", right = "" },
	},
})
tree.setup({})

rebind.register({
	["<Leader>n"] = { "<Cmd>NvimTreeFindFileToggle<CR>", "Toggle Tree" },
	["s"] = { "<Plug>(easymotion-overwin-f)", "Easymotion" },
	["<Leader>p"] = { "<cmd>lua require('telescope.builtin').find_files()<cr>", "Find Files" },
	["<Leader>f"] = { "<cmd>lua require('telescope.builtin').live_grep()<cr>", "Search Files" },
	["<Leader>u"] = { "<Cmd>UndotreeToggle<CR>", "Undo Tree" },
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
		elixir = {
			function()
				local args
				local util = require("formatter.util")
				local supports_stdin_filename =
					string.match(vim.fn.system("mix format --stdin-filename"), "Missing argument")

				if supports_stdin_filename ~= nil then
					args = { "format", "-", "--stdin-filename", util.escape_path(util.get_current_buffer_file_path()) }
				else
					args = { "format", "-" }
				end

				return { exe = "mix", args = args, stdin = true }
			end,
		},
		yaml = { require("formatter.filetypes.yaml").prettier },
		toml = { require("formatter.filetypes.toml").prettier },
		["*"] = { require("formatter.filetypes.any").remove_trailing_whitespace },
	},
})

tabbar.set(function(line)
	local theme = {
		fill = "Normal",
		head = { bg = "#ebbcba", fg = "#191724" },
		current_tab = { bg = "#9ccfd8", fg = "#191724" },
		tab = { bg = "#191724", fg = "#403d52" },
		win = "TabLine",
		tail = "TabLine",
	}

	return {
		{
			{ " (っ˘ڡ˘ς) ", hl = theme.head },
			line.sep("", theme.head, theme.fill),
		},
		line.tabs().foreach(function(tab)
			local hl = tab.is_current() and theme.current_tab or theme.tab
			local sepl = tab.is_current() and " " or " "
			local sepr = tab.is_current() and "" or ""

			return {
				line.sep(sepl, hl, theme.fill),
				tab.current_win().file_icon(),
				tab.name(),
				tab.close_btn(""),
				line.sep(sepr, hl, theme.fill),
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
