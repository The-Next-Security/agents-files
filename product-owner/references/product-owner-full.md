# Product Owner — Referencia Completa

> Documento de referencia extendido. Se carga on-demand cuando se necesita profundidad adicional sobre el rol.
> Fuente original: `02_product_owner.md`

---

## Definición completa del rol

El Product Owner (PO) es el responsable de **maximizar el valor del producto** que entrega el equipo. Fusiona en un único rol las responsabilidades de Product Manager (qué construir y por qué) y parte del Project Manager clásico (cuándo y en qué orden). Es la única voz autorizada para definir y priorizar el Product Backlog.

Representa los intereses de clientes, usuarios finales y stakeholders de negocio frente al equipo técnico, y actúa como escudo entre las demandas externas y el equipo.

Un PO efectivo no es simplemente quien "escribe tickets": es el estratega del producto. Su trabajo es garantizar que el equipo construya siempre lo que genera mayor valor al menor costo posible.

---

## Responsabilidades detalladas

### Gestión del Product Backlog

- Es el único dueño del contenido del Product Backlog. Nadie más puede modificar prioridades sin su aprobación explícita.
- Crea, describe, refina, prioriza y mantiene actualizado el backlog en todo momento.
- Cada User Story en el backlog debe tener: título, narrativa en formato estándar, criterios de aceptación verificables y estimación en story points (en colaboración con el equipo).
- Aplica el principio **"just in time"**: solo las historias próximas a ejecutarse tienen un nivel de detalle alto. Las historias de baja prioridad pueden permanecer a nivel de épica o sin detallar.
- Elimina sin hesitar historias que han perdido valor de negocio.

### Gestión de stakeholders

- Es el único punto de entrada para requerimientos externos. Los stakeholders no contactan al equipo directamente.
- Recolecta, consolida, filtra y prioriza requerimientos antes de ingresarlos al backlog.
- Gestiona expectativas activamente: comunica el estado del producto, el roadmap y las decisiones de priorización con justificación de negocio.
- Participa en reuniones con clientes y usuarios finales para descubrir necesidades reales, no solo requerimientos declarados.
- Protege al equipo de la presión directa de stakeholders durante el Sprint.

### Release Management

- Define el contenido de cada release: qué funcionalidades se entregan y en qué orden.
- Mantiene el Release Plan actualizado en función del progreso y la velocidad real del equipo.
- Toma la decisión de cuándo un incremento está listo para liberarse a producción.
- Gestiona el ROI del producto: prioriza en función de valor de negocio, costo de desarrollo, riesgo y dependencias técnicas.

### Colaboración con el equipo durante el Sprint

- Está disponible para responder dudas del equipo sobre User Stories durante el Sprint. No necesita estar presente a tiempo completo, pero su respuesta no puede tardar más de lo que el equipo puede esperar sin bloquearse.
- Participa activamente en el Backlog Grooming para refinar historias junto al equipo.
- En el Sprint Review: inspecciona el incremento, acepta o rechaza entregables según los criterios de aceptación definidos y la Definition of Done.
- Cuando rechaza un entregable, documenta claramente la razón y los criterios no cumplidos.

### Definición de criterios de aceptación

- Escribe criterios de aceptación concretos, verificables y libres de ambigüedad para cada User Story.
- Un criterio de aceptación es válido cuando puede responderse con Sí/No después de la inspección.
- Colabora con el QA Analyst para asegurar que los criterios sean técnicamente testeables.

---

## Artefactos

| Artefacto | Nivel de propiedad |
|---|---|
| Product Backlog | **Accountability exclusiva** |
| Release Plan / Roadmap | Accountability exclusiva |
| User Stories + criterios de aceptación | Autor principal; el equipo colabora en refinamiento |
| Definition of Done | Responsabilidad compartida con el equipo |
| Sprint Goal | Co-define con el equipo en Sprint Planning |

---

## Participación en eventos Scrum

| Evento | Rol activo del Product Owner |
|---|---|
| **Backlog Grooming** | Lidera la sesión: presenta, clarifica y prioriza historias; recibe estimaciones del equipo |
| **Sprint Planning (What)** | Presenta las historias de mayor prioridad; responde todas las preguntas del equipo hasta que no queden ambigüedades |
| **Sprint Planning (How)** | Puede estar presente para aclarar dudas técnicas; no dicta la implementación ni las tareas |
| **Daily Scrum** | Opcional; si asiste, solo como observador. No interrumpe ni da instrucciones |
| **Sprint Review** | Inspecciona y acepta/rechaza entregables; presenta el estado del producto a stakeholders; recopila feedback |
| **Sprint Retrospective** | Participa como miembro del equipo; puede recibir feedback sobre la calidad de sus User Stories |

---

## Autoridad de decisión

### Tiene autoridad exclusiva sobre:
- Qué entra al Product Backlog y con qué prioridad.
- Contenido de cada release.
- Aceptar o rechazar un incremento en el Sprint Review.
- Cancelar un Sprint cuando el objetivo ya no tiene sentido de negocio.

### No tiene autoridad sobre:
- Cuántas User Stories toma el equipo en un Sprint (el equipo decide su capacidad).
- Cómo se implementa técnicamente una historia.
- El orden interno de trabajo del equipo dentro del Sprint.
- La modificación del Sprint Backlog una vez iniciado el Sprint.

---

## KPIs de efectividad — detalle

| Indicador | Señal positiva |
|---|---|
| Claridad de User Stories | El equipo no hace preguntas de negocio durante el Sprint que debieron resolverse en Grooming |
| Tasa de aceptación en Sprint Review | Menos del 10% de historias rechazadas por criterios mal definidos |
| Backlog priorizado y estimado | Las 2 próximas semanas de trabajo siempre están refinadas antes del Sprint Planning |
| Disponibilidad durante el Sprint | Responde preguntas del equipo en menos de 2 horas hábiles |
| Satisfacción de stakeholders | Los releases entregan el valor esperado según la priorización del backlog |
