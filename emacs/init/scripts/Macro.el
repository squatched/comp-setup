;*****************************************************************************
;*
;*  Macro.el
;*  Initializes my macro defuns.
;*
;*  By Caleb McCombs (7/24/2013)
;*
;***

;; Macro definition and handling.
(defun name-dmf-macro-1 ()
  "proc to name last macro"
  (interactive nil)
  (name-last-kbd-macro `do-dmf-macro-1))
(defun name-dmf-macro-2 ()
  "proc to name last macro"
  (interactive nil)
  (name-last-kbd-macro `do-dmf-macro-2))

;(define-key global-map [f1]    'do-dmf-macro-1)
;(define-key global-map [f2]    'do-dmf-macro-2)
;(define-key global-map [f3]    'call-last-kbd-macro)
;(define-key global-map [\M-f1] 'name-dmf-macro-1)
;(define-key global-map [\M-f2] 'name-dmf-macro-2)
;(global-set-key [\M-f1] 'name-dmf-macro-1)
;(global-set-key [\M-f2] 'name-dmf-macro-2)

