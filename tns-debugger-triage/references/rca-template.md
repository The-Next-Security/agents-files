# RCA — <owner>/<repo> — Issue #<n>

## Metadata
- Fecha RCA: <ISO8601>
- Autor: Debugger Agent
- Link al issue: <URL>
- Severidad estimada: low | medium | high | critical
- Estado del RCA: completo | no reproducible | bloqueado

## Síntoma observado
<qué reportó el humano, literal o resumido>

## Reproducción determinística
<pasos exactos, comandos, input, entorno>

Si no es reproducible: "No reproducible tras 2 intentos documentados."

## Root cause identificado
<explicación técnica del por qué ocurre>

## Commit culpable
<SHA + mensaje del commit, vía git bisect si aplica>

Si no aplica o no se encontró: "No identificado — bug anterior al
histórico relevante o no-regresional."

## Propuesta de fix
<cambio concreto recomendado, con archivos y líneas>

## Riesgo de regresión del fix
<qué otras áreas podrían afectarse>

## Asignación sugerida
<rol: backend-dev | frontend-dev | node-specialist | ...>

## Evidencia adjunta
- Scripts de repro: <ruta en ~/tns-debug/>
- Logs: <fragmentos relevantes>
