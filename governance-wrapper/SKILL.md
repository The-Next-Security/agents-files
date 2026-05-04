---
name: governance-wrapper
description: Capa de gobernanza para validar acciones antes de ejecutar operaciones sensibles del sistema autónomo. Usar cuando se necesite revisar comandos, cambios de archivos, acciones sobre Git, decisiones de ejecución con riesgo operativo o solicitudes que deban pasar por políticas de seguridad y control. Triggers: "governance", "guardrail", "validar acción", "acción riesgosa", "comando peligroso", "policy", "política", "seguridad operativa", "control", "wrapper".
version: 1.0.0
user-invocable: true
metadata: {"openclaw":{"emoji":"🛡️","requires":{},"os":["darwin","linux","win32"]}}
---

# Governance Wrapper

Skill de gobernanza para revisar acciones antes de ejecutarlas en el sistema OpenClaw.

Su propósito es actuar como capa de control previo sobre acciones sensibles, especialmente cuando una petición implique:

- ejecutar comandos de shell
- modificar archivos críticos
- cambiar configuración del sistema
- hacer operaciones destructivas
- actuar sobre Git, worktrees, ramas, commits o PRs
- tocar credenciales, tokens o secretos
- operar fuera del alcance definido por el backlog o por las reglas del sistema

## Objetivo operativo

Aplicar una revisión previa tipo **permitir / bloquear / escalar** antes de continuar con una acción sensible.

## Política base inicial

Bloquear o escalar cualquier acción que incluya, directa o indirectamente:

- borrado destructivo masivo
- reinicio o apagado del sistema
- cambios de permisos inseguros
- acceso o exposición de secretos
- cambios en firewall, SSH o red sin validación explícita
- operaciones Git irreversibles sin justificación
- ejecución fuera del workspace previsto
- acciones que contradigan backlog como source of truth
- acciones que rompan el principio de cambios mínimos y auditables

## Reglas mínimas de decisión

### Permitir

Permitir solo cuando:

- la acción es acotada
- es trazable
- tiene objetivo claro
- es reversible o de bajo riesgo
- está alineada con el backlog y el estado actual del sistema

### Bloquear

Bloquear cuando:

- la acción sea destructiva
- afecte sistema base sin necesidad clara
- toque secretos o autenticación
- implique evasión de controles
- altere evidencia o trazabilidad
- contradiga políticas definidas del proyecto

### Escalar

Escalar cuando:

- el riesgo sea medio o alto
- falte contexto
- existan efectos laterales relevantes
- la acción toque producción, seguridad, identidad o comunicaciones externas

## Formato de evaluación recomendado

Para cada acción sensible, responder con esta estructura:

    Acción evaluada:
    Riesgo: bajo / medio / alto
    Decisión: permitir / bloquear / escalar
    Motivo:
    Controles requeridos:

## Casos típicos a bloquear

- `rm -rf /`
- borrado recursivo fuera del workspace
- `shutdown`
- `reboot`
- `chmod -R 777`
- exponer tokens, claves o credenciales
- desactivar firewall o hardening sin autorización explícita
- push forzado sin contexto aprobado
- modificar backlog source of truth sin trazabilidad

## Casos típicos a escalar

- cambios en `sshd_config`
- cambios en UFW, fail2ban o gateway
- rotación de credenciales
- cambios sobre worktrees del PR autónomo
- automatizaciones con efectos externos no verificados

## Relación con otras skills futuras

Esta skill debe convivir con:

- `agent-audit-trail`: registra decisiones y acciones
- `giraffe-guard`: guardrails operativos más estrictos
- `skill-threat-scanner`: detección de riesgos y patrones
- skills funcionales como `coding-agent`, `git-expert` o `github-manager`

## Regla de uso

Cuando exista duda sobre si una acción debe ejecutarse, esta skill debe priorizar:

**bloquear o escalar antes que permitir**.
