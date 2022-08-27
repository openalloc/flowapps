# OpenAlloc Flow Apps

_Power Tools for the Do-It-Yourself Investor_

This project consists of two applications which are part of the
[OpenAlloc](https://github.com/openalloc) family of open source Swift
software tools.

- [FlowAllocator](https://openalloc.github.io/FlowAllocator/index.html)
  - a sophisticated portfolio rebalancing tool

- [FlowWorth](https://openalloc.github.io/FlowWorth/index.html)
  - a tool for tracking value and performance over time

They are formerly proprietary applications now entirely open-sourced in
August 2022. 

They are written in _Swift_ language and the _SwiftUI_ framework using
Xcode 13.4

The current target is macOS 12.0 (Monterey) and newer, for Intel and Apple
Silicon. This requirement will move forward in the future.

There’s strong potential for supporting iPadOS/iOS, but would require
further development and testing by interested developers.

## Project Organization

Presently organized as an Xcode workspace. To load into Xcode from the Git
project root...

```bash 
$ open flowapps.xcworkspace
```

The dependent packages presently included in the workspace (e.g.,
‘FlowViz’) could be spun off into external package dependencies.

## Unit Tests

Most critical functionality in the libraries are backed by unit testing.
There is presently no UI testing code, but that could be added if needed.

Note that any given unit test may have defects or bad assumptions, and can
be worthy of review and re-write.

In the libraries, bug fixes and new contributions should be backed by unit
tests.

## License

Copyright 2021, 2022 OpenAlloc LLC

All application code is licensed under the 
[Mozilla Public License 2](https://www.mozilla.org/en-US/MPL/2.0/), 
except where noted in individual modules.

## Contributing

Contributions are welcome. You are encouraged to submit pull requests to
fix bugs, improve documentation, or offer new features. 

The pull request need not be a production-ready feature or fix. It can be
a draft of proposed changes, or simply a test to show that expected
behavior is buggy. Discussion on the pull request can proceed from there.

Contributions should ultimately have adequate test coverage. See tests for
current entities to see what coverage is expected.
