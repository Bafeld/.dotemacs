;; The default is 800  kilobytes. Measured in bytes.
(setq gc-cons-threshold  (* 50 1000 1000))

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
                              (time-subtract after-init-time before-init-time)))
                     gcs-done)))

;; Initialize package sources
(require 'package)

(setq package-archives  '(("melpa" . "https://melpa.org/packages/")
                          ("org" . "https://orgmode.org/elpa/")
                          ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

;; Refresh package contents unless they already exist
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize `use-package'
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

(global-set-key (kbd "C-M-u") 'universal-argument)

(defun bf/evil-hook ()
  ;; Make these modes start in emacs mode
  (dolist (mode '(custom-mode
                  term-mode
                  eshell-mode
                  git-rebase-mode
                  erc-mode
                  circe-server-mode
                  circe-chat-mode
                  circe-query-mode
                  sauron-mode
                  vterm-mode))
    (add-to-list 'evil-emacs-state-modes mode)))

(defun bf/dont-arrow-me-bro ()
  "Stop using the arrow keys"
  (interactive)
  (message "Arrow keys are bad, you know?"))

(use-package undo-tree
  :config
  (global-undo-tree-mode 1))

(use-package evil
  :demand t
  :init
  (setq evil-undo-system 'undo-tree)
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-want-C-i-jump nil)
  (setq evil-respect-visual-line-mode t)
  :hook (evil-mode . bf/evil-hook)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map  (kbd "C-g") 'evil-normal-state)

  ;; Use visual line motions even outside of visual-line-mode buffers
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  (define-key evil-normal-state-map (kbd "<left>")  'bf/dont-arrow-me-bro)
  (define-key evil-normal-state-map (kbd "<right>")  'bf/dont-arrow-me-bro)
  (define-key evil-normal-state-map (kbd "<down>")  'bf/dont-arrow-me-bro)
  (define-key evil-normal-state-map (kbd "<up>")  'bf/dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<left>") 'bf-dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<right>") 'bf-dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<down>") 'bf-dont-arrow-me-bro)
  (evil-global-set-key 'motion (kbd "<up>") 'bf-dont-arrow-me-bro)

  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-numbers
  :after evil
  :bind (:map evil-normal-state-map
              ("C-c +" . evil-numbers/inc-at-pt)
              ("C-c -" . evil-numbers/dec-at-pt)))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.3))

(use-package general
  :config
  (defun bf/find-user-init-file ()
    "Edit the `user-init-file', in the same window."
    (interactive)
    (find-file "~/.emacs.d/init.org"))

  (defun bf/load-user-init-file ()
    "Reload the `user-init-file'."
    (interactive)
    (load-file user-init-file))

  (defun bf/split-window-horizontally ()
    "Split the window horizontally and select it."
    (interactive)
    (split-window-horizontally)
    (evil-window-right 1))

  (defun bf/split-window-vertically ()
    "Split the window vertically and select it."
    (interactive)
    (split-window-vertically)
    (evil-window-down 1))

  (defun bf/kill-buffer ()
    "Kill the current buffer"
    (interactive)
    (kill-buffer))

  (general-create-definer bf/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (bf/leader-keys
    ;; misc
    "'" 'vterm
    "o" 'org-agenda-list

    ;; Applications
    "a" '(:ignore t :which-key "applications")
    "ad" 'dired
    "ac" 'calendar
    "ao" 'org-agenda

    ;; Toggles
    "t" '(:ignore t :which-key "toggles")
    "tw" 'whitespace-mode
    "tt" '(counsel-load-theme :which-key "choose theme")

    ;; Comments
    "c" '(:ignore t :which-key "comments")
    "cl" 'evilnc-comment-or-uncomment-lines

    ;; Files
    "f" '(:ignore t :which-key "files")
    "ff" 'counsel-find-file
    "fe" '(:ignore t :which-key "emacs")
    "fed" '(bf/find-user-init-file :which-key "edit-emacs-config")
    "feR" '(bf/load-user-init-file :which-key "reload-emacs-config")

    ;; Buffers
    "b" '(:ignore t :which-key "buffers")
    "bb" 'counsel-switch-buffer
    "bk" '(bf/kill-buffer :which-key "kill-buffer")
    "bd" 'kill-buffer-and-window
    "bl" 'buffer-menu

    ;; Windows
    "w" '(:ignore t :which-key "windows")
    "w-" '(bf/split-window-vertically :which-key "split-window-vertically")
    "w/" '(bf/split-window-horizontally :which-key "split-window-horizontally")
    "ww" 'other-window
    "wh" 'evil-window-left
    "wj" 'evil-window-down
    "wk" 'evil-window-up
    "wl" 'evil-window-right
    "wd" 'evil-window-delete
    ))

(use-package dired
  :ensure nil
  :commands (dired dired-jump)
  :bind (("C-x C-j" . dired-jump))
  :custom  ((dired-listing-switches "-agho --group-directories-first"))
  :config
  (evil-collection-define-key 'normal 'dired-mode-map
    "h" 'dired-up-directory
    "l" 'dired-find-file))

;; Turn off automatic backups
(setq make-backup-files nil)

;; Turn off the startup message
(setq inhibit-startup-message t)

;; Make window dividers show on bottom and the right
;(setq window-divider-default-places t)

(window-divider-mode 1)  ; Turn on window dividers
(electric-pair-mode 1)   ; Turn on bracket completion
(scroll-bar-mode -1)     ; Turn off the scroll bar
(tool-bar-mode -1)       ; Turn off the tool bar
(tooltip-mode -1)        ; Turn off tool-tips
(set-fringe-mode 10)     ; Set the fringe
(menu-bar-mode -1)       ; Turn off the menu bar
(global-hl-line-mode 1)  ; Turn on line highlighting
(setq visible-bell t)    ; Turn on the visible bell

(setq mouse-wheel-scroll-amount '(1 ((shift) . 1))) ;; one line at a time
(setq mouse-wheel-progressive-speed nil) ;; don't accelerate scrolling
(setq mouse-wheel-follow-mouse 't) ;; scroll the window under the mouse
(setq scroll-step 1) ;; keyboard scroll one line at a time

(column-number-mode)

;; Enable line numbers for some modes
(dolist (mode '(text-mode-hook
                prog-mode-hook
                conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))

;; Override some modes which derive from the above
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(use-package doom-themes :defer t)
(load-theme 'doom-gruvbox t)
;;(doom-themes-visual-bell-config)
(use-package all-the-icons)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(global-auto-revert-mode 1)

(winner-mode)

(use-package treemacs
  :defer t)

(use-package treemacs-evil
  :after treemacs evil)

(use-package treemacs-icons-dired
  :after treemacs dired
  :config
  (treemacs-icons-dired-mode))

(setq-default tab-width 2)
(setq-default  evil-shift-width tab-width)

(setq-default indent-tabs-mode nil)

(use-package evil-nerd-commenter)

(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)	
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))
  
(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(defun bf/org-mode-setup ()
  (org-indent-mode)
  (auto-fill-mode 0)
  (visual-line-mode 1)
  (setq evil-auto-indent nil))

(use-package org
  :hook (org-mode . bf/org-mode-setup)
  :config
  (setq org-ellipsis "⮟")
  (setq org-hide-emphasis-markers t)

  (setq org-agenda-files
    '("~/OrgFiles/systemcrafters.org"))

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode))

;; Type <el to get a source block for emacs lisp and so on   
(require 'org-tempo)
(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

(defun bf/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name "~/.emacs.d/"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'bf/org-babel-tangle-config)))

(defun bf/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode  1))

(use-package visual-fill-column
  :hook (org-mode . bf/org-mode-visual-fill))

(use-package vterm
  :commands vterm
  :config
  (setq vterm-max-scrollback 10000))

(use-package command-log-mode
  :config
  (global-command-log-mode))

(defun bf/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . bf/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l") ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy)

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
              ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
              ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

;; (use-package yasnippet
;;   :after lsp
;;   :config
;;   (yas-global-mode))

;; (use-package yasnippet-snippets
;;   :after yasnippet)

(use-package flycheck
  :init (global-flycheck-mode))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :hook (typescript-mode . lsp-deferred)
  :config
  (setq typescript-indent-level 2)
  (require 'dap-node)
  (dap-node-setup)) ;; Automatically installs Node debug adapter if needed

(use-package lsp-java
  :hook (java-mode . lsp-deferred)
  :config
  (require 'dap-java))

(use-package lsp-python-ms
  :init (setq lsp-python-ms-auto-install-server t)
  :hook (python-mode . (lambda ()
                         (require 'lsp-python-ms)
                         (lsp-deferred)))
  :custom
  (dap-python-debugger 'debugpy)
  :config
  (require 'dap-python))

(use-package pyvenv
  :config
  (pyvenv-mode 1))

(use-package dap-mode)
