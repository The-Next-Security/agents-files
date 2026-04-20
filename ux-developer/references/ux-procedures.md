# UX Developer — Procedimientos y referencias

## Design System — guía completa

### Estructura del sistema

```
design-system/
├── tokens/
│   ├── colors.json         ← paleta completa (primitivos + semánticos)
│   ├── typography.json     ← familias, tamaños, pesos, line-height
│   ├── spacing.json        ← escala de espaciado (4px base)
│   ├── shadows.json        ← elevaciones
│   ├── borders.json        ← radios, grosores
│   └── motion.json         ← duraciones, easings
├── components/
│   └── [componente]/
│       ├── [componente].fig  ← fuente de verdad visual
│       └── README.md         ← estados, uso, anti-patrones
└── CHANGELOG.md
```

### Tokens de color — estructura recomendada

```json
{
  "primitive": {
    "blue-500": "#3B82F6",
    "red-500": "#EF4444",
    "gray-100": "#F3F4F6"
  },
  "semantic": {
    "color-primary": "{primitive.blue-500}",
    "color-error": "{primitive.red-500}",
    "color-background-subtle": "{primitive.gray-100}"
  }
}
```

Los componentes usan siempre tokens semánticos, nunca primitivos directamente.

### Escala de espaciado (base 4px)

| Token | Valor | Uso típico |
|-------|-------|------------|
| `space-1` | 4px | Micro-gap entre ícono y texto |
| `space-2` | 8px | Gap interno de componente |
| `space-3` | 12px | Padding compacto |
| `space-4` | 16px | Padding estándar |
| `space-6` | 24px | Separación entre secciones |
| `space-8` | 32px | Gap grande entre bloques |
| `space-12` | 48px | Separación de secciones de página |

### Tipografía — especificación mínima por estilo

| Estilo | Familia | Tamaño | Peso | Line-height | Uso |
|--------|---------|--------|------|-------------|-----|
| `heading-1` | Inter | 32px | 700 | 1.2 | Títulos de página |
| `heading-2` | Inter | 24px | 600 | 1.3 | Títulos de sección |
| `heading-3` | Inter | 20px | 600 | 1.4 | Subtítulos |
| `body-lg` | Inter | 16px | 400 | 1.5 | Texto principal |
| `body-sm` | Inter | 14px | 400 | 1.5 | Texto secundario |
| `caption` | Inter | 12px | 400 | 1.4 | Labels, metadatos |
| `label` | Inter | 14px | 500 | 1 | Labels de formulario |

### Breakpoints estándar

| Nombre | Ancho | Target |
|--------|-------|--------|
| `mobile` | ≤ 375px | Smartphones |
| `tablet` | 376–768px | Tablets |
| `desktop-sm` | 769–1280px | Laptops |
| `desktop-lg` | ≥ 1281px | Monitores |

Los diseños se entregan para los 4 breakpoints salvo que el PO acuerde lo contrario.

---

## Research — templates y herramientas

### Guía de entrevista de usuario (template)

```markdown
## Objetivo de la sesión
¿Qué queremos aprender?

## Participantes
- Perfil del usuario: [descripción]
- Moderador: [nombre]
- Observador: [nombre]

## Preguntas de apertura (5 min)
- Cuéntame cómo es tu día a día relacionado con [contexto del producto].
- ¿Con qué frecuencia usas [tipo de herramienta]?

## Preguntas de profundidad (20 min)
- La última vez que hiciste [tarea], ¿cómo lo hiciste?
- ¿Qué fue lo más frustrante de ese proceso?
- ¿Qué harías diferente si pudieras?

## Tareas con prototipo (15 min)
- "Imagina que acabas de recibir X. ¿Qué harías?"
- Observar sin ayudar. Registrar: dónde duda, dónde falla, qué dice en voz alta.

## Cierre (5 min)
- ¿Hay algo que no te pregunté y que crees que debería saber?
```

### Síntesis de hallazgos — formato

```markdown
## Hallazgos de investigación — [fecha]

### Participantes
N usuarios, perfil: [descripción]

### Hallazgos principales

| # | Hallazgo | Evidencia | Frecuencia | Impacto |
|---|----------|-----------|------------|---------|
| 1 | [descripción] | "[cita directa]" | X/N usuarios | Alto/Medio/Bajo |

### Patrones de comportamiento
- [Patrón observado]

### Pain points priorizados
1. [Pain point] — impacto: Alto — usuarios afectados: X/N
2. ...

### Recomendaciones
| Recomendación | Impacto | Esfuerzo estimado | Prioridad |
|---------------|---------|-------------------|-----------|
| [Acción] | Alto | Bajo | 🔴 Urgente |
```

---

## Flujos de usuario — patrones recurrentes

### Flujo de autenticación

