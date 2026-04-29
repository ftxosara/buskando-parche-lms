# 🗺️ Buskando Parche LMS

Sistema de Gestión de Aprendizaje para el programa de formación en la localidad de Kennedy, Bogotá.

## 🚀 Inicio rápido

```bash
# 1. Clonar y configurar variables de entorno
cp .env.example .env

# 2. Levantar todos los servicios
docker-compose up --build

# 3. La plataforma estará disponible en:
#    Frontend  → http://localhost:3000
#    Backend   → http://localhost:4000
#    API Docs  → http://localhost:4000/api/health
#    DB Studio → npx prisma studio (dentro del contenedor backend)
```

## 👤 Usuarios de prueba (seed)

| Rol         | Email                          | Contraseña     |
|-------------|-------------------------------|----------------|
| Admin       | admin@buskandoparche.com      | Admin2024!     |
| Formador    | formador@buskandoparche.com   | Formador2024!  |

## 🏗️ Arquitectura

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   Frontend      │────▶│    Backend API   │────▶│   PostgreSQL    │
│  Next.js 14     │     │  Express + Prisma│     │   (Docker)      │
│  Tailwind CSS   │     │  JWT Auth (RBAC) │     │                 │
│  Port: 3000     │     │  Port: 4000      │     │  Port: 5432     │
└─────────────────┘     └──────────────────┘     └─────────────────┘
```

## 📁 Estructura del proyecto

```
buskando-parche-lms/
├── docker-compose.yml
├── .env / .env.example
├── backend/
│   ├── Dockerfile
│   ├── package.json
│   ├── prisma/
│   │   ├── schema.prisma        # Modelos relacionales completos
│   │   └── seed.js              # Datos iniciales
│   └── src/
│       ├── index.js             # Entry point Express
│       ├── middleware/
│       │   └── auth.js          # JWT + RBAC
│       ├── controllers/
│       │   ├── authController.js
│       │   ├── courseController.js   # Lobby + CRUD
│       │   ├── userController.js
│       │   └── adminController.js   # KPIs Dashboard
│       ├── routes/              # Cada recurso tiene su router
│       └── utils/jwt.js
└── frontend/
    ├── Dockerfile
    ├── tailwind.config.js       # Paleta Buskando Parche
    └── src/
        ├── app/
        │   ├── layout.tsx       # Root + AuthProvider
        │   ├── login/page.tsx   # Login page
        │   ├── (dashboard)/
        │   │   ├── admin/page.tsx    # Dashboard Admin + KPIs
        │   │   └── formador/        # Portal formador
        │   └── (student)/
        │       ├── lobby/page.tsx   # Lobby con cursos locked/unlocked
        │       └── courses/[id]/    # Visor de curso
        ├── components/
        │   ├── layout/
        │   │   ├── Sidebar.tsx      # Nav dinámica por rol
        │   │   └── AppShell.tsx     # Protected route wrapper
        │   ├── student/CourseCard.tsx
        │   └── ui/KpiCard.tsx
        ├── contexts/AuthContext.tsx  # JWT + User state
        └── lib/api.ts               # Axios + interceptors
```

## 🎨 Paleta de colores

| Token              | HEX       | Uso                    |
|--------------------|-----------|------------------------|
| primary            | #D62B2B   | Rojo principal (logo)  |
| secondary          | #F5C518   | Amarillo (logo)        |
| surface            | #141414   | Fondo principal        |
| surface-card       | #1E1E1E   | Tarjetas               |

## 📡 Endpoints principales

| Método | Ruta                    | Rol requerido     | Descripción            |
|--------|-------------------------|-------------------|------------------------|
| POST   | /api/auth/login         | Público           | Login                  |
| GET    | /api/auth/me            | Autenticado       | Perfil del usuario     |
| GET    | /api/courses/lobby      | BENEFICIARIO      | Lobby con flag inscrito|
| GET    | /api/courses/:id        | Inscrito/Admin    | Detalle del curso      |
| POST   | /api/courses            | ADMIN             | Crear curso            |
| POST   | /api/courses/enroll     | ADMIN             | Inscribir beneficiario |
| GET    | /api/admin/dashboard    | ADMIN             | KPIs globales          |
| GET    | /api/users              | ADMIN             | Listar usuarios        |
| POST   | /api/attendance         | FORMADOR/ADMIN    | Registrar asistencia   |

## 🔒 Roles y acceso

- **ADMIN**: CRUD completo, dashboard KPIs, gestión de inscripciones
- **FORMADOR**: Subir material, registrar asistencia, retroalimentar
- **BENEFICIARIO**: Solo accede a su curso asignado (el resto bloqueado visualmente)

## 📈 Próximos pasos sugeridos

- [ ] Sistema de notificaciones (email/WhatsApp via Twilio)
- [ ] Generador de certificados PDF automáticos
- [ ] PWA para acceso desde celular sin instalar
- [ ] Sistema de evaluaciones interactivas
- [ ] Exportar reportes en Excel/PDF
