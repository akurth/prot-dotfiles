;;; Vertical completion layout
(prot-emacs-package vertico
  (:install t)
  (:delay 5)
  ;; Those are the default values, but check the user option
  ;; `vertico-multiform-categories' for per-category tweaks.
  (setq vertico-scroll-margin 0)
  (setq vertico-count 10)
  (setq vertico-resize nil)
  (setq vertico-cycle t)

  (vertico-mode 1)

  (prot-emacs-keybind vertico-map
    "M-," #'vertico-quick-insert
    "M-." #'vertico-quick-exit)

  ;; This works with `file-name-shadow-mode'.  When you are in a
  ;; sub-directory and use, say, `find-file' to go to your home '~/' or
  ;; root '/' directory, Vertico will clear the old path to keep only
  ;; your current input.
  (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy))

;;; Detailed completion annotations (marginalia.el)
(prot-emacs-package marginalia
  (:install t)
  (:delay 5)
  (setq marginalia-max-relative-age 0) ; absolute time
  (marginalia-mode 1))

(provide 'prot-emacs-completion-vertico)
