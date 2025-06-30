define fnw
dart run flutter_node_worker
endef

init:
	$(fnw) init --dir=$(dir) --name=$(name)

add:
	$(fnw) add --dir=$(dir) --name=$(name)

build:
	$(fnw) add --dir=$(dir) --out-dir=$(out-dir)

install:
	$(fnw) add --dir=$(dir)

uninstall:
	$(fnw) add --dir=$(dir)
