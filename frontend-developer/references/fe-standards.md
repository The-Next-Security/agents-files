# Frontend Developer — Estándares y Stack de Referencia

## Stack técnico

| Categoría | Tecnologías |
|-----------|-------------|
| Framework UI | React, Vue.js, Angular, Svelte, Next.js, Nuxt |
| Estilos | CSS Modules, Tailwind CSS, Styled Components, SCSS |
| State Management | Redux Toolkit, Zustand, Pinia, MobX, Context API |
| Testing | Jest, Vitest, React Testing Library, Cypress, Playwright |
| Build Tools | Vite, Webpack, Turbopack, Rollup |
| HTTP / Data Fetching | Axios, Fetch API, TanStack Query (React Query), SWR |
| Accesibilidad | axe-core, Lighthouse, NVDA/VoiceOver (pruebas manuales) |
| Control de versiones | Git — branching strategy definida por GitHub Manager |

---

## Patrones de state management

### Cuándo usar cada enfoque

| Patrón | Cuándo |
|--------|--------|
| Estado local (`useState`) | Estado UI puntual — un componente lo dueña, nadie más lo necesita |
| Context API | Estado compartido por un árbol reducido de componentes (tema, auth) |
| Zustand / Redux Toolkit | Estado global complejo con múltiples consumidores y mutaciones |
| TanStack Query / SWR | Estado de servidor — cacheo, revalidación, sincronización de datos remotos |

Regla: preferir el patrón más simple que resuelva el problema. No usar Redux para estado local.

---

## Contrato de API — plantilla de definición

Antes de iniciar implementación, acordar con Backend Developer:

```yaml
endpoint: POST /api/recurso
request:
  headers:
    Authorization: Bearer <token>
  body:
    campo1: string (required, max 255)
    campo2: number (optional)
responses:
  200:
    body: { id: string, campo1: string, createdAt: ISO8601 }
  400:
    body: { error: string, field?: string }
  401: Unauthorized
  500: Internal Server Error
timeout: 10s
```

---

## Responsive — breakpoints estándar

```css
/* Mobile first */
/* xs: 0px+ (base) */
/* sm: 640px+ */
/* md: 768px+ */
/* lg: 1024px+ */
/* xl: 1280px+ */
/* 2xl: 1536px+ */
```

Verificar en staging: Chrome DevTools Device Mode con iPhone SE (375px), iPad (768px) y 1440px desktop.

---

## Manejo de errores de red — catálogo

| Código | Acción en el cliente |
|--------|---------------------|
| 400 | Mostrar mensaje de validación específico del campo |
| 401 | Redirigir a login / refrescar token |
| 403 | Mostrar "Sin permisos" — no exponer detalles |
| 404 | Mostrar empty state o mensaje "no encontrado" |
| 422 | Mapear errores de validación a campos del formulario |
| 429 | Mostrar "Demasiadas solicitudes, intenta más tarde" |
| 500/503 | Mostrar error genérico + botón de reintentar |
| Network error | Detectar offline: mostrar banner de conexión |

---

## Optimización de imágenes

```html
<!-- Siempre especificar dimensiones para evitar CLS -->
<img
  src="/images/hero.webp"
  width="1200"
  height="600"
  loading="lazy"
  decoding="async"
  alt="Descripción significativa"
/>

<!-- Usar srcset para responsividad -->
<img
  srcset="/img/hero-400.webp 400w, /img/hero-800.webp 800w"
  sizes="(max-width: 640px) 400px, 800px"
  src="/img/hero-800.webp"
  alt="..."
/>
```

Formatos preferidos (en orden): AVIF > WebP > PNG/JPEG como fallback.

---

## Convenciones de naming

```
components/
  Button/
    Button.tsx        ← PascalCase para componentes
    Button.test.tsx
    Button.module.css
  UserProfile/
    UserProfile.tsx
    useUserProfile.ts  ← camelCase con prefijo "use" para hooks
    userProfile.types.ts
    index.ts           ← barrel export

pages/
  dashboard.tsx        ← kebab-case para rutas/páginas

utils/
  formatDate.ts        ← camelCase para utilidades
```

---

## Participación en eventos Scrum

### Sprint Planning — preguntas a responder

1. ¿Están disponibles los diseños con todos los estados de UI?
2. ¿Está definido el contrato de API con Backend?
3. ¿Hay dependencias de componentes del Design System que aún no existen?
4. ¿Los criterios de aceptación mencionan dispositivos o navegadores específicos?

### Daily Scrum — formato

> "Ayer implementé [X]. Hoy trabajaré en [Y]. [Bloqueo: necesito el diseño del estado de error del componente Z / definir el endpoint de W con Backend]."

### Sprint Review — preparar demo

- Mostrar los flujos de usuario completos, no solo componentes aislados.
- Demostrar en al menos dos breakpoints (mobile + desktop).
- Si hay mejoras de rendimiento, mostrar métricas antes/después con Lighthouse.

---

## Entrega a QA — checklist previo

```
[ ] Código en rama feature pusheada y PR abierto
[ ] Todos los estados del componente implementados y visibles
[ ] Probado en Chrome, Firefox y Safari (últimas 2 versiones)
[ ] Probado en mobile 375px y desktop 1280px mínimo
[ ] No hay errores en consola del navegador
[ ] Lighthouse accesibilidad > 90 en la vista entregada
[ ] Variables de entorno de staging configuradas (no producción)
[ ] Link al PR incluido en el ticket de Jira/GitHub
```
