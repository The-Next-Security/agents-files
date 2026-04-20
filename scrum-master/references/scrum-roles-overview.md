# Scrum Roles — Documento General de Referencia

> **Propósito:** Documento maestro que define el framework de roles adoptado por el equipo. Establece el contexto compartido, los principios del framework, las relaciones entre roles y los mecanismos de coordinación. Cada rol tiene su documento específico referenciado al final de este índice.

---

## 1. Framework base: Scrum

Scrum es un framework ágil, iterativo e incremental para desarrollar y entregar productos complejos. No es una metodología paso a paso: es un conjunto mínimo de roles, eventos y artefactos que habilitan la autoorganización del equipo y la entrega continua de valor.

**Origen:** Artículo "The New New Product Development Game" — Takeuchi & Nonaka, Harvard Business Review, 1986. Formalizado para software por Ken Schwaber y Jeff Sutherland en los años 90. Versión vigente: Scrum Guide 2020.

**Principio central:** Los requerimientos son volátiles. La mejor estrategia para gestionar complejidad es entregar incrementos funcionales en ciclos cortos, inspeccionar el resultado y adaptar el plan.

---

## 2. Pilares del framework

| Pilar | Descripción |
|---|---|
| **Transparencia** | El estado real del trabajo, los impedimentos y el progreso son visibles para todos los miembros del equipo y stakeholders relevantes en todo momento. |
| **Inspección** | El equipo examina frecuentemente los artefactos y el progreso para detectar desviaciones indeseadas. |
| **Adaptación** | Cuando la inspección revela que el proceso o el producto se desvía del objetivo, el equipo ajusta tan pronto como sea posible. |

---

## 3. Valores del framework

Scrum exige que todos los miembros del equipo practiquen activamente los siguientes valores:

| Valor | Aplicación práctica |
|---|---|
| **Courage** | Tomar decisiones difíciles, dar feedback honesto, admitir errores. |
| **Focus** | Trabajar en lo que el Sprint requiere; no dispersarse en trabajo no comprometido. |
| **Commitment** | Obsesión con los objetivos del Sprint y la misión del producto. |
| **Respect** | Tratar a cada miembro del equipo como profesional competente, independientemente de experiencia o rol. |
| **Openness** | Transparencia sobre el trabajo, los errores y las dificultades. Ver los errores como oportunidades de mejora. |

---

## 4. Ciclo Inspect & Adapt

El mecanismo de mejora continua de Scrum opera en 4 pasos que se mapean directamente a los eventos del framework:

```
INSPECT  ──► Sprint Review + Sprint Retrospective
ADAPT    ──► Sprint Planning + Backlog Grooming
LEARN    ──► Daily Scrum
RESTART  ──► Cierre de Sprint → inicio del siguiente
```

---

## 5. Estructura del equipo

### 5.1 Roles formales de Scrum

El Scrum Guide 2020 define 3 accountabilities dentro de un Scrum Team:

| Accountability | Responsabilidad central |
|---|---|
| **Product Owner** | Maximizar el valor del producto. Dueño del Product Backlog. |
| **Scrum Master** | Garantizar que el equipo entiende y aplica correctamente el framework. Servant-leader. |
| **Developers** | Construir el incremento potencialmente liberable en cada Sprint. |

> **Nota sobre "Developers":** En el Scrum Guide, el término "Developer" incluye a todo miembro del equipo que contribuye a construir el producto, independientemente de su especialidad. En este equipo, los roles de Developer son: QA Analyst, Frontend Developer, Backend Developer, UX Developer, Git Expert y Documentation Expert.

### 5.2 Roles extendidos adoptados por este equipo

Además de los 3 roles formales de Scrum, este equipo define roles especializados dentro de la accountability de Developer:

| Rol | Especialidad principal |
|---|---|
| QA Analyst | Aseguramiento de calidad, pruebas, Definition of Done |
| Frontend Developer | Capa de presentación e interacción del usuario |
| Backend Developer | Lógica de negocio, APIs, persistencia, seguridad |
| UX Developer | Experiencia de usuario, diseño de interfaz, Design System |
| Git Expert | Control de versiones, branching strategy, CI/CD pipeline |
| Documentation Expert | Documentación técnica, funcional y de procesos |

---

## 6. Eventos Scrum

Todos los eventos son time-boxed. Saltarse o acortar eventos sin justificación reduce la transparencia y degrada el proceso.

