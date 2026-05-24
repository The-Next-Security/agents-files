---
name: tns-debugger-triage
description: 'TNS-specific bug triage. Given a GitHub issue labeled ''bug'' in one of the system repos (or any repo the system is working on), produces a deterministic root cause analysis (RCA) and publishes it as a comment in the corresponding GitHub issue. The RCA includes symptom, deterministic reproduction steps, root cause, culprit commit when applicable (via git bisect), proposed fix, regression risk assessment, and a suggested assignee role. If no issue exists, one is created first. This skill DIAGNOSES only; it does not implement fixes. Triggers: ''triage bug'', ''rca issue'', ''debug issue #'', ''reproduce bug'', ''diagnose'', ''investiga bug''.'
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-24
user-invocable: true
allowed-tools: Bash
tags: debug triage rca bug diagnosis root-cause github-issues reproduction
compatibility: Requires git, gh, jq. Requires GitHub CLI authenticated with access to the target repository.
metadata: {"openclaw":{"emoji":"🔬","riskLevel":"medium","ownerAgent":"roy","requires":{"bins":["git","gh","jq"],"env":[]},"os":["linux","darwin"],"outputs":["rcaReport","githubComment"],"scrum":["execution"],"worksWithSkills":["scrum-master","backend-developer","frontend-developer","node-specialist","agent-audit-trail"]}}
---

# tns-debugger-triage

## Rol Scrum

Esta skill la invoca el **Debugger Agent** cuando Roy le asigna un
triage de bug. Alternativamente, Roy puede invocarla directamente si
el Debugger no está disponible.

No implementa fixes. Su propósito es entregar un **RCA verificable y
accionable** al Dev correspondiente (Backend, Frontend, Node
Specialist, según aplique).

## Cuándo usar

- Cuando hay un issue con label `bug` que debe ser investigado.
- Cuando hay un reporte de falla en producción o staging y se
  necesita diagnóstico antes de decidir fix.
- Cuando se sospecha una regresión y se necesita identificar el
  commit culpable.

## Cuándo NO usar

- Si el bug ya tiene RCA hecho: aplicar directamente el fix con el
  Dev correspondiente.
- Si la tarea es un feature nuevo (no un bug).
- Si es un incidente activo de producción (primero estabilizar, el
  triage viene después).

## Entradas requeridas

1. Número del issue GitHub.
2. Repositorio (`owner/repo`).
3. (Opcional) logs o stack traces adicionales no presentes en el
   issue.

Sin el issue no hay triage; el skill pide el dato antes de arrancar.

## Salida producida

Un comentario RCA publicado en el issue GitHub correspondiente con
estructura fija. Si no existe issue → crear uno primero con el
contexto del bug antes de publicar el RCA.

```markdown
# RCA — <owner>/<repo> — Issue #<n>

## Metadata
- Fecha RCA: <ISO8601>
- Autor: Debugger Agent
- Link al issue: <URL>
- Severidad estimada: low | medium | high | critical
- Estado del RCA: completo | no reproducible | bloqueado

## Síntoma observado
<qué reportó el humano, literal o resumido>

## Reproducción determinística
<pasos exactos, comandos, input, entorno>
Si no es reproducible: "No reproducible tras 2 intentos documentados."

## Root cause identificado
<explicación técnica del por qué ocurre>

## Commit culpable
<SHA + mensaje del commit, vía git bisect si aplica>
Si no aplica o no se encontró: "No identificado — bug anterior al
histórico relevante o no-regresional."

## Propuesta de fix
<cambio concreto recomendado, con archivos y líneas>

## Riesgo de regresión del fix
<qué otras áreas podrían afectarse>

## Asignación sugerida
<rol: backend-dev | frontend-dev | node-specialist | ...>

## Evidencia adjunta
- Logs: <fragmentos relevantes del output de reproducción>
- Comandos de repro: <secuencia exacta ejecutada>
```

