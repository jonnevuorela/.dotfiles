-- lua/plugins/jukit.lua
--    Category,Package/Tool,Mandatory?,Notes / Installation hint
--    Python runtime,python3,Yes,Must be callable as python3
--    IPython,ipython ≥ 7.3.0,Highly recommended,pip install ipython
--    Plotting,matplotlib ≥ 3.4.0,Recommended,Especially for inline plotting
--    Helper scripts,"pillow, beautifulsoup4, numpy",Yes (for most features),pip install pillow beautifulsoup4 numpy
--    Notebook conversion,nbconvert ≥ 6.4.4,Yes (for .ipynb ↔ .py),pip install nbconvert
--    Image display (opt),ueberzug,Optional,Manual git install (no longer on PyPI)
--    Image processing,ImageMagick,Yes (for images),System package (apt/yum/brew install imagemagick)
--    HTML → image (Überzug),cutycapt or wkhtmltoimage,Optional,System package or binary
--    Terminal,kitty ≥ 0.22,Optional,Best experience with in-terminal plots
--
--   https://github.com/seebye/ueberzug.git
--   imagemagick
--
--   pip install ipython matplotlib pillow beautifulsoup4 numpy nbconvert
return {
	"luk400/vim-jukit",
	lazy = false, -- force load at startup
	priority = 1000, -- load early

	config = function()
		print("vim-jukit config function running") -- debug

		vim.g.jukit_shell_cmd = "ipython3"
		vim.g.jukit_terminal = ""
		vim.g.jukit_inline_plotting = 0
		vim.g.jukit_mappings = 0

		local opts = { noremap = true, silent = true }
		local map = vim.keymap.set

		-- ── Splits ───────────────────────────────────────────────────────
		map("n", "<leader>Ro", ":call jukit#splits#output()<CR>", opts) -- open output split
		map("n", "<leader>Rt", ":call jukit#splits#term()<CR>", opts) -- open empty terminal split
		map("n", "<leader>Rh", ":call jukit#splits#history()<CR>", opts) -- open output-history split
		map("n", "<leader>RO", ":call jukit#splits#output_and_history()<CR>", opts) -- both
		map("n", "<leader>Rd", ":call jukit#splits#close_output_split()<CR>", opts) -- close output
		map("n", "<leader>RH", ":call jukit#splits#close_history()<CR>", opts) -- close history
		map("n", "<leader>RD", ":call jukit#splits#close_output_and_history(1)<CR>", opts) -- close both
		map("n", "<leader>Rs", ":call jukit#splits#show_last_cell_output(1)<CR>", opts) -- show cell output
		map("n", "<leader>Rj", ":call jukit#splits#out_hist_scroll(1)<CR>", opts) -- scroll output hist down
		map("n", "<leader>Rk", ":call jukit#splits#out_hist_scroll(0)<CR>", opts) -- scroll up
		map("n", "<leader>Ra", ":call jukit#splits#toggle_auto_hist()<CR>", opts) -- toggle auto history

		-- ── Sending code ─────────────────────────────────────────────────
		map("n", "<leader>R<space>", ":call jukit#send#section(0)<CR>", opts) -- send current cell
		map("n", "<leader>R<CR>", ":call jukit#send#line()<CR>", opts) -- send current line
		map("v", "<leader>R<CR>", ":<C-U>call jukit#send#selection()<CR>", opts) -- send visual selection
		map("n", "<leader>Rc", ":call jukit#send#until_current_section()<CR>", opts) -- run until current cell
		map("n", "<leader>Ra", ":call jukit#send#all()<CR>", opts) -- run all cells

		-- ── Cell operations ──────────────────────────────────────────────
		map("n", "<leader>Rco", ":call jukit#cells#create_below(0)<CR>", opts) -- new code cell below
		map("n", "<leader>RcO", ":call jukit#cells#create_above(0)<CR>", opts) -- new code cell above
		map("n", "<leader>Rct", ":call jukit#cells#create_below(1)<CR>", opts) -- new markdown cell below
		map("n", "<leader>RcT", ":call jukit#cells#create_above(1)<CR>", opts) -- new markdown cell above
		map("n", "<leader>Rcd", ":call jukit#cells#delete()<CR>", opts) -- delete cell
		map("n", "<leader>Rcs", ":call jukit#cells#split()<CR>", opts) -- split cell
		map("n", "<leader>RcM", ":call jukit#cells#merge_above()<CR>", opts) -- merge with cell above
		map("n", "<leader>Rcm", ":call jukit#cells#merge_below()<CR>", opts) -- merge with cell below
		map("n", "<leader>Rck", ":call jukit#cells#move_up()<CR>", opts) -- move cell up
		map("n", "<leader>Rcj", ":call jukit#cells#move_down()<CR>", opts) -- move cell down
		map("n", "<leader>RJ", ":call jukit#cells#jump_to_next_cell()<CR>", opts) -- jump to next cell
		map("n", "<leader>RK", ":call jukit#cells#jump_to_previous_cell()<CR>", opts) -- jump to previous cell

		-- ── Output management ────────────────────────────────────────────
		map("n", "<leader>Rddo", ":call jukit#cells#delete_outputs(0)<CR>", opts) -- delete current cell output
		map("n", "<leader>Rdda", ":call jukit#cells#delete_outputs(1)<CR>", opts) -- delete all outputs

		-- ── Notebook conversion ──────────────────────────────────────────
		map("n", "<leader>Rnp", ":call jukit#convert#notebook_convert('jupyter-notebook')<CR>", opts) -- toggle .py ↔ .ipynb
		map("n", "<leader>Rht", ":call jukit#convert#save_nb_to_file(0,1,'html')<CR>", opts) -- to HTML (no rerun)
		map("n", "<leader>Rrht", ":call jukit#convert#save_nb_to_file(1,1,'html')<CR>", opts) -- to HTML + rerun
		map("n", "<leader>Rpd", ":call jukit#convert#save_nb_to_file(0,1,'pdf')<CR>", opts) -- to PDF (no rerun)
		map("n", "<leader>Rrpd", ":call jukit#convert#save_nb_to_file(1,1,'pdf')<CR>", opts) -- to PDF + rerun

		-- Optional: Überzug position (if you use it)
		-- map("n", "<leader>Rpos", ":call jukit#ueberzug#set_default_pos()<CR>", opts)
	end,
}
