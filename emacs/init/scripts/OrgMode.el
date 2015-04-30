;*****************************************************************************
;*
;*  Org.el
;*  Handles initializing my custom org-mode setups.
;*
;*  By Caleb McCombs (11/11/2014)
;*
;***

(require 'org)
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
