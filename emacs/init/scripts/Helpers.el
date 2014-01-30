;*****************************************************************************
;*
;*  Helpers.el
;*  Handles initialization of random helpers I have installed.
;*
;*  By Caleb McCombs (7/24/2013)
;*
;***

;; Activate smex
;; The following line forces smex to be auto-loaded. Use this if I come up
;;   against any other packages that don't seem to auto-load.
;(add-to-list 'load-path "~/.emacs.d/elpa/smex-20120831.2023/")

;; Startup Smex
(require 'smex)
(smex-initialize)

;; Startup TextMate
;;(add-to-list 'load-path "~/.emacs.d/vendor/textmate.el")
;;(require 'textmate)
;;(textmate-mode)

;; Activate idomenu
(autoload 'idomenu "idomenu" nil t)

