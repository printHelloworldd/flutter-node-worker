define fnw
dart run flutter_node_worker
endef

init:
	$(fnw) init --dir=$(dir) --name=$(name)

add:
	$(fnw) add --dir=$(dir) --name=$(name)

build-worker:
	$(fnw) build --dir=$(dir) --out-dir=$(out-dir)

install:
	$(fnw) install $(pkgs) --dir=$(dir)

uninstall:
	$(fnw) uninstall $(pkgs) --dir=$(dir)
