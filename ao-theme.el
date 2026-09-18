;;; ao-theme.el --- The AO theme, in dark and light variants -*- lexical-binding: t -*-

;; Copyright (C) 2026 Michael Jones

;; Author: Michael Jones <michael.jones.nzzn@use.startmail.com>
;; Maintainer: Michael Jones <michael.jones.nzzn@use.startmail.com>
;; URL: https://github.com/mjones/ao.theme
;; Version: 0.1.0
;; Package-Requires: ((emacs "28.1"))
;; Keywords: faces, theme, accessibility

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; AO is a pair of themes -- `ao-dark' and `ao-light' -- built around a
;; small set of signature colours:
;;
;;   * an amber accent (#ff9000) for the cursor, the active line number
;;     and matching parentheses;
;;   * a violet selection (#7533bd) for the region and for marked items;
;;   * a slate comment tone (#838a97) shared by both variants;
;;   * a steel-blue mode line that the tab bar mirrors.
;;
;; The dark variant sits on a deep navy ground (#080d15); the light
;; variant on a warm paper ground (#fbf7f0).  Both carry the same amber
;; and violet accents, so the two halves read as one theme.
;;
;; Usage:
;;
;;     (add-to-list 'custom-theme-load-path "/path/to/ao.theme")
;;     (add-to-list 'load-path "/path/to/ao.theme")
;;     (require 'ao-theme)
;;     (ao-theme-load-dark)          ; or (load-theme 'ao-dark t)
;;
;; `ao-theme-toggle' switches between the two variants and runs
;; `ao-theme-after-load-hook'.
;;
;; Colours can be adjusted without forking the theme, via
;; `ao-theme-common-palette-overrides' and the per-variant
;; `ao-theme-dark-palette-overrides' / `ao-theme-light-palette-overrides'.

;;; Code:

(eval-when-compile (require 'cl-lib))

(defgroup ao-theme nil
  "The AO theme, in dark and light variants."
  :group 'faces
  :prefix "ao-theme-"
  :tag "AO Theme")

;;;; User options

(defcustom ao-theme-bold-constructs nil
  "When non-nil, use bold for a few syntactic constructs.
Affects keywords, types, builtins and similar, via the `ao-theme-bold'
face.  Re-load the theme for a change to take effect."
  :group 'ao-theme
  :type 'boolean)

(defcustom ao-theme-italic-constructs nil
  "When non-nil, use italics for comments and doc strings.
Applied through the `ao-theme-slant' face.  Re-load the theme for a
change to take effect."
  :group 'ao-theme
  :type 'boolean)

(defcustom ao-theme-mixed-fonts nil
  "When non-nil, use a fixed-pitch font in code contexts inside prose.
Applies to Org blocks, tables, inline code and similar, through the
`ao-theme-fixed-pitch' face.  Only useful when the buffer itself uses a
variable-pitch font.  Re-load the theme for a change to take effect."
  :group 'ao-theme
  :type 'boolean)

(defcustom ao-theme-variable-pitch-ui nil
  "When non-nil, use a variable-pitch font for UI elements.
Applies to the mode line, the tab bar and the header line, through the
`ao-theme-ui-variable-pitch' face.  Re-load the theme for a change to
take effect."
  :group 'ao-theme
  :type 'boolean)

(defcustom ao-theme-to-toggle '(ao-dark ao-light)
  "The two themes that `ao-theme-toggle' cycles between."
  :group 'ao-theme
  :type '(list symbol symbol))

(defcustom ao-theme-after-load-hook nil
  "Hook run after an AO theme is loaded by this package's commands.
Run by `ao-theme-toggle', `ao-theme-load-dark' and
`ao-theme-load-light'.  A bare `load-theme' does not run it."
  :group 'ao-theme
  :type 'hook)

(defcustom ao-theme-common-palette-overrides nil
  "Palette overrides applied to both AO variants.
Each element is a list of (KEY VALUE), where KEY is a palette symbol
such as `cursor' and VALUE is either a colour string, the symbol
`unspecified', or another palette symbol to alias.  For example:

    (setq ao-theme-common-palette-overrides
          \\='((cursor \"#00ff00\")
            (bg-region bg-cyan-subtle)))

Re-load the theme for a change to take effect."
  :group 'ao-theme
  :type '(repeat (list symbol sexp)))

(defcustom ao-theme-dark-palette-overrides nil
  "Palette overrides applied to `ao-dark' only.
Same shape as `ao-theme-common-palette-overrides', and takes precedence
over it."
  :group 'ao-theme
  :type '(repeat (list symbol sexp)))

(defcustom ao-theme-light-palette-overrides nil
  "Palette overrides applied to `ao-light' only.
Same shape as `ao-theme-common-palette-overrides', and takes precedence
over it."
  :group 'ao-theme
  :type '(repeat (list symbol sexp)))

;;;; Palettes

(defconst ao-theme-dark-palette
  '(;;; The Ao palette, as defined by the Helix theme of the same name.
    ;; These are the raw colours; the semantic entries below alias them.
    (deep-abyss       . "#080d15")
    (moonlight-ocean  . "#0c1420")
    (midnight-thunder . "#0d1526")
    (nightfall-blue   . "#1f2937")
    (stormy-night     . "#254862")
    (twilight-blue    . "#2c5484")
    (pitch-black      . "#000000")
    (winter-sky       . "#f3f4f6")
    (ao-white         . "#dadada")
    (slate-gray       . "#838a97")
    (blaze-orange     . "#ff9000")
    (lemon-zest       . "#ffba00")
    (leafy-green      . "#81be83")
    (sky-blue         . "#45b1e8")
    (dreamy-blue      . "#6eb0ff")
    (crystal-blue     . "#99c7ff")
    (ruby-glow        . "#fa7970")
    (walnut-brown     . "#987654")
    (rustic-amber     . "#9d5800")
    (rustic-red       . "#540b0c")
    (slate-purple     . "#d2a8ff")
    (light-purple     . "#7533bd")
    (deep-purple      . "#4c1785")

    ;;; Ground and text
    (bg-main     . deep-abyss)
    (bg-dim      . midnight-thunder)
    (bg-alt      . nightfall-blue)
    (bg-active   . stormy-night)
    (bg-inactive . moonlight-ocean)
    (fg-main     . ao-white)
    (fg-dim      . slate-gray)
    (fg-alt      . winter-sky)
    (border      . pitch-black)
    (fg-divider  . slate-gray)

    ;;; Signature colours
    (accent    . blaze-orange)
    (selection . light-purple)
    (cursor    . blaze-orange)
    (comment   . slate-gray)

    ;;; Selection and current line
    (bg-region      . light-purple)
    (fg-region      . ao-white)
    (bg-mark-select . light-purple)
    (fg-mark-select . winter-sky)
    (bg-hl-line     . nightfall-blue)

    ;;; Fringe: Helix draws the gutter on the main background
    (bg-fringe . deep-abyss)
    (fg-fringe . ao-white)

    ;;; Mode line and tab bar (ui.statusline and ui.bufferline)
    (bg-mode-line-active       . twilight-blue)
    (fg-mode-line-active       . winter-sky)
    (border-mode-line-active   . twilight-blue)
    (bg-mode-line-inactive     . pitch-black)
    (fg-mode-line-inactive     . winter-sky)
    (border-mode-line-inactive . pitch-black)
    (bg-tab-bar     . pitch-black)
    (bg-tab-current . twilight-blue)
    (bg-tab-other   . pitch-black)
    (fg-tab-bar     . winter-sky)
    (fg-tab-dim     . slate-gray)
    (fg-tab-accent  . lemon-zest)

    ;;; Line numbers (ui.linenr and ui.gutter)
    (bg-line-number-active   . pitch-black)
    (fg-line-number-active   . blaze-orange)
    (bg-line-number-inactive . deep-abyss)
    (fg-line-number-inactive . slate-gray)

    ;;; Matching parentheses (ui.cursor.match): a dark chip with an orange
    ;;; glyph, which the block cursor inverts back into an orange block on
    ;;; the paren at point
    (bg-paren-match      . pitch-black)
    (fg-paren-match      . blaze-orange)
    (bg-paren-expression . blaze-orange)

    ;;; Menus, popups and hover (ui.menu and ui.popup)
    (bg-completion      . twilight-blue)
    (bg-hover           . stormy-night)
    (bg-hover-secondary . deep-purple)

    ;;; Search
    (bg-search-current . lemon-zest)
    (fg-search-current . deep-abyss)
    (bg-search-lazy    . twilight-blue)
    (fg-search-lazy    . winter-sky)
    (bg-search-replace . rustic-red)
    (fg-search-replace . winter-sky)

    ;;; Diagnostics (diagnostic.*)
    (bg-prominent-err     . rustic-red)
    (fg-prominent-err     . winter-sky)
    (bg-prominent-warning . rustic-amber)
    (fg-prominent-warning . winter-sky)
    (bg-prominent-note    . twilight-blue)
    (fg-prominent-note    . winter-sky)

    ;;; Character highlights
    (bg-char-0 . twilight-blue)
    (bg-char-1 . deep-purple)
    (bg-char-2 . rustic-amber)

    ;;; Arguments and whitespace (ui.virtual.whitespace)
    (bg-active-argument . "#3a2a12")
    (fg-active-argument . lemon-zest)
    (bg-space-err       . rustic-red)
    (fg-space           . stormy-night)

    ;;; Accent hues, mapped onto the Ao syntax colours
    (red             . ruby-glow)
    (red-warmer      . ruby-glow)
    (red-cooler      . ruby-glow)
    (red-faint       . walnut-brown)
    (red-intense     . ruby-glow)
    (green           . leafy-green)
    (green-warmer    . leafy-green)
    (green-cooler    . leafy-green)
    (green-faint     . leafy-green)
    (green-intense   . leafy-green)
    (yellow          . lemon-zest)
    (yellow-warmer   . lemon-zest)
    (yellow-cooler   . walnut-brown)
    (yellow-faint    . walnut-brown)
    (yellow-intense  . lemon-zest)
    (blue            . sky-blue)
    (blue-warmer     . dreamy-blue)
    (blue-cooler     . crystal-blue)
    (blue-faint      . dreamy-blue)
    (blue-intense    . sky-blue)
    (magenta         . slate-purple)
    (magenta-warmer  . slate-purple)
    (magenta-cooler  . slate-purple)
    (magenta-faint   . slate-purple)
    (magenta-intense . slate-purple)
    (cyan            . sky-blue)
    (cyan-warmer     . crystal-blue)
    (cyan-cooler     . crystal-blue)
    (cyan-faint      . dreamy-blue)
    (cyan-intense    . sky-blue)

    ;;; Accent backgrounds, tinted towards the navy ground
    (bg-red-subtle     . "#3a1416")
    (bg-green-subtle   . "#12301f")
    (bg-yellow-subtle  . "#3a2a12")
    (bg-blue-subtle    . "#12253a")
    (bg-magenta-subtle . "#2a1740")
    (bg-cyan-subtle    . "#10303a")
    (bg-red-intense     . rustic-red)
    (bg-green-intense   . "#2f6b3a")
    (bg-yellow-intense  . "#6b3d00")
    (bg-blue-intense    . twilight-blue)
    (bg-magenta-intense . deep-purple)
    (bg-cyan-intense    . "#1a5a78")

    ;;; Diffs
    (bg-added          . "#12301f")
    (bg-added-faint    . "#0d2417")
    (bg-added-refine   . "#1b4a2e")
    (fg-added          . leafy-green)
    (bg-removed        . "#3a1416")
    (bg-removed-faint  . "#2a0f11")
    (bg-removed-refine . rustic-red)
    (fg-removed        . ruby-glow)
    (bg-changed        . "#3a2a12")
    (bg-changed-faint  . "#2a1e0d")
    (bg-changed-refine . "#5c3a00")
    (fg-changed        . lemon-zest)

    ;;; Diagnostic foregrounds (warning, error, info, hint)
    (err     . ruby-glow)
    (warning . lemon-zest)
    (info    . sky-blue)
    (hint    . walnut-brown)

    ;;; Dates
    (date-common    . sky-blue)
    (date-deadline  . ruby-glow)
    (date-scheduled . lemon-zest)
    (date-weekday   . sky-blue)
    (date-weekend   . blaze-orange)

    ;;; Prose and markup (markup.*)
    (prose-code     . winter-sky)
    (prose-verbatim . winter-sky)
    (prose-macro    . slate-purple)
    (prose-tag      . leafy-green)
    (prose-table    . crystal-blue)
    (prose-todo     . leafy-green)
    (prose-done     . slate-gray)
    (prose-list     . blaze-orange)
    (prose-quote    . winter-sky)
    (link           . crystal-blue)
    (link-underline . light-purple)
    (link-url       . slate-purple)

    ;;; Key bindings
    (keybind-key . slate-purple)

    ;;; Headings (markup.heading.*)
    (heading-0 . blaze-orange)
    (heading-1 . crystal-blue)
    (heading-2 . sky-blue)
    (heading-3 . dreamy-blue)
    (heading-4 . crystal-blue)
    (heading-5 . sky-blue)
    (heading-6 . dreamy-blue)
    (heading-7 . crystal-blue)
    (heading-8 . slate-gray)

    ;;; Completion matches (ui.menu and ui.text.focus)
    (completion-match-0 . crystal-blue)
    (completion-match-1 . slate-purple)
    (completion-match-2 . leafy-green)
    (completion-match-3 . lemon-zest)
    (prompt             . dreamy-blue)

    ;;; Identifiers
    (identifier-name  . walnut-brown)
    (identifier-value . crystal-blue)

    ;;; Syntax, following the Ao Helix theme directly
    (syntax-keyword     . ruby-glow)
    (syntax-operator    . ao-white)
    (syntax-string      . sky-blue)
    (syntax-constant    . sky-blue)
    (syntax-type        . ao-white)
    (syntax-function    . slate-purple)
    (syntax-method      . leafy-green)
    (syntax-variable    . blaze-orange)
    (syntax-member      . leafy-green)
    (syntax-parameter   . lemon-zest)
    (syntax-attribute   . lemon-zest)
    (syntax-punctuation . ao-white)
    (syntax-bracket     . blaze-orange)
    (syntax-escape      . lemon-zest)
    (syntax-regexp      . lemon-zest)
    (syntax-namespace   . ao-white)
    (syntax-label       . sky-blue)
    (syntax-constructor . blaze-orange))
  "The palette of the `ao-dark' theme.
The first block holds the raw colours of the Ao theme for the Helix
editor; the rest give them semantic names.  Each entry is a cons cell of
\(KEY . VALUE), where VALUE is a colour string, the symbol `unspecified',
or another KEY to alias.")

(defconst ao-theme-light-palette
  '(;;; The page colours of the Fedora documentation site, which this
    ;; variant takes its ground and chrome from.
    (docs-white     . "#ffffff")
    (docs-smoke-30  . "#fafafa")
    (docs-smoke-50  . "#f5f5f5")
    (docs-smoke-70  . "#f0f0f0")
    (docs-smoke-90  . "#e1e1e1")
    (docs-gray-10   . "#c1c1c1")
    (docs-gray-30   . "#8e8e8e")
    (docs-gray-70   . "#5d5d5d")
    (docs-jet-30    . "#424242")
    (docs-jet-50    . "#333333")
    (docs-jet-70    . "#222222")
    (docs-jet-80    . "#191919")
    (docs-link      . "#1565c0")
    (docs-link-hover . "#104d92")

    ;;; The Ao colours, held at their own hues but darkened until they
    ;; clear 4.5:1 against the page and the code block.
    (blaze-orange  . "#a85f00")
    (lemon-zest    . "#946c00")
    (leafy-green   . "#3b7f3d")
    (sky-blue      . "#0a7ab3")
    (dreamy-blue   . "#0a66c2")
    (crystal-blue  . "#0a4fa8")
    (ruby-glow     . "#c5210f")
    (walnut-brown  . "#906c48")
    (slate-purple  . "#7d2ae8")
    (light-purple  . "#7529c7")
    (deep-purple   . "#4c0f8d")
    (slate-gray    . "#6a7282")
    ;; Unchanged from the dark variant: these keep the Ao identity.
    (blaze-orange-pure . "#ff9000")
    (twilight-blue     . "#2c5484")
    (winter-sky        . "#f3f4f6")
    (pitch-black       . "#000000")
    (deep-abyss        . "#080d15")
    (selection-purple  . "#7533bd")

    ;;; Ground and text
    (bg-main     . docs-white)
    (bg-dim      . docs-smoke-30)
    (bg-alt      . docs-smoke-70)
    (bg-active   . docs-smoke-90)
    (bg-inactive . docs-smoke-50)
    (fg-main     . docs-jet-70)
    (fg-dim      . docs-gray-70)
    (fg-alt      . docs-jet-30)
    (border      . docs-smoke-90)
    (fg-divider  . docs-gray-30)

    ;;; Signature colours
    (accent    . blaze-orange)
    (selection . selection-purple)
    (cursor    . blaze-orange-pure)
    (comment   . slate-gray)

    ;;; Selection and current line
    (bg-region      . selection-purple)
    (fg-region      . docs-white)
    (bg-mark-select . selection-purple)
    (fg-mark-select . docs-white)
    (bg-hl-line     . docs-smoke-50)

    ;;; Fringe
    (bg-fringe . docs-white)
    (fg-fringe . docs-jet-70)

    ;;; Mode line and tab bar: the Ao mode line, unchanged in both variants
    (bg-mode-line-active       . twilight-blue)
    (fg-mode-line-active       . winter-sky)
    (border-mode-line-active   . twilight-blue)
    (bg-mode-line-inactive     . pitch-black)
    (fg-mode-line-inactive     . winter-sky)
    (border-mode-line-inactive . pitch-black)
    (bg-tab-bar     . pitch-black)
    (bg-tab-current . twilight-blue)
    (bg-tab-other   . pitch-black)
    (fg-tab-bar     . winter-sky)
    (fg-tab-dim     . "#838a97")
    (fg-tab-accent  . "#ffba00")

    ;;; Line numbers
    (bg-line-number-active   . docs-smoke-70)
    (fg-line-number-active   . "#8a4e00")
    (bg-line-number-inactive . docs-white)
    (fg-line-number-inactive . docs-gray-70)

    ;;; Matching parentheses (ui.cursor.match): no chip in the light variant.
    ;;; The glyph under the block cursor takes this background, so leaving it
    ;;; on the paper ground gives the paren at point a white glyph on orange,
    ;;; matching the cursor everywhere else; the match is a bare orange glyph
    (bg-paren-match      . bg-main)
    (fg-paren-match      . blaze-orange-pure)
    (bg-paren-expression . blaze-orange-pure)

    ;;; Menus, popups and hover
    (bg-completion      . "#e7f0fb")
    (bg-hover           . "#e4f3fa")
    (bg-hover-secondary . "#fdf3e0")

    ;;; Search
    (bg-search-current . "#ffd666")
    (fg-search-current . docs-jet-70)
    (bg-search-lazy    . "#cfe0f7")
    (fg-search-lazy    . docs-jet-70)
    (bg-search-replace . "#f8cfcb")
    (fg-search-replace . docs-jet-70)

    ;;; Diagnostics
    (bg-prominent-err     . "#f8cfcb")
    (fg-prominent-err     . docs-jet-70)
    (bg-prominent-warning . "#f8e0b0")
    (fg-prominent-warning . docs-jet-70)
    (bg-prominent-note    . "#cfe0f7")
    (fg-prominent-note    . docs-jet-70)

    ;;; Character highlights
    (bg-char-0 . "#cfe0f7")
    (bg-char-1 . "#e3d0fb")
    (bg-char-2 . "#f8e0b0")

    ;;; Arguments and whitespace
    (bg-active-argument . "#fdf3e0")
    (fg-active-argument . "#7a5900")
    (bg-space-err       . "#f8cfcb")
    (fg-space           . docs-gray-10)

    ;;; Accent hues, mapped onto the Ao syntax colours
    (red             . ruby-glow)
    (red-warmer      . ruby-glow)
    (red-cooler      . ruby-glow)
    (red-faint       . walnut-brown)
    (red-intense     . ruby-glow)
    (green           . leafy-green)
    (green-warmer    . leafy-green)
    (green-cooler    . leafy-green)
    (green-faint     . leafy-green)
    (green-intense   . leafy-green)
    (yellow          . lemon-zest)
    (yellow-warmer   . lemon-zest)
    (yellow-cooler   . walnut-brown)
    (yellow-faint    . walnut-brown)
    (yellow-intense  . lemon-zest)
    (blue            . sky-blue)
    (blue-warmer     . dreamy-blue)
    (blue-cooler     . crystal-blue)
    (blue-faint      . dreamy-blue)
    (blue-intense    . sky-blue)
    (magenta         . slate-purple)
    (magenta-warmer  . slate-purple)
    (magenta-cooler  . slate-purple)
    (magenta-faint   . light-purple)
    (magenta-intense . slate-purple)
    (cyan            . sky-blue)
    (cyan-warmer     . crystal-blue)
    (cyan-cooler     . crystal-blue)
    (cyan-faint      . dreamy-blue)
    (cyan-intense    . sky-blue)

    ;;; Accent backgrounds, tinted off the page white
    (bg-red-subtle     . "#fdeceb")
    (bg-green-subtle   . "#e6f4e6")
    (bg-yellow-subtle  . "#fdf3e0")
    (bg-blue-subtle    . "#e7f0fb")
    (bg-magenta-subtle . "#f3e8fd")
    (bg-cyan-subtle    . "#e4f3fa")
    (bg-red-intense     . "#f8cfcb")
    (bg-green-intense   . "#c8e6c9")
    (bg-yellow-intense  . "#f8e0b0")
    (bg-blue-intense    . "#cfe0f7")
    (bg-magenta-intense . "#e3d0fb")
    (bg-cyan-intense    . "#c9e8f6")

    ;;; Diffs
    (bg-added          . "#e6f4e6")
    (bg-added-faint    . "#f2faf2")
    (bg-added-refine   . "#c8e6c9")
    (fg-added          . "#2e6b30")
    (bg-removed        . "#fdeceb")
    (bg-removed-faint  . "#fef5f4")
    (bg-removed-refine . "#f8cfcb")
    (fg-removed        . "#b3170a")
    (bg-changed        . "#fdf3e0")
    (bg-changed-faint  . "#fdf9f0")
    (bg-changed-refine . "#f8e0b0")
    (fg-changed        . "#7a5900")

    ;;; Diagnostic foregrounds
    (err     . ruby-glow)
    (warning . lemon-zest)
    (info    . sky-blue)
    (hint    . walnut-brown)

    ;;; Dates
    (date-common    . sky-blue)
    (date-deadline  . ruby-glow)
    (date-scheduled . lemon-zest)
    (date-weekday   . sky-blue)
    (date-weekend   . blaze-orange)

    ;;; Prose and markup
    (prose-code     . docs-jet-70)
    (prose-verbatim . docs-jet-70)
    (prose-macro    . slate-purple)
    (prose-tag      . leafy-green)
    (prose-table    . crystal-blue)
    (prose-todo     . leafy-green)
    (prose-done     . slate-gray)
    (prose-list     . blaze-orange)
    (prose-quote    . docs-gray-70)
    (link           . docs-link)
    (link-underline . light-purple)
    (link-url       . slate-purple)

    ;;; Key bindings
    (keybind-key . slate-purple)

    ;;; Headings: on a light ground the darkest blue carries the most weight
    (heading-0 . blaze-orange)
    (heading-1 . crystal-blue)
    (heading-2 . sky-blue)
    (heading-3 . dreamy-blue)
    (heading-4 . crystal-blue)
    (heading-5 . sky-blue)
    (heading-6 . dreamy-blue)
    (heading-7 . crystal-blue)
    (heading-8 . docs-gray-70)

    ;;; Completion matches
    (completion-match-0 . crystal-blue)
    (completion-match-1 . slate-purple)
    (completion-match-2 . leafy-green)
    (completion-match-3 . lemon-zest)
    (prompt             . dreamy-blue)

    ;;; Identifiers
    (identifier-name  . walnut-brown)
    (identifier-value . crystal-blue)

    ;;; Syntax, following the Ao Helix theme directly
    (syntax-keyword     . ruby-glow)
    (syntax-operator    . docs-jet-70)
    (syntax-string      . sky-blue)
    (syntax-constant    . sky-blue)
    (syntax-type        . docs-jet-70)
    (syntax-function    . slate-purple)
    (syntax-method      . leafy-green)
    (syntax-variable    . blaze-orange)
    (syntax-member      . leafy-green)
    (syntax-parameter   . lemon-zest)
    (syntax-attribute   . lemon-zest)
    (syntax-punctuation . docs-jet-70)
    (syntax-bracket     . blaze-orange)
    (syntax-escape      . lemon-zest)
    (syntax-regexp      . lemon-zest)
    (syntax-namespace   . docs-jet-70)
    (syntax-label       . sky-blue)
    (syntax-constructor . blaze-orange))
  "The palette of the `ao-light' theme.
The ground and chrome are taken from the Fedora documentation site; the
accents are the Ao colours, darkened to stay legible on a light ground.
Same shape as `ao-theme-dark-palette'.")

;;;; Palette resolution

(defun ao-theme--palette-overrides (variant)
  "Return the overrides in effect for VARIANT, a symbol: `dark' or `light'."
  (append (if (eq variant 'dark)
              ao-theme-dark-palette-overrides
            ao-theme-light-palette-overrides)
          ao-theme-common-palette-overrides))

(defun ao-theme--palette (variant)
  "Return the full palette alist for VARIANT, overrides applied."
  (append (mapcar (lambda (cell) (cons (car cell) (cadr cell)))
                  (ao-theme--palette-overrides variant))
          (if (eq variant 'dark)
              ao-theme-dark-palette
            ao-theme-light-palette)))

(defun ao-theme--color (key palette &optional depth)
  "Resolve KEY against PALETTE to a colour value.
A value that is itself a palette KEY is followed, up to a small DEPTH,
so that entries may alias one another.  Returns `unspecified' when KEY
is absent."
  (let ((value (alist-get key palette 'unspecified)))
    (cond
     ((stringp value) value)
     ((and (symbolp value)
           (not (eq value 'unspecified))
           (not (memq value '(t nil)))
           (< (or depth 0) 10))
      (ao-theme--color value palette (1+ (or depth 0))))
     (t value))))

(defvar ao-theme--current-palette nil
  "Palette of the AO theme that was most recently defined.")

;;;###autoload
(defun ao-theme-get-color-value (key)
  "Return the colour value of palette KEY for the current AO theme.
Useful for deriving faces of your own, for example:

    (set-face-attribute \\='tab-bar nil
                        :foreground (ao-theme-get-color-value \\='fg-tab-bar))"
  (if ao-theme--current-palette
      (ao-theme--color key ao-theme--current-palette)
    (user-error "No AO theme is currently loaded")))

;;;; Faces owned by the theme

(defface ao-theme-bold nil
  "Face for bold syntactic constructs, per `ao-theme-bold-constructs'."
  :group 'ao-theme)

(defface ao-theme-slant nil
  "Face for italic syntactic constructs, per `ao-theme-italic-constructs'."
  :group 'ao-theme)

(defface ao-theme-fixed-pitch nil
  "Face for code inside prose, per `ao-theme-mixed-fonts'."
  :group 'ao-theme)

(defface ao-theme-ui-variable-pitch nil
  "Face for UI elements, per `ao-theme-variable-pitch-ui'."
  :group 'ao-theme)

(defface ao-theme-button nil "Face for buttons." :group 'ao-theme)
(defface ao-theme-key-binding nil "Face for key bindings." :group 'ao-theme)
(defface ao-theme-prompt nil "Face for prompts." :group 'ao-theme)

(defface ao-theme-search-current nil "Face for the current search match." :group 'ao-theme)
(defface ao-theme-search-lazy nil "Face for other search matches." :group 'ao-theme)
(defface ao-theme-search-replace nil "Face for pending replacements." :group 'ao-theme)

(defface ao-theme-completion-selected nil "Face for the selected candidate." :group 'ao-theme)
(defface ao-theme-completion-match-0 nil "Face for the first matched group." :group 'ao-theme)
(defface ao-theme-completion-match-1 nil "Face for the second matched group." :group 'ao-theme)
(defface ao-theme-completion-match-2 nil "Face for the third matched group." :group 'ao-theme)
(defface ao-theme-completion-match-3 nil "Face for the fourth matched group." :group 'ao-theme)

(defface ao-theme-mark-sel nil "Face for selection marks." :group 'ao-theme)
(defface ao-theme-mark-del nil "Face for deletion marks." :group 'ao-theme)
(defface ao-theme-mark-alt nil "Face for alternative marks." :group 'ao-theme)

(defface ao-theme-prominent-error nil "Face for prominent errors." :group 'ao-theme)
(defface ao-theme-prominent-warning nil "Face for prominent warnings." :group 'ao-theme)
(defface ao-theme-prominent-note nil "Face for prominent notes." :group 'ao-theme)

(defface ao-theme-lang-error nil "Face for language errors." :group 'ao-theme)
(defface ao-theme-lang-warning nil "Face for language warnings." :group 'ao-theme)
(defface ao-theme-lang-note nil "Face for language notes." :group 'ao-theme)

(defface ao-theme-prose-code nil "Face for inline code in prose." :group 'ao-theme)
(defface ao-theme-prose-verbatim nil "Face for verbatim text in prose." :group 'ao-theme)
(defface ao-theme-prose-macro nil "Face for macros in prose." :group 'ao-theme)

(defface ao-theme-heading-0 nil "Face for level 0 headings (document titles)." :group 'ao-theme)
(defface ao-theme-heading-1 nil "Face for level 1 headings." :group 'ao-theme)
(defface ao-theme-heading-2 nil "Face for level 2 headings." :group 'ao-theme)
(defface ao-theme-heading-3 nil "Face for level 3 headings." :group 'ao-theme)
(defface ao-theme-heading-4 nil "Face for level 4 headings." :group 'ao-theme)
(defface ao-theme-heading-5 nil "Face for level 5 headings." :group 'ao-theme)
(defface ao-theme-heading-6 nil "Face for level 6 headings." :group 'ao-theme)
(defface ao-theme-heading-7 nil "Face for level 7 headings." :group 'ao-theme)
(defface ao-theme-heading-8 nil "Face for level 8 headings." :group 'ao-theme)

;;;; Face specifications

;; The specifications are split across several functions: one backquoted
;; list of this size exceeds `max-lisp-eval-depth' during macro expansion.

(defun ao-theme--faces-theme-owned-building-blocks (palette)
  "Return the theme-owned building blocks face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (ao-theme-bold ((t ,@(when ao-theme-bold-constructs '(:weight bold)))))
      (ao-theme-slant ((t ,@(when ao-theme-italic-constructs '(:slant italic)))))
      (ao-theme-fixed-pitch ((t ,@(when ao-theme-mixed-fonts '(:inherit fixed-pitch)))))
      (ao-theme-ui-variable-pitch ((t ,@(when ao-theme-variable-pitch-ui '(:inherit variable-pitch)))))
      (ao-theme-button ((t :inherit variable-pitch :background ,(c 'bg-active)
                           :foreground ,(c 'fg-main)
                           :box (:line-width 1 :color ,(c 'border) :style released-button))))
      (ao-theme-key-binding ((t :inherit (bold ao-theme-fixed-pitch) :foreground ,(c 'keybind-key))))
      (ao-theme-prompt ((t :foreground ,(c 'prompt))))
      (ao-theme-search-current ((t :background ,(c 'bg-search-current) :foreground ,(c 'fg-search-current))))
      (ao-theme-search-lazy ((t :background ,(c 'bg-search-lazy) :foreground ,(c 'fg-search-lazy))))
      (ao-theme-search-replace ((t :background ,(c 'bg-search-replace) :foreground ,(c 'fg-search-replace))))
      (ao-theme-completion-selected ((t :inherit bold :background ,(c 'bg-completion))))
      (ao-theme-completion-match-0 ((t :inherit bold :foreground ,(c 'completion-match-0))))
      (ao-theme-completion-match-1 ((t :inherit bold :foreground ,(c 'completion-match-1))))
      (ao-theme-completion-match-2 ((t :inherit bold :foreground ,(c 'completion-match-2))))
      (ao-theme-completion-match-3 ((t :inherit bold :foreground ,(c 'completion-match-3))))
      (ao-theme-mark-sel ((t :inherit bold :background ,(c 'bg-mark-select) :foreground ,(c 'fg-mark-select))))
      (ao-theme-mark-del ((t :inherit bold :background ,(c 'bg-red-subtle) :foreground ,(c 'red-cooler))))
      (ao-theme-mark-alt ((t :inherit bold :background ,(c 'bg-yellow-subtle) :foreground ,(c 'fg-changed))))
      (ao-theme-prominent-error ((t :background ,(c 'bg-prominent-err) :foreground ,(c 'fg-prominent-err))))
      (ao-theme-prominent-warning ((t :background ,(c 'bg-prominent-warning) :foreground ,(c 'fg-prominent-warning))))
      (ao-theme-prominent-note ((t :background ,(c 'bg-prominent-note) :foreground ,(c 'fg-prominent-note))))
      (ao-theme-lang-error ((t :underline (:style wave :color ,(c 'red-intense)))))
      (ao-theme-lang-warning ((t :underline (:style wave :color ,(c 'yellow)))))
      (ao-theme-lang-note ((t :underline (:style wave :color ,(c 'cyan)))))
      (ao-theme-prose-code ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'prose-code))))
      (ao-theme-prose-verbatim ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'prose-verbatim))))
      (ao-theme-prose-macro ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'prose-macro))))
      (ao-theme-heading-0 ((t :inherit bold :foreground ,(c 'heading-0))))
      (ao-theme-heading-1 ((t :inherit bold :foreground ,(c 'heading-1))))
      (ao-theme-heading-2 ((t :inherit bold :foreground ,(c 'heading-2))))
      (ao-theme-heading-3 ((t :inherit bold :foreground ,(c 'heading-3))))
      (ao-theme-heading-4 ((t :inherit bold :foreground ,(c 'heading-4))))
      (ao-theme-heading-5 ((t :inherit bold :foreground ,(c 'heading-5))))
      (ao-theme-heading-6 ((t :inherit bold :foreground ,(c 'heading-6))))
      (ao-theme-heading-7 ((t :inherit bold :foreground ,(c 'heading-7))))
      (ao-theme-heading-8 ((t :inherit bold :foreground ,(c 'heading-8)))))))

(defun ao-theme--faces-basic-faces (palette)
  "Return the basic faces face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (default ((t :background ,(c 'bg-main) :foreground ,(c 'fg-main))))
      (cursor ((t :background ,(c 'cursor))))
      (region ((t :background ,(c 'bg-region) :foreground ,(c 'fg-region))))
      (highlight ((t :background ,(c 'bg-hover) :foreground ,(c 'fg-main))))
      (secondary-selection ((t :background ,(c 'bg-hover-secondary) :foreground ,(c 'fg-main))))
      (match ((t :background ,(c 'bg-magenta-subtle) :foreground ,(c 'fg-main))))
      (shadow ((t :foreground ,(c 'fg-dim))))
      (success ((t :inherit bold :foreground ,(c 'info))))
      (warning ((t :inherit bold :foreground ,(c 'warning))))
      (error ((t :inherit bold :foreground ,(c 'err))))
      (link ((t :inherit button)))
      (link-visited ((t :foreground ,(c 'link-url))))
      (button ((t :foreground ,(c 'link))))
      (fringe ((t :background ,(c 'bg-fringe) :foreground ,(c 'fg-fringe))))
      (vertical-border ((t :foreground ,(c 'fg-divider))))
      (window-divider ((t :foreground ,(c 'fg-divider))))
      (window-divider-first-pixel ((t :foreground ,(c 'fg-divider))))
      (window-divider-last-pixel ((t :foreground ,(c 'fg-divider))))
      (minibuffer-prompt ((t :inherit ao-theme-prompt)))
      (tooltip ((t :background ,(c 'bg-active) :foreground ,(c 'fg-main))))
      (escape-glyph ((t :inherit bold :foreground ,(c 'err))))
      (homoglyph ((t :foreground ,(c 'warning))))
      (nobreak-space ((t :foreground ,(c 'warning) :underline t)))
      (nobreak-hyphen ((t :foreground ,(c 'warning))))
      (trailing-whitespace ((t :background ,(c 'bg-space-err))))
      (separator-line ((t :underline ,(c 'bg-active))))
      (help-key-binding ((t :inherit ao-theme-key-binding)))
      (help-argument-name ((t :inherit ao-theme-slant :foreground ,(c 'fg-active-argument))))
      (italic ((t :slant italic)))
      (bold ((t :weight bold)))
      (bold-italic ((t :inherit (bold italic))))
      (underline ((t :underline t)))
      (fixed-pitch-serif ((t :inherit fixed-pitch)))
      (hl-line ((t :background ,(c 'bg-hl-line) :extend t)))
      (fill-column-indicator ((t :height 1 :background ,(c 'bg-active) :foreground ,(c 'bg-active))))
      (show-paren-match ((t :background ,(c 'bg-paren-match) :foreground ,(c 'fg-paren-match))))
      (show-paren-match-expression ((t :background ,(c 'bg-paren-expression))))
      (show-paren-mismatch ((t :inherit ao-theme-prominent-error)))
      (cursor-intangible ((t :inherit shadow)))
      (glyphless-char ((t :inherit shadow :height 0.6)))
      (child-frame-border ((t :background ,(c 'border))))
      (internal-border ((t :background ,(c 'border))))
      (header-line ((t :inherit ao-theme-ui-variable-pitch :background ,(c 'bg-dim) :foreground ,(c 'fg-main))))
      (header-line-highlight ((t :inherit highlight))))))

(defun ao-theme--faces-search-and-replace (palette)
  "Return the search and replace face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (isearch ((t :inherit ao-theme-search-current)))
      (isearch-fail ((t :inherit ao-theme-prominent-error)))
      (isearch-group-1 ((t :background ,(c 'bg-magenta-intense) :foreground ,(c 'fg-main))))
      (isearch-group-2 ((t :background ,(c 'bg-green-intense) :foreground ,(c 'fg-main))))
      (lazy-highlight ((t :inherit ao-theme-search-lazy)))
      (query-replace ((t :inherit ao-theme-search-replace))))))

(defun ao-theme--faces-font-lock (palette)
  "Return the font lock face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (font-lock-comment-face ((t :inherit ao-theme-slant :foreground ,(c 'comment))))
      (font-lock-comment-delimiter-face ((t :inherit font-lock-comment-face)))
      (font-lock-doc-face ((t :inherit ao-theme-slant :foreground ,(c 'crystal-blue))))
      (font-lock-doc-markup-face ((t :inherit ao-theme-prose-macro)))
      (font-lock-string-face ((t :foreground ,(c 'syntax-string))))
      (font-lock-keyword-face ((t :inherit ao-theme-bold :foreground ,(c 'syntax-keyword))))
      (font-lock-builtin-face ((t :inherit ao-theme-bold :foreground ,(c 'syntax-method))))
      (font-lock-type-face ((t :inherit ao-theme-bold :foreground ,(c 'syntax-type))))
      (font-lock-constant-face ((t :foreground ,(c 'syntax-constant))))
      (font-lock-function-name-face ((t :foreground ,(c 'syntax-function))))
      (font-lock-variable-name-face ((t :foreground ,(c 'syntax-variable))))
      (font-lock-preprocessor-face ((t :foreground ,(c 'syntax-namespace))))
      (font-lock-negation-char-face ((t :inherit error)))
      (font-lock-warning-face ((t :inherit ao-theme-bold :foreground ,(c 'warning))))
      (font-lock-regexp-grouping-backslash ((t :inherit ao-theme-bold :foreground ,(c 'syntax-escape))))
      (font-lock-regexp-grouping-construct ((t :inherit ao-theme-bold :foreground ,(c 'syntax-regexp))))
      ;; Tree-sitter and Emacs 29+ additions
      (font-lock-bracket-face ((t :foreground ,(c 'syntax-bracket))))
      (font-lock-delimiter-face ((t :foreground ,(c 'syntax-punctuation))))
      (font-lock-punctuation-face ((t :foreground ,(c 'syntax-punctuation))))
      (font-lock-misc-punctuation-face ((t :foreground ,(c 'syntax-punctuation))))
      (font-lock-operator-face ((t :foreground ,(c 'syntax-operator))))
      (font-lock-escape-face ((t :foreground ,(c 'syntax-escape))))
      (font-lock-number-face ((t :foreground ,(c 'syntax-constant))))
      (font-lock-function-call-face ((t :inherit font-lock-function-name-face)))
      (font-lock-variable-use-face ((t :inherit font-lock-variable-name-face)))
      (font-lock-property-name-face ((t :foreground ,(c 'syntax-member))))
      (font-lock-property-use-face ((t :inherit font-lock-property-name-face)))
      (font-lock-regexp-face ((t :inherit font-lock-string-face))))))

(defun ao-theme--faces-mode-line-tab-bar-and-tab-line (palette)
  "Return the mode line, tab bar and tab line face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (mode-line ((t :inherit ao-theme-ui-variable-pitch
                     :background ,(c 'bg-mode-line-active)
                     :foreground ,(c 'fg-mode-line-active)
                     :box ,(c 'border-mode-line-active))))
      (mode-line-active ((t :inherit mode-line)))
      (mode-line-inactive ((t :inherit ao-theme-ui-variable-pitch
                              :background ,(c 'bg-mode-line-inactive)
                              :foreground ,(c 'fg-mode-line-inactive)
                              :box ,(c 'border-mode-line-inactive))))
      (mode-line-highlight ((t :background ,(c 'bg-hover) :foreground ,(c 'fg-main) :box ,(c 'fg-main))))
      (mode-line-buffer-id ((t :inherit bold)))
      (mode-line-emphasis ((t :inherit bold :foreground ,(c 'accent))))
      (tab-bar ((t :inherit ao-theme-ui-variable-pitch
                   :background ,(c 'bg-tab-bar) :foreground ,(c 'fg-tab-bar))))
      (tab-bar-tab ((t :inherit bold :background ,(c 'bg-tab-current) :foreground ,(c 'fg-tab-bar)
                       :box (:line-width -2 :color ,(c 'bg-tab-current)))))
      (tab-bar-tab-inactive ((t :background ,(c 'bg-tab-other) :foreground ,(c 'fg-tab-bar)
                                :box (:line-width -2 :color ,(c 'bg-tab-other)))))
      (tab-bar-tab-group-current ((t :inherit bold :background ,(c 'bg-tab-current) :foreground ,(c 'fg-tab-accent))))
      (tab-bar-tab-group-inactive ((t :background ,(c 'bg-tab-other) :foreground ,(c 'fg-tab-dim))))
      (tab-bar-tab-ungrouped ((t :inherit tab-bar-tab-inactive)))
      (tab-line ((t :inherit ao-theme-ui-variable-pitch :background ,(c 'bg-tab-bar)
                    :foreground ,(c 'fg-tab-bar) :height 0.95)))
      (tab-line-tab ((t :inherit tab-bar-tab)))
      (tab-line-tab-current ((t :inherit tab-line-tab)))
      (tab-line-tab-inactive ((t :inherit tab-bar-tab-inactive)))
      (tab-line-tab-inactive-alternative ((t :inherit tab-line-tab-inactive)))
      (tab-line-tab-modified ((t :foreground ,(c 'warning))))
      (tab-line-highlight ((t :inherit highlight))))))

(defun ao-theme--faces-line-numbers (palette)
  "Return the line numbers face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (line-number ((t :inherit default :background ,(c 'bg-line-number-inactive)
                       :foreground ,(c 'fg-line-number-inactive))))
      (line-number-current-line ((t :inherit (bold line-number)
                                    :background ,(c 'bg-line-number-active)
                                    :foreground ,(c 'fg-line-number-active))))
      (line-number-major-tick ((t :inherit line-number :foreground ,(c 'err))))
      (line-number-minor-tick ((t :inherit line-number :foreground ,(c 'fg-alt)))))))

(defun ao-theme--faces-completion-minibuffer-and-in-buffer (palette)
  "Return the completion face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (completions-common-part ((t :inherit ao-theme-completion-match-0)))
      (completions-first-difference ((t :inherit ao-theme-completion-match-1)))
      (completions-annotations ((t :inherit ao-theme-slant :foreground ,(c 'cyan-faint))))
      (completions-group-title ((t :inherit bold :foreground ,(c 'heading-2))))
      (completions-highlight ((t :inherit ao-theme-completion-selected)))
      ;; vertico
      (vertico-current ((t :inherit ao-theme-completion-selected)))
      (vertico-group-title ((t :inherit bold :foreground ,(c 'heading-2))))
      (vertico-group-separator ((t :strike-through t :foreground ,(c 'fg-dim))))
      (vertico-multiline ((t :inherit shadow)))
      (vertico-quick1 ((t :inherit bold :background ,(c 'bg-char-0) :foreground ,(c 'fg-main))))
      (vertico-quick2 ((t :inherit bold :background ,(c 'bg-char-1) :foreground ,(c 'fg-main))))
      ;; corfu
      (corfu-default ((t :background ,(c 'bg-dim) :foreground ,(c 'fg-main))))
      (corfu-current ((t :inherit ao-theme-completion-selected)))
      (corfu-bar ((t :background ,(c 'fg-dim))))
      (corfu-border ((t :background ,(c 'bg-active))))
      (corfu-annotations ((t :inherit completions-annotations)))
      (corfu-deprecated ((t :inherit shadow :strike-through t)))
      (corfu-echo ((t :inherit shadow)))
      (corfu-popupinfo ((t :inherit corfu-default)))
      (corfu-quick1 ((t :inherit vertico-quick1)))
      (corfu-quick2 ((t :inherit vertico-quick2)))
      ;; orderless
      (orderless-match-face-0 ((t :inherit ao-theme-completion-match-0)))
      (orderless-match-face-1 ((t :inherit ao-theme-completion-match-1)))
      (orderless-match-face-2 ((t :inherit ao-theme-completion-match-2)))
      (orderless-match-face-3 ((t :inherit ao-theme-completion-match-3)))
      ;; marginalia
      (marginalia-archive ((t :foreground ,(c 'cyan-cooler))))
      (marginalia-char ((t :foreground ,(c 'red-cooler))))
      (marginalia-date ((t :foreground ,(c 'date-common))))
      (marginalia-documentation ((t :inherit ao-theme-slant :foreground ,(c 'fg-dim))))
      (marginalia-file-name ((t :foreground ,(c 'blue-faint))))
      (marginalia-file-owner ((t :foreground ,(c 'red-faint))))
      (marginalia-file-priv-dir ((t :foreground ,(c 'blue-warmer))))
      (marginalia-file-priv-exec ((t :foreground ,(c 'green-warmer))))
      (marginalia-file-priv-link ((t :foreground ,(c 'cyan))))
      (marginalia-file-priv-no ((t :inherit shadow)))
      (marginalia-file-priv-other ((t :foreground ,(c 'yellow))))
      (marginalia-file-priv-rare ((t :foreground ,(c 'red))))
      (marginalia-file-priv-read ((t :foreground ,(c 'fg-main))))
      (marginalia-file-priv-write ((t :foreground ,(c 'red-cooler))))
      (marginalia-function ((t :foreground ,(c 'magenta))))
      (marginalia-key ((t :inherit ao-theme-key-binding)))
      (marginalia-lighter ((t :foreground ,(c 'blue-warmer))))
      (marginalia-list ((t :foreground ,(c 'magenta-warmer))))
      (marginalia-mode ((t :foreground ,(c 'cyan))))
      (marginalia-modified ((t :foreground ,(c 'warning))))
      (marginalia-null ((t :inherit shadow)))
      (marginalia-number ((t :foreground ,(c 'blue-cooler))))
      (marginalia-size ((t :foreground ,(c 'cyan-cooler))))
      (marginalia-string ((t :foreground ,(c 'blue-warmer))))
      (marginalia-symbol ((t :foreground ,(c 'magenta-cooler))))
      (marginalia-true ((t :foreground ,(c 'fg-main))))
      (marginalia-type ((t :foreground ,(c 'cyan-cooler))))
      (marginalia-value ((t :foreground ,(c 'identifier-value))))
      (marginalia-version ((t :foreground ,(c 'date-common))))
      ;; consult
      (consult-async-completing ((t :inherit bold)))
      (consult-async-failed ((t :inherit error)))
      (consult-async-running ((t :inherit bold)))
      (consult-async-split ((t :foreground ,(c 'accent))))
      (consult-file ((t :inherit marginalia-file-name)))
      (consult-key ((t :inherit ao-theme-key-binding)))
      (consult-imenu-prefix ((t :inherit shadow)))
      (consult-line-number ((t :inherit shadow)))
      (consult-line-number-prefix ((t :inherit line-number)))
      (consult-highlight-mark ((t :inherit ao-theme-mark-sel)))
      (consult-highlight-match ((t :inherit ao-theme-search-lazy)))
      (consult-preview-match ((t :inherit ao-theme-search-current)))
      (consult-separator ((t :foreground ,(c 'fg-divider))))
      ;; cape
      (cape-prefix-face ((t :inherit ao-theme-completion-match-0))))))

(defun ao-theme--faces-which-key (palette)
  "Return the which-key face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (which-key-key-face ((t :inherit ao-theme-key-binding)))
      (which-key-command-description-face ((t :foreground ,(c 'fg-main))))
      (which-key-group-description-face ((t :foreground ,(c 'magenta-warmer))))
      (which-key-highlighted-command-face ((t :foreground ,(c 'warning) :underline t)))
      (which-key-local-map-description-face ((t :foreground ,(c 'fg-main))))
      (which-key-note-face ((t :inherit shadow)))
      (which-key-separator-face ((t :inherit shadow)))
      (which-key-special-key-face ((t :inherit error))))))

(defun ao-theme--faces-widgets-custom-and-help (palette)
  "Return the widgets, custom and help face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (widget-field ((t :background ,(c 'bg-alt) :foreground ,(c 'fg-main) :extend nil)))
      (widget-single-line-field ((t :inherit widget-field)))
      (widget-button ((t :inherit bold :foreground ,(c 'blue-warmer))))
      (widget-button-pressed ((t :inherit widget-button :foreground ,(c 'magenta))))
      (widget-documentation ((t :inherit font-lock-doc-face)))
      (widget-inactive ((t :inherit shadow :background ,(c 'bg-dim))))
      (custom-button ((t :inherit ao-theme-button)))
      (custom-button-mouse ((t :inherit (highlight custom-button))))
      (custom-button-pressed ((t :inherit (secondary-selection custom-button))))
      (custom-changed ((t :background ,(c 'bg-changed) :foreground ,(c 'fg-changed))))
      (custom-comment ((t :inherit shadow)))
      (custom-comment-tag ((t :inherit (bold shadow))))
      (custom-face-tag ((t :inherit bold :foreground ,(c 'blue-cooler))))
      (custom-group-tag ((t :inherit ao-theme-heading-4)))
      (custom-group-subtitle ((t :inherit bold)))
      (custom-invalid ((t :inherit ao-theme-prominent-error)))
      (custom-modified ((t :inherit custom-changed)))
      (custom-rogue ((t :inherit custom-invalid)))
      (custom-set ((t :inherit success)))
      (custom-state ((t :foreground ,(c 'warning))))
      (custom-themed ((t :inherit custom-changed)))
      (custom-variable-obsolete ((t :inherit shadow)))
      (custom-variable-tag ((t :inherit bold :foreground ,(c 'cyan))))
      (custom-visibility ((t :inherit button :height 0.8)))
      (help-for-help-header ((t :height 1.2)))
      (info-menu-star ((t :foreground ,(c 'red))))
      (info-node ((t :inherit bold)))
      (info-title-1 ((t :inherit ao-theme-heading-1)))
      (info-title-2 ((t :inherit ao-theme-heading-2)))
      (info-title-3 ((t :inherit ao-theme-heading-3)))
      (info-title-4 ((t :inherit ao-theme-heading-4)))
      (Info-quoted ((t :inherit ao-theme-prose-verbatim))))))

(defun ao-theme--faces-diffs-version-control-and-magit (palette)
  "Return the diffs, version control and Magit face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (diff-added ((t :background ,(c 'bg-added) :foreground ,(c 'fg-added))))
      (diff-changed ((t :background ,(c 'bg-changed) :foreground ,(c 'fg-changed) :extend t)))
      (diff-removed ((t :background ,(c 'bg-removed) :foreground ,(c 'fg-removed))))
      (diff-indicator-added ((t :inherit (diff-added bold))))
      (diff-indicator-changed ((t :inherit (diff-changed bold))))
      (diff-indicator-removed ((t :inherit (diff-removed bold))))
      (diff-refine-added ((t :background ,(c 'bg-added-refine) :foreground ,(c 'fg-added))))
      (diff-refine-changed ((t :background ,(c 'bg-changed-refine) :foreground ,(c 'fg-changed))))
      (diff-refine-removed ((t :background ,(c 'bg-removed-refine) :foreground ,(c 'fg-removed))))
      (diff-header (( )))
      (diff-file-header ((t :inherit bold)))
      (diff-hunk-header ((t :inherit bold :background ,(c 'bg-inactive))))
      (diff-function ((t :background ,(c 'bg-inactive))))
      (diff-index ((t :inherit bold)))
      (diff-context (( )))
      (diff-nonexistent ((t :inherit bold :background ,(c 'bg-alt))))
      (ediff-current-diff-A ((t :background ,(c 'bg-removed) :foreground ,(c 'fg-removed))))
      (ediff-current-diff-B ((t :background ,(c 'bg-added) :foreground ,(c 'fg-added))))
      (ediff-current-diff-C ((t :background ,(c 'bg-changed) :foreground ,(c 'fg-changed))))
      (ediff-current-diff-Ancestor ((t :background ,(c 'bg-cyan-subtle) :foreground ,(c 'fg-main))))
      (ediff-even-diff-A ((t :background ,(c 'bg-dim))))
      (ediff-even-diff-B ((t :background ,(c 'bg-dim))))
      (ediff-even-diff-C ((t :background ,(c 'bg-dim))))
      (ediff-even-diff-Ancestor ((t :background ,(c 'bg-dim))))
      (ediff-fine-diff-A ((t :background ,(c 'bg-removed-refine) :foreground ,(c 'fg-removed))))
      (ediff-fine-diff-B ((t :background ,(c 'bg-added-refine) :foreground ,(c 'fg-added))))
      (ediff-fine-diff-C ((t :background ,(c 'bg-changed-refine) :foreground ,(c 'fg-changed))))
      (ediff-fine-diff-Ancestor ((t :background ,(c 'bg-cyan-intense) :foreground ,(c 'fg-main))))
      (ediff-odd-diff-A ((t :inherit ediff-even-diff-A)))
      (ediff-odd-diff-B ((t :inherit ediff-even-diff-B)))
      (ediff-odd-diff-C ((t :inherit ediff-even-diff-C)))
      (ediff-odd-diff-Ancestor ((t :inherit ediff-even-diff-Ancestor)))
      (smerge-base ((t :inherit diff-changed)))
      (smerge-lower ((t :inherit diff-added)))
      (smerge-upper ((t :inherit diff-removed)))
      (smerge-markers ((t :inherit diff-hunk-header)))
      (smerge-refined-added ((t :inherit diff-refine-added)))
      (smerge-refined-removed ((t :inherit diff-refine-removed)))
      (vc-conflict-state ((t :inherit bold :foreground ,(c 'err))))
      (vc-edited-state ((t :foreground ,(c 'warning))))
      (vc-locally-added-state ((t :foreground ,(c 'info))))
      (vc-locked-state ((t :foreground ,(c 'magenta-cooler))))
      (vc-missing-state ((t :inherit bold :foreground ,(c 'err))))
      (vc-needs-update-state ((t :foreground ,(c 'warning))))
      (vc-removed-state ((t :foreground ,(c 'err))))
      (vc-up-to-date-state ((t :foreground ,(c 'fg-dim))))
      (vc-dir-header ((t :inherit bold)))
      (vc-dir-header-value ((t :foreground ,(c 'identifier-value))))
      (vc-dir-file ((t :foreground ,(c 'fg-main))))
      (vc-dir-directory ((t :inherit dired-directory)))
      (vc-dir-status-up-to-date ((t :foreground ,(c 'fg-dim))))
      (vc-dir-status-edited ((t :foreground ,(c 'warning))))
      (vc-dir-status-ignored ((t :inherit shadow)))
      (vc-dir-status-warning ((t :inherit error)))
      (vc-dir-mark-indicator ((t :inherit ao-theme-mark-sel)))
      (magit-bisect-bad ((t :inherit error)))
      (magit-bisect-good ((t :inherit success)))
      (magit-bisect-skip ((t :inherit warning)))
      (magit-blame-date (( )))
      (magit-blame-dimmed ((t :inherit shadow)))
      (magit-blame-hash (( )))
      (magit-blame-highlight ((t :background ,(c 'bg-active) :foreground ,(c 'fg-main))))
      (magit-blame-name (( )))
      (magit-blame-summary (( )))
      (magit-branch-local ((t :foreground ,(c 'blue-cooler))))
      (magit-branch-remote ((t :foreground ,(c 'magenta-warmer))))
      (magit-branch-remote-head ((t :inherit bold :foreground ,(c 'magenta-warmer))))
      (magit-branch-upstream ((t :inherit ao-theme-slant)))
      (magit-branch-warning ((t :inherit warning)))
      (magit-cherry-equivalent ((t :foreground ,(c 'magenta-intense))))
      (magit-cherry-unmatched ((t :foreground ,(c 'cyan-intense))))
      (magit-diff-added ((t :background ,(c 'bg-added-faint) :foreground ,(c 'fg-added))))
      (magit-diff-added-highlight ((t :background ,(c 'bg-added) :foreground ,(c 'fg-added))))
      (magit-diff-removed ((t :background ,(c 'bg-removed-faint) :foreground ,(c 'fg-removed))))
      (magit-diff-removed-highlight ((t :background ,(c 'bg-removed) :foreground ,(c 'fg-removed))))
      (magit-diff-base ((t :background ,(c 'bg-changed-faint) :foreground ,(c 'fg-changed))))
      (magit-diff-base-highlight ((t :background ,(c 'bg-changed) :foreground ,(c 'fg-changed))))
      (magit-diff-context ((t :inherit shadow)))
      (magit-diff-context-highlight ((t :background ,(c 'bg-dim) :foreground ,(c 'fg-dim))))
      (magit-diff-file-heading ((t :inherit bold)))
      (magit-diff-file-heading-highlight ((t :inherit (bold magit-section-highlight))))
      (magit-diff-file-heading-selection ((t :inherit bold :background ,(c 'bg-hover-secondary))))
      (magit-diff-hunk-heading ((t :background ,(c 'bg-inactive))))
      (magit-diff-hunk-heading-highlight ((t :inherit bold :background ,(c 'bg-active) :foreground ,(c 'fg-main))))
      (magit-diff-hunk-heading-selection ((t :inherit bold :background ,(c 'bg-hover-secondary))))
      (magit-diff-hunk-region ((t :inherit bold)))
      (magit-diff-lines-boundary ((t :background ,(c 'fg-main))))
      (magit-diff-lines-heading ((t :background ,(c 'fg-dim) :foreground ,(c 'bg-main))))
      (magit-diff-revision-summary ((t :inherit bold)))
      (magit-diff-revision-summary-highlight ((t :inherit (bold magit-section-highlight))))
      (magit-diff-whitespace-warning ((t :inherit trailing-whitespace)))
      (magit-diffstat-added ((t :foreground ,(c 'fg-added))))
      (magit-diffstat-removed ((t :foreground ,(c 'fg-removed))))
      (magit-dimmed ((t :inherit shadow)))
      (magit-filename ((t :foreground ,(c 'identifier-value))))
      (magit-hash ((t :foreground ,(c 'identifier-name))))
      (magit-head ((t :inherit magit-branch-local)))
      (magit-header-line ((t :inherit bold)))
      (magit-header-line-key ((t :inherit ao-theme-key-binding)))
      (magit-header-line-log-select ((t :inherit bold)))
      (magit-keyword ((t :foreground ,(c 'magenta))))
      (magit-keyword-squash ((t :inherit bold :foreground ,(c 'warning))))
      (magit-log-author ((t :foreground ,(c 'identifier-name))))
      (magit-log-date ((t :foreground ,(c 'date-common))))
      (magit-log-graph ((t :inherit shadow)))
      (magit-mode-line-process ((t :inherit bold :foreground ,(c 'accent))))
      (magit-mode-line-process-error ((t :inherit bold :foreground ,(c 'err))))
      (magit-process-ng ((t :inherit error)))
      (magit-process-ok ((t :inherit success)))
      (magit-reflog-amend ((t :inherit warning)))
      (magit-reflog-checkout ((t :inherit bold :foreground ,(c 'blue-warmer))))
      (magit-reflog-cherry-pick ((t :inherit success)))
      (magit-reflog-commit ((t :inherit bold)))
      (magit-reflog-merge ((t :inherit success)))
      (magit-reflog-other ((t :inherit bold :foreground ,(c 'cyan))))
      (magit-reflog-rebase ((t :inherit bold :foreground ,(c 'magenta))))
      (magit-reflog-remote ((t :inherit (bold magit-branch-remote))))
      (magit-reflog-reset ((t :inherit error)))
      (magit-refname ((t :inherit shadow)))
      (magit-refname-pullreq ((t :inherit shadow)))
      (magit-refname-stash ((t :inherit shadow)))
      (magit-refname-wip ((t :inherit shadow)))
      (magit-section ((t :background ,(c 'bg-dim) :foreground ,(c 'fg-main))))
      (magit-section-heading ((t :inherit bold)))
      (magit-section-heading-selection ((t :inherit bold :background ,(c 'bg-hover-secondary))))
      (magit-section-highlight ((t :background ,(c 'bg-dim))))
      (magit-sequence-done ((t :inherit success)))
      (magit-sequence-drop ((t :inherit error)))
      (magit-sequence-exec ((t :inherit bold :foreground ,(c 'magenta))))
      (magit-sequence-head ((t :inherit bold :foreground ,(c 'cyan))))
      (magit-sequence-onto ((t :inherit (bold shadow))))
      (magit-sequence-part ((t :inherit warning)))
      (magit-sequence-pick ((t :inherit bold)))
      (magit-sequence-stop ((t :inherit error)))
      (magit-signature-bad ((t :inherit error)))
      (magit-signature-error ((t :inherit error)))
      (magit-signature-expired ((t :inherit warning)))
      (magit-signature-expired-key ((t :foreground ,(c 'warning))))
      (magit-signature-good ((t :inherit success)))
      (magit-signature-revoked ((t :inherit bold :foreground ,(c 'warning))))
      (magit-signature-untrusted ((t :inherit (bold shadow))))
      (magit-tag ((t :foreground ,(c 'yellow-cooler))))
      (git-timemachine-commit ((t :inherit warning)))
      (git-timemachine-minibuffer-author-face ((t :foreground ,(c 'identifier-name))))
      (git-timemachine-minibuffer-detail-face ((t :foreground ,(c 'fg-main)))))))

(defun ao-theme--faces-dired-and-dirvish (palette)
  "Return the dired and Dirvish face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (dired-directory ((t :foreground ,(c 'blue-cooler))))
      (dired-symlink ((t :inherit button :foreground ,(c 'cyan))))
      (dired-broken-symlink ((t :inherit button :foreground ,(c 'err))))
      (dired-header ((t :inherit bold)))
      (dired-ignored ((t :inherit shadow)))
      (dired-mark ((t :inherit bold)))
      (dired-marked ((t :inherit ao-theme-mark-sel)))
      (dired-flagged ((t :inherit ao-theme-mark-del)))
      (dired-perm-write ((t :inherit shadow)))
      (dired-set-id ((t :inherit bold :foreground ,(c 'red-warmer))))
      (dired-special ((t :foreground ,(c 'magenta))))
      (dired-warning ((t :inherit warning)))
      (dired-async-failures ((t :inherit error)))
      (dired-async-message ((t :inherit bold)))
      (dired-async-mode-message ((t :inherit bold)))
      (dirvish-hl-line ((t :inherit hl-line)))
      (dirvish-inactive ((t :inherit shadow)))
      (dirvish-vc-needs-merge-face ((t :background ,(c 'bg-red-subtle))))
      (dirvish-vc-unregistered-face ((t :inherit shadow)))
      (dired-subtree-depth-1-face (( )))
      (dired-subtree-depth-2-face (( )))
      (dired-subtree-depth-3-face (( )))
      (dired-subtree-depth-4-face (( )))
      (dired-subtree-depth-5-face (( )))
      (dired-subtree-depth-6-face (( )))
      (diredfl-autofile-name ((t :background ,(c 'bg-dim))))
      (diredfl-compressed-file-name ((t :foreground ,(c 'yellow-cooler))))
      (diredfl-compressed-file-suffix ((t :foreground ,(c 'red))))
      (diredfl-date-time ((t :foreground ,(c 'date-common))))
      (diredfl-deletion ((t :inherit dired-flagged)))
      (diredfl-deletion-file-name ((t :inherit diredfl-deletion)))
      (diredfl-dir-heading ((t :inherit bold)))
      (diredfl-dir-name ((t :inherit dired-directory)))
      (diredfl-dir-priv ((t :inherit dired-directory)))
      (diredfl-exec-priv ((t :foreground ,(c 'green-warmer))))
      (diredfl-executable-tag ((t :inherit diredfl-exec-priv)))
      (diredfl-file-name ((t :foreground ,(c 'fg-main))))
      (diredfl-file-suffix ((t :foreground ,(c 'cyan))))
      (diredfl-flag-mark ((t :inherit dired-marked)))
      (diredfl-flag-mark-line ((t :inherit dired-marked)))
      (diredfl-ignored-file-name ((t :inherit shadow)))
      (diredfl-link-priv ((t :foreground ,(c 'blue-warmer))))
      (diredfl-no-priv ((t :inherit shadow)))
      (diredfl-number ((t :inherit shadow)))
      (diredfl-other-priv ((t :foreground ,(c 'yellow))))
      (diredfl-rare-priv ((t :foreground ,(c 'red))))
      (diredfl-read-priv ((t :foreground ,(c 'fg-main))))
      (diredfl-symlink ((t :inherit dired-symlink)))
      (diredfl-write-priv ((t :foreground ,(c 'red-cooler)))))))

(defun ao-theme--faces-org-mode-and-friends (palette)
  "Return the org mode and friends face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (org-level-1 ((t :inherit ao-theme-heading-1)))
      (org-level-2 ((t :inherit ao-theme-heading-2)))
      (org-level-3 ((t :inherit ao-theme-heading-3)))
      (org-level-4 ((t :inherit ao-theme-heading-4)))
      (org-level-5 ((t :inherit ao-theme-heading-5)))
      (org-level-6 ((t :inherit ao-theme-heading-6)))
      (org-level-7 ((t :inherit ao-theme-heading-7)))
      (org-level-8 ((t :inherit ao-theme-heading-8)))
      (org-document-title ((t :inherit ao-theme-heading-0)))
      (org-document-info ((t :foreground ,(c 'fg-alt))))
      (org-document-info-keyword ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'fg-dim))))
      (org-archived ((t :inherit shadow)))
      (org-block ((t :inherit ao-theme-fixed-pitch :background ,(c 'bg-dim) :extend t)))
      (org-block-begin-line ((t :inherit ao-theme-fixed-pitch :background ,(c 'bg-dim)
                                :foreground ,(c 'fg-dim) :extend t)))
      (org-block-end-line ((t :inherit org-block-begin-line)))
      (org-quote ((t :inherit org-block)))
      (org-verse ((t :inherit org-block)))
      (org-code ((t :inherit ao-theme-prose-code)))
      (org-verbatim ((t :inherit ao-theme-prose-verbatim)))
      (org-macro ((t :inherit ao-theme-prose-macro)))
      (org-formula ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'fg-alt))))
      (org-table ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'prose-table))))
      (org-table-header ((t :inherit (bold org-table))))
      (org-todo ((t :foreground ,(c 'prose-todo))))
      (org-done ((t :foreground ,(c 'prose-done))))
      (org-headline-todo ((t :foreground ,(c 'prose-todo))))
      (org-headline-done ((t :inherit org-done)))
      (org-checkbox ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'yellow-warmer))))
      (org-checkbox-statistics-done ((t :inherit org-done)))
      (org-checkbox-statistics-todo ((t :inherit org-todo)))
      (org-date ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'date-common))))
      (org-date-selected ((t :inherit bold :foreground ,(c 'accent) :inverse-video t)))
      (org-time-grid ((t :foreground ,(c 'fg-dim))))
      (org-upcoming-deadline ((t :foreground ,(c 'date-deadline))))
      (org-upcoming-distant-deadline ((t :foreground ,(c 'fg-main))))
      (org-scheduled ((t :foreground ,(c 'date-scheduled))))
      (org-scheduled-previously ((t :inherit bold :foreground ,(c 'date-scheduled))))
      (org-scheduled-today ((t :inherit bold :foreground ,(c 'date-scheduled))))
      (org-imminent-deadline ((t :inherit bold :foreground ,(c 'date-deadline))))
      (org-tag ((t :foreground ,(c 'prose-tag))))
      (org-tag-group ((t :inherit (bold org-tag))))
      (org-drawer ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'fg-dim))))
      (org-special-keyword ((t :inherit org-drawer)))
      (org-property-value ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'identifier-value))))
      (org-meta-line ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'fg-dim))))
      (org-ellipsis (( )))
      (org-footnote ((t :inherit link)))
      (org-cite ((t :inherit link)))
      (org-cite-key ((t :inherit link)))
      (org-priority ((t :foreground ,(c 'magenta-cooler))))
      (org-agenda-structure ((t :inherit ao-theme-heading-2)))
      (org-agenda-structure-filter ((t :inherit (warning org-agenda-structure))))
      (org-agenda-structure-secondary ((t :inherit bold)))
      (org-agenda-date ((t :inherit ao-theme-heading-4)))
      (org-agenda-date-today ((t :inherit (bold org-agenda-date) :underline t)))
      (org-agenda-date-weekend ((t :inherit org-agenda-date :foreground ,(c 'date-weekend))))
      (org-agenda-date-weekend-today ((t :inherit (bold org-agenda-date-weekend))))
      (org-agenda-calendar-event ((t :foreground ,(c 'fg-main))))
      (org-agenda-calendar-sexp ((t :inherit ao-theme-slant :foreground ,(c 'fg-main))))
      (org-agenda-clocking ((t :background ,(c 'bg-yellow-subtle))))
      (org-agenda-column-dateline ((t :background ,(c 'bg-dim))))
      (org-agenda-current-time ((t :foreground ,(c 'accent))))
      (org-agenda-diary ((t :inherit shadow)))
      (org-agenda-done ((t :inherit org-done)))
      (org-agenda-filter-category ((t :inherit bold :foreground ,(c 'warning))))
      (org-agenda-filter-effort ((t :inherit bold :foreground ,(c 'warning))))
      (org-agenda-filter-regexp ((t :inherit bold :foreground ,(c 'warning))))
      (org-agenda-filter-tags ((t :inherit bold :foreground ,(c 'warning))))
      (org-agenda-restriction-lock ((t :background ,(c 'bg-dim) :foreground ,(c 'fg-dim))))
      (org-clock-overlay ((t :inherit ao-theme-search-replace)))
      (org-column ((t :inherit default :background ,(c 'bg-dim))))
      (org-column-title ((t :inherit (bold default) :background ,(c 'bg-dim) :underline t)))
      (org-dispatcher-highlight ((t :inherit bold :background ,(c 'bg-hover-secondary))))
      (org-latex-and-related ((t :foreground ,(c 'magenta-faint))))
      (org-mode-line-clock ((t :inherit bold)))
      (org-mode-line-clock-overrun ((t :inherit bold :foreground ,(c 'err))))
      (org-warning ((t :inherit warning)))
      (org-hide ((t :foreground ,(c 'bg-main))))
      (org-indent ((t :inherit (fixed-pitch org-hide))))
      (org-sexp-date ((t :foreground ,(c 'date-common))))
      (org-habit-alert-face ((t :background ,(c 'bg-yellow-intense) :foreground ,(c 'fg-main))))
      (org-habit-alert-future-face ((t :background ,(c 'bg-yellow-subtle))))
      (org-habit-clear-face ((t :background ,(c 'bg-blue-intense) :foreground ,(c 'fg-main))))
      (org-habit-clear-future-face ((t :background ,(c 'bg-blue-subtle))))
      (org-habit-overdue-face ((t :background ,(c 'bg-red-intense) :foreground ,(c 'fg-main))))
      (org-habit-overdue-future-face ((t :background ,(c 'bg-red-subtle))))
      (org-habit-ready-face ((t :background ,(c 'bg-green-intense) :foreground ,(c 'fg-main))))
      (org-habit-ready-future-face ((t :background ,(c 'bg-green-subtle))))
      (org-super-agenda-header ((t :inherit ao-theme-heading-3)))
      (org-bullet ((t :foreground ,(c 'accent))))
      (org-superstar-header-bullet ((t :foreground ,(c 'accent))))
      (org-superstar-item ((t :foreground ,(c 'fg-main))))
      (org-superstar-leading ((t :foreground ,(c 'fg-dim))))
      (org-msg-header-properties ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'identifier-value))))
      (org-msg-recipients-headers ((t :inherit ao-theme-fixed-pitch :foreground ,(c 'fg-alt))))
      (org-msg-edit-field ((t :inherit widget-field)))
      (toc-org-face ((t :inherit shadow))))))

(defun ao-theme--faces-denote (palette)
  "Return the denote face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (denote-faces-date ((t :foreground ,(c 'date-common))))
      (denote-faces-day ((t :foreground ,(c 'date-common))))
      (denote-faces-month ((t :foreground ,(c 'date-common))))
      (denote-faces-year ((t :foreground ,(c 'date-common))))
      (denote-faces-time ((t :inherit denote-faces-date)))
      (denote-faces-time-delimiter ((t :inherit shadow)))
      (denote-faces-delimiter ((t :inherit shadow)))
      (denote-faces-extension ((t :inherit shadow)))
      (denote-faces-keywords ((t :inherit bold :foreground ,(c 'prose-tag))))
      (denote-faces-signature ((t :inherit bold :foreground ,(c 'identifier-name))))
      (denote-faces-subdirectory ((t :inherit bold :foreground ,(c 'fg-alt))))
      (denote-faces-title ((t :foreground ,(c 'heading-0))))
      (denote-faces-prompt-current-name ((t :inherit ao-theme-slant :foreground ,(c 'fg-main))))
      (denote-faces-prompt-new-name ((t :inherit bold :foreground ,(c 'info))))
      (denote-faces-prompt-old-name ((t :inherit ao-theme-slant :foreground ,(c 'fg-dim)))))))

(defun ao-theme--faces-programming-support (palette)
  "Return the programming support face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (flymake-error ((t :inherit ao-theme-lang-error)))
      (flymake-warning ((t :inherit ao-theme-lang-warning)))
      (flymake-note ((t :inherit ao-theme-lang-note)))
      (flymake-error-echo ((t :inherit error)))
      (flymake-warning-echo ((t :inherit warning)))
      (flymake-note-echo ((t :inherit success)))
      (flymake-end-of-line-diagnostics-face ((t :inherit ao-theme-slant :height 0.85 :box ,(c 'border))))
      (flymake-error-echo-at-eol ((t :inherit flymake-end-of-line-diagnostics-face :foreground ,(c 'err))))
      (flymake-warning-echo-at-eol ((t :inherit flymake-end-of-line-diagnostics-face :foreground ,(c 'warning))))
      (flymake-note-echo-at-eol ((t :inherit flymake-end-of-line-diagnostics-face :foreground ,(c 'info))))
      (flymake-popon ((t :background ,(c 'bg-dim) :foreground ,(c 'fg-main))))
      (flymake-popon-border ((t :foreground ,(c 'fg-divider))))
      (flyspell-duplicate ((t :inherit ao-theme-lang-warning)))
      (flyspell-incorrect ((t :inherit ao-theme-lang-error)))
      (jinx-misspelled ((t :inherit ao-theme-lang-warning)))
      (jinx-highlight ((t :inherit ao-theme-search-current)))
      (jinx-accept ((t :inherit ao-theme-slant :foreground ,(c 'fg-dim))))
      (jinx-key ((t :inherit ao-theme-key-binding)))
      (jinx-save ((t :inherit success)))
      (eglot-diagnostic-tag-unnecessary-face ((t :inherit ao-theme-lang-note)))
      (eglot-diagnostic-tag-deprecated-face ((t :inherit shadow :strike-through t)))
      (eglot-highlight-symbol-face ((t :inherit bold :background ,(c 'bg-hover))))
      (eglot-mode-line ((t :inherit bold :foreground ,(c 'accent))))
      (eglot-mode-line-none-face ((t :inherit shadow)))
      (eldoc-highlight-function-argument ((t :inherit bold :background ,(c 'bg-active-argument)
                                             :foreground ,(c 'fg-active-argument))))
      (compilation-error ((t :inherit error)))
      (compilation-warning ((t :inherit warning)))
      (compilation-info ((t :inherit success)))
      (compilation-mode-line-exit ((t :inherit bold)))
      (compilation-mode-line-fail ((t :inherit bold :foreground ,(c 'err))))
      (compilation-mode-line-run ((t :inherit bold :foreground ,(c 'warning))))
      (compilation-line-number ((t :inherit shadow)))
      (compilation-column-number ((t :inherit shadow)))
      (next-error ((t :inherit ao-theme-prominent-error :extend t)))
      (next-error-message ((t :background ,(c 'bg-hover) :extend t)))
      (sp-pair-overlay-face ((t :background ,(c 'bg-hover))))
      (sp-show-pair-match-face ((t :inherit show-paren-match)))
      (sp-show-pair-mismatch-face ((t :inherit show-paren-mismatch)))
      (sp-wrap-overlay-face ((t :inherit sp-pair-overlay-face)))
      (sp-wrap-tag-overlay-face ((t :inherit sp-pair-overlay-face)))
      (rainbow-delimiters-base-error-face ((t :inherit error)))
      (rainbow-delimiters-depth-1-face ((t :foreground ,(c 'fg-main))))
      (rainbow-delimiters-depth-2-face ((t :foreground ,(c 'magenta-cooler))))
      (rainbow-delimiters-depth-3-face ((t :foreground ,(c 'cyan-cooler))))
      (rainbow-delimiters-depth-4-face ((t :foreground ,(c 'yellow-warmer))))
      (rainbow-delimiters-depth-5-face ((t :foreground ,(c 'blue-warmer))))
      (rainbow-delimiters-depth-6-face ((t :foreground ,(c 'green-cooler))))
      (rainbow-delimiters-depth-7-face ((t :foreground ,(c 'red-cooler))))
      (rainbow-delimiters-depth-8-face ((t :foreground ,(c 'magenta-warmer))))
      (rainbow-delimiters-depth-9-face ((t :foreground ,(c 'cyan))))
      (rainbow-delimiters-mismatched-face ((t :inherit show-paren-mismatch)))
      (rainbow-delimiters-unmatched-face ((t :inherit show-paren-mismatch)))
      (yas-field-highlight-face ((t :background ,(c 'bg-hover))))
      (csv-separator-face ((t :foreground ,(c 'accent))))
      (slime-error-face ((t :inherit ao-theme-lang-error)))
      (slime-note-face ((t :inherit ao-theme-lang-note)))
      (slime-style-warning-face ((t :inherit ao-theme-lang-note)))
      (slime-warning-face ((t :inherit ao-theme-lang-warning)))
      (slime-highlight-face ((t :inherit highlight)))
      (slime-repl-inputed-output-face ((t :foreground ,(c 'info))))
      (slime-repl-output-mouseover-face ((t :inherit highlight)))
      (font-latex-bold-face ((t :inherit bold)))
      (font-latex-italic-face ((t :inherit italic)))
      (font-latex-math-face ((t :inherit font-lock-constant-face)))
      (font-latex-sectioning-5-face ((t :inherit ao-theme-heading-5)))
      (font-latex-script-char-face ((t :inherit font-lock-builtin-face)))
      (font-latex-sedate-face ((t :inherit font-lock-keyword-face)))
      (font-latex-string-face ((t :inherit font-lock-string-face)))
      (font-latex-verbatim-face ((t :inherit ao-theme-prose-verbatim)))
      (font-latex-warning-face ((t :inherit font-lock-warning-face))))))

(defun ao-theme--faces-mail-chat-and-news (palette)
  "Return the mail, chat and news face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (erc-action-face ((t :inherit ao-theme-slant)))
      (erc-bold-face ((t :inherit bold)))
      (erc-button ((t :inherit button)))
      (erc-command-indicator-face ((t :inherit bold :foreground ,(c 'cyan))))
      (erc-current-nick-face ((t :inherit bold :foreground ,(c 'accent))))
      (erc-dangerous-host-face ((t :inherit error)))
      (erc-direct-msg-face ((t :foreground ,(c 'magenta))))
      (erc-error-face ((t :inherit error)))
      (erc-fool-face ((t :inherit shadow)))
      (erc-input-face ((t :foreground ,(c 'fg-main))))
      (erc-inverse-face ((t :inverse-video t)))
      (erc-keyword-face ((t :inherit bold :foreground ,(c 'warning))))
      (erc-my-nick-face ((t :inherit bold :foreground ,(c 'accent))))
      (erc-my-nick-prefix-face ((t :inherit erc-my-nick-face)))
      (erc-nick-default-face ((t :inherit bold :foreground ,(c 'blue-cooler))))
      (erc-nick-msg-face ((t :inherit warning)))
      (erc-nick-prefix-face ((t :inherit erc-nick-default-face)))
      (erc-notice-face ((t :inherit font-lock-comment-face)))
      (erc-pal-face ((t :inherit bold :foreground ,(c 'magenta-warmer))))
      (erc-prompt-face ((t :inherit ao-theme-prompt)))
      (erc-timestamp-face ((t :foreground ,(c 'date-common))))
      (erc-underline-face ((t :underline t)))
      (mu4e-attach-number-face ((t :inherit bold :foreground ,(c 'fg-dim))))
      (mu4e-cited-1-face ((t :inherit message-cited-text-1)))
      (mu4e-cited-2-face ((t :inherit message-cited-text-2)))
      (mu4e-cited-3-face ((t :inherit message-cited-text-3)))
      (mu4e-cited-4-face ((t :inherit message-cited-text-4)))
      (mu4e-cited-5-face ((t :inherit message-cited-text-1)))
      (mu4e-cited-6-face ((t :inherit message-cited-text-2)))
      (mu4e-cited-7-face ((t :inherit message-cited-text-3)))
      (mu4e-compose-header-face ((t :inherit mu4e-compose-separator-face)))
      (mu4e-compose-separator-face ((t :inherit ao-theme-slant :foreground ,(c 'fg-dim))))
      (mu4e-contact-face ((t :inherit message-header-to)))
      (mu4e-context-face ((t :inherit bold)))
      (mu4e-draft-face ((t :foreground ,(c 'warning))))
      (mu4e-flagged-face ((t :foreground ,(c 'magenta-cooler))))
      (mu4e-footer-face ((t :inherit ao-theme-slant :foreground ,(c 'fg-dim))))
      (mu4e-forwarded-face ((t :inherit success)))
      (mu4e-header-face ((t :inherit shadow)))
      (mu4e-header-highlight-face ((t :inherit hl-line)))
      (mu4e-header-key-face ((t :inherit message-header-name)))
      (mu4e-header-marks-face ((t :inherit mu4e-header-key-face)))
      (mu4e-header-title-face ((t :foreground ,(c 'fg-alt))))
      (mu4e-header-value-face ((t :inherit message-header-other)))
      (mu4e-highlight-face ((t :inherit ao-theme-key-binding)))
      (mu4e-link-face ((t :inherit link)))
      (mu4e-modeline-face ((t :inherit bold :foreground ,(c 'accent))))
      (mu4e-ok-face ((t :inherit success)))
      (mu4e-region-code ((t :inherit ao-theme-prose-code)))
      (mu4e-related-face ((t :inherit (italic shadow))))
      (mu4e-replied-face ((t :foreground ,(c 'info))))
      (mu4e-special-header-value-face ((t :inherit message-header-subject)))
      (mu4e-system-face ((t :inherit shadow)))
      (mu4e-thread-fold-face ((t :foreground ,(c 'fg-dim))))
      (mu4e-title-face ((t :inherit ao-theme-heading-0)))
      (mu4e-trashed-face ((t :foreground ,(c 'err))))
      (mu4e-unread-face ((t :inherit bold)))
      (mu4e-url-number-face ((t :inherit shadow)))
      (mu4e-view-body-face ((t :inherit default)))
      (mu4e-warning-face ((t :inherit warning)))
      (message-header-name ((t :inherit bold :foreground ,(c 'fg-dim))))
      (message-header-newsgroups ((t :inherit bold :foreground ,(c 'magenta-cooler))))
      (message-header-to ((t :inherit bold :foreground ,(c 'fg-alt))))
      (message-header-cc ((t :foreground ,(c 'blue-faint))))
      (message-header-other ((t :foreground ,(c 'cyan-faint))))
      (message-header-subject ((t :inherit bold :foreground ,(c 'heading-0))))
      (message-header-xheader ((t :foreground ,(c 'magenta-faint))))
      (message-mml ((t :foreground ,(c 'info))))
      (message-separator ((t :background ,(c 'bg-alt))))
      (message-cited-text-1 ((t :foreground ,(c 'blue-faint))))
      (message-cited-text-2 ((t :foreground ,(c 'green-faint))))
      (message-cited-text-3 ((t :foreground ,(c 'yellow-faint))))
      (message-cited-text-4 ((t :foreground ,(c 'red-faint))))
      (gnus-button ((t :inherit button)))
      (ement-room-fully-read-marker ((t :inherit ao-theme-prominent-note)))
      (ement-room-membership ((t :inherit shadow)))
      (ement-room-mention ((t :inherit highlight)))
      (ement-room-name ((t :inherit bold)))
      (ement-room-reactions ((t :inherit shadow)))
      (ement-room-read-receipt-marker ((t :inherit ao-theme-prominent-note)))
      (ement-room-self ((t :inherit bold :foreground ,(c 'accent))))
      (ement-room-self-message ((t :foreground ,(c 'fg-alt))))
      (ement-room-timestamp ((t :inherit shadow)))
      (ement-room-timestamp-header ((t :inherit bold :foreground ,(c 'date-common))))
      (ement-room-user ((t :inherit bold :foreground ,(c 'blue-cooler)))))))

(defun ao-theme--faces-shells-terminals-and-processes (palette)
  "Return the shells, terminals and processes face specifications, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (comint-highlight-input ((t :inherit bold)))
      (comint-highlight-prompt ((t :inherit ao-theme-prompt)))
      (eshell-prompt ((t :inherit ao-theme-prompt)))
      (eshell-ls-archive ((t :foreground ,(c 'magenta-cooler))))
      (eshell-ls-backup ((t :inherit shadow)))
      (eshell-ls-clutter ((t :inherit shadow)))
      (eshell-ls-directory ((t :inherit dired-directory)))
      (eshell-ls-executable ((t :foreground ,(c 'green-warmer))))
      (eshell-ls-missing ((t :inherit error)))
      (eshell-ls-product ((t :inherit shadow)))
      (eshell-ls-readonly ((t :foreground ,(c 'yellow-faint))))
      (eshell-ls-special ((t :foreground ,(c 'magenta))))
      (eshell-ls-symlink ((t :inherit dired-symlink)))
      (eshell-ls-unreadable ((t :inherit shadow)))
      (sh-heredoc ((t :inherit font-lock-string-face)))
      (sh-quoted-exec ((t :inherit font-lock-builtin-face)))
      (term ((t :background ,(c 'bg-main) :foreground ,(c 'fg-main))))
      (term-bold ((t :inherit bold)))
      (term-color-black ((t :background ,(c 'bg-main) :foreground ,(c 'fg-main))))
      (term-color-blue ((t :background ,(c 'blue) :foreground ,(c 'blue))))
      (term-color-cyan ((t :background ,(c 'cyan) :foreground ,(c 'cyan))))
      (term-color-green ((t :background ,(c 'green) :foreground ,(c 'green))))
      (term-color-magenta ((t :background ,(c 'magenta) :foreground ,(c 'magenta))))
      (term-color-red ((t :background ,(c 'red) :foreground ,(c 'red))))
      (term-color-white ((t :background ,(c 'fg-main) :foreground ,(c 'fg-main))))
      (term-color-yellow ((t :background ,(c 'yellow) :foreground ,(c 'yellow))))
      (term-underline ((t :underline t))))))

(defun ao-theme--faces-transient-ibuffer-speedbar-and-other-ui (palette)
  "Return the transient, ibuffer and other UI faces, for PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `(
      (transient-key ((t :inherit ao-theme-key-binding)))
      (transient-key-exit ((t :inherit ao-theme-key-binding :foreground ,(c 'err))))
      (transient-key-noop ((t :inherit (shadow ao-theme-key-binding))))
      (transient-key-return ((t :inherit ao-theme-key-binding :foreground ,(c 'warning))))
      (transient-key-stay ((t :inherit ao-theme-key-binding :foreground ,(c 'info))))
      (transient-key-stack ((t :inherit ao-theme-key-binding :foreground ,(c 'magenta-cooler))))
      (transient-active-infix ((t :background ,(c 'bg-hover-secondary))))
      (transient-argument ((t :inherit bold :background ,(c 'bg-active-argument)
                              :foreground ,(c 'fg-active-argument))))
      (transient-delimiter ((t :inherit shadow)))
      (transient-disabled-suffix ((t :inherit ao-theme-prominent-error)))
      (transient-enabled-suffix ((t :background ,(c 'bg-added) :foreground ,(c 'fg-added))))
      (transient-heading ((t :inherit bold :foreground ,(c 'heading-2))))
      (transient-inactive-argument ((t :inherit shadow)))
      (transient-inactive-value ((t :inherit shadow)))
      (transient-inapt-suffix ((t :inherit (shadow ao-theme-slant))))
      (transient-mismatched-key ((t :underline t)))
      (transient-nonstandard-key ((t :underline t)))
      (transient-unreachable ((t :inherit shadow)))
      (transient-unreachable-key ((t :inherit shadow)))
      (transient-value ((t :inherit bold :foreground ,(c 'identifier-value))))
      (ibuffer-locked-buffer ((t :foreground ,(c 'yellow-faint))))
      (ibuffer-filter-group-name-face ((t :inherit bold :foreground ,(c 'heading-3))))
      (ibuffer-marked-face ((t :inherit ao-theme-mark-sel)))
      (ibuffer-deletion-face ((t :inherit ao-theme-mark-del)))
      (speedbar-button-face ((t :inherit button)))
      (speedbar-directory-face ((t :inherit bold :foreground ,(c 'blue-cooler))))
      (speedbar-file-face ((t :foreground ,(c 'fg-main))))
      (speedbar-highlight-face ((t :inherit highlight)))
      (speedbar-selected-face ((t :inherit bold :foreground ,(c 'accent))))
      (speedbar-separator-face ((t :background ,(c 'bg-active))))
      (speedbar-tag-face ((t :foreground ,(c 'yellow-cooler))))
      (bookmark-face ((t :inherit ao-theme-prominent-note)))
      (bookmark-menu-bookmark ((t :inherit bold)))
      (bookmark-menu-heading ((t :inherit bold)))
      (package-description ((t :inherit default)))
      (package-help-section-name ((t :inherit bold)))
      (package-name ((t :inherit link)))
      (package-status-available ((t :foreground ,(c 'date-common))))
      (package-status-avail-obso ((t :inherit error)))
      (package-status-built-in ((t :foreground ,(c 'magenta-faint))))
      (package-status-dependency ((t :foreground ,(c 'magenta-cooler))))
      (package-status-disabled ((t :inherit error :strike-through t)))
      (package-status-external ((t :foreground ,(c 'cyan-cooler))))
      (package-status-held ((t :foreground ,(c 'yellow-warmer))))
      (package-status-incompat ((t :inherit warning)))
      (package-status-installed ((t :foreground ,(c 'yellow-faint))))
      (package-status-new ((t :inherit success)))
      (package-status-unsigned ((t :inherit error)))
      (calendar-month-header ((t :inherit bold)))
      (calendar-today ((t :inherit bold :underline t)))
      (calendar-weekday-header ((t :foreground ,(c 'date-weekday))))
      (calendar-weekend-header ((t :foreground ,(c 'date-weekend))))
      (diary ((t :foreground ,(c 'date-common))))
      (diary-anniversary ((t :foreground ,(c 'date-common))))
      (diary-time ((t :foreground ,(c 'date-common))))
      (holiday ((t :background ,(c 'bg-dim) :foreground ,(c 'date-weekend))))
      (tmr-mode-line-active ((t :inherit bold :foreground ,(c 'accent))))
      (tmr-mode-line-soon ((t :inherit bold :foreground ,(c 'warning))))
      (tmr-mode-line-urgent ((t :inherit bold :foreground ,(c 'err))))
      (tmr-finished ((t :inherit success)))
      (tmr-duration ((t :foreground ,(c 'date-common))))
      (tmr-description ((t :foreground ,(c 'fg-main))))
      (tmr-is-acknowledged ((t :inherit shadow)))
      (tmr-must-be-acknowledged ((t :inherit bold :foreground ,(c 'err))))
      (substitute-match ((t :inherit ao-theme-search-replace)))
      (beframe-face ((t :inherit ao-theme-mark-sel)))
      (olivetti-fringe ((t :background ,(c 'bg-main))))
      (pdf-view-region ((t :inherit region)))
      (pdf-isearch-match ((t :inherit ao-theme-search-current)))
      (pdf-occur-document-face ((t :inherit shadow)))
      (pdf-occur-page-face ((t :inherit link)))
      (subed-currently-played-face ((t :inherit bold :foreground ,(c 'info))))
      (subed-region-face ((t :inherit region)))
      (whitespace-big-indent ((t :background ,(c 'bg-space-err))))
      (whitespace-empty ((t :background ,(c 'bg-space-err))))
      (whitespace-hspace ((t :foreground ,(c 'fg-space))))
      (whitespace-indentation ((t :foreground ,(c 'fg-space))))
      (whitespace-line ((t :background ,(c 'bg-alt))))
      (whitespace-newline ((t :foreground ,(c 'fg-space))))
      (whitespace-space ((t :foreground ,(c 'fg-space))))
      (whitespace-space-after-tab ((t :background ,(c 'bg-space-err))))
      (whitespace-space-before-tab ((t :background ,(c 'bg-space-err))))
      (whitespace-tab ((t :foreground ,(c 'fg-space))))
      (whitespace-trailing ((t :inherit trailing-whitespace)))
      (hi-black-b ((t :inherit bold)))
      (hi-blue ((t :background ,(c 'bg-blue-subtle) :foreground ,(c 'fg-main))))
      (hi-green ((t :background ,(c 'bg-green-subtle) :foreground ,(c 'fg-main))))
      (hi-pink ((t :background ,(c 'bg-magenta-subtle) :foreground ,(c 'fg-main))))
      (hi-red-b ((t :inherit bold :foreground ,(c 'red))))
      (hi-salmon ((t :background ,(c 'bg-red-subtle) :foreground ,(c 'fg-main))))
      (hi-yellow ((t :background ,(c 'bg-yellow-subtle) :foreground ,(c 'fg-main))))
      (highlight-changes ((t :foreground ,(c 'warning))))
      (highlight-changes-delete ((t :foreground ,(c 'err) :strike-through t)))
      (outline-1 ((t :inherit ao-theme-heading-1)))
      (outline-2 ((t :inherit ao-theme-heading-2)))
      (outline-3 ((t :inherit ao-theme-heading-3)))
      (outline-4 ((t :inherit ao-theme-heading-4)))
      (outline-5 ((t :inherit ao-theme-heading-5)))
      (outline-6 ((t :inherit ao-theme-heading-6)))
      (outline-7 ((t :inherit ao-theme-heading-7)))
      (outline-8 ((t :inherit ao-theme-heading-8)))
      (outline-minor-0 (( )))
      (Man-overstrike ((t :inherit bold :foreground ,(c 'magenta))))
      (Man-underline ((t :inherit underline :foreground ,(c 'cyan))))
      (Man-reverse ((t :inherit highlight)))
      (woman-addition ((t :foreground ,(c 'magenta-cooler))))
      (woman-bold ((t :inherit bold :foreground ,(c 'magenta))))
      (woman-italic ((t :inherit italic :foreground ,(c 'cyan))))
      (woman-unknown ((t :foreground ,(c 'yellow))))
      (rainbow-mode-hex-face (( )))
      (ligature-mode-face (( ))))))

(defun ao-theme--faces (palette)
  "Return every AO face specification, resolved against PALETTE."
  (append
   (ao-theme--faces-theme-owned-building-blocks palette)
   (ao-theme--faces-basic-faces palette)
   (ao-theme--faces-search-and-replace palette)
   (ao-theme--faces-font-lock palette)
   (ao-theme--faces-mode-line-tab-bar-and-tab-line palette)
   (ao-theme--faces-line-numbers palette)
   (ao-theme--faces-completion-minibuffer-and-in-buffer palette)
   (ao-theme--faces-which-key palette)
   (ao-theme--faces-widgets-custom-and-help palette)
   (ao-theme--faces-diffs-version-control-and-magit palette)
   (ao-theme--faces-dired-and-dirvish palette)
   (ao-theme--faces-org-mode-and-friends palette)
   (ao-theme--faces-denote palette)
   (ao-theme--faces-programming-support palette)
   (ao-theme--faces-mail-chat-and-news palette)
   (ao-theme--faces-shells-terminals-and-processes palette)
   (ao-theme--faces-transient-ibuffer-speedbar-and-other-ui palette)))


;;;; Variables set by the theme

(defun ao-theme--variables (palette)
  "Return the AO custom variable settings, resolved against PALETTE."
  (cl-flet ((c (key) (ao-theme--color key palette)))
    `((ansi-color-names-vector
       [,(c 'bg-main) ,(c 'red) ,(c 'green) ,(c 'yellow)
        ,(c 'blue) ,(c 'magenta) ,(c 'cyan) ,(c 'fg-main)])
      (rainbow-html-colors-major-mode-list
       '(html-mode css-mode php-mode nxml-mode xml-mode)))))

;;;; Theme definition

(defun ao-theme--define (theme variant)
  "Define THEME using the palette of VARIANT, a symbol: `dark' or `light'."
  (let ((palette (ao-theme--palette variant)))
    (setq ao-theme--current-palette palette)
    (apply #'custom-theme-set-faces theme (ao-theme--faces palette))
    (apply #'custom-theme-set-variables theme (ao-theme--variables palette))))

;;;; Commands

(defun ao-theme--load (theme)
  "Disable the enabled themes, load THEME, then run the after-load hook."
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme theme t)
  (run-hooks 'ao-theme-after-load-hook)
  theme)

;;;###autoload
(defun ao-theme-load-dark ()
  "Load the `ao-dark' theme and run `ao-theme-after-load-hook'."
  (interactive)
  (ao-theme--load 'ao-dark))

;;;###autoload
(defun ao-theme-load-light ()
  "Load the `ao-light' theme and run `ao-theme-after-load-hook'."
  (interactive)
  (ao-theme--load 'ao-light))

;;;###autoload
(defun ao-theme-toggle ()
  "Toggle between the two themes in `ao-theme-to-toggle'.
Loads the first of them when neither is currently enabled, and runs
`ao-theme-after-load-hook' afterwards."
  (interactive)
  (pcase-let ((`(,one ,two) ao-theme-to-toggle))
    (unless (and one two)
      (user-error "`ao-theme-to-toggle' must name exactly two themes"))
    (ao-theme--load (if (memq one custom-enabled-themes) two one))))

;;;###autoload
(when load-file-name
  (let ((dir (file-name-directory load-file-name)))
    (unless (equal dir (expand-file-name "themes/" data-directory))
      (add-to-list 'custom-theme-load-path dir))))

(provide 'ao-theme)

;;; ao-theme.el ends here
