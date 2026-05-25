# GitHub Procedures — github-manager

> Referencia operativa para el skill `github-manager`.
> Todos los procedimientos siguen los principios: historial git sagrado,
> un commit por archivo, ramas protegidas por principio, ninguna rama se elimina.

---

## Convenciones

### Naming de ramas

```
feature/<descripcion-corta>     → nueva funcionalidad
fix/<descripcion-corta>         → corrección de bug
chore/<descripcion-corta>       → mantenimiento, dependencias, config
docs/<descripcion-corta>        → solo documentación
release/vX.Y.Z                  → rama de release (creada por usuario real)
```

Reglas:
- Usar kebab-case, sin mayúsculas, sin espacios
- Máximo 5 palabras en la descripción
- Siempre crear desde `dev`, nunca desde `main/master`

### Conventional Commits

```
feat(módulo): descripción concisa del cambio
fix(módulo): descripción concisa de la corrección
docs(módulo): descripción concisa de la documentación
chore(módulo): descripción concisa de la tarea de mantenimiento
refactor(módulo): descripción concisa del refactor
test(módulo): descripción concisa del test
```

Reglas:
- Mensaje en español, salvo términos técnicos irremplazables
- Un commit = exactamente un archivo modificado o creado
- Nunca commits bulk ("varios cambios", "fix multiple things")

---

## Ramas

### Crear rama de trabajo

```bash
# Actualizar dev antes de crear la rama
git fetch origin
git checkout dev
git pull origin dev

# Crear rama de feature
git checkout -b feature/<nombre>

# Confirmar
git branch --show-current
```

### Verificar estado de ramas remotas

```bash
git branch -r
gh api repos/{owner}/{repo}/branches --jq '.[].name'
```

> **Recordar:** ninguna rama se elimina. Las ramas son registro permanente del trabajo.

---

## Commits

### Flujo de commit atómico (un archivo)

```bash
# 1. Escanear el archivo antes de agregarlo (ver sección Seguridad)
# 2. Agregar exactamente un archivo
git add <ruta/del/archivo>

# 3. Verificar que solo ese archivo está en staging
git diff --cached --name-only

# 4. Hacer commit con mensaje descriptivo
git commit -m "feat(módulo): descripción concisa del cambio"

# 5. Verificar el commit
git log --oneline -1
```

### Lo que nunca se hace en un commit

```bash
# ❌ Prohibido — commit de múltiples archivos
git add .
git commit -m "varios cambios"

# ❌ Prohibido — modificar historial
git commit --amend
git reset HEAD~1
git rebase -i
```

---

## Push

### Push de avance en rama de trabajo

```bash
# Primera vez (establece upstream)
git push -u origin feature/<nombre>

# Siguientes veces
git push

# Verificar que se subió
git log origin/feature/<nombre> --oneline -3
```

**Frecuencia recomendada:** mínimo 1 push por sesión de trabajo activa.
Esto permite a Felipe ver el progreso en GitHub en tiempo real.

---

## Pull Requests

### Abrir PR hacia dev

```bash
gh pr create \
  --base dev \
  --title "feat(módulo): descripción concisa" \
  --body "## Descripción

Qué hace este PR y por qué.

## Cambios realizados

- archivo1: descripción del cambio
- archivo2: descripción del cambio

## Cómo verificar

Pasos para que el reviewer valide los cambios.

## Checklist
- [ ] CI en verde
- [ ] Sin secretos en los commits
- [ ] Un commit por archivo
- [ ] Descripción completa" \
  --reviewer andresTNS \
  --reviewer Bufigol
```

Reglas:
- Siempre `--base dev`, nunca `--base main` salvo en PRs de release
- Siempre incluir a `andresTNS` como reviewer
- Mínimo 2 reviewers de: `Bufigol`, `andresTNS`, `felipecleverox`, `TNSTRACK`

### Verificar estado del PR

```bash
# Estado general
gh pr view <número>

# Checks de CI
gh pr checks <número>

# Diff completo
gh pr diff <número>

# Lista de PRs abiertos en el repo
gh pr list --state open
```

### Criterio de merge

Un PR puede mergearse cuando:
1. ✅ CI en verde (todos los checks pasan)
2. ✅ Mínimo 2 approvals, incluyendo `andresTNS`
3. ✅ Sin conflictos con `dev`
4. ✅ Ningún reviewer ha pedido cambios pendientes

El merge lo ejecuta el reviewer o el usuario real — no el agente que abrió el PR.

---

## Comentarios

### Comentar en un PR

```bash
# Comentario de progreso
gh pr comment <número> \
  --body "**Avance:** <descripción de lo que se completó>

**Próximo paso:** <qué sigue>
**Bloqueos:** <ninguno / descripción si hay>"

# Pedir aclaración
gh pr comment <número> \
  --body "**Consulta:** <pregunta específica al reviewer o al equipo>"
```

