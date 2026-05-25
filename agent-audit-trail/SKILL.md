---
name: agent-audit-trail
description: Registra y documenta acciones relevantes del sistema autónomo para trazabilidad, auditoría y análisis posterior. Opera en modo pasivo y continuo — se invoca automáticamente al ejecutar acciones sensibles, cambios en archivos, operaciones Git, decisiones de governance o cualquier evento que deba quedar trazado. Triggers: "audit", "log", "registro", "trazabilidad", "evidencia", "tracking", "historial", "auditoría", "evento", "acción ejecutada".
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-23
user-invocable: false
allowed-tools: Bash
tags: audit log traceability events security governance passive always-on
compatibility: No external dependencies. Writes to filesystem. Compatible with any OpenClaw or Hermes environment.
metadata: {"openclaw":{"emoji":"📜","riskLevel":"low","ownerAgent":"system","requires":{"bins":[],"env":[]},"os":["linux","darwin"],"outputs":["auditEntry","auditReport"],"scrum":["execution","retrospective"],"worksWithSkills":["governance-wrapper","giraffe-guard","skill-threat-scanner","agent-dispatch","coding-agent"]}}
---

# Agent Audit Trail

Skill de trazabilidad continua del sistema OpenClaw. Opera en background durante toda la
vida del sistema — no requiere activación explícita. Garantiza que cualquier acción
relevante pueda reconstruirse a partir del registro.

**Principio fundamental:** lo no registrado se considera no ocurrido.

---

## Modo de operación

Este skill opera en modo **pasivo y continuo**. Se activa automáticamente cuando otro
skill solicita el registro de una acción. No puede desactivarse durante una sesión activa.

- **Activación**: invocado por governance-wrapper, giraffe-guard y cualquier skill que ejecute acciones sensibles
- **Persistencia**: continua durante el sprint y entre sprints
- **Consulta**: Roy puede consultar el audit trail en cualquier momento

---

## Qué se registra

Registrar siempre que ocurra alguno de los siguientes:

- Ejecución de comandos de shell con efecto en el sistema
- Cambios en archivos del workspace
- Operaciones Git: commit, push, PR, worktree add/remove
- Decisiones de governance-wrapper: permitir / bloquear / escalar
- Bloqueos o limitaciones de giraffe-guard
- Errores o excepciones en ejecución de agentes
- Eventos del flujo Scrum: spawn de worker, cierre de issue, merge de PR
- Acciones iniciadas desde Telegram vía Aníbal → Roy

## Qué no registrar

- Acciones rutinarias de solo lectura sin impacto en el estado del sistema
- Consultas informativas sin efecto secundario
- Logs de debug temporales — el audit trail es permanente

---

## Formato de entrada

Cada entry del audit trail sigue esta estructura:

```
timestamp: 2026-05-23T14:32:01Z
actor: <nombre-del-skill-o-agente>
acción: <descripción concisa de qué se ejecutó>
resultado: éxito | error | bloqueado | escalado
riesgo: bajo | medio | alto
contexto: <repo, issue#, worktree, PR# si aplica>
```

**Ejemplo — spawn de worker:**
```
timestamp: 2026-05-23T14:32:01Z
actor: agent-dispatch
acción: spawn worker backend-dev para issue The-Next-Security/TNS_TRACK_DEMO#115
resultado: éxito
riesgo: medio
contexto: repo=TNS_TRACK_DEMO, workerSessionId=backend-dev-issue-115
```

---

## Niveles de riesgo

| Nivel | Descripción | Ejemplos |
|-------|-------------|---------|
| **bajo** | Acciones rutinarias sin impacto relevante | Lectura de archivo, consulta a sprint-state.json |
| **medio** | Cambios que afectan estado del sistema | Commit, creación de worktree, spawn de worker |
| **alto** | Acciones sensibles sobre seguridad o producción | Intento de push a rama protegida, acceso a credenciales, PR merge |

---

## Casos obligatorios de registro

- Cualquier acción evaluada por governance-wrapper (con resultado)
- Cualquier bloqueo o limitación aplicada por giraffe-guard
- Modificaciones al backlog o al sprint-state.json
- Cambios en configuración del sistema OpenClaw
- Ejecución de automatizaciones con efecto externo (Telegram, GitHub)
- Errores en ejecución de workers o skills
- Decisiones de Roy que afecten el curso del sprint

---

## Flujo por evento Scrum

### Backlog Grooming / Sprint Planning

No participación activa. Datos históricos disponibles si Roy necesita revisar riesgos
de historias candidatas o patrones de errores en sprints anteriores.

### Daily Scrum

No participa en el Daily. Si se detecta una anomalía crítica durante el sprint (acción
bloqueada repetidamente, patrón de errores) → alerta inmediata a Roy **sin esperar el Daily**.

### Ejecución durante el Sprint

Activo durante todo el sprint. Registra automáticamente toda acción sensible ejecutada
por cualquier skill. Roy puede consultar el trail en cualquier momento:

```bash
# Ver últimas N entradas del audit trail
tail -n 50 ~/.openclaw/audit/audit-trail.log

# Buscar acciones de un repo específico
grep "TNS_TRACK_DEMO" ~/.openclaw/audit/audit-trail.log
```

### Pre-Sprint Review

Roy puede solicitar un resumen del sprint para incluir en el Sprint Review:
- Acciones ejecutadas por tipo y nivel de riesgo
- Bloqueos detectados y resueltos
- Errores registrados con sus contextos

### Sprint Retrospective

Proveer métricas del sprint pasado para la retrospectiva:
- Total de acciones registradas por nivel de riesgo
- Acciones bloqueadas por governance-wrapper
- Errores recurrentes que merecen análisis

---

## Relación con otras skills

| Skill | Qué recibo | Qué entrego |
|-------|-----------|------------|
| **governance-wrapper** | Solicitud de registro en cada decisión permit/block/escalar | Entry de audit trail con decisión y motivo |
| **giraffe-guard** | Solicitud de registro en cada bloqueo/limitación | Entry de audit trail con señal detectada |
| **skill-threat-scanner** | — | Dataset completo de eventos para análisis de patrones |
| **agent-dispatch, coding-agent, otros** | Solicitud de registro al ejecutar acciones sensibles | Entry de audit trail confirmado |

---

## Límites duros

- ❌ **Nunca** eliminar o modificar entries ya escritos — el audit trail es inmutable
- ❌ **Nunca** registrar información sensible (tokens, passwords, credenciales) en el body del entry
- ❌ **Nunca** omitir el registro de una acción evaluada por governance-wrapper
- ❌ **Nunca** desactivarse durante una sesión activa del sistema
- ❌ **Nunca** registrar ruido: solo eventos con impacto en el estado del sistema

---

## KPIs de efectividad

| Indicador | Meta |
|-----------|------|
| Acciones de governance-wrapper registradas | 100% |
| Entries con formato completo (todos los campos) | 100% |
| Entries con información sensible expuesta | 0 |
| Tiempo máximo entre acción y registro | < 1s |
| Datos disponibles para Sprint Retrospective | 100% de los sprints |
