PREFIX =? /usr/local

.PHONY: test
test:
	shellcheck src/git-scaffold.sh

.PHONY: install
install: $(PREFIX)/bin/git-scaffold

$(PREFIX)/bin/git-scaffold: src/git-scaffold.sh
	cp $< $@
