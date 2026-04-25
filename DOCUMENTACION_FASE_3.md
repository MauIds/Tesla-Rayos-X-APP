# Proyecto Guiado — Fase III: Tesla Rayos X & Control Biológico

## 1. Introducción y Alcance

La Fase III comprende el análisis de requerimientos, diseño, construcción, pruebas e integración de una aplicación móvil para la empresa **Tesla Rayos X & Control Biológico**. El sistema digitaliza el proceso de solicitud y gestión de citas de servicio, reemplazando flujos manuales por una plataforma con autenticación, control de roles y actualización en tiempo real.

### 1.1 Objetivos del Sistema

| Objetivo | Descripción |
|---|---|
| Gestión de solicitudes | Usuarios registrados crean, consultan y cancelan citas de servicio |
| Panel administrativo | Rol `admin` aprueba o rechaza solicitudes desde la misma app |
| Autenticación segura | Acceso mediante correo/contraseña o Google OAuth (flujo PKCE) |
| Trazabilidad | Historial de solicitudes con estado `Pendiente / Aprobado / Rechazado` |

### 1.2 Requerimientos Funcionales

| ID | Requerimiento | Prioridad |
|---|---|---|
| RF01 | Registro e inicio de sesión (email + Google) | Alta |
| RF02 | Creación de solicitud de cita con servicio, fecha, hora y datos del cliente | Alta |
| RF03 | Listado en tiempo real de solicitudes propias | Alta |
| RF04 | Control de roles: `client` y `admin` | Alta |
| RF05 | Panel admin con filtros por estado y acciones Aprobar/Rechazar | Alta |
| RF06 | Perfil de usuario editable (nombre, datos de cuenta) | Media |
| RF07 | Recuperación de contraseña por correo | Media |
| RF08 | Notificación visual (badge) de solicitudes pendientes en admin | Media |

### 1.3 Requerimientos No Funcionales

- **Seguridad:** Row Level Security en Supabase — cada usuario accede solo a sus propios registros.
- **Tiempo real:** Cambios de estado se reflejan sin recargar la app vía Supabase `.stream()`.
- **Escalabilidad:** Backend serverless (Supabase/PostgreSQL) sin infraestructura propia.
- **Idioma:** Toda la interfaz en español; errores de autenticación traducidos al usuario final.

---

## 2. Diseño de la Solución

### 2.1 Diseño Visual — Prototipado en Figma

El prototipo de alta fidelidad fue elaborado en **Figma** antes de iniciar la construcción, cubriendo:

- Flujos diferenciados por rol: cliente (Nueva Cita + Mis Solicitudes) y administrador (+ Panel Admin).
- Sistema de diseño con paleta **Material 3** (`AppColors`), tipografía **Manrope** (Google Fonts) y componentes reutilizables (tarjetas, chips de estado, selectores de fecha/hora).
- Prototipo interactivo para validar la navegación y la experiencia de usuario antes de escribir código.

> **Enlace al prototipo Figma:** `[Insertar URL del prototipo aquí]`

### 2.2 Diseño Funcional — Arquitectura Lógica y Modelo Relacional

#### Arquitectura de la aplicación

La app sigue una **arquitectura por features con separación domain/data/presentation**:

```
lib/
├── core/theme/          → Tokens de diseño (colores, tipografía)
├── features/
│   ├── auth/            → Autenticación (email + Google OAuth)
│   ├── nueva_cita/      → Formulario de solicitud de cita
│   ├── mis_solicitudes/ → Listado en tiempo real de solicitudes propias
│   ├── profile/         → Perfil y datos del usuario autenticado
│   └── admin/           → Panel de gestión para rol admin
└── shared/routing/      → GoRouter con redirección basada en estado de auth
```

#### Modelo Relacional (Supabase / PostgreSQL)

