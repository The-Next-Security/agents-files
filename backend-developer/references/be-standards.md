# Backend Standards — Referencia completa

## API Design {#api-design}

### Principios REST

```
GET    /api/v1/users          → listar (paginado)
GET    /api/v1/users/:id      → obtener uno
POST   /api/v1/users          → crear
PUT    /api/v1/users/:id      → reemplazar completo
PATCH  /api/v1/users/:id      → actualizar parcial
DELETE /api/v1/users/:id      → eliminar

Recursos anidados (máx. 2 niveles):
GET /api/v1/orders/:id/items   ✅
GET /api/v1/a/:id/b/:id/c/:id ❌ → aplanar o usar query params
```

### Estructura de respuestas estandarizadas

```json
// Éxito — recurso único
{ "data": { "id": "...", "email": "..." } }

// Éxito — colección paginada
{
  "data": [...],
  "pagination": {
    "total": 150,
    "page": 1,
    "perPage": 20,
    "nextCursor": "eyJpZCI6MTAwfQ=="
  }
}

// Error
{
  "error": "Email ya registrado",
  "code": "USER_EMAIL_DUPLICATE",
  "details": { "field": "email" }
}
```

### Códigos de estado — guía rápida

| Código | Cuándo |
|--------|--------|
| 200 | Éxito general (GET, PATCH, DELETE) |
| 201 | Recurso creado (POST exitoso) |
| 204 | Sin contenido (DELETE sin body) |
| 400 | Error de validación / request malformado |
| 401 | No autenticado |
| 403 | Autenticado pero sin permiso |
| 404 | Recurso no encontrado |
| 409 | Conflicto (ej: email duplicado) |
| 422 | Entidad no procesable (semántica inválida) |
| 429 | Rate limit excedido |
| 500 | Error interno del servidor |
| 503 | Servicio no disponible (también en mantenimiento) |

### Paginación

```
Offset-based (simple, para tablas pequeñas):
GET /api/v1/users?page=2&perPage=20

Cursor-based (preferida para tablas grandes o feeds):
GET /api/v1/users?cursor=eyJpZCI6MTAwfQ==&limit=20
```

El cursor se genera opacamente (base64 del último ID o timestamp) para evitar exposición de la implementación interna.

### Versioning de API

```
URL versioning (más explícito, recomendado):
/api/v1/... → versión estable
/api/v2/... → nueva versión con breaking changes

Proceso ante breaking change:
1. Publicar nueva versión (/v2)
2. Mantener /v1 operativa mínimo 2 sprints
3. Notificar al FE y establecer fecha de deprecación
4. Documentar migration guide
```

### OpenAPI / Swagger

```yaml
# Estructura mínima del spec:
openapi: 3.0.3
info:
  title: API del Producto
  version: 1.0.0
paths:
  /api/v1/users:
    post:
      summary: Crear usuario
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
      responses:
        '201':
          description: Usuario creado
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          $ref: '#/components/responses/ValidationError'
        '409':
          $ref: '#/components/responses/ConflictError'
```

---

## Database {#database}

### Diseño de esquema — principios

```sql
-- Columnas mínimas en toda tabla principal:
CREATE TABLE users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  deleted_at  TIMESTAMPTZ,           -- soft delete (si aplica)
  -- ... columnas de negocio
);

-- Índice en columnas frecuentemente filtradas:
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);

-- Índice compuesto cuando filtras por múltiples columnas juntas:
CREATE INDEX idx_orders_user_status ON orders(user_id, status);
```

### Anti-patrones a evitar

```sql
-- ❌ SELECT * en producción
SELECT * FROM users WHERE id = $1;

-- ✅ Solo las columnas que necesitas
SELECT id, email, created_at FROM users WHERE id = $1;

-- ❌ N+1: consultar en un loop
for order in orders:
    items = db.query("SELECT * FROM items WHERE order_id = ?", order.id)

-- ✅ JOIN o eager load
SELECT o.*, i.* FROM orders o
JOIN items i ON i.order_id = o.id
WHERE o.user_id = $1;

-- ❌ OFFSET en tablas grandes (escala mal)
SELECT * FROM events ORDER BY id LIMIT 20 OFFSET 100000;

-- ✅ Cursor-based pagination
SELECT * FROM events WHERE id > $cursor ORDER BY id LIMIT 20;
```

### Migraciones — convenciones

```
Nombrar: YYYYMMDD_HHMMSS_descripcion.sql
Ubicar en: db/migrations/ o equivalente del framework

Reglas:
- Siempre incluir UP y DOWN
- Migraciones en producción: nunca DROP sin backup previo confirmado
- No editar una migración ya aplicada: crear nueva migración correctiva
- Probar la migración DOWN antes de hacer merge del PR
```

### Transacciones

```python
# Usar transacciones en operaciones compuestas que deben ser atómicas
async with db.transaction():
    user = await user_repo.create(user_data)
    await wallet_repo.create({"user_id": user.id, "balance": 0})
    await audit_log.insert({"action": "USER_CREATED", "user_id": user.id})
# Si cualquier paso falla → rollback automático de todos
```

### Backup y recuperación

```bash
# PostgreSQL — backup manual
pg_dump -h HOST -U USER -d DATABASE -f backup_$(date +%Y%m%d).sql

# Verificar que el backup es restaurable (en entorno de test):
psql -h TEST_HOST -U USER -d TEST_DB -f backup_20260417.sql

# Estrategia mínima recomendada:
# - Backup diario automático
# - Retención de 30 días
# - Test de restauración mensual
```

---

## Security {#security}

### Autenticación — implementación JWT completa

