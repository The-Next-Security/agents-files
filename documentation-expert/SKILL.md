---
name: documentation-expert
description: Gestiona toda la documentación técnica y funcional del producto. Usar cuando se necesite crear o actualizar un README, redactar un Architecture Decision Record (ADR), documentar una API, generar release notes o changelog, escribir una guía de onboarding, crear un manual de usuario, definir estándares de documentación, revisar documentación desactualizada, o asegurar que la Definition of Done incluya criterios de documentación. Triggers: "documenta", "README", "ADR", "release notes", "changelog", "manual", "onboarding", "documentación", "guía", "runbook", "CONTRIBUTING", "Swagger", "OpenAPI", "Storybook", "arquitectura", "decisión técnica".
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-24
user-invocable: true
allowed-tools: Bash
tags: documentation readme adr changelog release-notes onboarding api-docs technical-writing
compatibility: No external dependencies. Requires read access to the codebase and GitHub for PR-based documentation workflows.
metadata: {"openclaw":{"emoji":"📝","riskLevel":"low","ownerAgent":"backend-dev","requires":{"bins":[],"env":[]},"os":["linux","darwin"],"outputs":["updatedDocs","changelog"],"scrum":["grooming","planning","daily","execution","pre-review","retro"],"worksWithSkills":["scrum-master","product-owner","backend-developer","frontend-developer","qa-analyst","ux-developer","github-manager"]}}
---

# Documentation Expert

Developer responsable de que el conocimiento del producto, el sistema y el proceso esté capturado, organizado y disponible para quienes lo necesiten.

> **Principio rector:** La documentación es parte del producto, no un anexo. Si una funcionalidad no tiene documentación, no está terminada.

---

## Setup

Antes de operar, identificar:

```
1. ¿Qué tipo de documentación se necesita? (técnica / funcional / proceso)
2. ¿Para quién es? (developers / stakeholders / usuarios finales)
3. ¿Dónde debe vivir? (repo / Notion / Confluence / sitio de docs)
4. ¿Requiere input de otro agente? (FE, BE, QA, PO, UX)
```

---

## Tipos de documentación

### Técnica (para developers)

| Tipo | Dónde vive | Propietario |
|------|-----------|-------------|
| README | Raíz del repo | Documentation Expert (exclusivo) |
| ADR | `/docs/adr/` | Documentation Expert + FE/BE |
| Documentación de APIs | OpenAPI/Swagger | Documentation Expert + BE |
| Documentación de componentes FE | Storybook / JSDoc | Documentation Expert + FE |
| Diagramas de arquitectura | `/docs/diagrams/` | Documentation Expert |
| Runbooks | `/docs/runbooks/` | Documentation Expert |
| CONTRIBUTING.md | Raíz del repo | Documentation Expert + Git workflow |

### Funcional (para stakeholders y usuarios)

| Tipo | Dónde vive | Propietario |
|------|-----------|-------------|
| Manual de usuario | Notion / Confluence / sitio docs | Documentation Expert (exclusivo) |
| Especificaciones funcionales | Markdown o Confluence | Documentation Expert |
| Changelog / Release Notes | `CHANGELOG.md` | Documentation Expert + PO |
| Glosario del dominio | Markdown o Confluence | Documentation Expert |

### Proceso (para el equipo Scrum)

| Tipo | Dónde vive | Propietario |
|------|-----------|-------------|
| Definition of Done | Herramienta del equipo + Markdown | Equipo completo |
| Guía de onboarding | Notion / Confluence / Markdown | Documentation Expert (exclusivo) |
| Team playbook | Notion / Confluence | Documentation Expert |

---

## README — estructura estándar

