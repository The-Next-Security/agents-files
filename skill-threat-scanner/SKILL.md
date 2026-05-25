---
name: skill-threat-scanner
description: Analiza patrones de comportamiento del sistema autónomo para detectar riesgos, anomalías y posibles amenazas en la operación. Opera en modo pasivo, consumiendo el audit trail de agent-audit-trail y las señales de governance-wrapper y giraffe-guard para identificar tendencias peligrosas que ningún skill individual puede detectar por sí solo. Triggers: "threat", "riesgo", "anomalía", "patrón", "comportamiento", "seguridad", "análisis", "detección", "alerta".
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-23
user-invocable: false
allowed-tools: Bash
tags: threat detection anomaly patterns security analysis governance passive always-on monitoring
compatibility: Requires agent-audit-trail data. Compatible with any OpenClaw or Hermes environment.
metadata: {"openclaw":{"emoji":"🧠","riskLevel":"low","ownerAgent":"system","requires":{"bins":[],"env":[]},"os":["linux","darwin"],"outputs":["threatReport","alertLevel"],"scrum":["execution","retrospective"],"worksWithSkills":["agent-audit-trail","governance-wrapper","giraffe-guard"]}}
---

# Skill Threat Scanner

Skill de análisis de amenazas del sistema OpenClaw. Opera en modo pasivo, consumiendo
datos de agent-audit-trail, governance-wrapper y giraffe-guard para detectar patrones
peligrosos que emergen con el tiempo y no son visibles en una sola acción aislada.

**Diferencia clave:** governance-wrapper y giraffe-guard evalúan acciones individuales.
Threat Scanner detecta **patrones que solo son visibles en series de eventos**.

---

## Modo de operación

Este skill opera en modo **pasivo y analítico**. No evalúa acciones en tiempo real —
analiza el historial acumulado para identificar tendencias. Puede activarse bajo demanda
por Roy o ejecutarse periódicamente.

- **Activación**: periódica (configurable) o bajo demanda de Roy
- **Input**: audit trail de agent-audit-trail, decisiones de governance-wrapper, señales de giraffe-guard
- **Output**: informe de amenazas con nivel de alerta y recomendación de respuesta

---

## Qué analiza

- Logs completos del agent-audit-trail del sprint activo
- Historial de decisiones de governance-wrapper (bloqueos/escalamientos)
- Frecuencia y tipos de activaciones de giraffe-guard
- Distribución temporal de acciones por tipo y actor
- Errores recurrentes en workers o skills
- Volumen de operaciones por canal (GitHub, Telegram, Git)

---

## Tipos de amenazas detectables

### Comportamiento errático

- Múltiples errores consecutivos del mismo agente sin recuperación
- Decisiones inconsistentes de governance en contextos similares
- Cambios de dirección frecuentes sin input externo que los justifique

### Abuso del sistema

- Ejecución excesiva de acciones respecto al volumen típico del sprint
- Generación masiva de commits o PRs en ventana de tiempo corta
- Spam de interacciones con sistemas externos

### Riesgos de seguridad

- Intentos repetidos de acciones bloqueadas por governance-wrapper
- Intentos de acceso a credenciales o secretos en múltiples ocasiones
- Modificaciones sensibles recurrentes no alineadas con el sprint

### Desalineación operativa

- Acciones frecuentes fuera del contexto del sprint activo
- Workers ejecutando tareas no relacionadas con su issue asignado
- Automatizaciones generando efectos externos sin trazabilidad en el backlog

---

## Niveles de alerta

| Nivel | Descripción | Acción recomendada |
|-------|------------|-------------------|
| **bajo** | Comportamiento dentro de lo esperado | Informar al cierre del sprint (Retrospective) |
| **medio** | Anomalías detectadas, requiere observación | Informar a Roy; monitorear sprint activo |
| **alto** | Riesgo significativo, patrón confirmado | Escalar a Roy inmediatamente |
| **crítico** | Comportamiento peligroso o comprometido | Detener la sesión activa; escalar a Felipe vía Aníbal |

---

## Proceso de análisis