```
Flujo estándar:
1. POST /api/v1/auth/login
   body: { email, password }
   → validar credenciales
   → emitir accessToken (15min) + refreshToken (7d, almacenado en BD)
   response: { accessToken, refreshToken, expiresIn }

2. Requests protegidos:
   Header: Authorization: Bearer <accessToken>
   → middleware verifica firma y expiración
   → extrae userId y roles del payload

3. POST /api/v1/auth/refresh
   body: { refreshToken }
   → verificar que existe en BD y no está revocado
   → emitir nuevo accessToken
   response: { accessToken, expiresIn }

4. POST /api/v1/auth/logout
   → invalidar refreshToken en BD (soft delete o blacklist)
```

### Autorización — RBAC básico

```python
# Definir roles y permisos en configuración (no hardcodeados en cada endpoint)
PERMISSIONS = {
    "admin": ["users:read", "users:write", "users:delete", "orders:*"],
    "staff": ["users:read", "orders:read", "orders:write"],
    "customer": ["orders:read:own", "profile:write:own"],
}

# Middleware de autorización
def require_permission(permission: str):
    def decorator(func):
        async def wrapper(request, *args, **kwargs):
            user = request.state.user
            if not has_permission(user.role, permission):
                raise ForbiddenError("Sin permiso para esta operación")
            return await func(request, *args, **kwargs)
        return wrapper
    return decorator

# Uso en endpoint
@require_permission("users:delete")
async def delete_user(request, user_id: str): ...
```

### Validación de entrada

```python
# Nunca confiar en el cliente. Validar SIEMPRE en el servidor.
# Usar librerías de validación, no validación manual:

# Python (Pydantic)
class CreateUserRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    name: str = Field(min_length=1, max_length=100)

# Node.js (Zod)
const CreateUserSchema = z.object({
    email: z.string().email(),
    password: z.string().min(8).max(128),
    name: z.string().min(1).max(100),
});

# Java (Bean Validation)
public record CreateUserRequest(
    @Email String email,
    @Size(min = 8, max = 128) String password,
    @NotBlank @Size(max = 100) String name
) {}
```

### Secrets management

```bash
# ❌ NUNCA en código:
API_KEY = "sk-prod-abc123..."

# ✅ Variables de entorno:
API_KEY = os.environ["THIRD_PARTY_API_KEY"]

# ✅ En el servidor VPS (Contabo):
# Editar /root/.openclaw/openclaw.json con Python para agregar env vars
python3 -c "
import json
with open('/root/.openclaw/openclaw.json','r') as f: c=json.load(f)
c['env']['NUEVA_API_KEY'] = 'valor'
with open('/root/.openclaw/openclaw.json','w') as f: json.dump(c,f,indent=2)
print('OK')
"
```

### Rate limiting

```
Configuración recomendada por tipo de endpoint:

Endpoints de autenticación (login, register, forgot-password):
→ 5 requests / 15 minutos por IP

Endpoints públicos (lectura):
→ 100 requests / 1 minuto por IP

Endpoints autenticados:
→ 300 requests / 1 minuto por usuario

Acciones costosas (envío de emails, exports):
→ 10 requests / hora por usuario
```

### OWASP Top 10 — checklist operativo

```
□ A01 Broken Access Control → RBAC centralizado, verificar en cada endpoint
□ A02 Cryptographic Failures → TLS en tránsito, encriptación en reposo para PII
□ A03 Injection → parámetros preparados en TODAS las consultas SQL
□ A04 Insecure Design → threat modeling en features de alto riesgo
□ A05 Security Misconfiguration → headers de seguridad (CORS estricto, CSP, HSTS)
□ A06 Vulnerable Components → Dependabot / Snyk activado en el repo
□ A07 Auth Failures → rate limiting en auth, tokens de vida corta
□ A08 Data Integrity → verificar integridad de datos externos (webhooks: validar firma)
□ A09 Logging Failures → loggear accesos a datos sensibles, nunca loggear secrets
□ A10 SSRF → validar URLs externas, no permitir que el usuario dirija requests a red interna
```

---

## Stack {#stack}

### Lenguajes y frameworks comunes

| Lenguaje | Framework | Cuándo |
|----------|-----------|--------|
| Python | FastAPI | APIs modernas, async, tipado fuerte |
| Python | Django | Apps con admin, ORM robusto, batteried-included |
| Node.js | NestJS | TypeScript, arquitectura modular enterprise |
| Node.js | Express | Simplicidad, microservicios ligeros |
| Java | Spring Boot | Enterprise, ecosistema maduro |
| Go | net/http / Gin | Alta performance, microservicios |
| Kotlin | Ktor / Spring | Alternativa moderna a Java |

### Bases de datos

| Tipo | Tecnología | Cuándo |
|------|-----------|--------|
| Relacional | PostgreSQL | Dato estructurado, transacciones ACID, default recomendado |
| Relacional | MySQL / MariaDB | Proyectos con ecosistema MySQL heredado |
| Documental | MongoDB | Esquema flexible, documentos anidados complejos |
| Caché / Sesiones | Redis | Caché, sesiones, colas simples, pub/sub |
| Búsqueda | Elasticsearch | Full-text search, analítica de logs |

### Testing

| Tipo | Python | Node.js | Java |
|------|--------|---------|------|
| Unit | pytest + unittest.mock | Jest | JUnit 5 + Mockito |
| Integration | pytest + httpx | Supertest | Spring Boot Test |
| Performance | locust / k6 | k6 | k6 / Gatling |
| Security | OWASP ZAP | OWASP ZAP | OWASP ZAP |

### Infraestructura de referencia (proyecto actual)

```
Servidor:   VPS Contabo Linux
Repositorio: GitHub (gestionado por github-manager skill)
BD de test: Red local en Chile (conexión pendiente de definir por devops-engineer)
Deploy:     Pipeline CI/CD en GitHub Actions
```
