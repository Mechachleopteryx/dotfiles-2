;; convenient list- and functional-related macros
(use-package dash)

;; used in some (third-party) custom themes
;; (not sure if there's a better way to indicate this dependency)
(use-package autothemer)

;; intuitive "state machine" menus
(use-package hydra)

(use-package dictionary)

(use-package my-python
  :after general)

(use-package my-python
  :after general)

(use-package php-mode)

(use-package tex
  :defer t
  :ensure auctex)

;; ido mode
(use-package ido
  ;; disabled since using ivy
  :disabled t
  :config
  (setq ido-enable-flex-matching t)
  (setq ido-everywhere t)
  (ido-mode 1))

(use-package sublimity
  :disabled t
  :config
  (sublimity-mode 1))

(use-package minimap
  :disabled t)

(use-package company
  :config
  ;; enable company mode autocompletion in all buffers
  (global-company-mode 1))

(use-package company-jedi)

(use-package ivy
  ;; company is for in-buffer auto-completion,
  ;; ivy is for application-level on-demand completion
  :config
  (ivy-mode 1)
  ;; use fuzzy-style matching in all cases except swiper (from SX)
  ;; (setq ivy-re-builders-alist
  ;; 	'((swiper . ivy--regex-plus)
  ;; 	  (t . ivy--regex-fuzzy)))
  (setq ivy-use-virtual-buffers t)
  (setq ivy-wrap t))

(use-package counsel
  :bind ("M-x" . counsel-M-x)
  :bind ("C-c k" . counsel-unicode-char)
  :config
  (counsel-mode 1))

(use-package swiper
  :bind ("C-s" . swiper))

(use-package ivy-hydra)

(use-package ivy-rich
  :config
  (ivy-rich-mode t))

;; looks like smex (smart command history in M-x) is used by counsel just
;; by being installed, and doesn't need to be explicitly invoked here
(use-package smex
  :config
  (smex-initialize))

