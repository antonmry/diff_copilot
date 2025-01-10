# Diff Copilot Neovim

This is a Neovim plugin that integrates with GitHub Copilot to provide enhanced
vimdiff capabilities.

https://github.com/user-attachments/assets/35e64933-bc4f-4cb9-9c5c-a59e30f27b37

https://github.com/user-attachments/assets/7bcfefe1-6ca2-4faa-a3a3-23e843a641a3


## Installation

To install this plugin, you can use your preferred plugin manager. For example,
using `lazy.nvim`:

```lua
{
	"antonmry/diff_copilot.nvim",
	dependencies = { "CopilotC-Nvim/CopilotChat.nvim", "jpalardy/vim-slime" },
	config = true,
   }
```

## Usage

Once installed, you can use the following commands to interact with the plugin:

- `:DiffCopilot` - Asks for the prompt and directly opens the diff view with
  Copilot suggestions.
- `:DiffRequest` - Sends the content of the registry `o` as prompt and opens the
  diff view with Copilot suggestions. The registry `o` is automatically
  populated with the content of `/tmp/output.log`.
- `:SendR` - Sends the content of the registry `r` to the terminal using
  `vim-slime`.

`SendR` and `DiffRequest` are intended to be used with
[antonmry/llm-helper-cli].

## Contributing

Contributions are welcome! Please open an issue or submit a pull request on
GitHub.

## License

This project is licensed under the MIT License.

[antonmry/llm-helper-cli]: https://github.com/antonmry/llm-helper-cli
