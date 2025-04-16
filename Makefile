.PHONY: all fmt lint test

all: fmt lint test

fmt:
	stylua lua --config-path=.stylua.toml

lint:
	luacheck lua --globals vim describe it assert

test:
	nvim -l scripts/minitest.lua
