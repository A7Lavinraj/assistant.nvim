fmt:
	stylua lua/ --config-path=.stylua.toml

lint:
	luacheck lua/ --globals vim

test:
	nvim --headless -u "tests/init.lua" -c "PlenaryBustedDirectory tests {minimal_init = 'tests/init.lua', sequential = true}"

all: fmt lint test
