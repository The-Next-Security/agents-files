# Dispatch Procedures — Agent Dispatch

Procedimientos operativos de referencia para el skill `agent-dispatch`.
Este archivo extiende el `SKILL.md` con detalle técnico que sería demasiado extenso
para el archivo principal. Todas las secciones son referenciadas desde el SKILL.md.

> Última actualización: 2026-05-23
> Propietario: Roy (Scrum Master, Capa 1)

---

## Idempotencia

Verificación obligatoria antes de cualquier spawn. Un spawn duplicado sobre el mismo
issue crea un worker huérfano que consume tokens y produce conflictos de worktree.

### Paso a paso

```
1. Leer sprint-state.json:
   exec "cat scrum/sprint-state.json"

2. Buscar en inProgress[] el item con id = "<repo>/<issue-id>":
   - Ejemplo: "The-Next-Security/TNS_TRACK_DEMO#46"

3. Evaluar escenario (ver tabla abajo)

4. Si hay workerSessionId activo → PARAR. Reportar a Felipe.
   Si no hay workerSessionId → continuar al spawn.

5. Post-spawn: registrar workerSessionId via sprint-manager.js:
   node sprint-manager.js set-worker <issue-id> <workerSessionId>
```

### Tabla de escenarios

| Estado en sprint-state.json | workerSessionId | qaStatus | Acción |
|-----------------------------|----------------|----------|--------|
| No está en inProgress | — | — | Proceder al spawn. Registrar entry post-spawn. |
| Está en inProgress | Sí | `in-progress` | **NO spawnar.** Worker activo. Reportar a Felipe. |
| Está en inProgress | Sí | `failed` | Activar `tns-debugger-triage`. Respawn solo tras RCA. |
| Está en inProgress | Sí | `passed` | Worker terminó. Verificar si hay PR pendiente de merge. |
| Está en inProgress | No | — | Inconsistencia de estado. Registrar workerSessionId y spawnar. |

### Formato de workerSessionId

```
<agentId>-<tipo>-<referencia>

Tipos válidos:
  fix     → corrección de bug (ej: backend-dev-fix-pr-121)
  issue   → implementación de issue (ej: backend-dev-issue-115)
  pr      → review de PR (ej: qa-analyst-pr-87)
  feat    → feature nueva (ej: frontend-dev-feat-onboarding)

Ejemplos reales del sistema:
  backend-dev-fix-pr-121
  backend-dev-issue-115
  qa-analyst-pr-87
```

---

## Task prompt

El task prompt es el único punto de comunicación entre Roy y el worker al momento del
spawn. Debe ser autocontenido: el worker no tiene acceso al contexto de la sesión de Roy,
ni al historial de mensajes anteriores.

### Template base obligatorio

```
Tarea: <descripción concisa de qué implementar o revisar>

Repo local: <ruta absoluta en el servidor, ej: /opt/tns-workbench/autonomous-workbench>
Branch base: dev
Feature branch: <feat/slug | fix/slug>
Worktree: <ruta absoluta del worktree, ej: /opt/tns-workbench/autonomous-workbench/worktrees/feat/slug>

Acceptance criteria:
- <criterio verificable 1>
- <criterio verificable 2>
- <criterio verificable N>

Pasos sugeridos:
1. cd <ruta repo>
2. git worktree add <worktree-path> -b <feature-branch> dev
3. <paso de implementación específico>
4. <paso de implementación específico>
N. git add <archivo> && git commit -m "<tipo>(<scope>): <descripción>"
N+1. git push -u origin <feature-branch>
N+2. gh pr create --base dev \
     --title "<tipo>: <descripción>" \
     --body "<resumen>" \
     --reviewer andresTNS \
     --reviewer Bufigol

Reglas que aplican:
- D-07: NUNCA commit/push directo a dev/main/master. Solo vía feature branch + PR.
- Un commit por archivo modificado. El historial git es sagrado.
- PR requiere 2 approvals incluyendo andresTNS antes de cualquier merge.
- Sin secretos, tokens ni credenciales en ningún archivo commiteado.

Entrega esperada: número de PR creado + URL
```

### Ejemplo — backend-dev implementando endpoint

