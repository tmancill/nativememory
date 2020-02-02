# nativememory

This is a test-harness that demontrates a minor difference between the behavior of AdoptOpenJDK 8 and Ubuntu's build of OpenJDK 8 when large numbers of threads allocate native memory.

In summary: allocate threads that then allocate memory via `Native.malloc()`.  After 30 seconds, 50% of those threads free their allocated memory and exit normally.  The other threads continue to run.  See [src/main/java/Main.java](src/main/java/Main.java) for logic.

Use `pmap -x` to grab the total amount of memory allocated and display that when all threads are active and then again after half of them have exited.

NOTES:
- `./run.sh` takes (3) arguments: <threadcount> <chunksizeMB> <chunkcount>
- `./run.sh` is expected to be run on a Linux system.
- You may need to install `procps` in your docker container.

## notes

- `man mallopt`
- `MALLOC_TOP_PAD_` can also affect this behavior (and be used to save some memory).


## repro case

Use `repro.sh` to demonstrate that:

1. AdoptOpenJDK 8 on Ubuntu results in unreleased freed native memory when `MALLOC_TRIM_THRESHOLD_` is *not* set.
1. AdoptOpenJDK 8 on Ubuntu releases all freed native memory when `MALLOC_TRIM_THRESHOLD_` is set.
1. Ubuntu's build of the JRE releases all freed native memory without having to set `MALLOC_TRIM_THRESHOLD_`.

**example output**

What we're looking for is that after 30 seconds, the dirtied pages allocated by the threads that have exited should have been reaped and no longer show up in the second report.

```
========================================================================

Ubuntu + AdoptOpenJDK, unset MALLOC_TRIM_THRESHOLD_

MALLOC_TRIM_THRESHOLD_= ; MALLOC_TOP_PAD_=
pid 9 allocated 4096 threads x chunkSize 1MB x chunkCount 4 = 16384MB total
=========== Sun Feb  2 10:13:32 UTC 2020 ===========
total kB         28099288 8754576 8738508
=========== Sun Feb  2 10:14:03 UTC 2020 ===========
total kB         27327272 8312424 8296356
killed pid 9


========================================================================

Ubuntu + AdoptOpenJDK, MALLOC_TRIM_THRESHOLD_=200000000

MALLOC_TRIM_THRESHOLD_=200000000 ; MALLOC_TOP_PAD_=
pid 9 allocated 4096 threads x chunkSize 1MB x chunkCount 4 = 16384MB total
=========== Sun Feb  2 10:14:15 UTC 2020 ===========
total kB         30850156 9349668 9333648
=========== Sun Feb  2 10:14:45 UTC 2020 ===========
total kB         22428780 4907116 4891092
killed pid 9

========================================================================

Ubuntu + Ubuntu OpenJDK, unset MALLOC_TRIM_THRESHOLD_

debconf: delaying package configuration, since apt-utils is not installed
MALLOC_TRIM_THRESHOLD_= ; MALLOC_TOP_PAD_=
pid 3620 allocated 4096 threads x chunkSize 1MB x chunkCount 4 = 16384MB total
=========== Sun Feb  2 10:15:39 UTC 2020 ===========
total kB         30855912 9478860 9461512
=========== Sun Feb  2 10:16:09 UTC 2020 ===========
total kB         22434536 4990052 4972680
killed pid 3620
```
