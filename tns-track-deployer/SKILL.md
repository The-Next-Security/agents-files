---
name: tns-track-deployer
description: 'TNS-specific scaffolder for new TNS Track verticals. Given a client brief in JSON or markdown, creates a new private GitHub repository from the TNS Track template, scaffolds the project, opens an initial PR against dev, and reports with a link to the PR. This skill does NOT deploy to production. It only scaffolds and opens the repo + PR. Production deployment is a separate, human-approved step. RESTRICTED: requires explicit written authorization from Felipe with specific client before any execution. Triggers: ''despliega vertical'', ''nueva vertical TNS Track'', ''crea repo tns-track'', ''scaffold client''.'
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-24
user-invocable: false
allowed-tools: Bash
tags: scaffold deployment tns-track vertical client github restricted
compatibility: Requires git, gh, jq, node. Status: disabled-intentional. Execution requires explicit written authorization from Felipe with specific client name.
metadata: {"openclaw":{"emoji":"🚀","riskLevel":"high","ownerAgent":null,"requires":{"bins":["git","gh","jq","node"],"env":[]},"os":["linux","darwin"],"outputs":[],"scrum":[],"worksWithSkills":[]}}
---

# tns-track-deployer

## Rol Scrum

Lo invocan **Backend Developer + Roy (coordinación)** cuando Felipe
o un humano autorizado solicita la apertura de una nueva vertical TNS
Track para un cliente.

No hace deploy real a producción. El alcance es scaffold + PR
inicial; el deploy queda fuera de 1.0.0 y requiere aprobación humana
explícita en una iteración posterior.

## Cuándo usar

- Cuando Felipe pide: "despliega vertical nueva de TNS Track para
  cliente X".
- Cuando se agrega una nueva vertical al portafolio y hace falta
  el scaffolding inicial.

## Cuándo NO usar

- Para deploy a producción (esto no lo hace esta skill en 1.0.0).
- Para modificar una vertical ya existente (esto lo hace el Dev
  correspondiente con un PR normal).
- Si el brief no incluye autorización explícita del cliente (pedir a
  Felipe antes de continuar).

## Entradas requeridas

Un brief en uno de estos formatos:

### Formato JSON

```json
{
  "client_name": "Acme Corp",
  "client_slug": "acme",
  "industry": "logistics",
  "vertical": "transport-tracking",
  "hardware_target": ["teltonika-fmb920"],
  "deadline": "2026-06-15",
  "authorized_by": "felipe@thenextsecurity.cl"
}
```

### Formato markdown

```markdown
# Brief: Acme Corp

- client_slug: acme
- industry: logistics
- vertical: transport-tracking
- hardware_target: teltonika-fmb920
- deadline: 2026-06-15
- authorized_by: felipe@thenextsecurity.cl
```

Sin los campos obligatorios (`client_name`, `client_slug`, `vertical`,
`authorized_by`), la skill aborta antes de cualquier acción.

## Salida producida

1. Repo GitHub privado creado: `The-Next-Security/tns-track-<client_slug>`.
2. Estructura inicial clonada desde el template
   `The-Next-Security/tns-track-template` (si el template existe).
3. Archivo `.env.example` con variables necesarias documentadas (sin
   secretos reales).
4. `CHANGELOG.md` inicializado con versión `0.1.0`.
5. `README.md` con contexto del cliente, vertical, hardware objetivo
   y próximos pasos.
6. Branch inicial `dev` creada desde `main`.
7. PR inicial abierto `feature/1.0.0-scaffold -> dev` con un commit
   que agrega la configuración específica del cliente.
8. Reporte a Roy con el link al PR.

## Flujo de ejecución

1. Parsear el brief. Validar campos obligatorios.
2. Verificar que el slug del cliente no colisione con un repo ya
   existente (`gh repo view` y fallar con explicación si existe).
3. Crear el repo privado
   (`gh repo create --private --template The-Next-Security/tns-track-template`).
4. Clonar localmente en worktree scratch.
5. Crear branches `main` (default inicial) y `dev`.
6. Proteger `main` (requiere branch protection; si no se puede vía
   token, dejar nota para Felipe en el PR).
7. Crear `feature/1.0.0-scaffold` desde `dev`.
8. Escribir `README.md`, `CHANGELOG.md`, `.env.example` específicos
   del cliente.
9. Commit: `chore(scaffold): initialize <client_slug> vertical`.
10. Push y abrir PR contra `dev` con body que documenta el brief
    procesado, el estado del scaffolding y los próximos pasos
    (autorización de deploy, configuración de secretos, CI).
11. Reportar el link del PR al caller (Roy o Backend Dev).

## Guardrails

- NO hace `gh repo create` con `--public`. Siempre privado.
- NO commitea secretos, credenciales, tokens o valores reales del
  cliente. Solo `.env.example`.
- NO hace deploy a producción. Si el brief pide deploy, responde con
  la limitación de 1.0.0 y lo marca como pendiente de habilitación.
- NO genera webhooks ni integraciones con servicios externos sin
  autorización explícita (en el brief o vía Aníbal).
- NO toca repos existentes. Si el repo ya existe, aborta con
  explicación para que Roy decida si es actualización (otro flujo)
  o si el slug debe cambiar.
- Timeout duro: 30 minutos. Si se excede, reportar estado parcial
  (hasta qué paso llegó) y escalar.

## Tests

La skill incluye tests en `tests/` que validan:
- Parseo correcto del brief en JSON y markdown.
- Rechazo de briefs inválidos (falta de campos obligatorios).
- Que la estructura generada sigue las convenciones de TNS Track.

Los tests usan briefs sintéticos, no hacen llamadas reales a GitHub.

---

## Límites duros

⚠️ **Esta skill está DESHABILITADA por defecto (status=disabled-intentional en el routing registry). No se puede invocar desde workers autónomos.**

- ❌ **Nunca** ejecutar sin autorización escrita de Felipe que especifique el nombre exacto del cliente
- ❌ **Nunca** invocar desde workers autónomos o por Roy sin instrucción explícita de Felipe
- ❌ **Nunca** realizar deploy a producción — alcance estricto: scaffold + PR inicial únicamente
- ❌ **Nunca** crear repos con `--public` — siempre privados
- ❌ **Nunca** commitear secretos, tokens, credenciales o valores reales en el scaffold
- ❌ **Nunca** generar webhooks o integraciones con servicios externos sin autorización explícita del brief o vía Aníbal
- ❌ **Nunca** ejecutar sin registrar la operación completa en agent-audit-trail (cliente, brief hash, repo creado, PR URL)
- ❌ **Nunca** tocar repos existentes — si el repo ya existe, abortar con explicación
