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
;; .h, .hpp, .c, .cpp, .inl
(add-to-list 'auto-mode-alist '("\\.(h(pp)?|c(pp)?|inl)$" . c++-mode))

;; Activate actionscript mode
(autoload 'actionscript-mode "actionscript-mode" "Major mode for actionscript." t)
(add-to-list 'auto-mode-alist '("\\.as$" . actionscript-mode))

;; Activate powershell mode
(autoload 'powershell-mode "powershell-mode" "Major mode for powershell." t)
;; .ps1, .psm1, .psd1
(add-to-list 'auto-mode-alist '("\\.ps(m|d)?1$" . powershell-mode))

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

;; Activate Json mode
(autoload 'json-mode "json-mode" "Json editing mode." t)
(add-to-list 'auto-mode-alist '("\\.map$" . json-mode))
