# cdp
Find project directories and cd into them.  
Basically a remake of `z` .

Uses rust (`./find_projects.rs`) to recursively find project directories.  
Project directories are identified by containing any code or manifest file,  
which are simply found by their file extension.

`./cdp.sh` wraps the compiled `./find_projects` program,  
and may launch `fzf`. See `./cdp.sh --help` for details.

`./cdp` is yet another wrapper, for `./cdp.sh`, which should be sourced  
into the user's interactive shell to actually `cd` into a project directory.  
See __Usage__.

## Usage
```
. ./cdp [...FLAGS] [...OPTIONS] [PATTERN]
```

## Build
You need to compile the rust program `./find_projects.rs` for `cdp.sh` to run.  
To compile with `rustc` run the build script ...
```
./build
```

## Installation
_TODO..._

## License
Distributed under the terms of the [MIT license].

[MIT license]: ./LICENSE
