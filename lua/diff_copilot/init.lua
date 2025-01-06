local M = {}

local chat = require("CopilotChat")

function M.diffCopilot()
	vim.cmd("diffthis")
	-- Create a floating window
	local buf = vim.api.nvim_create_buf(false, true)
	local width = vim.o.columns
	local height = vim.o.lines
	local win_width = math.ceil(width * 0.8)
	local win_height = math.ceil(height * 0.8)
	local row = math.ceil((height - win_height) / 2)
	local col = math.ceil((width - win_width) / 2)

	local opts = {
		style = "minimal",
		relative = "editor",
		width = win_width,
		height = win_height,
		row = row,
		col = col,
		border = "single",
	}

	local win = vim.api.nvim_open_win(buf, true, opts)
	local current_buf = vim.api.nvim_get_current_buf()

	-- Set keymap to close the floating window
	vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", "<Cmd>bd!<CR>", { noremap = true, silent = true })

	-- Set keymap to send input to chat.ask
	vim.api.nvim_buf_set_keymap(
		buf,
		"n",
		"<CR>",
		':lua require("diff_copilot.init").send_input(' .. buf .. ", " .. win .. ")<CR>",
		{ noremap = true, silent = true }
	)

	-- Store the buffer and window id for later use
	M.buf = buf
	M.win = win
end

function M.send_input(buf, win)
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	vim.api.nvim_win_close(win, true)

	chat.ask("/Diff " .. table.concat(lines, "\n"), {
		callback = function(response)
			local lines = vim.split(response, "\n")
			if lines[1]:match("^```") then
				table.remove(lines, 1)
			end
			if lines[#lines]:match("^```") then
				table.remove(lines, #lines)
			end

			vim.cmd("vnew")
			local new_buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, lines)
			vim.cmd("diffthis")
		end,
	})
	vim.api.nvim_command("CopilotChatClose")
end

function M.create_diff_prompt()
	chat.config.prompts["Diff"] = {
		prompt = "",
		system_prompt = "Your task is to create code according to the user's request. Follow these instructions precisely. Return ONLY the proposed code. You can add explanations in comments inside the code, but not outside. The response should compile and run without errors or any modification. Don't add explanations or comments after the code. Don't add any explanation and return only a single block of code.",
		description = "This is a prompt for a diff task",
	}
end

function M.setup()
	-- Configuration for diff_copilot.nvim
	M.create_diff_prompt()
	vim.api.nvim_create_user_command("DiffCopilot", M.diffCopilot, {})
	-- Only for testing
	--vim.api.nvim_create_user_command("CreateDiffPrompt", M.create_diff_prompt, {})

	-- Configuration for diff_copilot.output (provisional)
	require("diff_copilot.output").setup()
end

return M
