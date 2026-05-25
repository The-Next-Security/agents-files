---
name: node-specialist
description: Diagnóstico profundo de patologías en runtime Node.js y TypeScript — memory leaks, CPU spikes, event loop bloqueado, errores avanzados de tipado y crashes del proceso (SIGSEGV/OOM). Se activa directamente por labels de performance/node, o como profundización posterior a tns-debugger-triage cuando la causa raíz identificada es el runtime Node.js. Solo diagnostica: no implementa fixes. Triggers: "memory leak", "CPU spike", "heap dump", "event loop blocked", "TypeScript error avanzado", "OOM", "SIGSEGV", "process crash", "performance Node", "label:performance", "label:memory-leak", "label:node".
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-23
user-invocable: true
allowed-tools: Bash
tags: node typescript performance diagnostics memory-leak cpu-spike event-loop crash
compatibility: Requires Node.js installed. Requires git and gh. Requires read access to target repo.
metadata: {"openclaw":{"emoji":"⚡","riskLevel":"medium","ownerAgent":"roy","requires":{"bins":["node","git","gh"],"env":[]},"os":["linux","darwin"],"outputs":["nodeAnalysisReport"],"scrum":["execution"],"worksWithSkills":["tns-debugger-triage","agent-audit-trail","backend-developer","github-manager"]}}
---

# Node Specialist

Diagnóstico profundo de patologías en runtime Node.js y TypeScript. Roy lo aplica
directamente — no requiere spawnear agente separado. El resultado siempre queda
trazado en GitHub: comentado en el issue activo si existe, o en un issue nuevo
creado al momento.

**Límite crítico:** no implementa fixes. Diagnostica, propone y entrega el análisis
al Dev correspondiente para que implemente la solución.

---

## Cuándo activarme

**Modo A — Activación directa por label** (sin pasar por tns-debugger-triage):
- Issue con label `performance`, `memory-leak`, `event-loop`, `node`, `oom`, `sigsegv`
- Reporte de OOM: `FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed`
- CPU sostenida >80% sin carga aparente
- Event loop lag >100ms medido en producción
- Proceso crashea con `SIGSEGV` o `SIGABRT`

**Modo B — Activación secuencial** (posterior a tns-debugger-triage):
- tns-debugger-triage produjo RCA con causa raíz identificada en Node.js runtime
- Roy activa node-specialist para profundizar con análisis específico

**Modo C — Activado por síntoma reportado por worker**:
- `backend-dev` detectó un problema de performance Node.js durante implementación
- El síntoma llega a Roy vía sprint-state.json o resultado del PR → Roy evalúa y activa

## Cuándo NO activarme

- El bug es lógico (error de negocio, validación incorrecta) → `tns-debugger-triage`
- Es un error de dependencia npm desactualizada → actualizar el paquete directamente
- Es un timeout de red o servicio externo → diagnosticar el servicio, no Node.js
- Ya existe un RCA completo para el issue → pasar directamente al Dev para el fix

---

## Protocolo de activación

Antes de operar, confirmar:

```
# ¿Tengo el repo y el síntoma claro?
#   Si NO → pedirlo antes de empezar. Sin contexto no hay diagnóstico.
# ¿Hay un RCA de tns-debugger-triage disponible como contexto?
#   Si SÍ (Modo B) → leerlo primero para partir del punto identificado.
#   Si NO (Modo A/C) → proceder desde cero con el síntoma.
# ¿Tengo acceso al repo y herramientas disponibles (node, git, gh)?
#   Si NO → reportar bloqueo a Felipe vía Aníbal antes de continuar.
# ¿Hay un issue activo en sprint-state.json para este repo?
#   Verificar: exec "cat scrum/sprint-state.json"
#   Esto determina si comentar en issue existente o crear issue nuevo.
```

---

## Flujo por evento Scrum

### Backlog Grooming

