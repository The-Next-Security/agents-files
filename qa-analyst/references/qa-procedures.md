# QA Analyst — Procedimientos detallados

> Referencia cargada on-demand desde `SKILL.md`. Contiene los procedimientos técnicos completos.

---

## Tabla de contenidos

1. [Casos de prueba](#casos-de-prueba)
2. [Tipos de prueba y checklist](#tipos-de-prueba-y-checklist)
3. [Gestión de defectos](#gestión-de-defectos)
4. [Automatización](#automatización)
5. [Accesibilidad WCAG 2.1 AA](#accesibilidad-wcag-21-aa)
6. [Seguridad básica OWASP](#seguridad-básica-owasp)
7. [Pruebas de rendimiento](#pruebas-de-rendimiento)
8. [KPIs del rol](#kpis-del-rol)

---

## Casos de prueba

### Estructura de un caso de prueba

```markdown
**ID:** TC-[HISTORIA]-[NÚMERO]  (ej: TC-US42-01)
**Historia:** US-42 — [título de la historia]
**Tipo:** Funcional / Regresión / Integración / Rendimiento / Accesibilidad
**Prioridad:** Alta / Media / Baja

**Precondiciones:**
- Estado del sistema requerido
- Datos de entrada disponibles
- Usuario autenticado como [rol] (si aplica)

**Pasos:**
1. [Acción exacta]
2. [Acción exacta]
3. ...

**Resultado esperado:**
[Comportamiento exacto que debe observarse]

**Resultado real:**
[A completar durante ejecución]

**Estado:** ✅ Pasa / ❌ Falla / ⏭️ Bloqueado / ⏳ Pendiente

**Evidencia:**
- [link a captura / log / video]
```

### Categorías de casos a cubrir siempre

Para cada historia, diseñar casos que cubran:

| Categoría | Descripción |
|-----------|-------------|
| **Camino feliz** | Flujo principal sin errores, con datos válidos |
| **Camino alternativo** | Flujos secundarios válidos contemplados en la historia |
| **Casos borde** | Valores límite: mínimo, máximo, vacío, nulo |
| **Error handling** | Datos inválidos, formatos incorrectos, errores de red |
| **Permisos y roles** | Acceso denegado para roles que no deben tener acceso |
| **Regresión** | Funcionalidades relacionadas que no deben romperse |

---

## Tipos de prueba y checklist

### Pruebas funcionales (todas las historias)

```
[ ] Camino feliz ejecutado y documentado
[ ] Casos borde identificados y probados
[ ] Manejo de errores verificado
[ ] Mensajes de error son claros y no exponen datos sensibles
[ ] Navegación / flujo de UI coherente (si tiene interfaz)
[ ] Validaciones de formulario funcionan correctamente
```

### Pruebas de regresión (cada Sprint)

```
[ ] Suite de regresión ejecutada sobre el incremento completo
[ ] No hay roturas en funcionalidades previamente aprobadas
[ ] Pruebas automatizadas de regresión pasan en CI
[ ] Si hay rotura: registrar defecto antes de continuar
```

### Pruebas de integración (cuando aplica)

Aplicar cuando la historia involucra comunicación entre FE ↔ BE, llamadas a APIs externas, o múltiples microservicios.

```
[ ] Contrato de API verificado (request/response match con documentación)
[ ] Manejo de errores HTTP probado: 400, 401, 403, 404, 500
[ ] Timeouts y reintentos se comportan correctamente
[ ] Datos fluyen correctamente de extremo a extremo
[ ] Sin duplicación de datos en operaciones POST/PUT repetidas
```

### Pruebas end-to-end (pre-release)

```
[ ] Flujos críticos de usuario ejecutados de inicio a fin
[ ] Pruebas en múltiples navegadores (si aplica): Chrome, Firefox, Safari
[ ] Pruebas en resoluciones mobile/tablet/desktop (si aplica)
[ ] Autenticación y autorización funcionan correctamente
[ ] Integraciones externas (pagos, email, etc.) verificadas en staging
```

### Pruebas de UI / visual regression (historias con cambios visuales)

```
[ ] La implementación coincide con el diseño aprobado por UX
[ ] Responsive en breakpoints definidos: mobile (375px), tablet (768px), desktop (1280px+)
[ ] Sin overflow de texto o elementos
[ ] Estados de UI cubiertos: hover, focus, disabled, loading, empty state, error state
[ ] Dark mode / light mode (si aplica)
```

---

## Gestión de defectos

### Estructura de un bug report

```markdown
**ID:** BUG-[NÚMERO]
**Fecha:** YYYY-MM-DD
**Historia relacionada:** US-[NÚMERO] (si aplica)
**Entorno:** Local / Staging / Producción
**Severidad:** Crítico / Alto / Medio / Bajo
**Estado:** Abierto / En progreso / En verificación / Cerrado

---

**Resumen:** [Una línea descriptiva del problema]

**Pasos para reproducir:**
1. Ir a [URL o pantalla]
2. Hacer [acción]
3. Observar [comportamiento]

**Comportamiento real:**
[Qué ocurre actualmente]

**Comportamiento esperado:**
[Qué debería ocurrir]

**Contexto adicional:**
- Navegador / SO / versión de app
- Usuario / rol afectado
- Frecuencia: siempre / intermitente

**Evidencia adjunta:**
- [ ] Captura de pantalla
- [ ] Video de sesión
- [ ] Log de consola / error log
- [ ] Request/response (para bugs de API)

**Asignado a:** [developer]
**Fix verificado por:** [QA] — [fecha de cierre]
```

### Flujo de vida de un defecto

```
Detectado → Registrado (QA)
         → Clasificado por severidad (QA)
         → Crítico/Alto: asignado al developer inmediatamente
           Medio/Bajo: agregado al backlog → PO prioriza
         → Developer corrige
         → QA verifica en el mismo entorno donde se detectó
         → Si pasa: cerrado con evidencia
         → Si no pasa: reabierto con nueva evidencia
```

### Gestión por severidad

**Crítico:**
1. Registrar el defecto con todos los campos
2. Notificar al Scrum Master y al developer responsable de inmediato
3. La historia no puede avanzar hasta que esté resuelto
4. Verificar fix antes de reabrirlo como "historia en progreso"

**Alto:**
1. Registrar y asignar al developer responsable
2. La historia no puede declararse Done hasta que esté cerrado
3. Si no puede resolverse en el Sprint: escalar al SM para decisión

**Medio / Bajo:**
1. Registrar con evidencia completa en el backlog
2. Notificar al PO para priorización
3. No bloquea el Sprint ni la DoD
4. Se convierte en nueva User Story o tarea de mejora

---

## Automatización

### Pirámide de pruebas — estructura recomendada

```
        /   E2E (pocos, alto valor)   \
       /   Integración (moderados)    \
      /   Unitarias (muchas, rápidas)  \
```

### Qué automatizar primero

Prioridad alta para automatizar:
1. Flujos críticos del negocio (happy path de features core)
2. Casos de regresión que se ejecutan en cada Sprint
3. Pruebas de API (contrato, errores HTTP, auth)
4. Validaciones de formularios con múltiples combinaciones de datos

Candidatos para prueba manual (baja prioridad de automatización):
- Flujos que cambian frecuentemente (son caros de mantener)
- Pruebas exploratorias
- Validación visual subjetiva

### Integración con CI/CD

Coordinar con DevOps / Git Expert para:

```yaml
# Estructura de gates recomendada en pipeline
on_pull_request:
  - unit_tests        # Rápidos, siempre
  - lint + typecheck
  - integration_tests # Si el PR toca BE/API

on_merge_to_main:
  - full_test_suite   # Unitarias + integración
  - e2e_critical_paths
  - coverage_report   # Falla si cae bajo el umbral

pre_release:
  - full_e2e
  - performance_baseline
  - accessibility_scan
```

### Mantenimiento de suites

- Cuando cambia una funcionalidad: actualizar los casos de prueba **en el mismo PR**
- Pruebas que fallan de forma intermitente (flaky tests): registrar como bug de alta prioridad en el backlog de calidad
- Revisar cobertura mensualmente y proponer nuevos casos en Retrospective

---

## Accesibilidad WCAG 2.1 AA

### Criterios mínimos a verificar

```
[ ] Contraste de color: texto normal ≥ 4.5:1, texto grande ≥ 3:1
[ ] Navegación por teclado: todos los elementos interactivos son alcanzables con Tab
[ ] Focus visible: el foco del teclado es claramente visible
[ ] Atributos alt en imágenes (decorativas: alt="", informativas: descripción real)
[ ] Etiquetas en formularios: cada campo tiene <label> asociado o aria-label
[ ] Mensajes de error accesibles: anunciados a lectores de pantalla
[ ] No hay trampas de teclado: se puede salir de cualquier componente con teclado
[ ] Encabezados jerárquicos: h1 → h2 → h3 sin saltos
[ ] Roles ARIA usados correctamente (no abusados)
```

### Herramientas recomendadas

- **axe DevTools** (extensión de browser) — escaneo automático
- **Lighthouse** (Chrome DevTools) — auditoría de accesibilidad
- **NVDA** (Windows) o **VoiceOver** (macOS/iOS) — prueba con lector de pantalla
- **Color Contrast Analyser** — verificación manual de contraste

### Flujo de validación

1. Ejecutar axe o Lighthouse sobre la pantalla/componente
2. Clasificar hallazgos: crítico (impide uso) / moderado / menor
3. Revisar manualmente la navegación por teclado
4. Reportar defectos con referencia al criterio WCAG específico (ej: "WCAG 1.4.3 — Contraste insuficiente")
5. Coordinar fix con UX Developer y FE Developer

---

## Seguridad básica OWASP

Aplicar en historias que involucren autenticación, entrada de datos de usuario, o acceso a recursos protegidos.

### Checklist OWASP Top 10 básico

```
[ ] Inyección (SQL, NoSQL, command): inputs de usuario son sanitizados y parametrizados
[ ] Autenticación rota: sesiones expiran correctamente; no hay bypass de login
[ ] Exposición de datos sensibles: passwords no en texto plano; datos sensibles no en logs
[ ] Control de acceso roto: usuarios no pueden acceder a recursos de otros usuarios
[ ] Configuración incorrecta: no hay endpoints de debug expuestos en staging/producción
[ ] XSS: inputs de usuario no se renderizan como HTML sin sanitizar
[ ] CSRF: operaciones con efecto secundario tienen protección CSRF
[ ] Headers de seguridad: Content-Security-Policy, X-Frame-Options presentes
```

Coordinar hallazgos con BE Developer. Si se detecta vulnerabilidad grave → escalar al SM de inmediato, **no** registrar en backlog público.

---

## Pruebas de rendimiento

Aplicar en historias críticas de carga o cuando el PO / stakeholder define SLAs.

### Métricas baseline a establecer

| Métrica | Umbral típico (ajustar según SLA) |
|---------|-----------------------------------|
| Time to First Byte (TTFB) | < 200ms |
| Tiempo de carga de página | < 3s en 3G simulado |
| Respuesta de API (p95) | < 500ms bajo carga normal |
| Respuesta de API bajo carga (load test) | Definido por PO |

### Herramientas recomendadas

- **k6** — load testing de APIs (scripting en JS)
- **Lighthouse** — performance score de frontend
- **Artillery** — alternativa a k6 para API load testing
- **Chrome DevTools Performance tab** — profiling de frontend

### Flujo básico

1. Establecer baseline antes del Sprint (o al iniciar el proyecto)
2. Ejecutar prueba de carga simple (k6 o Artillery) sobre endpoints críticos
3. Comparar contra baseline y contra SLA definido por PO
4. Si hay degradación significativa (>20% vs baseline): registrar como defecto Alto
5. Reportar resultados en Sprint Review si el PO lo requirió

---

## KPIs del rol

| Indicador | Señal positiva |
|-----------|----------------|
| Defectos detectados en producción | Decrece sprint a sprint |
| Defectos detectados en Sprint vs. post-Sprint | Alta proporción detectada durante el Sprint (shift-left) |
| Cobertura de pruebas automatizadas | Crece de forma sostenida; supera umbral acordado |
| Tiempo promedio de cierre de defectos (días) | Decrece con el tiempo |
| Historias rechazadas en Sprint Review por calidad | < 5% del total de historias demostradas |
| Defectos reabiertos | < 10% del total de defectos cerrados |

Reportar estos KPIs en Retrospective y en el resumen de Sprint para visibilidad del equipo.
