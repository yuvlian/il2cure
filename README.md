# il2cure

a basic Windows il2cpp "modding" library in Odin. Resolve exports,
walk reflection, install hooks, all natively!

imagine a few small packages that
let you make a .dll and take over a game from the inside.

and because it's raw
native code you get the things the managed modding stacks can't do!

patching
instructions, hooking at the byte level, touching constants, with no GC and
no managed runtime in the way...

## wyg?

- **export resolution**: you can easily fine grain the way exports are resolved! or skip the ones you dont need... GetProcAddress, by byte-pattern signature, by obfuscated name, or by API-table index. `il2cpp.init()` lazily loads every export the library needs.

- **reflection**: list & interact with assemblies/images, classes, fields, methods, properties, and attribute flags the way you would in C# `System.Reflection`!!

- **hooks**: methodPointer, inline detours, IAT patch, single byte patchers, blablabla. They are easy to install and uninstall. Stuff like pristines are also handled

- **unity wrappers**: if you wanna use unity's built in stuff, i should have most of them wrapped already in `unity/unity.odin`

- **formatting**: an layer for turning raw metadata into readable strings, and a `frame` helper that maps a reflected class onto a plain Odin struct by field name.

## reqs

- odin https://github.com/odin-lang/Odin/releases
- an il2cpp game to test the dll you made, duh. Note that this project was made in mind for Unity 6000+
- a way to load the dll. Most games will load one of these: `winhttp.dll` / `version.dll` / `umpdc.dll` if you put them beside the `Game.exe`. If not then just make an injector, lol.

## quick start

clone repo, build the base example:

```
odin build .examples/base -build-mode:dll
```

all this dll does is just set timescale to 0.2 once

## examples

- `base/`: the one in quick start. the "hello world" of this project. attach, spawn a thread, open a console, wait for the game, init il2cpp.

- `coverage/`: a fake mod that tries to use everything in the project. i recommend reading the source code, but this might help for the first read.

## packages

| package      | what it does |
|--------------|--------------|
| `console/`   | helper for Windows console |
| `extra/`     | extra stuff that idk where to put, like boot & formatting helpers |
| `hook/`      | inline detours + the x86-64 decoder underneath, IAT patching, byte patchers |
| `il2cpp/`    | the ultimate awesome possum wubba lubba dub dub il2cpp bridge |
| `reflection/`| `System.Reflection`-style layer over assemblies/classes/members/attributes |
| `scan/`      | PE/module walking: signature scanning, resolving `rel32`/rip-relative addresses and whatever, sections, imports |
| `unity/`     | wrappers for common Unity stuff |

## how it works

idk im lazy to explain. if u want to learn odin: https://odinbook.com/ 

its a good read i heard. i cant read sorry i cant say much!

## license

MIT

-- --

### if you read it this far, check out my other awesome odin project for counter strike 2: https://github.com/yuvlian/aqua-omega-attack :D
