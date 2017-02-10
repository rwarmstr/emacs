(require 'package)

(if (string-prefix-p system-name "x")
    (setq url-proxy-services
      '(("no_proxy" . "^\\(localhost\\|10.*\\)")
        ("http" . "proxy:8080")
        ("https" . "proxy:8080"))))

(add-to-list 'package-archives
	     '("melpa" . "http://melpa.org/packages/") t)

(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(defvar myPackages
  '(better-defaults
    material-theme
    smart-tabs-mode
    dts-mode
    multi-term
    flycheck
    flycheck-color-mode-line
    elpy
    magit
    bitbake
    company
    irony
    company-irony
    company-irony-c-headers
    company-c-headers
    aggressive-indent
    fill-column-indicator
    use-package
    projectile
    yasnippet))

(mapc #'(lambda (package)
	  (unless (package-installed-p package)
	    (package-install package)))
      myPackages)

;; Basic initialization
(setq inhibit-startup-message t)
(show-paren-mode 1)
(column-number-mode 1)

;; Enable smart tabs more for C, C++, and JavaScript
(smart-tabs-insinuate 'c 'c++ 'javascript)

(setq c-default-style '((java-mode . "java") (awk-mode . "awk") (other . "k&r"))
      c-basic-offset 8
      tab-width 8)

(global-set-key (kbd "<f5>") 'whitespace-mode)

(server-start)

;; Redirect standard backup files
(make-directory "~/.saves" t)

(setq backup-directory-alist '((".*" . "~/.saves")))
(setq auto-save-file-name-transforms
      '((".*" "~/.saves/\\1" t)))

(message "Deleting old backup files...")
(let ((week (* 60 60 24 7))
      (current (float-time (current-time))))
  (dolist (file (directory-files "~/.saves" t))
    (when (and (backup-file-name-p file)
	       (> (- current (float-time (nth 5 (file-attributes file))))
		  week))
      (message "%s" file)
      (delete-file file))))

(load-theme 'material t)

(elpy-enable)

(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; Setup irony mode
(use-package irony
  :ensure t
  :defer t
  :init
  (add-hook 'c++-mode-hook 'irony-mode)
  (add-hook 'c-mode-hook 'irony-mode)
  (add-hook 'objc-mode-hook 'irony-mode)

  :config
  (defun my-irony-mode-hook ()
    (define-key irony-mode-map [remap completion-at-point]
      'irony-completion-at-point-async)
    (define-key irony-mode-map [remap complete-symbol]
      'irony-completion-at-point-async))
  (add-hook 'irony-mode-hook 'my-irony-mode-hook)
  (add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
  )

(use-package company
  :ensure t
  :defer t
  :init (add-hook 'after-init-hook 'global-company-mode)

  :config
  (use-package company-irony :ensure t :defer t)
  (use-package company-irony-c-headers :ensure t :defer t)
  (setq company-idle-delay nil
        company-minimum-prefix-length 2
        company-show-numbers t
        company-tooltip-limit 20
        company-dabbrev-downcase nil
        company-backends '((company-c-headers company-irony company-gtags))
        )
  :bind ("C-;" . company-complete-common)
  )

;;(add-to-list 'company-backends 'company-c-headers)

;; Global formatting configuration
(aggressive-indent-global-mode)		;; Enable aggressive indent everywhere

;; configure projectile
(projectile-global-mode)

;; Configure FCI
(setq-default fci-rule-column 80)	;; Show column ruler at 80 chars
(setq fci-handle-truncate-lines nil)
(defun auto-fci-mode (&optional unused)
  (if (and
       (not (string-match "^\*.*\*$" (buffer-name)))
       (not (eq major-mode 'dired-mode))
       (not (eq major-mode 'terminal-mode)))
      (if (> (window-width) fci-rule-column) 
          (fci-mode 1)
        (fci-mode 0))
    (fci-mode 0)
    ))
(add-hook 'after-change-major-mode-hook 'auto-fci-mode)
(add-hook 'window-configuration-change-hook 'auto-fci-mode)
(add-hook 'c-mode-hook 'fci-mode)
(add-hook 'c++-mode-hook 'fci-mode)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(dired-auto-revert-buffer (quote dired-directory-changed-p))
 '(dired-dwim-target t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(global-set-key (kbd "C-x <up>") 'windmove-up)
(global-set-key (kbd "C-x <down>") 'windmove-down)
(global-set-key (kbd "C-x <left>") 'windmove-left)
(global-set-key (kbd "C-x <right>") 'windmove-right)

(global-set-key (kbd "C-x g") 'magit-status)

;; Enable yasnippet
(require 'yasnippet)
(yas-global-mode 1)
