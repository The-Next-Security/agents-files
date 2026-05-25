# Git Governance Policy

## Objetivo
Definir el corredor permitido para autonomía controlada sobre Git y PRs en OpenClaw.

## Permitido automáticamente
- git status
- git checkout -b <feature-branch>
- git add <files>
- git commit -m "<message>"
- git push origin <feature-branch>
- gh pr create --base main --head <feature-branch>

## Permitido con evaluación previa de governance-wrapper
- cambios sobre múltiples archivos sensibles
- modificaciones en skills de seguridad o gobernanza
- cambios que afecten backlog, políticas o trazabilidad
- operaciones Git con efectos laterales no triviales

## Bloqueado
- git push --force
- commits automáticos sobre main
- git checkout main para modificar contenido
- git merge automático a main
- git rebase destructivo
- git reset --hard sobre ramas compartidas
- borrado de ramas remotas sin contexto aprobado
- operaciones fuera del repo permitido

## Reglas operativas
- main es rama protegida de facto
- toda modificación autónoma debe salir por feature/* o fix/*
- todo cambio relevante debe terminar en PR
- cambios mínimos, auditables y trazables
- ante duda: bloquear o escalar antes que permitir

## Logging esperado
Toda acción relevante debe registrar:
- timestamp
- actor
- comando o acción
- branch
- repo
- decisión de governance
- resultado
