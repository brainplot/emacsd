(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

(let ((local-package-list '(doom-themes
                            company
                            counsel
                            dired-sidebar
                            diredfl
                            eglot
                            emmet-mode
                            expand-region
                            fish-mode
                            gitattributes-mode
                            gitconfig-mode
                            gitignore-mode
                            google-this
                            magit
                            markdown-mode
                            move-text
                            multiple-cursors
                            powershell
                            rainbow-delimiters
                            rust-mode
                            use-package
                            yaml-mode
                            yasnippet
                            yasnippet-snippets)))
  (when (eq system-type 'gnu/linux)
    (push 'pinentry local-package-list))
  (when (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
    (push 'ninja-mode local-package-list))
  (package--save-selected-packages local-package-list))

(when (or (eq system-type 'windows-nt) (eq system-type 'ms-dos))
  (push (let ((cmake-info (with-temp-buffer
                            (cons (call-process "WHERE" nil t nil "cmake.exe") (buffer-string)))))
          (when (eq 0 (car cmake-info))
            (let* ((cmake-version-string (shell-command-to-string "cmake.exe /V"))
                   (cmake-asset-dir (concat "/cmake-"
                                            (substring cmake-version-string
                                                       (string-match "[0-9]+\\.[0-9]+" cmake-version-string 14)
                                                       (match-end 0)))))
              (expand-file-name
               (concat "../share" cmake-asset-dir "/editors/emacs")
               (file-name-directory (cdr cmake-info))))))
        load-path))

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package doom-themes
  :init
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  :config
  (load-theme 'doom-vibrant t)
  (doom-themes-org-config))

(use-package eglot
  :bind (("C-c l" . eglot)
         :map eglot-mode-map
         ("C-c f" . eglot-format)
         ("C-c <f4>" . eglot-shutdown))
  :config
  (push 'company eglot-stay-out-of)
  (push '(c++-mode . ("clangd" "--background-index" "--compile-commands-dir=build"
                      "--header-insertion=never" "--pch-storage=memory" "-j=6"))
        eglot-server-programs))

(use-package git-commit)

(use-package gitignore-mode
  :mode ("\\.dockerignore\\'"))

(use-package gitconfig-mode
  :defer t)

(use-package gitattributes-mode
  :defer t)

(use-package magit
  :custom
  (magit-commit-show-diff nil)
  :bind (("C-x g" . magit-status)
         ("C-c g" . magit-file-dispatch)))

(use-package company
  :demand
  :bind (:map company-active-map
              ("RET")
              ("<return>")
              ("M-p")
              ("M-n")
              ("C-p" . (lambda () (interactive) (company-complete-common-or-cycle -1)))
              ("C-n" . (lambda () (interactive) (company-complete-common-or-cycle)))
              ("<tab>" . company-complete-selection))
  :custom
  (company-dabbrev-downcase nil)
  (company-idle-delay 0.2)
  (company-minimum-prefix-length 2)
  (company-backends '((company-capf :with company-yasnippet)
                      (company-semantic :with company-yasnippet)
                      (company-cmake :with company-yasnippet)
                      (company-dabbrev-code company-keywords)
                      company-dabbrev
                      company-files))
  :hook (after-init . global-company-mode))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package ivy
  :demand
  :custom
  (ivy-count-format "(%d/%d) ")
  (ivy-use-virtual-buffers t)
  (ivy-wrap t)
  :bind (("C-x b" . ivy-switch-buffer)
         ("C-c v" . ivy-push-view)
         ("C-c V" . ivy-pop-view))
  :config
  (ivy-mode 1))

(use-package swiper
  :after ivy
  :demand
  :bind ("C-s" . swiper-isearch))

(use-package counsel
  :after swiper
  :demand
  :bind (("M-x". counsel-M-x)
         ("C-x C-f". counsel-find-file)
         ("M-y". counsel-yank-pop)
         ("<f1> f". counsel-describe-function)
         ("<f1> v". counsel-describe-variable)
         ("<f1> l". counsel-find-library)
         ("<f2> i". counsel-info-lookup-symbol)
         ("<f2> u". counsel-unicode-char)
         ("<f2> j". counsel-set-variable)))

(use-package multiple-cursors
  :bind (("C-c m ^"     . mc/edit-beginnings-of-lines)
         ("C-c m `"     . mc/edit-beginnings-of-lines)
         ("C-c m $"     . mc/edit-ends-of-lines)
         ("C-c m '"     . mc/edit-ends-of-lines)
         ("C-c m R"     . mc/reverse-regions)
         ("C-c m S"     . mc/sort-regions)
         ("C-c m W"     . mc/mark-all-words-like-this)
         ("C-c m Y"     . mc/mark-all-symbols-like-this)
         ("C-c m a"     . mc/mark-all-like-this-dwim)
         ("C-c m c"     . mc/mark-all-dwim)
         ("C-c m l"     . mc/insert-letters)
         ("C-c m n"     . mc/insert-numbers)
         ("C-c m r"     . mc/mark-all-in-region)
         ("C-c m %"     . mc/mark-all-in-region-regexp)
         ("C-c m t"     . mc/mark-sgml-tag-pair)
         ("C-c m w"     . mc/mark-next-like-this-word)
         ("C-c m x"     . mc/mark-more-like-this-extended)
         ("C-c m y"     . mc/mark-next-like-this-symbol)
         ("C-c m C-SPC" . mc/mark-pop)
         ("C-c m ("     . mc/mark-all-symbols-like-this-in-defun)
         ("C-c m C-("   . mc/mark-all-words-like-this-in-defun)
         ("C-c m M-("   . mc/mark-all-like-this-in-defun)
         ("C-c m ["     . mc/vertical-align-with-space)
         ("C-c m {"     . mc/vertical-align)

         ("S-<down-mouse-1>")
         ("S-<mouse-1>" . mc/add-cursor-on-click)))

(use-package expand-region
  :bind ("C-=" . er/expand-region))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

(use-package pinentry
  :if (eq system-type 'gnu/linux)
  :config (pinentry-start))

(use-package cmake-mode
  :demand
  :hook (cmake-mode . indent-with-spaces))

(use-package rust-mode
  :hook (rust-mode . indent-with-spaces))

(use-package ninja-mode)

(use-package emmet-mode
  :custom
  (emmet-move-cursor-between-quotes t)
  :bind (:map emmet-mode-keymap
              ("<C-return>")
              ("<C-tab>" . emmet-expand-yas)
              ("C-M-p" . emmet-prev-edit-point)
              ("C-M-n" . emmet-next-edit-point))
  :hook (sgml-mode css-mode js-jsx-mode web-mode))

(use-package powershell
  :defer t)

(use-package yaml-mode
  :mode ("\\.clang-format\\'"))

(use-package move-text
  :bind (("M-p" . move-text-up)
         ("M-n" . move-text-down)))

(use-package diredfl
  :commands diredfl-mode
  :hook (dired-mode . diredfl-mode))

(use-package dired-sidebar
  :bind ("<f8>" . dired-sidebar-toggle-sidebar)
  :commands dired-sidebar-toggle-sidebar
  :init
  (add-hook 'dired-sidebar-mode-hook
            #'(lambda ()
                (toggle-scroll-bar -1)
                (unless (file-remote-p default-directory)
                  (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands))

(use-package google-this
  :defer t
  :config (google-this-mode 1))
