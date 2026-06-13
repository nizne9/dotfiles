# Third-party code

## fzy

- Upstream: https://github.com/jhawthorn/fzy
- Version: v1.1
- Commit: d811eaf9d73593f8293a73f98a17b36f016873e6
- License: MIT
- Import strategy: vendored upstream source under `third_party/fzy/`.

The `third_party/fzy/` directory should remain an upstream-shaped snapshot. CMake copies fzy's `src/config.def.h`, `src/match.c`, `src/match.h`, and `src/bonus.h` to a generated build directory, producing the `config.h` layout that upstream's Makefile normally creates without modifying the vendored source.

Keep local launcher-specific behavior in `src/fzymatcher.cpp` instead of patching fzy directly.