```
1. Leer audit trail del período:
   tail -n 500 ~/.openclaw/audit/audit-trail.log

2. Calcular métricas base:
   - Total de acciones por tipo
   - Tasa de errores (errores / total acciones)
   - Tasa de bloqueos (bloqueados / total evaluados por governance)
   - Activaciones de giraffe-guard

3. Comparar contra umbrales:
   - Tasa de errores > 20% → nivel medio
   - Tasa de bloqueos > 10% → nivel medio
   - Intentos de acciones bloqueadas repetidas > 3 → nivel alto
   - Comportamiento no relacionado con sprint activo > 30% → nivel alto

4. Identificar patrones temporales:
   - ¿Las anomalías están concentradas en un período?
   - ¿Hay correlación con un skill o worker específico?
   - ¿El patrón se repite de sprint a sprint?

5. Generar informe:
   - Nivel de alerta global
   - Top 3 anomalías identificadas con evidencia
   - Recomendación de respuesta
```

---

## Formato de informe

```
Período analizado: [inicio] — [fin]
Nivel de alerta: bajo | medio | alto | crítico

Métricas del período:
  Total acciones registradas: N
  Tasa de errores: X%
  Tasa de bloqueos por governance: Y%
  Activaciones de giraffe-guard: N

Anomalías detectadas:
  1. [descripción del patrón + evidencia del audit trail]
  2. [descripción del patrón + evidencia del audit trail]
  3. [descripción del patrón + evidencia del audit trail]

Recomendación:
  [informar | monitorear | escalar a Roy | detener sesión]
```

---

## Flujo por evento Scrum

### Backlog Grooming / Sprint Planning

Roy puede solicitar un análisis de riesgos basado en el historial de sprints anteriores
para informar la planificación. Skill-threat-scanner provee: patrones históricos de
errores, skills con mayor tasa de anomalías, áreas del sistema con escalamientos frecuentes.

### Daily Scrum

No participa en el Daily. Si detecta una amenaza de nivel alto o crítico durante
el sprint → alerta inmediata a Roy **sin esperar el Daily**.

### Ejecución durante el Sprint

Ejecuta análisis periódico del audit trail acumulado. Frecuencia recomendada: al
final de cada sesión activa o cuando giraffe-guard detecta comportamiento anómalo.

### Pre-Sprint Review

Generar informe de cierre del sprint para presentar en Sprint Review:
- Nivel de alerta global del sprint
- Top anomalías identificadas
- Áreas del sistema que requieren atención en el próximo sprint

### Sprint Retrospective

Proveer datos para la retrospectiva:
- Tendencias de sprint a sprint (¿mejora o empeora la tasa de anomalías?)
- Skills o workers con mayor tasa de errores/bloqueos
- Recomendaciones de cambios en política de governance o umbrales de giraffe-guard

---

## Relación con otras skills

| Skill | Qué recibo | Qué entrego |
|-------|-----------|------------|
| **agent-audit-trail** | Dataset completo de eventos del sistema | Análisis de patrones y nivel de alerta |
| **governance-wrapper** | Historial de decisiones permit/block/escalar | Identificación de patrones en decisiones de governance |
| **giraffe-guard** | Historial de frecuencias y bloqueos de runaway | Análisis de loops y comportamiento repetitivo a largo plazo |
| **Roy (Scrum Master)** | — | Informe de amenazas con nivel de alerta y recomendación de acción |

---

## Límites duros

- ❌ **Nunca** emitir alertas sin evidencia concreta del audit trail
- ❌ **Nunca** modificar el audit trail durante el análisis — solo lectura
- ❌ **Nunca** detener la sesión del sistema sin alerta de nivel crítico confirmada
- ❌ **Nunca** escalar directamente a Felipe — canal obligatorio: Roy → Aníbal → Felipe
  (salvo nivel crítico con autorización de D-013 breakglass)
- ❌ **Nunca** bajar el nivel de alerta sin evidencia de resolución del patrón

---

## KPIs de efectividad

| Indicador | Meta |
|-----------|------|
| Amenazas de nivel alto/crítico detectadas antes de causar daño | > 95% |
| Falsos positivos (alertas sin evidencia real) | < 10% |
| Informes de Sprint Retrospective generados | 100% de los sprints |
| Tiempo de detección de patrón anómalo desde inicio | < 1 sesión |
| Amenazas repetidas en sprints consecutivos (no resueltas) | 0 |
