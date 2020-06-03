;;; ~/.doom.d/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here

;; Most basic support for Brazil I could possibly do.
(projectile-register-project-type 'Brazil-Package '("Config")
                                  :compile "brazil-build")
(projectile-register-project-type 'Brazil-Workspace '("packageInfo"))

;; From @Henrik (via Discord):
;; A breaking update in the doom-modeline package is causing (void-function battery-update) errors at startup. It was introduced in https://github.com/seagle0128/doom-modeline/commit/247d77cc60dffb85f779c612fe792c07a8b5705a.
;;
;; - The issue has been reported: https://github.com/seagle0128/doom-modeline/issues/274
;; - Adding this to ~/.doom.d/config.el will suppress the error while we wait for a fix: (fset 'battery-update #'ignore)
(fset 'battery-update #'ignore)

;; Projectile project dirs...
(setq projectile-project-search-path '("~/Projects" "~/Workspaces"))

;; Enable subword mode everywhere!!!
(global-subword-mode 1)


;; If we have a local ca-bundle for DOOM Emacs, point GnuTLS at it rather than
;; the system provided one.
(let ((local-cert-bundle-path "~/.config/doom/ca-bundle.crt"))
  (when (file-exists-p local-cert-bundle-path)
    ;;; Code:
    (setq gnutls-trustfiles local-cert-bundle-path)))
