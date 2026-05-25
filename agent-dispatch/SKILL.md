---
name: agent-dispatch
description: Precondición obligatoria antes de cualquier spawn de worker — verifica idempotencia en sprint-state.json, construye el task prompt con contexto completo (worktree, acceptance criteria, repo, branch, regla D-07) y lo entrega listo para /subagents spawn. Usar cuando Roy va a delegar implementación, QA o diagnóstico a un worker de Capa 2 (backend-dev, frontend-dev, qa-analyst). Triggers: "spawna worker", "delega tarea", "dispatch", "implementa", "crea endpoint", "backend", "frontend", "qa", "review PR", "respawnear worker".
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-23
user-invocable: true
allowed-tools: Bash
tags: dispatch spawn worker delegation orchestration idempotency scrum prompt-engineering
compatibility: Requires sprint-state.json readable via exec+cat. Requires /subagents spawn available in Roy tool list.
metadata: {"openclaw":{"emoji":"🚀","riskLevel":"high","ownerAgent":"roy","requires":{"bins":[],"env":[]},"os":["linux","darwin"],"outputs":["spawnPrompt","auditEntry","workerSessionId"],"scrum":["planning","execution","pre-review"],"worksWithSkills":["agent-audit-trail","governance-wrapper","giraffe-guard","tns-debugger-triage","product-owner"]}}
---

# Agent Dispatch

Precondición obligatoria antes de cualquier `/subagents spawn`. Su rol no es ejecutar el
spawn, sino garantizar que cada spawn sea correcto, idempotente y trazable: verifica que
el worker no está ya activo, construye el task prompt con todos los datos que el worker
necesita para operar sin ambigüedad, y deja el audit trail antes y después del spawn.

**Roy no improvisa prompts al spawnar.** Toda delegación a un worker pasa por este skill.

---

## Cuándo activarme

- Roy va a delegar implementación de código a `backend-dev` o `frontend-dev`
- Roy va a delegar review de PR a `qa-analyst`
- Roy detecta que un worker anterior falló y evalúa si respawnear
- Roy quiere paralelizar dos features en workers separados
- Una feature se asignó en sprint-state.json y aún no tiene `workerSessionId`

---

## Protocolo de activación

Antes de operar, confirmar:

```
# ¿El issue/story tiene acceptance criteria claros?
#   Si NO → activar product-owner primero. No spawnar sin mini-spec.
# ¿Existe worktree libre para el worker target?
#   Verificar: exec "git worktree list" en el repo target
# ¿Ya existe un workerSessionId activo para este issue en sprint-state.json?
#   Si SÍ → NO spawnar. El worker ya existe. Ver sección "Idempotencia".
# ¿El riskLevel de la tarea es high?
#   Si SÍ → governance-wrapper ya está activo. Verificar que no hay bloqueo.
```

Si no hay acceptance criteria → no spawnar. Activar `product-owner` y esperar mini-spec.

---

## Flujo por evento Scrum

### Backlog Grooming

- Revisar items del sprint-state.json en estado `backlog` que no tengan `assignedRole` definido
- Marcar cuáles necesitarán spawn de worker vs. cuáles Roy puede resolver directo con una skill
- Aplicar heurística de escalamiento (ver sección "Heurística de escalamiento")
- Señal de alerta: si un issue tiene `confidence: low` en routingDecision → activar
  `product-owner` antes de incluir en sprint

### Sprint Planning

- Para cada story comprometida que requiera worker: verificar que el repo target tiene rama
  `dev` actualizada
- Confirmar que los workspaces de los workers existen: `agents/backend-dev/`,
  `agents/frontend-dev/`, `agents/qa-analyst/`
- Si un workspace no existe → loggear, avisar a Felipe. No planificar esa story.
- Crear entrada anticipada en sprint-state.json con `status: in-sprint` y `assignedRole`
  definido

### Daily Scrum

```
Estado de workers: [workerSessionId activos en sprint-state.json → status + prUrl si aplica]
Spawns pendientes: [stories en in-sprint sin workerSessionId asignado]
Bloqueos: [issues sin acceptance criteria / worktrees en conflicto / CI rojo sin diagnóstico]
```