| Evento | Frecuencia | Time-box | Propósito |
|---|---|---|---|
| **Backlog Grooming** | Continuo / semanal | ~10% de la capacidad del Sprint | Refinar, estimar y priorizar historias para próximos Sprints |
| **Sprint Planning** | Inicio de cada Sprint | Máx. 2h por semana de Sprint | Definir el Sprint Goal y comprometer el Sprint Backlog |
| **Daily Scrum** | Diario | Máx. 15 min | Sincronizar el equipo y detectar impedimentos |
| **Sprint Review** | Fin de cada Sprint | Máx. 1h por semana de Sprint | Demostrar el incremento y recopilar feedback |
| **Sprint Retrospective** | Fin de cada Sprint | Máx. 45 min por semana de Sprint | Mejorar el proceso interno del equipo |

### Estructura del Sprint Planning

**Parte 1 — What (¿Qué vamos a construir?):**
El PO presenta las User Stories de mayor prioridad. El equipo hace preguntas, entiende los criterios de aceptación y selecciona qué historias puede completar.

**Parte 2 — How (¿Cómo lo vamos a construir?):**
El equipo descompone las historias seleccionadas en tareas técnicas concretas. Define dependencias, asigna responsabilidades iniciales y estima el esfuerzo por tarea.

---

## 7. Artefactos Scrum

### 7.1 Product Backlog

- **Dueño:** Product Owner.
- Lista ordenada por prioridad de todo el trabajo conocido del producto.
- Contiene User Stories, bugs pendientes, deuda técnica y requerimientos no funcionales.
- Es un documento vivo: se actualiza en cada Sprint.
- No contiene tareas técnicas de bajo nivel.

### 7.2 Sprint Backlog

- **Dueño:** El equipo (Developers).
- Subconjunto del Product Backlog comprometido para el Sprint actual.
- Incluye las User Stories seleccionadas y las tareas técnicas derivadas.
- Solo el equipo puede modificarlo durante el Sprint.

### 7.3 Incremento

- El resultado tangible de cada Sprint: software funcional que cumple la Definition of Done.
- Cada incremento es potencialmente liberable a producción.

### 7.4 Definition of Done (DoD)

- Lista de criterios que una User Story debe cumplir para considerarse terminada.
- Aplica en múltiples niveles: tarea, historia, Sprint, release, producto.
- Es responsabilidad compartida de todo el equipo definirla y mantenerla.
- Si una historia no cumple la DoD, no puede ser presentada en el Sprint Review.

**DoD mínima de referencia para este equipo:**

```
[ ] Criterios de aceptación del PO verificados y aprobados.
[ ] Código revisado via pull request por al menos 1 Developer.
[ ] Pruebas unitarias escritas y pasando (cobertura mínima acordada).
[ ] Pruebas de integración ejecutadas sin errores bloqueantes.
[ ] Código mergeado al branch principal según la branching strategy.
[ ] Documentación técnica actualizada (API docs, README, ADRs).
[ ] Diseño implementado revisado y aprobado por UX Developer.
[ ] Sin vulnerabilidades de seguridad críticas detectadas.
[ ] Desplegado en entorno de staging/testing.
```

---

## 8. Formato de User Story

```
Título: [Nombre corto y descriptivo]

Como [actor específico],
quiero/debo [acción concreta]
para [objetivo o resultado de negocio].

Criterios de aceptación:
- [ ] [Condición verificable 1]
- [ ] [Condición verificable 2]
- [ ] [Condición verificable N]

Estimación: [story points — Fibonacci: 1, 2, 3, 5, 8, 13, 21]
Prioridad: [Alta / Media / Baja]
Dependencias: [otros tickets, servicios externos, decisiones de arquitectura]
```

---

## 9. Reglas de estimación (Planning Poker)

- Se usa la secuencia Fibonacci: 0, 1, 2, 3, 5, 8, 13, 21, ∞.
- La unidad es story points, no horas ni días.
- Cada Developer estima de forma independiente antes de revelar su carta.
- Cuando hay divergencia alta (ej: alguien pone 3 y otro 13), ambos extremos explican su razonamiento antes de re-estimar.
- Una historia con estimación de 13 o más puntos es candidata a ser dividida en historias más pequeñas.
- La historia con estimación ∞ no está suficientemente definida para estimarse: regresa al PO para refinamiento.

---

## 10. Matriz de autoridad de decisión

