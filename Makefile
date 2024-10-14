fmt:
	stylua lua/ tests/ --config-path=./.stylua.toml

lint:
	luacheck lua/ tests/ --globals vim

test:
	nvim --headless -u "tests/init.lua" -c "PlenaryBustedDirectory tests {minimal_init = 'tests/init.lua', sequential = true}"

all: fmt lint test
