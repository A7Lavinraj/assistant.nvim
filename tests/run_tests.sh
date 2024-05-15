#!/bin/bash

nvim --headless -u "tests/init.lua" -c "PlenaryBustedDirectory tests {minimal_init = 'tests/init.lua', sequential = true}"
# nvim --headless -u "tests/init.lua" -c "lua require('plenary') print('setup complete')"
