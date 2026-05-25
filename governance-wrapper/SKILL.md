---
name: governance-wrapper
description: Capa de gobernanza que valida acciones antes de ejecutar operaciones sensibles del sistema autónomo. Opera en modo pasivo y continuo — evalúa toda acción con riesgo operativo antes de permitirla. Aplica política permit / bloquear / escalar según contenido, contexto y alineación con el backlog. Triggers: "governance", "guardrail", "validar acción", "acción riesgosa", "comando peligroso", "policy", "política", "seguridad operativa", "control", "wrapper".
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-23
user-invocable: false
allowed-tools: Bash
tags: governance policy security allow-block-escalate pre-execution guardrail passive always-on
compatibility: No external dependencies. Compatible with any OpenClaw or Hermes environment.
metadata: {"openclaw":{"emoji":"🛡️","riskLevel":"low","ownerAgent":"system","requires":{"bins":[],"env":[]},"os":["linux","darwin"],"outputs":["govDecision","auditEntry"],"scrum":["execution","retrospective"],"worksWithSkills":["agent-audit-trail","giraffe-guard","skill-threat-scanner","coding-agent","git-expert","github-manager"]}}
---

# Governance Wrapper

Skill de gobernanza pre-ejecución del sistema OpenClaw. Opera en modo pasivo y continuo,
evaluando toda acción sensible antes de ejecutarse. Su decisión es vinculante: ninguna
acción con riesgo medio o alto se ejecuta sin pasar por este wrapper.

**Regla de oro:** ante la duda, bloquear o escalar antes que permitir.

---

## Modo de operación

Este skill opera en modo **pasivo y continuo**. Se activa automáticamente antes de
cualquier acción sensible ejecutada por cualquier skill del sistema. No puede omitirse
para acciones clasificadas como riesgo medio o alto.

- **Activación**: automática — invocado por cualquier skill antes de ejecutar acción sensible
- **Persistencia**: continua durante toda la sesión activa
- **Decisión**: permit / bloquear / escalar — con motivo documentado siempre

---

## Qué evalúa

Toda acción que incluya, directa o indirectamente:

- Ejecución de comandos de shell con efectos en el sistema
- Modificación de archivos en el workspace de producción
- Operaciones Git: commit, push, merge, rebase, worktree
- Acceso, rotación o exposición de credenciales o secretos
- Cambios en configuración del sistema OpenClaw
- Operaciones fuera del workspace previsto
- Acciones que contradigan el backlog como source of truth
- Cambios en infraestructura: firewall, SSH, red, gateway

---

## Política base

### Permitir cuando

- La acción es acotada y tiene un objetivo claro
- Es trazable (puede registrarse en agent-audit-trail)
- Es reversible o de riesgo bajo
- Está alineada con una historia en `inProgress[]` del sprint activo

### Bloquear cuando

- La acción es destructiva e irreversible
- Afecta el sistema base sin necesidad clara
- Toca secretos, tokens o autenticación
- Implica evasión de controles de governance
- Altera evidencia o trazabilidad existente
- Contradice políticas explícitas del proyecto (D-07 y similares)

### Escalar cuando

- El riesgo es medio o alto y falta contexto para decidir
- Hay efectos laterales relevantes no evaluados
- La acción toca producción, seguridad, identidad o comunicaciones externas
- giraffe-guard reportó comportamiento repetitivo para esta acción

---

## Árbol de decisión

```
¿La acción está en la lista de bloqueo incondicional?
  └── SÍ → BLOQUEAR. Registrar en audit-trail. Fin.

¿Cuál es el riesgo de la acción?
  ├── bajo  → PERMITIR si está alineada con sprint. Registrar.
  ├── medio → ¿Hay contexto suficiente para evaluar?
  │           ├── SÍ → PERMITIR con registro obligatorio
  │           └── NO → ESCALAR a Roy
  └── alto  → ESCALAR siempre. No permitir sin validación externa.

¿La acción está alineada con inProgress[] en sprint-state.json?
  ├── SÍ → continuar con evaluación de riesgo
  └── NO → ESCALAR (acción fuera del contexto del sprint)
```

