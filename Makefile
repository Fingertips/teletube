all: teletube

teletube: main.cr src/**/*.cr
	shards
	crystal build -o teletube main.cr
	@strip teletube
	@du -sh teletube

clean:
	rm -rf .crystal teletube .deps .shards libs lib *.dwarf

PREFIX ?= /usr/local

install: teletube
	install -d $(PREFIX)/bin
	install teletube $(PREFIX)/bin