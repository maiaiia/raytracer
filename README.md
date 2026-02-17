# raytracer

A physically-based ray tracer written in Swift, following the [Ray Tracing in One Weekend](https://raytracing.github.io/) series. Mostly a learning project, both for ray tracing and Swift, which I've been really enjoying for its clean syntax and ease of use.

On top of the book's implementation I added better code organisation (at least tried to!!) and multithreading which gave around a 3x speedup over the single-threaded version.

## Progress

- [x] Book 1 — Ray Tracing in One Weekend
- [ ] Book 2 — Ray Tracing: The Next Week
- [ ] Book 3 — Ray Tracing: The Rest of Your Life

## Roadmap

- [ ] GUI with real-time rendering preview
- [ ] Load scenes from `.obj` files
- [ ] General code cleanup

## Usage

```bash
# Render to PPM
swift run RayTracer > output.ppm

# Release build (faster)
swift build -c release
.build/release/RayTracer > output.ppm
```
