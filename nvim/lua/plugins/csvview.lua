return {
	"hat0uma/csvview.nvim",
	ft = { "csv" }, -- load plugin only when a .csv file is opened
	cmd = { "CsvViewEnable", "CsvViewDisable", "CsvViewToggle" },
	opts = {
		display_mode = "border",
		parser = { comments = { "#", "//" } },
		keymaps = {
			textobject_field_inner = { "if", mode = { "o", "x" } },
			textobject_field_outer = { "af", mode = { "o", "x" } },
			jump_next_field_end = { "<Tab>", mode = { "n", "v" } },
			jump_prev_field_end = { "<S-Tab>", mode = { "n", "v" } },
			jump_next_row = { "<Enter>", mode = { "n", "v" } },
			jump_prev_row = { "<S-Enter>", mode = { "n", "v" } },
		},
	},

	-- Automatically enable CsvView when entering a CSV file
	init = function()
		vim.api.nvim_create_autocmd({ "FileType" }, {
			pattern = "csv",
			callback = function()
				vim.schedule(function()
					-- Only run if the buffer is actually a CSV file
					if vim.bo.filetype == "csv" then
						vim.cmd("CsvViewEnable")
					end
				end)
			end,
			desc = "Auto-enable csvview.nvim on CSV files",
		})
	end,
}
