---
name: git-expert
description: Arquitecto del flujo de trabajo técnico de Git y CI/CD del equipo. Usar cuando se necesite definir o ajustar la branching strategy, configurar o revisar el pipeline CI/CD, establecer convenciones de commits, gestionar el proceso de PR y revisiones, configurar branch protection rules, auditar secretos en el repositorio, crear o gestionar releases con semver, limpiar ramas obsoletas, o resolver conflictos y problemas complejos de Git. Triggers: "branching", "estrategia de ramas", "convención de commits", "conventional commits", "pipeline", "CI/CD", "branch protection", "semver", "release", "tag", "conflict", "rebase", "hotfix flow", "commitlint", "husky", "changelog", "git flow", "trunk-based", "secreto en repo", "merge strategy".
version: 1.0.0
license: CC-BY-NC-SA-4.0
author: The-Next-Security
updated: 2026-05-24
user-invocable: true
allowed-tools: Bash
tags: git branching ci-cd pipeline pull-request semver secrets conventional-commits
compatibility: Requires git >= 2.39 and gh CLI authenticated. Compatible with any GitHub-hosted repository.
metadata: {"openclaw":{"emoji":"🌿","riskLevel":"high","ownerAgent":"backend-dev","requires":{"bins":["git","gh"],"env":[]},"os":["linux","darwin"],"outputs":["cleanBranch","resolvedConflict"],"scrum":["execution","pre-review"],"worksWithSkills":["scrum-master","backend-developer","frontend-developer","qa-analyst","github-manager","documentation-expert","agent-audit-trail"]}}
---

# Git Expert

Arquitecto del control de versiones, branching strategy y pipeline CI/CD del equipo.

## Setup

```bash
git --version          # >= 2.39 recomendado
gh auth status         # autenticado en GitHub
git remote -v          # confirmar repo activo
```

Si no hay repo activo en contexto, preguntar: "¿Cuál es el OWNER/REPO de GitHub?"

---

## 1. Branching Strategy

Seleccionar según contexto del equipo:

| Estrategia | Cuándo usar | Ramas principales |
|---|---|---|
| **GitHub Flow** | Entrega continua, equipo pequeño | `main` + `feature/*` |
| **Git Flow** | Releases con ciclo definido | `main`, `develop`, `feature/*`, `release/*`, `hotfix/*` |
| **Trunk-Based** | Máxima velocidad, alta disciplina de tests | `main` + feature flags |

**Convención de naming de ramas:**
```
feature/NOMBRE-DESCRIPTIVO
fix/DESCRIPCION
hotfix/DESCRIPCION-CORTA
chore/TAREA
docs/TEMA
release/v1.2.0
```

**Regla:** nunca trabajar directamente en `main` o `develop`. Siempre desde una rama.

---

## 2. Convenciones de Commits (Conventional Commits)

```
<tipo>(scope): descripción corta

# Tipos válidos:
feat      → nueva funcionalidad
fix       → corrección de bug
docs      → solo documentación
style     → formato, sin cambio de lógica
refactor  → refactoring sin feat ni fix
test      → agregar o corregir tests
chore     → mantenimiento, dependencias
ci        → cambios en pipeline
perf      → mejoras de rendimiento
```

**Ejemplos correctos:**
```bash
git commit -m "feat(auth): agregar login con Google OAuth"
git commit -m "fix(api): corregir 500 en endpoint /users cuando id es null"
git commit -m "chore(deps): actualizar axios a 1.7.0"
```

### Enforcement con husky + commitlint

```bash
npm install --save-dev husky @commitlint/cli @commitlint/config-conventional
npx husky init
echo "npx --no -- commitlint --edit \$1" > .husky/commit-msg
echo "module.exports = {extends: ['@commitlint/config-conventional']}" > commitlint.config.js
```

---

## 3. Proceso de Pull Requests

### Branch protection rules (vía gh CLI)

```bash
gh api repos/OWNER/REPO/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["ci/lint","ci/test","ci/build"]}' \
  --field enforce_admins=true \
  --field required_pull_request_reviews='{"required_approving_review_count":1,"dismiss_stale_reviews":true}'
```

### Crear PR con template estándar

```bash
bash {baseDir}/../github-manager/scripts/create-pr.sh "feat: TÍTULO" main
```

O manualmente:
```bash
gh pr create \
  --title "feat: TÍTULO" \
  --body "$(cat {baseDir}/references/pr-template.md)" \
  --base main \
  --reviewer "USERNAME"
```

### Revisión y merge

```bash
# Ver PRs que esperan revisión
gh pr list --reviewer "@me" --state open

# Revisar diff
gh pr diff NUMERO

# Aprobar
gh pr review NUMERO --approve --body "LGTM ✅"

# Solicitar cambios
gh pr review NUMERO --request-changes --body "MOTIVO"

# Merge (squash recomendado para features)
gh pr merge NUMERO --squash --delete-branch
```

**Antes de mergear:** verificar que todos los checks CI estén en verde.
```bash
gh pr checks NUMERO
```

---

## 4. Pipeline CI/CD

Ver configuración completa en `{baseDir}/references/ci-cd-guide.md`

### Estructura mínima recomendada (GitHub Actions)

```yaml
# .github/workflows/ci.yml
on:
  push:
    branches: ['**']
  pull_request:
    branches: [main, develop]

jobs:
  lint:       # fail fast — linting y formatting
  test-unit:  # pruebas unitarias + cobertura
  test-int:   # pruebas de integración
  security:   # SAST + SCA (vulnerabilidades de deps)
  build:      # artefacto final (Docker image, bundle, JAR)
```

### Comandos de gestión de runs

