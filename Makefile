MAKEFLAGS=-j 10

fennel_paths := fnl/?.fnl
lua_paths := lua/?.lua /usr/share/nvim/runtime/lua/?.lua

FNL_FLAGS =
FNL = fennel
FNL += $(patsubst %, --add-fennel-path %, $(fennel_paths))
FNL += $(patsubst %, --add-package-path %, $(lua_paths))
FNL += $(FNL_FLAGS)
FNL += --compile

lua_files := $(patsubst fnl/%.fnl, lua/%.lua, $(wildcard fnl/*.fnl))
lua_files := $(filter-out %-macro.lua, $(lua_files))

reset := \e[0;0m
blue := \e[1;34m

all:: $(dir lua_files) $(lua_files)

@PHONY:
clean::
	rm -rf $(lua_files)

lua/%.lua:: fnl/%.fnl
	mkdir -p $(dir $@)
	if ! $(FNL) $< > $@; then rm $@; fi
	sed -i -E '/debug.traceback = fennel.traceback/d' $@

% ::
	@echo $@
