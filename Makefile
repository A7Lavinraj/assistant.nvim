fmt:
	stylua lua --config-path=./.stylua.toml

lint:
	luacheck lua --globals vim describe it assert

test:
	nvim --headless -u "__config__/init.lua" -c "PlenaryBustedDirectory lua {minimal_init = 'tests/init.lua', sequential = true}"

all: fmt lint test
