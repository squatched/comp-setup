;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

;; Add my load path.

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.
(package-initialize)

(add-to-list 'load-path "~/.emacs.d/elpa/")
(add-to-list 'load-path "~/.emacs.d/init/")

;; Set autosave files (such as #file#) and backup files (such as file~) to
;;   save to custom directories instead of wherever the file actually
;;   exists.

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector
   ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(auto-save-file-name-transforms (quote ((".*" "~/.emacs.autosaves/\\1" t))))
 '(backup-directory-alist (quote ((".*" . "~/.emacs.backups/"))))
 '(c-tab-always-indent nil)
 '(column-number-mode t)
 '(custom-enabled-themes (quote (deeper-blue)))
 '(desktop-load-locked-desktop t)
 '(desktop-path (quote ("~/.emacs.d/")))
 '(desktop-restore-frames nil)
 '(desktop-save t)
 '(desktop-save-mode t)
 '(ecb-compile-window-width (quote edit-window))
 '(ecb-layout-name "left-custom")
 '(ecb-layout-window-sizes
   (quote
    (("left-custom"
      (ecb-directories-buffer-name 0.20707070707070707 . 0.4339622641509434)
      (ecb-methods-buffer-name 0.20707070707070707 . 0.4528301886792453)
      (ecb-history-buffer-name 0.20707070707070707 . 0.09433962264150944))
     ("left9"
      (ecb-directories-buffer-name 0.22727272727272727 . 0.4339622641509434)
      (ecb-methods-buffer-name 0.22727272727272727 . 0.4528301886792453)
      (ecb-history-buffer-name 0.22727272727272727 . 0.09433962264150944)))))
 '(ecb-mode-line-display-window-number nil)
 '(ecb-options-version "2.40")
 '(ecb-primary-secondary-mouse-buttons (quote mouse-1--mouse-2))
 '(ecb-show-sources-in-directories-buffer (quote always))
 '(ecb-source-path
   (quote
    (("/srv/proj/maa/server" "maa_server")
     ("/srv/proj/maa/client" "maa_client")
     ("/srv/vm/server" "vm_maa_server")
     ("/srv/vm/client" "vm_maa_client"))))
 '(ecb-tip-of-the-day nil)
 '(ecb-tree-make-parent-node-sticky nil)
 '(ecb-windows-width 0.25)
 '(ede-project-directories (quote ("/srv/proj/maa/server/rails")))
 '(global-linum-mode t)
 '(ido-enable-flex-matching t)
 '(ido-everywhere t)
 '(ido-mode (quote both) nil (ido))
 '(indent-tabs-mode nil)
 '(indicate-buffer-boundaries (quote left))
 '(json-reformat:indent-width 2)
 '(json-reformat:pretty-string\? t)
 '(package-archives
   (quote
    (("gnu" . "http://elpa.gnu.org/packages/")
     ("melpa" . "http://melpa.milkbox.net/packages/"))))
 '(package-selected-packages
   (quote
    (powershell yaml-mode textmate smex rinari popup modern-cpp-font-lock lua-mode load-dir json-mode idomenu ido-ubiquitous ecb batch-mode)))
 '(reb-re-syntax (quote string))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(tab-always-indent (quote complete))
 '(tab-width 2)
 '(text-mode-hook (quote (turn-on-auto-fill text-mode-hook-identify)))
 '(tool-bar-mode nil)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Bitstream Vera Sans Mono" :foundry "bitstream" :slant normal :weight normal :height 91 :width normal)))))

;; Make kill-emacs save desktop and release the lock.
(add-hook 'kill-emacs-hook
          `(lambda ()
             (desktop-save ,(car desktop-path) t)))

;; create the autosave dir if necessary, since emacs won't
(make-directory "~/.emacs.autosaves/" t)

;; Set server mode so we don't get multiple instances of emacs.
(server-start)

;; Set tab width to 2
(setq tab-stop-list (number-sequence 2 200 2))

;; Set up my init stuff to fire after elpa packages are initialized.
(add-hook 'after-init-hook (lambda () (load "~/.emacs.d/init/init.el")))

;; Disable the system beep warning bell
(setq ring-bell-function 'ignore)
(put 'upcase-region 'disabled nil)
