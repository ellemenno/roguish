# roguish
a rougue-like


## building
> roguish uses the [grinder] task runner for dart (see `tool/grind.dart`)

to see the list of available build tasks:

```console
$ grind
```

to build and run while developing:

```console
$ grind compile && bin/roguish
```

to run all the tasks needed to prepare a release candidate:

```console
$ grind build
```


## debugging

- logs are written to `log.txt` in the root of the project.
- log level, runtime seed, and key codes can be set in `bin/roguish.conf`.
- use the `~` (_tilde_) key to toggle runtime stats.
- use the `` ` `` (_grave_) key to open the command bar.
  - see `lib/screen/src/command_screen::_parseCommand()` for supported commands.



[grinder]: https://github.com/google/grinder.dart "dart workflows, automated"
