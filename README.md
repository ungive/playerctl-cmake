# playerctl-cmake

Build files to build `playerctl` with the CMake build system instead of Meson.

## Build

```
$ mkdir build && cd build
$ cmake ..
$ cmake --build .
```

This produces a `libplayerctl.so` shared library
and the `playerctl-cli` command line interface.

## License

This project is licensed under the same terms as `playerctl`.
See `COPYING` for details.