- Identificar issues en el backlog con labels `performance`, `memory-leak`,
  `event-loop`, `node`, `oom`, `sigsegv` — son candidatos directos a este skill
- Verificar que los repos candidatos tienen Node.js accesible en el entorno
- Señal de alerta: issue de performance sin labels específicos → sugerir al
  Product Owner que los agregue para activar routing automático correcto

### Sprint Planning

- Para cada issue de performance comprometido: confirmar que `node`, `git` y
  `gh` están disponibles en el entorno de diagnóstico
- Estimar si el diagnóstico requiere reproducción activa (más tiempo) o solo
  análisis estático del código (más rápido)
- Documentar en el task del sprint si viene de tns-debugger-triage (Modo B)
  o es activación directa (Modo A)

### Daily Scrum

```
Ayer: [qué diagnóstico ejecuté / qué patología analicé / en qué issue comenté]
Hoy: [qué issue de performance diagnosticaré / qué profundización haré sobre RCA existente]
Bloqueos: [repo inaccesible / síntoma no reproducible / herramienta no disponible / issue sin contexto suficiente]
```

Bloqueo que impide el diagnóstico → escalar al Scrum Master como impedimento
en el Daily.

### Ejecución durante el Sprint

Ver procedimientos de diagnóstico completos en `{baseDir}/references/node-procedures.md`:
- Memory leak: heap snapshots y análisis de objetos retenidos → sección "Memory leak"
- CPU spike: perfil de CPU y análisis de hot paths → sección "CPU spike"
- Event loop bloqueado: medición de lag y detección de operaciones síncronas → sección "Event loop"
- TypeScript avanzado: errores de tipado complejos y circularidades → sección "TypeScript"
- Proceso crashea: SIGSEGV, SIGABRT, OOM → sección "Crashes"
- Reporte en GitHub: flujo de decisión issue existente vs. nuevo → sección "Reporte GitHub"

### Pre-Sprint Review

```
[ ] Diagnóstico reportado en GitHub: comentario en issue activo o issue nuevo creado
[ ] Causa raíz identificada con evidencia en el comentario de GitHub
[ ] Fix propuesto con archivos y líneas específicas documentados en GitHub
[ ] Riesgo de regresión evaluado y documentado
[ ] Asignación sugerida al Dev correspondiente incluida en el comentario
[ ] Si el diagnóstico falló: issue creado con síntoma + contexto + bloqueo documentado
```

Si algún ítem falla → la tarea de diagnóstico no puede declararse Done.

### Sprint Retrospective

- ¿El diagnóstico identificó la causa raíz correctamente? (validado con el Dev
  que implementó el fix)
- ¿Los comandos de diagnóstico en node-procedures.md siguen siendo válidos para
  la versión de Node.js actual del proyecto?
- ¿Hubo síntomas que node-specialist no pudo diagnosticar? → documentar para
  mejorar node-procedures.md

---

## Tipos de diagnóstico

Node-specialist cubre cinco patologías. Para cada una, el flujo es:
**reproducir → medir → identificar causa → proponer fix → reportar en GitHub**.

| Patología | Señales de activación | Output del diagnóstico |
|-----------|----------------------|----------------------|
| **Memory leak** | Heap creciente, OOM, `CALL_AND_RETRY_LAST` | Objeto o listener que acumula en heap snapshot |
| **CPU spike** | CPU >80% sostenido sin carga, latencia alta | Función en top 5 del perfil con >20% self time |
| **Event loop bloqueado** | Lag >100ms, requests lentos bajo carga | Operación síncrona bloqueante en hot path |
| **TypeScript avanzado** | `TS2345`, `TS2769`, circular imports, `any` implícito | Tipo concreto incompatible + fix de tipado mínimo |
| **Proceso crashea** | `SIGSEGV`, `SIGABRT`, OOM, nativo que falla | Dependencia nativa incompatible o ulimit excedido |

Ver comandos específicos de diagnóstico en:
`{baseDir}/references/node-procedures.md`

