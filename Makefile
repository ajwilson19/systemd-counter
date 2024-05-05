all: test build build-deb
build:
	cargo build --release
run:
	cargo run
test:
	cargo test
clean:
	cargo clean
	rm -rf counter-v2.0.0
	rm -f counter-v2.0.0.deb
build-deb: build
	bash bin/build.sh
	cp target/release/counter counter-v2.0.0/usr/bin
	dpkg-deb --root-owner-group --build counter-v2.0.0
lint-deb: build-deb
	-lintian counter-v2.0.0.deb
docker-image:
	docker build -t counter:latest .