```markdown
# Nombre del Proyecto

Descripción de una línea: qué hace y para quién.

## Requisitos previos
- Node 20+ / Python 3.11+ / etc.
- Variables de entorno necesarias (ver `.env.example`)

## Setup local
```bash
git clone ...
cd proyecto
cp .env.example .env
npm install
npm run dev
```

## Cómo ejecutar pruebas
```bash
npm test            # unitarias
npm run test:e2e    # end-to-end
```

## Estructura del proyecto
```
src/
├── components/   ← UI components
├── api/          ← llamadas a backend
└── utils/        ← helpers compartidos
```

## Cómo contribuir
Ver [CONTRIBUTING.md](./CONTRIBUTING.md)

## Links útiles
- [Documentación de APIs](./docs/api/)
- [ADRs](./docs/adr/)
- [Guía de onboarding](./docs/onboarding.md)
```

---

## ADR — Architecture Decision Record

### Cuándo crear un ADR
- Cambio de framework o librería principal
- Decisión de arquitectura con trade-offs significativos
- Elección de estrategia de autenticación / seguridad
- Cambio en la estructura de la BD o el modelo de datos
- Cualquier decisión que el equipo probablemente se preguntará "¿por qué hicimos esto?"

### Estructura estándar

```markdown
# ADR-NNN: Título de la decisión

**Fecha:** YYYY-MM-DD
**Estado:** Propuesto | Aceptado | Obsoleto | Reemplazado por ADR-NNN

## Contexto
¿Qué problema o situación nos llevó a tomar esta decisión?

## Decisión
¿Qué decidimos hacer?

## Alternativas consideradas
- **Opción A:** descripción — pros/contras
- **Opción B:** descripción — pros/contras

## Consecuencias
- ✅ Qué se gana
- ⚠️  Qué se sacrifica o complica
- 📌 Decisiones futuras que esto condiciona
```

Guardar en `/docs/adr/NNN-titulo-kebab-case.md`

---

## Release Notes / Changelog

### Formato estándar

```markdown
## [v1.2.0] — YYYY-MM-DD

### Nuevas funcionalidades
- feat: descripción clara para el usuario final (#PR)

### Correcciones
- fix: descripción del bug corregido (#PR)

### Cambios internos
- chore: refactor, dependencias, CI (sin impacto para el usuario)

### Breaking changes ⚠️
- Describir qué cambia y cómo migrar

**Full changelog:** https://github.com/OWNER/REPO/compare/v1.1.0...v1.2.0
```

### Generar desde PRs mergeados (GitHub)

```bash
gh release create v1.2.0 --generate-notes --repo OWNER/REPO
# Draft primero para revisar antes de publicar:
gh release create v1.2.0 --generate-notes --draft --repo OWNER/REPO
```

---

## Guía de onboarding — estructura mínima

```markdown
# Onboarding — [Nombre del Proyecto]

## Accesos que necesitas (pedir a quién)
- [ ] GitHub: repo + org → pedir a [persona/rol]
- [ ] Variables de entorno → pedir a [persona/rol]
- [ ] Acceso a BD de staging → pedir a [persona/rol]

## Setup del entorno local
Ver README.md — sección "Setup local"

## Arquitectura en 5 minutos
[Diagrama o descripción breve]

## Flujo de trabajo del equipo
1. Tomar issue del backlog
2. Crear rama desde main: `git checkout -b feature/nombre`
3. Commits con Conventional Commits
4. PR → review → merge con squash

## A quién preguntar
| Tema | Persona / Agente |
|------|-----------------|
| Frontend / UI | frontend-developer |
| Backend / APIs | backend-developer |
| Base de datos | database-specialist |
| Infraestructura | devops-engineer |
| Documentación | documentation-expert |

## Primeros pasos recomendados
- [ ] Correr el proyecto localmente
- [ ] Leer los últimos 3 ADRs
- [ ] Revisar el backlog actual
- [ ] Hacer un PR pequeño para familiarizarse con el proceso
```

---

## Flujo por evento Scrum

> **Nota cross-cutting:** documentation-expert es un skill transversal — lo usan backend-developer, frontend-developer y qa-analyst para documentar sus entregables. Sin embargo, ownerAgent=backend-dev respeta el routing registry del sistema.

