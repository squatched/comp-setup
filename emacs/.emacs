;; Add my load path.
(add-to-list 'load-path "~/.emacs.d")

;; Set autosave files (such as #file#) and backup files (such as file~) to
;;   save to custom directories instead of wherever the file actually
;;   exists.

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(ansi-color-names-vector ["black" "#d55e00" "#009e73" "#f8ec59" "#0072b2" "#cc79a7" "#56b4e9" "white"])
 '(auto-save-file-name-transforms (quote ((".*" "~/.emacs.autosaves/\\1" t))))
 '(backup-directory-alist (quote ((".*" . "~/.emacs.backups/"))))
 '(c-tab-always-indent nil)
 '(column-number-mode t)
 '(custom-enabled-themes (quote (deeper-blue)))
 '(desktop-save-mode t)
 '(global-linum-mode t)
 '(ido-enable-flex-matching t)
 '(ido-everywhere t)
 '(ido-mode (quote both) nil (ido))
 '(indent-tabs-mode nil)
 '(indicate-buffer-boundaries (quote left))
 '(package-archives (quote (("gnu" . "http://elpa.gnu.org/packages/") ("melpa" . "http://melpa.milkbox.net/packages/"))))
 '(save-place t nil (saveplace))
 '(show-paren-mode t)
 '(tab-always-indent (quote complete))
 '(tab-width 4)
 '(text-mode-hook (quote (turn-on-auto-fill text-mode-hook-identify)))
 '(tool-bar-mode nil)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; create the autosave dir if necessary, since emacs won't
(make-directory "~/.emacs.autosaves/" t)

;; Set server mode so we don't get multiple instances of emacs.
(server-start)

;; Set tab width to 4
(setq tab-stop-list (number-sequence 4 200 4))

;; Set up my init stuff to fire after elpa packages are initialized.
(add-hook 'after-init-hook (lambda () (load "~/.emacs.d/init/init.el")))
