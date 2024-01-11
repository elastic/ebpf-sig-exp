# Experiments with eBPF and signals

[Blog post about this research](https://www.elastic.co/security-labs/signaling-from-within-how-ebpf-interacts-with-signals)

This repository holds a series of scripts and mini programs that attempt to
demonstrate "what happens if we use SIGKILL as a security mechanism". Primarily
we are interested in pinpointing what kind of system behaviour we can
effectively "block".

# Running
```
$ make test
or
$ make test FAST=y # (escapes racers)
or
$ make test FAST=y ART=/path/artefacts
```

As discussed in the [blog post](https://www.elastic.co/security-labs/signaling-from-within-ebpf), different file systems may
yield different results, you can pass `ART=/tmp/artefacts` to see how tmpfs
behaves for instance.