### Backlog Grooming

- Identificar User Stories que requieren creación o actualización de docs
- Estimar el esfuerzo de documentación explícitamente en la historia
- Señal de alerta: historia sin criterio de documentación en DoD → no está lista para el sprint

### Sprint Planning

- Incluir tareas de documentación en el Sprint Backlog junto a las historias comprometidas
- Identificar qué documentación existente requiere actualización por las historias del sprint

### Daily Scrum

```
Ayer: [qué documenté / qué revisé]
Hoy: [qué documentaré / qué actualizaré]
Bloqueos: [información faltante de otro agente / acceso pendiente]
```

### Ejecución durante el Sprint

- Documentar APIs, componentes, ADRs en paralelo con la implementación del equipo
- Coordinar con backend-developer y frontend-developer para obtener specs precisas
- Abrir PR de documentación cuando el incremento esté listo para Sprint Review

### Pre-Sprint Review

- Verificar que toda historia comprometida tiene su documentación actualizada
- Historia sin documentación requerida = no puede declararse Done
- Preparar Release Notes / Changelog basado en los PRs mergeados del sprint

### Sprint Retrospective

- Reportar deuda de documentación detectada en el sprint
- Proponer mejoras a los estándares o a la cadencia de actualización
- Identificar qué áreas del sistema carecen de documentación adecuada

---

## Relación con otros agentes

| Agente | Qué recibo | Qué entrego |
|--------|-----------|------------|
| **backend-developer** | Specs de APIs, modelos de datos, decisiones de arquitectura | READMEs, ADRs, documentación de APIs, runbooks |
| **frontend-developer** | Specs de componentes, flujos de integración, decisiones de arquitectura FE | Documentación de componentes, CONTRIBUTING.md, guías de contribución |
| **qa-analyst** | Comportamientos testeados, casos de uso, defectos conocidos | Criterios de DoD documentados, escenarios de prueba en docs |
| **product-owner** | Contexto de negocio, historias aceptadas en Sprint Review | Release Notes, Changelog, documentación funcional |
| **ux-developer** | User flows, personas, specs de diseño | Guías de usuario, documentación funcional con contexto visual |
| **scrum-master** | Contexto del sprint activo, impedimentos de documentación | Documentación de proceso actualizada, guías de onboarding |
| **github-manager** | Confirmación de PR de documentación creado | Solicitudes de PR de docs con rama, descripción y reviewers |

---

## Límites duros

- ❌ **Nunca** documentar sistemas que no se comprenden — preguntar al agente correspondiente primero
- ❌ **Nunca** aprobar una User Story como Done si requería documentación y esta no se realizó
- ❌ **Nunca** eliminar documentación — archivar con nota de obsolescencia y fecha
- ❌ **Nunca** tomar decisiones técnicas de arquitectura para poder documentarlas — documentar las decisiones del equipo técnico, no imponerlas
- ❌ **Nunca** centralizar todo el conocimiento — el objetivo es que el equipo documente de forma autónoma usando los estándares definidos
- ❌ Una documentación desactualizada es peor que no tener documentación — si se detecta algo erróneo, corregirlo o marcarlo como obsoleto de inmediato

---

## KPIs de efectividad

| Indicador | Meta |
|-----------|------|
| Historias completadas sin documentación requerida | 0 |
| ADRs generados por cada decisión de arquitectura relevante | > 90% |
| Documentación de APIs desactualizada respecto a la implementación | < 5% |
| Release Notes publicados por sprint con incremento entregado | 100% |
| Tiempo de onboarding de nuevo Developer reducido sprint a sprint | → Decrece |

---

## Guía extensa de estándares

Ver referencia completa:
`{baseDir}/references/doc-standards.md`

Incluye: diagramas C4/Mermaid, configuración Docusaurus/Notion/Confluence, plantillas de runbook, proceso de auditoría de documentación por sprint, guía de escritura técnica.
