# V8 profiling research

## Profiling in Chrome Canary (V8 engine)

In order to profile the performance of a web application one would usually use the browsers built-in developer tools. Every once in a while however the comes a time when a developer needs a better understanding of a performance issue in order to solve it. The built-in collecting and analysis tooling in V8 can help with that.

# Developer tools

## Visualizing performance profiles

## Resources

- [Franziska Hinkelmann - Performance Profiling for V8 / Script17 (Slides)](https://fhinkel.rocks/PerformanceProfiling/assets/player/KeynoteDHTMLPlayer.html#3)
- [Franziska Hinkelmann - Performance Profiling for V8 / Script17 (Video)](https://www.youtube.com/watch?v=j6LfSlg8Fig)
- [Franziska Hinkelmann - Performance Profiling for V8 / Script17 (Files)](https://github.com/fhinkel/PerformanceProfiling)

- [V8 profile documentation](https://v8.dev/docs/profile)
- https://github.com/thlorenz/v8-perf
- https://github.com/thlorenz/turbolizer
- https://chromedevtools.github.io/devtools-protocol/v8/Profiler/#method-startTypeProfile
- https://nodejs.org/api/inspector.html
- https://blog.ghaiklor.com/tracing-de-optimizations-in-nodejs-2ba16900fc6f
- https://www.chromium.org/developers/creating-v8-profiling-timeline-plots
- https://www.chromium.org/developers/how-tos/trace-event-profiling-tool

v8/tools/ic-explorer.html
--trace-ic

Inline cache

%HaveSameMap

node --allow-natives-syntax

Baseline compiler (general analysis of what functions are hot)
Optimizing compiler (recompile hot functions) - TurboFan (Crankshaft was the old one)

// trace-ic
// logfile=""

IC States

- uninitialized
- monomorphic IC (1 map) - local cache
- polymorphic IC (2-4 maps) - local cache
- megamorphic (more than 4 maps) - global cache
