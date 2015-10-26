;*****************************************************************************
;*
;*  Python.el
;*  Handles initialization of python mode.
;*  This file was started based on: http://google-styleguide.googlecode.com/svn/trunk/google-c-style.el
;*
;*  By Caleb McCombs (9/24/2015)
;*
;***

;; Set up my tab width to be 4 characters.
(add-hook 'python-mode-hook
          (lambda ()
            (setq indent-tabs-mode nil)
            (setq tab-width 4)
            (setq python-indent 4)))