### Comentar en un issue

```bash
# Inicio de trabajo
gh issue comment <número> \
  --body "**Iniciando trabajo en este issue.**

Branch de trabajo: \`feature/<nombre>\`
PR se abrirá contra \`dev\` cuando esté listo."

# Avance de trabajo
gh issue comment <número> \
  --body "**Avance:** <descripción del progreso>

Commits realizados: <lista o referencia al PR>"
```

### Comentarios automáticos de CI

Al detectar CI verde en un PR:
```bash
gh pr comment <número> \
  --body "✅ **CI en verde.** Todos los checks pasaron. Listo para review."
```

Al detectar CI rojo:
```bash
gh pr comment <número> \
  --body "❌ **CI falló.** Detalle del error:

\`\`\`
<output del error>
\`\`\`

**Pasos propuestos para resolución:** <análisis>"
```

---

## Review y aprobación

### Ver reviews pendientes

```bash
gh pr list --review-requested @me
gh pr view <número> --json reviews
```

### Responder a request-changes

```bash
# Ver los cambios pedidos
gh pr view <número> --json reviewRequests,reviews

# Después de corregir, notificar
gh pr comment <número> \
  --body "**Cambios aplicados.** Se corrigió: <descripción>.
Listo para re-review."
```

---

## Seguridad

### Escaneo pre-commit de secretos

Antes de `git add` sobre cualquier archivo, verificar que no contiene:

```
Patrones a detectar:
- API keys: sk-..., pk-..., AKIA..., AIza...
- Tokens: ghp_..., gho_..., github_pat_...
- Passwords hardcodeados: password=, passwd=, secret=
- Archivos .env con valores reales (no placeholders)
- Private keys: -----BEGIN ... PRIVATE KEY-----
- Connection strings con credenciales: mysql://user:pass@...
```

Si se detecta alguno de estos patrones:

1. **No agregar el archivo** (`git add` no se ejecuta)
2. Notificar al agente solicitante con el detalle del secreto detectado
3. Notificar a `skill-threat-scanner` con el contexto:
   - Repo afectado
   - Nombre del archivo
   - Tipo de secreto detectado
   - Agente que intentó el commit
4. Proponer al agente la corrección: usar variables de entorno o placeholders

### Archivos que nunca se commitean

```gitignore
.env
.env.local
.env.*.local
*.pem
*.key
*_rsa
*_dsa
secrets.*
credentials.*
```

---

## Release

### Señal de activación

El usuario real activa el workflow con un mensaje del tipo:
"vamos a hacer release de X repo" o "preparemos el release vX.Y.Z"

### Flujo completo de Release

```bash
# Paso 1: Verificar que dev está integrado y CI en verde
git fetch origin
git checkout dev
git pull origin dev
gh run list --branch dev --limit 5

# Paso 2: Crear PR dev → main/master
gh pr create \
  --base main \
  --head dev \
  --title "release: vX.Y.Z — <descripción del release>" \
  --body "## Release vX.Y.Z

### Cambios incluidos
<resumen de los PRs mergeados en este ciclo>

### CHANGELOG
<contenido del CHANGELOG.md>

### Verificación
- [ ] CI en verde en dev
- [ ] CHANGELOG actualizado
- [ ] Versión confirmada por usuario real" \
  --reviewer andresTNS \
  --reviewer Bufigol

# Paso 3: Esperar aprobación (CI verde + 2 approvals + sin conflictos)
# El merge lo hace el usuario real o el reviewer

# Paso 4: Una vez mergeado, crear tag y release
git fetch origin
git checkout main
git pull origin main

git tag -a vX.Y.Z -m "Release vX.Y.Z — <descripción>"
git push origin vX.Y.Z

gh release create vX.Y.Z \
  --title "vX.Y.Z — <título descriptivo>" \
  --notes-file CHANGELOG.md \
  --target main

# Paso 5: Confirmar publicación
gh release view vX.Y.Z
```

### Versionado SemVer

El número de versión lo decide el usuario real en pingpong con el equipo:

```
vX.Y.Z
  X → Major: cambios incompatibles con versiones anteriores (BREAKING CHANGE)
  Y → Minor: nueva funcionalidad compatible hacia atrás (feat)
  Z → Patch: correcciones de bugs compatibles hacia atrás (fix)
```

El agente puede proponer el número basándose en los tipos de commit del ciclo,
pero la decisión final la toma el usuario real.

---

## Checklist de operación diaria

```
[ ] gh auth status → autenticado
[ ] git fetch origin → repos actualizados
[ ] gh pr list → PRs abiertos revisados
[ ] CI status en PRs activos verificado
[ ] Push de avance realizado en ramas activas
[ ] Comentarios de progreso agregados en PRs e issues asignados
```
