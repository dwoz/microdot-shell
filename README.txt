What is microdot?

Microdot is a shell function which wraps git to provide a simple tool to manage
dot files.

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
    $ md commit ~/.bashrc

  - Use an existing dotfiles data git repo

    $ md clone git@github.com:mygithub/mydotfiles.git
