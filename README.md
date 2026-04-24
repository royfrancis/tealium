# tealium <span><a href="https://github.com/royfrancis/tealium"><img src="assets/logos/logo.webp" style="height:40px;vertical-align:middle;"></a></span> 

[![ci_badge](https://github.com/royfrancis/tealium/workflows/deploy/badge.svg)](https://github.com/royfrancis/tealium/actions?workflow=deploy)  [![linkcheck_badge](https://github.com/royfrancis/tealium/workflows/linkcheck/badge.svg)](https://github.com/royfrancis/tealium/actions?workflow=linkcheck)  [![lifecycle_badge](https://lifecycle.r-lib.org/articles/figures/lifecycle-experimental.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)

Quarto website template for courses

![Report home](preview-home.webp)

![Report preview](preview-report.webp)

![Slide preview](preview-slide.webp)

For a demo site and usage, see [here](https://royfrancis.github.io/tealium).

## Usage

- Recommended quarto 1.8.25 or higher
- To download and use a starter template, run in the terminal

:exclamation: Demo files are not downloaded

```
quarto use template royfrancis/tealium
```

- Install required extensions

```
quarto add --no-prompt quarto-ext/fontawesome
quarto add --no-prompt royfrancis/quarto-revealjs-header
quarto add --no-prompt royfrancis/quarto-revealjs-pointer
quarto add --no-prompt mcanouil/quarto-collapse-output@1.4.0
quarto add --no-prompt royfrancis/quarto-accordion
quarto add --no-prompt royfrancis/quarto-leaflet
quarto add --no-prompt royfrancis/quarto-particles
```

- Render all html files into `docs` directory to make sure everything works as expected

```
quarto render
```

- See more documentation on the [demo site](https://royfrancis.github.io/tealium/home_contents.html) for customization

## Showcase

Here is an example of this template in action:

- [RaukR 2026](https://nbisweden.github.io/raukr-2026/)

## Acknowledgements

- Built using [Quarto](https://quarto.org/)
- Uses the [fontawesome extension](https://github.com/quarto-ext/fontawesome) for icons
- Uses the [collapse-output extension](mcanouil/quarto-collapse-output@1.4.0) for code output folding

---

2026 • Roy Francis
