---
name: giraffe-guard
description: Aplica guardrails operativos para prevenir comportamientos peligrosos, loops autónomos, ejecuciones descontroladas o acciones fuera de contexto en el sistema OpenClaw. Usar cuando se requiera validar límites de ejecución, frecuencia de acciones o comportamiento global del sistema. Triggers: "guard", "loop", "runaway", "protección", "límite", "control de ejecución", "frecuencia", "spam", "seguridad operativa".
version: 1.0.0
user-invocable: true
metadata: {"openclaw":{"emoji":"🦒","requires":{},"os":["darwin","linux","win32"]}}
---

# Giraffe Guard

Skill de protección operativa del sistema autónomo OpenClaw.

## Objetivo

Evitar que el sistema ejecute acciones peligrosas por comportamiento emergente, errores de lógica o loops no controlados.

## Qué protege

- loops infinitos de ejecución
- acciones repetitivas sin control
- ejecución excesiva en corto tiempo
- llamadas encadenadas sin validación
- automatizaciones fuera de contexto
- saturación del sistema o del gateway
- spam de acciones hacia Git, Telegram u otros canales

## Señales de riesgo

- misma acción ejecutándose múltiples veces en corto intervalo
- múltiples decisiones consecutivas sin intervención externa
- ejecución de acciones sin validación de governance
- incremento anormal en volumen de operaciones
- comportamiento no alineado con backlog o sprint actual

## Reglas base

### Limitar frecuencia

- no permitir ejecuciones repetidas sin pausa
- aplicar throttling si una acción se repite

### Detectar loops

- si una misma acción ocurre más de N veces → escalar o bloquear
- si hay recursividad no controlada → bloquear

### Validar contexto

- toda acción debe estar alineada con:
  - backlog
  - sprint activo
  - tarea en ejecución

### Control de encadenamiento

- limitar profundidad de acciones encadenadas
- evitar cascadas automáticas sin validación

## Respuestas posibles

- permitir → comportamiento normal
- limitar → reducir frecuencia o intensidad
- escalar → requiere validación externa
- bloquear → comportamiento peligroso detectado

## Ejemplos de bloqueo

- loop de commits automáticos
- múltiples PR generados sin control
- ejecución masiva de comandos
- spam de mensajes en Telegram
- ejecución continua de scripts sin fin

## Relación con otras skills

- complementa a governance-wrapper
- alimenta agent-audit-trail
- trabaja junto a skill-threat-scanner
- protege el flujo autónomo del sistema

## Regla de uso

Si el sistema muestra comportamiento repetitivo, no controlado o fuera de contexto:

**detener o limitar antes de permitir continuar**
