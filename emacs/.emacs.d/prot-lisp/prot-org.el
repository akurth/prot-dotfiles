;;; prot-org.el --- Tweaks for my org-mode configurations -*- lexical-binding: t -*-

;; Copyright (C) 2021-2023  Protesilaos Stavrou

;; Author: Protesilaos Stavrou <info@protesilaos.com>
;; URL: https://protesilaos.com/emacs/dotemacs
;; Version: 0.1.0
;; Package-Requires: ((emacs "30.1"))

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
;; This covers my tweaks for Org that are meant for use in my
;; Emacs setup: https://protesilaos.com/emacs/dotemacs.
;;
;; Remember that every piece of Elisp that I write is for my own
;; educational and recreational purposes.  I am not a programmer and I
;; do not recommend that you copy any of this if you are not certain of
;; what it does.

;;; Code:

(require 'prot-common)
(require 'org)

(defgroup prot-org ()
  "Extensions for org.el."
  :group 'org)

;;;; org-capture

(defvar prot-org--capture-coach-person-history nil)

(declare-function message-fetch-field "message" (header &optional first))
(declare-function notmuch-show-get-header "notmuch-show")

(defun prot-org--capture-coach-person-message-from ()
  "Return default value for `prot-org--capture-coach-person-prompt'."
  (when-let ((from (cond
                    ((derived-mode-p 'message-mode)
                     (message-fetch-field "To"))
                    ((derived-mode-p 'notmuch-show-mode)
                     (notmuch-show-get-header :From)))))
    (string-clean-whitespace (car (split-string from "<")))))

(defun prot-org--capture-coach-person-message-from-and-subject ()
  "Return default value for `prot-org--capture-coach-person-prompt'."
  (cond
   ((derived-mode-p 'message-mode)
    (message-fetch-field "Subject"))
   ((derived-mode-p 'notmuch-show-mode)
    (notmuch-show-get-header :Subject))))

(defun prot-org--capture-coach-person-prompt ()
  "Prompt for person for use in `prot-org-capture-coach'."
  (completing-read "Person to coach: "
                   prot-org--capture-coach-person-history
                   nil nil nil
                   'prot-org--capture-coach-person-history
                   (prot-org--capture-coach-person-message-from)))

(defvar prot-org--capture-coach-description-history nil)

(defun prot-org--capture-coach-description-prompt ()
  "Prompt for description in `prot-org-capture-coach'."
  (read-string "Description: "
               nil
               'prot-org--capture-coach-description-history
               (prot-org--capture-coach-person-message-from-and-subject)))

(defun prot-org--capture-coach-date-prompt-range ()
  "Prompt for Org date and return it as a +1h range.
For use in `prot-org-capture-coach'."
  (let ((date (org-read-date :with-time)))
    ;; We cannot use this here, unfortunately, as the Org agenda
    ;; interprets it both as a deadline and an event with the date
    ;; range.
    ;;
    ;; (format "DEADLINE: <%s>--<%s>\n" date
    (format "<%s>--<%s>\n" date
            (org-read-date
             :with-time nil "++1h" nil
             (org-encode-time (org-parse-time-string date))))))

(defun prot-org-capture-coach ()
  "Contents of an Org capture template for my coaching lessons."
  (concat "* COACH " (prot-org--capture-coach-person-prompt) " "
          (prot-org--capture-coach-description-prompt) " :lesson:\n"
          ;; See comment above
          ;; (prot-org--capture-coach-date-prompt-range)
          "DEADLINE: %^T\n"
          ":PROPERTIES:\n"
          ":CAPTURED: %U\n"
          ":APPT_WARNTIME: 20\n"
          ":END:\n\n"
          "%a%?"))

(defun prot-org-capture-coach-clock ()
  "Contents of an Org capture for my clocked coaching services."
  (concat "* COACH " (prot-org--capture-coach-person-prompt) " "
          (prot-org--capture-coach-description-prompt) " :service:\n"
          ;; See comment above
          ;; (prot-org--capture-coach-date-prompt-range)
          ":PROPERTIES:\n"
          ":CAPTURED: %U\n"
          ":END:\n\n"
          "%a%?"))

(declare-function cl-letf "cl-lib")

;; Adapted from source: <https://stackoverflow.com/a/54251825>.
;;
;; Thanks to Juanjo Presa (@uningan on GitHub) for discovering that the
;; original version was causing an error in `org-roam'.  I then figure
;; we were missing the `&rest':
;; <https://github.com/org-roam/org-roam/issues/2142#issuecomment-1100718373>.
(defun prot-org--capture-no-delete-windows (&rest args)
  (cl-letf (((symbol-function 'delete-other-windows) 'ignore))
    (apply args)))

;; Same source as above
(advice-add 'org-capture-place-template :around 'prot-org--capture-no-delete-windows)
(advice-add 'org-add-log-note :around 'prot-org--capture-no-delete-windows)

;;;; org-agenda

(declare-function calendar-day-name "calendar")
(declare-function calendar-day-of-week "calendar")
(declare-function calendar-month-name "calendar")
(declare-function org-days-to-iso-week "org")
(declare-function calendar-absolute-from-gregorian "calendar")

(defvar org-agenda-format-date)

;;;###autoload
(defun prot-org-agenda-format-date-aligned (date)
  "Format a DATE string for display in the daily/weekly agenda.
This function makes sure that dates are aligned for easy reading.

Slightly tweaked version of `org-agenda-format-date-aligned' that
produces dates with a fixed length."
  (require 'cal-iso)
  (let* ((dayname (calendar-day-name date t))
         (day (cadr date))
         (day-of-week (calendar-day-of-week date))
         (month (car date))
         (monthname (calendar-month-name month t))
         (year (nth 2 date))
         (iso-week (org-days-to-iso-week
                    (calendar-absolute-from-gregorian date)))
         ;; (weekyear (cond ((and (= month 1) (>= iso-week 52))
         ;;                  (1- year))
         ;;                 ((and (= month 12) (<= iso-week 1))
         ;;                  (1+ year))
         ;;                 (t year)))
         (weekstring (if (= day-of-week 1)
                         (format " (W%02d)" iso-week)
                       "")))
    (format "%s %2d %s %4d%s"
            dayname day monthname year weekstring)))

(defvar org-priority-highest)

(defvar prot-org-custom-daily-agenda
  ;; NOTE 2021-12-08: Specifying a match like the following does not
  ;; work.
  ;;
  ;; tags-todo "+PRIORITY=\"A\""
  ;;
  ;; So we match everything and then skip entries with
  ;; `org-agenda-skip-function'.
  `((tags-todo "*"
               ((org-agenda-skip-function '(org-agenda-skip-if nil '(timestamp)))
                (org-agenda-skip-function
                 `(org-agenda-skip-entry-if
                   'notregexp ,(format "\\[#%s\\]" (char-to-string org-priority-highest))))
                (org-agenda-block-separator nil)
                (org-agenda-overriding-header "Important tasks without a date\n")))
    (agenda "" ((org-agenda-time-grid nil)
                (org-agenda-start-on-weekday nil)
                (org-agenda-span 1)
                (org-agenda-show-all-dates nil)
                (org-scheduled-past-days 365)
                ;; Excludes today's scheduled items
                (org-scheduled-delay-days 1)
                (org-agenda-block-separator nil)
                (org-agenda-entry-types '(:scheduled))
                (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                (org-agenda-skip-function '(org-agenda-skip-entry-if 'regexp "TRAIN"))
                (org-agenda-category-filter "-habit")
                (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                (org-agenda-format-date "")
                (org-agenda-overriding-header "\nPending scheduled tasks")))
    (agenda "" ((org-agenda-span 1)
                (org-deadline-warning-days 0)
                (org-agenda-block-separator nil)
                (org-scheduled-past-days 0)
                ;; We don't need the `org-agenda-date-today'
                ;; highlight because that only has a practical
                ;; utility in multi-day views.
                (org-agenda-day-face-function (lambda (date) 'org-agenda-date))
                (org-agenda-format-date "%A %-e %B %Y")
                (org-agenda-overriding-header "\nToday's agenda\n")))
    (agenda "" ((org-agenda-start-on-weekday nil)
                (org-agenda-start-day nil)
                (org-agenda-start-day "+1d")
                (org-agenda-span 3)
                (org-deadline-warning-days 0)
                (org-agenda-block-separator nil)
                (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                (org-agenda-overriding-header "\nNext three days\n")))
    (agenda "" ((org-agenda-time-grid nil)
                (org-agenda-start-on-weekday nil)
                ;; We don't want to replicate the previous section's
                ;; three days, so we start counting from the day after.
                (org-agenda-start-day "+4d")
                (org-agenda-span 14)
                (org-agenda-show-all-dates nil)
                (org-deadline-warning-days 0)
                (org-agenda-block-separator nil)
                (org-agenda-entry-types '(:deadline))
                (org-agenda-skip-function '(org-agenda-skip-entry-if 'todo 'done))
                (org-agenda-overriding-header "\nUpcoming deadlines (+14d)\n"))))
  "Custom agenda for use in `org-agenda-custom-commands'.")

;;;;; agenda appointments

(defvar prot-org-agenda-after-edit-hook nil
  "Hook that runs after select Org commands.
To be used with `advice-add'.")

(defun prot-org--agenda-after-edit (&rest _)
  "Run `prot-org-agenda-after-edit-hook'."
  (run-hooks 'prot-org-agenda-after-edit-hook))

(defvar prot-org-after-deadline-or-schedule-hook nil
  "Hook that runs after `org--deadline-or-schedule'.
To be used with `advice-add'.")

(defvar prot-org--appt-agenda-commands
  '( org-agenda-archive org-agenda-deadline org-agenda-schedule
     org-agenda-todo org-archive-subtree)
  "List of commands that run `prot-org-agenda-after-edit-hook'.")

(dolist (fn prot-org--appt-agenda-commands)
  (advice-add fn :after #'prot-org--agenda-after-edit))

(defun prot-org--after-deadline-or-schedule (&rest _)
  "Run `prot-org-after-deadline-or-schedule-hook'."
  (run-hooks 'prot-org-after-deadline-or-schedule-hook))

(defun prot-org-org-agenda-to-appt ()
  "Make `org-agenda-to-appt' always refresh appointment list."
  (org-agenda-to-appt :refresh))

(dolist (hook '(org-capture-after-finalize-hook
                org-after-todo-state-change-hook
                org-agenda-after-show-hook
                prot-org-agenda-after-edit-hook))
  (add-hook hook #'prot-org-org-agenda-to-appt))

(declare-function org--deadline-or-schedule "org" (arg type time))

(advice-add #'org--deadline-or-schedule :after #'prot-org--after-deadline-or-schedule)

(add-hook 'prot-org-after-deadline-or-schedule-hook #'prot-org-org-agenda-to-appt)

;;;; org-export

(declare-function org-html-export-as-html "org")
(declare-function org-texinfo-export-to-info "org")

;;;###autoload
(defun prot-org-ox-html ()
  "Streamline HTML export."
  (interactive)
  (org-html-export-as-html nil nil nil t nil))

;;;###autoload
(defun prot-org-ox-texinfo ()
  "Streamline Info export."
  (interactive)
  (org-texinfo-export-to-info))

;;;; org-id

(declare-function org-id-add-location "org")
(declare-function org-with-point-at "org")
(declare-function org-entry-get "org")
(declare-function org-id-new "org")
(declare-function org-entry-put "org")

;; Copied from this article (with minor tweaks from my side):
;; <https://writequit.org/articles/emacs-org-mode-generate-ids.html>.
(defun prot-org--id-get (&optional pom create prefix)
  "Get the CUSTOM_ID property of the entry at point-or-marker POM.

If POM is nil, refer to the entry at point.  If the entry does
not have an CUSTOM_ID, the function returns nil.  However, when
CREATE is non nil, create a CUSTOM_ID if none is present already.
PREFIX will be passed through to `org-id-new'.  In any case, the
CUSTOM_ID of the entry is returned."
  (org-with-point-at pom
    (let ((id (org-entry-get nil "CUSTOM_ID")))
      (cond
       ((and id (stringp id) (string-match "\\S-" id))
        id)
       (create
        (setq id (org-id-new (concat prefix "h")))
        (org-entry-put pom "CUSTOM_ID" id)
        (org-id-add-location id (format "%s" (buffer-file-name (buffer-base-buffer))))
        id)))))

(declare-function org-map-entries "org")

;;;###autoload
(defun prot-org-id-headlines ()
  "Add missing CUSTOM_ID to all headlines in current file."
  (interactive)
  (org-map-entries
   (lambda () (prot-org--id-get (point) t))))

;;;###autoload
(defun prot-org-id-headline ()
  "Add missing CUSTOM_ID to headline at point."
  (interactive)
  (prot-org--id-get (point) t))

(provide 'prot-org)
;;; prot-org.el ends here
