;;; Pulsar
;; Read the pulsar manual: <https://protesilaos.com/emacs/pulsar>.
(prot-emacs-package pulsar
  (:install t)
  (:delay 5)
  (dolist (cmd '( narrow-to-page narrow-to-defun
                  narrow-to-region widen
                  logos-forward-page-dwim
                  logos-backward-page-dwim))
    (add-to-list 'pulsar-pulse-functions cmd))

  (setopt pulsar-pulse t
          pulsar-delay 0.055
          pulsar-iterations 10
          pulsar-face 'pulsar-blue
          pulsar-highlight-face 'pulsar-yellow)

  (pulsar-global-mode 1)

  ;; There are convenience functions/commands which pulse the line using
  ;; a specific colour: `pulsar-pulse-line-red' is one of them.
  (add-hook 'next-error-hook #'pulsar-pulse-line-red)

  (add-hook 'minibuffer-setup-hook #'pulsar-pulse-line-red)

  ;; pulsar does not define any key bindings.  This is just my personal
  ;; preference.  Remember to read the manual on the matter.  Evaluate:
  ;;
  ;; (info "(elisp) Key Binding Conventions")
  (prot-emacs-keybind global-map
    "C-x l" pulsar-pulse-line ; override `count-lines-page'
    "C-x L" pulsar-highlight-dwim)) ; or use `pulsar-highlight-line'

;;; Lin
;; Read the lin manual: <https://protesilaos.com/emacs/lin>.
(prot-emacs-package lin
  (:install t)
  (:delay 5)
  ;; You can use this to live update the face:
  ;;
  ;; (customize-set-variable 'lin-face 'lin-green)
  ;;
  ;; Or `setopt' on Emacs 29: (setopt lin-face 'lin-yellow)
  ;;
  ;; I still prefer `setq' for consistency.
  (setq lin-face
        (if (eq prot-emacs-load-theme-family 'modus)
            'lin-cyan
          'hl-line))

  (setq lin-mode-hooks
        '(bongo-mode-hook
          dired-mode-hook
          elfeed-search-mode-hook
          git-rebase-mode-hook
          ibuffer-mode-hook
          ilist-mode-hook
          ledger-report-mode-hook
          log-view-mode-hook
          magit-log-mode-hook
          mu4e-headers-mode
          notmuch-search-mode-hook
          notmuch-tree-mode-hook
          occur-mode-hook
          org-agenda-mode-hook
          tabulated-list-mode-hook
          vc-dir-mode-hook))

  (lin-global-mode 1)) ; applies to all `lin-mode-hooks'

;;; Rainbow mode for colour previewing (rainbow-mode.el)
(prot-emacs-package rainbow-mode
  (:install t)
  (:delay 10)
  (setq rainbow-ansi-colors nil)
  (setq rainbow-x-colors nil)

  (defun prot/rainbow-mode-in-themes ()
    (when-let* ((file (buffer-file-name))
                ((derived-mode-p 'emacs-lisp-mode))
                ((string-match-p "-theme" file)))
      (rainbow-mode 1)))

  (add-hook 'emacs-lisp-mode-hook #'prot/rainbow-mode-in-themes)

  (define-key ctl-x-x-map "c" #'rainbow-mode)) ; C-x x c

;;; Cursor appearance (cursory)
;; Read the manual: <https://protesilaos.com/emacs/cursory>.
(prot-emacs-package cursory
  (:install t)
  (:delay 5)
  (setq cursory-presets
        '((box
           :blink-cursor-interval 0.8)
          (box-no-blink
           :blink-cursor-mode -1)
          (bar
           :cursor-type (bar . 2)
           :blink-cursor-interval 0.5)
          (bar-no-other-window
           :inherit bar
           :cursor-in-non-selected-windows nil)
          (underscore
           :cursor-type (hbar . 3)
           :blink-cursor-blinks 50)
          (underscore-thin-other-window
           :inherit underscore
           :cursor-in-non-selected-windows (hbar . 1))
          (underscore-thick
           :cursor-type (hbar . 8)
           :blink-cursor-interval 0.3
           :blink-cursor-blinks 50
           :cursor-in-non-selected-windows (hbar . 3))
          (t ; the default values
           :cursor-type box
           :cursor-in-non-selected-windows hollow
           :blink-cursor-mode 1
           :blink-cursor-blinks 10
           :blink-cursor-interval 0.2
           :blink-cursor-delay 0.2)))

  ;; I am using the default values of `cursory-latest-state-file'.

  ;; Set last preset or fall back to desired style from `cursory-presets'.
  (cursory-set-preset (or (cursory-restore-latest-preset) 'bar))

  ;; The other side of `cursory-restore-latest-preset'.
  (add-hook 'kill-emacs-hook #'cursory-store-latest-preset)

  ;; We have to use the "point" mnemonic, because C-c c is often the
  ;; suggested binding for `org-capture' and is the one I use as well.
  (define-key global-map (kbd "C-c p") #'cursory-set-preset))

(provide 'prot-emacs-theme-extras)
