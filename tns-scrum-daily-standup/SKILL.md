---
name: tns-scrum-daily-standup
description: 'TNS-specific Scrum daily stand-up facilitator. Invoked by Roy (Scrum Master) to consolidate status of the 9 specialists into a single compact report for Telegram. Each specialist reports: what was done yesterday, what is planned today, blockers. The skill aggregates, formats under the standard daily structure, and delivers through Roy''s channel. Triggers: ''daily'', ''daily stand-up'', ''standup'', ''daily report'', ''reporte diario''.'
version: 1.0.0
user-invocable: true
metadata: {"openclaw":{"requires":{"bins":["jq"]},"os":["linux","darwin"]}}
---

# tns-scrum-daily-standup

## Rol Scrum

Lo invoca **Roy (Scrum Master)** como facilitador del daily
stand-up, ya sea por trigger manual ("daily") o por el cron del
equipo (`daily-standup` a las 09:00 Chile).

Cada especialista del equipo aporta su mini-reporte y Roy consolida
en un único mensaje compacto para Telegram.

## Cuándo usar

- En el cron diario (09:00 Chile).
- Cuando un humano autorizado (Felipe u otro aprobador) solicita
  "dame el daily" por Telegram.
- Al inicio de un sprint para establecer visibilidad.

## Cuándo NO usar

- Fuera del sprint activo (si no hay sprint, no hay daily).
- Si el equipo no tiene work items asignados (sprint vacío).
- Como reemplazo de un sprint review o retrospective.

## Entradas requeridas

- Acceso de lectura a `/root/.openclaw/scrum/sprint-state.json`.
- Acceso de lectura a `/root/.openclaw/scrum/product-backlog.json`.
- Acceso a los workspaces de los 9 especialistas
  (`/root/.openclaw/agents/<rol>/`) para leer sus heartbeats y
  decisions-log si aplica.
- Acceso GitHub para listar PRs abiertos de los repos activos.

## Salida producida

Un mensaje compacto enviado a Telegram (vía Aníbal) con la
siguiente estructura estándar:

```
Daily stand-up — <fecha ISO>
Sprint: <sprint-id> — día <N> de <M>

== Product Owner ==
Ayer: <qué hizo>
Hoy: <qué planifica>
Blockers: <si hay>

== QA Analyst ==
Ayer: ...
Hoy: ...
Blockers: ...

== Frontend Developer ==
...

== Backend Developer ==
...

== UX Developer ==
...

== Git Expert ==
...

== Docs Expert ==
...

== Node/TS Specialist ==
...

== Debugger Agent ==
...

== Sprint health ==
- Items done / total: X / Y
- PRs abiertos del equipo: N
- CI status (main/dev de los 3 repos): <resumen>
- Impedimentos abiertos: <si hay>

== Necesidades humanas pendientes ==
<si hay, en formato qué/por qué/cómo/bloqueo>
```

Longitud objetivo: máximo 40 líneas. Si excede, Roy recorta las
secciones sin blockers/novedades relevantes.

## Flujo de ejecución

1. Leer `sprint-state.json` y verificar que hay sprint activo. Si
   no, responder "sin sprint activo, daily skipped" y abortar.
2. Para cada uno de los 9 especialistas:
   a. Leer su `~/.openclaw/agents/<rol>/history/decisions-log.md`
      (si existe) para recuperar qué hizo ayer.
   b. Leer items del sprint-state asignados a ese rol para saber
      qué planifica hoy.
   c. Identificar si ese rol reportó bloqueos en heartbeat o en
      comentarios de sus PRs.
3. Consultar `gh pr list` en los 3 repos activos para métrica de
   sprint health.
4. Consultar estado CI (`gh run list`) para cada repo (último run
   en `main` y `dev`).
5. Verificar si hay necesidades humanas pendientes (ver
   `TOOLS.md` sección "Cómo trabajo").
6. Aggregar todo en el formato estándar.
7. Enviar a Telegram vía el helper
   `infra/lib/telegram-notify.sh` (del corredor) o vía el canal
   configurado por Aníbal.
8. Guardar el daily en
   `~/.openclaw/scrum/daily-reports/daily-<fecha>.md` para
   histórico.

## Guardrails

- NO inventa actividad. Si un especialista no tiene actividad
  registrada, reporta "sin actividad registrada" en vez de
  fabricar un reporte.
- NO expone contenido sensible en el reporte (secrets, tokens,
  rutas internas). Si detecta, omite la línea y deja nota al final
  ("<N líneas omitidas por contenido sensible>").
- Máximo 40 líneas en el mensaje final. Exceder implica condensar.
- NO envía el daily si no hay sprint activo; responde con nota
  corta a Roy.
- NO duplica envíos: si el daily de hoy ya se envió (presencia de
  `daily-reports/daily-<fecha>.md`), responde con link al archivo
  y no re-envía.

## Tests

La skill incluye tests en `tests/` que validan el formato del
reporte generado contra datos mock de sprint y especialistas.
