# V8 profiling research

## Profiling in Chrome Canary (V8 engine)

In order to profile the performance of a web application one would usually use the browsers built-in developer tools. Every once in a while however the comes a time when a developer needs a better understanding of a performance issue in order to solve it. The built-in collecting and analysis tooling in V8 can help with that.

## Record and visualizing performance profiles

In order to record and visualize advanced performance profiles you should use `chrome://tracing`.

## Installation

Automatically set up for MacOS:

```sh
$ ./scripts/setup_macos.sh
```

## Usage

```sh
$ ./scripts/run.sh <URL>
```

## Resources

- [Franziska Hinkelmann - Performance Profiling for V8 / Script17 (Slides)](https://fhinkel.rocks/PerformanceProfiling/assets/player/KeynoteDHTMLPlayer.html#3)
- [Franziska Hinkelmann - Performance Profiling for V8 / Script17 (Video)](https://www.youtube.com/watch?v=j6LfSlg8Fig)
- [Franziska Hinkelmann - Performance Profiling for V8 / Script17 (Files)](https://github.com/fhinkel/PerformanceProfiling)
- [V8 profile documentation](https://v8.dev/docs/profile)
- [V8 performance notes and resources](https://github.com/thlorenz/v8-perf)
- [Turbolizer](https://github.com/thlorenz/turbolizer)
- [The Trace Event Profiling Tool (chrome://tracing)](https://www.chromium.org/developers/how-tos/trace-event-profiling-tool)
