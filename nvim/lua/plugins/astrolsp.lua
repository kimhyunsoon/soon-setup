return {
  "AstroNvim/astrolsp",
  opts = {
    features = {
      autoformat = false,
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    formatting = {
      format_on_save = {
        enabled = false,
      },
    },
    config = {
      clangd = { capabilities = { offsetEncoding = "utf-8" } },
    },
    mappings = {
      n = {
      },
    },
  },
}
