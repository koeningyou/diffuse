.PHONY: build system vendor


# Variables

NPM_DIR=./node_modules
SRC_DIR=./src
BUILD_DIR=./build


# Default task

all: dev


#
# Build tasks
#

build: clean elm system vendor
	@echo "> Build completed ⚡"


clean:
	@echo "> Cleaning build directory"
	@rm -rf $(BUILD_DIR) || true


elm:
	@echo "> Compiling Elm application"
	@elm make $(SRC_DIR)/Applications/Brain.elm --output $(BUILD_DIR)/brain.js
	@elm make $(SRC_DIR)/Applications/UI.elm --output $(BUILD_DIR)/application.js


system:
	@echo "> Compiling system"
	@stack build && stack exec build


vendor:
	@echo "> Copying vendor things"
	@stack build && stack exec vendor


#
# Dev tasks
#

dev: build
	@make -j watch-wo-build server


doc-tests:
	@echo "> Running documentation tests"
	@( cd src && \
		find . -name "*.elm" -print0 | \
		xargs -0 -n 1 sh -c 'elm-proofread -- $0 || exit 255; echo "\n\n"'
	)


server:
	@echo "> Booting up web server on port 5000"
	@devd --port 5000 --all --crossdomain --quiet --notfound=index.html $(BUILD_DIR)


test:
	@make -j doc-tests


watch: build
	@make watch_wo_build


watch-wo-build:
	@echo "> Watching"
	@make -j watch-elm watch-system


watch-elm:
	@watchexec -p \
		-w $(SRC_DIR)/Applications \
		-w $(SRC_DIR)/Library \
		-- make elm


watch-system:
	@watchexec -p --ignore *.elm -- make system
