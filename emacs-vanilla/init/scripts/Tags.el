;*****************************************************************************
;*
;*  Tags.el
;*  Initializes my tag handling stuff.
;*
;*  By Caleb McCombs (7/24/2013)
;*
;***

;; Load tag files
(setq tags-table-list
      '("./" "./../" "./../../" "./../../../" "./../../../../" "./../../../../../" "./../../../../../../"))

;;;  Jonas.Jarnestrom<at>ki.ericsson.se A smarter               
;;;  find-tag that automagically reruns etags when it cant find a               
;;;  requested item and then makes a new try to locate it.                      
;;;  Fri Mar 15 09:52:14 2002    
(defadvice find-tag (around refresh-etags activate)
  "Rerun etags and reload tags if tag not found and redo find-tag.
   If buffer is modified, ask about save before running etags."
  (let ((extension (file-name-extension (buffer-file-name))))
    (condition-case err
        ad-do-it
      (error (and (buffer-modified-p)
                  (not (ding))
                  (y-or-n-p "Buffer is modified, save it? ")
                  (save-buffer))
             (er-refresh-etags extension)
             ad-do-it))))
(defun er-refresh-etags (&optional extension)
  "Run etags on all peer files in current dir and reload them silently."
  (interactive)
  (shell-command (format "ectags *.%s" (or extension "el")))
  (let ((tags-revert-without-query t))  ; don't query, revert silently
    (visit-tags-table default-directory nil)))