El RCA se publica como comentario en el issue GitHub. Roy y el
Debugger Agent reciben la URL del issue con el RCA. El próximo paso
es spawnear al Dev correspondiente con el issue como input.

## Flujo de ejecución

1. Leer el issue vía `gh issue view <n> --repo <owner>/<repo> --json
   title,body,labels,author,createdAt,comments`.
2. Clonar el repo en un worktree scratch si no está ya presente
   localmente.
3. Intentar reproducir el bug siguiendo los pasos del issue. Si hay
   ambigüedad, documentar los supuestos usados.
4. Si es reproducible:
   a. Probar `git bisect` entre la rama `main` y un commit
      anterior conocido como bueno (si lo hay).
   b. Identificar root cause leyendo el código alrededor del
      commit culpable.
5. Si no es reproducible tras 2 intentos, marcar en el RCA y
   proponer pedir más contexto al reporter.
6. Redactar el RCA completo con la estructura fija.
7. Publicar el RCA como comentario en el issue GitHub correspondiente
   vía `gh issue comment <n> --repo <owner>/<repo> --body "..."`.
   Si no existe issue → crear primero con `gh issue create`.
8. Para repos de cliente (no TNS): no comentar en el issue externo;
   reportar el RCA completo a Roy directamente.
9. Reportar a Roy la URL del issue donde quedó el RCA.

## Guardrails

- NO aplica fixes. Solo diagnostica.
- NO ejecuta código del repo objetivo en el corredor del sistema;
  usa worktree scratch aislada.
- NO comenta en issues de repos fuera del alcance autorizado.
- NO expone credenciales en logs, archivos RCA, o comentarios.
- Si la reproducción requiere credenciales o recursos externos que
  no están disponibles, escalar a Roy antes de abortar.
- Timeout duro: 30 minutos por triage. Si se excede, marcar RCA
  como "bloqueado" y escalar.

## Tests

La skill incluye tests en `tests/` que validan la estructura del
RCA generado y el comportamiento sobre un issue sintético.

---

## Flujo por evento Scrum

### Ejecución durante el Sprint

Este skill se activa cuando Roy o el Debugger Agent reporta un bug que requiere diagnóstico antes del fix.

**Flujo dentro del sprint:**
1. QA Analyst abre issue con label `bug` tras detectar falla en Sprint Review o ejecución
2. Roy asigna el triage al Debugger Agent (o invoca el skill directamente)
3. tns-debugger-triage ejecuta el análisis y publica el RCA en el issue
4. Roy asigna el issue con el RCA al Dev correspondiente (backend / frontend / node-specialist)
5. Si el bug es bloqueante para el Sprint Goal → `node sprint-manager.js block <id> "razón"`

No participa en Grooming, Planning, Daily, Review ni Retrospective directamente.
En Retrospective: el historial de RCAs puede consultarse para identificar patrones de bugs recurrentes.

---

## Límites duros

- ❌ **Nunca** implementar el fix — solo diagnosticar y publicar RCA
- ❌ **Nunca** comentar en issues de repos externos sin autorización explícita de Roy
- ❌ **Nunca** exponer credenciales, tokens o secrets en el RCA o en comentarios del issue
- ❌ **Nunca** superar 30 minutos por triage — si se excede, marcar RCA como "bloqueado" y escalar
- ❌ **Nunca** publicar RCA sin verificar que el issue existe (si no existe → crear primero)
- ❌ **Nunca** usar `~/tns-debug/` como destino primario del RCA — el issue GitHub es la fuente de verdad

---

## KPIs de efectividad

| Indicador | Meta |
|-----------|------|
| RCAs publicados en issue GitHub (no en archivos locales) | 100% |
| Bugs con root cause identificado (vs "no reproducible") | > 80% |
| Tiempo de triage por bug | < 30 minutos |
| RCAs con commit culpable identificado (cuando aplica git bisect) | > 60% |
| Bugs recurrentes detectados en Retrospectiva | → 0 (resueltos en origen) |