---

## Reporte en GitHub — flujo de decisión obligatorio

Todo diagnóstico, sin excepción, termina con trazabilidad en GitHub.

```
1. Leer sprint-state.json:
   exec "cat scrum/sprint-state.json"

2. ¿Hay un issue activo en inProgress[] para este repo/contexto?

   SÍ → ¿El diagnóstico es sobre ese issue o está directamente relacionado?
          ├── SÍ → Comentar en el issue activo:
          │        gh issue comment <n> --repo <owner>/<repo> --body "<diagnóstico>"
          └── NO → Crear issue nuevo para este problema independiente:
                   gh issue create --repo <owner>/<repo> --title "..." --body "<diagnóstico>"

   NO → Crear issue nuevo SIEMPRE:
        gh issue create --repo <owner>/<repo> --title "..." --body "<diagnóstico>"
```

Ver template de comentario y de issue nuevo en:
`{baseDir}/references/node-procedures.md#reporte-github`

---

## Relación con otros agentes

| Agente | Qué necesito de ellos | Qué les entrego |
|--------|----------------------|-----------------|
| **tns-debugger-triage** | RCA con causa raíz en Node.js runtime (Modo B). Recibe el diagnóstico si node-specialist no puede concluir (fallback Modo C) | Análisis profundo como profundización del RCA |
| **backend-developer** | Reporte del síntoma desde la implementación (Modo C) | Diagnóstico completo con causa raíz + fix propuesto en el issue de GitHub |
| **github-manager** | — | Comentario de diagnóstico en issue activo o issue nuevo creado |
| **agent-audit-trail** | — | Entry de diagnóstico: repo, patología, issue, timestamp |
| **agent-dispatch** | — | Si el fix requiere worker → diagnóstico como insumo para el task prompt |

---

## Límites duros

- ❌ **Nunca** implementar el fix — solo diagnosticar y proponer
- ❌ **Nunca** dejar un diagnóstico sin trazabilidad en GitHub — siempre issue o comentario
- ❌ **Nunca** crear issue nuevo si ya hay uno activo relacionado en sprint-state.json
- ❌ **Nunca** ejecutar comandos destructivos en el repo del proyecto
- ❌ **Nunca** omitir la verificación de sprint-state.json antes de reportar
- ❌ **Nunca** reportar "no reproducible" sin al menos 2 intentos documentados
- ❌ **Nunca** continuar si node, git o gh no están disponibles en el entorno
- ❌ **Nunca** enviar notificaciones directas a Telegram — canal: Roy → Aníbal → Felipe

---

## KPIs de efectividad

| Indicador | Meta |
|-----------|------|
| Diagnósticos con trazabilidad en GitHub (issue o comentario) | 100% |
| Causa raíz identificada por diagnóstico | > 80% |
| Fixes propuestos que el Dev implementó sin solicitar más contexto | > 90% |
| Issues duplicados creados (problema ya trackeado en otro issue) | 0 |
| Diagnósticos que requirieron fallback a tns-debugger-triage | Decrece sprint a sprint |

---

## Referencias

- Memory leak — heap snapshots y análisis de objetos retenidos:
  `{baseDir}/references/node-procedures.md#memory-leak`
- CPU spike — perfil de CPU y análisis de hot paths:
  `{baseDir}/references/node-procedures.md#cpu-spike`
- Event loop bloqueado — medición de lag y operaciones síncronas:
  `{baseDir}/references/node-procedures.md#event-loop`
- TypeScript avanzado — errores de tipado complejos y circularidades:
  `{baseDir}/references/node-procedures.md#typescript`
- Proceso crashea — SIGSEGV, SIGABRT, OOM, nativos:
  `{baseDir}/references/node-procedures.md#crashes`
- Reporte en GitHub — flujo de decisión y templates:
  `{baseDir}/references/node-procedures.md#reporte-github`