### Ejecución durante el Sprint

Ver procedimientos detallados en `{baseDir}/references/dispatch-procedures.md`:
- Verificación de idempotencia → sección "Idempotencia"
- Construcción del task prompt → sección "Task prompt"
- Spawn y registro en sprint-state.json → sección "Spawn"
- Respawn tras fallo de QA → sección "Respawn"
- Paralelismo de workers → sección "Paralelismo"

### Pre-Sprint Review

```
[ ] Todos los items in-progress tienen workerSessionId registrado en sprint-state.json
[ ] Ningún worktree activo sin PR asociado (gh pr list para verificar)
[ ] Workers que fallaron QA tienen diagnóstico en ~/tns-debug/rca-*.md
[ ] Audit trail completo: cada spawn registrado vía agent-audit-trail
[ ] Sin worktrees huérfanos: git worktree list no muestra paths sin PR
```

### Sprint Retrospective

- ¿Cuántos spawns requirieron respawn? Causa raíz de cada uno
- ¿Algún spawn se ejecutó sin idempotencia verificada? (gap crítico)
- ¿El task prompt fue suficiente o el worker pidió clarificaciones? → mejorar template
- Propuestas de mejora al template del task prompt o al flujo de QA

---

## Heurística de escalamiento

Ante duda, escalar **una capa**, no dos. El costo de spawn sube exponencialmente.

```
¿La tarea cabe en mi razonamiento directo?
  → Hacerla directo. Sin skill, sin spawn.

¿La tarea requiere leer código o ejecutar script rápido?
  → Usar skill coding-agent (efímero ligero, ~5K-15K tokens).

¿La tarea es una feature completa con commits, PR y QA?
  → Spawnar worker persistente (~30K-100K tokens + tokens del worker).

¿Dos features son independientes Y no comparten worktree?
  → Paralelizar SOLO si ambas están en sprint activo y hay capacidad.
  → Costo: 2× + overhead de coordinación. Requiere aprobación de Felipe.
```

Ver árbol de decisión completo con costos en:
`{baseDir}/references/dispatch-procedures.md#escalamiento`

---

## Idempotencia — verificación obligatoria

Antes de cualquier spawn, leer `sprint-state.json` (disponible como symlink en workspace):

```bash
exec "cat scrum/sprint-state.json"
```

Buscar en `inProgress[]` un item donde `id` coincida con el issue target.

| Escenario | Acción |
|-----------|--------|
| Item no existe en `inProgress` | Proceder al spawn. Registrar `workerSessionId` al spawnear. |
| Item existe con `workerSessionId` y `status: in-progress` | **NO spawnar.** Worker ya activo. Reportar a Felipe. |
| Item existe con `workerSessionId` y QA falló | Activar `tns-debugger-triage` primero. Respawn solo tras RCA. |
| Item existe sin `workerSessionId` | Inconsistencia. Registrar entry y spawnar con idempotencia forzada. |

El `workerSessionId` sigue el formato: `<agentId>-<tipo>-<número>`.
Ejemplos: `backend-dev-fix-pr-121`, `qa-analyst-pr-87`, `backend-dev-issue-115`.

---

## Workers disponibles

| Worker | agentId | Cuándo delegarle |
|--------|---------|-----------------|
| `backend-dev` | `backend-dev` | Implementación de código, APIs, endpoints, DB, lógica de negocio, scripts |
| `frontend-dev` | `frontend-dev` | UI, componentes React, integraciones cliente, CSS |
| `qa-analyst` | `qa-analyst` | Review de PR, validación DoD, test plans, aprobación o request-changes |

Roy no usa `backend-developer`, `frontend-developer` ni `qa-analyst` directamente.
Delega a los workers que tienen esas skills en su allowlist.

---

## Construcción del task prompt

El task prompt es el documento que el worker recibe al ser spawneado. Debe ser
autocontenido: el worker no tiene contexto previo de la sesión de Roy.

