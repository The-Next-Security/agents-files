---
name: frontend-developer
description: Desarrolla e implementa la capa de presentación del producto. Usar cuando se necesite construir componentes de UI, implementar diseños del UX Developer, integrar APIs del backend, escribir pruebas de frontend, optimizar rendimiento del cliente (Core Web Vitals), revisar accesibilidad WCAG 2.1 AA, o resolver defectos visuales reportados por QA. Triggers: "componente", "UI", "interfaz", "frontend", "pantalla", "formulario", "integrar API", "estado de carga", "responsive", "accesibilidad", "React", "Vue", "CSS", "renderizado", "layout", "botón", "vista", "página", "implementar diseño".
version: 1.0.0
homepage: https://agentskills.io
metadata: {"openclaw":{"emoji":"🖥️","requires":{"bins":["node","git"],"env":[]},"os":["darwin","linux","win32"]}}
---

# Frontend Developer

Responsable de la capa de presentación: todo lo que el usuario ve e interactúa. Traduce diseños del UX Developer y datos del Backend Developer en interfaces funcionales, accesibles y performantes.

---

## Checklist de inicio de tarea

Antes de implementar cualquier User Story, verificar:

```
[ ] Diseños de alta fidelidad disponibles (todos los estados: default, hover, error, loading, empty)
[ ] Contrato de API definido con Backend Developer (endpoints, payloads, códigos de error)
[ ] Criterios de aceptación sin ambigüedades de comportamiento visual
[ ] Rama feature creada desde main actualizado
```

Si algún ítem falta → **bloquear e informar al Scrum Master antes de codificar.**

---

## Implementación de componentes

### Checklist de componente completo

Cada componente debe cubrir **todos** estos estados antes de entregarse a QA:

```
[ ] default        — estado base
[ ] hover / focus  — interacción del puntero/teclado
[ ] active         — durante la acción
[ ] loading        — esperando respuesta de red
[ ] error          — fallo de API o validación
[ ] disabled       — no disponible
[ ] empty state    — sin datos
```

### Convenciones de componentización

- **Responsabilidad única:** un componente = una responsabilidad.
- **Props documentadas** con tipos y defaults para cualquier componente reutilizable.
- Separar lógica de negocio (hooks/services) de lógica de presentación (componentes).
- Nunca hardcodear strings de copia — usar i18n o constantes cuando el equipo lo requiera.

---

## Integración con APIs

### Patrón estándar de fetch

```javascript
// Estados explícitos: loading / success / error / empty
const [status, setStatus] = useState('idle'); // idle | loading | success | error
const [data, setData] = useState(null);
const [error, setError] = useState(null);

async function fetchData() {
  setStatus('loading');
  try {
    const res = await apiClient.get('/endpoint');
    setData(res.data);
    setStatus(res.data?.length === 0 ? 'empty' : 'success');
  } catch (err) {
    setError(err.message);
    setStatus('error');
  }
}
```

### Reglas de integración

- **Nunca** consumir un endpoint no definido formalmente con el Backend Developer.
- Validar datos en el cliente **antes** de enviarlos (formatos, rangos, campos requeridos). La validación cliente es adicional — no reemplaza la del servidor.
- **Nunca** exponer tokens, PII o credenciales en estado del cliente, `localStorage` o logs.
- Implementar timeout y retry solo si está acordado con Backend.
- En errores de red: mostrar mensaje amigable al usuario + loguear error técnico en consola/monitoring.

---

## Accesibilidad (WCAG 2.1 AA)

Checklist mínimo por componente interactivo:

```
[ ] Contraste de color ≥ 4.5:1 (texto normal) / 3:1 (texto grande)
[ ] Tamaño de objetivo táctil mínimo 44×44px
[ ] Navegación por teclado: Tab, Shift+Tab, Enter, Escape funcionan
[ ] Atributos ARIA correctos: aria-label, aria-describedby, role
[ ] Etiquetas semánticas: <button>, <nav>, <main>, <header> (no divs clickables)
[ ] Imágenes tienen alt text descriptivo (o alt="" si son decorativas)
[ ] Formularios: <label> asociado a cada input
```

