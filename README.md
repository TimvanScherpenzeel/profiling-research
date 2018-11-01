# Profiling research

In order to profile the performance of a web application one would usually use the browsers built-in developer tools. Every once in a while however there comes a time when a developer needs a better understanding of a performance issue in order to solve it. In order to get that understanding the developer needs access to low-level optimisations, de-optimisations and caching techniques in modern browser engines. Due to security restrictions in the browser it is only really possible to get this low-level information from browsers by enabling various flags when launching the browser locally.

Chromium and V8 ship with various built-in tools that help their developers during development of the browser and engine. Luckily we, as web developer, can leverage these same tools to get a better understanding of what is happening under the hood.

## Compiler pipeline

To understand what parts of the application are useful to profile one must have a general understanding of the architecture of the compiler pipeline in modern browser engines like V8. The compiler pipelines behind each browser are similar but not at all the same on a technical level. By looking at the V8 pipeline in general terms we can understand what are the core parts of each engine without getting lost in the implementation details.

It is not necessary to understand the intrinsics of each browser engine but it is benificial as a starting point in understanding what is harming the performance of your application.

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

JavaScript source code is `JIT (Just In Time)` compiled meaning it is being compiled to machine code as the program is running. Source code is initially just plain text with a mime-type that identifies it as JavaScript. It must be parsed by a `parser` in order to be understood as JavaScript by the browser engine.

### Parser

The parser generally consists out of a `pre-parser` and a `full-parser`. The `pre-parser` rapidly checks for syntactical and early errors in the program and will throw if it finds any. The `full-parser` evaluates the scope of variables throughout the program and collects basic type information.

### AST (Abstract Syntax Tree)

The `Abstract Syntax Tree` or in short `AST` is created from the parsed source code.
`AST's` are data structures widely used in compilers, due to their property of representing the structure of program code. An `AST` is usually the result of the syntax analysis phase of a compiler, a tree representation of the abstract syntactic structure of source code. Each node of the tree denotes a construct occurring in the source code.

### Baseline compiler

The goal of the baseline compiler (`Ignition` in `V8`) is to rapidly generate relatively unoptimized `machine code` (CPU architecture specific `bytecode` in the case of `Ignition`) as fast as possible and infer general type information to be used in potential further compilation steps. Whilst running, functions that are called often are marked as `hot` and are a candidate for further optimization using the optimizing compiler(s).

### Optimizing compiler

The optimizing compiler (`Turbofan` in `V8`) recompiles `hot` functions using previously collected type information to optimize the generated `machine code` further.
However, in order to make a faster version of the `machine code`, the optimizing compiler has to make some assumptions regarding the shape of the object, that they always have the same property names and order, then the compiler can make further optimisations based on that. If the object shape has been the same throughout the lifetime of the program it is assumed that it will remain that way during future execution. Unfortunately in JavaScript there are no guarantees that this is actually the case meaning that object shapes can change at any stage over time. Due to this lack of guarantees the assumptions of the compiler need to be validated every single time before it runs. If it turns out the assumptions are false the optimizing compiler assumes it made the wrong assumptions, trashes the last version of the optimized code and steps back to a de-optimized version where assumptions are still valid. It is therefore very important that you limit the amount of type changes of an object throughout the lifetime of the program in order to keep the highly optimized code produced by the optimizng compiler alive.

### Conclusion

When profiling and optimizing your JavaScript code effort should go out to optimizing the parts of the application that are being optimized (meaning that these functions are `hot`) and more importantly which parts of the application are being de-optimized (likely because types are changing in `hot` parts of the code). Other things to take into account are optimizing object property access, object shapes and inline caches. Inline caches are used to memorize information on where to find properties on objects to reduce the number of expensive lookups.

## Memory profiling and garbage collection

One of the main parts of the browser engine developers do not have explicit control over is the garbage collector.

- out of scope variables / functions
- objects that lost their references (name WeakMaps as a possible solution)
- show how to profile the memory over time and give general tips regarding the initialisation of variables and inner functions

## GPU profiling

Show how to profile the GPU and how to interpret the visualized results.

## CPU profiling

Show how to profile the GPU and how to interpret the visualized results.

## Note on transpiling code

Research if ES6 code is faster to execute because of less variable switching due to const's.

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
- [Understanding V8’s Bytecode](https://medium.com/dailyjs/understanding-v8s-bytecode-317d46c94775)
