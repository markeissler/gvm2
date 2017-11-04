# Changelog: GVM2

## 0.10.5 / 2017-10-20

Fixes for gvm-installer to address regression which caused the installer to fail for new installations. Also improved
the update process to fail if the user requested the same __GVM2__ version that is currently installed.

This release includes a number of fixes for __ZSH__ support. Unit and integration tests for __ZSH__ support will be
included with the next release and at that time support is anticipated to be stable and complete.

Finally, an additional internal continuous integration (CI) server has been added to help with testing. Status for the master
branch as built on the [Jenkins CI](https://jenkins.io/) server can be viewed at the top of the [README](README.md)
page. This CI server is building against __Debian Jessie__ (bash 4/zsh 5, gcc-4) and __Debian Stretch__
(bash 4/zsh 5.3, gcc-6). The [Travis CI](https://travis-ci.org/markeissler/gvm2) server will continue to build for both
__macOS__ and __Ubuntu Trusty__ platforms at this time but is currently restricted to just testing for bash 4.

### Short list of commit messages

  * GVM2-72 Add GIT_COMMIT to Rakefile for Jenkins.
  * GVM2-72 Enclose bash -c paths in quotes.
  * GVM2-71 Fix broken line wrap on gvm-installer output.
  * GVM2-68 Fix unexpanded label reference in Rakefile.
  * GVM2-67 Remove symlink install strategy from gvm-installer.
  * GVM2-66 Fix gvm-installer to resolve dot and tilde in GVM_DEST.
  * GVM2-65 Isolate tests for gcc4 vs gcc6 on linux.
  * GVM2-64 Fix broken Package Set-Specific config produced by pkgset-create.
  * GVM2-63 Fix broken pgkset env files produced by pkgset-create.
  * GVM2-62 Add check for bash dependency.
  * GVM2-61 Improve sanity checking for missing dependencies.
  * GVM2-60 Fix scripts/update to fail if version is already installed.
  * GVM2-56 Improve gvm-installer final output.
  * GVM2-56 Fix calls to display_error() in gvm-installer.
  * GVM2-54 Fix __gvm_find_latest() to return correct latest version.
  * GVM2-53 Fix output for scripts/check.
  * GVM2-53 Update gvm update tests.
  * GVM2-26 Fix scripts/env/use.sh for zsh.
  * GVM2-26 Fix scripts/env/pkgset_use.sh for zsh.
  * GVM2-26 Fix scripts/uninstall for zsh.
  * GVM2-26 Fix __gvm_pwd() for zsh.
  * GVM2-26 Fix dep_load for zsh.
  * GVM2-26 Update bash_pseudo_hash to v1.4.1.
  * GVM2-26 Fix dep_load for zsh.

## 0.10.4 / 2017-10-07

Bug fixes.

### Short list of commit messages

  * GVM2-52 Fix linkthis usage text for clarity.
  * GVM2-51 Fix pkgenv to send proper path to text editor.
  * GVM2-50 Update gvm update tests.
  * GVM2-49 Fix sorting of gvm update list.

## 0.10.3 / 2017-09-26

Improve `gvm update` to not need a git login. The updated function will move the current installation out of the way and
then perform a new installation by pulling the installer (for the requested __GVM2__ version) from Github and then
running it. On success of the install process, the config directories from the previous installation will be copied to
the updated installation and then the previous installation will be removed. This design is intended to provide a method
to restore the previous installation manually upon failure.

> NOTE: The current roadmap will soon retire the use of `git` to install __GVM2__ in favor of installation from release
    archives. While the use of `git` provides some level of implementation convenience and efficiency it also results in
    an unnecessary use of storage space.

## 0.10.2 / 2017-09-22

Bug fixes to support calling `gvm` as a script instead of a function. In an interactive shell you should be loading the
`gvm` command as a function by sourcing gvm into your shell ([refer to the README](README.md)). In a non-interactive
shell `gvm` would not normally be loaded as a function but should be fully functional by calling the `$HOME/.gvm/bin/gvm`
script. Both of the `gvm use` and `gvm pkgset use` functions were broken for the latter scenario.

### Short list of commit messages

  * GVM2-46 Fix output of confirmation prompt status on cancel.
  * GVM2-45 Refactor implode as a script. Fix hang on --help.
  * GVM2-44 Update gvm-installer profile updates for sourcing gvm.
  * GVM2-44 Add tests to check if commands are reachable when gvm loaded as function or script.
  * GVM2-44 Update gvm loader script generation in gvm-installer.
  * GVM2-44 Update dependencies for gvm.sh and cd.sh.
  * GVM2-44 Fix use and pkgset-use commands when gvm not loaded as function.
  * GVM2-43 #comment Revise gvm sourcing instructions in README.

### Additional contributors for this release

Thanks to PRs from the following contributors:

  * Karthikeyan Marudhachalam ([tmkarthi](https://github.com/tmkarthi))

## 0.10.1 / 2017-09-12

The upgrade instructions for upgrades of older __GVM2__ (< 0.10.0) and __GVM__ installations were incorrect as they
resulted in previous environments being removed. The new instructions not only correct this problem but are also
simplified and ensure that no lingering legacy files are retained.

### Short list of commit messages

  * Revise upgrade instructions in README.

## 0.10.0 / 2017-09-12

Wow. Wow! With this release __GVM2__ has been 93% rewritten. Almost the entire code base has been touched
at this point and the remaining bits will be touched in upcoming releases.

Some of the goals for this release:

- Consistency: This includes consistent design patterns, consistent command invocation, consistent command usage help.
- Performance: Drastically reducing the number of sub-shells spawned throughout invocation lifetime.
- Deprecation: Remove checks for deprecated dependencies (e.g. mercurial) and repurpose commands that no longer make
    sense (e.g. `gvm cross` and `gvm update`).
- Add ability to update installed __GVM2__ from the command line. (Who hasn't been waiting for this?)

Read more about these topics below.

Some of the goals for the next release:

- Refactor install script
- Add polish to command output (like adding a final newline where needed)

### Consistency

Command help has been standardized and implemented throuhgout. Some of this work still needs a bit of polish but you
should be able to pass the `-h` or `--help` option to any command and receive usage information.

Every command has been refactored to support consistent __option__ and (where applicable) __sub-option__ flags and
some commands (like `gvm cross` and `gvm uninstall`) will support a list of arguments.

The goal is to also implement `--porcelain` and `--quiet` option support throughout to facilitate automated workflows.
Stubs for these options have been added to commands but not fully (or consistently) implemented yet.

### Performance

Testing __GVM2__ on [WSL - Windows Subsystem for Linux]() triggered a code review regarding the frequency with which
sub-shells were spawned throughout invocation lifetime. While forking processes is a relativley lightweight procedure
on UNIX/Linux, on Windows NT forking processes is a relatively expensive procedure. Without getting into the weeds
here, we generally want to reduce the number of times we fork on WSL (at least for now).

This release has been refactored entirely to drastically reduce the number of times a sub-shell is forked. This has
reduced the amount of time it takes to complete certain __GVM2__ commands like `gvm list` which could take upwards of
17 seconds to complete previously and now takes about 6 seconds on average. This is still very slow (on MacOS we are
looking at less than 1 second) but any further improvements will likely have to come from the Windows team.

### Deprecation

This is a big one.

- [bash-pseudo-hash](https://github.com/markeissler/bash-pseudo-hash) is an underlying library that is used throughout
    the __GVM2__ code base. This library has been updated to `v1.3.0` which improves performance and elminates a
    dependeny on the `hexdump` utility.
- Once upon a time the __Go__ project relied on [mercurial](https://www.mercurial-scm.org/) as its source control
    system; consquently, the original [GVM](https://github.com/moovweb/gvm) had a requirement that mercurial was
    installed. With this release, the entire dependency check code has been refactored and __GVM2__ no longer checks
    for the presence of the `hg` command.

#### Updated Commands

All of the commands have been refactored but some have also been replaced, repurposed, or removed.

##### Added: gvm check

The `gvm check` command is used to verify command dependencies. Previously, this functionality was implemented by
the `scripts/gvm-check` script and was only meant to be run automatically whenever invoking the `gvm` main command.
This updated command continues to be invoked automatically when calling specific commands (instead of performing the
check every time) but it can also be invoked by the user at any time.

```sh
Usage: gvm check [option] [<command ...>]
```

#### Added: gvm update

The `gvm update` command provides a new mechanism for updating the __GVM2__ installation. The `--list` option
provides a list of versions that are available. A warning prompt is displayed if the user specifies a version
number (to upgrade to) that doesn't support the update mechanism–meaning the user would have to manually perform
an update from an older version that doesn't support this new update mechanism.

#### Updated: gvm cross

The gvm cross command has been repurposed. In GVM the command installed support for cross compilation, that support
is now included with Go 1.5+. Therefore, the repurposed command is used to actually facilitate cross compilation
itself and has the following syntax:

```sh
Usage: gvm cross [option] <os> <arch> [sub-option] <file ...>
```

As well, the --list option will return a list of supported cross compilation target platforms:

```sh
Usage: gvm cross --list [option]
```

#### Removed: gvm get

The `gvm get` command has been removed. This poorly documented command was the mechanism used by the original
[GVM](https://github.com/moovweb/gvm) to update the installation. The only way to know its purpose was to read
the code that implemented it. This command has been superseded by the new `gvm update` command.

#### Removed: gvm-check

This was an internal script that should not have normally been called from the command line.

#### Removed: gvm update (the old command)

The previous gvm update command has been repurposed. The original command was used to update the local Go
archive cache. This made no sense since available Go versions were always retrieved by polling the upstream
git repo. Furthermore, the archive was explicitly updated before attempting to install a Go version from
source, which is why the local archive exists. It didn't make any sense to run this command separately.

### Short list of commit messages

Over 140 commits have been applied to this release. To view the commits, [check the __GVM2__ repo](https://github.com/markeissler/gvm2).

## 0.9.2 / 2017-07-22

So many bug fixes and improvements. Hurray!

### Automatic environment fixing (system, system@global)

The `system` and `system@global` environments are generated automatically at __GVM2__ installation. These environments
can become broken if/when the underlying system-native Go install is upgraded. __GVM2__ will now detect these changes
and try to fix these environments automatically.

### Target-specific listall

When using the `gvm listall` command output will be filtered for the target platform. Specifically, on macOS the source
list will reflect releases that are buildable on that platform (which is a subset due to build environment changes as
of macOS 10.12--blame Apple!).

### Go is considered installed even if a binary was installed

This is a fix for legacy weirdness. __GVM2__ had been considering Go installed only if a source distribution had been
previously installed from source (using `gvm install VERSION`). And yet Go could always be installed from a pre-built
(binary) package (using `gvm install VERSION --binary`). Behavior has been changed so now Go is considered to have been
installed in either case.

> NOTE: It is likely that in a future version of __GVM2__ that the behavior of installs will change so that binaries are
preferred and installed by default. In fact, __GVM2__ might step away from the current method of `git cloning` the repo
and just use packaged source and binary distributions. Just a heads up.

### Improved command help

It has started with the `gvm listall` command which now offers this help:

```txt
usage: gvm listall [options]

OPTIONS:
    -a, --all                   List all versions available
    -B, --binary                List available pre-built versions available
    -s, --source                List available source versions available
        --porcelain             Machine-readable output
    -h, --help                  Show this message

Command line arguments
----------------------
Without any arguments source (-s|--source) is selected by default. Only bonafide
releases are listed: legacy "weekly" and "release" tags are omitted. The source
list is filtered to only include versions that can be built on the running
platform. The binary list is filtered to only include versions that should have
a binary package available for the running platform.
```

This is the new format that will be implemented across all commands so that help is available and in a consistent
format.

### Short list of commit messages

This list has been filtered and summarized.

  * GVM2-2   Update README formatting.
  * GVM2-6   Update README to reflect suppression of sources not available for build target.
  * GVM2-21  Fix PATH munging for sudo rvm installs.
  * GVM2-3   Fix environment generation to produce cleaner entries.
  * GVM2-16  Fix munging of PATHs for elements that contain spaces.
  * GVM2-5   GVM2-14 Refactor gvm_listall script to filter list based on platform.
  * GVM2-14  Fix regex pattern in __gvm_find_available() to support beta and rc tags.
  * GVM2-20  Refactor dependency loading in function files and tests.
  * GVM2-14  Rename locale version error files to make them shorter.
  * GVM2-14  Fix cd() to consider Go installed if either the archive or binaries are present.
  * GVM2-14  Fix gvm_use() to consider Go installed if either the archive or binaries are present.
  * GVM2-14  Refactor __gvm_find_installed() to use __gvm_read_environment_file().
  * GVM2-14  Add __gvm_find_installed() function to find installed gos.
  * GVM2-10  Prevent shell config files from updates during test runs.
  * GVM2-2   Add debug flag support to gvm_export_path().
  * GVM2-5   Refactor install tests to support darwin and linux separately.
  * GVM2-5   Add DEBUG info to binary install.
  * GVM2-5   Refactor build (compile) to always use 1.4-bootstrap and restrict PATH.
  * GVM2-11  Fix straggling calls legacy calls to cd().
  * GVM2-5   Refactor install to move detect_run_os() into external function file.
  * GVM2-2   Refactor gvm_environment_sanitize() to fix broken system and system@ environments.

## 0.9.1 / 2017-05-28

Fix __Upgrading__ instructions in README file to include backup instructions and
to fix incorrect starting point directory.

## 0.9.0 / 2017-05-24

__GVM2__ adds some significant new functionality to Go environment management
with the introduction of:

  * `cd()` override
  * `.go-version`
  * `.go-pkgset`
  * `PATH` munging so [RVM](https://rvm.io/) and __GVM2__ can happily work together.
  * Fix bootsrap problems for MacOS Sierra (10.12).

### `cd()` override

__GVM2__ will override the `cd()` function in your shell to support `.go-version`
and `.go-pkgset` functionality. Overrides to `cd()` by others (most notably [RVM](https://rvm.io/))
will be preseved.

### `.go-version`

__GVM2__ will automatically select the correct (installed) Go version as you
switch directories by searching for the closest `.go-version` file. The "closest"
file is the one in the current directory or the closest parent directory.

### `.go-pkgset`

Just like the `.go-version` file support, __GVM2__ will also select the correct
__GVM2__ package set (after selecting a Go version) as you switch directories.

### `PATH` munging

To support co-existence with [RVM](https://rvm.io/), __GVM2__ will re-sort the
shell `PATH` so that __RVM__ appears first, __GVM2__ appears second, and remaining
`PATH` contents follow. Along the way, __GVM2__ will purge duplicate `PATH` entries.

### Fix bootstrap problems for MacOS Sierra (10.12)

__GMV2__ correctly bootstraps on __MacOS Sierra__ by adapting to upstream changes
made by Apple.

### Short list of commit messages

  * Update README for 0.9.0.
  * Add dependency check for hexdump.
  * Update installer for gvm2.
  * Update DEBUG instructions.
  * Update Upgrading instructions.
  * Update repo url for installer.
  * Add shell function binding from gvm2() to gvm().
  * Update version.
  * Update license.
  * Update doc formatting.
  * Add DEBUG.md to discuss Travis-CI build debugging strategies.
  * Fix Rakefile to sort tests by filename in ascending order.
  * Fix install to patch source for MacOS Sierra (10.12) before building.
  * Detect and install tagged bootstrap version of go1.4 when installing go1.4.
  * Add support for additional debug output to gvm-installer.
  * Update travis config to clone to a greater depth.
  * Fix Rakefile and travis config to support copying build logs to S3.
  * Fix "gvm use" to support go version alias names.
  * Fix "gvm use" pkgset name parsing.
  * Update "gvm use" help output for clarity.
  * Fix "gvm use" command to support 'master' version.
  * Fix install to only call builtin cd() function.
  * Fix formatting to git install instructions output by gvm-installer.
  * Fix tests in Rakefile to first cd into test directories.
  * Fix "gvm" command to return proper error code on failure during checks.
  * Fix "gvm" so it doesn't rename '.git' directory...only installer should do that.
  * Fix installer to create a system@global pkgset.
  * Update installer to output guidance for .go-version and .go-pkgset support.
  * Add zsh compatibility.
  * After loading cd(), cd to current directory to trigger auto selection.
  * Add munge_path() function to correct PATH for rvm compatibility.
  * Refactor pkgset-use to support cd().
  * Add fallback support for version and pkgset to cd().
  * Add support for porcelain output to list and pkgset-list.
  * Add GVM_DEBUG_LEVEL for less verbose debug output.
  * Add support for .go-version, .go-pkgset, and cd() override.
  * Forked from gvm.
