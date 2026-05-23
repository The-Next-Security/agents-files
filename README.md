# agents-files

[![Última actualización](https://img.shields.io/github/last-commit/The-Next-Security/agents-files?label=%C3%BAltimo%20commit&style=flat-square)](https://github.com/The-Next-Security/agents-files/commits/main)
[![Skills](https://img.shields.io/badge/skills-19-blue?style=flat-square)](#catálogo-de-skills)
[![Organización](https://img.shields.io/badge/org-The--Next--Security-black?style=flat-square)](https://github.com/The-Next-Security)
[![Sistema](https://img.shields.io/badge/sistema-OpenClaw-purple?style=flat-square)](https://github.com/The-Next-Security/autonomous-workbench)

Biblioteca canónica de skills del sistema autónomo **OpenClaw** de The Next Security.
Cada carpeta representa una skill operativa con su archivo `SKILL.md` como fuente de
verdad: define identidad, triggers de activación, comportamiento, reglas de operación
y relaciones con otros agentes del sistema.

---

## Índice

- [¿Qué es este repositorio?](#qué-es-este-repositorio)
- [Catálogo de skills](#catálogo-de-skills)
  - [Roles del equipo Scrum](#-roles-del-equipo-scrum)
  - [Skills de sistema OpenClaw](#️-skills-de-sistema-openclaw)
  - [Skills específicas de TNS](#-skills-específicas-de-tns)
- [Estructura del repositorio](#estructura-del-repositorio)
- [Estándar canónico de SKILL.md](#estándar-canónico-de-skillmd)
  - [Frontmatter](#frontmatter)
  - [Cuerpo del archivo](#cuerpo-del-archivo)
- [Cómo agregar una nueva skill](#cómo-agregar-una-nueva-skill)
- [Relación con los otros repos del sistema](#relación-con-los-otros-repos-del-sistema)
- [Política de contribución](#política-de-contribución)
- [Instalación en una nueva organización](#instalación-en-una-nueva-organización)

---

## ¿Qué es este repositorio?

`agents-files` es uno de los tres repositorios base del sistema OpenClaw de The Next Security.
Contiene las skills operativas que definen el comportamiento de los agentes especializados:
qué hacen, cuándo se activan, cómo se relacionan entre sí y qué límites no pueden cruzar.
Cualquier modificación a este repositorio impacta directamente en cómo el sistema autónomo
toma decisiones, delega trabajo y ejecuta tareas de desarrollo bajo el framework Scrum.

---

## Catálogo de skills

### 🧑‍💻 Roles del equipo Scrum

Los nueve especialistas que ejecutan el trabajo técnico bajo coordinación del Scrum Master.
Cada skill define la participación del rol en cada evento Scrum, sus entregables, sus KPIs
y sus límites duros de operación.

| Skill | Emoji | Descripción |
|-------|:-----:|-------------|
| [`product-owner`](./product-owner/SKILL.md) | 📋 | Gestiona el Product Backlog y maximiza el valor del producto. Responsable de User Stories, criterios de aceptación, priorización y aceptación de entregables en Sprint Review. |
| [`scrum-master`](./scrum-master/SKILL.md) | 🏉 | Servant-leader del equipo. Facilita todos los eventos Scrum, remueve impedimentos, protege al equipo de interrupciones externas y gestiona métricas de velocity y burndown. |
| [`backend-developer`](./backend-developer/SKILL.md) | ⚙️ | Implementa la lógica de negocio, APIs REST/GraphQL, persistencia de datos y seguridad del servidor. Define contratos de API con el Frontend Developer y es responsable del hardening de la capa servidor. |
| [`frontend-developer`](./frontend-developer/SKILL.md) | 🖥️ | Desarrolla la capa de presentación: componentes de UI, integración con APIs del backend y optimización de rendimiento cliente. Garante de accesibilidad WCAG 2.1 AA y Core Web Vitals. |
| [`ux-developer`](./ux-developer/SKILL.md) | 🎨 | Diseña la experiencia de usuario aplicando Double Diamond, WCAG 2.1 AA e ISO 9241. Desde el research hasta el handoff al Frontend Developer, incluyendo el Design System y los flujos de usuario. |
| [`qa-analyst`](./qa-analyst/SKILL.md) | 🔍 | Garante técnico de calidad del equipo. Actúa shift-left desde el Grooming: diseña casos de prueba, gestiona defectos, valida la Definition of Done y audita la cobertura de automatización. |
| [`git-expert`](./git-expert/SKILL.md) | 🌿 | Arquitecto del flujo de trabajo técnico de Git y CI/CD. Define la branching strategy, configura pipelines, gestiona releases con semver y audita secretos en el repositorio. |
| [`documentation-expert`](./documentation-expert/SKILL.md) | 📝 | Gestiona toda la documentación técnica y funcional del producto: READMEs, ADRs, documentación de APIs, release notes, guías de onboarding y runbooks. |
| [`node-specialist`](./node-specialist/SKILL.md) | ⚡ | Diagnóstico profundo de performance en Node.js y TypeScript: memory leaks, CPU spikes, event loop bloqueado y errores avanzados de tipado. Se activa cuando `tns-debugger-triage` identifica la causa raíz en el runtime de Node. |

---

### 🛡️ Skills de sistema OpenClaw

Skills transversales que gobiernan el comportamiento autónomo del sistema: seguridad,
trazabilidad, delegación de tareas y protección ante comportamientos no controlados.
No son roles Scrum, son la infraestructura operativa que hace que el sistema sea seguro
y auditable.

| Skill | Emoji | Descripción |
|-------|:-----:|-------------|
| [`agent-audit-trail`](./agent-audit-trail/SKILL.md) | 📜 | Registra y documenta todas las acciones relevantes del sistema para trazabilidad y auditoría. Lo no registrado se considera no ocurrido: toda acción sensible debe poder ser reconstruida desde este trail. |
| [`agent-dispatch`](./agent-dispatch/SKILL.md) | 🚀 | Gestiona el spawn de workers persistentes (backend-dev, frontend-dev, qa-analyst) usando `sessions_spawn`. Garantiza que cada worker se lanza con el `agentId` correcto y sobre el worktree adecuado. |
| [`coding-agent`](./coding-agent/SKILL.md) | 🧩 | Delega tareas de código a agentes CLI (Codex, Claude Code, Pi) mediante procesos en background. Gestiona el ciclo de vida de los agentes: spawn, monitoreo, input y terminación. |
| [`giraffe-guard`](./giraffe-guard/SKILL.md) | 🦒 | Aplica guardrails operativos para prevenir loops infinitos, ejecuciones repetitivas no controladas, spam hacia canales externos y comportamiento emergente peligroso del sistema autónomo. |
| [`github-manager`](./github-manager/SKILL.md) | 🐙 | Gestiona todas las operaciones sobre GitHub: creación de PRs, revisión de CI, gestión de ramas y releases. Punto de entrada centralizado para interacciones con la API de GitHub. |
| [`governance-wrapper`](./governance-wrapper/SKILL.md) | 🛡️ | Capa de gobernanza previa a cualquier acción sensible. Evalúa cada operación con criterio permitir / bloquear / escalar antes de ejecutarla. Principio rector: bloquear o escalar antes que permitir. |
| [`skill-threat-scanner`](./skill-threat-scanner/SKILL.md) | 🧠 | Analiza patrones de comportamiento del sistema para detectar anomalías, riesgos y posibles amenazas. Consume datos de `agent-audit-trail` y activaciones de `giraffe-guard` para alimentar decisiones de contención. |

---

### 🏢 Skills específicas de TNS

Skills diseñadas para los flujos operativos propios de The Next Security: diagnóstico
de bugs en los repos del sistema, reporte diario del equipo autónomo y scaffolding de
nuevas verticales del producto TNS Track.

| Skill | Descripción |
|-------|-------------|
| [`tns-debugger-triage`](./tns-debugger-triage/SKILL.md) | Bug triage específico de TNS. Dado un issue con label `bug`, produce un RCA determinístico en `~/tns-debug/rca-<issue-id>.md` con síntoma, reproducción, causa raíz, commit culpable y fix propuesto. Solo diagnostica; no implementa fixes. |
| [`tns-scrum-daily-standup`](./tns-scrum-daily-standup/SKILL.md) | Facilitador del daily stand-up del equipo autónomo. Lo invoca Roy (Scrum Master) para consolidar el estado de los 9 especialistas en un reporte compacto de máximo 40 líneas enviado a Telegram vía Aníbal. |
| [`tns-track-deployer`](./tns-track-deployer/SKILL.md) | Scaffolding de nuevas verticales TNS Track. Dado un brief de cliente (JSON o markdown), crea el repositorio privado, estructura el proyecto desde el template y abre el PR inicial contra `dev`. No hace deploy a producción. |

---

## Estructura del repositorio

Cada skill ocupa una carpeta propia. El único archivo obligatorio es `SKILL.md`.
Las subcarpetas `references/` y `tests/` son opcionales pero recomendadas para
skills complejas que requieren documentación de respaldo o validación automatizada.

```
agents-files/
├── <nombre-del-skill>/
│   ├── SKILL.md              ← fuente de verdad operativa de la skill (OBLIGATORIO)
│   ├── references/           ← documentación de respaldo, estándares, procedimientos (OPCIONAL)
│   │   └── *.md
│   └── tests/                ← validaciones del comportamiento de la skill (OPCIONAL)
│       └── *.js / *.md
├── README.md                 ← este archivo
└── ...
```

---

## Estándar canónico de SKILL.md

Toda skill de este repositorio sigue el mismo estándar de estructura. Respetarlo
garantiza que los agentes del sistema puedan leer, interpretar y activar cualquier
skill de forma predecible. Las desviaciones del estándar se consideran deuda técnica
y deben corregirse antes del siguiente release.

### Frontmatter

El frontmatter usa **JSON inline** para el campo `metadata`. Este es el formato estándar
del repo — todos los skills existentes lo usan y OpenClaw lo parsea de esta manera.
No usar YAML expandido para `metadata`, aunque sea equivalente, para mantener consistencia.

```yaml
---
name: nombre-del-skill                                        # OBLIGATORIO — kebab-case, único en el repo
description: Línea 1 qué hace el skill y para qué existe. Línea 2 cuándo activarlo y en qué contexto. Triggers: "palabra1", "palabra2", "palabra3".
                                                              # OBLIGATORIO — string inline, mínimo 3 ideas:
                                                              #   1. Qué hace y para qué existe
                                                              #   2. Cuándo usarlo y contexto de activación
                                                              #   3. Lista explícita de triggers de activación
version: 1.0.0                                                # OBLIGATORIO — semver
user-invocable: true                                          # OBLIGATORIO — true o false
metadata: {"openclaw":{"emoji":"🔧","requires":{"bins":["git"],"env":[]},"os":["darwin","linux","win32"]}}
                                                              # OBLIGATORIO — JSON inline
                                                              #   emoji: único en el repo
                                                              #   requires.bins: binarios necesarios ([] si ninguno)
                                                              #   requires.env: variables de entorno ([] si ninguna)
                                                              #   requires.anyBins: OPCIONAL — cualquiera basta
                                                              #   os: OPCIONAL — omitir si aplica a todos
                                                              #   install: OPCIONAL — si requiere instalación especial
homepage: https://referencia.com                              # OPCIONAL — URL de documentación externa
---
```

**Ejemplo real** tomado de un skill del repo:

```yaml
---
name: qa-analyst
description: Gestiona el aseguramiento de calidad del producto de software. Usar cuando se necesite revisar criterios de aceptación, diseñar casos de prueba, registrar defectos o validar la Definition of Done. Triggers: "prueba", "test", "bug", "defecto", "QA", "calidad", "DoD", "regresión", "cobertura".
version: 1.0.0
homepage: https://agentskills.io
metadata: {"openclaw":{"emoji":"🔍","requires":{"bins":[],"env":[]},"os":["darwin","linux","win32"]}}
---
```

### Cuerpo del archivo

El cuerpo sigue una estructura de secciones estándar. Las marcadas como **OBLIGATORIO**
deben estar presentes en toda skill. Las **RECOMENDADAS** aplican según la naturaleza
del skill y su complejidad operativa.

```
# Nombre del Skill                    ← OBLIGATORIO — H1 con nombre legible
Descripción de 1-3 líneas.            ← OBLIGATORIO — qué es y cuál es su principio rector

## Cuándo activarme                   ← OBLIGATORIO — casos de uso concretos
## Cuándo NO usar / Protocolo         ← OBLIGATORIO — límites de activación y contexto mínimo
## Flujo de ejecución / por evento    ← OBLIGATORIO — pasos concretos y ordenados
## Guardrails / Límites duros         ← OBLIGATORIO — prohibiciones no negociables
## Relación con otras skills          ← RECOMENDADO — tabla de coordinación con otros agentes
## KPIs de efectividad                ← RECOMENDADO — métricas medibles del rol
## Referencias                        ← RECOMENDADO si hay archivos en references/
```

> **Nota sobre `{baseDir}`:** en el cuerpo del SKILL.md se puede usar `{baseDir}` como
> placeholder para referir a la carpeta raíz del skill en tiempo de ejecución.
> Ejemplo: `{baseDir}/references/be-standards.md#api-design`

---

## Cómo agregar una nueva skill

Seguir estos pasos en orden. No saltear ninguno — cada uno tiene un propósito.

### 1. Crear la carpeta

```bash
mkdir agents-files/<nombre-kebab-case>
```

El nombre debe ser descriptivo, en kebab-case y único en el repo.
Ejemplos correctos: `cache-manager`, `tns-alert-router`, `deploy-validator`.

### 2. Crear el `SKILL.md`

Usar el estándar canónico definido en la sección anterior. Checklist mínimo:

```
[ ] name: único, kebab-case
[ ] description: mínimo 3 líneas con triggers explícitos
[ ] version: 1.0.0 para skills nuevas
[ ] user-invocable: declarado explícitamente (true o false)
[ ] emoji: único, no usado por otra skill del repo
[ ] Secciones obligatorias del cuerpo presentes
[ ] Límites duros documentados
```

### 3. Agregar references/ si aplica

Si la skill tiene procedimientos detallados, estándares o templates que extenderían
demasiado el `SKILL.md`, crear la carpeta `references/` con archivos markdown separados
y referenciarlos desde el `SKILL.md` usando `{baseDir}/references/<archivo>.md#sección`.

### 4. Agregar tests/ si aplica

Si la skill produce entregables verificables (documentos con estructura fija, reportes,
scaffolding), crear tests que validen esa estructura usando datos sintéticos.
Los tests no deben hacer llamadas reales a GitHub ni a servicios externos.

### 5. Actualizar este README

Agregar la nueva skill en la tabla del grupo correspondiente:
- **Roles del equipo Scrum** — si es un rol especialista del equipo de desarrollo
- **Skills de sistema OpenClaw** — si es infraestructura transversal del sistema autónomo
- **Skills específicas de TNS** — si es un flujo operativo propio de The Next Security

Actualizar el badge de conteo de skills en el encabezado.

### 6. Abrir el PR

```bash
# Crear rama desde dev
git checkout dev
git pull origin dev
git checkout -b feat/skill-<nombre>

# Un commit por archivo creado
git add <nombre>/SKILL.md
git commit -m "feat(<nombre>): agregar skill SKILL.md"

git add <nombre>/references/<archivo>.md   # si aplica
git commit -m "docs(<nombre>): agregar referencias"

git add README.md
git commit -m "docs(readme): registrar skill <nombre> en catálogo"

git push -u origin feat/skill-<nombre>
```

El PR debe ir a `dev`, no a `main`. Se requieren 2 aprobadores incluyendo `andresTNS`.

---

## Relación con los otros repos del sistema

`agents-files` forma parte de un sistema de tres repositorios que trabajan en conjunto.
Modificar uno puede impactar a los otros, por lo que los cambios que afecten interfaces
o contratos entre repos deben coordinarse antes de abrirse como PR.

| Repositorio | Rol en el sistema |
|-------------|------------------|
| [`agents-files`](https://github.com/The-Next-Security/agents-files) *(este repo)* | Biblioteca de skills de los agentes especializados. Define qué hace cada agente, cómo se activa y qué límites respeta. |
| [`autonomous-workbench`](https://github.com/The-Next-Security/autonomous-workbench) | Corredor de ejecución del sistema. Aquí vive Roy (Scrum Master), los docs de arquitectura, la infraestructura y los worktrees de trabajo autónomo. |
| [`scrum-files`](https://github.com/The-Next-Security/scrum-files) | Motor Scrum del sistema. Contiene `sprint-manager.js`, el Product Backlog, el estado del sprint activo y el catálogo de repos. |

**Jerarquía operativa:**

```
Felipe (humano — decisiones estratégicas y aprobaciones)
  └── Aníbal (capa 0 — interfaz Telegram, recibe instrucciones)
        └── Roy (capa 1 — Scrum Master, coordina desde autonomous-workbench)
              └── 9 especialistas (capa 2 — ejecutan usando las skills de este repo)
```

---

## Política de contribución

### Ramas

| Rama | Propósito | ¿Commits directos? |
|------|-----------|--------------------|
| `main` | Código en producción | ❌ Nunca |
| `dev` | Rama de integración | ❌ Solo via PR |
| `feat/<slug>` | Nueva skill o funcionalidad | ✅ Rama de trabajo |
| `fix/<slug>` | Corrección de skill existente | ✅ Rama de trabajo |
| `docs/<slug>` | Cambios solo de documentación | ✅ Rama de trabajo |

Toda rama de trabajo se crea desde `dev`. Los PRs tienen `dev` como base. Nunca se
abre un PR directamente a `main` salvo en proceso de release formal.

### Commits

Formato obligatorio: [Conventional Commits](https://www.conventionalcommits.org/)

```
<tipo>(<scope>): descripción corta en español

# Tipos válidos:
feat      → nueva skill o funcionalidad
fix       → corrección de skill existente
docs      → cambios solo de documentación (README, referencias)
refactor  → reestructuración sin cambio funcional
chore     → mantenimiento (renombrar, mover archivos)
test      → agregar o corregir tests de skills
```

**Regla:** un commit por archivo modificado. No agrupar cambios de múltiples skills
en un solo commit. Esto garantiza historial limpio y reversiones quirúrgicas.

```bash
# ✅ Correcto
git commit -m "feat(tns-alert-router): agregar skill SKILL.md"
git commit -m "docs(tns-alert-router): agregar referencias de alertas"
git commit -m "docs(readme): registrar tns-alert-router en catálogo"

# ❌ Incorrecto
git commit -m "agregar nueva skill con referencias y actualizar readme"
```

### Pull Requests

**Checklist obligatorio antes de abrir un PR:**

```
[ ] La rama parte de dev actualizado (git pull origin dev)
[ ] SKILL.md cumple el estándar canónico (frontmatter + secciones obligatorias)
[ ] Emoji de la nueva skill es único en el repo
[ ] README actualizado con la nueva skill en el grupo correcto
[ ] Badge de conteo actualizado si se agregó o eliminó una skill
[ ] Un commit por archivo (no commits agrupados)
[ ] Sin secretos, tokens ni credenciales en ningún archivo
[ ] PR apunta a dev, no a main
```

**Proceso de revisión:**

```bash
# Ver PRs pendientes de revisión
gh pr list --repo The-Next-Security/agents-files --state open

# Revisar diff
gh pr diff <número>

# Aprobar
gh pr review <número> --approve --body "LGTM ✅"

# Solicitar cambios
gh pr review <número> --request-changes --body "Motivo específico"

# Merge (squash solo si hay commits de fixup; no-ff para features)
gh pr merge <número> --merge --delete-branch
```

**Aprobadores requeridos:** mínimo 2, incluyendo obligatoriamente `andresTNS`.
Los aprobadores autorizados son: `felipecleverox`, `Bufigol`, `TNSTRACK`, `andresTNS`.

### Lo que NO va en este repositorio

```
❌ Estado de autenticación (auth-profiles.json, tokens OAuth)
❌ Historial de sesiones de agentes
❌ Backups (.tgz, .bak.*)
❌ Secretos, API keys o credenciales de ningún tipo
❌ Archivos de estado runtime (.json con estado mutable del sistema)
```

El estado runtime vive en `~/.openclaw/` en el servidor, no en este repo.

---

## Instalación en una nueva organización

Este repositorio está configurado para la instalación de **The Next Security (TNS)**.
Si lo estás desplegando en otra organización, los valores específicos de TNS se usan
como referencia: reemplázalos por los de tu instalación antes de poner en operación.
El sistema no funcionará correctamente si quedan valores de TNS en una instalación ajena.

| Valor | Dónde aparece | Valor TNS (referencia) | Tu valor |
|-------|---------------|------------------------|----------|
| Nombre de la organización | Badges, URLs de repos, menciones | `The-Next-Security` | `<tu-org-github>` |
| Nombre del sistema | Badges, README, documentación | `OpenClaw` | `<nombre-de-tu-sistema>` |
| Aprobadores de PR | Política de contribución | `andresTNS`, `Bufigol`, `TNSTRACK`, `felipecleverox` | `<tus-usuarios-github>` |
| Aprobador obligatorio | Política de contribución | `andresTNS` | `<tu-aprobador-principal>` |
| Repo del corredor | Sección "Relación con otros repos" | `autonomous-workbench` | `<tu-workbench>` |
| Repo del motor Scrum | Sección "Relación con otros repos" | `scrum-files` | `<tu-scrum-repo>` |
| Canal de mensajería | Skills `tns-*` | Telegram | `<tu-canal>` |
| Agente de interfaz | Jerarquía operativa | Aníbal | `<nombre-de-tu-agente-capa-0>` |
| Agente Scrum Master | Jerarquía operativa | Roy | `<nombre-de-tu-agente-capa-1>` |
| Ruta del estado runtime | Skills y documentación | `~/.openclaw/` | `<tu-ruta-de-estado>` |

### Pasos de instalación

```bash
# 1. Clonar el repositorio
git clone https://github.com/<tu-org>/agents-files.git
cd agents-files

# 2. Crear tu rama de trabajo desde dev
git checkout dev
git checkout -b feat/install-<tu-org>

# 3. Actualizar los valores propios de TNS en README.md
#    (badges, URLs, aprobadores, nombres de agentes)

# 4. Revisar las skills TNS-específicas y adaptarlas a tu stack:
#    tns-debugger-triage, tns-scrum-daily-standup, tns-track-deployer

# 5. Verificar que los binarios requeridos están disponibles en tu servidor
#    Los más comunes: git, gh, jq, node
which git gh jq node

# 6. Abrir PR a dev con tus cambios de configuración
git add README.md
git commit -m "chore(install): configurar para <tu-org>"
git push -u origin feat/install-<tu-org>
gh pr create --base dev --title "chore(install): configurar para <tu-org>"
```

### Skills que requieren adaptación obligatoria

Las skills genéricas (roles Scrum y sistema OpenClaw) funcionan sin cambios.
Las siguientes skills son específicas de TNS y deben revisarse antes de usar:

| Skill | Qué adaptar |
|-------|-------------|
| [`tns-debugger-triage`](./tns-debugger-triage/SKILL.md) | Rutas de repos, formato de RCA, canal de reporte |
| [`tns-scrum-daily-standup`](./tns-scrum-daily-standup/SKILL.md) | Canal de mensajería, rutas de estado del sprint, horario del cron |
| [`tns-track-deployer`](./tns-track-deployer/SKILL.md) | Nombre del template de repo, org de GitHub, campos del brief |
