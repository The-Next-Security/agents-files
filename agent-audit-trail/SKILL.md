---
name: agent-audit-trail
description: Registra y documenta acciones relevantes del sistema autónomo para trazabilidad, auditoría y análisis posterior. Usar cuando se ejecuten acciones sensibles, cambios en archivos, operaciones sobre Git, decisiones relevantes o eventos que deban quedar registrados. Triggers: "audit", "log", "registro", "trazabilidad", "evidencia", "tracking", "historial", "auditoría", "evento", "acción ejecutada".
version: 1.0.0
user-invocable: true
metadata: {"openclaw":{"emoji":"📜","requires":{},"os":["darwin","linux","win32"]}}
---

# Agent Audit Trail

Skill encargada de registrar eventos y acciones relevantes del sistema OpenClaw.

## Objetivo

Mantener trazabilidad completa de lo que ocurre en el sistema autónomo:

- acciones ejecutadas
- decisiones tomadas
- errores ocurridos
- bloqueos de seguridad
- cambios sobre el sistema o repositorio

## Qué se debe registrar

Registrar siempre que ocurra alguno de los siguientes:

- ejecución de comandos
- cambios en archivos
- acciones sobre Git como commit, push o PR
- decisiones de governance como permitir, bloquear o escalar
- errores o excepciones
- eventos del flujo Scrum
- acciones iniciadas por Telegram

## Formato de registro recomendado

    Timestamp:
    Actor (skill/agente):
    Acción:
    Resultado:
    Riesgo:
    Contexto:

## Niveles de riesgo

- bajo: acciones rutinarias sin impacto relevante
- medio: cambios que afectan estado del sistema
- alto: acciones sensibles sobre seguridad, producción o datos críticos

## Principios

- todo lo importante se registra
- lo no registrado se considera no ocurrido
- los registros deben ser claros y legibles
- evitar ruido innecesario y no registrar por registrar

## Casos obligatorios de registro

- cualquier acción evaluada por governance-wrapper
- bloqueos de seguridad
- modificaciones del backlog
- cambios en configuración del sistema
- ejecución de automatizaciones
- errores en ejecución de agentes

## Relación con otras skills

- recibe eventos desde governance-wrapper
- complementa a giraffe-guard
- alimenta análisis de skill-threat-scanner
- permite trazabilidad para debugging y mejora continua

## Regla de uso

Toda acción relevante del sistema debe poder ser reconstruida a partir de este audit trail.