```
Tarea: Implementar GET /health en infra/webhooks/github-handler.js

Repo local: /opt/tns-workbench/autonomous-workbench
Branch base: dev
Feature branch: feat/get-health-endpoint
Worktree: /opt/tns-workbench/autonomous-workbench/worktrees/feat/get-health-endpoint

Acceptance criteria:
- GET /health retorna HTTP 200
- Body: {"status":"ok","version":"<git-shortsha>","uptime":<process.uptime()>}
- No rompe el endpoint POST /webhooks/github existente
- Sin console.log de debug en el código commiteado

Pasos sugeridos:
1. cd /opt/tns-workbench/autonomous-workbench
2. git worktree add worktrees/feat/get-health-endpoint -b feat/get-health-endpoint dev
3. Implementar el endpoint en infra/webhooks/github-handler.js
4. git add infra/webhooks/github-handler.js
5. git commit -m "feat(health): agregar GET /health con status, version y uptime"
6. git push -u origin feat/get-health-endpoint
7. gh pr create --base dev \
   --title "feat: GET /health endpoint" \
   --body "Agrega endpoint de salud con status, version git y uptime del proceso." \
   --reviewer andresTNS \
   --reviewer Bufigol

Reglas que aplican:
- D-07: NUNCA commit/push a dev/main/master directamente.
- Un commit por archivo. Historial git es sagrado.
- PR requiere 2 approvals: andresTNS obligatorio.

Entrega esperada: número de PR + URL del PR creado.
```

### Ejemplo — qa-analyst revisando PR

```
Tarea: Revisar PR #121 en The-Next-Security/TNS_TRACK_DEMO

Repo local: /opt/tns-workbench/autonomous-workbench
PR target: https://github.com/The-Next-Security/TNS_TRACK_DEMO/pull/121

Acceptance criteria para aprobación:
- [BUG] Warning Critical dependency en react-datepicker resuelto
- Sin regresiones en endpoints existentes
- Dependencias alineadas con merges #116-#120
- CI verde: ESLint, Prettier, Build y formato de commits

Pasos sugeridos:
1. gh pr checkout 121 --repo The-Next-Security/TNS_TRACK_DEMO
2. gh pr diff 121 --repo The-Next-Security/TNS_TRACK_DEMO
3. Revisar criterios de aceptación uno por uno
4a. Si todo ok: gh pr review 121 --approve --body "QA: LGTM. Criterios verificados."
4b. Si hay issues: gh pr review 121 --request-changes --body "Issues: <lista detallada>"

Reglas que aplican:
- No aprobar si CI rojo o si hay conflictos pendientes.
- No hacer merge — eso es exclusivo de Felipe.

Entrega esperada: approved / changes-requested + detalle de qué se verificó.
```

---

## Spawn

Secuencia de acciones completa desde la verificación hasta el registro post-spawn.

```
1. VERIFICAR idempotencia (ver sección #idempotencia)
   → Si hay workerSessionId activo: PARAR.

2. VERIFICAR worktree disponible:
   exec "git worktree list" en el repo target
   → Si el worktree ya está en uso: PARAR. Elegir worktree alternativo o reportar a Felipe.

3. CONSTRUIR task prompt (ver sección #task-prompt)
   → Completar todas las secciones obligatorias.
   → Verificar que D-07 está incluido explícitamente.

4. REGISTRAR pre-spawn en agent-audit-trail:
   Entry: { acción: "spawn", agentId, issue, worktree, timestamp, promptHash }

5. EJECUTAR spawn:
   /subagents spawn con el task prompt construido en paso 3

6. REGISTRAR workerSessionId post-spawn en sprint-state.json:
   node sprint-manager.js set-worker <issue-id> <workerSessionId>

7. CONFIRMAR a Felipe (vía Aníbal):
   "Worker <agentId> spawneado para issue #<N>. workerSessionId: <id>. PR esperado en ~<tiempo>."
```

---

## Respawn

Flujo a seguir cuando un worker falló QA y Roy evalúa si debe respawnear.

