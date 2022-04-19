;;; prot-notmuch.el --- Tweaks for my notmuch.el configurations -*- lexical-binding: t -*-

;; Copyright (C) 2021-2022  Protesilaos Stavrou

;; Author: Protesilaos Stavrou <info@protesilaos.com>
;; URL: https://protesilaos.com/emacs/dotemacs
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1"))

;; This file is NOT part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; This covers my tweaks for notmuch.el that are meant for use in my
;; Emacs setup: https://protesilaos.com/emacs/dotemacs.
;;
;; Remember that every piece of Elisp that I write is for my own
;; educational and recreational purposes.  I am not a programmer and I
;; do not recommend that you copy any of this if you are not certain of
;; what it does.

;;; Code:

(require 'prot-common)
(eval-when-compile (require 'cl-lib))

(defgroup prot-notmuch ()
  "Extensions for notmuch.el."
  :group 'notmuch)

(defcustom prot-notmuch-delete-tag "del"
  "Single tag that applies to mail marked for deletion.
This is used by `prot-notmuch-delete-mail'."
  :type 'string
  :group 'prot-notmuch)

(defcustom prot-notmuch-mark-complete-tags '("+archived" "-inbox" "-list" "-todo" "-ref" "-unread")
  "List of tags to mark as completed."
  :type '(repeat string)
  :group 'prot-notmuch)

(defcustom prot-notmuch-mark-delete-tags '("+del" "-inbox" "-archived" "-unread")
  "List of tags to mark for deletion.
To actually delete email, refer to `prot-notmuch-delete-mail'."
  :type '(repeat string)
  :group 'prot-notmuch)

(defcustom prot-notmuch-mark-flag-tags '("+flag" "-unread")
  "List of tags to mark as important (flagged).
This gets the `notmuch-tag-flagged' face, if that is specified in
`notmuch-tag-formats'."
  :type '(repeat string)
  :group 'prot-notmuch)

(defcustom prot-notmuch-mark-spam-tags '("+spam" "+del" "-inbox" "-unread")
  "List of tags to mark as spam."
  :type '(repeat string)
  :group 'prot-notmuch)

(defcustom prot-notmuch-mark-todo-tags '("+todo" "-unread")
  "List of tags to mark as a to-do item."
  :type '(repeat string)
  :group 'prot-notmuch)

(defcustom prot-notmuch-mark-reference-tags '("+ref" "-unread")
  "List of tags to mark as a reference."
  :type '(repeat string)
  :group 'prot-notmuch)

;;;; Utilities

(defface prot-notmuch-encrypted-tag
  '((default :inherit italic)
    (((class color) (min-colors 88) (background light))
     :foreground "#5d3026")
    (((class color) (min-colors 88) (background dark))
     :foreground "#f8dec0"))
  "Face for the 'encrypted' tag or related in Notmuch.
Refer to the variable `notmuch-tag-formats' for how to assign
those.")

(defface prot-notmuch-sent-tag
  '((default :inherit italic)
    (((class color) (min-colors 88) (background light))
     :foreground "#005e00")
    (((class color) (min-colors 88) (background dark))
     :foreground "#44bc44"))
  "Face for the 'sent' tag or related in Notmuch.
Refer to the variable `notmuch-tag-formats' for how to assign
those.")

(defface prot-notmuch-spam-tag
  '((default :inherit italic)
    (((class color) (min-colors 88) (background light))
     :foreground "#70480f")
    (((class color) (min-colors 88) (background dark))
     :foreground "#c4d030"))
  "Face for the 'spam' tag or related in Notmuch.
Refer to the variable `notmuch-tag-formats' for how to assign
those.")

(defface prot-notmuch-ref-tag
  '((default :inherit italic)
    (((class color) (min-colors 88) (background light))
     :foreground "#005a5f")
    (((class color) (min-colors 88) (background dark))
     :foreground "#6ae4b9"))
  "Face for the 'ref' tag or related in Notmuch.
Refer to the variable `notmuch-tag-formats' for how to assign
those.")

(defface prot-notmuch-todo-tag
  '((default :inherit italic)
    (((class color) (min-colors 88) (background light))
     :foreground "#a60000")
    (((class color) (min-colors 88) (background dark))
     :foreground "#ff8059"))
  "Face for the 'todo' tag or related in Notmuch.
Refer to the variable `notmuch-tag-formats' for how to assign
those.")

;;;; Commands

(autoload 'notmuch-interactive-region "notmuch")
(autoload 'notmuch-tag-change-list "notmuch")
(autoload 'notmuch-search-next-thread "notmuch")
(autoload 'notmuch-search-tag "notmuch")

(defmacro prot-notmuch-search-tag-thread (name tags)
  "Produce NAME function parsing TAGS."
  (declare (indent defun))
  `(defun ,name (&optional untag beg end)
     ,(format
       "Mark with `%s' the currently selected thread.

Operate on each message in the currently selected thread.  With
optional BEG and END as points delimiting a region that
encompasses multiple threads, operate on all those messages
instead.

With optional prefix argument (\\[universal-argument]) as UNTAG,
reverse the application of the tags.

This function advances to the next thread when finished."
       tags)
     (interactive (cons current-prefix-arg (notmuch-interactive-region)))
     (when ,tags
       (notmuch-search-tag
        (notmuch-tag-change-list ,tags untag) beg end))
     (when (eq beg end)
       (notmuch-search-next-thread))))

(prot-notmuch-search-tag-thread
  prot-notmuch-search-complete-thread
  prot-notmuch-mark-complete-tags)

(prot-notmuch-search-tag-thread
  prot-notmuch-search-delete-thread
  prot-notmuch-mark-delete-tags)

(prot-notmuch-search-tag-thread
  prot-notmuch-search-flag-thread
  prot-notmuch-mark-flag-tags)

(prot-notmuch-search-tag-thread
  prot-notmuch-search-spam-thread
  prot-notmuch-mark-spam-tags)

(prot-notmuch-search-tag-thread
  prot-notmuch-search-todo-thread
  prot-notmuch-mark-todo-tags)

(prot-notmuch-search-tag-thread
  prot-notmuch-search-reference-thread
  prot-notmuch-mark-reference-tags)

(defmacro prot-notmuch-show-tag-message (name tags)
  "Produce NAME function parsing TAGS."
  (declare (indent defun))
  `(defun ,name (&optional untag)
     ,(format
       "Apply `%s' to message.

With optional prefix argument (\\[universal-argument]) as UNTAG,
reverse the application of the tags."
       tags)
     (interactive "P")
     (when ,tags
       (apply 'notmuch-show-tag-message
	          (notmuch-tag-change-list ,tags untag)))))

(prot-notmuch-show-tag-message
  prot-notmuch-show-complete-message
  prot-notmuch-mark-complete-tags)

(prot-notmuch-show-tag-message
  prot-notmuch-show-delete-message
  prot-notmuch-mark-delete-tags)

(prot-notmuch-show-tag-message
  prot-notmuch-show-flag-message
  prot-notmuch-mark-flag-tags)

(prot-notmuch-show-tag-message
  prot-notmuch-show-spam-message
  prot-notmuch-mark-spam-tags)

(prot-notmuch-show-tag-message
  prot-notmuch-show-todo-message
  prot-notmuch-mark-todo-tags)

(prot-notmuch-show-tag-message
  prot-notmuch-show-reference-message
  prot-notmuch-mark-reference-tags)

(autoload 'notmuch-refresh-this-buffer "notmuch")
(autoload 'notmuch-refresh-all-buffers "notmuch")

(defun prot-notmuch-refresh-buffer (&optional arg)
  "Run `notmuch-refresh-this-buffer'.
With optional prefix ARG (\\[universal-argument]) call
`notmuch-refresh-all-buffers'."
  (interactive "P")
  (if arg
      (notmuch-refresh-all-buffers)
    (notmuch-refresh-this-buffer)))

;;;###autoload
(defun prot-notmuch-delete-mail ()
  "Permanently delete mail marked as `prot-notmuch-delete-mail'.
Prompt for confirmation before carrying out the operation.

Do not attempt to refresh the index.  This will be done upon the
next invocation of 'notmuch new'."
  (interactive)
  (let* ((del-tag prot-notmuch-delete-tag)
         (count
          (string-to-number
           (with-temp-buffer
             (shell-command
              (format "notmuch count tag:%s" prot-notmuch-delete-tag) t)
             (buffer-substring-no-properties (point-min) (1- (point-max))))))
         (mail (if (> count 1) "mails" "mail")))
    (unless (> count 0)
      (user-error "No mail marked as `%s'" del-tag))
    (when (yes-or-no-p
           (format "Delete %d %s marked as `%s'?" count mail del-tag))
      (shell-command
       (format "notmuch search --output=files --format=text0 tag:%s | xargs -r0 rm" del-tag)
       t))))

;;;; Mode line unread indicator

;; NOTE 2021-05-14: I have an alternative to this in prot-mail.el which
;; does not rely on notmuch as it uses find instead.  The following
;; approach is specific to my setup and is what I prefer now.

(defcustom prot-notmuch-mode-line-count-args "tag:unread and tag:inbox"
  "Arguments to pass to 'notmuch count' for counting new mail."
  :type 'string
  :group 'prot-notmuch)

(defcustom prot-notmuch-mode-line-indicator-commands '(notmuch-refresh-this-buffer)
  "List of commands that will be advised to update the mode line.
The advice is designed to run a hook which is used internally by
the function `prot-notmuch-mail-indicator'."
  :type 'list
  :group 'prot-notmuch)

(defface prot-notmuch-mail-count
  '((default :inherit bold)
    (((class color) (min-colors 88) (background light))
     :foreground "#61284f")
    (((class color) (min-colors 88) (background dark))
     :foreground "#fbd6f4")
    (t :foreground "magenta"))
  "Face for mode line indicator that shows a new mail count.")

(defvar prot-notmuch-new-mail-string nil
  "New maildir count number for the mode line.")

(defun prot-notmuch--new-mail ()
  "Search for new mail in personal maildir paths."
  (with-temp-buffer
    (shell-command
     (format "notmuch count %s" prot-notmuch-mode-line-count-args) t)
    (buffer-substring-no-properties (point-min) (1- (point-max)))))

(defun prot-notmuch--mode-string (count)
  "Add properties to COUNT string."
  (when (not (string= count "0"))
    (propertize (format "@%s " count)
                'face 'prot-notmuch-mail-count
                'help-echo "New mails matching `prot-notmuch-mode-line-count-args'")))

(defvar prot-notmuch--mode-line-mail-indicator nil
  "Internal variable used to store the state of new mails.")

(defun prot-notmuch--mode-line-mail-indicator ()
  "Prepare new mail count mode line indicator."
  (let* ((count (prot-notmuch--new-mail))
         (indicator (prot-notmuch--mode-string count))
         (old-indicator prot-notmuch--mode-line-mail-indicator))
    (when old-indicator
      (setq global-mode-string (delete old-indicator global-mode-string)))
    (cond
     ((>= (string-to-number count) 1)
      (setq global-mode-string (push indicator global-mode-string))
      (setq prot-notmuch--mode-line-mail-indicator indicator))
     (t
      (setq prot-notmuch--mode-line-mail-indicator nil)))))

(defvar prot-notmuch--mode-line-mail-sync-hook nil
  "Hook to refresh the mode line for the mail indicator.")

(defun prot-notmuch--add-hook (&rest _)
  "Run `prot-notmuch--mode-line-mail-sync-hook'.
Meant to be used as advice after specified commands that should
update the mode line indicator with the new mail count."
  (run-hooks 'prot-notmuch--mode-line-mail-sync-hook))

;;;###autoload
(define-minor-mode prot-notmuch-mail-indicator
  "Enable mode line indicator with counter for new mail."
  :init-value nil
  :global t
  (if prot-notmuch-mail-indicator
      (progn
        (run-at-time t 60 #'prot-notmuch--mode-line-mail-indicator)
        (when prot-notmuch-mode-line-indicator-commands
          (dolist (fn prot-notmuch-mode-line-indicator-commands)
            (advice-add fn :after #'prot-notmuch--add-hook)))
        (add-hook 'prot-notmuch--mode-line-mail-sync-hook #'prot-notmuch--mode-line-mail-indicator)
        (force-mode-line-update t))
    (cancel-function-timers #'prot-notmuch--mode-line-mail-indicator)
    (setq global-mode-string (delete prot-notmuch--mode-line-mail-indicator global-mode-string))
    (remove-hook 'prot-notmuch--mode-line-mail-sync-hook #'prot-notmuch--mode-line-mail-indicator)
    (when prot-notmuch-mode-line-indicator-commands
      (dolist (fn prot-notmuch-mode-line-indicator-commands)
        (advice-remove fn #'prot-notmuch--add-hook)))
    (force-mode-line-update t)))

;;;; SourceHut-related setup

(defconst prot-notmuch-patch-control-codes
  '("PROPOSED" "NEEDS_REVISION" "SUPERSEDED" "APPROVED" "REJECTED" "APPLIED")
  "Control codes for SourceHut patches.
See `prot-notmuch-patch-add-email-control-code' for how to apply
them.")

(declare-function message-fetch-field "message" (header &optional first))
(declare-function message-add-header "message" (&rest headers))

;; Read: <https://man.sr.ht/lists.sr.ht/#email-controls>.
;;;###autoload
(defun prot-notmuch-patch-add-email-control-code (control-code)
  "Add custom header for SourceHut email controls.
The CONTROL-CODE is one of these special keywords (capitalisation
is canonical): PROPOSED, NEEDS_REVISION, SUPERSEDED, APPROVED,
REJECTED, APPLIED."
  (interactive
   (list (completing-read "Select control code: " prot-notmuch-patch-control-codes nil t)))
  (if (member control-code prot-notmuch-patch-control-codes)
    (unless (message-fetch-field "X-Sourcehut-Patchset-Update")
      (message-add-header (format "X-Sourcehut-Patchset-Update: %s" control-code)))
    (user-error "%s is not specified in `prot-notmuch-patch-control-codes'" control-code)))

(provide 'prot-notmuch)
;;; prot-notmuch.el ends here
