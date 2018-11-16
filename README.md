# Profiling research

In order to profile the performance of a web application one would usually use the browsers built-in developer tools. Every once in a while however there comes a time when a developer needs a better understanding of a performance issue in order to solve it. In order to get that understanding the developer needs access to low-level optimisations, de-optimisations and caching techniques in modern browser engines. Due to security restrictions in the browser it is only really possible to get this low-level information from browsers by enabling various flags when launching the browser locally.

Chromium and V8 ship with various built-in tools that help their developers during development of the browser and engine. Luckily we, as web developer, can leverage these same tools to get a better understanding of what is happening under the hood.

To understand what parts of the application are useful to profile one must have a general understanding of the architecture of the compiler pipeline in modern browser engines like `V8`. The compiler pipelines behind each browser are similar but not at all the same on a technical level. By looking at the `V8` pipeline in general terms we can understand what are the core parts of each engine without getting lost in the implementation details.

It is not necessary to understand the intrinsics of each browser engine but it is benificial as a starting point in understanding what is harming the performance of your application.

## Compiler pipeline

![V8 compiler pipeline](/docs/V8_COMPILER_PIPELINE.jpg?raw=true)

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

The optimizing compiler (`Turbofan` in `V8`) recompiles `hot` functions using previously collected type information to optimize the generated `machine code` further. However, in order to make a faster version of the `machine code`, the optimizing compiler has to make some assumptions regarding the shape of the object, that they always have the same property names and order, then the compiler can make further optimisations based on that. If the object shape has been the same throughout the lifetime of the program it is assumed that it will remain that way during future execution. Unfortunately in JavaScript there are no guarantees that this is actually the case meaning that object shapes can change at any stage over time. Due to this lack of guarantees the assumptions of the compiler need to be validated every single time before it runs. If it turns out the assumptions are false the optimizing compiler assumes it made the wrong assumptions, trashes the last version of the optimized code and steps back to a de-optimized version where assumptions are still valid. It is therefore very important that you limit the amount of type changes of an object throughout the lifetime of the program in order to keep the highly optimized code produced by the optimizing compiler alive.

### Conclusion

When profiling and optimizing your JavaScript code effort should go out to optimizing the parts of the application that are being optimized by the optimizing compiler, meaning that these functions are `hot`, and more importantly which parts of the application are being de-optimized. De-optimization likely happens because types are changing in `hot` parts of the code or certain optimizations are not yet implemented by the compiler (such as `try catch` a few years ago). It is important to note that whilst you should pay attention when using these unoptimized implementations you should use them and report to the browser engines that you are using these features. If a certain de-optimization shows up a lot in heuristics and performance bug reports it is likely to be picked up by the engine maintainers as a priority. Other things to take into account are optimizing object property access, maintaining object shapes and understand the power of inline caches. Inline caches are used to memorize information on where to find properties on objects to reduce the number of expensive lookups.

## Profiling

I'll primarily focus on profiling using built-in tools of `V8` as most developers are familiar with Chrome. Besides the built-in browser developer tools one can start the browser with flags to enable the performance profiling of various parts of the web application. In order to record and visualize these performance profiles you should use `chrome://tracing`, previously `about://tracing`. Please note that any traces recorded with the tool will contains all currently opened resources (tabs, extensions, subresources) with the browser. Make sure that Chrome starts without any other resources active in order to be able to get a relatively clean trace.

In order to record a clean trace you should keep the recording to a maximum of 10 seconds, focus on a single activity per recording and leave the computer completely idle for 2 seconds before and after each recording. This will help making the slow process stand out amongst the other recorded data.

### Memory profiling and garbage collection

The essential point of garbage collection is the ability to manage memory usage by an application. All management of the memory is done by the browser engine, no API is exposed to web developers to control it. Web developer can however learn how to structure their programs in order to use the garbage collector to their advantage.

All variables in a program are part of the object graph and object variables can reference other variables. Allocating variables is done from the `young memory pool` and is very cheap until the memory pool runs out of memory. Whenever that happens a garbage collection is forced which causes higher latency, dropped frames and thus a major impact on the user experience.

Objects have two sizes: `shallow (self)` and `retained (self + descendents)`. All variables that cannot be reached from the root node are considered as garbage. The job of the garbage collector is to `mark-and-sweep` or in other words: go through objects that are allocated in memory and determine wheter they are `dead` or `alive`. If an object is unreachable it is removed from memory and previously allocated memory gets released back to the heap. Generally, e.g. in `V8`, the object heap is segmented into two parts: the `young generation` and the `old generation`. The `young generation` consists of `new space` in which new objects are allocated. It allocates fast, frequently collects and collects fast. The `old space` stores objects that are survived enough garbage collector cycles to be promoted to the `old generation`. It allocates fast, infrequently collects and does slower collection.

The cost of the garbage collection is proportional to the number of live objects. This is due to a copying mechanism that copies over objects that are still alive into a new space. Most of the time newly allocated objects do not survive long enough in order to become old. It is important to understand that each allocation moves you closer to a garbage collection and every collection pauses the execution of your application. It is therefore important in performance critical applications to strive for a static amount of alive objects and prevent allocating new ones whilst running.

In order to limit the amount of objects that have to be garbage collected a developer should take the following aspects into account:

