---
name: tns-debugger-triage
description: 'TNS-specific bug triage. Given a GitHub issue labeled ''bug'' in one of the system repos (or any repo the system is working on), produces a deterministic root cause analysis (RCA) document at ~/tns-debug/rca-<issue-id>.md. The RCA includes symptom, deterministic reproduction steps, root cause, culprit commit when applicable (via git bisect), proposed fix, regression risk assessment, and a suggested assignee role. This skill DIAGNOSES only; it does not implement fixes. Triggers: ''triage bug'', ''rca issue'', ''debug issue #'', ''reproduce bug'', ''diagnose'', ''investiga bug''.'
version: 1.0.0
user-invocable: true
metadata: {"openclaw":{"requires":{"bins":["git","gh","jq"]},"os":["linux","darwin"]}}
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

Un archivo RCA en `~/tns-debug/rca-<owner>-<repo>-<issue-id>.md` con
estructura fija:

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
- Scripts de repro: <ruta en ~/tns-debug/>
- Logs: <fragmentos relevantes>
```

El archivo RCA queda en `~/tns-debug/`. La ruta exacta se reporta al
Debugger Agent (o a Roy) para que el próximo paso sea spawnear al
Dev correspondiente con el RCA como input.

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
6. Redactar el RCA con la estructura fija.
7. Guardar en `~/tns-debug/rca-<owner>-<repo>-<issue-id>.md`.
8. Comentar en el issue GitHub con un resumen compacto del RCA y
   link al archivo (solo si el repo es de TNS; para repos de
   cliente, solo reportar a Roy).
9. Reportar la ruta del RCA al caller.

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
