# Changelog: GVM2

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
