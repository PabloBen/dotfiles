# Testing notes

## Estado actual

- No se observó directorio `tests/` ni CI/CD (`.github/**` ausente).
- No hay linter/formateador configurado en el repositorio raíz.
- Durante onboarding se ejecutó `bash -n *.sh` y no reportó errores de sintaxis.

## Validación recomendada por tipo de cambio

- Cambios a scripts shell: `bash -n <script>` como mínimo; si se dispone de `shellcheck`, ejecutarlo antes de pruebas manuales.
- Cambios de permisos de scripts no son necesarios si se conserva la convención `bash script.sh`.
- Cambios de instalación: probar en VM/contenedor o entorno desechable antes de usar en la máquina principal.
- Cambios de symlinks: validar con rutas temporales o respaldos explícitos.
- Cambios de Docker/uninstall: revisar manualmente comandos destructivos y confirmar que el usuario acepta pérdida de datos.
- Cambios de tmux/Alacritty: cargar configuración manualmente (`tmux source-file`, arranque de Alacritty) solo en entorno del usuario.
- Cambios solo en `docs/ai/**`: revisar diff y confirmar que no se almacenan raw diffs ni logs largos.

## Riesgos de validación

- Muchos scripts tienen efectos de sistema y red; no deben ejecutarse automáticamente durante revisión.
- La falta de tests automatizados hace que la validación manual sea parte del Definition of Done.
