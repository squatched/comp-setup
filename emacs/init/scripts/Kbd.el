;*****************************************************************************
;*
;*  Kbd.el
;*  Handles initializing my custom key bindings.
;*
;*  By Caleb McCombs (7/24/2013)
;*
;***

(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command) ;;old M-x

(global-set-key (kbd "<f1>") 'do-dmf-macro-1)
(global-set-key (kbd "<f2>") 'do-dmf-macro-2)
(global-set-key (kbd "<f3>") 'call-last-kbd-macro)
(global-set-key (kbd "M-<f1>") 'name-dmf-macro-1)
(global-set-key (kbd "M-<f2>") 'name-dmf-macro-2)

