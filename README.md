# Profiling research

In order to profile the performance of a web application one would usually use the browsers built-in developer tools. Every once in a while however there comes a time when a developer needs a better understanding of a performance issue in order to solve it. In order to get that understanding the developer needs access to low-level optimisations, de-optimisations and caching techniques in modern browser engines. Due to security restrictions in the browser it is only really possible to get this low-level information from browsers by enabling various flags when launching the browser locally.

Chromium and V8 ship with various built-in tools that help their developers during development of the browser and engine. Luckily we, as web developer, can leverage these same tools to get a better understanding of what is happening under the hood.

## Compiler pipeline

### Overview

```
    Source code
        │
        |
        V
      Parser
        │
        |
        V
       AST
        │
        |
        V
    Baseline compiler ───> Unoptimized machine code
            |                       Λ
            | (hot functions)       | (changed types)
            V                       |
    Optimizing compiler ───> Optimized machine code
```

### Source code

JavaScript source code is `JIT (Just In Time)` compiled meaning it is compiled as it runs. Source code is initially just text. It must be parsed by the `parser` in order to be understood as JavaScript by the browser engine.

### Parser

In order for the browser engine to understand the source code it needs to be parsed. Generally the entire JavaScript source code must be parsed before creating an `AST`. A parser generally checks for any syntactical and early errors and the scope of variables.

### AST (Abstract Syntax Tree)

The `Abstract Syntax Tree` or in short `AST` is created from the parsed source code.
`AST's` are data structures widely used in compilers, due to their property of representing the structure of program code. An `AST` is usually the result of the syntax analysis phase of a compiler, a tree representation of the abstract syntactic structure of source code. Each node of the tree denotes a construct occurring in the source code.

### Baseline compiler

The goal of the baseline compiler (`Ignition` in `V8`) is to rapidly generate relatively unoptimized `JIT code` as fast as possible and infer general type information to be used in potential further compilation steps. Whilst running, functions that are called often are marked as `hot` and can be a candidate for optimization using the optimizing compiler(s).

### Optimizing compiler

The optimizing compiler (`Turbofan` in `V8`) recompiles `hot` functions using the previously collected type information to optimize the generated `JIT code` further.
However, in order to make a faster version of the `JIT code`, the optimizing compiler has to make some assumptions.

For example, if it can assume that all objects created by a particular constructor have the same shape—that is, that they always have the same property names, and that those properties were added in the same order— then it can cut some corners based on that.

The optimizing compiler uses the information the monitor has gathered by watching code execution to make these judgments. If something has been true for all previous passes through a loop, it assumes it will continue to be true. Unfortunately in JavaScript there are no guarantees meaning that shapes can change at any stage over time.
Due to this lack of guarantees the assumptions of the compiler need to be validated every single time. If it turns out the assumption turned out to be false the `JIT` assumes it made the wrong assumptions, trashes the last version of the optimized code and must step back to a valid de-optimized version because necessary type information will be missing. It is therefore very important that you limit the amount of type changes of an object throughout the lifetime of the program in order to keep the highly optimized `hot` `JIT code` alive.

### Conclusion

When profiling a large part of your effort should go out to the parts of the application that are being optimized and more importantly which parts of the application are being de-optimized. Other things to take into account are optimizing object property access, object shapes and inline caches (`IC's`). JavaScript engines use `IC's` to memorize information on where to find properties on objects to reduce the number of expensive lookups.

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
- [Ignition - an interpreter for V8](https://www.youtube.com/watch?v=r5OWCtuKiAk)
- [A crash course in Just In Time (JIT) compilers](https://hacks.mozilla.org/2017/02/a-crash-course-in-just-in-time-jit-compilers/)
- [JavaScript engine fundamentals: Shapes and Inline Caches](https://mathiasbynens.be/notes/shapes-ics)
- [JavaScript Engines: The Good Parts™ - Mathias Bynens & Benedikt Meurer - JSConf EU 2018](https://www.youtube.com/watch?v=5nmpokoRaZI)
