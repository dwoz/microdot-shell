What is microdot?

Microdot is a shell function which wraps git to provide a simple tool for
managing your 'dot files'.

The microdot function is a thin wrapper around git in the form of a bash
function. The purpose is to provide dot file history, backup and syncinc to
multiple places. Git already does a great job of stroing history, backing
things up and syncing changes to multiple places. So microdot leverages the
power of git. The mocrodot function provides a simplified workflow to managing
a set of files in your home directory under git without turning your entire
home directory into a git repository.


How to I use it?

  - Download or checkout this repository to obtain microdot.sh

  - Source microdot.sh in your .bashrc and alias the microdot function.

    Add the following to ~/.bashrc:

    source microdot.sh
    alias md='microdot'

  - Source your .bashrc to make the md command available

    $ source ~/.bashrc

  - Initialize a new dotfiles data git repo

    $ md init
    $ md remote add origin git@github.com:mygithub/mydotfiles.git
    $ md commit ~/.bashrc -m 'Adding my .bashrc file'
    $ md push origin master

  - Use an existing dotfiles data git repo

    $ md clone git@github.com:mygithub/mydotfiles.git
