;*****************************************************************************
;*
;*  Modes.el
;*  Handles initializing my major modes.
;*
;*  By Caleb McCombs (7/24/2013)
;*
;***

;*****************************************************************************
;*
;*  Utility Modes
;*
;**


;*****************************************************************************
;*
;*  Programming/Scripting Modes
;*
;***

;; Activate cc mode
(autoload 'c++-mode "c++-mode" "Major mode for editing C++ code." t)
(add-to-list 'auto-mode-alist '("\\.h$"   . c++-mode))
(add-to-list 'auto-mode-alist '("\\.hpp$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.c$"   . c++-mode))
(add-to-list 'auto-mode-alist '("\\.cpp$" . c++-mode))
(add-to-list 'auto-mode-alist '("\\.inl$" . c++-mode))


;; Activate actionscript mode
(autoload 'actionscript-mode "actionscript-mode" "Major mode for actionscript." t)
(add-to-list 'auto-mode-alist '("\\.as$" . actionscript-mode))

;; Activate powershell mode
(autoload 'powershell-mode "powershell-mode" "Major mode for powershell." t)
(add-to-list 'auto-mode-alist '("\\.ps1$" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.psm1$" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.psd1$" . powershell-mode))

;; Activate lua mode
(autoload 'lua-mode "lua-mode" "Lua editing mode." t)
(add-to-list 'auto-mode-alist '("\\.lua$" . lua-mode))
(add-to-list 'interpreter-mode-alist '("lua" . lua-mode))

;; Activate batch mode
(autoload 'batch-mode "batch-mode" "Major mode for dos batch scripts." t)
(add-to-list 'auto-mode-alist '("\\.bat$" . batch-mode))

;; Activate yaml mode
(autoload 'yaml-mode "yaml-mode" "Major mode for yaml files." t)
(add-to-list 'auto-mode-alist '("\\.yml$" . yaml-mode))

;; Activate haxe mode
(autoload 'haxe-mode "haxe-mode" "Major mode for haxe files." t)
(add-to-list 'auto-mode-alist '("\\.hx$" . haxe-mode))