```
1. LEER qaFailReason en sprint-state.json para el item:
   exec "cat scrum/sprint-state.json" → buscar qaStatus: "failed" y qaFailReason

2. ACTIVAR tns-debugger-triage:
   → Leer skills/tns-debugger-triage/SKILL.md
   → Producir RCA: síntoma, causa raíz, fix propuesto
   → Guardar en ~/tns-debug/rca-<repo>-<issue-id>.md

3. EVALUAR decisión de respawn:
   → Si el fix es claro y el worker puede implementarlo: respawnear con prompt actualizado
   → Si el problema requiere decisión de Felipe (scope change, arquitectura): escalar

4. Si se decide respawnear:
   → Limpiar worktree anterior si aplica: exec "git worktree remove <path> --force"
   → Crear workerSessionId nuevo: <agentId>-fix-pr-<nuevo-número>
   → Construir prompt actualizado incluyendo el RCA y el fix propuesto
   → Volver al flujo de #spawn desde el paso 1

5. REGISTRAR decisión en agent-audit-trail:
   Entry: { acción: "respawn", issue, qaFailReason, rcaPath, workerSessionIdAnterior, workerSessionIdNuevo }
```

---

## Paralelismo

Cuándo y cómo coordinar dos workers activos simultáneamente.

### Condiciones para paralelizar

Todas deben cumplirse:
```
[ ] Las dos features son independientes (sin dependencias entre sí)
[ ] Cada feature tiene su propio worktree en repos distintos o branches distintos
[ ] Ambas features están comprometidas en el sprint activo
[ ] Felipe autorizó el paralelismo explícitamente en esta sesión
[ ] El costo estimado de tokens es aceptable (2× worker + overhead de coordinación)
```

Si alguna condición falla → no paralelizar. Secuenciar.

### Costo de tokens (referencia para decisión)

| Operación | Costo estimado |
|-----------|---------------|
| Razonamiento directo de Roy | ~1K-3K tokens |
| Skill aplicada por Roy (coding-agent) | ~5K-15K tokens |
| Worker persistente (backend-dev, frontend-dev) | ~30K-100K tokens + tokens del worker |
| Dos workers en paralelo | 2× worker + ~10K-20K overhead de coordinación |

### Coordinación de dos workers activos

```
1. Spawnear worker A → registrar workerSessionId-A en sprint-state.json
2. Spawnear worker B → registrar workerSessionId-B en sprint-state.json
3. Monitorear ambos vía sprint-state.json (NO sessions_list — da timeout)
4. Cuando worker A termina: notificar a Felipe, activar qa-analyst para PR de A
5. Cuando worker B termina: ídem
6. No mergear ningún PR sin aprobación de Felipe — ambos pueden tener conflictos entre sí
```

---

## Escalamiento

Árbol de decisión para elegir el nivel correcto de ejecución.

```
¿La tarea cabe en el razonamiento directo de Roy?
(lectura de archivo, cálculo simple, consulta a sprint-state.json)
  ├── SÍ → Roy la hace directo. Sin skill, sin spawn.
  └── NO → continuar

¿La tarea requiere ejecutar código, leer repo o script rápido?
(< 30 min, sin commits, sin PR)
  ├── SÍ → Usar coding-agent. Efímero ligero, ~5K-15K tokens.
  └── NO → continuar

¿La tarea es una feature completa con commits, PR y QA?
(implementación real, > 30 min)
  ├── SÍ → Spawnar worker persistente (~30K-100K tokens).
  └── NO → revisar si es diagnóstico → usar tns-debugger-triage

¿Hay DOS features independientes y el sprint las requiere en paralelo?
  ├── SÍ + Felipe autorizó → Paralelizar. Ver sección #paralelismo.
  └── NO → Secuenciar. Worker A termina → Worker B inicia.
```

### Anti-patrones de escalamiento

```
❌ Spawnar worker para una tarea que Roy puede hacer en 5 min directo
❌ Paralelizar sin verificar que los worktrees son independientes
❌ Usar coding-agent para tareas que requieren commits y PR (es efímero, no persistente)
❌ Spawnear worker sin haber aplicado tns-debugger-triage cuando el issue es un bug
❌ Escalar dos capas de golpe (Roy → worker con subagentes propios) sin consultar a Felipe
```
