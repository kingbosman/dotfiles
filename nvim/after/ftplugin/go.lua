-- Go uses real tabs (enforced by gofmt), but the default tabstop=8 makes
-- them look enormous. Setting tabstop=4 is purely visual — files still store
-- actual tab characters, so gofmt and all tooling remains happy.
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = false
