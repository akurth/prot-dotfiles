;;; Minibuffer and Completions in Tandem or Minibuffer Confines Transcended
;; Read the manual: <https://protesilaos.com/emacs/mct>.
(prot-emacs-package mct
  (:install t)
  (:delay 1)
  (setq mct-hide-completion-mode-line t)
  ;; The blocklist and passlist accept either commands/functions or
  ;; completion categories.
  (setq mct-completion-blocklist '(notmuch-mua-new-mail notmuch-mua-prompt-for-sender))
  (setq mct-completion-passlist
        '( consult-buffer consult-location embark-keybinding
           imenu prot-search-outline select-frame-by-name))
  (setq mct-remove-shadowed-file-names t)
  (setq mct-completion-window-size (cons #'mct-frame-height-third 1))
  (setq mct-persist-dynamic-completion nil)
  (setq mct-live-completion 'visible)
  (setq completions-sort #'mct-sort-multi-category)

  (mct-mode 1))

(provide 'prot-emacs-mct)