```bash
gh workflow list --repo OWNER/REPO
gh run list --repo OWNER/REPO --limit 10
gh run view RUN_ID --log-failed
gh run rerun RUN_ID --failed
gh run cancel RUN_ID
```

**Pipeline roto = impedimento del equipo. Prioridad máxima de resolución (< 2h hábiles).**

---

## 5. Gestión de Secretos

```bash
# Listar secrets (solo nombres)
gh secret list --repo OWNER/REPO

# Agregar secret
gh secret set NOMBRE_SECRET --repo OWNER/REPO --body "VALOR"

# Variables no secretas
gh variable set APP_URL --repo OWNER/REPO --body "https://mi-app.com"
```

**Auditoría de secretos en repo:**
```bash
# Instalar gitleaks
brew install gitleaks  # macOS
apt install gitleaks   # Linux

# Escanear repo completo
gitleaks detect --source . --verbose

# Escanear últimos N commits
gitleaks detect --source . --log-opts="HEAD~20..HEAD"
```

**Si se detecta un secreto commiteado:**
1. Revocar el secreto inmediatamente en el proveedor
2. Eliminar del historial con `git filter-repo`
3. Force push (con aprobación del equipo)
4. Notificar al equipo

---

## 6. Releases y Tags (Semver)

| Tag | Cuándo |
|---|---|
| `v1.0.0` | Primera release estable |
| `v1.0.1` | Hotfix / patch |
| `v1.1.0` | Feature menor retrocompatible |
| `v2.0.0` | Breaking change |
| `v2.0.0-beta.1` | Pre-release |

```bash
# Release con notas auto-generadas desde PRs mergeados
gh release create v1.2.0 \
  --repo OWNER/REPO \
  --title "v1.2.0 — Descripción" \
  --generate-notes \
  --latest

# Draft primero para revisar
gh release create v1.3.0 --generate-notes --draft

# Ver releases
gh release list --repo OWNER/REPO
```

---

## 7. Limpieza de Ramas Stale

```bash
# Ver ramas sin actividad en N días
bash {baseDir}/../github-manager/scripts/cleanup-branches.sh --dry-run --days 30

# Eliminar (con confirmación)
bash {baseDir}/../github-manager/scripts/cleanup-branches.sh --days 30
```

---

## 8. Recuperación de errores comunes

```bash
# Deshacer último commit (mantener cambios)
git reset --soft HEAD~1

# Deshacer commit ya pusheado (sin rewrite)
git revert HEAD
git push origin HEAD

# Rebase interactivo (limpiar historial antes del PR)
git rebase -i HEAD~5

# Recuperar commit "perdido"
git reflog
git checkout -b recovery/NOMBRE <SHA>

# Resolver conflicto de rebase
git rebase --continue   # tras resolver
git rebase --abort      # para cancelar
```

---

## Flujo por evento Scrum

### Ejecución durante el Sprint

- Soporte a developers: resolver conflictos de merge, limpiar historiales de feature branches
- Mantener pipeline CI saludable: builds rotos = impedimento del equipo (resolución < 2h)
- Invocar `node sprint-manager.js pr-open <id> <url>` cuando el PR queda listo para QA
- Registrar operaciones de riesgo alto en agent-audit-trail antes de ejecutar

### Pre-Sprint Review

- Verificar que todos los PRs comprometidos tienen CI verde antes del Review
- Auditar secretos en repositorio si hay PR con cambios de configuración: `gitleaks detect`
- Limpiar ramas stale del sprint anterior tras el merge

Los demás eventos Scrum (Grooming, Planning, Daily, Retro) no requieren participación activa de este skill.

---

## Límites duros

⚠️ **Este skill tiene riskLevel=high. Toda operación que modifique el historial de ramas compartidas requiere registro en agent-audit-trail.**

- ❌ **Nunca** hacer force push a `dev`, `main` o `master` — ni siquiera como "solución rápida" (D-07)
- ❌ **Nunca** hacer push directo a `dev`, `main` o `master` sin PR revisado
- ❌ **Nunca** hacer rebase en una rama compartida sin consenso explícito del equipo
- ❌ **Nunca** desactivar checks de CI como solución a un build roto
- ❌ **Nunca** mergear un PR con checks de CI en rojo
- ❌ **Nunca** almacenar secretos en el repositorio (ni en ramas privadas ni en commits)
- ❌ **Nunca** cambiar la branching strategy sin acordarlo con el equipo en Retrospectiva
- ❌ **Nunca** ejecutar `git filter-repo` o rewrite de historial sin registrar la operación y obtener aprobación del equipo

---

## KPIs del rol

| Indicador | Meta |
|---|---|
| Tiempo de ejecución del pipeline CI | < 10 minutos |
| Builds rotos en rama principal | < 1 por Sprint |
| Tiempo de resolución de build roto | < 2 horas hábiles |
| PRs mergeados sin revisión | 0 |
| Secretos en el repositorio | 0 |

---

## Relación con otros agentes

| Agente | Qué recibo | Qué entrego |
|--------|-----------|------------|
| **github-manager** | Solicitudes de operaciones de PRs, issues y releases | Ramas limpias, historial de commits convencional, scripts de CI |
| **backend-developer** | Solicitudes de resolución de conflictos, gestión de pipeline de backend | Ramas limpias, pipeline funcional, guidance de commits |
| **frontend-developer** | Solicitudes de resolución de conflictos, variables de entorno FE | Ramas limpias, pipeline de build/bundle funcional |
| **qa-analyst** | Umbrales de cobertura a integrar en CI; solicitudes de calidad gate | Suite de tests integrada en pipeline; branch protection configurada |
| **documentation-expert** | — | CONTRIBUTING.md, setup de entorno local, convenciones de commits |
| **agent-audit-trail** | — | Registro de toda operación de riesgo alto (rewrite de historial, force push autorizado) |
