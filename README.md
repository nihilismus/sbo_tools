# A set of tools to deal with The SlackBuilds.org project.

**sbo_tools** is a set of Bash scripts to help you in your daily use
of The SlackBuilds.org project.

# Tools

* **sbo_sync**: synchronize a local repository of Slackware build scripts.
* **sbo_pkg**: creates a Slackware package using a SlackBuild file.
* **sbo_find**: searches through the local repository for a given SlackBuild.
* **sbo_inst**: lists/searches for installed packages.

# Installation

As root execute:

`make`

By default the tools would be installed inside `/usr/local/bin`, to install
in other directory execute as, for example:

`make PREFIX=/usr`

This would install the tools inside `/usr/bin`

# Uninstallation

As root execute:

`make uninstall`

Same as installation, to uninstall from `/usr/bin` execute:

`make PREFIX=/usr uninstall`

# Usage

Execute any of the tools with the `--help` option to get a basic
documentation about their use.
