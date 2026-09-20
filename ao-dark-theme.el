;;; ao-dark-theme.el --- The dark variant of the AO theme -*- lexical-binding: t -*-

;; Copyright (C) 2026 Michael Jones

;; Author: Michael A Jones <yardquit@pm.me>
;; URL: https://github.com/YardQuit/ao
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
;; The dark variant of AO: a deep navy ground with an amber cursor, a
;; violet region and a steel-blue mode line, carried over hex-for-hex
;; from the AO theme for the Helix editor.  See the `ao-theme' library
;; for the palette and the user options.

;;; Code:

(require 'ao-theme)

(deftheme ao-dark
  "Dark variant of the AO theme.
A deep navy ground (#080d15) with an amber accent (#ff9000), a violet
selection (#7533bd) and a steel-blue mode line mirrored by the tab bar."
  :background-mode 'dark
  :kind 'color-scheme
  :family 'ao)

(ao-theme--define 'ao-dark 'dark)

(provide-theme 'ao-dark)

;;; ao-dark-theme.el ends here
