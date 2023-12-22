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


## debugging

- logs are written to `log.txt` in the root of the project.
- log level, runtime seed, and key codes can be set in `bin/rougish.conf`.
- use the `~` key to toggle runtime stats.
- use the `\`` key to open the command bar. See `lib/screen/src/command\_screen::\_parseCommand` for supported commands.



[grinder] https://github.com/google/grinder.dart "dart workflows, automated"