```
[Landing / Login] 
  → [Formulario email + contraseña]
    → [Validación cliente] → error inline si falla
    → [Submit] → loading state
      → [Éxito] → redirect a dashboard
      → [Error credenciales] → mensaje inline + retry
      → [Error red] → toast de error + retry
  → [¿Olvidaste tu contraseña?]
    → [Formulario email]
      → [Email enviado] → pantalla de confirmación
      → [Email no encontrado] → mensaje + opción de registro
```

### Flujo de formulario largo (multi-paso)

```
[Paso 1/N] → validación inline por campo → [Siguiente]
  → [Paso 2/N] → [Anterior] / [Siguiente]
    → ...
      → [Paso N/N] → [Confirmar]
        → loading
          → [Éxito] → pantalla de confirmación
          → [Error] → volver al paso con error marcado + mensaje
```

Reglas para multi-paso:
- Indicador de progreso visible en todos los pasos.
- El usuario puede volver a cualquier paso anterior sin perder datos.
- Los datos se guardan en borrador si el usuario abandona (si aplica).
- En mobile, cada paso ocupa pantalla completa.

### Flujo de lista + detalle

```
[Lista] 
  → loading (skeleton de ítems)
  → [Lista con datos] → [Ítem] → [Detalle]
  → [Lista vacía] → mensaje + CTA principal
  → [Error de carga] → mensaje + botón "Reintentar"

[Detalle]
  → loading (skeleton del contenido)
  → [Contenido cargado]
  → [Error] → mensaje + "Volver a la lista"
```

---

## Checklist de handoff — versión extendida

### Para cada pantalla entregada

**Estructura y layout**
```
[ ] Layout definido para mobile, tablet y desktop
[ ] Grid / columnas especificados
[ ] Comportamiento de scroll documentado (sticky headers, infinite scroll, etc.)
[ ] Orden de tabulación definido (accesibilidad de teclado)
```

**Componentes**
```
[ ] Nombre del componente coincide con el Design System o se crea uno nuevo nombrado
[ ] Todos los estados: default, hover, focus, active, disabled, loading, error, empty, success
[ ] Variantes documentadas (tamaño, color, con/sin ícono)
[ ] Comportamiento responsivo de cada componente
```

**Datos y contenido**
```
[ ] Longitud máxima de texto en cada campo (para truncado)
[ ] Comportamiento con texto muy largo (ellipsis, wrap, scroll)
[ ] Placeholder y mensajes de ayuda en campos de formulario
[ ] Mensajes de error por campo (validación)
[ ] Mensajes de éxito/confirmación
[ ] Formato de fechas, números, monedas (para internacionalización si aplica)
```

**Interacciones**
```
[ ] Animaciones de entrada/salida de modales y drawers
[ ] Transiciones entre estados (duración + easing)
[ ] Feedback háptico en mobile (si aplica)
[ ] Comportamiento de gestos en mobile (swipe, pinch, etc.)
```

**Accesibilidad**
```
[ ] Contraste verificado con herramienta (Stark, Colour Contrast Analyser, etc.)
[ ] Alternativa de texto para imágenes e íconos
[ ] Mensajes de error anunciados a lectores de pantalla (aria-live)
[ ] Landmarks semánticos definidos (header, nav, main, footer)
```

---

## Anti-patrones a evitar

| Anti-patrón | Problema | Solución |
|-------------|----------|----------|
| Diseñar solo el happy path | El FE descubre los edge cases en implementación, genera retrabajo | Diseñar TODOS los estados antes de entregar |
| Hardcodear colores en mockups | Inconsistencia, difícil de mantener | Usar siempre tokens del Design System |
| Entregar diseño sin revisar con FE | Diseños técnicamente inviables | Revisión de viabilidad técnica antes del handoff |
| Asumir que el usuario lee las instrucciones | Los usuarios escanean, no leen | Diseñar para escaneo: jerarquía visual clara, CTAs obvios |
| Usar solo color para comunicar estado | Inaccessible para daltonismo | Ícono + texto + color para estados críticos |
| Diseñar para pantalla grande primero | Mobile se ve apretado, retrabajo | Mobile first, escalar a desktop |
| No documentar las interacciones | El FE las inventa o las omite | Especificar trigger, duración, easing para cada animación |

---

## KPIs del rol

| Indicador | Meta |
|-----------|------|
| Diseños disponibles antes del Sprint Planning | 100% de stories del sprint |
| Discrepancias diseño vs. implementación reportadas en review | < 5% de componentes |
| Defectos de usabilidad detectados en producción | Decrece sprint a sprint |
| Cobertura del Design System | Crece sprint a sprint |
| Tiempo entre entrega de diseño e inicio de implementación | Decrece (menos bloqueos) |
| Hallazgos de pruebas de usabilidad que llegan al backlog | > 80% de recomendaciones |
