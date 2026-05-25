---
name: coding-agent
description: Ejecuta tareas de código ligeras y efímeras mediante un CLI de codificación disponible en el entorno (Codex, Claude Code, OpenCode, Pi o equivalente) — sin commits a ramas de producción ni apertura de PRs. Usar cuando Roy necesita ejecutar scripts ad-hoc, leer o analizar un repositorio, hacer chequeos rápidos o exploraciones de código que no justifican spawnear un worker persistente. Si la tarea requiere commits, PR o QA → usar agent-dispatch. Triggers: "script rápido", "ad-hoc", "chequea el repo", "lista archivos", "analiza este código", "ejecuta", "lee el repo", "quick check".
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-23
user-invocable: true
allowed-tools: Bash
tags: cli execution ad-hoc script ephemeral codex claude-code orchestration
compatibility: Requires at least one coding CLI available in PATH (codex, claude, opencode, or pi). No PTY required for Claude Code. PTY required for Codex/OpenCode/Pi.
metadata: {"openclaw":{"emoji":"🧩","riskLevel":"medium","ownerAgent":"roy","requires":{"bins":[],"env":[]},"os":["linux","darwin"],"outputs":["scriptOutput","analysisReport"],"scrum":["execution"],"worksWithSkills":["agent-dispatch","tns-debugger-triage","agent-audit-trail","governance-wrapper"]}}
---

# Coding Agent

Ejecuta tareas de código ligeras y efímeras mediante el CLI de codificación disponible
en el entorno. Roy orquesta — el CLI ejecuta. Nunca produce commits a ramas de producción
ni abre PRs: eso es responsabilidad de los workers persistentes coordinados por
`agent-dispatch`.

**Límite crítico:** si la tarea tarda más de 30 minutos o requiere commits + PR →
escalar a `agent-dispatch` inmediatamente.

---

## Cuándo activarme

- Ejecutar un script ad-hoc sin persistencia en el repo
- Leer, analizar o explorar el código de un repositorio
- Chequeos rápidos: listar archivos, verificar dependencias, inspeccionar configuración
- Exploraciones de datos o transformaciones de una sola vez
- Tareas de diagnóstico de soporte para `tns-debugger-triage` o `node-specialist`

## Cuándo NO activarme

| Tarea | Skill correcta |
|-------|---------------|
| Feature completa con commits + PR | `agent-dispatch` |
| Diagnóstico de bug con RCA | `tns-debugger-triage` |
| Análisis profundo Node.js/TS | `node-specialist` |
| Operaciones git complejas | `git-expert` (dentro del worker) |
| Tarea > 30 min | `agent-dispatch` |

---

## Protocolo de activación

Antes de operar, confirmar:

```
# ¿La tarea tiene criterio de completitud claro?
#   Si NO → definirlo antes de ejecutar
# ¿La tarea requiere commits o PR?
#   Si SÍ → NO activar. Usar agent-dispatch.
# ¿Hay un CLI de codificación disponible en el entorno?
#   Verificar disponibilidad antes de asumir: which codex / which claude / etc.
# ¿La tarea podría afectar ramas protegidas (dev/main/master)?
#   Si SÍ → bloquear. Governance-wrapper ya está activo, pero verificar explícitamente.
```

---

## Flujo por evento Scrum

### Backlog Grooming

- Verificar que los repos de las stories comprometidas tienen al menos un CLI de
  codificación disponible: `which codex`, `which claude`, `which opencode`, `which pi`
- Identificar stories donde Roy necesitará exploración técnica previa (estructura
  de código, dependencias, rutas) antes del Sprint Planning — agendar esas
  exploraciones como tareas de coding-agent
- Señal de alerta: si ningún CLI está disponible en el entorno → reportar a Felipe
  vía Aníbal antes de que el sprint inicie; no planificar tareas que dependan de
  esta skill

### Sprint Planning

- Confirmar disponibilidad del CLI en el entorno del sprint activo
- Identificar qué stories requieren exploración técnica previa (chequeos de repo,
  verificación de dependencias) que coding-agent puede resolver antes del inicio
  de implementación
- Las exploraciones de coding-agent son insumo para los task prompts de `agent-dispatch`
  — planificar en ese orden: exploración → dispatch

### Daily Scrum

```
Ayer: [qué scripts o análisis ejecuté / qué exploraciones de repo realicé]
Hoy: [qué tarea ligera ejecutaré / qué repo o código analizaré]
Bloqueos: [CLI no disponible / tarea que superó 30 min y necesita escalar a agent-dispatch / worktree scratch no limpiado]
```

Bloqueo que afecta el avance del sprint → escalar al Scrum Master como impedimento
en el Daily.

### Ejecución durante el Sprint

Ver procedimientos detallados en `{baseDir}/references/coding-agent-procedures.md`:
- Detección de CLI disponible → sección "Detección de entorno"
- Ejecución en foreground → sección "Ejecución foreground"
- Ejecución en background + monitoreo → sección "Ejecución background"
- Worktree scratch para operaciones de lectura → sección "Worktree scratch"
- Límites de scope y cuándo escalar → sección "Límites de ejecución"

### Pre-Sprint Review

Checklist antes de cerrar ejecuciones de coding-agent en el Sprint:

