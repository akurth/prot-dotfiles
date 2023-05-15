# My Emacs and other configurations for Arch Linux

This is the set of files that powers my day-to-day computing experience.
GNU Emacs is its centrepiece, with other programs providing ancillary
functionalities.  In some cases, such as with the configurations for
Vim, all relevant files are carried over from my pre-Emacs days and are
maintained as a contingency plan or in case I need to revisit some old
setup.

## Do not track my dotfiles (rolling, unstable, and untested)

_Ceci n'est pas une distribution Emacs._

This repo functions as a laboratory of experimentation for my computing
environment.  What I do with Emacs or any other program in the GNU/Linux
milieu that forms part of my dotfiles is only meant to work for me.  As
such, I offer no support whatsoever to those tracking this repository
and may introduce breaking changes without prior notice.

This is all to say that **you understand the risks associated with
tracking an ever-changing project that does not enjoy widespread testing
and whose target audience is only me**.  If you are fine with that and
are willing to assume responsibility for any possible breakage, then
please feel welcome to follow along.  You can always open an issue here
or contribute any fixes, if you will.

## Emacs setup

I do not recommend you reproduce my Emacs setup because I do not use
the de facto standard of `use-package` to configure packages.  I
prefer a simpler approach.

If you insist though, the files are in the `emacs` directory.  Add them
to your home directory with:

```sh
/path/to/prot-dotfiles $ stow -t "$HOME" emacs
```

This will create symlinks to my configuration files inside the
`~/.emacs.d` directory.  My custom libraries are in the directory
`prot-lisp` while the configuration modules (where we tweak variables,
assign key bindings, etc.) are in the directory `prot-emacs-modules`.

The modules are loaded from the `init.el`.  Each module defines the
packages to install/load.  **My setup auto-installs packages**.  This
will happen the first time you start up Emacs.  If a package is not
found in the archives it likely means that you need to refresh the
package listing: `M-x package-refresh-contents`.  This is done
automatically at startup, if necessary, but is needed for any new
packages you may define.  Then retry installing the package.

There are two files that you can use to personalise your setup: (i)
`prot-emacs-pre-custom.el` and (ii) `prot-emacs-post-custom.el`.

Both files must be in the same directory as the `init.el` and
`early-init.el`.  This typically is the `~/.emacs.d/` directory.

These files serve two different purposes.

1. The `prot-emacs-pre-custom.el` is useful if you want to do
   something BEFORE loading my configurations.  For example, you may
   want to exclude some of my packages from your setup.  So you can
   add something like this:

   ```elisp
   ;; This goes in the file prot-emacs-pre-custom.el
   (setq prot-emacs-omit-packages
         ;; Names of packages here
         '( citar citar-denote citar-embark
            clojure-mode cider
            flymake-kondor flymake-shellcheck flymake-proselint))
   ```

2. The `prot-emacs-post-custom.el` is loaded AFTER all my
   customisations.  You can use this to add additional packages or
   make further changes to existing ones.

If you make changes to the dotfiles, such as by moving things around,
run stow again with the `-R` flag:

```sh
/path/to/prot-dotfiles $ stow -t "$HOME" -R emacs
```

## Window managers

I used to have configurations for bspwm, herbstluftwm, and swaywm.
Since 2023-02-24 I have removed sway: Wayland is not ready for my
purposes and I have had no issues whatsoever with Xorg.  I also tried
GNOME for a while to get a feel for Wayaland and see how Emacs
compiled `--with-pgtk` performs.  In short: Emacs is the same and
Wayland is not as featureful as Xorg.

+ **bspwm:** I have been using it for years and consider it top-notch.
  It is stable and scriptable.  Use this if you prefer automatic
  tiling.

+ **herbstluftwm (hlwm):** Shares some concepts with bspwm and can
  actually be configured in the same way.  The main differences
  between the two are that (i) hlwm prioritises manual tiling methods
  and (ii) can treat arbitrary rectangles of a monitor as virtual
  monitors.  The virtual monitors feature is perfect for anyone with a
  widescreen display.  The one I have (which is not mine, but anyway)
  is 2560x1920, so I split it by default into a regular 1920x1080 area
  and another "sidebar" of 640x1080.

Both of my tiling window managers have a shared basis in the
`xorg-twm` stow package ("twm" stands for "tiling window manager").
They both use the Simple X Hot Key Daemon (sxhkd) to set key bindings
and have practically the same `polybar` panel.  Furthermore, both are
subject to the theme-switching of my `delight` script.  In other
words, I can use them interchangeably.

Check the `xtwm-key-binding-cheatsheet.md` file for an overview of
their key bindings.

## Copying

Unless otherwise noted, all code herein is distributed under the terms
of the GNU General Public License Version 3 or later.
