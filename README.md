# Ao

Ao for Emacs — still the [Ao theme for the Helix
editor](https://github.com/helix-editor/helix/blob/master/runtime/themes/ao.toml),
carried over hex-for-hex and paired with a new light variant built from
the same palette, with a toggle between them. Standalone: no dependency
on any other theme.

_Ao_ is 青 (あお), Japanese for blue — traditionally the whole blue-green
range, which is why 青信号 ("ao signal") is a green traffic light. The
palette is inspired by Fedora's official colour scheme.

```elisp
(add-to-list 'load-path        "/path/to/ao.theme")
(add-to-list 'custom-theme-load-path "/path/to/ao.theme")
(require 'ao-theme)
(ao-theme-load-dark)     ; or (load-theme 'ao-dark t)
```

| Command | Does |
| --- | --- |
| `ao-theme-toggle` | switch between `ao-dark` and `ao-light` |
| `ao-theme-load-dark` / `ao-theme-load-light` | load one directly |

All three disable the currently enabled themes first and then run
`ao-theme-after-load-hook`. A plain `load-theme` does neither.

## Where the colours come from

**`ao-dark`** is the Helix Ao theme, by the same author, carried over
hex-for-hex: ground, syntax, gutter, statusline and diagnostics all
match it exactly.

**`ao-light`** is that same Ao palette worked for a light ground, not a
second theme wearing the name. Every accent keeps its Ao hue and is
darkened only until it clears 4.5:1 on the page — the Helix colours are
tuned for a dark ground and are unreadable on white as-is. The neutrals
around them — white page, `#222222` body text, `#fafafa` panels,
`#e1e1e1` borders, `#1565c0` links — follow Fedora's official colour
scheme.

The **mode line is the same in both variants**: `#2c5484` on `#f3f4f6`,
as in Helix's `ui.statusline`. The tab bar mirrors it, as Helix's
bufferline does.

Org **code blocks** sit on `#fafafa` in `ao-light` — the Fedora panel
tone — while the text in them stays Ao.

### Signature colours

| Role | Dark | Light |
| --- | --- | --- |
| Ground | `#080d15` deep abyss | `#ffffff` |
| Text | `#dadada` | `#222222` |
| Cursor, matching paren | `#ff9000` blaze orange | `#ff9000` |
| Region | `#7533bd` light purple | `#7533bd` |
| Mode line | `#2c5484` twilight blue | `#2c5484` |
| Comment | `#838a97` slate gray | `#6a7282` |
| Code block | `#0d1526` | `#fafafa` |

### Syntax, following Helix's `ao.toml`

| | Dark | Light |
| --- | --- | --- |
| keyword | `#fa7970` | `#c5210f` |
| string, constant | `#45b1e8` | `#0a7ab3` |
| function | `#d2a8ff` | `#7d2ae8` |
| method, member | `#81be83` | `#3b7f3d` |
| variable, bracket | `#ff9000` | `#a85f00` |
| parameter, escape | `#ffba00` | `#946c00` |
| type, operator, punctuation | `#dadada` | `#222222` |

## Contrast

Every face that sets a foreground was checked against the background it
actually lands on, following `:inherit` chains. Of 678 such faces, all
meet 4.5:1 in `ao-dark`; in `ao-light` all do except the six 1px
divider and border faces, which sit at 3.28:1 — above the 3:1 that WCAG
asks of non-text UI components.

A few faces set a foreground equal to their background on purpose and
are exempt: `org-hide`, `org-indent`, `fill-column-indicator`, the
`term-color-*` swatches, and the `whitespace-*` markers.

## Customising

Four booleans, each off by default; re-load the theme after changing one:

- `ao-theme-bold-constructs` — bold keywords, types, builtins
- `ao-theme-italic-constructs` — italic comments and doc strings
- `ao-theme-mixed-fonts` — fixed-pitch code inside prose
- `ao-theme-variable-pitch-ui` — variable-pitch mode line, tab bar, header line

`ao-theme-tty-cursor-color` applies to **text-terminal frames only**
(`emacs -nw`, `emacsclient -nw`); graphical frames are left alone, where
the `cursor` face already decides and a palette override is the way to
change it. In a text terminal the terminal draws its own cursor and
ignores the `cursor` face, so a terminal whose cursor is a pale grey
leaves it invisible on the light variant's white ground.  This option
asks the terminal for a colour with an OSC 12 escape sequence:

```elisp
(setq ao-theme-tty-cursor-color t)          ; the palette's amber (default)
(setq ao-theme-tty-cursor-color "#000000")  ; a colour of your own
(setq ao-theme-tty-cursor-color nil)        ; leave the terminal alone
```

The value is read whenever a theme is enabled or a terminal frame is
created, so set it before loading the theme.  The terminal's own colour is
restored when the theme is disabled, and terminals that ignore OSC 12 are
unaffected.

Colours are overridable without forking, via
`ao-theme-common-palette-overrides` and the per-variant
`ao-theme-dark-palette-overrides` / `ao-theme-light-palette-overrides`.
A value may be a hex string, `unspecified`, or another palette key:

```elisp
;; The matching paren is an orange glyph on a dark chip, which the block
;; cursor inverts into an orange block on the paren at point.  For the
;; Helix look -- an orange block on both -- swap the two back:
(setq ao-theme-common-palette-overrides
      '((bg-paren-match accent)
        (fg-paren-match "#000000")))
```

`ao-theme-get-color-value` reads a colour out of the loaded variant, for
faces of your own:

```elisp
(set-face-attribute 'some-face nil
                    :foreground (ao-theme-get-color-value 'accent))
```

## Layout

| File | Holds |
| --- | --- |
| `ao-theme.el` | both palettes, the 844 face specs, the commands |
| `ao-dark-theme.el` / `ao-light-theme.el` | `deftheme` for each variant |

Faces cover core Emacs and the packages in use here: Org, Denote, Magit
and diff/ediff/smerge, Dired and Dirvish, the Vertico/Corfu/Consult/
Marginalia/Orderless stack, which-key, Transient, Eglot, Flymake, Jinx,
ERC, mu4e, Ement, Ibuffer, Speedbar, and the rest.

## Licence

GPL-3.0-or-later.
