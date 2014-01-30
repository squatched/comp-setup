;*****************************************************************************
;*
;*  CC.el
;*  Handles initialization of CC mode.
;*  This file was started based on: http://google-styleguide.googlecode.com/svn/trunk/google-c-style.el
;*
;*  By Caleb McCombs (7/24/2013)
;*
;***

;*****************************************************************************
;*
;*  Local Helpers
;*
;***

;=============================================================================
; This defun simply gets the first non-whitespace character at or before point.
(defun get-previous-non-whitespace-character-pos-in-line ()
  "Searches backwards for the next non-whitespace character."
  (save-excursion
    (let ((beginning-of-line-pos (line-beginning-position)))
      (re-search-backward "\\(\\s-\\|\\s<\\|\\s>\\)+" beginning-of-line-pos))))


;*****************************************************************************
;*
;*  ArenaNet C Style
;*
;***

;=============================================================================
;Based on http://www.us.xemacs.org/Documentation/packages/html/cc-mode_9.html#SEC35
;Lots of eLisp tips: http://steve-yegge.blogspot.com/2008/01/emergency-elisp.html
;Default c-hanging-braces-alist: http://cc-mode.sourceforge.net/html-manual/Hanging-Braces.html#Hanging-Braces
(defun arenanet-c-determine-defun-open-hangs (syntax pos)
  "Dynamically calculate if the opening brace for a function should hang or not."
  (catch 'return
    (if (not (eq syntax 'defun-open))
        (throw 'return nil))
    (save-excursion
      (backward-char)
      (goto-char (get-previous-non-whitespace-character-pos-in-line))
      (let ((previous-syntax (car (car (c-guess-basic-syntax)))))
        (if (or (eq previous-syntax 'member-init-intro)
                (eq previous-syntax 'member-init-cont))
            (throw 'return '(before after)))))
    (throw 'return '(after))))

;=============================================================================
(defun arenanet-c-determine-class-open-hangs (syntax pos)
  "Dynamically calculate if the opening brace for a class definition should hang or not."
  (catch 'return
    (if (not (eq syntax 'class-open))
        (throw 'return nil))
    (save-excursion
      (backward-char)
      (goto-char (get-previous-non-whitespace-character-pos-in-line))
      (let ((previous-syntax (car (car (c-guess-basic-syntax)))))
        (if (or (eq previous-syntax 'inherit-intro)
                (eq previous-syntax 'inherit-cont))
            (throw 'return '(before after)))))
    (throw 'return '(after))))

;=============================================================================
(defconst arenanet-c-style
  `(
    ; We use ANSI C prototypes only so ignore this to speed up indentation.
    (c-recognize-knr-p . nil)
    ; Speed up indentation in XEmacs
    (c-enable-xemacs-performance-kludge-p . t)
    ; Our basic indentation level is 4 spaces.
    (c-basic-offset . 4)
    ; Don't use tabs, use spaces!
    (indent-tabs-mode . nil)
    ; Not sure, but I *THINK* this means new comments will be offset by 1 on
    ;   a new line and when anchored, offset by 3. Not unlike THIS comment!
    (c-comment-only-line-offset . (1 . 3))
    ; This handles where to put new lines for braces.
    (c-hanging-braces-alist . (; Top-Level Function Definition
                               (defun-open . arenanet-c-determine-defun-open-hangs)
                               (defun-close . (before after))
                               ; Class Definition
                               (class-open . arenanet-c-determine-class-open-hangs)
                               (class-close . (before after))
                               ; In-Class Inline Method Definition
                               (inline-open)
                               (inline-close . (after))
                               ; Statement Block
                               (block-open . (before after))
                               (block-close . (before after))
                               ; Enum or Static Array List
                               (brace-list-open . (after))
                               (brace-list-close . (before after))
                               ; Enum or Static Array First Entry (No newlines around first entry)
                               (brace-list-intro)
                               ; Lines in an enum or static array list that begin with an open brace.
                               (brace-entry-open)
                               ; Statement on a new-line.
                               (statement-cont . (after))
                               ; Case block that starts with a brace.
                               (statement-case-open . (after))
                               ; Substatement (such as an if or for loop)
                               (substatement-open . (after))
                               ; Lines that close a function arg list.
                               (arglist-close . (after))
                               ; Extern blocks
                               (extern-lang-open . (after))
                               (extern-lang-close . (before after))
                               ; Namespaces
                               (namespace-open . (after))
                               (namespace-close . (before after))
                               ; Included here just fore completeness, CORBA IDL is unused by ArenaNet.
                               (module-open . (after))
                               (module-close . (before after))
                               ; Same as above, don't use CORBA CIDL
                               (composition-open . (after))
                               (composition-close . (before after))
                               ; Also for completeness, these are for java anonymous inner classes.
                               ;   We might have a standard for this but I'm not aware of it.
                               (inexpr-class-open . (after))
                               (inexpr-class-close . (before after))))
    (c-hanging-colons-alist . (; Case labels in switch blocks
                               (case-label . (after))
                               ; Labels (for gotos, yuck)
                               (label . (after))
                               ; Class access control label
                               (access-label)
                               ; Colon in a constructor, before member-init list.
                               (member-init-intro . (after))
                               (inher-intro . (after))))
    (c-hanging-semi&comma-criteria
     . ())))
    

    
;(defun arenanet-c-mode-common-hook ()
;  (c-set-style

;;;;
;; Customizations for all modes in CC Mode.
;(defun my-c-mode-common-hook ()
  ;; set my personal style for the current buffer
  ;;(c-set-style "PERSONAL")
  ;; other customizations
;  (setq tab-width 4
        ;; this will make sure spaces are used instead of tabs
;        indent-tabs-mode nil)
;    (c-toggle-electric-state 1)         ; Turn on auto-formatting when certain chars are typed.
;    (c-toggle-auto-hungry-state 1)      ; Delete white space to comment in one button press.
;    (subword-mode 1)                    ; Enable M-b & M-f to navigate in sub words.
;    (c-toggle-syntactic-indentation 1)) ; Allow syntactic indentation.
;(add-hook 'c-mode-common-hook 'arenanet-c-mode-common-hook)

