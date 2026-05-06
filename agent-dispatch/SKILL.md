---
name: agent-dispatch
description: 'Spawna workers persistentes (backend-dev, frontend-dev, qa-analyst) usando sessions_spawn. Usar cuando la tarea requiere delegar implementación de código, revisión de PR o QA a un worker de Capa 2. Triggers: "implementa", "crea endpoint", "abre PR", "review PR", "QA", "backend", "frontend", "qa", "spawna worker", "delega tarea", "dispatch".'
---

# Agent Dispatch — Cómo spawnar workers en TNS

## ⚠️ REGLA CRÍTICA ANTES DE CUALQUIER SPAWN

**`agentId` es OBLIGATORIO y debe ser el ID del worker target, NO "roy".**

Sin `agentId`, OpenClaw spawnea otro Roy en vez del worker. Siempre verifica:
- Backend → `agentId: "backend-dev"`
- Frontend → `agentId: "frontend-dev"`
- QA → `agentId: "qa-analyst"`

## Tool disponible: `sessions_spawn`

Cuando eres spawneado por Anibal como subagente (depth 1), **tienes `sessions_spawn` disponible** en tu tool list. Úsalo directamente — no uses exec, no uses /subagents slash command.

## Workers disponibles

| Worker | agentId (OBLIGATORIO) | Cuándo |
|--------|----------------------|--------|
| Backend Dev | `"backend-dev"` | APIs, endpoints, servicios, DB, lógica de negocio |
| Frontend Dev | `"frontend-dev"` | UI, componentes React/Next, integraciones cliente |
| QA Analyst | `"qa-analyst"` | Revisar PRs, validar DoD, test plans |

El `agentDir` y `workspaceDir` los resuelve OpenClaw automáticamente desde el `agentId` — no los pases.

## Parámetros del tool

```json
{
  "agentId": "<OBLIGATORIO: backend-dev | frontend-dev | qa-analyst>",
  "runtime": "subagent",
  "label": "<worker>-<feature-slug>",
  "task": "<prompt completo para el worker>",
  "cwd": "/opt/tns-workbench/autonomous-workbench",
  "timeoutSeconds": 1800,
  "runTimeoutSeconds": 1800,
  "cleanup": "delete",
  "sandbox": "inherit"
}
```

## Flujo completo para una feature backend

### Paso 1 — Spawnar backend-dev

```json
{
  "agentId": "backend-dev",
  "runtime": "subagent",
  "label": "backend-dev-feat-get-health",
  "task": "Tarea: implementa GET /health en infra/webhooks/github-handler.js\n\nRepo local: /opt/tns-workbench/autonomous-workbench\nBranch base: dev\nFeature branch: feat/get-health-endpoint\nWorktree: /opt/tns-workbench/autonomous-workbench/worktrees/feat/get-health-endpoint\n\nPasos:\n1. cd /opt/tns-workbench/autonomous-workbench\n2. git worktree add worktrees/feat/get-health-endpoint -b feat/get-health-endpoint dev\n3. Implementa el endpoint (ver specs)\n4. git add -p, git commit, git push -u origin feat/get-health-endpoint\n5. gh pr create --base dev --title 'feat: GET /health' --body '...' --reviewer andresTNS --reviewer Bufigol\n6. Devuelve PR número + URL\n\nSpecs:\n- Response: {\"status\":\"ok\",\"version\":\"<git shortsha>\",\"uptime\":<process.uptime()>}\n- Regla #5: NUNCA commit/push a dev/main/master directamente\n\nEntrega: número de PR creado + URL.",
  "cwd": "/opt/tns-workbench/autonomous-workbench",
  "timeoutSeconds": 1800,
  "runTimeoutSeconds": 1800,
  "cleanup": "delete",
  "sandbox": "inherit"
}
```

### Paso 2 — Esperar resultado con sessions_yield

```json
{ "message": "backend-dev dispatched para feat/get-health-endpoint. Esperando resultado." }
```

### Paso 3 — Cuando llegue el resultado: spawnar qa-analyst

```json
{
  "agentId": "qa-analyst",
  "runtime": "subagent",
  "label": "qa-analyst-pr-<número>",
  "task": "Revisa el PR #<número> en The-Next-Security/autonomous-workbench.\n\nCriterios de aceptación:\n- GET /health retorna 200 con body {\"status\":\"ok\",\"version\":\"<sha>\",\"uptime\":<number>}\n- No rompe el endpoint POST /webhooks/github existente\n- Código limpio, sin console.log de debug\n\nProceso:\n1. gh pr checkout <número>\n2. Revisar diff: gh pr diff <número>\n3. Si todo ok: gh pr review <número> --approve --body 'QA: LGTM.'\n4. Si hay issues: gh pr review <número> --request-changes --body 'Issues: <lista>'\n5. Devuelve: approved/changes-requested + detalle\n\nRepo local: /opt/tns-workbench/autonomous-workbench",
  "cwd": "/opt/tns-workbench/autonomous-workbench",
  "timeoutSeconds": 900,
  "runTimeoutSeconds": 900,
  "cleanup": "delete",
  "sandbox": "inherit"
}
```

### Paso 4 — Reportar a Anibal (vía sessions_yield final)

Cuando QA termina, reporta a Anibal con:
- Branch/PR creado
- Estado de QA (aprobado / cambios pedidos)
- Próximo paso (merge cuando Felipe lo autorice)

## Reglas de dispatch (D-07 y D-013)

1. **UN worker por worktree**: nunca spawnes dos workers sobre el mismo worktree simultáneamente.
2. **Verifica que el worktree esté libre** antes de spawnar: `git worktree list` en el repo.
3. **Regla #5**: el task prompt a backend-dev/frontend-dev SIEMPRE debe incluir explícitamente que NO commit/push a dev/main/master.
4. **D-013**: tú comunicas los resultados a Anibal, no directamente a Felipe via Telegram.
5. **No re-spawnes si ya hay un worker activo** sobre la misma tarea. Verifica `subagents/runs.json`.

## ❌ Errores comunes a evitar

- ❌ Omitir `agentId` — spawnea otro Roy en vez del worker target.
- ❌ Poner `agentId: "roy"` — mismo problema.
- ❌ `exec` para inspeccionar el repo antes de spawnar — innecesario, dale el contexto al worker directamente.
- ❌ Usar `coding-agent` skill — eso hace el trabajo tú mismo. Delega con `sessions_spawn`.
- ❌ Esperar el resultado con exec/sleep — usa `sessions_yield`.