(use-package magit
  :config
  ;; use side-by-side view for blame -- this doesn't work atm
  ;; (setq magit-blame--style (nth 1 magit-blame-styles))
  (define-key (current-global-map)
              (kbd "C-x g")
              'magit-status)
  (define-key (current-global-map)
              (kbd "C-x M-g")
              'magit-dispatch-popup))

(use-package tabbar
  :disabled t
  :config
  ;; turn on the tabbar
  (tabbar-mode t)
  (define-key (current-global-map)
              (kbd "s-{")
              'tabbar-backward)
  (define-key (current-global-map)
              (kbd "s-}")
              'tabbar-forward))

(use-package evil-tabs
  :disabled t
  :config
  (global-evil-tabs-mode t))

(use-package evil-matchit
  :config
  (global-evil-matchit-mode 1))

;; not sure why this is necessary, but this initializes sunrise
;; commander, along with all of its extensions
(el-get-bundle sunrise-commander)

(use-package recentf
  :config
  (recentf-mode t)
  (setq recentf-max-menu-items 25))

(use-package popwin
  :disabled t
  :config
  (popwin-mode t))

(use-package ibuffer
  ;; replace oldschool buffer-list, as recommended here:
  ;; http://martinowen.net/blog/2010/02/03/tips-for-emacs-ibuffer.html
  :bind ("C-x C-b" . ibuffer)
  :init
  (add-hook 'ibuffer-mode-hook
	    '(lambda ()
	       (ibuffer-auto-mode 1)))
	       ;;(ibuffer-switch-to-saved-filter-groups "default"))))
  :config
  (setq ibuffer-show-empty-filter-groups nil))

(use-package ibuffer-vc
  ;; organize buffers by version-controlled repo
  ;; note: there's projectile-ibuffer
  :disabled t
  :init
  ;; TODO: C-k doesn't go up filter groups as expected
  ;; (add-hook 'ibuffer-hook
  ;;           (lambda ()
  ;;             (define-key
  ;;               (current-local-map)
  ;;               (kbd "C-k")
  ;;               'ibuffer-backward-filter-group)))
  (add-hook 'ibuffer-hook
	    (lambda ()
	      (ibuffer-vc-set-filter-groups-by-vc-root)
	      (unless (eq ibuffer-sorting-mode 'alphabetic)
            (ibuffer-do-sort-by-alphabetic)))))

(use-package ibuffer-sidebar
  :disabled t
  :commands (ibuffer-sidebar-toggle-sidebar)
  :bind ("C-c b" . ibuffer-sidebar-toggle-sidebar)
  :config
  (setq ibuffer-sidebar-use-custom-font t)
  (setq ibuffer-sidebar-face `(:family "Helvetica" :height 140)))

(use-package smart-mode-line
  :disabled t
  :config
  (sml/setup)
  (setq sml/theme 'dark))

(use-package telephone-line
  :config
  (telephone-line-mode t))

;; cozy time
(use-package fireplace)

;; virtual caps lock since actual one is remapped to Esc
(use-package caps-lock)

(use-package ace-window
  :disabled t
  :bind ("s-w" . ace-window)
  :config
  (setq aw-keys '(?h ?j ?k ?l ?g ?f ?d ?s ?a)))


;;;;;;;;;;;;;;;;;;
;; CUSTOM MODES ;;
;;;;;;;;;;;;;;;;;;


(use-package my-buffer-mode)


;;;;;;;;;;;;;;;;;;;;;;
;; CUSTOM FUNCTIONS ;;
;;;;;;;;;;;;;;;;;;;;;;


(defun my-count-lines-page ()
  "Modified from emacs's built-in count-lines-page to return a list of
   values corresponding to the position in the page."
  (interactive)
  (save-excursion
    (let ((opoint (point)) beg end
	  total before after)
      (forward-page)
      (beginning-of-line)
      (or (looking-at page-delimiter)
	  (end-of-line))
      (setq end (point))
      (backward-page)
      (setq beg (point))
      (setq total (count-lines beg end)
	    before (count-lines beg opoint)
	    after (count-lines opoint end))
      (list total before after))))

(defun my-buffer-info ()
  "get info on current buffer -- similar to Vim's C-g"
  (interactive)
  (-let [(total before after) (my-count-lines-page)]
    (if (= total 0)
	(setq bufinfo (list "-- No lines in buffer --"))
      (progn (setq percentage (floor (* (/ (float before)
					   total)
					100)))
	     (setq page-position (concat
				  "-- "
				  (number-to-string percentage)
				  "%"
				  " --"))
	     (setq total-lines (concat
				(number-to-string total)
				" lines"))
	     (setq bufinfo (list total-lines page-position))))
    (add-to-list 'bufinfo
		 (buffer-file-name))
    (message "%s" (string-join bufinfo " "))))

(defun xah-new-empty-buffer ()
  "Create a new empty buffer.
   New buffer will be named “untitled” or “untitled<2>”, “untitled<3>”, etc.

   It returns the buffer (for elisp programing).

   URL `http://ergoemacs.org/emacs/emacs_new_empty_buffer.html'
   Version 2017-11-01"
  (interactive)
  (let (($buf (generate-new-buffer "untitled")))
    (switch-to-buffer $buf)
    (funcall (default-value 'major-mode))
    (setq buffer-offer-save t)
    $buf))

(defun my-lisp-repl ()
  (interactive)
  (evil-window-vsplit)
  (evil-window-right 1)
  (ielm))


(use-package general
  ;; general is a package that provides various
  ;; resources and utilities for defining keybindings
  :config
  (setq general-override-states '(insert
                                  emacs
                                  hybrid
                                  normal
                                  visual
                                  motion
                                  operator
                                  replace))
  (general-override-mode)

  (defhydra hydra-leader (:idle 1.0
                          :columns 2
                          :exit t)
    "Quick actions"
    ("a" org-agenda "Org agenda")
    ("d" dictionary-lookup-definition "lookup in dictionary")
    ("g" magit-status "Magit (git)")
    ("l" my-lisp-repl "Lisp REPL")
    ("s" eshell "Shell")
    ("t" sr-speedbar-toggle "Nav Sidebar")
    ("u" undo-tree-visualize "Undo tree"))

  (general-define-key
   :states '(normal visual motion)
   :keymaps 'override
   "SPC" 'hydra-leader/body))

(use-package my-familiar
  :after evil)

(use-package my-general-behavior)

(use-package my-look-and-feel)


;;;;;;;;;;;;;;;;;;;;;;;;
;; CUSTOM KEYBINDINGS ;;
;;;;;;;;;;;;;;;;;;;;;;;;


;; map Mac's Command key to Emacs/Lisp's Super key
(setq mac-command-modifier 'super)
;; make Fn key do Hyper [coz, why not]
(setq mac-function-modifier 'hyper)

; Note: "define-key (current-global-map)" is the same as global-set-key

;; default "emacs leader" is \, but rebinding that (Vim default) key
;; to be a local leader for different modes (like python) since that's
;; more useful. Move emacs leader to s-\ instead
(global-set-key (kbd "s-\\") 'evil-execute-in-emacs-state)

(define-key
  ;; info on the current buffer
  (current-global-map)
  (kbd "C-c b")
  'my-buffer-info)

(define-key
  ;; navigation sidebar
  (current-global-map)
  (kbd "C-c t")
  'sr-speedbar-toggle)

(define-key
  ;; open a new empty buffer
  (current-global-map)
  (kbd "C-c n")
  'xah-new-empty-buffer)

(define-key
  ;; drop into a shell (preserves path)
  (current-global-map)
  (kbd "C-c s")
  'eshell)

(define-key
  ;; lookup in dictionary
  (current-global-map)
  (kbd "C-c d")
  'dictionary-lookup-definition)

(define-key
  ;; open an elisp shell
  (current-global-map)
  (kbd "C-c l")
  'my-lisp-repl)

(define-key
  ;; emulate caps lock -- alternative to an actual CAPS LOCK key
  (current-global-map)
  (kbd "C-<escape>")
  'caps-lock-mode)

(define-key
  ;; calculator mode
  (current-global-map)
  (kbd "C-+")
  'calc)


;;;;;;;;;;;;;;;;;
;; HYDRA MENUS ;;
;;;;;;;;;;;;;;;;;


(defun current-transparency ()
  (nth 0
       (frame-parameter (selected-frame)
			'alpha)))

;; Set transparency of emacs
(defun transparency (value)
 "Sets the transparency of the frame window. 0=transparent/100=opaque"
 (interactive "nTransparency Value 0 - 100 opaque:")
 (set-frame-parameter (selected-frame) 'alpha (cons value value)))

(defun adjust-transparency (delta)
  "Adjust the transparency of the frame window by the configured delta,
   in the range: 0=transparent/100=opaque"
  (interactive)
  (transparency (+ (current-transparency)
		   delta)))

(defun increase-transparency ()
  "Increase frame transparency."
  (interactive)
  (adjust-transparency -3))

(defun decrease-transparency ()
  "Decrease frame transparency."
  (interactive)
  (adjust-transparency 3))

(defun maximize-transparency ()
  "Maximize frame transparency (i.e. make transparent)"
  (interactive)
  (transparency 0))

(defun minimize-transparency ()
  "Minimize frame transparency (i.e. make opaque)"
  (interactive)
  (transparency 100))

(defun return-to-original-transparency ()
  "Return to original transparency prior to making changes."
  (interactive)
  (transparency original-transparency))

(defhydra hydra-transparency (:columns 1
                              :body-pre (setq original-transparency
                                              (current-transparency)))
  "Control frame transparency"
  ("+" decrease-transparency "decrease transparency")
  ("-" increase-transparency "increase transparency")
  ("k" decrease-transparency "decrease transparency")
  ("j" increase-transparency "increase transparency")
  ("K" minimize-transparency "min transparency (opaque)")
  ("J" maximize-transparency "max transparency (transparent)")
  ("q" return-to-original-transparency  "return to original transparency" :exit t)
  ("<escape>" my-noop "quit" :exit t))

(defhydra hydra-application (:columns 1
                             :exit t)
  "Control application environment"
  ("t" hydra-transparency/body "transparency")
  ("n" display-line-numbers-mode "toggle line numbers")
  ("l" hl-line-mode "toggle highlight line"))

;; hydra to configure the application environment
;; contains a nested hydra to modulate transparency
(global-set-key (kbd "s-e") 'hydra-application/body)