```
[ ] Todas las tareas ejecutadas tuvieron CLI detectado previamente (sin asumir disponibilidad)
[ ] Ninguna ejecución produjo commits o push a dev/main/master
[ ] Worktrees scratch creados durante el Sprint fueron limpiados
[ ] Ningún proceso en background quedó colgado (process action:poll verificado)
[ ] Resultados reportados vía Roy → Aníbal (sin notificaciones directas)
[ ] Tareas que superaron 30 min fueron escaladas a agent-dispatch correctamente
```

Si algún ítem falla → documentar en Sprint Retrospective como deuda operativa.

### Sprint Retrospective

- ¿Alguna tarea escaló a agent-dispatch en mitad de la ejecución? → ajustar criterio
  de corte ligero/pesado para el próximo sprint
- ¿Alguna ejecución produjo efectos secundarios en el repo (archivos residuales,
  worktrees no limpiados)? → mejorar protocolo de limpieza
- ¿El CLI usado fue siempre el más adecuado para la tarea? → revisar orden de preferencia

---

## Detección de CLI disponible

Antes de cualquier ejecución, verificar qué CLI está disponible. No asumir.

Orden de preferencia: `codex` → `claude` → `opencode` → `pi`

Ver script de detección completo en:
`{baseDir}/references/coding-agent-procedures.md#deteccion`

Si ninguno está disponible → reportar a Felipe vía Aníbal. No intentar instalar CLIs.

---

## Modos de ejecución por CLI

Cada CLI tiene su propio modo no-interactivo. Usar siempre el correcto:

| CLI | Modo no-interactivo | PTY requerido |
|-----|--------------------|----|
| `codex` | `codex exec "prompt"` o `codex --full-auto "prompt"` | ✅ Sí |
| `claude` | `claude --permission-mode bypassPermissions --print "prompt"` | ❌ No |
| `opencode` | `opencode run "prompt"` | ✅ Sí |
| `pi` | `pi -p "prompt"` | ✅ Sí |

**Regla:** nunca usar modo interactivo en ejecuciones autónomas. El CLI debe
ejecutar y salir limpiamente.

---

## Worktree scratch para operaciones de lectura

Si la tarea requiere explorar una rama específica sin afectar el worktree principal:

```
1. Crear directorio temporal aislado
2. Crear worktree scratch sobre la rama target
3. Ejecutar tarea en el scratch
4. Limpiar al terminar: git worktree remove --force
```

**NUNCA** hacer checkout en el directorio de trabajo principal de Roy
ni en los directorios de workers activos.

Ver procedimiento completo en:
`{baseDir}/references/coding-agent-procedures.md#worktree-scratch`

---

## Relación con otros agentes

| Agente | Qué necesito de ellos | Qué les entrego |
|--------|----------------------|-----------------|
| **agent-dispatch** | Señal de que la tarea superó el scope ligero → tomar el relevo | Resultado del análisis como insumo para el task prompt del worker |
| **tns-debugger-triage** | — | Outputs de scripts de diagnóstico como evidencia para el RCA |
| **agent-audit-trail** | — | Entry de ejecución: CLI usado, workdir, prompt, timestamp, resultado |
| **governance-wrapper** | Validación pasiva (siempre activa) | Contexto de ejecución para evaluación de permisos |

---

## Límites duros

- ❌ **Nunca** ejecutar con prompt que implique commit/push a `dev`, `main` o `master`
- ❌ **Nunca** continuar si la tarea supera 30 minutos — escalar a `agent-dispatch`
- ❌ **Nunca** ejecutar en el directorio de trabajo principal de Roy
- ❌ **Nunca** ejecutar en el directorio de un worker activo (riesgo de corrupción de worktree)
- ❌ **Nunca** instalar CLIs no disponibles — reportar ausencia a Felipe vía Aníbal
- ❌ **Nunca** enviar notificaciones directas a Telegram — canal obligatorio: Roy → Aníbal → Felipe
- ❌ **Nunca** asumir que un CLI específico está disponible sin verificar primero
- ❌ **Nunca** usar modo interactivo con Claude Code — produce comportamiento impredecible
- ❌ **Nunca** dejar worktrees scratch o procesos en background sin limpiar al finalizar

---

## KPIs de efectividad

| Indicador | Meta |
|-----------|------|
| Tareas ejecutadas sin commits/push no autorizados | 100% |
| CLI detectado antes de cada ejecución (sin asumir disponibilidad) | 100% |
| Tareas que superaron 30 min escaladas correctamente a agent-dispatch | 100% |
| Worktrees scratch limpiados post-ejecución | 100% |
| Notificaciones enviadas vía canal Roy → Aníbal (no directo) | 100% |

---

## Referencias

- Detección de CLI disponible y orden de preferencia:
  `{baseDir}/references/coding-agent-procedures.md#deteccion`
- Ejecución foreground y background con monitoreo:
  `{baseDir}/references/coding-agent-procedures.md#ejecucion`
- Límites de ejecución y árbol de decisión de escalamiento:
  `{baseDir}/references/coding-agent-procedures.md#limites`
- Worktree scratch para operaciones de lectura aisladas:
  `{baseDir}/references/coding-agent-procedures.md#worktree-scratch`
