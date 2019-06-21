This project provides code for reproducing a timeout when running unit tests
on DDC in Chrome 75 and above (I've tried builds of 76 and 77) in a docker
container. The timeout appears to be caused by test suites that require a large
number of files to be downloaded. We have only encountered this issue when 
running tests inside a docker container. If we run the same tests on 
Linux/Chrome 75 outside of a docker container we don't encounter the timeout.
The tests do run to completion on Chromium (currently version 73). They also
run to completion when compiled with dart2js.

This project includes a Dockerfile that executes unit tests first on the
current version of Chromium and then on Chrome. The tests will run to completion
on Chromium but then will timeout while loading the test suite on Chrome. To
build the docker container and run the tests execute:

```bash
docker build .
```

Here is an example of the timeout we are seeing:

```
00:00 +0: compiling test/big_test.dart
00:00 +0 -1: compiling test/big_test.dart [E]
  TimeoutException after 0:12:00.000000: Test timed out after 12 minutes.
  package:test_api/src/backend/invoker.dart 332:28              Invoker._handleError.<fn>
  dart:async/zone.dart 1120:38                                  _rootRun
  dart:async/zone.dart 1021:19                                  _CustomZone.run
  package:test_api/src/backend/invoker.dart 330:10              Invoker._handleError
  package:test_api/src/backend/invoker.dart 283:9               Invoker.heartbeat.<fn>.<fn>
  dart:async/zone.dart 1120:38                                  _rootRun
  dart:async/zone.dart 1021:19                                  _CustomZone.run
  package:test_api/src/backend/invoker.dart 281:38              Invoker.heartbeat.<fn>
  package:stack_trace/src/stack_zone_specification.dart 209:15  StackZoneSpecification._run
  package:stack_trace/src/stack_zone_specification.dart 119:48  StackZoneSpecification._registerCallback.<fn>
  dart:async/zone.dart 1124:13                                  _rootRun
  dart:async/zone.dart 1021:19                                  _CustomZone.run
  dart:async/zone.dart 947:23                                   _CustomZone.bindCallback.<fn>
  dart:async-patch/timer_patch.dart 21:15                       Timer._createTimer.<fn>
  dart:isolate-patch/timer_impl.dart 382:19                     _Timer._runTimers
  dart:isolate-patch/timer_impl.dart 416:5                      _Timer._handleMessage
  dart:isolate-patch/isolate_patch.dart 171:12                  _RawReceivePortImpl._handleMessage
  ===== asynchronous gap ===========================
  dart:async/zone.dart 1045:19                                  _CustomZone.registerCallback
  dart:async/zone.dart 946:22                                   _CustomZone.bindCallback
  dart:async/zone.dart 1191:21                                  _rootCreateTimer
  dart:async/zone.dart 1088:19                                  _CustomZone.createTimer
  package:test_api/src/backend/invoker.dart 280:34              Invoker.heartbeat
  package:test_api/src/backend/invoker.dart 215:5               Invoker.removeOutstandingCallback
  package:test_api/src/backend/invoker.dart 402:13              Invoker._onRun.<fn>.<fn>.<fn>.<fn>
  ===== asynchronous gap ===========================
  dart:async/zone.dart 1053:19                                  _CustomZone.registerUnaryCallback
  dart:async-patch/async_patch.dart 77:23                       _asyncThenWrapperHelper
  package:test_api/src/backend/invoker.dart                     Invoker._onRun.<fn>.<fn>.<fn>.<fn>
  dart:async/future.dart 176:37                                 new Future.<fn>
  package:stack_trace/src/stack_zone_specification.dart 209:15  StackZoneSpecification._run
  package:stack_trace/src/stack_zone_specification.dart 119:48  StackZoneSpecification._registerCallback.<fn>
  dart:async/zone.dart 1120:38                                  _rootRun
  dart:async/zone.dart 1021:19                                  _CustomZone.run
  dart:async/zone.dart 923:7                                    _CustomZone.runGuarded
  dart:async/zone.dart 963:23                                   _CustomZone.bindCallbackGuarded.<fn>
  package:stack_trace/src/stack_zone_specification.dart 209:15  StackZoneSpecification._run
  package:stack_trace/src/stack_zone_specification.dart 119:48  StackZoneSpecification._registerCallback.<fn>
  dart:async/zone.dart 1124:13                                  _rootRun
  dart:async/zone.dart 1021:19                                  _CustomZone.run
  dart:async/zone.dart 947:23                                   _CustomZone.bindCallback.<fn>
  dart:async-patch/timer_patch.dart 21:15                       Timer._createTimer.<fn>
  dart:isolate-patch/timer_impl.dart 382:19                     _Timer._runTimers
  dart:isolate-patch/timer_impl.dart 416:5                      _Timer._handleMessage
  dart:isolate-patch/isolate_patch.dart 171:12                  _RawReceivePortImpl._handleMessage
  ===== asynchronous gap ===========================
  dart:async/zone.dart 1045:19                                  _CustomZone.registerCallback
  dart:async/zone.dart 962:22                                   _CustomZone.bindCallbackGuarded
  dart:async/timer.dart 52:45                                   new Timer
  dart:async/timer.dart 87:9                                    Timer.run
  dart:async/future.dart 174:11                                 new Future
  package:test_api/src/backend/invoker.dart 399:21              Invoker._onRun.<fn>.<fn>.<fn>

00:00 +0 -1: Some tests failed.
```