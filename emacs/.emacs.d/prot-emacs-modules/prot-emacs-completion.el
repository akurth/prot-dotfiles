;;; General minibuffer settings
(prot-emacs-configure
  (:delay 1)

;;;; Minibuffer configurations
  (setq completion-styles '(basic substring initials flex orderless)) ; also see `completion-category-overrides'
  (setq completion-category-defaults nil)

  ;; A list of known completion categories:
  ;;
  ;; - `bookmark'
  ;; - `buffer'
  ;; - `charset'
  ;; - `coding-system'
  ;; - `color'
  ;; - `command' (e.g. `M-x')
  ;; - `customize-group'
  ;; - `environment-variable'
  ;; - `expression'
  ;; - `face'
  ;; - `file'
  ;; - `function' (the `describe-function' command bound to `C-h f')
  ;; - `info-menu'
  ;; - `imenu'
  ;; - `input-method'
  ;; - `kill-ring'
  ;; - `library'
  ;; - `minor-mode'
  ;; - `multi-category'
  ;; - `package'
  ;; - `project-file'
  ;; - `symbol' (the `describe-symbol' command bound to `C-h o')
  ;; - `theme'
  ;; - `unicode-name' (the `insert-char' command bound to `C-x 8 RET')
  ;; - `variable' (the `describe-variable' command bound to `C-h v')
  ;; - `consult-grep'
  ;; - `consult-isearch'
  ;; - `consult-kmacro'
  ;; - `consult-location'
  ;; - `embark-keybinding'
  ;;
  (setq completion-category-overrides
        ;; NOTE 2021-10-25: I am adding `basic' because it works better as a
        ;; default for some contexts.  Read:
        ;; <https://debbugs.gnu.org/cgi/bugreport.cgi?bug=50387>.
        ;;
        ;; `partial-completion' is a killer app for files, because it
        ;; can expand ~/.l/s/fo to ~/.local/share/fonts.
        ;;
        ;; If `basic' cannot match my current input, Emacs tries the
        ;; next completion style in the given order.  In other words,
        ;; `orderless' kicks in as soon as I input a space or one of its
        ;; style dispatcher characters.
        '((file (styles . (basic partial-completion orderless)))
          (bookmark (styles . (basic substring)))
          (library (styles . (basic substring)))
          (embark-keybinding (styles . (basic substring)))
          (imenu (styles . (basic substring orderless)))
          (consult-location (styles . (basic substring orderless)))
          (kill-ring (styles . (emacs22 orderless)))
          (eglot (styles . (emacs22 substring orderless)))))

  (setq completion-ignore-case t)
  (setq read-buffer-completion-ignore-case t)
  (setq read-file-name-completion-ignore-case t)
  (setq-default case-fold-search t)   ; For general regexp

  (setq enable-recursive-minibuffers t)
  (setq read-minibuffer-restore-windows nil) ; Emacs 28
  (minibuffer-depth-indicate-mode 1)

  (setq minibuffer-default-prompt-format " [%s]") ; Emacs 29
  (minibuffer-electric-default-mode 1)

  (setq resize-mini-windows t)
  (setq read-answer-short t) ; also check `use-short-answers' for Emacs28
  (setq echo-keystrokes 0.25)
  (setq kill-ring-max 60) ; Keep it small

  ;; Do not allow the cursor to move inside the minibuffer prompt.  I
  ;; got this from the documentation of Daniel Mendler's Vertico
  ;; package: <https://github.com/minad/vertico>.
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))

  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

  ;; Add prompt indicator to `completing-read-multiple'.  We display
  ;; [`completing-read-multiple': <separator>], e.g.,
  ;; [`completing-read-multiple': ,] if the separator is a comma.  This
  ;; is adapted from the README of the `vertico' package by Daniel
  ;; Mendler.  I made some small tweaks to propertize the segments of
  ;; the prompt.
  (defun crm-indicator (args)
    (cons (format "[`completing-read-multiple': %s]  %s"
                  (propertize
                   (replace-regexp-in-string
                    "\\`\\[.*?]\\*\\|\\[.*?]\\*\\'" ""
                    crm-separator)
                   'face 'error)
                  (car args))
          (cdr args)))

  (advice-add #'completing-read-multiple :filter-args #'crm-indicator)

  (file-name-shadow-mode 1)

  (setq completions-format 'one-column)
  (setq completion-show-help nil)
  (setq completion-auto-help 'always)
  (setq completion-auto-select nil)
  (setq completions-detailed t)
  (setq completion-show-inline-help nil)
  (setq completions-max-height 6)
  (setq completions-header-format (propertize "%s candidates:\n" 'face 'bold-italic))
  (setq completions-highlight-face 'completions-highlight)
  (setq minibuffer-completion-auto-choose t)
  (setq minibuffer-visible-completions t) ; Emacs 30
  (setq completions-sort 'historical)

  (unless prot-emacs-completion-ui
    (prot-emacs-keybind minibuffer-local-completion-map
      "<up>" #'minibuffer-previous-line-completion
      "<down>" #'minibuffer-next-line-completion)

    (add-hook 'completion-list-mode-hook #'prot-common-truncate-lines-silently))

;;;; `savehist' (minibuffer and related histories)
  (setq savehist-file (locate-user-emacs-file "savehist"))
  (setq history-length 100)
  (setq history-delete-duplicates t)
  (setq savehist-save-minibuffer-history t)
  (setq savehist-additional-variables '(register-alist kill-ring))
  (savehist-mode 1)

;;;; `dabbrev' (dynamic word completion (dynamic abbreviations))
  (setq dabbrev-abbrev-char-regexp "\\sw\\|\\s_")
  (setq dabbrev-abbrev-skip-leading-regexp "[$*/=~']")
  (setq dabbrev-backward-only nil)
  (setq dabbrev-case-distinction 'case-replace)
  (setq dabbrev-case-fold-search nil)
  (setq dabbrev-case-replace 'case-replace)
  (setq dabbrev-check-other-buffers t)
  (setq dabbrev-eliminate-newlines t)
  (setq dabbrev-upcase-means-case-search t)
  (setq dabbrev-ignored-buffer-modes
        '(archive-mode image-mode docview-mode pdf-view-mode))

;;;; `abbrev' (Abbreviations, else Abbrevs)
  (setq only-global-abbrevs nil)

  (prot-emacs-abbrev global-abbrev-table
    "meweb"   "https://protesilaos.com"
    "megit"   "https://github.com/protesilaos"
    "mehub"   "https://github.com/protesilaos"
    "meclone" "git@github.com/protesilaos/"
    "melab"   "https://gitlab.com/protesilaos"
    "medrive" "hyper://5cr7mxac8o8aymun698736tayrh1h4kbqf359cfk57swjke716gy/"
    ";web"   "https://protesilaos.com"
    ";git"   "https://github.com/protesilaos"
    ";hub"   "https://github.com/protesilaos"
    ";clone" "git@github.com/protesilaos/"
    ";lab"   "https://gitlab.com/protesilaos"
    ";drive" "hyper://5cr7mxac8o8aymun698736tayrh1h4kbqf359cfk57swjke716gy/")

  (prot-emacs-abbrev text-mode-abbrev-table
    "asciidoc"       "AsciiDoc"
    "auctex"         "AUCTeX"
    "cafe"           "café"
    "cliche"         "cliché"
    "clojurescript"  "ClojureScript"
    "emacsconf"      "EmacsConf"
    "github"         "GitHub"
    "gitlab"         "GitLab"
    "javascript"     "JavaScript"
    "latex"          "LaTeX"
    "libreplanet"    "LibrePlanet"
    "linkedin"       "LinkedIn"
    "paypal"         "PayPal"
    "sourcehut"      "SourceHut"
    "texmacs"        "TeXmacs"
    "typescript"     "TypeScript"
    "visavis"        "vis-à-vis"
    "youtube"        "YouTube"
    ";up"            "🙃"
    ";uni"           "🦄"
    ";laugh"         "🤣"
    ";smile"         "😀"
    ";sun"           "☀️")

  ;; Allow abbrevs with a prefix colon, semicolon, or underscore.  I demonstrated
  ;; this here: <https://protesilaos.com/codelog/2024-02-03-emacs-abbrev-mode/>.
  (abbrev-table-put global-abbrev-table :regexp "\\(?:^\\|[\t\s]+\\)\\(?1:[:;_].*\\|.*\\)")
  (abbrev-table-put text-mode-abbrev-table :regexp "\\(?:^\\|[\t\s]+\\)\\(?1:[:;_].*\\|.*\\)")

  (with-eval-after-load 'message
    (prot-emacs-abbrev message-mode-abbrev-table
      "bestregards"  "Best regards,\nProtesilaos (or simply \"Prot\")"
      "allthebest"   "All the best,\nProtesilaos (or simply \"Prot\")"
      "niceday"      "Have a nice day,\nProtesilaos (or simply \"Prot\")"
      "abest"        "All the best,\nProt"
      "bregards"     "Best regards,\nProt"
      "nday"         "Have a nice day,\nProt"
      "nosrht"       "P.S. I am phasing out SourceHut: <https://protesilaos.com/codelog/2024-01-27-sourcehut-no-more/>.
Development continues on GitHub with GitLab as a mirror."))

  ;; Unlike the above, the `prot-emacs-abbrev-function' macro does not
  ;; expand a static text, but calls a function which dynamically
  ;; expands into the requisite form.
  (require 'prot-abbrev)
  (prot-emacs-abbrev-function global-abbrev-table
    "metime" #'prot-abbrev-current-time
    "medate" #'prot-abbrev-current-date
    "mejitsi" #'prot-abbrev-jitsi-link
    ";time" #'prot-abbrev-current-time
    ";date" #'prot-abbrev-current-date
    ";jitsi" #'prot-abbrev-jitsi-link)

  (prot-emacs-abbrev-function text-mode-abbrev-table
    ";update" #'prot-abbrev-update-html)

  ;; message-mode derives from text-mode, so we don't need a separate
  ;; hook for it.
  (dolist (hook '(text-mode-hook prog-mode-hook git-commit-mode-hook))
    (add-hook hook #'abbrev-mode))

  ;; Because the *scratch* buffer is produced before we load this, we
  ;; have to explicitly activate the mode there.
  (when-let ((scratch (get-buffer "*scratch*")))
    (with-current-buffer scratch
      (abbrev-mode 1)))

  ;; By default, abbrev asks for confirmation on whether to use
  ;; `abbrev-file-name' to save abbrevations.  I do not need that, nor
  ;; do I want it.
  (remove-hook 'save-some-buffers-functions #'abbrev--possibly-save))

;;; Orderless completion style (and prot-orderless.el)
(prot-emacs-package orderless
  (:install t)
  (:delay 5)
  ;; Remember to check my `completion-styles' and the
  ;; `completion-category-overrides'.
  (setq orderless-matching-styles
        '(orderless-prefixes orderless-regexp))

  ;; SPC should never complete: use it for `orderless' groups.
  ;; The `?' is a regexp construct.
  (prot-emacs-keybind minibuffer-local-completion-map
    "SPC" nil
    "?" nil))

(prot-emacs-package prot-orderless
  (setq orderless-style-dispatchers
        '(prot-orderless-literal
          prot-orderless-file-ext
          prot-orderless-beg-or-end)))

;;; Corfu (in-buffer completion popup)
(prot-emacs-package corfu
  (:install t)
  (:delay 5)
  (setq corfu-min-width 20)

  (global-corfu-mode 1)

  (setq corfu-popupinfo-delay '(1.25 . 0.5))
  (corfu-popupinfo-mode 1) ; shows documentation after `corfu-popupinfo-delay'

  ;; I also have (setq tab-always-indent 'complete) for TAB to complete
  ;; when it does not need to perform an indentation change.
  (define-key corfu-map (kbd "<tab>") #'corfu-complete)

  ;; Sort by input history (no need to modify `corfu-sort-function').
  (with-eval-after-load 'savehist
    (corfu-history-mode 1)
    (add-to-list 'savehist-additional-variables 'corfu-history)))

;;; Enhanced minibuffer commands (consult.el)
(when prot-emacs-completion-extras
  (prot-emacs-package consult
    (:install t)
    (:delay 5)
    (setq consult-line-numbers-widen t)
    ;; (setq completion-in-region-function #'consult-completion-in-region)
    (setq consult-async-min-input 3)
    (setq consult-async-input-debounce 0.5)
    (setq consult-async-input-throttle 0.8)
    (setq consult-narrow-key nil)
    (setq consult-find-args
          (concat "find . -not ( "
                  "-path */.git* -prune "
                  "-or -path */.cache* -prune )"))
    (setq consult-preview-key 'any)

    (add-to-list 'consult-mode-histories '(vc-git-log-edit-mode . log-edit-comment-ring))

    (add-hook 'completion-list-mode-hook #'consult-preview-at-point-mode)

    (require 'consult-imenu) ; the `imenu' extension is in its own file

    (prot-emacs-keybind global-map
      "M-g M-g" #'consult-goto-line
      "M-K" #'consult-keep-lines ; M-S-k is similar to M-S-5 (M-%)
      "M-F" #'consult-focus-lines ; same principle
      "M-s M-b" #'consult-buffer
      "M-s M-f" #'consult-find
      "M-s M-g" #'consult-grep
      "M-s M-h" #'consult-history
      "M-s M-i" #'consult-imenu
      "M-s M-l" #'consult-line
      "M-s M-m" #'consult-mark
      "M-s M-y" #'consult-yank-pop
      "M-s M-s" #'consult-outline)
    (define-key consult-narrow-map (kbd "?") #'consult-narrow-help)
    (define-key minibuffer-local-map (kbd "C-s") #'consult-history)

    (with-eval-after-load 'pulsar
      ;; see my `pulsar' package: <https://protesilaos.com/emacs/pulsar>
      (setq consult-after-jump-hook nil) ; reset it to avoid conflicts with my function
      (dolist (fn '(pulsar-recenter-top pulsar-reveal-entry))
        (add-hook 'consult-after-jump-hook fn)))))

;;; Extended minibuffer actions and more (embark.el and prot-embark.el)
(when prot-emacs-completion-extras
  (prot-emacs-package embark
    (:install t)
    (:delay 5)
    (setq embark-confirm-act-all nil)
    ;; The prot-embark.el has an advice to further simplify the
    ;; minimal indicator.  It shows cycling, which I never want to see
    ;; or do.
    (setq embark-mixed-indicator-both nil)
    (setq embark-mixed-indicator-delay 1.0)
    (setq embark-indicators '(embark-mixed-indicator embark-highlight-indicator))
    (setq embark-verbose-indicator-nested nil) ; I think I don't have them, but I do not want them either
    (setq embark-verbose-indicator-buffer-sections '(bindings))
    (setq embark-verbose-indicator-excluded-actions
          '(embark-cycle embark-act-all embark-collect embark-export embark-insert))

    ;; I never cycle and want to disable the damn thing.  Normally, a
    ;; nil value disables a key binding but here that value is
    ;; interpreted as the binding for `embark-act'.  So I just add
    ;; some obscure key that I do not have.  I absolutely do not want
    ;; to cycle!
    (setq embark-cycle-key "<XF86Travel>")

    ;; I do not want `embark-org' and am not sure what is loading it.
    ;; So I just unsert all the keymaps... This is the nuclear option
    ;; but here we are.
    (with-eval-after-load 'embark-org
      (defvar prot/embark-org-keymaps
        '(embark-org-table-cell-map
          embark-org-table-map
          embark-org-link-copy-map
          embark-org-link-map
          embark-org-src-block-map
          embark-org-item-map
          embark-org-plain-list-map
          embark-org-export-in-place-map)
        "List of Embark keymaps for Org.")

      ;; Reset `prot/embark-org-keymaps'.
      (seq-do
       (lambda (keymap)
         (set keymap (make-sparse-keymap)))
       prot/embark-org-keymaps)))

  ;; I define my own keymaps because I only use a few functions in a
  ;; limited number of contexts.
  (prot-emacs-package prot-embark
    (:delay 5)
    (setq embark-keymap-alist
          '((buffer prot-embark-buffer-map)
            (command prot-embark-command-map)
            (expression prot-embark-expression-map)
            (file prot-embark-file-map)
            (function prot-embark-function-map)
            (identifier prot-embark-identifier-map)
            (package prot-embark-package-map)
            (region prot-embark-region-map)
            (symbol prot-embark-symbol-map)
            (url prot-embark-url-map)
            (variable prot-embark-variable-map)
            (t embark-general-map)))

    (mapc
     (lambda (map)
       (define-key map (kbd "C-,") #'prot-embark-act-no-quit)
       (define-key map (kbd "C-.") #'prot-embark-act-quit))
     (list global-map embark-collect-mode-map minibuffer-local-filename-completion-map))))

;; Needed for correct exporting while using Embark with Consult
;; commands.
(prot-emacs-package embark-consult (:install t) (:delay 5))

;;; Detailed completion annotations (marginalia.el)
(prot-emacs-package marginalia
  (:install t)
  (:delay 5)
  (setq marginalia-max-relative-age 0) ; absolute time
  (marginalia-mode 1))

;;;; Custom completion annotations
(prot-emacs-package prot-marginalia
  (:delay 5)
  (setq marginalia-annotator-registry
        '((bookmark prot-marginalia-bookmark)
          (buffer prot-marginalia-buffer)
          (command marginalia-annotate-command)
          (function prot-marginalia-symbol)
          (symbol prot-marginalia-symbol)
          (variable prot-marginalia-symbol)
          (face marginalia-annotate-face)
          (imenu marginalia-annotate-imenu)
          (package prot-marginalia-package)
          (unicode-name marginalia-annotate-char))))

;;; The minibuffer user interface (mct, vertico, or none)
(when prot-emacs-completion-ui
  (require
   (pcase prot-emacs-completion-ui
     ('mct 'prot-emacs-mct)
     ('vertico 'prot-emacs-vertico))))

(provide 'prot-emacs-completion)
