---
name: giraffe-guard
description: Aplica guardrails operativos para prevenir loops autónomos, ejecuciones descontroladas y comportamientos runaway en el sistema OpenClaw. Opera en modo pasivo y continuo — evalúa frecuencia, profundidad de encadenamiento y alineación con el sprint activo de cada acción antes de permitirla. Triggers: "guard", "loop", "runaway", "protección", "límite", "control de ejecución", "frecuencia", "spam", "seguridad operativa".
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-23
user-invocable: false
allowed-tools: Bash
tags: guard loop detection runaway protection throttling frequency governance passive always-on
compatibility: No external dependencies. Compatible with any OpenClaw or Hermes environment.
metadata: {"openclaw":{"emoji":"🦒","riskLevel":"low","ownerAgent":"system","requires":{"bins":[],"env":[]},"os":["linux","darwin"],"outputs":["guardDecision","throttleSignal"],"scrum":["execution","retrospective"],"worksWithSkills":["governance-wrapper","agent-audit-trail","skill-threat-scanner"]}}
---

# Giraffe Guard

Skill de protección operativa del sistema OpenClaw. Opera en modo pasivo y continuo,
evaluando cada acción antes de que se ejecute. Su responsabilidad es detectar y frenar
comportamientos emergentes peligrosos: loops, encadenamientos sin control y ejecuciones
fuera de contexto.

**Regla de oro:** detener o limitar antes de permitir continuar cuando hay señal de runaway.

---

## Modo de operación

Este skill opera en modo **pasivo y continuo**. Se activa automáticamente antes de cada
acción que pueda crear efectos repetitivos o encadenados. Complementa a governance-wrapper
con foco en frecuencia y contexto temporal, no solo en contenido de la acción.

- **Activación**: automática antes de acciones con potencial de repetición
- **Persistencia**: continua durante la sesión activa
- **Umbral configurable**: N acciones del mismo tipo en T segundos → escalar o bloquear

---

## Qué protege

- Loops infinitos de ejecución
- Acciones repetitivas sin pausa entre ellas
- Ejecución excesiva en intervalos cortos
- Llamadas encadenadas sin validación intermedia
- Automatizaciones fuera del contexto del sprint activo
- Saturación de canales: Git, Telegram u otros
- Cascade automática sin punto de verificación

---

## Señales de riesgo

| Señal | Descripción |
|-------|------------|
| **Frecuencia anormal** | Misma acción N veces en T segundos sin pausa |
| **Encadenamiento profundo** | Más de M acciones consecutivas sin input externo |
| **Desalineación con sprint** | Acción no relacionada con ninguna historia inProgress[] |
| **Escalamiento sin resolución** | Misma decisión escalada repetidamente sin respuesta |
| **Saturación de canal** | >X mensajes al mismo destino en la misma sesión |

---

## Árbol de decisión

```
¿La acción se repite más de N veces en T segundos?
  ├── SÍ → BLOQUEAR si N > umbral_crítico
  │        LIMITAR (throttle) si N > umbral_aviso
  └── NO → continuar

¿La profundidad de encadenamiento supera M?
  ├── SÍ → ESCALAR a Roy para validación externa
  └── NO → continuar

¿La acción está alineada con una historia en sprint-state.json inProgress[]?
  ├── NO + riesgo alto → BLOQUEAR
  │   NO + riesgo bajo → ESCALAR
  └── SÍ → continuar

¿Hay recursividad no controlada detectada?
  └── SÍ → BLOQUEAR inmediatamente
```

---

## Umbrales de referencia (configurables)

| Parámetro | Valor por defecto | Descripción |
|-----------|-----------------|-------------|
| `N_aviso` | 3 | Acciones idénticas antes de emitir aviso |
| `N_bloqueo` | 5 | Acciones idénticas antes de bloquear |
| `T_ventana` | 60s | Ventana de tiempo para contar repeticiones |
| `M_profundidad` | 4 | Máximo de acciones encadenadas sin input externo |
| `X_canal` | 10 | Máximo de mensajes al mismo canal por sesión |

---

## Respuestas posibles

| Decisión | Cuándo | Acción |
|----------|--------|--------|
| **Permitir** | Comportamiento normal, frecuencia dentro de umbrales | Continuar sin intervención |
| **Limitar** | Frecuencia sobre N_aviso, bajo N_bloqueo | Aplicar throttle: pausa forzada antes de continuar |
| **Escalar** | Contexto ambiguo, profundidad M alcanzada, desalineación con sprint | Notificar a Roy y esperar validación |
| **Bloquear** | Frecuencia sobre N_bloqueo, recursividad detectada, loop confirmado | Detener la acción y registrar en agent-audit-trail |

---

## Ejemplos de bloqueo confirmado

- Loop de commits automáticos (misma acción >5 veces en 60s)
- Múltiples PRs generados sin control en la misma sesión
- Spam de mensajes a Telegram (>10 en la misma sesión)
- Ejecución continua de scripts sin condición de fin
- Encadenamiento recursivo skill → skill → skill sin input externo

---

## Flujo por evento Scrum

### Backlog Grooming / Sprint Planning

No participación activa. Roy puede consultar histórico de bloqueos del sprint anterior
para identificar patterns que indiquen stories sobrecomplejas o ambiguas que generen
comportamientos repetitivos durante la ejecución.

### Daily Scrum

No participa en el Daily. Si bloquea una acción crítica durante el sprint → alerta
inmediata a Roy **sin esperar el Daily**. El bloqueo queda registrado en agent-audit-trail.

### Ejecución durante el Sprint

Activo durante toda la ejecución. Evalúa frecuencia y encadenamiento de cada acción
ejecutada por cualquier skill. El sistema consulta giraffe-guard antes de permitir
acciones con potencial de repetición.

### Pre-Sprint Review / Sprint Retrospective

Proveer al Sprint Retrospective el resumen de bloqueos y limitaciones del sprint:
- Acciones bloqueadas por loops detectados
- Acciones limitadas por throttling
- Escalamientos realizados y su resolución

---

## Relación con otras skills

| Skill | Qué recibo | Qué entrego |
|-------|-----------|------------|
| **governance-wrapper** | Complemento de evaluación de riesgo por contenido | Señal de comportamiento repetitivo o contexto temporal |
| **agent-audit-trail** | — | Entry de bloqueo/limitación/escalamiento para registro |
| **skill-threat-scanner** | — | Datos de frecuencia y encadenamiento para análisis |
| **coding-agent, agent-dispatch, otros** | Contexto de acción a ejecutar | Permitir / Limitar / Escalar / Bloquear |

---

## Límites duros

- ❌ **Nunca** bloquear sin registrar la razón en agent-audit-trail
- ❌ **Nunca** modificar los umbrales N/T/M durante una sesión activa sin aprobación de Roy
- ❌ **Nunca** ignorar una señal de recursividad confirmada — bloqueo obligatorio
- ❌ **Nunca** escalar sin proveer contexto: acción, frecuencia detectada, umbral superado
- ❌ **Nunca** desactivarse durante una sesión activa del sistema

---

## KPIs de efectividad

| Indicador | Meta |
|-----------|------|
| Loops bloqueados antes de causar daño | 100% |
| Bloqueos falsos positivos (acciones legítimas bloqueadas) | < 5% |
| Tiempo de detección desde inicio del loop | < 3 acciones |
| Bloqueos sin registro en agent-audit-trail | 0 |
| Escalamientos resueltos sin intervención de Felipe | > 70% |
