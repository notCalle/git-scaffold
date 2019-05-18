.PHONY: install

install: /usr/local/bin/git-scaffold

/usr/local/bin/git-scaffold: src/git-scaffold.sh
	cp $< $@
