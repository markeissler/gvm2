# gvm2

[![License](http://img.shields.io/badge/license-MIT-yellowgreen.svg)](#license)

__GVM2__ manages [Go (Golang)](https://golang.org/) application environments and
enables switching between them.

>BETA: __GVM2__ is currently in pre-release. That doesn't mean it's not ready for production, it just means it
hasn't been tested by a large audience yet. The more the merrier and the faster we get to v1.0. Install it, open issues
if you find bugs.

## Build Status

| Service    | bash 4.3 | zsh 5.0.7 | zsh 5.3+ |
|:-----------|:--------:|:---------:|:--------:|
| Jenkins CI | [![Build Status](http://ci.mixtur.com/buildStatus/icon?job=bash-pseudo-hash+%28bash+4%29)]() | [![Build Status](http://ci.mixtur.com/buildStatus/icon?job=gvm2+%28bash+4%29)]() | [![Build Status](http://ci.mixtur.com/buildStatus/icon?job=gvm2+%28zsh+5.3%2B%29)]() |
| Travis CI  | [![Build Status](https://travis-ci.org/markeissler/gvm2.svg?branch=master)](https://travis-ci.org/markeissler/gvm2) | -- | -- |

## Overview

__GVM2__ supports Go development through the creation of **_Go environments_** where each environment supports isolation of
a Go version and associated package dependencies.

The goal of __GVM2__ is to become the ubiquitous environment manager for Go development in the same way that the [RVM](https://github.com/rvm/rvm)
environment manager has become an indispensable tool for ruby development.

Perhaps the biggest step forward is the introduction of __GVM2__ `.go-version` and `.go-pkgset` files similar to
__RVM__'s `.ruby-version` and `.ruby-gemset` files. When you add these `.go-` files to your project's directory (or even
in a parent directory) __GVM2__ will automatically update your `GOPATH` and related environment variables to reflect the
correct Go version and package dependencies for the current project.

## Installing

To upgrade a previous installation see the [Upgrading](#upgrading) section.

>NOTE: Before proceeding verify that all dependencies have been installed. See the [Dependencies](#dependencies) section
for more information.

For a fresh installation:

```sh
prompt> curl -sSL https://raw.githubusercontent.com/markeissler/gvm2/master/binscripts/gvm-installer | bash
```

Or if you are using zsh just change `bash` to `zsh`.

<a name="sourcing"></a>

### Sourcing gvm into your shell (bash, zsh)

The __GVM2__ installer will attempt to update your shell init file (`.profile`, `.bash_profile`, `.zlogin`, etc.) by
appending the following line:

```sh
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
```

After the installer completes, you should verify that the line has been added to the correct file (e.g. `.profile`
vs `.bash_profile`) since the installer can't guess the peculiarities of your setup!

>If you are using [RVM](https://github.com/rvm/rvm) as well, then __GVM2__ should be loaded __after__ RVM. __The
instructions for RVM will conflict with these instructions.__ Loading RVM last will result in a broken environment.
While __GVM2__ has been designed to accommodate RVM, the reverse statement is not true.

If you are using both __GVM2__ and [RVM](https://github.com/rvm/rvm), then you will need to make sure that __GVM2__ is
loaded last:

```sh
export PATH="$PATH:$HOME/.rvm/bin"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
```

If __GVM2__ is installed after RVM, then the above entries should have been appended to your shell init file in the
correct order.

<a name="upgrading"></a>

## Upgrading (> 0.10.0)

```sh
prompt> gvm update
```

List available updates:

```sh
prompt> gvm update --list
```

>NOTE: This command may be renamed to "upgrade" in a forthcoming release.

## Upgrading (< 0.10.0)

If you need to upgrade an older version of __GVM2__ (prior to 0.10.0) or if you'd like to migrate from __GVM__ to
__GVM2__ then you will need to proceed with a manual upgrade.

Essentially, with this method you will move your current install, then re-install __GVM2__ (latest version), then
copy your previous configuration to the new installation. Once you are satisified that the upgrade has been a
success you may elect to delete the previous (renamed) installation.

>WARNING: Proceed with caution and make sure you follow these steps exactly.

1. Move your `$HOME/.gvm` directory:

```sh
prompt> builtin cd ~
prompt> mv ~/.gvm ~/.gvm.bak
```

2. Re-install __GVM2__:

```sh
prompt> curl -sSL https://raw.githubusercontent.com/markeissler/gvm2/master/binscripts/gvm-installer | bash
```

3. Copy your previous configuration into the new installation:

```sh
prompt> cp -Rp ~/.gvm.bak/{archive,environments,gos,pkgsets} ~/.gvm/
```

4. Open a new terminal to test.

5. If everything looks ok, then go ahead and remove the `~/.gvm.bak` directory.

## General Usage

All __GVM2__ commands offer online help:

```txt
Usage: gvm <command> [option]

GVM2 is the Go enVironment Manager

Commands:
    alias       Manage Go version aliases
    check       Check for and list missing dependencies
    cross       Cross compile a Go program
    diff        View changes to an installed Go directory contents
    help        Show this message
    implode     Uninstall GVM2 (You probably don't want to do this)
    install     Install a Go version
    linkthis    Create link from package set src directory to working directory
    list        List currently installed versions of Go
    listall     List Go versions available for installation
    pkgset      Manage GVM2 package sets (aka "pkgsets")
    pkgenv      Edit the environment for a GVM2 package set
    uninstall   Uninstall a Go version
    update      Update GVM2 to latest release
    use         Select which installed Go version to use
    version     Print the GVM2 version number

Run 'gvm <command> --help' for more information on a command.
```

## Installing Go

Once you've installed __GVM2__, you will need to install a bootstrap version of Go. The last revision of Go that can be
built with C compilers is Go 1.4.; therefore, __the very first version of Go that you must install is Go 1.4__:

```sh
prompt> gvm install go1.4.3
prompt> gvm use go1.4.3
```

Once those steps have been completed, Go will be in your PATH. Also, `$GOROOT` and `$GOPATH` will be set automatically.
You can verify success with:

```sh
prompt> go version
go version go1.4.3 linux/amd64
```

Additional options can be specified when installing Go:

```txt
Usage: gvm install [version] [options]
    -s,  --source=SOURCE      Install Go from specified source.
    -n,  --name=NAME          Override the default name for this version.
    -pb, --with-protobuf      Install Go protocol buffers.
    -b,  --with-build-tools   Install package build tools.
    -B,  --binary             Only install from binary.
         --prefer-binary      Attempt a binary install, falling back to source.
    -h,  --help               Display this message.
```

A little more background: [compiler_note](https://docs.google.com/document/d/1OaatvGhEAq7VseQ9kkavxKNAfepWy2yhPUBs96FGV28/edit)

## List Go Versions

To list all installed Go versions:

```sh
prompt> gvm list
```

To list all Go source versions available for download:

```sh
prompt> gvm listall
```

Additional options can be specified:

```txt
Usage: gvm listall [option]

List Go versions available for installation

Options:
    -a, --all                   List all versions available
    -B, --binary                List available pre-built versions available
    -s, --source                List available source versions available
        --porcelain             Machine-readable output
    -q, --quiet                 Suppress progress messages
    -h, --help                  Show this message
```

The `gvm listall` command will, by default, list all __source__ versions that are available to build on the target
platform. The list will be considerably shorter for macOS due to changes in the build environment as of macOS 10.12
(Sierra). In general, you can install older versions of Go on macOS by installing __pre-built versions (binaries)__.

To list all pre-built versions available for the target platform specify the `--binary` option to the `gvm listall`
command.

>NOTE: The installer may default to installing binaries in a forthcoming release.

### Suppression of rc, beta, release, weekly tags

The `gvm listall` command suppresses output of __rc__ and __beta__ tags for pre-built packages simply because they are
not available. The legacy __release__ and __weekly__ tags are suppressed for brevity.

## Using a Go Version

Before you can use Go, you will need to select a Go version. Usually, this step will be automatically handled by
__GVM2__ but you can, at any time, manually select a Go version:

```sh
prompt> gvm use go1.4
```

The Go version that is in use will be the last one you selected or the one that is auto-selected by __GVM2__. See
[Auto selection of Go version and GVM2 pkgset](#auto-selection) for more information.

## Using a Package Set with a Go Version

A package set (__pkgset__) provides a way for you to isolate dependencies for a project in that all dependencies
installed with `go get` will be installed into the currently active __pkgset__.

Package sets are bound to Go versions. When you switch Go versions (using the `gvm use` command), the list of package
sets available will change. The package set in use will be the last one you selected or the one that is auto-selected by
__GVM2__ depending on the presence of a `.go-pkgset` file.

### Create a Package Set

Before you can create or select a package set, you must first select a Go version.

```sh
prompt> gvm pkgset create "my-package-set"
prompt> gvm pkgset use "my-package-set"
```

## Determining which Go version and pkgset is active

### Active Go version

There are two ways to determine which version of Go is active. The first option is to use the native `go version`
command:

```sh
prompt> go version
go version go1.7.1 darwin/amd64

```

The second option is to use __GVM2__:

```sh
prompt> gvm list

gvm gos (installed)

   go1.4.3
   go1.6.3
   go1.7
=> go1.7.1
   system
```

In the above example, the active Go version is flagged with the `=>` indicator.

### Active Go pkgset

```sh
prompt> gvm pkgset list

gvm go package sets (go1.7.1)

    global
=>  gotest_1.7
    dataconnect_1.7
    spoofexample_1.7
    testinghttp_1.7
```

In the above example, the active Go pkgset is flagged with the `=>` indicator.

## Uninstalling

To completely remove gvm and all installed Go versions and packages:

```sh
prompt> gvm implode
```

If that doesn't work see the troubleshooting steps at the bottom of this page.

## Using .go-version and .go-pkgset files

Prior to the introduction of the `.go-version` and `.go-pkgset` files, you had to manually select the Go version and
package set in use, and then those settings remained set until you once again changed them or began a new session. When
juggling several Go projects it can become quite a hassle to not only remember which version and pkgset you should be
using, but also to execute the commands to switch to the correct version and pkgset.

The use of `.go-version` and `.go-pkgset` files eliminates this problem all together.

### .go-version

The content of a `.go-version` file is simple:

```sh
prompt> cat ~/dev/my_go_project/.go-version
go1.4
```

Just a single line consisting of a Go version as reported by the `gvm list`
command.

### .go-pkgset

The content of a `.go-pkgset` file is simple:

```sh
prompt> cat ~/dev/my_go_project/.go-pkgset
my-package-set
```

Again, a single line consisting of a __GVM2__ package set as reported by the `gvm pkgset list` command.

<a name="auto-selection"></a>

### Auto selection of Go version and GVM pkgset

Whenever you change directories (using `cd`), __GVM2__ will search for an applicable `.go-version` and `.go-pkgset`
file. The search will begin in the directory that your are changing to and will then continue all the way up to the top
of your HOME directory. If these files appear anywhere along the path during the upwards traversal, __GVM2__ will select
the file, parse it and apply it. __GVM2__ will only consider the first file it encounters.

If the `.go-version` and/or the `.go-pkgset` files are not found, __GVM2__ will next attempt to make suitable guesses
for an appropriate environment to select. The order of guessing looks like this:

```
Go version:
    1. default environment
    2. system environment
    3. highest version of Go installed

GVM pkgset:
    global pkgset for the version of Go selected
```

>NOTE: Auto selection is only supported when `gvm` is loaded as a function into your shell. See the
[Sourcing gvm into your shell (bash, zsh)](#sourcing) section for more information.

<a name="dependencies"></a>

## Dependencies

### macOS Dependencies

#### Install Xcode command line tools

```sh
prompt> xcode-select --install
```

### Linux Dependencies

<a name="install-ubuntu"></a>

### Debian/Ubuntu

```sh
prompt> sudo apt-get install curl git make binutils bison gcc build-essential
```

### Redhat/Centos

```sh
prompt> sudo yum install curl git make bison gcc glibc-devel
```

### FreeBSD Dependencies

```sh
prompt> sudo pkg_add -r bash git
```

>WARNING: __GVM2__ is not currently tested or developed for FreeBSD. Complete support for this platform will likely
be restored in the future but is not currently scheduled.

## Windows 10 WSL (aka Bash on Ubuntu on Windows)

__GVM2__ works on WSL. Instructions are the same as for [Debian/Ubuntu](#install-ubuntu).

>NOTE: __GVM2 0.10.0__ vastly improves performance on WSL over previous releases, however, due to limitations in
the current implementation of WSL with regard to file system interaction, performance is still poor when compared
to running __GVM2__ on native Linux (bare metal, VM, Docker container, etc.) or macOS. This behavior is not
limited to __GVM2__. For more information see: [Major performance (I/O?) issue in /mnt/* and in ~ (home) #873](https://github.com/Microsoft/BashOnWindows/issues/873).

## Typical Usage

The following example illustrates a typical workflow. The example assumes that "go1.7" has already been installed.

```sh
prompt> mkdir my_project
prompt> cd my_project
prompt> gvm use go1.7
prompt> gvm pkgset create "my_project"
prompt> gvm pgkset use "my_project"
prompt> echo "go1.7" > .go-version
prompt> echo "my_project" > .go-pkgset
```

Because we are creating both the `.go-version` and `.go-pkgset` files the next time you change into this directory
__GVM2__ will automatically set both the Go version and pkgset.

## Vendoring

Vendoring is a moving target in __GVM2__ with a specific goal to add support for Godep vendoring. Existing legacy
[GPKG](http://github.com/moovweb/gpkg) support will likely be removed.

## Vendoring Native Code and Dependencies

__GVM2__ supports vendoring package set-specific native code and related dependencies, which is useful if you need to
qualify a new configuration or version of one of these dependencies against a last-known-good version in an isolated
manner.

The following environment variables are available once you've selected a package set (`gvm pgkset use <package_name>`):

1. `${GVM_OVERLAY_PREFIX}` functions in a manner akin to a root directory hierarchy suitable for `auto{conf,make,tools}`
    where it could be passed in to `./configure --prefix=${GVM_OVERLAY_PREFIX}` and not conflict with any existing
    operating system artifacts and hermetically be used by your workspace.  This is suitable to use with
    `C{PP,XX}FLAGS and LDFLAGS`, but you will have to manage these yourself, since each tool that uses them is
    different.

2. `${PATH}` includes `${GVM_OVERLAY_PREFIX}/bin` so that any tools you manually install will reside there, available
    for you.

3. `${LD_LIBRARY_PATH}` includes `${GVM_OVERLAY_PREFIX}/lib` so that any runtime library searching can be fulfilled
    there on FreeBSD and Linux.

4. `${DYLD_LIBRARY_PATH}` includes `${GVM_OVERLAY_PREFIX}/lib` so that any runtime library searching can be fulfilled
    there on MacOS.

5. `${PKG_CONFIG_PATH}` includes `${GVM_OVERLAY_PREFIX}/lib/pkgconfig` so that `pkg-config` can automatically resolve
    any vendored dependencies.

### Vendoring Native Code Example Workflow


```sh
prompt> gvm use go1.1
prompt> gvm pkgset use current-known-good

# Let's assume that this includes some C headers and native libraries, which
# Go's CGO facility wraps for us.  Let's assume that these native
# dependencies are at version V.
prompt> gvm pkgset create trial-next-version

# Let's assume that V+1 has come along and you want to safely trial it in
# your workspace.
prompt> gvm pkgset use trial-next-version

# Do your work here replicating current-known-good from above, but install
# V+1 into ${GVM_OVERLAY_PREFIX}.
```

See `examples/native` for a working example.

## Contributing

Contributions are welcome:

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

Please be sure to provide a concise overview of the issue you are trying to resolve. If you are submitting a pull
request (PR) to address a bug you've encountered then it is critical you also provide steps to reproduce the problem
along with captured output.

## Authors

__GVM2__ is the work of __Mark Eissler__ based on the original work of others as noted in the
[Attributions](#attributions) section below.

<a name=attributions></a>

## Attributions

__GVM2__ is a fork of [GVM](https://github.com/moovweb/gvm). A lot of work has gone into producing __GVM2__ which offers
a more _RVM-like_ experience. Still, without the prior work of __Josh Bussdieker (jbuss, jaja, jbussdieker)__, previous
contributors and, of course, the inspiration provided by the [RVM](https://github.com/rvm/rvm) project, this project
would probably not exist.

## License

__GVM2__ is licensed under the MIT open source license.

---
Without open source, there would be no Internet as we know it today.
