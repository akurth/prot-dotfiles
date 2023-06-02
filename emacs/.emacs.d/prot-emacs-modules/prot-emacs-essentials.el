;;; Essential configurations
(prot-emacs-configure
  (:delay 5)

  ;; NOTE 2023-05-20: Normally those would not have to be `require'd
  ;; as every point of entry is autoloaded.  But Emacs does not have
  ;; an autoloads file for them, as they are not installed the usual
  ;; way.
  (require 'prot-common)
  (require 'prot-simple)
  (require 'prot-prefix)

;;; General settings and common custom functions (prot-simple.el)
  (setq delete-pair-blink-delay 0.15) ; Emacs28 -- see `prot-simple-delete-pair-dwim'
  (setq help-window-select t)
  (setq next-error-recenter '(4)) ; center of the window
  (setq find-library-include-other-files nil) ; Emacs 29
  (setq remote-file-name-inhibit-delete-by-moving-to-trash t) ; Emacs 30
  (setq remote-file-name-inhibit-auto-save t)                 ; Emacs 30
  (setq save-interprogram-paste-before-kill t)
  (setq mode-require-final-newline 'visit-save)

  (setq prot-simple-insert-pair-alist
      '(("' Single quote"        . (39 39))     ; ' '
        ("\" Double quotes"      . (34 34))     ; " "
        ("` Elisp quote"         . (96 39))     ; ` '
        ("‘ Single apostrophe"   . (8216 8217)) ; ‘ ’
        ("“ Double apostrophes"  . (8220 8221)) ; “ ”
        ("( Parentheses"         . (40 41))     ; ( )
        ("{ Curly brackets"      . (123 125))   ; { }
        ("[ Square brackets"     . (91 93))     ; [ ]
        ("< Angled brackets"     . (60 62))     ; < >
        ("« Εισαγωγικά Gr quote" . (171 187))   ; « »
        ("= Equals signs"        . (61 61))     ; = =
        ("~ Tilde"               . (126 126))   ; ~ ~
        ("* Asterisks"           . (42 42))     ; * *
        ("/ Forward Slash"       . (47 47))     ; / /
        ("_ underscores"         . (95 95))))    ; _ _
  (setq prot-simple-date-specifier "%F")
  (setq prot-simple-time-specifier "%R %z")
  (setq prot-simple-scratch-buffer-default-mode 'text-mode)

  ;; General commands
  (prot-emacs-keybind global-map
    "<insert>" nil
    "C-x C-z" nil
    "C-x C-c" nil ; avoid accidentally exiting Emacs
    "C-x C-c C-c" #'save-buffers-kill-emacs
    "C-h h" nil
    "M-`" nil
    "C-g" #'prot-simple-keyboard-quit-dwim
    "C-h ." #'prot-simple-describe-symbol ; overrides `display-local-help'
    "C-h K" #'describe-keymap ; overrides `Info-goto-emacs-key-command-node'
    "C-h c" #'describe-char ; overrides `describe-key-briefly'
    "C-c s" #'prot-simple-scratch-buffer
    ;; Commands for lines
    "M-o" #'delete-blank-lines   ; alias for C-x C-o
    "M-k" #'prot-simple-kill-line-backward
    "C-S-w" #'prot-simple-copy-line-or-region
    "C-S-y" #'prot-simple-yank-replace-line-or-region
    "M-SPC" #'cycle-spacing
    "C-S-n" #'prot-simple-multi-line-next
    "C-S-p" #'prot-simple-multi-line-prev
    "<C-return>" #'prot-simple-new-line-below
    "<C-S-return>" #'prot-simple-new-line-above
    ;; Commands for text insertion or manipulation
    "C-=" #'prot-simple-insert-date
    "C-<" #'prot-simple-escape-url-dwim
    "C-'" #'prot-simple-insert-pair
    "M-'" #'prot-simple-insert-pair
    "M-\\" #'prot-simple-delete-pair-dwim
    "M-z" #'zap-up-to-char ; NOT `zap-to-char'
    "M-Z" #'prot-simple-zap-to-char-backward
    "<C-M-backspace>" #'backward-kill-sexp
    "M-c" #'capitalize-dwim
    "M-l" #'downcase-dwim        ; "lower" case
    "M-u" #'upcase-dwim
    ;; Commands for object transposition
    "C-t" #'prot-simple-transpose-chars
    "C-x C-t" #'prot-simple-transpose-lines
    "C-S-t" #'prot-simple-transpose-paragraphs
    "C-x M-t" #'prot-simple-transpose-sentences
    "C-M-t" #'prot-simple-transpose-sexps
    "M-t" #'prot-simple-transpose-words
    ;; Commands for marking objects
    "M-@" #'prot-simple-mark-word       ; replaces `mark-word'
    "C-M-SPC" #'prot-simple-mark-construct-dwim
    "C-M-d" #'prot-simple-downward-list
    ;; Commands for paragraphs
    "M-Q" #'prot-simple-unfill-region-or-paragraph
    ;; Commands for windows and pages
    "C-x n k" #'prot-simple-delete-page-delimiters
    "C-x M-r" #'prot-simple-swap-window-buffers
    ;; Commands for buffers
    "M-=" #'count-words
    "<C-f2>" #'prot-simple-rename-file-and-buffer
    "C-x k" #'prot-simple-kill-buffer-current
    "C-x K" #'kill-buffer
    "M-s b" #'prot-simple-buffers-major-mode
    "M-s v" #'prot-simple-buffers-vc-root
    ;; Prefix keymap (prot-prefix.el)
    "C-z" #'prot-prefix)

  ;; Keymap for buffers (Emacs28)
  (prot-emacs-keybind ctl-x-x-map
    "f" #'follow-mode  ; override `font-lock-update'
    "r" #'rename-uniquely
    "l" #'visual-line-mode)

;;;; Mouse wheel behaviour
  ;; In Emacs 27+, use Control + mouse wheel to scale text.
  (setq mouse-wheel-scroll-amount
        '(1
          ((shift) . 5)
          ((meta) . 0.5)
          ((control) . text-scale))
        mouse-drag-copy-region nil
        make-pointer-invisible t
        mouse-wheel-progressive-speed t
        mouse-wheel-follow-mouse t)

  ;; Scrolling behaviour
  (setq-default scroll-preserve-screen-position t
                scroll-conservatively 1 ; affects `scroll-step'
                scroll-margin 0
                next-screen-context-lines 0)

  (mouse-wheel-mode 1)
  (define-key global-map (kbd "C-M-<mouse-3>") #'tear-off-window)

;;; Repeatable key chords (repeat-mode)
  (setq repeat-on-final-keystroke t
        repeat-exit-timeout 5
        repeat-exit-key "<escape>"
        repeat-keep-prefix nil
        repeat-check-key t
        repeat-echo-function 'ignore
        ;; Technically, this is not in repeal.el, though it is the
        ;; same idea.
        set-mark-command-repeat-pop t)
  (repeat-mode 1)

;;;; Built-in bookmarking framework (bookmark.el)
  (setq bookmark-use-annotations nil)
  (setq bookmark-automatically-show-annotations t)
  (setq bookmark-fringe-mark nil) ; Emacs 29 to hide bookmark fringe icon

  (add-hook 'bookmark-bmenu-mode-hook #'hl-line-mode)

  (defun prot/bookmark-save-no-prompt (&rest _)
    "Run `bookmark-save' without prompts.

The intent of this function is to be added as an :after advice to
`bookmark-set-internal'.  Concretely, this means that when
`bookmark-set-internal' is called, this function is called right
afterwards.  We set this up because there is no hook after
setting a bookmark and we want to automatically save bookmarks at
that point."
    (funcall 'bookmark-save))

  (advice-add 'bookmark-set-internal :after 'prot/bookmark-save-no-prompt)

;;;; Auto revert mode
  (setq auto-revert-verbose t)
  (global-auto-revert-mode 1)

;;;; Delete selection
  (delete-selection-mode 1)

;;;; Tooltips (tooltip-mode)
  (setq tooltip-delay 0.5
        tooltip-short-delay 0.5
        x-gtk-use-system-tooltips nil
        tooltip-frame-parameters
        '((name . "tooltip")
          (internal-border-width . 6)
          (border-width . 0)
          (no-special-glyphs . t)))

  (autoload #'tooltip-mode "tooltip")
  (tooltip-mode 1)

;;;; Display current time
  (setq display-time-format "%a %e %b, %H:%M ")
  ;;;; Covered by `display-time-format'
  ;; (setq display-time-24hr-format t)
  ;; (setq display-time-day-and-date t)
  (setq display-time-interval 60)
  (setq display-time-default-load-average nil)
  ;; NOTE 2022-09-21: For all those, I have implemented my own solution
  ;; that also shows the number of new items, although it depends on
  ;; notmuch: the `notmuch-indicator' package.
  (setq display-time-mail-directory nil)
  (setq display-time-mail-function nil)
  (setq display-time-use-mail-icon nil)
  (setq display-time-mail-string nil)
  (setq display-time-mail-face nil)

;;;;; World clock (M-x world-clock)
  (setq display-time-world-list t)
  (setq zoneinfo-style-world-list ; M-x shell RET timedatectl list-timezones
        '(("America/Los_Angeles" "Los Angeles")
          ("America/Chicago" "Chicago")
          ("Brazil/Acre" "Rio Branco")
          ("America/New_York" "New York")
          ("Brazil/East" "Brasília")
          ("UTC" "UTC")
          ("Europe/Lisbon" "Lisbon")
          ("Europe/Brussels" "Brussels")
          ("Europe/Athens" "Athens")
          ("Asia/Tehran" "Tehran")
          ("Asia/Tbilisi" "Tbilisi")
          ("Asia/Yekaterinburg" "Yekaterinburg")
          ("Asia/Shanghai" "Shanghai")
          ("Asia/Tokyo" "Tokyo")
          ("Asia/Vladivostok" "Vladivostok")
          ("Australia/Sydney" "Sydney")
          ("Pacific/Auckland" "Auckland")))

  ;; All of the following variables are for Emacs 28
  (setq world-clock-list t)
  (setq world-clock-time-format "%R %z  %A %d %B")
  (setq world-clock-buffer-name "*world-clock*") ; Placement handled by `display-buffer-alist'
  (setq world-clock-timer-enable t)
  (setq world-clock-timer-second 60)

  (display-time-mode 1)

;;;; `man' (manpages)
  (setq Man-notify-method 'pushy) ; does not obey `display-buffer-alist'

;;;; `proced' (process monitor, similar to `top')
  (setq proced-auto-update-flag t)
  (setq proced-enable-color-flag t) ; Emacs 29
  (setq proced-auto-update-interval 5)
  (setq proced-descend t)
  (setq proced-filter 'user)
  
;;;; Emacs server (allow emacsclient to connect to running session)
  ;; The "server" is functionally like the daemon, except it is run by
  ;; the first Emacs frame we launch.  When we close that frame, the
  ;; server is terminated.  Whereas the daemon remains active even if
  ;; all Emacs frames are closed.
  ;;
  ;; I experimented with the daemon for a while.  Emacs would crash
  ;; whenever I would encounter an error in some Lisp evaluation.
  ;; Whereas the server works just fine when I need to connect to it via
  ;; the emacsclient.
  (server-start))

;;; Substitute
;; Another package of mine... Video demo:
;; <https://protesilaos.com/codelog/2023-01-16-emacs-substitute-package-demo/>.
(prot-emacs-package substitute
  (:install t)
  (:delay 5)
  ;; Set this to non-nil to highlight all occurrences of the current
  ;; target.
  (setopt substitute-highlight t)

  ;; Set this to t if you want to always treat the letter casing
  ;; literally.  Otherwise each command accepts a `C-u' prefix
  ;; argument to do this on-demand.
  (setq substitute-fixed-letter-case nil)

  ;; Produce a message after the substitution that reports on what
  ;; happened.  It is a single line, like "Substituted `TARGET' with
  ;; `SUBSTITUTE' N times across the buffer.
  (add-hook 'substitute-post-replace-hook #'substitute-report-operation)

  ;; The mnemonic for the prefix is that M-# (or M-S-3) is close to
  ;; M-% (or M-S-5).
  (prot-emacs-keybind global-map
    "M-# s" #'substitute-target-below-point ; Forward motion like isearch (C-s)
    "M-# r" #'substitute-target-above-point ; Backward motion like isearch (C-r)
    "M-# d" #'substitute-target-in-defun    ; "defun" mnemonic
    "M-# b" #'substitute-target-in-buffer)) ; "buffer" mnemonic

;;; Go to last change
(prot-emacs-package goto-last-change
  (:install t)
  (:delay 5)
  (with-eval-after-load 'prot-prefix
    (define-key prot-prefix-repeat-map (kbd "z") #'goto-last-change)
    (put #'goto-last-change 'repeat-map 'prot-prefix-repeat-map)
    (transient-append-suffix 'prot-prefix '(0 -1 -1)
      '("z" "goto-last-change" goto-last-change))))

;;; TMR May Ring (tmr is used to set timers)
;; Read the manual: <https://protesilaos.com/emacs/tmr>.
(prot-emacs-package tmr
  (:install t)
  (:delay 15)
  (setq tmr-sound-file "/usr/share/sounds/freedesktop/stereo/alarm-clock-elapsed.oga"
        tmr-notification-urgency 'normal
        tmr-description-list 'tmr-description-history)

  (prot-emacs-keybind global-map
    "C-c t t" #'tmr
    "C-c t T" #'tmr-with-description
    "C-c t l" #'tmr-tabulated-view ; "list timers" mnemonic
    "C-c t c" #'tmr-clone
    "C-c t k" #'tmr-cancel
    "C-c t s" #'tmr-reschedule
    "C-c t e" #'tmr-edit-description
    "C-c t r" #'tmr-remove
    "C-c t R" #'tmr-remove-finished))

;;; Pass interface (password-store)
(prot-emacs-package password-store
  (:install t)
  (:delay 15)
  (setq password-store-time-before-clipboard-restore 30)
  ;; Mnemonic is the root of the "code" word (κώδικας).  But also to add
  ;; the password to the kill-ring.  Other options are already taken.
  (define-key global-map (kbd "C-c k") #'password-store-copy))

(prot-emacs-package pass (:install t) (:delay 5))

;;; Shell (M-x shell)
(prot-emacs-package shell
  (:delay 15)
  (setq shell-command-prompt-show-cwd t) ; Emacs 27.1
  (setq ansi-color-for-comint-mode t)
  (setq shell-input-autoexpand 'input)
  (setq shell-highlight-undef-enable t) ; Emacs 29.1
  (setq shell-has-auto-cd nil) ; Emacs 29.1
  (setq shell-get-old-input-include-continuation-lines t) ; Emacs 30.1
  (setq shell-kill-buffer-on-exit t) ; Emacs 29.1
  (setq-default comint-scroll-to-bottom-on-input t)
  (setq-default comint-scroll-to-bottom-on-output nil)
  (setq-default comint-input-autoexpand 'input)
  (setq comint-prompt-read-only t)
  (setq comint-buffer-maximum-size 9999)
  (setq comint-completion-autolist t)

  ;; Check my .bashrc which handles `comint-terminfo-terminal':
  ;;
  ;; if [ "$TERM" = "dumb" ]
  ;; then
  ;;     export PAGER="cat"
  ;;     alias less="cat"
  ;; else
  ;;     export PAGER="less --quit-at-eof"
  ;; fi

  (define-key global-map (kbd "<f1>") #'shell) ; I don't use F1 for help commands

  (prot-emacs-keybind shell-mode-map
    "<up>" #'comint-previous-input
    "<down>" #'comint-next-input
    "C-c C-k" #'comint-clear-buffer
    "C-c C-w" #'comint-write-output))

(provide 'prot-emacs-essentials)
