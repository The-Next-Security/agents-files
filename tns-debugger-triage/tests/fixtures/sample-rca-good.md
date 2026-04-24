# RCA — The-Next-Security/sample-repo — Issue #42

## Metadata
- Fecha RCA: 2026-04-25T12:00:00Z
- Autor: Debugger Agent
- Link al issue: https://github.com/The-Next-Security/sample-repo/issues/42
- Severidad estimada: medium
- Estado del RCA: completo

## Síntoma observado
El endpoint `/api/users/:id` devuelve 500 cuando el id no es numérico.

## Reproducción determinística
1. Levantar servidor local con `npm run dev`.
2. `curl -i http://localhost:3000/api/users/abc`
3. Esperado: 400 Bad Request.
4. Obtenido: 500 Internal Server Error con stack trace.

## Root cause identificado
El handler pasa el id directo a Prisma sin validar tipo. Prisma
lanza PrismaClientKnownRequestError que no está capturado.

## Commit culpable
abc12345 feat(users): add user lookup endpoint

## Propuesta de fix
Agregar validación de schema (zod) antes del handler.
Archivo: src/routes/users.ts líneas 15-22.

## Riesgo de regresión del fix
Bajo. El cambio solo agrega validación; no altera happy path.

## Asignación sugerida
backend-dev

## Evidencia adjunta
- Scripts de repro: ~/tns-debug/rca-sample-42/repro.sh
- Logs: stack trace de Prisma en server.log línea 1204.
