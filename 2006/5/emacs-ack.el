;;; ack integration

(load "compile")

(defcustom ack-command "ack --nocolor --nogroup "
  "*Last ack command used in \\[ack]; default for next ack."
  :type 'string
  :group 'compilation)

;; History of ack commands.
(defvar ack-history nil)


(defun ack (command-args)
  "Run ack, with user-specified args, and collect output in a buffer.
While ack runs asynchronously, you can use the \\[next-error] command
to find the text that the ack hits refer to.

This command uses a special history list for its arguments, so you can
easily repeat a ack command.

Adapted from (defun grep) from compile.el
"
  (interactive
   ;; XEmacs change
   (list (read-shell-command "Run ack (like this): "
			     ack-command 'ack-history)))
  (let ((buf (compile-internal command-args
			       "No more ack hits" "ack"
			       ;; Give it a simpler regexp to match.
			       nil grep-regexp-alist)))
    (save-excursion
      (set-buffer buf)
      (set (make-local-variable 'compilation-exit-message-function)
	   ;; XEmacs change
	   (lambda (proc msg)
	     (let ((code (process-exit-status proc)))
	       (if (eq (process-status proc) 'exit)
		   (cond ((zerop code)
			  (cons (format "finished (%d matches found)\n"
					;; stolen from count-matches,
					;; should be refactored by
					;; count-matches returning
					;; count.
					(let ((count 0) opoint)
					  (save-excursion
					    (goto-char (point-min))
					    (while (and (not (eobp))
							(progn (setq opoint (point))
							       (re-search-forward (caar grep-regexp-alist) nil t)))
					      (if (= opoint (point))
						  (forward-char 1)
						(setq count (1+ count))))
					    count)))
				"matched"))
			 ((= code 1)
			  '("finished with no matches found\n" . "no match"))
			 (t
			  (cons msg code)))
		 (cons msg code))))))))