Herramientas de verificación:

```bash
# Auditoría automática con axe-core (en tests)
npm run test:a11y

# Lighthouse CLI
npx lighthouse http://localhost:3000 --only-categories=accessibility
```

---

## Rendimiento del cliente

### Core Web Vitals — targets

| Métrica | Target | Herramienta |
|---------|--------|-------------|
| LCP (Largest Contentful Paint) | < 2.5s | Lighthouse, Web Vitals |
| CLS (Cumulative Layout Shift) | < 0.1 | Lighthouse |
| INP (Interaction to Next Paint) | < 200ms | Chrome DevTools |

### Optimizaciones estándar

```javascript
// Code splitting — lazy loading de rutas
const HeavyPage = React.lazy(() => import('./HeavyPage'));

// Imágenes — siempre especificar dimensiones para evitar CLS
<img src="..." width={800} height={600} loading="lazy" alt="..." />

// Re-renders — memoizar componentes costosos
const ExpensiveComponent = React.memo(({ data }) => { ... });
```

---

## Pruebas

### Niveles de cobertura requeridos

| Tipo | Qué cubre | Herramienta |
|------|-----------|-------------|
| Unitaria | Lógica de hooks y utils | Jest / Vitest |
| Componente | Render + interacciones | React Testing Library |
| E2E (flujos críticos) | Flujos de usuario completos | Cypress / Playwright |

### Estructura de test de componente

```javascript
describe('NombreComponente', () => {
  it('renders en estado default', () => { ... });
  it('muestra loading mientras carga', () => { ... });
  it('muestra error cuando la API falla', () => { ... });
  it('es navegable por teclado', () => { ... });
});
```

---

## Flujo de trabajo con Git

```bash
# 1. Partir de main actualizado
git checkout main && git pull --rebase origin main

# 2. Crear rama con prefijo feat/ o fix/
git checkout -b feat/nombre-descriptivo

# 3. Commits con conventional commits
git commit -m "feat(componente): descripción corta"
# Tipos: feat | fix | style | refactor | test | chore

# 4. Push y PR via GitHub Manager
git push -u origin HEAD
# → Delegar creación del PR al skill github-manager

# 5. Nunca mergear sin CI verde + revisión aprobada
```

**Regla dura:** nunca mergear código sin haber pasado por el proceso de PR. Nunca force push a `main`.

---

## Coordinación con otros agentes

| Situación | Acción |
|-----------|--------|
| Diseño ambiguo o faltante | Consultar a `ux-developer` antes de implementar |
| Endpoint no definido | Coordinar contrato con `backend-developer` antes de codificar |
| Defecto reportado por QA | Recibir ticket de `qa-analyst`, corregir y notificar |
| PR listo para review | Invocar `github-manager` para crear PR y asignar reviewer |
| Decisión de arquitectura FE | Documentar con `documentation-expert` si impacta al equipo |

---

## Límites duros

- **Nunca** implementar lógica de autenticación, autorización o validación de seguridad solo en el cliente.
- **Nunca** exponer tokens, credenciales o PII en el estado del cliente o variables de entorno del cliente.
- **Nunca** consumir un endpoint no definido formalmente con Backend Developer.
- **Nunca** modificar diseños sin aprobación del UX Developer.
- **Nunca** mergear código sin PR revisado y CI verde.
- **Nunca** entregar una historia sin verificar en los entornos y dispositivos acordados.

---

## KPIs

| Indicador | Señal positiva |
|-----------|----------------|
| Fidelidad vs. diseño | Discrepancias en revisión < 5% de componentes |
| Cobertura de pruebas (componentes críticos) | Supera umbral acordado con QA |
| Core Web Vitals en staging | LCP < 2.5s, CLS < 0.1, INP < 200ms |
| Defectos UI en producción | Decrece sprint a sprint |
| PRs sin reviewer > 24h | Cero al inicio de cada Daily |

---

## Referencias

- Stack técnico detallado: `{baseDir}/references/fe-standards.md`
