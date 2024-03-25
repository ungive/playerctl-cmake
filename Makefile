.PHONY: build clean

all: clean build

build:
	mkdir -p build; \
		cd build; \
		cmake ..; \
		cmake --build .

clean:
	rm -rf build playerctl playerctl-2.4.1
