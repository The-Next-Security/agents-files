---
name: node-specialist
description: 'Diagnóstico de performance Node.js/TypeScript: memory leaks, CPU spikes, latencia, tipado avanzado. Úsala cuando tns-debugger-triage identifica la causa raíz en runtime Node pero necesitas análisis más profundo. Triggers: "memory leak", "CPU spike", "heap dump", "event loop blocked", "TypeScript error avanzado", "tipado", "performance Node", "OOM", "process crash".'
---

# Node Specialist — Diagnóstico Node.js/TypeScript

## Cuándo usar esta skill

- `tns-debugger-triage` identificó la causa raíz en Node.js runtime (no en lógica de negocio)
- Hay un OOM (`FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed`)
- CPU sostenida >80% sin carga aparente
- Event loop lag >100ms medido en producción
- Error TypeScript complejo que `tsc` no resuelve con mensaje claro
- Proceso crashea con `SIGABRT` o `SIGSEGV` (heap corruption)

## No usar si

- El bug es lógico (usa `tns-debugger-triage`)
- Es un error de dependencia npm (actualiza el paquete, revisa changelog)
- Es un timeout de red (diagnostica el servicio externo)

---

## 1. Memory leak — flujo diagnóstico

```bash
# 1. Tomar heap snapshot inicial
node --inspect <app.js>
# En DevTools: Memory → Take snapshot

# 2. Reproducir la carga sospechosa
# 3. Tomar segundo snapshot → Compare snapshots → Buscar objetos con delta positivo

# Alternativa sin DevTools (producción):
node -e "
const v8 = require('v8');
const s = v8.writeHeapSnapshot();
console.log('Heap snapshot:', s);
"
```

**Señales de leak:**
- `Buffer` o `String` acumulándose en retained size
- Listeners no removidos (`EventEmitter` con >10 listeners en mismo evento)
- Closures reteniendo referencias a arrays grandes

**Fix más común en TNS repos:** event listener no removido en WebSocket/HTTP server.

---

## 2. CPU spike — flujo diagnóstico

```bash
# Perfil CPU 30s
node --cpu-prof --cpu-prof-interval=100 <app.js>
# Genera <isolate>-<pid>-v8.cpuprofile → abrir en Chrome DevTools

# En producción (sin reiniciar):
kill -USR1 <pid>  # genera perfil si --inspect está activo
```

**Señales:**
- Función en top 5 con >20% self time → optimizar o cachear
- `JSON.parse` / `JSON.stringify` en hot path con payloads >1MB → stream en su lugar
- `crypto.pbkdf2Sync` en handler HTTP → mover a async

---

## 3. Event loop bloqueado

```bash
# Medir lag
node -e "
const { monitorEventLoopDelay } = require('perf_hooks');
const h = monitorEventLoopDelay({ resolution: 10 });
h.enable();
setTimeout(() => {
  h.disable();
  console.log('mean:', h.mean / 1e6, 'ms', 'max:', h.max / 1e6, 'ms');
}, 5000);
"
```

**Causas comunes:**
- `fs.readFileSync` en handler HTTP
- `JSON.parse` de payload >5MB
- `child_process.execSync` en request path

---

## 4. TypeScript avanzado

```bash
# Ver errores con ubicación exacta
npx tsc --noEmit 2>&1 | head -50

# Diagnosticar tipo inferido
npx tsc --noEmit --diagnostics 2>&1 | grep "Types"

# Verificar versión de TS y lib targets
cat tsconfig.json | python3 -m json.tool
```

**Errores frecuentes en TNS repos:**
- `TS2345 Argument of type X is not assignable to Y` → revisar si hay `any` implícito upstream
- `TS2769 No overload matches this call` → el tipo del callback no coincide, usar cast explícito o wrapper tipado
- Circular imports → reorganizar en barrels o mover tipos a `types.ts` compartido

---

## 5. Proceso crashea (SIGSEGV/SIGABRT)

```bash
# Ver ulimits
ulimit -a

# Verificar versión de Node compatible con dependencias nativas
node -e "console.log(process.version, process.platform, process.arch)"
npm list --depth=0 | grep -E "sharp|canvas|bcrypt|sqlite3"

# Rebuildar nativos
npm rebuild
```

---

## Entregables esperados

Al usar esta skill, producir:
1. **Causa raíz confirmada** con evidencia (snapshot, perfil, log)
2. **Fix propuesto** — mínimo invasivo, sin refactor innecesario
3. **Verificación** — cómo confirmar que el fix resuelve el síntoma
4. Guardar hallazgos en `~/tns-debug/node-<repo>-<issue-id>.md`
