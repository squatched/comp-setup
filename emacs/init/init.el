;*****************************************************************************
;*
;*  init.el
;*  This init is run after packages are initialized.
;*
;*  By Caleb McCombs (7/24/2013)
;*
;***

;; Load everything in this directory.
(require 'load-dir)
(setq load-dirs "~/.emacs.d/init/scripts")
(load-dirs)
(setq load-dirs nil)