- Avoid allocating new objects or change types of outer scoped (or even global) variables inside of a `hot` function.
- Avoid circular references. A circular reference is formed when two objects reference each other. Memory leaks can occur when the engine and garbage collector fail to identify a circular reference meaning that neither object will ever be destroyed and memory will keep growing over time.
- A possible solution for the object allocation problem in the `young generation` is the use of an `object pool` that basically pre-allocates a fixed number of objects ahead of time and keeps them alive by recycling them. This is a relatively common technique that allows you to have more explicit control over your objects lifetime. This however does come with an upfront cost when initializing and filling the pool and a consistent chunk of memory throughout your applications lifetime. An example of an object pool implementation can be found [here](https://github.com/timvanscherpenzeel/object-pool).
- Make use of [WeakMaps](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WeakMap) where possible as they hold "weak" references to key objects, which means that they do not prevent garbage collection in case there would be no other reference to the key object.
- Avoid associating the `delete` keyword in JavaScript with manual memory management. The `delete` keyword is used to remove properties from objects, not objects or variables as a whole, and is therefore **not** useful to mark objects ready to be garbage collected.
- When profiling make sure to run it in an incognito window in a fresh browser instance **without** any browser extensions as they share the same heap as the JavaScript program that you are trying to profile.

#### Heap snapshot

![Heap snapshot](/docs/HEAP_SNAPSHOT.jpg?raw=true)

In the `Chrome developer tools` panel, in the memory tab, you can find the option to take a `heap snapshot` which shows the memory distribution among your applications JavaScript objects and related DOM nodes. It is important to note that right **before** you click the heap snapshot button a major garbage collection is done. Because of this you can assume that everything that `V8` assumes to be able to garbage collected has already been cleaned up allowing you to get an idea of what `V8` was unable to clean up at the time.

Once you have taken your snapshot you can start inspecting it.

You should ignore everything in parentheses and everything that is dimmed in the `heap snapshot`. These are various constructors that you do not have explicit control over in your application. The snapshot is ordered by the `constructor` name and you can filter the heap to find your constructor using the `class filter` up top. If you record multiple snapshots it is benificial to compare them to each other. You can do this by opening the dropdown menu left of the `class filter` and set it to `comparison`. You can now see the difference between two snapshots. The list will be much shorter and you can see more easily what has changed in memory.

Objects in the `heap snapshot` with a yellow background are an indicator that there is no active handle available meaning that these objects will be difficult to clean up as you have probably lost its reference to it. Most likely it is still in the DOM tree but you lost your JavaScript reference to it.

Objects with a red background in the `heap snapshot` are considered objects that have been detatched from the DOM tree but their JavaScript reference is being retained. A DOM node can only be garbage collected when there are no references to it from either the page's DOM tree or JavaScript code. A node is said to be "detached" when it's removed from the DOM tree but some JavaScript still references it. Detached DOM nodes are a common cause of memory leaks. They are only alive because they are part of the yellow node's tree.

In general, you want to focus on the yellow nodes in the `heap snapshot`. Fix your code so that the yellow node isn't alive for longer than it needs to be, and you also get rid of the red nodes that are part of the yellow node's tree.

For more information there are excellent entries on the Chrome developer tools blog on memory profiling:

- [Fix memory problems](https://developers.google.com/web/tools/chrome-devtools/memory-problems/)
- [Understand memory terminology](https://developers.google.com/web/tools/chrome-devtools/memory-problems/memory-101)
- [Record Heap Snapshots](https://developers.google.com/web/tools/chrome-devtools/memory-problems/heap-snapshots)
- [Use the Allocation Profiler](https://developers.google.com/web/tools/chrome-devtools/memory-problems/allocation-profiler)

#### Three snapshot technique

A recommended technique for capturing and analyzing snapshots is to do three captures and do comparisons between them as shown in the following graphic.

![Three snapshot technique](/docs/GOOGLE_THREE_SNAPSHOT_TECHNIQUE.jpg?raw=true)

_Image source: Google Developers Live - https://www.youtube.com/watch?v=L3ugr9BJqIs_

### CPU profiling

Show how to profile the CPU and how to interpret the visualized results.

https://chromium.googlesource.com/chromium/src/+/master/docs/profiling.md

### GPU profiling

There are several ways to profile a GPU.

Show how to profile the GPU and how to interpret the visualized results.

https://chromium.googlesource.com/chromium/src/+/master/docs/memory-infra/probe-gpu.md

https://developer.apple.com/library/archive/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/ToolsOverview/ToolsOverview.html

https://www.html5rocks.com/en/tutorials/games/abouttracing/

## Debugging

### GPU debugging

There are several ways one can debug WebGL and the native OpenGL instructions using an external debugger like [RenderDoc (Windows, Linux)](https://renderdoc.org/docs/index.html) or [APITrace (Windows, Linux, Mac (limited support))](https://github.com/apitrace/apitrace). Instructions on how to use debug WebGL using APITrace can be found [here](https://github.com/apitrace/apitrace/wiki/Google-Chrome-Browser).

For tracing an individual frame without setting up an external debugger I highly recommend using the Chrome extension [Spector.js](https://spector.babylonjs.com/).

Finally one can also wrap the `WebGLRenderingContext` with a debugging wrapper like the [one provided by the Khronos Group](https://www.npmjs.com/package/webgl-debug) to catch invalid WebGL operations and give the errors a bit more context. This comes with a large overhead as every single instruction is traced (and optionally logged to the console so make sure to only optionally include the dependency in development.

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

- [The Breakpoint Ep. 8: Memory Profiling with Chrome DevTools](https://www.youtube.com/watch?v=L3ugr9BJqIs)
- [V8 Garbage Collector](https://github.com/thlorenz/v8-perf/blob/master/gc.md#heap-organization-in-detail)
- [Google I/O 2013 - Accelerating Oz with V8: Follow the Yellow Brick Road to JavaScript Performance](https://www.youtube.com/watch?v=VhpdsjBUS3g)
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
