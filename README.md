# Profiling research

In order to profile the performance of a web application one would usually use the browsers built-in developer tools. Every once in a while however there comes a time when a developer needs a better understanding of a performance issue in order to solve it. In order to get that understanding the developer needs access to low-level optimisations, de-optimisations and caching techniques in modern browser engines. Due to security restrictions in the browser it is only really possible to get this low-level information from browsers by enabling various flags when launching the browser locally.

Chromium and V8 ship with various built-in tools that help their developers during development of the browser and engine. Luckily we, as web developer, can leverage these same tools to get a better understanding of what is happening under the hood.

To understand what parts of the application are useful to profile one must have a general understanding of the architecture of the compiler pipeline in modern browser engines like V8. The compiler pipelines behind each browser are similar but not at all the same on a technical level. By looking at the V8 pipeline in general terms we can understand what are the core parts of each engine without getting lost in the implementation details.

It is not necessary to understand the intrinsics of each browser engine but it is benificial as a starting point in understanding what is harming the performance of your application.

## Compiler pipeline

![V8 compiler pipeline](/docs/V8_COMPILER_PIPELINE.png?raw=true)

_Image source: Franziska Hinkelmann - https://medium.com/dailyjs/understanding-v8s-bytecode-317d46c94775_

### Source code

JavaScript source code is `JIT (Just In Time)` compiled meaning it is being compiled to machine code as the program is running. Source code is initially just plain text with a mime-type that identifies it as JavaScript. It must be parsed by a `parser` in order to be understood as JavaScript by the browser engine.

### Parser

The parser generally consists out of a `pre-parser` and a `full-parser`. The `pre-parser` rapidly checks for syntactical and early errors in the program and will throw if it finds any. The `full-parser` evaluates the scope of variables throughout the program and collects basic type information.

### AST

The `Abstract Syntax Tree` or in short `AST` is created from the parsed source code.
`AST's` are data structures widely used in compilers, due to their property of representing the structure of program code. An `AST` is usually the result of the syntax analysis phase of a compiler, a tree representation of the abstract syntactic structure of source code. Each node of the tree denotes a construct occurring in the source code. It is benificial to get a good understanding of what `AST's` are as they are very oftenly used in pre-processors, code generators, minifiers, transpilers, linters and codemods.

### Baseline compiler

The goal of the baseline compiler (`Ignition` in `V8`) is to rapidly generate relatively unoptimized `machine code` (CPU architecture specific `bytecode` in the case of `Ignition`) as fast as possible and infer general type information to be used in potential further compilation steps. Whilst running, functions that are called often are marked as `hot` and are a candidate for further optimization using the optimizing compiler(s).

### Optimizing compiler

The optimizing compiler (`Turbofan` in `V8`) recompiles `hot` functions using previously collected type information to optimize the generated `machine code` further. However, in order to make a faster version of the `machine code`, the optimizing compiler has to make some assumptions regarding the shape of the object, that they always have the same property names and order, then the compiler can make further optimisations based on that. If the object shape has been the same throughout the lifetime of the program it is assumed that it will remain that way during future execution. Unfortunately in JavaScript there are no guarantees that this is actually the case meaning that object shapes can change at any stage over time. Due to this lack of guarantees the assumptions of the compiler need to be validated every single time before it runs. If it turns out the assumptions are false the optimizing compiler assumes it made the wrong assumptions, trashes the last version of the optimized code and steps back to a de-optimized version where assumptions are still valid. It is therefore very important that you limit the amount of type changes of an object throughout the lifetime of the program in order to keep the highly optimized code produced by the optimizng compiler alive.

### Conclusion

When profiling and optimizing your JavaScript code effort should go out to optimizing the parts of the application that are being optimized (meaning that these functions are `hot`) and more importantly which parts of the application are being de-optimized (likely because types are changing in `hot` parts of the code). Other things to take into account are optimizing object property access, object shapes and inline caches. Inline caches are used to memorize information on where to find properties on objects to reduce the number of expensive lookups.

## Profiling

I'll primarily focus on profiling using built-in tools of V8 as most developers are familiar with Chrome. Besides the built-in browser developer tools one can start the browser with flags to enable the performance profiling of various parts of the web application. In order to record and visualize these performance profiles you should use `chrome://tracing`, previously `about://tracing`. Please note that any traces recorded with the tool will contains all currently opened resources (tabs, extensions, subresources) with the browser. Make sure that Chrome starts without any other resources active in order to be able to get a relatively clean trace.

In order to record a clean trace you should keep the recording to a maximum of 10 seconds, focus on a single activity per recording and leave the computer completely idle for 2 seconds before and after each recording. This will help making the slow process stand out amongst the other recorded data.

### Memory profiling and garbage collection

The essential point of garbage collection is the ability to manage memory usage by an application. All management of the memory is done by the browser engine, no ECMAScript API is exposed to web developers to control it. The job of the garbage collector is to `mark-and-sweep` or in other words: go through objects that are allocated in memory and determine wheter they are `dead` or `alive`. If an object is not reachable it is considered dead, is removed from memory and previously allocated memory gets released back to the heap.

In order to limit the amount of objects that have to be garbage collected a developer should take the following aspects into account:

- Avoid allocating new variables or type changing outer scoped variables inside of a `hot` function
- Have a look at using a global `object pool` in order to recycle objects and avoid the dynamic allocation over the lifetime of your application. This is a relatively common technique that allows you to have more explicit control over your objects lifetime. This however does come with an upfront cost when initializing and filling the pool and a consistent chunk of memory throughout your applications lifetime. An example of an object pool implementation can be found [here](https://github.com/timvanscherpenzeel/object-pool).
- Make use of [WeakMaps](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap) where possible as they hold "weak" references to key objects, which means that they do not prevent garbage collection in case there would be no other reference to the key object.
- Avoid associating the `delete` keyword in JavaScript with manual memory management. The `delete` keyword is used to remove properties from objects, not objects or variables as a whole, and is therefore **not** useful to mark objects ready to be garbage collected.

https://chromium.googlesource.com/chromium/src/+/master/docs/memory-infra/README.md

- Show how to use the developer tools in order to get a memory profile over time
- Show how to profile the memory over time and give general tips regarding the initialisation of variables and inner functions

### CPU profiling

Show how to profile the CPU and how to interpret the visualized results.

https://chromium.googlesource.com/chromium/src/+/master/docs/profiling.md

### GPU profiling

Show how to profile the GPU and how to interpret the visualized results.

https://chromium.googlesource.com/chromium/src/+/master/docs/memory-infra/probe-gpu.md

https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/OpenGLProfilerUserGuide/Introduction/Introduction.html

https://renderdoc.org/docs/index.html

https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/ToolsOverview/ToolsOverview.html

https://www.html5rocks.com/en/tutorials/games/abouttracing/

## Installation

To automatically download and setup Chromy Canary on MacOS using Homebrew you can use:

```sh
$ ./scripts/setup_macos.sh
```

In order to install `V8` and the `D8` shell I recommend following the excellent guide by [Kevin Cennis](https://gist.github.com/kevincennis/0cd2138c78a07412ef21).

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
- [Visualize JavaScript AST's](https://resources.jointjs.com/demos/javascript-ast)
- [Garbage collection in V8, an illustrated guide](https://medium.com/@_lrlna/garbage-collection-in-v8-an-illustrated-guide-d24a952ee3b8)
