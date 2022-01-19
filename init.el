;;; package --- Summary

;;; Commentary: My init.el.


;;; Code:

(if (eq system-type 'windows-nt)
    (setq user-emacs-directory (concat (getenv "HOME") "/.emacs.d/"))
  ;; Linux.
  (setq user-emacs-directory (concat (getenv "HOME") "/.config/emacs/")))

;; Move where emacs puts its cache variables.
(let* ((my-emacs-custom-file (concat user-emacs-directory "custom-vars.el")))
  ;; Create custom variable file if it does not exist.
  (when (not (file-exists-p my-emacs-custom-file))
    (with-temp-buffer (write-file my-emacs-custom-file)))
  (setq custom-file my-emacs-custom-file)
  (load "custom-vars.el" 'noerror))


;; Set up package management.
(require 'package)

(package-initialize)

(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)

;; Set up quelpa.
(unless (package-installed-p 'quelpa)
  (with-temp-buffer
    (url-insert-file-contents "https://github.com/quelpa/quelpa/raw/master/quelpa.el")
    (eval-buffer)
    (quelpa-self-upgrade)))

(unless (package-installed-p 'quelpa-use-package)
  (package-refresh-contents)
  (package-install 'quelpa-use-package))

(quelpa
 '(quelpa-use-package
   :fetcher git
   :url "https://github.com/quelpa/quelpa-use-package.git"))
(require 'quelpa-use-package)

(put 'narrow-to-region 'disabled nil)

;; Use use-package
(eval-when-compile
  (require 'use-package))
;; Less verbose.
(defalias 'yes-or-no-p 'y-or-n-p)
;; Some transparency
(set-frame-parameter (selected-frame) 'alpha '(85 . 85))
(add-to-list 'default-frame-alist '(alpha . (85 . 85)))
;; Add lisp directory to where emacs will search for lisp code.
(add-to-list 'load-path (concat user-emacs-directory "lisp/"))
;; Do not put things in the kill ring in the X clipboard.
(setq x-gtk-use-system-tooltips nil)     

;; font
(add-to-list 'default-frame-alist
	         '(font . "Iosevka:size=18"))
;; Change "lambda" to lambda symbol.
(use-package prettify-symbols-mode
  :init 
  (defconst lisp--prettify-symbols-alist
    '(("lambda"  . ?λ)))
  :hook
  (lisp-mode))

;; Add directory to look for themes.
(add-to-list 'load-path (concat user-emacs-directory "/themes/"))
(setq custom-safe-themes t)   ; Treat all themes as safe
;; Add these color themes.
(quelpa
 '(replace-colorthemes
   :fetcher git
   :url "https://github.com/emacs-jp/replace-colorthemes"))
;; Modus vivendi.
(use-package modus-themes
  :ensure t
  :init
  (setq modus-themes-bold-constructs t
        modus-themes-mode-line '3d
        modus-themes-italic-constructs t
        modus-themes-mixed-fonts nil
        modus-themes-subtle-line-numbers nil
        modus-themes-intense-markup t)

  (modus-themes-load-themes)
  (modus-themes-load-vivendi))

;; Basic settings.
(use-package rainbow-delimiters
  :ensure t
  :hook (prog-mode . rainbow-delimiters-mode))

(save-place-mode 1) 
(setq tty-menu-open-use-tmm t)
(global-set-key [f10] 'tmm-menubar)
(put 'upcase-region 'disabled nil)
(electric-pair-mode t)
(show-paren-mode 1)
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)
(setq column-number-mode t)
(display-time-mode 1)

(setq vc-follow-symlinks t) ; Otherwise emacs asks
(setq tramp-terminal-type "tramp") ; See zshrc
(add-hook 'after-save-hook #'executable-make-buffer-file-executable-if-script-p)
(setq-default truncate-lines t)

;;; Scroll settings.
;; scroll one line at a time (less "jumpy" than defaults)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll window under mouse

(use-package good-scroll
  :ensure t
  :init
  (good-scroll-mode 1))

(use-package smooth-scrolling
  :ensure t
  :init
  (setq smooth-scroll-margin 1) 
  (smooth-scrolling-mode 1))
;; Do not jump scroll
(setq auto-window-vscroll nil)
(setq scroll-conservatively 10)
(setq scroll-margin 1)

;; Column 80 fill line.
(setq display-fill-column-indicator-column 80)
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)


(setenv "MANWIDTH" "100") ; For man mode

;;; IDE settings.

(use-package conf-mode
  :init
  (add-to-list 'auto-mode-alist '("/sxhkdrc\\'" . conf-unix-mode))
  (add-to-list 'auto-mode-alist '("/zshrc\\'" . shell-script-mode))
  (add-to-list 'auto-mode-alist '("\\config\\'" . conf-mode))
  (add-to-list 'auto-mode-alist '("\\.Xdefaults'" . conf-xdefaults-mode))
  (add-to-list 'auto-mode-alist '("\\.Xresources'" conf-xdefaults-mode))
  (add-to-list 'auto-mode-alist '("\\.Xdefaults'" . conf-xdefaults-mode)))


(use-package systemd
  :ensure t
  :mode (("\\.service\\'" . systemd-mode)))

(use-package fish-mode
  :ensure t
  :mode (("\\.fish\\'" . fish-mode)))

(use-package rust-mode
  :ensure t
  :mode (("\\.rs\\'" . rust-mode)))

(use-package undo-tree
  :ensure t)
(use-package highlight
  :ensure t)

(use-package markdown-mode
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))

(use-package org
  :init 
  (setq org-src-preserve-indentation nil 
        org-edit-src-content-indentation 0)
  (require 'org-tempo)
  (add-hook 'org-mode-hook 'toggle-truncate-lines)

  (setq org-src-tab-acts-natively t)
  :bind (:map org-mode-map
              ("M-S-<up>" . 'text-scale-increase)
              ("M-S-<down>" . 'text-scale-decrease)))

(use-package org-indent-mode
  :config
  (org-indent-mode t)
  :hook org-mode)

(use-package org-bullets
  :ensure t)

(use-package wc-mode
  :ensure t
  :hook org-mode)


(use-package display-line-numbers-mode
  :hook (prog-mode org-mode LaTex-mode)
  :init
  (setq display-line-numbers-type 'relative))


(when (and module-file-suffix (not (eq system-type 'windows-nt)))
  (use-package vterm
    :ensure t
    :init (setq vterm-always-compile-module t)
    :bind (:map vterm-mode-map
                ("M-c" . 'vterm-copy-mode)
                ("M-i" . 'ido-switch-buffer))))


(use-package ivy
  :ensure t
  :init
  (use-package swiper
    :ensure t)
  (use-package counsel
    :ensure t)
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq enable-recursive-minibuffers t)
  ;; TODO cua-bindings for ivy
    (global-key-binding (kbd "C-f") nil))

(use-package company
  :ensure t
  :init (add-hook 'prog-mode-hook 'company-mode)
  :bind (:map company-active-map
              ("C-n" . company-select-next)
              ("C-p" . company-select-previous))
  :config
  (setq company-idle-delay 0.3)
  (setq company-tooltip-align-annotations t) ; aligns annotation to the right hand side
  (setq company-minimum-prefix-length 1)
  (setq company-clang-arguments '("-std=c++17"))
  (use-package company-c-headers
    :ensure t
    :init
    (add-to-list 'company-backends 'company-c-headers)))

(use-package flycheck
  :ensure t)

(use-package with-editor
  :ensure t)

(use-package magit
  :ensure t
  :init
  (add-hook 'diff-mode-hook #'whitespace-mode)
  (add-hook 'git-commit-setup-hook #'git-commit-turn-on-flyspell))

(defun insert-current-date ()
  (interactive)
  (insert (shell-command-to-string "echo -n $(date +%Y-%m-%d)")))

(use-package git-modes
  :ensure t
  :init
  (add-to-list 'auto-mode-alist '("\\.gitignore\\'" . gitignore-mode)) )

(use-package rainbow-mode
  :ensure t
  :hook (web-mode emacs-lisp-mode))

(use-package crontab-mode
  :ensure t)

(add-hook 'prog-mode-hook #'flyspell-prog-mode) ; Flyspell on comments and strings.

(use-package cmake-mode
  :ensure t)

(use-package web-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.api\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("/some/react/path/.*\\.js[x]?\\'" . web-mode))

  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-engines-alist
        '(("php"    . "\\.phtml\\'")
          ("blade"  . "\\.blade\\.")
          ("handlebars" . "\\.handlebars\\'")))

  (setq web-mode-content-types-alist
        '(("json" . "/some/path/.*\\.api\\'")
          ("xml"  . "/other/path/.*\\.api\\'")
          ("jsx"  . "/some/react/path/.*\\.js[x]?\\'")))
  (setq web-mode-markup-indent-offset 2)
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.handlebars\\'" . web-mode))
  (define-key web-mode-map (kbd "C-n") 'web-mode-tag-match)
  (setq web-mode-enable-current-column-highlight t)
  (setq web-mode-enable-current-element-highlight t)
  (setq web-mode-enable-auto-closing t))

(use-package impatient-mode
  :ensure t
  :hook web-mode)

(use-package emmet-mode
  :ensure t
  :config
  (define-key web-mode-map (kbd "C-j") 'emmet-expand-line)
  (emmet-mode)
                                        ;      (emmet-preview-mode)
  :hook web-mode)


(use-package cc-mode
  :config
  (setq c-default-style "linux"
        c-basic-offset 4)
  (c-set-offset 'inline-open '0))

(use-package json-mode
  :ensure t)

(use-package elpy
  :ensure t
  :init
  (add-hook 'python-mode-hook #'(lambda ()
                                  (elpy-enable)
                                  (when (require 'flycheck nil t)
                                    (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
                                    (add-hook 'elpy-mode-hook 'flycheck-mode)))))

(use-package blacken
  :ensure t)

(use-package py-autopep8
  :ensure t
  :init
  (add-hook 'elpy-mode-hook #'py-autopep8-enable-on-save))

(setq ispell-program-name (executable-find "hunspell"))
(setq ispell-local-dictionary "en_US")
(setq ispell-local-dictionary-alist
      '(("en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil nil nil utf-8)))

(add-hook 'org-mode-hook 'flyspell-mode)


(defun er-doas-edit (&optional arg)
  "Edit currently visited file as root With a prefix ARG prompt for a file to visit.  Will also prompt for a file to visit if current buffer is not visiting a file."
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/doas:root@localhost:"
                         (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/doas:root@localhost:" buffer-file-name))))



(defun er-sudo-edit (&optional arg)
  "Edit currently visited file as root With a prefix ARG prompt for a file to visit.  Will also prompt for a file to visit if current buffer is not visiting a file."
  (interactive "P")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:"
                         (ido-read-file-name "Find file(as root): ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(setq-default bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)
;; For slight performance increase with long lines.
(global-so-long-mode 1)

;; For asynchronous.
(use-package async
  :ensure t)


(use-package yasnippet
  :ensure t
  :init
  (require 'yasnippet)
  (yas-reload-all)
  (add-hook 'prog-mode-hook #'yas-minor-mode))

(use-package yasnippet-snippets
  :ensure t)

(quelpa
 '(rebinder
   :fetcher git
   :url "https://github.com/darkstego/rebinder.el"))

;; Set up CUA keybinds. Much better than cua-mode.
(require 'rebinder)

;; C-c to save.
(define-key global-map (kbd "C-d") (rebinder-dynamic-binding "C-c"))
(define-key rebinder-mode-map (kbd "C-c") #'kill-ring-save)
;; C-v to save.
(define-key rebinder-mode-map (kbd "C-v") #'yank)
;; C-x to cut.
(define-key global-map (kbd "C-l") (rebinder-dynamic-binding "C-x"))
(define-key rebinder-mode-map (kbd "C-x") #'kill-region)
;; C-a to select entire buffer.
;; TODO add in a Joe-like feature where the block is separate from
;; mark and point.
(define-key rebinder-mode-map (kbd "C-a") #'(lambda ()
                                              (interactive)
                                              (goto-char (point-min))
                                              (set-mark-command nil)
                                              (goto-char (point-max))))
;; C-f for swiper.
(define-key rebinder-mode-map (kbd "C-f") #'swiper)
;; C-z undo
(define-key rebinder-mode-map (kbd "C-z") #'undo-tree-undo)
;; C-y redo
(define-key rebinder-mode-map (kbd "C-y") #'undo-tree-redo)
;; C-s save
(define-key rebinder-mode-map (kbd "C-s") #'save-buffer)
;; C-h search-replace
(define-key global-map (kbd "M-h") (rebinder-dynamic-binding "C-h"))
(define-key rebinder-mode-map (kbd "C-h") #'replace-string)
;; C-o Open file.
;; TODO maybe find file in external window.
(define-key rebinder-mode-map (kbd "C-o") #'find-file)
;; C-n Open file.
;; TODO maybe find file in external window.
(define-key rebinder-mode-map (kbd "C-n") #'find-file)
;; C-w close the buffer.
(define-key rebinder-mode-map (kbd "C-w") #'kill-buffer)
;; Alt-F4 quit.
(define-key rebinder-mode-map (kbd "<M-f4>") #'kill-emacs)

;; TODO bookmark stack.


;; TODO rebind select paragraph.

(rebinder-hook-to-mode 't 'after-change-major-mode-hook)

(provide '.emacs)
;;; .emacs ends here
