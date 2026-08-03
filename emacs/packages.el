;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:fetcher github :repo "username/repo"))
;; (package! builtin-package :disable t)

;; Support CMakeLists.txt
(package! cmake-mode)

;; Export Org docs to beautiful reveal.js presentations
(package! ox-reveal :disable t)
(package! org-re-reveal
  :recipe (:host gitlab :repo "oer/org-re-reveal"))

(package! htmlize)

;; Python style formatter.
(package! blacken)
