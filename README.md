# A set of tools for The SlackBuilds.org project.

**sbo_tools** is a set of Bash scripts to help you in your daily use
of The SlackBuilds.org project.

# Features

* No configuration file: it should just works (TM).
* It does not put in your way: based in "Write programs that do one thing and do it well."
* No dialog-based: just the command line interface you already know,
  so you can use `cd`, `ls`, `cat`, `vi`,  you name it.

# Notes

`sbo_tools`:
* is not part of The SlackBuilds.org (SBo) project.
* is not for an specific Slackware Linux version but it has been used exclusively in
  Slackware Linux 13.37, 14.0 and 14.1
* just works with SBo repository that matches your Slackware Linux version, using
  rsync to update your local repository of SlackBuilds.

# Tools

* **sbo_sync**: synchronize a local repository with SBo SlackBuilds repository.
* **sbo_pkg**: creates an Slackware package using an SlackBuild.
* **sbo_find**: searches through the local repository for a given SlackBuild.
* **sbo_inst**: searches and lists installed SlackBuilds or packages.
* **sbo_diff**: print a list of SlackBuilds available as updates.
* **sbo_wwws**: a command-line interface to http://slackbuilds.org/result/
* **sbo_info**: given an SlackBuild's directory prints a formated information.

# Installation

As normal-user/root execute:

`git clone https://github.com/nihilismus/sbo_tools.git`

Inside sbo_tools directory, execute as root:

`make`

By default the tools are going to be installed inside `/usr/local/bin`, to install
in another directory execute, for example:

`make PREFIX=/usr`

This would install the tools inside `/usr/bin`

# Setup

Once you have installed sbo_tools, as root execute:

```
sbo_sync
sbo_sync: rsync:://slackbuilds.org/slackbuilds/14.1 => /usr/ports/14.1
sbo_sync: synchronizing in 5 segs .....
receiving incremental file list
./
...
sent 4.00K bytes  received 438.12K bytes  52.01K bytes/sec
total size is 38.70M  speedup is 87.53
sbo_sync: done
```

If you want to mantain your local repository, lets say, inside `/home/sbo`,
you can create a symlink as root:

`ln -s /home/sbo /usr/ports`

and sbo_tools would create your local repository at /usr/ports/14.1

# Usage

Execute any of the tools with the `--help` option to get a basic
documentation about their use.

# Update

Inside sbo_tools directory, execute as normal-user/root:

`git pull`


# Uninstallation

Inside sbo_tools directory, execute as root:

`make uninstall`

Same as installation, to uninstall from `/usr/bin` execute:

`make PREFIX=/usr uninstall`

# TODO

* Add more documentation (man pages?, wiki?, examples?)
* Improve code, maybe it would need a restructuring (at this moment
  is a mess, but a good one ;)
* Make use of sbopkg queue files, http://www.sbopkg.org/queues.php (at this moment
  there's no way to program the installation of a package from its SlackBuild with
  its corresponding dependencies)

# Contact me

* hba.nihilismus@gmail.com
* http://twitter.com/nihilipster

# Related projects

* http://sbopkg.org  
  If you are interesting in something with a
  dialog-based-configuration-file-all-in-one-command approach.
* http://dawnrazor.net/sbotools/  
  If you want a silver bullet with a
  im-more-clever-to-tell-you-how-to-manage-your-system-configuration-file approach.
