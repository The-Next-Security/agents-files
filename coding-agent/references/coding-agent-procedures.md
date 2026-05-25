# Coding Agent Procedures

Procedimientos operativos de referencia para el skill `coding-agent`.
Extiende el `SKILL.md` con detalle técnico que sería demasiado extenso
para el archivo principal.

> Última actualización: 2026-05-23
> Propietario: Roy (Scrum Master, Capa 1)

---

## Detección de entorno

Antes de cualquier ejecución, verificar qué CLI está disponible. Nunca asumir.

### Orden de preferencia

```
codex → claude → opencode → pi
```

### Verificación paso a paso

```bash
# Verificar cada CLI individualmente (sin comandos compuestos)
which codex
which claude
which opencode
which pi
```

Usar el primer CLI que retorne una ruta válida. Si ninguno retorna ruta → CLI no
disponible. Reportar a Felipe vía Aníbal y no ejecutar.

### Tabla de disponibilidad

| CLI | Paquete de instalación | Verificación |
|-----|----------------------|-------------|
| `codex` | `@openai/codex` (npm) | `which codex` |
| `claude` | `@anthropic-ai/claude-code` (npm) | `which claude` |
| `opencode` | `opencode` (npm/brew) | `which opencode` |
| `pi` | `@mariozechner/pi-coding-agent` (npm) | `which pi` |

**Si ninguno está disponible:**
- No intentar instalar ningún paquete de forma autónoma
- Reportar: "CLI de codificación no disponible en el entorno. Se requiere instalación
  manual por Felipe."
- Comunicar vía canal Roy → Aníbal → Felipe

---

## Ejecución

### Foreground (tarea < 5 min)

Para tareas cortas que completan rápidamente. Roy espera el resultado antes de
continuar.

**Claude Code (sin PTY):**
```bash
cd <ruta-del-repo>
claude --permission-mode bypassPermissions --print "<prompt completo>"
```

**Codex (con PTY):**
```bash
# workdir: <ruta-del-repo>
# pty: true
codex exec "<prompt completo>"
```

**OpenCode (con PTY):**
```bash
# workdir: <ruta-del-repo>
# pty: true
opencode run "<prompt completo>"
```

**Pi (con PTY):**
```bash
# workdir: <ruta-del-repo>
# pty: true
pi -p "<prompt completo>"
```

### Background (tarea 5-30 min)

Para tareas que toman más tiempo. Roy monitorea el progreso sin bloquear.

```
1. Iniciar en background:
   workdir: <ruta-del-repo>
   background: true
   command: <cli> <modo-no-interactivo> "<prompt>"
   → Retorna: sessionId para monitoreo

2. Verificar progreso:
   process action:log sessionId:<id>
   → Ver output acumulado

3. Verificar si terminó:
   process action:poll sessionId:<id>
   → running: true/false

4. Si el CLI necesita input:
   process action:submit sessionId:<id> data:"<respuesta>"

5. Si cuelga o supera 30 min:
   process action:kill sessionId:<id>
   → Escalar a agent-dispatch

6. Al terminar: leer resultado completo:
   process action:log sessionId:<id>
```

### Reporte de resultado

Al completar cualquier ejecución (foreground o background), Roy reporta el resultado
siguiendo el canal oficial:

```
Roy → Aníbal → Felipe (cuando Felipe pregunte)
```

No usar comandos de notificación directa a Telegram. No usar `openclaw system event`
ni equivalentes. Aníbal serializa el mensaje naturalmente cuando Felipe interactúe.

---

## Límites de ejecución

### Árbol de decisión: ¿coding-agent o escalar?

```
¿La tarea requiere commits o abrir un PR?
  ├── SÍ → agent-dispatch. NO continuar con coding-agent.
  └── NO → continuar

¿La tarea es diagnóstico de un bug específico con RCA?
  ├── SÍ → tns-debugger-triage. NO continuar con coding-agent.
  └── NO → continuar

¿La tarea es análisis profundo de performance Node.js?
  ├── SÍ → node-specialist. NO continuar con coding-agent.
  └── NO → continuar

¿La tarea tomará más de 30 minutos?
  ├── SÍ → agent-dispatch. NO continuar con coding-agent.
  └── NO → ejecutar con coding-agent ✅
```

### Qué está prohibido en el prompt al CLI

El prompt que Roy entrega al CLI nunca debe incluir instrucciones de:

```
❌ git commit -m "..."
❌ git push origin <cualquier rama>
❌ git push --force
❌ gh pr create
❌ gh pr merge
❌ npm publish
❌ cualquier deploy o publicación
```

Si el CLI genera alguna de estas acciones de forma autónoma → abortar la sesión
inmediatamente con `process action:kill`.

### Anti-patrones de ejecución

```
❌ Asumir que codex está disponible sin verificar primero
❌ Usar PTY con Claude Code (produce comportamiento impredecible)
❌ No limpiar worktrees scratch al finalizar
❌ Dejar procesos en background sin verificar que terminaron
❌ Continuar si la tarea supera 30 min (escalar a agent-dispatch)
❌ Ejecutar en /root/.openclaw/ o en el directorio de un worker activo
❌ Enviar notificaciones directas a Telegram al completar
```

---

## Worktree scratch

Para operaciones que requieren explorar una rama específica sin afectar el
worktree principal. Útil para análisis de PRs, comparación de branches o
lectura de código en un estado histórico.

### Crear worktree scratch

```bash
# 1. Verificar que el repo tiene git inicializado
git -C <ruta-repo> status

# 2. Generar ruta del scratch
# Usar un nombre descriptivo para identificarlo fácilmente
# Ejemplo: /tmp/scratch-review-pr-121

# 3. Crear el worktree
git -C <ruta-repo> worktree add /tmp/scratch-<slug> <branch-o-commit>
```

### Ejecutar la tarea en el scratch

```bash
# workdir: /tmp/scratch-<slug>
# command: <cli> <modo-no-interactivo> "<prompt>"
```

### Limpiar el scratch al terminar

```bash
# OBLIGATORIO — siempre limpiar, incluso si la tarea falló
git -C <ruta-repo> worktree remove /tmp/scratch-<slug> --force
```

### Verificar que no quedan scratches huérfanos

```bash
git -C <ruta-repo> worktree list
```

Si aparece algún worktree en `/tmp/scratch-*` que ya no tiene proceso activo →
eliminarlo con `git worktree remove --force`.

### Reglas del worktree scratch

```
✅ Siempre en /tmp/ o directorio temporal del sistema
✅ Nombre descriptivo que identifique el propósito
✅ Limpiar siempre al terminar, incluso si hubo error
❌ NUNCA crear scratch en el directorio de trabajo de Roy
❌ NUNCA crear scratch en el directorio de un worker activo
❌ NUNCA hacer push desde un worktree scratch
❌ NUNCA crear más de 3 scratches simultáneos (riesgo de fragmentación)
```
