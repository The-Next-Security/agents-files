# Formato del daily stand-up

El daily se reporta en un único mensaje con la siguiente estructura
fija. El orden de los 9 especialistas es siempre el mismo para que
los humanos puedan escanear rápido.

## Estructura canónica

```
Daily stand-up — <fecha ISO>
Sprint: <sprint-id> — día <N> de <M>

== Product Owner ==
Ayer: <acciones concretas>
Hoy: <plan concreto>
Blockers: <si hay, si no omitir o "ninguno">

== QA Analyst ==
...

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
<si hay, formato TOOLS.md>
```

## Reglas de redacción

- Cada acción en pasado (ayer) o presente (hoy) comienza con verbo.
- Sin adjetivos vacíos ("excelente trabajo", "importante avance").
- Sin emojis.
- Máximo 3 líneas por especialista (ayer + hoy + blockers).
- Si no hay actividad para un rol, reportar exactamente: "Ayer: sin
  actividad registrada. Hoy: <plan asignado o 'sin asignación'>.
  Blockers: ninguno."
- Si hay bloqueos, nombrar el bloqueador explícitamente (nombre del
  recurso, issue, persona o dependencia).
