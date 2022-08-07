# rougish
a rougue-like

## building
> rougish uses the [grinder] task runner for dart (see `tool/grind.dart`)

to see the list of available build tasks:

```console
$ grind
```

to build and run while developing:

```console
$ grind compile && bin/rougish
```

to run all the tasks needed to prepare a release candidate:

```console
$ grind build
```



[grinder] https://github.com/google/grinder.dart "dart workflows, automated"
