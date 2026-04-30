# Architecture notes

## Propósito

Repositorio personal de dotfiles y scripts de instalación/desinstalación para configurar herramientas de terminal en Ubuntu: Bash aliases, tmux, Alacritty, Docker, fzf, batcat, Nerd Fonts y perfil de VS Code.

## Estructura principal

- `dotfiles/`: configuraciones de usuario que se enlazan o copian hacia `$HOME`.
  - `bash_aliases`: aliases de shell; actualmente incluye aliases para `exa`, `batcat` y un alias Docker para `opencode-secure` en cambios locales.
  - `tmux.conf` y `tmux.conf.default`: configuración tmux y configuración base.
  - `alacritty.toml` y `alacritty.yml`: ambos formatos de configuración Alacritty se conservan intencionalmente por compatibilidad.
  - `vscode.code-profile`: perfil exportado de VS Code.
  - Thunderbird `msgFilterRules.dat` era obsoleto y fue removido.
- `install_*.sh`: entrypoints manuales para instalar componentes.
- `uninstall_docker.sh`: entrypoint destructivo para purgar Docker y datos asociados.
- `tmux_shortcuts.md`: documentación de atajos tmux.
- `AGENTS.md`, `opencode.jsonc`, `docs/ai/**`: workflow/configuración versionable de OpenCode/AI; `.opencode/` permanece local/ignorado.

## Entrypoints y efectos

- `install_bash_stuff.sh`: crea symlink de `dotfiles/bash_aliases` a `~/.bash_aliases`; respalda archivo existente con `.bak`.
- `install_tmux.sh`: instala `tmux` con `apt`, clona TPM y crea symlinks hacia `~/.config/tmux/`.
- `install_allacrity.sh`: compila Alacritty desde GitHub, instala dependencias, modifica alternatives, man pages, completions y config de Alacritty. Nota: el nombre parece tener typo (`allacrity`).
- `install_docker.sh`: instala Docker desde el repositorio oficial de Docker para Ubuntu y modifica grupos del sistema.
- `uninstall_docker.sh`: borra paquetes, datos en `/var/lib/docker`, configuración y reglas iptables tras confirmación interactiva.
- `install_fzf.sh`, `install_batcat.sh`, `install_nerd_fonts.sh`: instalaciones simples con `git`, `apt`, `wget`, `unzip` y movimiento de archivos.

## Señales de arquitectura

- Modelo simple, script-first: no hay framework, build system ni packaging raíz.
- Alcance confirmado Ubuntu-only (`apt`, rutas `/etc/apt`, `systemctl`, paquetes Ubuntu).
- Varias rutas están hardcodeadas a `~/dev/dotfiles` o rutas absolutas de usuario.
- Los scripts son manuales y no están orquestados por un instalador único.
- Los scripts se invocan con `bash script.sh`; no se requiere bit ejecutable.
