# gvm2

__GVM2__ manages [Go (Golang)](https://golang.org/) application environments and
enables switching between them.

>BETA: __GVM2__ is currently in pre-release. That doesn't mean it's not ready for production, it just means it
hasn't been tested by a large audience yet. The more the merrier and the faster we get to v1.0. Install it, open issues
if you find bugs.

## Build Status

| Service | Master | Develop |
|:--------|:-------|:--------|
| CI Status | [![Build Status](https://travis-ci.org/markeissler/gvm2.svg?branch=master)](https://travis-ci.org/markeissler/gvm2) | [![Build Status](https://travis-ci.org/markeissler/gvm2.svg?branch=develop)](https://travis-ci.org/markeissler/gvm2) |
| Documentation |![Build Status](https://img.shields.io/badge/doxygen-unknown-lightgrey.svg) | ![Build Status](https://img.shields.io/badge/doxygen-unknown-lightgrey.svg)|

## Overview

Juggling different versions of Go across different projects is a troublesome task, a task that involves remembering and
manually updating Go environment variables.

While it "would be nice" to only ever have to work with a single version of Go, perhaps the most-recent release, the
reality is that different projects may require different Go versions just because (you know what the reasons are). And
different projects will almost definitely require different package dependencies.

The [RVM](https://github.com/rvm/rvm) team had already solved this problem for ruby development;
[GVM](https://github.com/moovweb/gvm) got us part of the way to solving the same problem for Go develpment. __GVM2__ has
the goal of taking things a bit further by making this tool behave more like __RVM__.

Perhaps the biggest step forward is the introduction of __GVM2__ `.go-version` and `.go-pkgset` files similar to
__RVM__'s `.ruby-version` and `.ruby-gemset` files. What a huge convenience it is to have your Go version selected
automatically whenever you change directories! Couple this functionality with support for isolated dependency sets (in
the form of "package sets") and suddenly version and package management business becomes a breeze.

## Installing

To upgrade a previous installation see the [Upgrading](#upgrading) section.

For a fresh installation:

```sh
prompt> curl -sSL https://raw.githubusercontent.com/markeissler/gvm2/master/binscripts/gvm-installer | bash
```

Or if you are using zsh just change `bash` to `zsh`.

### Sourcing gvm into your shell (bash, zsh)

The __GVM2__ installer will attempt to update your shell init file (`.bashrc`, `.bash_profile`, `.zlogin`, etc.) by
appending the following line:

```sh
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
```

After the installer completes, you should verify that the line has been added to the correct file (e.g. `.bashrc` vs
`.bash_profile`) since the installer can't guess the peculiarities of your setup!

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

## Upgrading

__GVM2__ does not yet support upgrading previous installations. Rest assured that before this project achieves revision
1.0 this shortcoming will have been resolved. In the meantime, you can upgrade in place with the following
instructions...

>WARNING: It is highly recommended to backup your entire `$HOME/.gvm` directory before proceeding.

1. Backup your `$HOME/.gvm` directory:

```sh
prompt> builtin cd ~
prompt> cp -Rp ~/.gvm ~/.gvm.bak
```

2. Grab the HEAD commit on master. This creates just the `.git` directory; the original `.git` directory will have been
    renamed during original installation.

```sh
prompt> git clone --no-checkout "https://github.com/markeissler/gvm2.git" ~/.gvm/gvm-update.tmp
```

3. Move the resulting `.git` directory in place, then reset the local repo state.

```sh
prompt> mv ~/.gvm/gvm-update.tmp/.git ~/.gvm/
prompt> rmdir ~/.gvm/gvm-update.tmp/
prompt> builtin cd ~/.gvm
prompt> git reset --hard HEAD
prompt> mv git.bak git.bak.old
prompt> mv .git git.bak
```

4. Open a new terminal to test.

5. If everything looks ok, then go ahead and remove the `~/.gvm.bak` directory.

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

[compiler_note]: https://docs.google.com/document/d/1OaatvGhEAq7VseQ9kkavxKNAfepWy2yhPUBs96FGV28/edit

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
usage: gvm listall [options]

OPTIONS:
    -a, --all                   List all versions available
    -B, --binary                List available pre-built versions available
    -s, --source                List available source versions available
        --porcelain             Machine-readable output
    -h, --help                  Show this message
```

The `gvm listall` command will, by default, list all __source__ versions that are available to build on the target
platform. The list will be considerably shorted for macOS due to changes in the build environment as of macOS 10.12
(Sierra). In general, you can install older versions of Go on macOS by installing pre-built packages (binaries).

To list all pre-built packages available for the target platform specify the `--binary` option to the `gvm listall`
command.

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
__GVM2__ depending on the presence of a .go-pkgset file.

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

Whenever you change directories (using the cd() command), __GVM2__ will search for an applicable `.go-version` and
`.go-pkgset` file. The search will begin in the directory that your are changing to and will then continue all the way
up to the top of your HOME directory. If these files appear anywhere along the path during the upwards traversal,
__GVM2__ will select the file, parse it and apply it. __GVM2__ will only consider the first file it encounters.

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

## macOS Requirements

### Install Xcode command line tools

```sh
prompt> xcode-select --install
```

### Add dependencies with Homebrew

The easiest way to install dependencies on MacOS is with the [Homebrew](https://brew.sh/) package manager:

```sh
prompt> brew update
prompt> brew install mercurial
```

## Linux Requirements

<a name="install-ubuntu"></a>

### Debian/Ubuntu

```sh
prompt> sudo apt-get install curl git mercurial make binutils bison gcc build-essential bsdmainutils
```

### Redhat/Centos

```sh
prompt> sudo yum install curl git make bison gcc glibc-devel
```

 * Install Mercurial from http://pkgs.repoforge.org/mercurial/

## FreeBSD Requirements

```sh
prompt> sudo pkg_add -r bash git mercurial
```

> WARNING: __GVM2__ is not currently tested or developed for FreeBSD. Complete support for this platform will likely
be restored in the future but is not currently scheduled.

## Windows 10 WSL (aka Bash on Ubuntu on Windows)

__GVM2__ works on WSL. Instructions are the same as for [Debian/Ubuntu](#install-ubuntu).

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

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

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
