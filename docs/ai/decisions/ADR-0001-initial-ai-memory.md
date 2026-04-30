# ADR-0001: Crear memoria AI inicial

Fecha: 2026-04-30

## Estado

Aceptada.

## Contexto

El repositorio no tenía `README.md` raíz ni `docs/ai/**`. `AGENTS.md` indica usar onboarding y memoria durable antes de planificar cambios. El usuario pidió revisar el repositorio antes de futuros cambios sobre `.gitignore` y un instalador de OpenCode.

## Decisión

Crear memoria inicial bajo `docs/ai/**` con estructura mínima: índice, arquitectura, desarrollo, testing, ADR inicial y log mensual.

## Consecuencias

- Futuras sesiones pueden cargar contexto de forma progresiva sin redescubrir la estructura.
- La memoria no contiene plan de implementación; los cambios futuros deberán planificarse por fases tras aprobación.
