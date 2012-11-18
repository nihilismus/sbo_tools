# A set of tools to deal with The SlackBuilds.org project.

**sbo_tools** is a set of Bash scripts to help you in your daily use
of The SlackBuilds.org project.

# Features

* No configuration file: based in "Convention over configuration".
* It does not put in your way: based in "Write programs that do one thing and do it well."
* No dialog-based: just the command line interface you already know,
  so you can use `cd`, `ls`, `cat`, `vi`,  you name it.

# Notes

* sbo_tools is not part of The SlackBuilds.org (SBo) project.
* sbo_tools is not for an specific Slackware Linux version but its daily use it is for the
  Slackware Linux version you have installed so there is no way to access a different
  SBo repository version.
* From the previous note, sbo_tools depends on the content of `/etc/slackware-version` to
  work without the need for a configuration file/option.

# Tools

* **sbo_sync**: synchronize a local repository of Slackware build scripts.
* **sbo_pkg**: creates a Slackware package using a SlackBuild file.
* **sbo_find**: searches through the local repository for a given SlackBuild.
* **sbo_inst**: lists/searches for installed packages.
* **sbo_diff**: print a list of updates.
* **sbo_wwws**: a command-line interface to http://slackbuilds.org/result/
* **sbo_info**: given an SlackBuild's directory prints a minimal formated information.

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

`sbo_sync`

This would end with an error like:

`sbo_sync: Error, directory /usr/ports/13.37 does not exist.`

This means that the version of your Slackware Linux installation is 13.37, so now
execute:

`mkdir -p /usr/ports/13.37`

Create /usr/ports/13.37/ChangeLog.txt as en empty file:

`touch /usr/ports/13.37/ChangeLog.txt`

Execute once again:

```
sbo_sync
sbo_sync: rsync:://slackbuilds.org/slackbuilds/13.37 => /usr/ports/13.37
receiving incremental file list
./
ChangeLog.txt
README
SLACKBUILDS.TXT
SLACKBUILDS.TXT.gz
academic/
academic/EMBASSY/
academic/EMBASSY/CONTENTS
academic/EMBASSY/EMBASSY.SlackBuild
...
system/zfs-fuse/slack-desc
system/zfs-fuse/zfs-fuse.SlackBuild
system/zfs-fuse/zfs-fuse.info

sent 324.14K bytes  received 25.61M bytes  102.29K bytes/sec
total size is 24.46M  speedup is 0.94
sbo_sync: done
```
If you want to mantain your local repository, lets say, inside `/home/sbo`,
you can create a symlink as root:

`ln -s /home/sbo /usr/ports`

and sbo_tools should just works.

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
  
