# CI/CD Guide — Git Expert

## GitHub Actions: Configuración completa

### Workflow de CI (integración continua)

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: ['**']
  pull_request:
    branches: [main, develop]

jobs:
  lint:
    name: Lint & Format
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run lint
      - run: npm run format:check

  test-unit:
    name: Unit Tests
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run test:unit -- --coverage
      - uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/

  test-integration:
    name: Integration Tests
    runs-on: ubuntu-latest
    needs: test-unit
    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: testpass
          POSTGRES_DB: testdb
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run test:integration
        env:
          DATABASE_URL: postgresql://postgres:testpass@localhost:5432/testdb

  security:
    name: Security Scan
    runs-on: ubuntu-latest
    needs: lint
    steps:
      - uses: actions/checkout@v4
      # SAST con CodeQL
      - uses: github/codeql-action/init@v3
        with:
          languages: javascript, typescript
      - uses: github/codeql-action/analyze@v3
      # SCA — vulnerabilidades en dependencias
      - run: npm audit --audit-level=high

  build:
    name: Build
    runs-on: ubuntu-latest
    needs: [test-unit, test-integration, security]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'npm'
      - run: npm ci
      - run: npm run build
      - uses: actions/upload-artifact@v4
        with:
          name: dist
          path: dist/
```

### Workflow de CD — deploy a staging

```yaml
# .github/workflows/cd-staging.yml
name: Deploy to Staging

on:
  push:
    branches: [develop]

jobs:
  deploy:
    name: Deploy Staging
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .
      - name: Push to registry
        run: |
          echo ${{ secrets.REGISTRY_TOKEN }} | docker login -u ${{ secrets.REGISTRY_USER }} --password-stdin
          docker push myapp:${{ github.sha }}
      - name: Deploy to staging
        run: |
          ssh -o StrictHostKeyChecking=no ${{ secrets.STAGING_SSH_KEY }} root@staging-server \
            "docker pull myapp:${{ github.sha }} && docker-compose up -d"
      - name: Notify team
        uses: slackapi/slack-github-action@v1
        with:
          payload: '{"text": "✅ Deploy a staging completado: ${{ github.sha }}"}'
        env:
          SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

### Workflow de CD — deploy a producción (manual)

```yaml
# .github/workflows/cd-prod.yml
name: Deploy to Production

on:
  workflow_dispatch:
    inputs:
      version:
        description: 'Tag de release a deployar (ej: v1.2.0)'
        required: true

jobs:
  deploy:
    name: Deploy Production
    runs-on: ubuntu-latest
    environment: production   # requiere aprobación manual en GitHub
    steps:
      - uses: actions/checkout@v4
        with:
          ref: ${{ inputs.version }}
      - name: Deploy
        run: echo "Deployando ${{ inputs.version }} a producción..."
      # ... pasos de deploy reales
```

---

## Estrategias de branching — detalle

### GitHub Flow (recomendado para este proyecto)

```
main ──────────────────────────────────────────────► producción
       │              │                │
       ▼              ▼                ▼
  feature/A      feature/B         hotfix/C
       │              │                │
       └──── PR ───► main ◄─── PR ────┘
```

**Flujo completo:**
```bash
# 1. Partir de main actualizado
git checkout main && git pull --rebase origin main

# 2. Crear rama
git checkout -b feature/NOMBRE-DESCRIPTIVO

# 3. Trabajo + commits semánticos
git add -p
git commit -m "feat(scope): descripción"

# 4. Push + PR
git push -u origin HEAD
gh pr create --title "feat: TÍTULO" --reviewer "REVIEWER"

# 5. Iterar sobre feedback (sin rewrite del historial si ya hay revisores)
git commit -m "fix: ajuste por feedback de code review"
git push origin HEAD

# 6. Merge tras CI verde + aprobación
gh pr merge NUMERO --squash --delete-branch
```

### Git Flow (para productos con releases definidas)

```
main      ──────────────────────────► tags: v1.0, v1.1, v2.0
develop   ────────────────────────►
feature/* ──► develop
release/* ──► main + develop
hotfix/*  ──► main + develop
```

```bash
# Inicializar Git Flow
git flow init

# Feature
git flow feature start NOMBRE
git flow feature finish NOMBRE  # merge a develop

# Release
git flow release start v1.2.0
git flow release finish v1.2.0  # merge a main + develop + tag

# Hotfix
git flow hotfix start DESCRIPCION
git flow hotfix finish DESCRIPCION  # merge a main + develop
```

---

## Métricas del pipeline

| Métrica | Target | Señal de alerta |
|---|---|---|
| Tiempo total de CI | < 10 min | > 15 min → optimizar |
| Frecuencia de CI rojo en `main` | < 1/sprint | > 2/sprint → revisar proceso |
| Cobertura de tests en CI | 100% suite | < 80% → agregar tests |
| Tiempo de deploy a staging | < 15 min post-merge | > 30 min → optimizar CD |
| PRs mergeados sin CI verde | 0 | Cualquiera → revisar branch protection |

---

## Resolución de problemas frecuentes

### CI lento (> 10 minutos)

```yaml
# Cache de dependencias
- uses: actions/cache@v4
  with:
    path: ~/.npm
    key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}

# Paralelizar jobs (usar needs: solo donde hay dependencia real)
# Ejecutar test shards en paralelo
- run: npm run test -- --shard=1/3
- run: npm run test -- --shard=2/3
- run: npm run test -- --shard=3/3
```

### Build roto en `main`

```bash
# 1. Identificar el commit que rompió
git bisect start
git bisect bad HEAD
git bisect good <ULTIMO_SHA_VERDE>

# 2. Ver logs del run fallido
gh run view RUN_ID --log-failed

# 3. Revertir si es urgente
git revert HEAD
git push origin main
# (requiere desactivar branch protection temporalmente o via Admin)

# 4. Notificar al equipo inmediatamente
# Pipeline roto = impedimento. Máxima prioridad.
```

### Conflicto de rebase complejo

```bash
# Ver todos los conflictos
git status

# Para cada archivo en conflicto:
# 1. Abrir y resolver manualmente (o con mergetool)
git mergetool

# 2. Marcar como resuelto
git add archivo-resuelto.js

# 3. Continuar
git rebase --continue

# Si se complica mucho: abortar y hacer merge tradicional
git rebase --abort
git merge origin/main  # alternativa más segura
```

---

## Template CONTRIBUTING.md

```markdown
# Cómo contribuir

## Setup del entorno local

1. Fork del repo y clone local
2. Instalar dependencias: `npm install`
3. Copiar variables de entorno: `cp .env.example .env.local`
4. Completar `.env.local` con valores de desarrollo (ver con el equipo)

## Flujo de trabajo

1. Crear rama desde `main`: `git checkout -b feature/NOMBRE`
2. Commitear con Conventional Commits: `feat:`, `fix:`, `docs:`...
3. Push y abrir PR hacia `main`
4. Esperar revisión de al menos 1 miembro del equipo
5. CI debe pasar antes del merge

## Convención de commits

Seguimos [Conventional Commits](https://conventionalcommits.org):
- `feat(scope): descripción` — nueva funcionalidad
- `fix(scope): descripción` — corrección de bug
- `docs: descripción` — solo documentación
- `chore: descripción` — mantenimiento

## Branch protection

- No se puede hacer merge directo a `main`
- Se requiere 1 aprobación de PR
- CI debe estar en verde (lint + tests + build)

## Secretos y variables de entorno

**Nunca** commitear `.env`, `.env.local`, ni ningún archivo con credenciales.
El `.gitignore` ya los excluye, pero verificar siempre antes de hacer `git add`.
```
