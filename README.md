av_ram
======

av_ram is a generic memory that is intended to map against on-chip RAM or registers. It is currently hard coded to use 32 bits and has a Avalon interface for burst accesses

Parameters
----------

Name  | Description          | Default value             |
----- | -------------------- | ------------------------- |
dw    | Avalon data width    | 32 (only supported value) |
depth | Memory size in bytes | 256                       |
aw    | Address width        | clog2(depth)              |

Test bench
----------
av_ram comes with a self-checking test bench that uses the `av_bfm_transactor` from [av_bfm](https://github.com/sirchuckalot/av_bfm).

TODO
----

- Make width configurable
- Add technology-specific backends
- Only allow wrap bursts less than memory size
