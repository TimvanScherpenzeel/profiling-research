# Profiler

TurboFan

https://v8.dev/docs/profile

https://github.com/thlorenz/v8-perf

https://chromedevtools.github.io/devtools-protocol/v8/Profiler/#method-startTypeProfile

https://nodejs.org/api/inspector.html

https://blog.ghaiklor.com/tracing-de-optimizations-in-nodejs-2ba16900fc6f

https://gist.github.com/cevek/ef1c9761a67d80d642f98cc75885bf31

```sh
alias chrome="open -a Google\ Chrome --args --disable-web-security"
alias canary="$CANARY --user-data-dir=/Users/plepers/Documents/chrome_profiles/canary --allow-file-access-from-files > /dev/null 2>&1"
alias canaryp="$CANARY --user-data-dir=/Users/plepers/Documents/chrome_profiles/canaryp --allow-file-access-from-files --js-flags=\"--trace-opt --trace-opt-stats --trace-stub-failures\" > /Users/plepers/tmp/canary.log 2> /Users/plepers/tmp/canary_err.log"
```

Flamechart
Stack

```sh
alias chrome_canary_profile="/Applications/Google\ Chrome\ Canary.app/Contents/MacOS/Google\ Chrome\ Canary --js-flags=\"--trace-opt --trace-opt-stats --trace-deopt --trace-file-names --trace-stub-failures\" > ./profiler/chrome_canary_profile.log 2> ./profiler/chrome_canary_error.log"
```

IRHydra

```sh
node --trace-hydrogen --trace-phase=Z --trace-deopt --code-comments --hydrogen-track-positions --redirect-code-traces --redirect-code-traces-to=code.asm test.js
```