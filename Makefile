all: teletube

teletube: main.cr src/**/*.cr
	shards
	ruby scripts/options.rb
	crystal build --error-trace -o teletube main.cr
	@strip teletube
	@du -sh teletube

release: main.cr src/**/*.cr
	shards
	ruby scripts/options.rb
	crystal build main.cr --release -o teletube
	@strip teletube
	@du -sh teletube
	ruby scripts/build.rb

clean:
	rm -rf .crystal teletube .deps .shards libs lib *.dwarf build

PREFIX ?= /usr/local

install: teletube
	install -d $(PREFIX)/bin
	install teletube $(PREFIX)/bin