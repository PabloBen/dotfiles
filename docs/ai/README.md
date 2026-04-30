# AI memory

Repositorio de dotfiles e instaladores personales para entorno Ubuntu.

## Cómo usar esta memoria

- Leer este archivo después de `AGENTS.md` y antes de planificar cambios.
- Cargar solo los archivos necesarios según la tarea.
- No asumir que los scripts son seguros para ejecutar sin revisión: varios instalan paquetes, clonan repositorios o modifican archivos del sistema.

## Mapa rápido

- `architecture.md`: estructura, entrypoints y señales de arquitectura.
- `development.md`: convenciones, comandos y notas de trabajo local.
- `testing.md`: validación disponible y riesgos de pruebas.
- `decisions/ADR-0001-initial-ai-memory.md`: decisión inicial de memoria AI.
- `logs/2026-04.md`: registro breve de onboarding inicial.

## Estado conocido

- El repositorio se mantiene como Ubuntu-only.
- Los scripts se invocan con `bash script.sh`; no se requiere bit ejecutable versionado.
- No hay `README.md` raíz; la memoria durable vive bajo `docs/ai/**`.
- No se observó CI/CD ni suite de tests automatizada.
- `.opencode/` es local/ignorado; `AGENTS.md`, `opencode.jsonc` y `docs/ai/**` son archivos versionables del workflow.
