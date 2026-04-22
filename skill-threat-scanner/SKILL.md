---
name: skill-threat-scanner
description: Analiza patrones de comportamiento del sistema autónomo para detectar riesgos, anomalías o posibles amenazas en la operación. Usar cuando se requiera evaluar tendencias, identificar comportamientos anómalos o analizar eventos acumulados en el tiempo. Triggers: "threat", "riesgo", "anomalía", "patrón", "comportamiento", "seguridad", "análisis", "detección", "alerta".
version: 1.0.0
user-invocable: true
metadata: {"openclaw":{"emoji":"🧠","requires":{},"os":["darwin","linux","win32"]}}
---

# Threat Scanner

Skill encargada de detectar patrones de riesgo en el sistema OpenClaw.

## Objetivo

Identificar comportamientos anómalos o potencialmente peligrosos a partir del análisis acumulado de eventos y acciones.

## Qué analiza

- logs del agent-audit-trail
- decisiones de governance-wrapper
- bloqueos de giraffe-guard
- frecuencia y tipo de acciones ejecutadas
- errores recurrentes
- uso de recursos del sistema

## Tipos de amenazas detectables

### Comportamiento errático

- múltiples errores consecutivos
- decisiones inconsistentes
- cambios de dirección sin contexto

### Abuso del sistema

- ejecución excesiva de acciones
- generación masiva de commits o PRs
- spam de interacciones externas

### Riesgos de seguridad

- intentos repetidos de acciones bloqueadas
- acceso o manipulación de credenciales
- modificaciones sensibles recurrentes

### Desalineación operativa

- acciones fuera del backlog
- ejecución sin relación con el sprint
- automatizaciones sin objetivo claro

## Señales de alerta

- incremento sostenido de errores
- múltiples bloqueos por governance
- activación frecuente de giraffe-guard
- comportamiento no determinístico
- desviación del flujo esperado del sistema

## Niveles de alerta

- bajo → comportamiento dentro de lo esperado
- medio → anomalías detectadas, requiere observación
- alto → riesgo significativo, requiere intervención
- crítico → comportamiento peligroso o comprometido

## Respuesta recomendada

- informar → notificar estado
- monitorear → seguimiento continuo
- escalar → requerir validación externa
- detener → detener ejecución del sistema

## Relación con otras skills

- consume datos de agent-audit-trail
- analiza decisiones de governance-wrapper
- monitorea activaciones de giraffe-guard
- alimenta decisiones estratégicas del sistema

## Regla de uso

Cuando se detecten patrones anómalos o repetitivos en el comportamiento del sistema:

**priorizar análisis y contención antes de continuar la operación**
