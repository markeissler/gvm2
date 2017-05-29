# 0.9.1 / 2017-05-28

Fix __Upgrading__ instructions in README file to include backup instructions and
to fix incorrect starting point directory.

# 0.9.0 / 2017-05-24

__GVM2__ adds some significant new functionality to Go environment management
with the introduction of:

* `cd()` override
* `.go-version`
* `.go-pkgset`
* `PATH` munging so [RVM](https://rvm.io/) and __GVM2__ can happily work together.
* Fix bootsrap problems for MacOS Sierra (10.12).

## `cd()` override

__GVM2__ will override the `cd()` function in your shell to support `.go-version`
and `.go-pkgset` functionality. Overrides to `cd()` by others (most notably [RVM](https://rvm.io/))
will be preseved.

## `.go-version`

__GVM2__ will automatically select the correct (installed) Go version as you
switch directories by searching for the closest `.go-version` file. The "closest"
file is the one in the current directory or the closest parent directory.

## `.go-pkgset`

Just like the `.go-version` file support, __GVM2__ will also select the correct
__GVM2__ package set (after selecting a Go version) as you switch directories.

## `PATH` munging

To support co-existence with [RVM](https://rvm.io/), __GVM2__ will re-sort the
shell `PATH` so that __RVM__ appears first, __GVM2__ appears second, and remaining
`PATH` contents follow. Along the way, __GVM2__ will purge duplicate `PATH` entries.

## Fix bootstrap problems for MacOS Sierra (10.12)

__GMV2__ correctly bootstraps on __MacOS Sierra__ by adapting to upstream changes
made by Apple.

## Short list of commit messages

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