---

## Formato de evaluación

Para cada acción evaluada, documentar:

```
Acción evaluada: <descripción exacta del comando o cambio>
Riesgo: bajo | medio | alto
Decisión: permitir | bloquear | escalar
Motivo: <razón técnica concreta>
Controles requeridos: <condiciones para permitir si aplica>
```

---

## Lista de bloqueo incondicional

```
❌ rm -rf / o equivalentes fuera del workspace
❌ shutdown / reboot / halt del servidor
❌ chmod -R 777 o cambios de permisos inseguros masivos
❌ Exposición de tokens, passwords o credenciales en logs/archivos
❌ Desactivación de firewall, fail2ban, UFW sin autorización explícita de Felipe
❌ git push --force a dev/main/master
❌ Modificación del backlog source of truth sin trazabilidad
❌ Ejecución fuera de los worktrees definidos en el workspace
```

---

## Casos típicos a escalar

```
⚠️ Cambios en sshd_config
⚠️ Cambios en configuración de UFW, fail2ban o nginx
⚠️ Rotación de credenciales del sistema
⚠️ Cambios en worktrees activos de workers en ejecución
⚠️ Automatizaciones con efectos sobre GitHub, Telegram o sistemas externos no verificados
⚠️ Scripts con --force o --no-verify que bypasean validaciones
```

---

## Flujo por evento Scrum

### Backlog Grooming / Sprint Planning

No participación activa. Roy puede revisar historial de decisiones del sprint anterior
para identificar patrones de acciones que generan escalamientos frecuentes y ajustar
la política o los workflows del próximo sprint.

### Daily Scrum

No participa en el Daily. Si bloquea o escala una acción crítica durante el sprint →
notificación inmediata a Roy **sin esperar el Daily**. El bloqueo queda en agent-audit-trail.

### Ejecución durante el Sprint

Activo durante toda la ejecución. Evalúa toda acción sensible antes de ejecutarse.
Registra cada decisión en agent-audit-trail con motivo completo.

### Pre-Sprint Review / Sprint Retrospective

Proveer al Sprint Retrospective el historial de evaluaciones del sprint:
- Acciones bloqueadas incondicionalmente y sus contextos
- Acciones escaladas y cómo se resolvieron
- Patrones repetitivos que sugieran ajustes a la política base

---

## Relación con otras skills

| Skill | Qué recibo | Qué entrego |
|-------|-----------|------------|
| **coding-agent, git-expert, github-manager, agent-dispatch** | Solicitud de validación antes de ejecutar acción sensible | Permit / Bloquear / Escalar + motivo documentado |
| **agent-audit-trail** | — | Decisión para registro permanente |
| **giraffe-guard** | Señal de comportamiento repetitivo para la acción | Contexto adicional de frecuencia para decisión de escalamiento |
| **skill-threat-scanner** | — | Historial de decisiones para análisis de patrones |

---

## Límites duros

- ❌ **Nunca** permitir una acción de la lista de bloqueo incondicional — sin excepciones
- ❌ **Nunca** permitir acciones de riesgo alto sin validación externa de Roy o Felipe
- ❌ **Nunca** emitir una decisión sin registrarla en agent-audit-trail
- ❌ **Nunca** omitirse en el flujo de una acción sensible — no hay bypass
- ❌ **Nunca** modificar la política base durante una sesión sin aprobación de Felipe

---

## KPIs de efectividad

| Indicador | Meta |
|-----------|------|
| Acciones de riesgo alto ejecutadas sin evaluación previa | 0 |
| Decisiones sin registro en agent-audit-trail | 0 |
| Falsos positivos (acciones legítimas bloqueadas) | < 5% |
| Tiempo de evaluación por acción | < 500ms |
| Acciones de lista de bloqueo incondicional que pasaron | 0 |
