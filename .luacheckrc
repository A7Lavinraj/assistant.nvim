globals = {
  "vim",
  "describe",
  "assert",
  "it",
}

exclude_files = {
  "**/*_spec.lua", -- Ignore all files ending with _spec.lua at any depth
}

files = {
  ["scripts/*.lua"] = {
    stds = "lua53",
    globals = { "script_global" },
  },
}

exclude_files = {
  "__test__/*", -- Ignore top-level __test__ directory
  "**/__test__/*", -- Ignore nested __test__ directories
}
