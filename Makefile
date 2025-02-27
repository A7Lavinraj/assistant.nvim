all: fmt lint test

fmt:
	stylua lua --config-path=./.stylua.toml

lint:
	luacheck lua --globals vim describe it assert

test:
	nvim -l scripts/minit.lua
