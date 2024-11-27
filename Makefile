fmt:
	stylua lua --config-path=./.stylua.toml

lint:
	luacheck lua --globals vim describe it assert

test:
	nvim --headless -c "PlenaryBustedDirectory lua"

all: fmt lint test
