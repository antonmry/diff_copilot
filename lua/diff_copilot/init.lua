local M = {}

local chat = require("CopilotChat")

local function handleResponse(response)
	local diff = vim.split(response, "\n")
	local start_idx, end_idx = nil, nil
	for i, line in ipairs(diff) do
		if line:match("^```") then
			if not start_idx then
				start_idx = i
			else
				end_idx = i
				break
			end
		end
	end

	if start_idx and end_idx then
		diff = { unpack(diff, start_idx + 1, end_idx - 1) }
		vim.cmd("vnew")
		local new_buf = vim.api.nvim_get_current_buf()
		vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, diff)
		vim.cmd("diffthis")
		vim.api.nvim_command("CopilotChatClose")
	else
		print("Diff Error: Invalid response")
	end
end

function M.diff_request()
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
			handleResponse(response)
		end,
	})
end

function M.process_output()
	local content = vim.fn.getreg("o")
	chat.ask("/Diff Fix " .. content, {
		callback = function(response)
			handleResponse(response)
		end,
	})
end

local function create_diff_prompt()
	chat.config.prompts["Diff"] = {
		prompt = "",
		system_prompt = "Your task is to create code according to the user's request. Follow these instructions precisely. Return ONLY the full file with the proposed change. You can add explanations in comments inside the code, but not outside. The response should compile and run without errors or any modification. Don't add explanations or comments after the code. Don't add any explanation and return only a single block of code.",
		description = "This is a prompt for a diff task",
	}
end

function M.setup()
	-- Configuration for diff_request
	create_diff_prompt()
	vim.api.nvim_create_user_command("DiffRequest", M.diff_request, {})

	-- Configuration for diff_output
	require("diff_copilot.output").setup()
	vim.api.nvim_create_user_command("DiffOutput", M.process_output, {})
end

return M
