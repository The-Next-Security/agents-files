# Node Procedures — Node Specialist

Procedimientos técnicos de diagnóstico para el skill `node-specialist`.
Cada sección cubre una patología específica de Node.js/TypeScript con los
comandos exactos, señales de identificación y fixes más comunes.

> Última actualización: 2026-05-23
> Propietario: Roy (Scrum Master, Capa 1)

---

## Memory leak

### Señales de activación

- Heap creciente en el tiempo sin liberarse tras GC
- `FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed — JavaScript heap out of memory`
- RSS del proceso crece continuamente bajo carga sostenida
- EventEmitter con >10 listeners en el mismo evento (Node emite warning)

### Diagnóstico — heap snapshot

```bash
# Opción A: con acceso al proceso en ejecución (Node Inspector)
node --inspect <app.js>
# Conectar Chrome DevTools: chrome://inspect
# Memory → Take heap snapshot
# Reproducir la carga sospechosa
# Take second snapshot → Compare snapshots
# Buscar objetos con delta positivo en "# Delta" y "Size Delta"

# Opción B: snapshot programático (sin DevTools, para producción)
node -e "const v8 = require('v8'); const s = v8.writeHeapSnapshot(); console.log('Snapshot:', s);"
# Genera: Heap.20260523.123456.12345.0.001.heapsnapshot
# Abrir en Chrome DevTools → Memory → Load
```

### Señales de leak en el snapshot

- `Buffer` o `String` acumulándose en retained size
- Listeners no removidos: buscar `EventEmitter` con arrays de callbacks crecientes
- Closures reteniendo referencias a arrays u objetos grandes
- Objetos en `Detached DOM tree` (si hay JSDOM o puppeteer)

### Fixes más comunes en repos TNS

```javascript
// ❌ Listener que se agrega pero nunca se remueve
server.on('request', handler)

// ✅ Remover al cerrar
server.on('request', handler)
server.off('request', handler) // o server.removeListener

// ❌ Array global que acumula sin límite
const cache = []
cache.push(newItem) // nunca se vacía

// ✅ LRU cache con límite
const LRU = require('lru-cache')
const cache = new LRU({ max: 500 })
```

---

## CPU spike

### Señales de activación

- CPU sostenida >80% sin carga aparente
- Latencia de respuesta alta bajo carga moderada
- `process.cpuUsage()` mostrando user time desproporcionado

### Diagnóstico — perfil de CPU

```bash
# Perfil de 30 segundos durante la carga
node --cpu-prof --cpu-prof-interval=100 <app.js>
# Genera: CPU.20260523.123456.12345.0.001.cpuprofile
# Abrir en Chrome DevTools → Performance → Load profile

# En producción (sin reiniciar, si --inspect está activo):
kill -USR1 <pid>
# Genera perfil en el directorio actual
```

### Análisis del perfil

En Chrome DevTools → flamegraph o "Heavy (Bottom Up)":
- Buscar funciones en top 5 con >20% self time
- Identificar si es código propio o de dependencia
- Buscar llamadas síncronas en hot paths HTTP

### Causas comunes y fixes

```javascript
// ❌ JSON.parse/stringify en hot path con payloads >1MB
app.post('/data', (req, res) => {
  const data = JSON.parse(req.body) // bloqueante con payloads grandes
})

// ✅ Validar tamaño antes o usar stream
app.post('/data', express.json({ limit: '100kb' }), handler)

// ❌ crypto.pbkdf2Sync en handler HTTP (bloqueante)
app.post('/login', (req, res) => {
  const hash = crypto.pbkdf2Sync(password, salt, 100000, 64, 'sha512')
})

// ✅ Versión async
app.post('/login', async (req, res) => {
  const hash = await crypto.pbkdf2(password, salt, 100000, 64, 'sha512')
})
```

---

## Event loop

### Señales de activación

- Event loop lag >100ms medido en producción
- Requests HTTP lentos bajo carga moderada
- Timeouts en operaciones que deberían ser rápidas

### Diagnóstico — medición de lag

```bash
node -e "
const { monitorEventLoopDelay } = require('perf_hooks');
const h = monitorEventLoopDelay({ resolution: 10 });
h.enable();
setTimeout(() => {
  h.disable();
  console.log('mean:', h.mean / 1e6, 'ms');
  console.log('max:', h.max / 1e6, 'ms');
  console.log('p99:', h.percentile(99) / 1e6, 'ms');
}, 5000);
"
```

Umbrales de referencia:
- mean < 5ms → saludable
- mean 5-50ms → degradado
- mean > 50ms → bloqueado, requiere acción inmediata

### Causas comunes y fixes

```javascript
// ❌ fs.readFileSync en handler HTTP
app.get('/config', (req, res) => {
  const config = fs.readFileSync('./config.json') // bloquea el loop
})

// ✅ Cachear en memoria al iniciar
let config
app.listen(3000, () => {
  config = JSON.parse(fs.readFileSync('./config.json'))
})
app.get('/config', (req, res) => res.json(config))

// ❌ child_process.execSync en request path
app.get('/version', (req, res) => {
  const v = execSync('git rev-parse HEAD').toString()
})

// ✅ Precalcular al iniciar
const VERSION = execSync('git rev-parse HEAD').toString().trim()
app.get('/version', (req, res) => res.json({ version: VERSION })
```

---

## TypeScript

### Señales de activación

- `tsc --noEmit` falla con errores no claros
- `TS2345 Argument of type X is not assignable to Y`
- `TS2769 No overload matches this call`
- Circular imports que rompen la compilación
- `any` implícito que esconde bugs en runtime

