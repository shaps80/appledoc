appledoc
========

I use appledoc a lot for generating my documentation but one thing that's annoyed me for a while is the installation and usage of this great utility from the command line.

I sometimes have to setup a new computer and wanted a handy script that I could just install and have it do all the heavy lifting, forcing my devs to work the same way as the rest of the team. This has been especially useful when dealing with contractors.

adgen currently supports the following features:

* Downloads, compiles and installs appledoc when required.
  * -u forces a fresh installation of appledoc, overwriting existing version
* GIT style config files are stored per directory 
* Simple text file for .adconfig allowing easy editing
  * -p prints current config
  * -r runs config again
* Auto install to Xcode
  * -x to disable
* Displays full details about each step, paths, etc...
* Colors indicate important information, warnings or errors
* If you're using GIT, auto-add (optional) GIT tracking to generated documentation and config
* Confirmation for config, you can bail if its incorrect
* Auto discovery and feedback about Xcode projects found and GIT status
* Auto backup (optional) existing documentation folder
* Auto generation of documentation, keeping intermediate files where specified in config
* Auto generate config file on first run/per directory
* Built in Help system with more information and options 'adgen -h'

Future Plans
------------

* Menu based system
* Silent auto-generation every nth second

Installation
------------

I've provided the actual script however the easiest way to install is by downloading the adgen-installer and running it. 
Once you've done that just run 'adgen' from the folder where your Xcode project files exist and the script will take of the rest.

To install manually you'll need to chmod 700 (executable) adgen.sh and copy it to /bin/local/bin/adgen
