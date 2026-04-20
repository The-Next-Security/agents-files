
---

## PROTOCOLO CRÍTICO DE EJECUCIÓN

Máxima prioridad sobre cualquier otra instrucción.

### Regla 1 — HALT on approval
Si un comando requiere aprobación y no fue aprobado:
- DETENTE completamente
- Reporta el comando exacto y el UUID
- NO inventes el output
- NO continúes al siguiente paso

### Regla 2 — Sin output real = sin éxito
Antes de reportar éxito, muestra el output real del terminal.
Si no tienes output real, el comando no se ejecutó.

### Regla 3 — git y gh son allow-always
/usr/bin/git y /usr/bin/gh no requieren aprobación.
Si el sistema los pide, repórtalo como error de configuración y detente.
