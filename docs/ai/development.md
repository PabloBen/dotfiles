# Development notes

## Stack y toolchain

- Bash scripts (`#!/usr/bin/env bash`) para instalación y configuración.
- Config files: TOML/YAML para Alacritty, tmux config, VS Code profile JSON exportado.
- OpenCode config: `opencode.jsonc`; `.opencode/package.json` depende de `@opencode-ai/plugin` `1.14.29`.
- Alcance de instaladores OpenCode: solo CLI/workflow local, no producto o servicio adicional.

## Comandos útiles

- Revisión de sintaxis shell sin ejecutar efectos: `bash -n *.sh`.
- Ejecución manual esperada: `bash <script>.sh`; no se requiere marcar scripts como ejecutables.
- Estado de cambios: `git status --short`.
- Revisión de modos/permisos versionados: `git ls-files -s`.

## Convenciones observadas

- Scripts en raíz con nombres `install_<herramienta>.sh` y `uninstall_<herramienta>.sh`.
- Mensajes de scripts principalmente en inglés; algunos usan emojis.
- Symlinks esperados desde `$HOME` hacia `~/dev/dotfiles/dotfiles`.
- Preferencia por cambios mínimos y memoria durable bajo `docs/ai/**` según `AGENTS.md`.
- `.opencode/` queda local/ignorado; `AGENTS.md`, `opencode.jsonc` y `docs/ai/**` son workflow files versionables.

## Estado de git observado durante onboarding

- Durante onboarding había cambios locales/untracked; preservar cambios del usuario.
- Los scripts `*.sh` se mantienen invocables con `bash script.sh`; no hay requisito de bit ejecutable.

## Riesgos para cambios futuros

- No sobrescribir cambios locales del usuario.
- Revisar con cuidado `.opencode/`: contiene tooling local y debe permanecer ignorado.
- Los scripts que usan `apt`, `rm -rf`, `usermod`, `groupdel`, `update-alternatives` o rutas del sistema requieren revisión manual antes de ejecución.
- Evitar convertir estos scripts en una instalación automática global sin aceptación explícita.