**Secciones obligatorias del task prompt:**

```
Tarea: <descripción concisa de qué hacer>

Repo local: <ruta absoluta en el servidor>
Branch base: <dev>
Feature branch: <feat/slug o fix/slug>
Worktree: <ruta del worktree asignado>

Acceptance criteria:
- <criterio 1>
- <criterio 2>

Pasos sugeridos:
1. <paso>
2. <paso>
...N. Abrir PR a dev con reviewers: andresTNS, Bufigol

Reglas que aplican:
- D-07: NUNCA commit/push directo a dev/main/master. Solo vía feature branch + PR.
- Un commit por archivo modificado. Historial git es sagrado.
- PR requiere 2 approvals incluyendo andresTNS.

Entrega esperada: <PR número + URL / reporte QA / RCA>
```

Ver template completo con ejemplos reales (backend, frontend, QA) en:
`{baseDir}/references/dispatch-procedures.md#task-prompt`

---

## Relación con otros agentes

| Agente | Qué necesito de ellos | Qué les entrego |
|--------|----------------------|-----------------|
| **product-owner** | Mini-spec con acceptance criteria claros antes de spawnar | Señal de que el issue está listo para dispatch |
| **agent-audit-trail** | — | Entry de spawn: agentId, workerSessionId, issue, timestamp |
| **governance-wrapper** | Validación pasiva (siempre activa) — bloquea si la operación viola reglas | Contexto de la operación que voy a ejecutar |
| **giraffe-guard** | Detección de loops — alerta si estoy spawneando en ciclo | Señal de spawn (para que detecte patrones anómalos) |
| **tns-debugger-triage** | RCA cuando un worker falla QA — antes de decidir respawn | Resultado de QA (qaStatus, qaFailReason) del sprint-state.json |
| **backend-dev / frontend-dev / qa-analyst** | — | Task prompt completo + worktree asignado + workerSessionId |

---

## Límites duros

- ❌ **Nunca** spawnar sin verificar idempotencia en sprint-state.json primero
- ❌ **Nunca** spawnar si el issue no tiene acceptance criteria — activar product-owner primero
- ❌ **Nunca** incluir en el task prompt instrucciones de commit/push a `dev`, `main` o `master`
- ❌ **Nunca** spawnar dos workers sobre el mismo worktree simultáneamente
- ❌ **Nunca** respawnear tras fallo de QA sin diagnóstico previo de tns-debugger-triage
- ❌ **Nunca** paralelizar workers sin aprobación explícita de Felipe
- ❌ **Nunca** llamar `sessions_list` — produce timeout invariablemente; usar sprint-state.json
- ❌ **Nunca** omitir el registro de workerSessionId en sprint-state.json post-spawn
- ❌ **Nunca** spawnar con agentId desconocido — solo `backend-dev`, `frontend-dev`, `qa-analyst`

---

## KPIs de efectividad

| Indicador | Meta |
|-----------|------|
| Spawns idempotentes (sin duplicados) | 100% |
| Task prompts con todas las secciones obligatorias | 100% |
| Spawns con workerSessionId registrado en sprint-state.json | 100% |
| Workers que requirieron clarificaciones post-spawn | < 10% |
| Respawns sin diagnóstico previo de tns-debugger-triage | 0 |
| Paralelismos no autorizados por Felipe | 0 |

---

## Referencias

- Procedimientos completos de idempotencia, prompt y spawn:
  `{baseDir}/references/dispatch-procedures.md#idempotencia`
- Template del task prompt con ejemplos reales:
  `{baseDir}/references/dispatch-procedures.md#task-prompt`
- Flujo de respawn tras fallo de QA:
  `{baseDir}/references/dispatch-procedures.md#respawn`
- Paralelismo de workers — cuándo y cómo coordinarlo:
  `{baseDir}/references/dispatch-procedures.md#paralelismo`
- Heurística de escalamiento (skill vs efímero vs worker):
  `{baseDir}/references/dispatch-procedures.md#escalamiento`