| Tabla | Columna | Tipo | Restricción |
|---|---|---|---|
| `profiles` | `id` | UUID PK | FK → `auth.users.id` ON DELETE CASCADE |
| | `email` | TEXT | |
| | `display_name` | TEXT | |
| | `role` | TEXT | `'client'` (default) \| `'admin'` |
| | `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT NOW() |
| `requests` | `id` | UUID PK | DEFAULT `gen_random_uuid()` |
| | `user_id` | UUID | FK → `auth.users.id` ON DELETE CASCADE |
| | `servicio` | TEXT | NOT NULL |
| | `servicio_icon` | TEXT | NOT NULL |
| | `nombre_cliente` | TEXT | NOT NULL |
| | `fecha` | DATE | NOT NULL |
| | `hora` | TEXT | Opcional |
| | `descripcion` | TEXT | Opcional |
| | `telefono` | TEXT | Opcional |
| | `estado` | TEXT | CHECK (`Pendiente` \| `Aprobado` \| `Rechazado`) |
| | `created_at` | TIMESTAMPTZ | NOT NULL DEFAULT NOW() |

**Relaciones:**

```
auth.users  1 ──< profiles   (1 perfil por usuario, creado por trigger)
auth.users  1 ──< requests   (N solicitudes por usuario)
```

**Seguridad de datos:** Row Level Security habilitada en ambas tablas. Los usuarios solo pueden leer y modificar sus propios registros. El rol `admin` requiere una política permisiva adicional en `requests` para acceso total.

**Trigger automático:** Al crear un usuario en `auth.users`, la función `handle_new_user()` inserta automáticamente un registro en `profiles` con `role = 'client'`.

---

## 3. Desarrollo y Construcción — Stack Tecnológico

### 3.1 Frontend: Flutter + Dart

| Paquete | Versión | Rol |
|---|---|---|
| `flutter` | SDK | Framework UI multiplataforma |
| `flutter_riverpod` | ^2.5.1 | Gestión de estado global |
| `go_router` | ^14.2.7 | Navegación declarativa con redirección por auth |
| `google_fonts` | ^6.2.1 | Tipografía Manrope |
| `flutter_dotenv` | ^5.1.0 | Carga de variables de entorno desde `assets/.env` |
| `intl` | ^0.19.0 | Formateo de fechas en español |
| `gap` | ^3.0.1 | Espaciado semántico en layouts |

**Patrones de estado:**
- `StateNotifierProvider<AuthNotifier, AuthState>` — ciclo de vida de sesión.
- `StreamProvider` — solicitudes en tiempo real vía Supabase `.stream()`.
- Estado de auth modelado con clases selladas: `AuthInitial | AuthLoading | AuthAuthenticated | AuthError | AuthUnauthenticated`.

### 3.2 Backend: Supabase (Firebase equivalente)

| Servicio Supabase | Uso en el proyecto |
|---|---|
| **Auth** | Registro, login por email y Google OAuth (PKCE) |
| **PostgreSQL** | Tablas `profiles` y `requests` con RLS |
| **Realtime** | Stream de cambios en `requests` para actualización instantánea |
| **Row Level Security** | Aislamiento de datos por usuario a nivel de base de datos |

> Las credenciales (`SUPABASE_URL`, `SUPABASE_ANON_KEY`) se cargan desde `assets/.env` (excluido de git). El esquema completo se encuentra en `supabase_migrations.sql`.

---

## 4. Aseguramiento de Calidad (QA)

### 4.1 Pruebas Visuales

Validan que la interfaz construida coincide con el diseño aprobado en Figma.

| Criterio | Método |
|---|---|
| Consistencia de colores (`AppColors`) | Comparación con tokens de diseño definidos en `core/theme/app_colors.dart` |
| Tipografía (Manrope, pesos y tamaños) | Inspección manual contra especificaciones de Figma |
| Responsividad en distintas densidades | Prueba en emuladores con diferentes resoluciones |
| Estados de UI (cargando, vacío, error) | Forzar cada estado en desarrollo y verificar presentación |
| Badges de notificación en barra inferior | Verificar conteo correcto al crear/actualizar solicitudes |

### 4.2 Pruebas Funcionales

Validan que cada flujo de negocio opera según los requerimientos.

| Caso de prueba | Resultado esperado |
|---|---|
| Login con credenciales correctas | Redirige a `/home`, tab activo según rol |
| Login con credenciales incorrectas | Muestra mensaje traducido al español, sin acceso |
| Registro con correo ya existente | Error `'Este correo ya está registrado'` |
| Crear solicitud con todos los campos | Registro persiste en Supabase, aparece en Mis Solicitudes |
| Solicitud visible en panel admin | Admin ve solicitud de cualquier usuario en tab "Pendientes" |
| Admin aprueba solicitud | `estado` cambia a `'Aprobado'`, cliente ve cambio en tiempo real |
| Admin rechaza solicitud | `estado` cambia a `'Rechazado'`, snackbar de confirmación |
| Usuario sin rol admin | Tab Admin no aparece en barra inferior |
| Recuperación de contraseña | Correo enviado, estado retorna a `AuthUnauthenticated` |
| Cierre de sesión | `onAuthStateChange` dispara `AuthUnauthenticated`, router redirige a `/login` |

---

## 5. Integración y Resultados

### 5.1 Pasos de Puesta en Marcha

```bash
# 1. Clonar el repositorio
git clone <url-del-repositorio>
cd teslarayosx

# 2. Instalar dependencias
flutter pub get

# 3. Configurar variables de entorno
# Crear archivo assets/.env con:
# SUPABASE_URL=https://<proyecto>.supabase.co
# SUPABASE_ANON_KEY=<anon-key>

# 4. Ejecutar migraciones en Supabase
# Copiar contenido de supabase_migrations.sql
# Pegar en: Supabase Dashboard > SQL Editor > New query > Run

# 5. Ejecutar la app
flutter run
```

### 5.2 Evidencias — Capturas de Pantalla

> Insertar capturas de la aplicación funcional en las secciones correspondientes.

| Vista | Captura |
|---|---|
| Pantalla de login | `![Login](./screenshots/login.png)` |
| Registro de usuario | `![Signup](./screenshots/signup.png)` |
| Nueva solicitud (formulario) | `![Nueva Cita](./screenshots/nueva_cita.png)` |
| Mis solicitudes (tiempo real) | `![Mis Solicitudes](./screenshots/mis_solicitudes.png)` |
| Panel administrador | `![Admin](./screenshots/admin.png)` |
| Detalle de solicitud | `![Detalle](./screenshots/detalle.png)` |
| Perfil de usuario | `![Perfil](./screenshots/perfil.png)` |

---

## 6. Estatus de Entregables

| Entregable | Descripción | Estado |
|---|---|---|
| Documento de respaldo técnico | Este archivo `DOCUMENTACION_FASE_3.md` con análisis, diseño, stack, QA e integración | - [ ] Pendiente revisión |
| Archivos fuente del código | Repositorio completo (Flutter app + `supabase_migrations.sql` + assets) | - [ ] Pendiente subida |
| Certificado de LinkedIn Learning | Certificado del curso asociado al stack tecnológico (Flutter / Supabase / Firebase) | - [ ] Pendiente adjuntar |
| Aplicación funcional | App instalable en Android con todos los RF implementados y probados | - [ ] Pendiente build final |

---

*Documento técnico — Fase III del Proyecto Guiado: Tesla Rayos X & Control Biológico.*
