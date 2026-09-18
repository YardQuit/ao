;;; ao-light-theme.el --- The light variant of the AO theme -*- lexical-binding: t -*-

;; Copyright (C) 2026 Michael Jones

;; Author: Michael Jones <michael.jones.nzzn@use.startmail.com>
;; URL: https://github.com/mjones/ao.theme
;; Package-Requires: ((emacs "28.1"))
;; Keywords: faces, theme

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
;; The light variant of AO: a warm paper ground carrying the same amber
;; cursor and violet region as the dark variant.  See the `ao-theme'
;; library for the palette and the user options.

;;; Code:

(require 'ao-theme)

(deftheme ao-light
  "Light variant of the AO theme.
A warm paper ground (#fbf7f0) with an amber accent (#ff9000), a violet
selection (#7533bd) and a mode line mirrored by the tab bar."
  :background-mode 'light
  :kind 'color-scheme
  :family 'ao)

(ao-theme--define 'ao-light 'light)

(provide-theme 'ao-light)

;;; ao-light-theme.el ends here
