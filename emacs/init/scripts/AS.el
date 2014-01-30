;*****************************************************************************
;*
;*  AS.el
;*  Handles initializing syntax highlighting for action script.
;*
;*  By Caleb McCombs (7/24/2013)
;*
;***

;; Activate imenu in AS
(add-hook 'actionscript-mode-hook 'imenu-add-menubar-index)
(add-hook 'actionscript-mode-hook 'actionscript-init-imenu)
(defun actionscript-init-imenu ()
  (interactive)
  (setq imenu-generic-expression as-imenu-as-generic-expression)
  (global-set-key [mouse-3] 'imenu))

(defvar as-imenu-as-generic-expression
  ` (
    ("variables"
     ,(concat
       "^"
        "[ t]*(public|protected|mx_internal|private)"
        "[ t]+var"
        "[ t]+([a-zA-Z_][a-zA-Z0-9_]*)"     ; match function name
        "[ t]*:([a-zA-Z_][a-zA-Z0-9_]*)"        ), 2)

    ;; Getters
    ("Getters"
     ,(concat
       "^"
       "[ t]*(override[ tn]+)?"
        "[ t]*(public|protected|mx_internal|private)"
        "[ t]+function"
        "[ t]+"
        "(get[ t]+([a-zA-Z_][a-zA-Z0-9_]*)[ t]*)()"
       ) 3)

    ;;setters
    ("setters"
     ,(concat
       "^"
       "[ t]*(override[ tn]+)?"
        "[ t]*(public|protected|mx_internal|private)"
        "[ t]+function"
        "[ t]+"
        "(set[ t]+([a-zA-Z_][a-zA-Z0-9_]*)[ t]*)"
        "("
        "([a-zA-Z_][a-zA-Z0-9_]*):([a-zA-Z_][a-zA-Z0-9_]*)[ tn]*"
        ")"
       ) 3)

;; Class definitions
    (nil
     ,(concat
         "^"
         "((public|protected|mx_internal|private)[ t]+)?"
         "(class|interface)[ t]+"
         "("                                ; the string we want to get
         "[a-zA-Z0-9_]+"                      ; class name
         ")"
         "[ tn]*"
         "(extends [ tn]*[a-zA-Z0-9_]+)?"
         "[ tn]*";;[:{]"
         "(implements [ tn]*([a-zA-Z0-9_]+[,][ tn]*)*[a-zA-Z0-9_])?"
         "[ tn]*";;[:{]"
         ) 4)

;; General function name regexp
    (nil
     ,(concat
       "^"
       "[ t]*(override[ tn]+)?"
        "[ t]*(public|protected|mx_internal|private)"
       "([ t]+static)?"
        "[ t]+function"
        "[ t]+([a-zA-Z_][a-zA-Z0-9_]*)"     ; match function name
        "[ t]*("
        "[^)]*)"
       ) 4)
    )
  "Imenu generic expression for C++ mode.  See `imenu-generic-expression'.")