| Decisión | PO | SM | QA | FE | BE | UX | Git | Docs |
|---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| Prioridad del Product Backlog | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Cancelar un Sprint | ✅ | 🔔 | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Cuánto trabajo entra en un Sprint | ❌ | ❌ | 🤝 | 🤝 | 🤝 | 🤝 | 🤝 | 🤝 |
| Cómo se implementa una historia | ❌ | ❌ | 🤝 | ✅ | ✅ | ✅ | 🔔 | ❌ |
| Aceptar/rechazar un entregable | ✅ | ❌ | 🔔 | ❌ | ❌ | 🔔 | ❌ | ❌ |
| Remover impedimentos externos | ❌ | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Definition of Done | 🤝 | 🤝 | ✅ | 🤝 | 🤝 | 🤝 | 🤝 | 🤝 |
| Arquitectura técnica | ❌ | ❌ | ❌ | ✅ | ✅ | ❌ | 🤝 | ❌ |
| Branching strategy y flujo Git | ❌ | ❌ | ❌ | 🔔 | 🔔 | ❌ | ✅ | ❌ |
| Estándares de documentación | ❌ | ❌ | ❌ | 🔔 | 🔔 | 🔔 | 🔔 | ✅ |
| Design System | ❌ | ❌ | ❌ | 🤝 | ❌ | ✅ | ❌ | ❌ |
| Contratos de API | ❌ | ❌ | ❌ | 🤝 | ✅ | ❌ | ❌ | 🔔 |

> ✅ Autoridad exclusiva | 🤝 Responsabilidad compartida | 🔔 Rol de input/consulta | ❌ Sin autoridad

---

## 11. Diagrama de interacciones

```
                    ┌──────────────────────┐
                    │    STAKEHOLDERS      │
                    └──────────┬───────────┘
                               │ requerimientos
                               ▼
                    ┌──────────────────────┐
                    │    PRODUCT OWNER     │
                    │  backlog, releases,  │
                    │  criterios, ROI      │
                    └──────┬───────┬───────┘
                           │       │
              User Stories │       │ proceso / coaching
                           │       ▼
                           │  ┌────────────────┐
                           │  │  SCRUM MASTER  │
                           │  │  facilita,     │
                           │  │  protege,      │
                           │  │  remueve imp.  │
                           │  └────────┬───────┘
                           │           │
                           ▼           ▼
          ┌────────────────────────────────────────────────────┐
          │                   SCRUM TEAM                       │
          │                                                    │
          │  ┌───────────┐  ┌───────────┐  ┌───────────────┐  │
          │  │    UX     │  │ FRONTEND  │  │   BACKEND     │  │
          │  │ DEVELOPER │─►│ DEVELOPER │◄─│   DEVELOPER   │  │
          │  │           │  │           │  │               │  │
          │  └─────┬─────┘  └─────┬─────┘  └───────┬───────┘  │
          │        │              │                │           │
          │        └──────────────┼────────────────┘           │
          │                       │                            │
          │               ┌───────▼───────┐                    │
          │               │  QA ANALYST   │                    │
          │               │  calidad, DoD │                    │
          │               └───────┬───────┘                    │
          │                       │                            │
          │        ┌──────────────┴─────────────┐              │
          │        ▼                            ▼              │
          │  ┌───────────┐            ┌──────────────────┐     │
          │  │    GIT    │            │  DOCUMENTATION   │     │
          │  │  EXPERT   │            │     EXPERT       │     │
          │  │ versiones │            │  docs, guías,    │     │
          │  │ CI/CD     │            │  estándares      │     │
          │  └───────────┘            └──────────────────┘     │
          └────────────────────────────────────────────────────┘
```

---

## 12. Índice de documentos específicos por rol

| Archivo | Rol |
|---|---|
| `01_scrum_master.md` | Scrum Master |
| `02_product_owner.md` | Product Owner |
| `03_qa_analyst.md` | QA Analyst |
| `04_frontend_developer.md` | Frontend Developer |
| `05_backend_developer.md` | Backend Developer |
| `06_ux_developer.md` | UX Developer |
| `07_git_expert.md` | Git Expert |
| `08_documentation_expert.md` | Documentation Expert |

---

*Basado en: The Scrum Framework Training Book (International Scrum Institute™, 3ª ed.) · Scrum Guide 2020 (Schwaber & Sutherland) · Wikipedia: Scrum (project management) · Scrum.org · Atlassian Agile.*
