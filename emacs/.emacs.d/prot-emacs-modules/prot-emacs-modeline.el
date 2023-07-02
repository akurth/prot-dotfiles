;;; Mode line
(prot-emacs-package prot-modeline
  (setq mode-line-compact nil) ; Emacs 28

  (setq-default mode-line-format
                '("%e"
                  prot-modeline-kbd-macro
                  " "
                  mode-line-mule-info
                  mode-line-modified
                  mode-line-remote
                  " "
                  prot-modeline-buffer-identification
                  "  "
                  prot-modeline-major-mode
                  "  "
                  prot-modeline-vc-branch
                  "  "
                  prot-modeline-flymake
                  "  "
                  prot-modeline-align-right
                  prot-modeline-misc-info)))

;;; Keycast mode
(prot-emacs-package keycast
  (:install t)
  (:delay 60)
  (setq keycast-mode-line-format "%2s%k%c%r")
  (setq keycast-mode-line-insert-after 'prot-modeline-vc-branch)
  (setq keycast-mode-line-window-predicate 'mode-line-window-selected-p)
  (setq keycast-mode-line-remove-tail-elements nil)

  (dolist (input '(self-insert-command org-self-insert-command))
    (add-to-list 'keycast-substitute-alist `(,input "." "Typing…")))

  (dolist (event '(mouse-event-p mouse-movement-p mwheel-scroll))
    (add-to-list 'keycast-substitute-alist `(,event nil)))

  (with-eval-after-load 'prot-prefix
    (transient-append-suffix 'prot-prefix-toggle '(0 1 0)
      '("k" "keycast-mode" keycast-mode))))

(provide 'prot-emacs-modeline)
