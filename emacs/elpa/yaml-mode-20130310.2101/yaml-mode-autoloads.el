;;; yaml-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads (yaml-mode yaml) "yaml-mode" "../../../../../AppData/Roaming/.emacs.d/elpa/yaml-mode-20130310.2101/yaml-mode.el"
;;;;;;  "4420e8062193c6879069550742131706")
;;; Generated autoloads from ../../../../../AppData/Roaming/.emacs.d/elpa/yaml-mode-20130310.2101/yaml-mode.el

(let ((loads (get 'yaml 'custom-loads))) (if (member '"yaml-mode" loads) nil (put 'yaml 'custom-loads (cons '"yaml-mode" loads))))

(autoload 'yaml-mode "yaml-mode" "\
Simple mode to edit YAML.

\\{yaml-mode-map}

\(fn)" t nil)

(add-to-list 'auto-mode-alist '("\\.ya?ml$" . yaml-mode))

;;;***

;;;### (autoloads nil nil ("../../../../../AppData/Roaming/.emacs.d/elpa/yaml-mode-20130310.2101/yaml-mode-pkg.el"
;;;;;;  "../../../../../AppData/Roaming/.emacs.d/elpa/yaml-mode-20130310.2101/yaml-mode.el")
;;;;;;  (21225 29510 669000 0))

;;;***

(provide 'yaml-mode-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; yaml-mode-autoloads.el ends here
