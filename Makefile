# include .env file and export its env vars
# (-include to ignore error if it does not exist)
# Note that any unset variables here will wipe the variables if they are set in
# .zshrc or .bashrc. Make sure that the variables are set in .env, especially if
# you're running into issues with fork tests
-include .env

# forge coverage

coverage :; forge coverage --report summary --match-path test/*

coverage-report :; forge coverage --report lcov && lcov --remove lcov.info  -o lcov.info 'test/*' 'script/*' && genhtml lcov.info --branch-coverage --output-dir coverage
