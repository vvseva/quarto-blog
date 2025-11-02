Repository: Quarto-based personal website (vvseva/quarto-blog)

Purpose
- Help AI coding assistants be productive in this Quarto website repository: where to edit source, how to build/publish, and important repo conventions.

Quick facts (big picture)
- This is a Quarto website project. Primary source files are .qmd in the repo root and in `posts/`, `slides/`, `teaching/`, and top-level pages like `index.qmd`, `projects.qmd`, `teaching.qmd`.
- Rendered site output lives in `_site/` and vendored assets are under `site_libs/` and `_www/` — these are generated/compiled assets; avoid editing them directly.
- Execution artifacts and captured outputs for reproducibility are stored in `_freeze/` (see `_quarto.yml`: `execute: freeze: true`). Do not edit `_freeze/` unless intentionally updating frozen outputs.

Where to make content changes (source of truth)
- Edit the `.qmd` files under the repository root and `posts/` (e.g. `posts/11-OCMC24/ocmc24.qmd` and the data file `posts/11-OCMC24/ocmc24.csv`).
- For site-wide configuration and styling, edit `_quarto.yml` (theme, navbar, resources) and the custom scss/css files at the repo root (e.g. `litera_custom.scss`, `styles.css`).

Local developer workflow (commands you can run locally)
- Build the site locally: run `quarto render .` in the repository root.
- Serve a live preview: run `quarto preview` (or `quarto preview --no-browser` on headless systems).
- Use RStudio by opening `quarto-blog.Rproj` if you prefer an IDE.

CI / Publish behavior
- GitHub Actions workflow: `.github/workflows/publish.yml`. It triggers on `push` to `master` and on manual `workflow_dispatch`.
- The workflow uses `quarto-dev/quarto-actions/setup@v2` and `quarto-dev/quarto-actions/publish@v2` with `target: quarto-pub` and expects `secrets.QUARTO_PUB_AUTH_TOKEN` to be present.
- To publish the site manually/mimic CI locally, use the same Quarto publish target (note: actual publish from local machine requires a valid QUARTO_PUB_AUTH_TOKEN and the same publish target defined in `_publish.yml`).

Project-specific conventions & patterns
- Execution freeze: `_quarto.yml` sets `execute: freeze: true`. Many pages rely on frozen results in `_freeze/`; prefer editing source and re-rendering rather than editing the frozen outputs.
- Vendored libraries: `site_libs/` and `_www/` contain third-party JS/CSS shipped with the site. Replace only when intentionally upgrading/patching libraries.
- Content structure: use the existing directory conventions: `posts/` for blog posts, `slides/` for slide decks, `teaching/` for teaching materials.

Files to review when changing behavior
- `_quarto.yml` — global site config (theme, navbar, execution settings).
- `_publish.yml` — Quarto publish target and URL mapping.
- `.github/workflows/publish.yml` — CI actions and triggers.
- `quarto-blog.Rproj` — convenience for editing in RStudio.

Safety rules for AI edits (concrete and actionable)
1. Never modify generated directories: `_site/`, `_freeze/` (unless explicitly regenerating), or `site_libs/` without a clear reason and a matching build step.
2. When changing code chunks inside `.qmd` files that execute R/python, do not remove or ignore the repository's reproducibility intent (`execute: freeze: true`) without documenting why and running a full render.
3. For any change that affects the site layout/config, update `_quarto.yml` and verify locally with `quarto render` or `quarto preview` before opening a PR.

Examples to use as references
- Post with data: `posts/11-OCMC24/ocmc24.qmd` uses an accompanying CSV `posts/11-OCMC24/ocmc24.csv` — prefer editing the .qmd or the CSV in source rather than altering generated HTML.
- Navbar & resources: see `_quarto.yml` for how `projects.qmd`, `teaching.qmd`, and social icons are wired into the site.

What to include in a PR from an AI assistant
- Short description of the change, which `.qmd` files were edited, and whether a local `quarto render` was run successfully.
- If outputs changed intentionally (regenerating frozen outputs), list the steps taken to regenerate and any modified `_freeze/` files.

If anything here is unclear or you'd like the instructions to be more prescriptive (for example, exact preview flags or a required set of smoke tests), tell me which parts to expand and I will iterate.
