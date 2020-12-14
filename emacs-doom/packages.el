;; -*- no-byte-compile: t; -*-
;;; ~/.doom.d/packages.el

;;; Examples:
;; (package! some-package)
;; (package! another-package :recipe (:fetcher github :repo "username/repo"))
;; (package! builtin-package :disable t)

;; Support CMakeLists.txt
(package! cmake-mode)

;; Export Org docs to beautiful reveal.js presentations
(package! org-reveal)
(package! htmlize)