### Diagnóstico

```bash
# Ver todos los errores con ubicación exacta
npx tsc --noEmit 2>&1 | head -50

# Diagnosticar tipo inferido de una expresión
npx tsc --noEmit --diagnostics 2>&1 | grep "Types"

# Verificar versión de TS y targets
cat tsconfig.json

# Detectar circular imports
npx madge --circular --extensions ts src/
```

### Errores frecuentes y fixes

```typescript
// ❌ TS2345: tipo incorrecto pasado a función
function process(items: string[]) {}
process(maybeItems) // maybeItems es string[] | undefined

// ✅ Guard explícito
if (maybeItems) process(maybeItems)

// ❌ TS2769: callback con firma incompatible
array.map((item, index) => item.id) // tipos del callback no coinciden

// ✅ Tipado explícito del parámetro
array.map((item: MyType) => item.id)

// ❌ Circular import (A importa B, B importa A)
// src/a.ts: import { B } from './b'
// src/b.ts: import { A } from './a'

// ✅ Extraer tipos compartidos a types.ts
// src/types.ts: export type { A, B }
// src/a.ts: import { B } from './types'
// src/b.ts: import { A } from './types'
```

---

## Crashes

### Señales de activación

- Proceso termina con `SIGSEGV` o `SIGABRT` (heap corruption)
- `FATAL ERROR: ... out of memory` con OOM killer
- Dependencia nativa falla al cargar (`Error: cannot open shared object file`)

### Diagnóstico

```bash
# Verificar ulimits del proceso
ulimit -a

# Verificar versión de Node y arquitectura
node -e "console.log(process.version, process.platform, process.arch)"

# Listar dependencias nativas instaladas
npm list --depth=0 | grep -E "sharp|canvas|bcrypt|sqlite3|node-gyp"

# Verificar compatibilidad de dependencia nativa con versión de Node
# Buscar en el repositorio de la dependencia: "node X.Y support"

# Rebuild de nativos (resuelve la mayoría de incompatibilidades post-upgrade)
npm rebuild
```

### Causas comunes

| Síntoma | Causa más probable | Fix |
|---------|------------------|-----|
| `SIGSEGV` después de upgrade Node | Nativo compilado contra versión anterior | `npm rebuild` |
| OOM en servidor con RAM suficiente | `--max-old-space-size` no configurado | `node --max-old-space-size=4096 app.js` |
| `cannot open shared object file` | Nativo con dependencia de sistema faltante | Instalar dependencia de sistema (ej: `libvips` para sharp) |
| `SIGABRT` en tests | Nativo que hace doble free | Actualizar nativo a versión compatible con Node actual |

---

## Reporte GitHub

Flujo obligatorio al finalizar cualquier diagnóstico. Todo diagnóstico queda
trazado en GitHub — sin excepción.

### Paso 1 — Verificar issue activo

```bash
exec "cat scrum/sprint-state.json"
# Buscar en inProgress[] un item con id que coincida con <owner>/<repo>#<n>
```

### Paso 2 — Decidir dónde reportar

```
¿Hay issue activo en sprint-state.json para este repo?
  │
  ├── SÍ → ¿El diagnóstico es sobre ese issue o está relacionado?
  │           ├── SÍ → Comentar en el issue activo
  │           └── NO → Crear issue nuevo
  │
  └── NO → Crear issue nuevo SIEMPRE
```

### Template — comentar en issue existente

```bash
gh issue comment <n> --repo <owner>/<repo> --body "## ⚡ Node Specialist — Diagnóstico

**Patología:** <memory-leak | cpu-spike | event-loop | typescript | crash>
**Modo:** <directo-por-label | post-triage | worker-reportado>

### Causa raíz
<explicación técnica con evidencia concreta>

### Fix propuesto
- **Archivo:** \`<ruta/al/archivo.ts>\`
- **Líneas:** <N-M>
- **Cambio:** <descripción del cambio mínimo necesario>

### Riesgo de regresión
<qué otras áreas podrían verse afectadas>

### Asignación sugerida
@<backend-dev | frontend-dev>"
```

### Template — crear issue nuevo

```bash
gh issue create \
  --repo <owner>/<repo> \
  --title "perf(<área>): <descripción corta del problema>" \
  --label "performance" \
  --body "## ⚡ Node Specialist — Diagnóstico

**Detectado por:** Roy (Node Specialist)
**Patología:** <memory-leak | cpu-spike | event-loop | typescript | crash>

### Síntoma observado
<qué se observó + evidencia>

### Causa raíz
<explicación técnica confirmada>

### Fix propuesto
- **Archivo:** \`<ruta/al/archivo.ts>\`
- **Líneas:** <N-M>
- **Cambio:** <descripción>

### Riesgo de regresión
<evaluación>

### Asignación sugerida
<backend-dev | frontend-dev>"
```

### Reglas del reporte

```
✅ Siempre verificar sprint-state.json antes de reportar
✅ Comentar en issue activo si el diagnóstico está relacionado
✅ Crear issue nuevo si no hay issue activo o el problema es independiente
✅ Incluir siempre: causa raíz + fix propuesto + riesgo + asignación
❌ NUNCA dejar un diagnóstico sin trazabilidad en GitHub
❌ NUNCA crear issue nuevo si ya hay uno activo relacionado
❌ NUNCA reportar sin evidencia concreta (snapshot, perfil, log, comando ejecutado)
```
