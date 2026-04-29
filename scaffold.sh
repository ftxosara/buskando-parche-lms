#!/usr/bin/env bash
# =============================================================================
# LMS "Buskando Parche" - Script de Scaffolding Completo
# Ejecutar: chmod +x scaffold.sh && ./scaffold.sh
# =============================================================================
set -e

ROOT="buskando-parche-lms"
echo "🚀 Creando estructura del proyecto: $ROOT"
mkdir -p $ROOT
cd $ROOT

# =============================================================================
# NIVEL RAÍZ
# =============================================================================
cat > .env.example << 'ENVEOF'
# ── Base de datos ──────────────────────────────────────────────────────────
POSTGRES_USER=buskando_user
POSTGRES_PASSWORD=supersecretpassword
POSTGRES_DB=buskando_lms
DATABASE_URL=postgresql://buskando_user:supersecretpassword@postgres:5432/buskando_lms

# ── JWT ────────────────────────────────────────────────────────────────────
JWT_SECRET=your_jwt_secret_change_in_production_min_32chars
JWT_EXPIRES_IN=7d

# ── Backend ────────────────────────────────────────────────────────────────
NODE_ENV=development
BACKEND_PORT=4000

# ── Frontend ───────────────────────────────────────────────────────────────
NEXT_PUBLIC_API_URL=http://localhost:4000/api
ENVEOF

cp .env.example .env

cat > docker-compose.yml << 'DCEOF'
version: '3.9'

services:
  # ──────────────────────────────────────────────────────────────────────────
  postgres:
    image: postgres:16-alpine
    container_name: buskando_postgres
    restart: unless-stopped
    environment:
      POSTGRES_USER: ${POSTGRES_USER}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
      POSTGRES_DB: ${POSTGRES_DB}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB}"]
      interval: 10s
      timeout: 5s
      retries: 5

  # ──────────────────────────────────────────────────────────────────────────
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: buskando_backend
    restart: unless-stopped
    depends_on:
      postgres:
        condition: service_healthy
    env_file: .env
    ports:
      - "4000:4000"
    volumes:
      - ./backend/src:/app/src
      - ./backend/prisma:/app/prisma
      - uploads:/app/uploads
    command: >
      sh -c "npx prisma migrate deploy && npx prisma db seed && npm run dev"

  # ──────────────────────────────────────────────────────────────────────────
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: buskando_frontend
    restart: unless-stopped
    depends_on:
      - backend
    env_file: .env
    ports:
      - "3000:3000"
    volumes:
      - ./frontend/src:/app/src
      - ./frontend/public:/app/public

volumes:
  postgres_data:
  uploads:
DCEOF

echo "✅ docker-compose.yml creado"

# =============================================================================
# BACKEND
# =============================================================================
mkdir -p backend/src/{routes,controllers,middleware,utils,services}
mkdir -p backend/prisma/migrations
mkdir -p backend/uploads

cat > backend/Dockerfile << 'BEOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npx prisma generate
EXPOSE 4000
BEOF

cat > backend/package.json << 'PKGEOF'
{
  "name": "buskando-parche-backend",
  "version": "1.0.0",
  "description": "LMS Buskando Parche - Backend API",
  "main": "src/index.js",
  "scripts": {
    "dev": "nodemon src/index.js",
    "start": "node src/index.js",
    "migrate": "npx prisma migrate dev",
    "studio": "npx prisma studio"
  },
  "dependencies": {
    "@prisma/client": "^5.14.0",
    "bcryptjs": "^2.4.3",
    "cors": "^2.8.5",
    "dotenv": "^16.4.5",
    "express": "^4.19.2",
    "express-validator": "^7.1.0",
    "helmet": "^7.1.0",
    "jsonwebtoken": "^9.0.2",
    "morgan": "^1.10.0",
    "multer": "^1.4.5-lts.1",
    "winston": "^3.13.0"
  },
  "devDependencies": {
    "nodemon": "^3.1.4",
    "prisma": "^5.14.0"
  },
  "prisma": {
    "seed": "node prisma/seed.js"
  }
}
PKGEOF

# ── Prisma Schema ────────────────────────────────────────────────────────────
cat > backend/prisma/schema.prisma << 'SCHEOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ─── ENUMS ────────────────────────────────────────────────────────────────────
enum Role {
  ADMIN
  FORMADOR
  BENEFICIARIO
}

enum Gender {
  MASCULINO
  FEMENINO
  NO_BINARIO
  PREFIERO_NO_DECIR
}

enum PopulationGroup {
  EMPRENDEDOR
  MIPYME
  PRESTADOR_TURISTICO
  VICTIMA_CONFLICTO
  DISCAPACIDAD
  AFRODESCENDIENTE
  INDIGENA
  ADULTO_MAYOR
  OTRO
}

enum CourseModality {
  VIRTUAL
  PRESENCIAL
}

enum EnrollmentStatus {
  ACTIVO
  COMPLETADO
  INACTIVO
}

enum AttendanceStatus {
  PRESENTE
  AUSENTE
  EXCUSA
}

// ─── USERS ───────────────────────────────────────────────────────────────────
model User {
  id             String   @id @default(cuid())
  email          String   @unique
  passwordHash   String   @map("password_hash")
  role           Role     @default(BENEFICIARIO)

  // Info personal
  firstName      String   @map("first_name")
  lastName       String   @map("last_name")
  cedula         String   @unique
  phone          String?

  // Info socio-demográfica (trazabilidad del contrato)
  gender         Gender?
  populationGroup PopulationGroup? @map("population_group")
  upz            String?
  locality       String?
  entrepreneurshipStatus String? @map("entrepreneurship_status")
  birthDate      DateTime? @map("birth_date")

  // Timestamps
  createdAt      DateTime @default(now()) @map("created_at")
  updatedAt      DateTime @updatedAt @map("updated_at")
  isActive       Boolean  @default(true) @map("is_active")

  // Relaciones
  enrollments    Enrollment[]
  attendances    Attendance[]
  submissions    Submission[]
  forumPosts     ForumPost[]
  forumReplies   ForumReply[]
  coursesTeaching Course[] @relation("CourseFormador")

  @@map("users")
}

// ─── COURSES ─────────────────────────────────────────────────────────────────
model Course {
  id             String         @id @default(cuid())
  title          String
  description    String
  modality       CourseModality @default(VIRTUAL)
  coverImageUrl  String?        @map("cover_image_url")
  totalSessions  Int            @default(20) @map("total_sessions")
  isPublished    Boolean        @default(false) @map("is_published")

  formadorId     String?        @map("formador_id")
  formador       User?          @relation("CourseFormador", fields: [formadorId], references: [id])

  createdAt      DateTime       @default(now()) @map("created_at")
  updatedAt      DateTime       @updatedAt @map("updated_at")

  sessions       Session[]
  enrollments    Enrollment[]
  forumPosts     ForumPost[]

  @@map("courses")
}

// ─── SESSIONS (hasta 20 por curso) ───────────────────────────────────────────
model Session {
  id          String   @id @default(cuid())
  courseId    String   @map("course_id")
  course      Course   @relation(fields: [courseId], references: [id], onDelete: Cascade)

  title       String
  description String?
  order       Int      // 1..20
  scheduledAt DateTime? @map("scheduled_at")
  durationMin Int      @default(120) @map("duration_min")

  resources   Resource[]
  attendances Attendance[]
  submissions Submission[]

  createdAt   DateTime @default(now()) @map("created_at")

  @@unique([courseId, order])
  @@map("sessions")
}

// ─── RESOURCES (video, pdf, link) ────────────────────────────────────────────
model Resource {
  id        String   @id @default(cuid())
  sessionId String   @map("session_id")
  session   Session  @relation(fields: [sessionId], references: [id], onDelete: Cascade)

  title     String
  type      String   // "video" | "pdf" | "link" | "image"
  url       String
  order     Int      @default(0)

  createdAt DateTime @default(now()) @map("created_at")

  @@map("resources")
}

// ─── ENROLLMENTS ──────────────────────────────────────────────────────────────
model Enrollment {
  id        String           @id @default(cuid())
  userId    String           @map("user_id")
  user      User             @relation(fields: [userId], references: [id])
  courseId  String           @map("course_id")
  course    Course           @relation(fields: [courseId], references: [id])
  status    EnrollmentStatus @default(ACTIVO)

  enrolledAt  DateTime @default(now()) @map("enrolled_at")
  completedAt DateTime? @map("completed_at")

  certificateUrl String? @map("certificate_url")

  @@unique([userId, courseId])
  @@map("enrollments")
}

// ─── ATTENDANCE ───────────────────────────────────────────────────────────────
model Attendance {
  id        String           @id @default(cuid())
  userId    String           @map("user_id")
  user      User             @relation(fields: [userId], references: [id])
  sessionId String           @map("session_id")
  session   Session          @relation(fields: [sessionId], references: [id])
  status    AttendanceStatus @default(PRESENTE)
  notes     String?
  markedAt  DateTime         @default(now()) @map("marked_at")

  @@unique([userId, sessionId])
  @@map("attendances")
}

// ─── EVALUATIONS / SUBMISSIONS ────────────────────────────────────────────────
model Evaluation {
  id          String   @id @default(cuid())
  sessionId   String?  @map("session_id")
  courseId    String?  @map("course_id")
  title       String
  description String?
  maxScore    Float    @default(100) @map("max_score")
  passingScore Float   @default(60) @map("passing_score")

  questions   Json     // JSON array of question objects
  createdAt   DateTime @default(now()) @map("created_at")

  submissions Submission[]

  @@map("evaluations")
}

model Submission {
  id           String     @id @default(cuid())
  evaluationId String     @map("evaluation_id")
  evaluation   Evaluation @relation(fields: [evaluationId], references: [id])
  userId       String     @map("user_id")
  user         User       @relation(fields: [userId], references: [id])
  sessionId    String?    @map("session_id")
  session      Session?   @relation(fields: [sessionId], references: [id])

  answers      Json
  score        Float?
  feedback     String?
  submittedAt  DateTime   @default(now()) @map("submitted_at")
  gradedAt     DateTime?  @map("graded_at")

  @@map("submissions")
}

// ─── FORUM ────────────────────────────────────────────────────────────────────
model ForumPost {
  id        String       @id @default(cuid())
  courseId  String       @map("course_id")
  course    Course       @relation(fields: [courseId], references: [id])
  authorId  String       @map("author_id")
  author    User         @relation(fields: [authorId], references: [id])

  title     String
  body      String
  isPinned  Boolean      @default(false) @map("is_pinned")
  createdAt DateTime     @default(now()) @map("created_at")
  updatedAt DateTime     @updatedAt @map("updated_at")

  replies   ForumReply[]

  @@map("forum_posts")
}

model ForumReply {
  id        String    @id @default(cuid())
  postId    String    @map("post_id")
  post      ForumPost @relation(fields: [postId], references: [id], onDelete: Cascade)
  authorId  String    @map("author_id")
  author    User      @relation(fields: [authorId], references: [id])

  body      String
  createdAt DateTime  @default(now()) @map("created_at")

  @@map("forum_replies")
}
SCHEOF

# ── Seed ─────────────────────────────────────────────────────────────────────
cat > backend/prisma/seed.js << 'SEEDEOF'
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Admin
  const adminPwd = await bcrypt.hash('Admin2024!', 12);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@buskandoparche.com' },
    update: {},
    create: {
      email: 'admin@buskandoparche.com',
      passwordHash: adminPwd,
      role: 'ADMIN',
      firstName: 'Admin',
      lastName: 'Sistema',
      cedula: '1000000001',
      phone: '3001234567',
    },
  });

  // Formador
  const formadorPwd = await bcrypt.hash('Formador2024!', 12);
  const formador = await prisma.user.upsert({
    where: { email: 'formador@buskandoparche.com' },
    update: {},
    create: {
      email: 'formador@buskandoparche.com',
      passwordHash: formadorPwd,
      role: 'FORMADOR',
      firstName: 'Carlos',
      lastName: 'Pérez',
      cedula: '1000000002',
      phone: '3009876543',
    },
  });

  // Cursos iniciales
  const courses = [
    {
      title: 'Marketing Digital Turístico',
      description: 'Aprende a posicionar tu negocio turístico en medios digitales: redes sociales, SEO local y campañas digitales.',
      modality: 'VIRTUAL',
      totalSessions: 20,
      isPublished: true,
    },
    {
      title: 'Inglés en el Turismo',
      description: 'Comunicación básica e intermedia en inglés orientada a la atención de turistas internacionales.',
      modality: 'VIRTUAL',
      totalSessions: 20,
      isPublished: true,
    },
    {
      title: 'Gestión Empresarial',
      description: 'Herramientas de planeación, finanzas básicas y estructura organizacional para MiPymes y emprendedores.',
      modality: 'PRESENCIAL',
      totalSessions: 20,
      isPublished: true,
    },
    {
      title: 'Turismo Sostenible',
      description: 'Principios de sostenibilidad, buenas prácticas ambientales y certificación para prestadores turísticos.',
      modality: 'PRESENCIAL',
      totalSessions: 20,
      isPublished: true,
    },
  ];

  for (const courseData of courses) {
    const course = await prisma.course.upsert({
      where: { id: courseData.title.toLowerCase().replace(/ /g, '-') },
      update: {},
      create: {
        ...courseData,
        formadorId: formador.id,
      },
    }).catch(async () => {
      return prisma.course.create({ data: { ...courseData, formadorId: formador.id } });
    });

    // Crear 20 sesiones por curso
    for (let i = 1; i <= 20; i++) {
      await prisma.session.upsert({
        where: { courseId_order: { courseId: course.id, order: i } },
        update: {},
        create: {
          courseId: course.id,
          title: `Sesión ${i}`,
          description: `Contenido de la sesión ${i} del curso ${courseData.title}`,
          order: i,
        },
      });
    }
  }

  console.log('✅ Seed completado.');
  console.log('👤 Admin: admin@buskandoparche.com / Admin2024!');
  console.log('👤 Formador: formador@buskandoparche.com / Formador2024!');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
SEEDEOF

# ── Backend Entry Point ──────────────────────────────────────────────────────
cat > backend/src/index.js << 'IDXEOF'
require('dotenv').config();
const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const morgan = require('morgan');
const path = require('path');

const authRoutes = require('./routes/auth');
const userRoutes = require('./routes/users');
const courseRoutes = require('./routes/courses');
const sessionRoutes = require('./routes/sessions');
const attendanceRoutes = require('./routes/attendance');
const forumRoutes = require('./routes/forum');
const adminRoutes = require('./routes/admin');

const app = express();

// ── Security & Middleware ──────────────────────────────────────────────────
app.use(helmet());
app.use(cors({ origin: process.env.FRONTEND_URL || '*', credentials: true }));
app.use(express.json({ limit: '10mb' }));
app.use(morgan('dev'));
app.use('/uploads', express.static(path.join(__dirname, '..', 'uploads')));

// ── Routes ────────────────────────────────────────────────────────────────
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/courses', courseRoutes);
app.use('/api/sessions', sessionRoutes);
app.use('/api/attendance', attendanceRoutes);
app.use('/api/forum', forumRoutes);
app.use('/api/admin', adminRoutes);

// ── Health Check ──────────────────────────────────────────────────────────
app.get('/api/health', (_, res) => res.json({ status: 'OK', version: '1.0.0' }));

// ── 404 ───────────────────────────────────────────────────────────────────
app.use((req, res) => res.status(404).json({ error: 'Ruta no encontrada' }));

// ── Error Handler ──────────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({ error: err.message || 'Error interno del servidor' });
});

const PORT = process.env.BACKEND_PORT || 4000;
app.listen(PORT, () => {
  console.log(`🚀 Backend corriendo en http://localhost:${PORT}`);
});
IDXEOF

# ── JWT Utils ────────────────────────────────────────────────────────────────
cat > backend/src/utils/jwt.js << 'JWTEOF'
const jwt = require('jsonwebtoken');

const SECRET = process.env.JWT_SECRET || 'fallback_secret_change_me';
const EXPIRES = process.env.JWT_EXPIRES_IN || '7d';

const sign = (payload) => jwt.sign(payload, SECRET, { expiresIn: EXPIRES });

const verify = (token) => jwt.verify(token, SECRET);

module.exports = { sign, verify };
JWTEOF

# ── Auth Middleware ──────────────────────────────────────────────────────────
cat > backend/src/middleware/auth.js << 'AUTHEOF'
const { verify } = require('../utils/jwt');
const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

/**
 * Verifica JWT y adjunta req.user
 */
const authenticate = async (req, res, next) => {
  try {
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer '))
      return res.status(401).json({ error: 'Token requerido' });

    const token = header.split(' ')[1];
    const payload = verify(token);

    const user = await prisma.user.findUnique({
      where: { id: payload.userId },
      select: { id: true, email: true, role: true, firstName: true, lastName: true, isActive: true },
    });

    if (!user || !user.isActive)
      return res.status(401).json({ error: 'Usuario no autorizado o inactivo' });

    req.user = user;
    next();
  } catch {
    return res.status(401).json({ error: 'Token inválido o expirado' });
  }
};

/**
 * Verifica roles. Uso: authorize('ADMIN', 'FORMADOR')
 */
const authorize = (...roles) => (req, res, next) => {
  if (!roles.includes(req.user?.role))
    return res.status(403).json({ error: 'No tienes permisos para esta acción' });
  next();
};

module.exports = { authenticate, authorize };
AUTHEOF

# ── Auth Controller ─────────────────────────────────────────────────────────
cat > backend/src/controllers/authController.js << 'ACTEOF'
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const { sign } = require('../utils/jwt');

const prisma = new PrismaClient();

const login = async (req, res) => {
  try {
    const { email, password } = req.body;
    if (!email || !password)
      return res.status(400).json({ error: 'Email y contraseña son requeridos' });

    const user = await prisma.user.findUnique({ where: { email: email.toLowerCase() } });
    if (!user || !user.isActive)
      return res.status(401).json({ error: 'Credenciales inválidas' });

    const valid = await bcrypt.compare(password, user.passwordHash);
    if (!valid)
      return res.status(401).json({ error: 'Credenciales inválidas' });

    const token = sign({ userId: user.id, role: user.role });

    return res.json({
      token,
      user: {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
      },
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al iniciar sesión' });
  }
};

const me = async (req, res) => {
  const user = await prisma.user.findUnique({
    where: { id: req.user.id },
    select: {
      id: true, email: true, firstName: true, lastName: true,
      role: true, cedula: true, phone: true, gender: true,
      populationGroup: true, upz: true, locality: true,
    },
  });
  return res.json(user);
};

module.exports = { login, me };
ACTEOF

# ── Course Controller ────────────────────────────────────────────────────────
cat > backend/src/controllers/courseController.js << 'CCEOF'
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Para el LOBBY del beneficiario:
 * Devuelve todos los cursos publicados con flag `isEnrolled`
 */
const getLobby = async (req, res) => {
  try {
    const userId = req.user.id;
    const courses = await prisma.course.findMany({
      where: { isPublished: true },
      include: {
        formador: { select: { firstName: true, lastName: true } },
        _count: { select: { enrollments: true, sessions: true } },
        enrollments: { where: { userId } },
      },
    });

    const data = courses.map((c) => ({
      id: c.id,
      title: c.title,
      description: c.description,
      modality: c.modality,
      coverImageUrl: c.coverImageUrl,
      totalSessions: c.totalSessions,
      formador: c.formador
        ? `${c.formador.firstName} ${c.formador.lastName}`
        : 'Por asignar',
      totalEnrolled: c._count.enrollments,
      isEnrolled: c.enrollments.length > 0,
      enrollmentStatus: c.enrollments[0]?.status ?? null,
    }));

    return res.json(data);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al cargar el lobby' });
  }
};

const getCourseDetail = async (req, res) => {
  try {
    const { id } = req.params;
    const userId = req.user.id;

    const enrollment = await prisma.enrollment.findUnique({
      where: { userId_courseId: { userId, courseId: id } },
    });

    // Beneficiarios solo pueden ver su curso asignado
    if (req.user.role === 'BENEFICIARIO' && !enrollment)
      return res.status(403).json({ error: 'No tienes acceso a este curso' });

    const course = await prisma.course.findUnique({
      where: { id },
      include: {
        sessions: {
          orderBy: { order: 'asc' },
          include: {
            resources: { orderBy: { order: 'asc' } },
            attendances: { where: { userId } },
          },
        },
        formador: { select: { firstName: true, lastName: true, email: true } },
      },
    });

    if (!course) return res.status(404).json({ error: 'Curso no encontrado' });

    return res.json({ ...course, enrollment });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al cargar el curso' });
  }
};

const createCourse = async (req, res) => {
  try {
    const { title, description, modality, totalSessions, formadorId } = req.body;
    const course = await prisma.course.create({
      data: { title, description, modality, totalSessions: totalSessions || 20, formadorId },
    });

    // Auto-crear sesiones
    const sessionData = Array.from({ length: course.totalSessions }, (_, i) => ({
      courseId: course.id,
      title: `Sesión ${i + 1}`,
      order: i + 1,
    }));
    await prisma.session.createMany({ data: sessionData });

    return res.status(201).json(course);
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al crear el curso' });
  }
};

const enrollUser = async (req, res) => {
  try {
    const { courseId, userId } = req.body;
    const enrollment = await prisma.enrollment.create({
      data: { courseId, userId },
    });
    return res.status(201).json(enrollment);
  } catch (err) {
    if (err.code === 'P2002')
      return res.status(409).json({ error: 'El usuario ya está inscrito en este curso' });
    return res.status(500).json({ error: 'Error al inscribir usuario' });
  }
};

module.exports = { getLobby, getCourseDetail, createCourse, enrollUser };
CCEOF

# ── Admin Controller ─────────────────────────────────────────────────────────
cat > backend/src/controllers/adminController.js << 'ADMEOF'
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Dashboard KPIs para el administrador
 */
const getDashboard = async (req, res) => {
  try {
    const [
      totalUsers,
      totalBeneficiarios,
      mujeres,
      totalCourses,
      totalEnrollments,
      attendanceSummary,
    ] = await Promise.all([
      prisma.user.count({ where: { isActive: true } }),
      prisma.user.count({ where: { role: 'BENEFICIARIO', isActive: true } }),
      prisma.user.count({ where: { role: 'BENEFICIARIO', gender: 'FEMENINO', isActive: true } }),
      prisma.course.count({ where: { isPublished: true } }),
      prisma.enrollment.count({ where: { status: 'ACTIVO' } }),
      prisma.attendance.groupBy({
        by: ['status'],
        _count: { status: true },
      }),
    ]);

    const courseKpis = await prisma.course.findMany({
      where: { isPublished: true },
      select: {
        id: true,
        title: true,
        _count: { select: { enrollments: true } },
        sessions: {
          select: {
            _count: { select: { attendances: true } },
          },
        },
      },
    });

    const porcentajeMujeres = totalBeneficiarios > 0
      ? ((mujeres / totalBeneficiarios) * 100).toFixed(1)
      : 0;

    const attendanceMap = {};
    attendanceSummary.forEach((a) => { attendanceMap[a.status] = a._count.status; });

    const totalAttendance = Object.values(attendanceMap).reduce((a, b) => a + b, 0);
    const presenteCount = attendanceMap['PRESENTE'] || 0;
    const porcentajeAsistencia = totalAttendance > 0
      ? ((presenteCount / totalAttendance) * 100).toFixed(1)
      : 0;

    // Grupos poblacionales
    const populationBreakdown = await prisma.user.groupBy({
      by: ['populationGroup'],
      where: { role: 'BENEFICIARIO', isActive: true },
      _count: { populationGroup: true },
    });

    return res.json({
      kpis: {
        totalUsers,
        totalBeneficiarios,
        porcentajeMujeres: `${porcentajeMujeres}%`,
        metaMujeres: totalBeneficiarios >= 50 ? (mujeres >= 25 ? '✅ Cumplida' : '⚠️ En riesgo') : 'Sin datos',
        totalCourses,
        totalEnrollments,
        porcentajeAsistencia: `${porcentajeAsistencia}%`,
      },
      courseKpis: courseKpis.map((c) => ({
        id: c.id,
        title: c.title,
        inscritos: c._count.enrollments,
      })),
      populationBreakdown: populationBreakdown.map((p) => ({
        grupo: p.populationGroup || 'Sin clasificar',
        cantidad: p._count.populationGroup,
      })),
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Error al cargar el dashboard' });
  }
};

module.exports = { getDashboard };
ADMEOF

# ── User Controller ──────────────────────────────────────────────────────────
cat > backend/src/controllers/userController.js << 'UCEOF'
const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

const listUsers = async (req, res) => {
  const { role, page = 1, limit = 20 } = req.query;
  const where = role ? { role } : {};
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip: (page - 1) * limit,
      take: Number(limit),
      select: {
        id: true, email: true, firstName: true, lastName: true,
        cedula: true, phone: true, role: true, gender: true,
        populationGroup: true, locality: true, isActive: true, createdAt: true,
        enrollments: { select: { courseId: true, status: true } },
      },
      orderBy: { createdAt: 'desc' },
    }),
    prisma.user.count({ where }),
  ]);
  return res.json({ data: users, total, page: Number(page), limit: Number(limit) });
};

const createUser = async (req, res) => {
  try {
    const { email, password, role, firstName, lastName, cedula,
            phone, gender, populationGroup, upz, locality } = req.body;

    const hash = await bcrypt.hash(password || 'Temporal2024!', 12);
    const user = await prisma.user.create({
      data: { email: email.toLowerCase(), passwordHash: hash, role,
              firstName, lastName, cedula, phone, gender, populationGroup,
              upz, locality },
    });

    const { passwordHash, ...safe } = user;
    return res.status(201).json(safe);
  } catch (err) {
    if (err.code === 'P2002')
      return res.status(409).json({ error: 'Email o cédula ya registrado' });
    return res.status(500).json({ error: 'Error al crear usuario' });
  }
};

const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const data = { ...req.body };
    delete data.passwordHash;
    const user = await prisma.user.update({ where: { id }, data });
    const { passwordHash, ...safe } = user;
    return res.json(safe);
  } catch {
    return res.status(500).json({ error: 'Error al actualizar usuario' });
  }
};

const deactivateUser = async (req, res) => {
  const { id } = req.params;
  await prisma.user.update({ where: { id }, data: { isActive: false } });
  return res.json({ message: 'Usuario desactivado' });
};

module.exports = { listUsers, createUser, updateUser, deactivateUser };
UCEOF

# ── Routes ────────────────────────────────────────────────────────────────────
cat > backend/src/routes/auth.js << 'EOF'
const router = require('express').Router();
const { login, me } = require('../controllers/authController');
const { authenticate } = require('../middleware/auth');

router.post('/login', login);
router.get('/me', authenticate, me);

module.exports = router;
EOF

cat > backend/src/routes/users.js << 'EOF'
const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const { listUsers, createUser, updateUser, deactivateUser } = require('../controllers/userController');

router.use(authenticate);
router.get('/', authorize('ADMIN'), listUsers);
router.post('/', authorize('ADMIN'), createUser);
router.put('/:id', authorize('ADMIN'), updateUser);
router.delete('/:id', authorize('ADMIN'), deactivateUser);

module.exports = router;
EOF

cat > backend/src/routes/courses.js << 'EOF'
const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getLobby, getCourseDetail, createCourse, enrollUser } = require('../controllers/courseController');

router.use(authenticate);
router.get('/lobby', getLobby);
router.get('/:id', getCourseDetail);
router.post('/', authorize('ADMIN'), createCourse);
router.post('/enroll', authorize('ADMIN'), enrollUser);

module.exports = router;
EOF

cat > backend/src/routes/sessions.js << 'EOF'
const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const { PrismaClient } = require('@prisma/client');
const multer = require('multer');
const path = require('path');

const prisma = new PrismaClient();

const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, path.join(__dirname, '../../uploads')),
  filename: (req, file, cb) => cb(null, `${Date.now()}-${file.originalname}`),
});
const upload = multer({ storage, limits: { fileSize: 50 * 1024 * 1024 } });

router.use(authenticate);

router.get('/:id', async (req, res) => {
  const session = await prisma.session.findUnique({
    where: { id: req.params.id },
    include: { resources: { orderBy: { order: 'asc' } } },
  });
  if (!session) return res.status(404).json({ error: 'Sesión no encontrada' });
  return res.json(session);
});

router.post('/:id/resources', authorize('FORMADOR', 'ADMIN'), upload.single('file'), async (req, res) => {
  const { title, type, url } = req.body;
  const resourceUrl = req.file ? `/uploads/${req.file.filename}` : url;
  const resource = await prisma.resource.create({
    data: { sessionId: req.params.id, title, type, url: resourceUrl },
  });
  return res.status(201).json(resource);
});

module.exports = router;
EOF

cat > backend/src/routes/attendance.js << 'EOF'
const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

router.use(authenticate);

// Registrar asistencia (formador / admin)
router.post('/', authorize('FORMADOR', 'ADMIN'), async (req, res) => {
  const { sessionId, attendances } = req.body;
  // attendances: [{ userId, status, notes }]
  const ops = attendances.map((a) =>
    prisma.attendance.upsert({
      where: { userId_sessionId: { userId: a.userId, sessionId } },
      update: { status: a.status, notes: a.notes },
      create: { userId: a.userId, sessionId, status: a.status, notes: a.notes },
    })
  );
  const result = await Promise.all(ops);
  return res.json(result);
});

// Ver asistencia de una sesión
router.get('/session/:sessionId', authorize('FORMADOR', 'ADMIN'), async (req, res) => {
  const records = await prisma.attendance.findMany({
    where: { sessionId: req.params.sessionId },
    include: { user: { select: { firstName: true, lastName: true, cedula: true } } },
  });
  return res.json(records);
});

module.exports = router;
EOF

cat > backend/src/routes/forum.js << 'EOF'
const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

router.use(authenticate);

router.get('/course/:courseId', async (req, res) => {
  const posts = await prisma.forumPost.findMany({
    where: { courseId: req.params.courseId },
    include: {
      author: { select: { firstName: true, lastName: true, role: true } },
      replies: {
        include: { author: { select: { firstName: true, lastName: true, role: true } } },
        orderBy: { createdAt: 'asc' },
      },
    },
    orderBy: [{ isPinned: 'desc' }, { createdAt: 'desc' }],
  });
  return res.json(posts);
});

router.post('/', async (req, res) => {
  const { courseId, title, body } = req.body;
  const post = await prisma.forumPost.create({
    data: { courseId, title, body, authorId: req.user.id },
  });
  return res.status(201).json(post);
});

router.post('/:postId/replies', async (req, res) => {
  const reply = await prisma.forumReply.create({
    data: { postId: req.params.postId, body: req.body.body, authorId: req.user.id },
  });
  return res.status(201).json(reply);
});

module.exports = router;
EOF

cat > backend/src/routes/admin.js << 'EOF'
const router = require('express').Router();
const { authenticate, authorize } = require('../middleware/auth');
const { getDashboard } = require('../controllers/adminController');

router.use(authenticate, authorize('ADMIN'));
router.get('/dashboard', getDashboard);

module.exports = router;
EOF

echo "✅ Backend generado"

# =============================================================================
# FRONTEND (Next.js 14 App Router + Tailwind)
# =============================================================================
mkdir -p frontend/src/{app,components,contexts,lib,types}
mkdir -p frontend/src/app/{login,"(dashboard)/admin","(dashboard)/formador","(student)/lobby","(student)/courses/[id]"}
mkdir -p frontend/src/components/{ui,layout,admin,student,formador}
mkdir -p frontend/public

cat > frontend/Dockerfile << 'FEOF'
FROM node:20-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
EXPOSE 3000
CMD ["npm", "run", "dev"]
FEOF

cat > frontend/package.json << 'FPKG'
{
  "name": "buskando-parche-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "14.2.5",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "axios": "^1.7.2",
    "react-hook-form": "^7.52.0",
    "react-hot-toast": "^2.4.1",
    "lucide-react": "^0.400.0",
    "clsx": "^2.1.1",
    "recharts": "^2.12.7"
  },
  "devDependencies": {
    "typescript": "^5.5.3",
    "@types/node": "^20.14.9",
    "@types/react": "^18.3.3",
    "@types/react-dom": "^18.3.0",
    "tailwindcss": "^3.4.6",
    "postcss": "^8.4.39",
    "autoprefixer": "^10.4.19"
  }
}
FPKG

cat > frontend/next.config.js << 'NCJ'
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: { appDir: true },
  images: { domains: ['localhost'] },
};
module.exports = nextConfig;
NCJ

cat > frontend/tailwind.config.js << 'TCJ'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ['./src/**/*.{js,ts,jsx,tsx,mdx}'],
  theme: {
    extend: {
      colors: {
        // ── Paleta Buskando Parche ──────────────────────────────────
        primary: {
          DEFAULT: '#D62B2B',   // Rojo principal del logo
          light:   '#E85555',
          dark:    '#A81F1F',
        },
        secondary: {
          DEFAULT: '#F5C518',   // Amarillo/dorado del logo
          light:   '#F9D85A',
          dark:    '#C9A010',
        },
        surface: {
          DEFAULT: '#141414',   // Fondo oscuro principal
          card:    '#1E1E1E',   // Tarjetas
          border:  '#2A2A2A',   // Bordes
          muted:   '#3A3A3A',   // Elementos silenciados
        },
        text: {
          primary:   '#FFFFFF',
          secondary: '#B0B0B0',
          muted:     '#6B7280',
        },
        success:  '#22C55E',
        warning:  '#F59E0B',
        error:    '#EF4444',
        info:     '#3B82F6',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', 'sans-serif'],
        display: ['Poppins', 'sans-serif'],
      },
      backgroundImage: {
        'gradient-brand': 'linear-gradient(135deg, #D62B2B 0%, #A81F1F 100%)',
        'gradient-card':  'linear-gradient(135deg, #1E1E1E 0%, #141414 100%)',
      },
      boxShadow: {
        'brand': '0 4px 24px rgba(214, 43, 43, 0.3)',
        'card':  '0 2px 16px rgba(0, 0, 0, 0.4)',
        'glow':  '0 0 20px rgba(245, 197, 24, 0.2)',
      },
      animation: {
        'fade-in': 'fadeIn 0.3s ease-out',
        'slide-up': 'slideUp 0.4s ease-out',
        'pulse-brand': 'pulseBrand 2s infinite',
      },
      keyframes: {
        fadeIn: { from: { opacity: 0 }, to: { opacity: 1 } },
        slideUp: { from: { transform: 'translateY(20px)', opacity: 0 }, to: { transform: 'translateY(0)', opacity: 1 } },
        pulseBrand: { '0%,100%': { boxShadow: '0 0 0 0 rgba(214,43,43,0.4)' }, '50%': { boxShadow: '0 0 0 8px rgba(214,43,43,0)' } },
      },
    },
  },
  plugins: [],
};
TCJ

cat > frontend/postcss.config.js << 'EOF'
module.exports = { plugins: { tailwindcss: {}, autoprefixer: {} } };
EOF

# ── Globals CSS ──────────────────────────────────────────────────────────────
mkdir -p frontend/src/app
cat > frontend/src/app/globals.css << 'EOF'
@import url('https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Poppins:wght@600;700;800&display=swap');

@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html { @apply bg-surface text-text-primary; }
  * { @apply border-surface-border; }
  ::-webkit-scrollbar { @apply w-1.5; }
  ::-webkit-scrollbar-track { @apply bg-surface; }
  ::-webkit-scrollbar-thumb { @apply bg-surface-muted rounded-full; }
}

@layer components {
  .btn-primary {
    @apply bg-primary hover:bg-primary-dark text-white font-semibold px-6 py-3
           rounded-xl transition-all duration-200 shadow-brand hover:shadow-lg
           active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed;
  }
  .btn-secondary {
    @apply bg-secondary hover:bg-secondary-dark text-surface font-semibold px-6 py-3
           rounded-xl transition-all duration-200 active:scale-95;
  }
  .btn-ghost {
    @apply text-text-secondary hover:text-white hover:bg-surface-muted
           px-4 py-2 rounded-lg transition-all duration-200;
  }
  .card {
    @apply bg-surface-card rounded-2xl border border-surface-border shadow-card p-6;
  }
  .input {
    @apply w-full bg-surface border border-surface-border rounded-xl px-4 py-3
           text-text-primary placeholder-text-muted focus:outline-none
           focus:ring-2 focus:ring-primary focus:border-transparent
           transition-all duration-200;
  }
  .badge {
    @apply inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold;
  }
  .badge-primary   { @apply badge bg-primary/20 text-primary-light; }
  .badge-secondary { @apply badge bg-secondary/20 text-secondary; }
  .badge-success   { @apply badge bg-success/20 text-success; }
  .badge-warning   { @apply badge bg-warning/20 text-warning; }
  .badge-muted     { @apply badge bg-surface-muted text-text-secondary; }
}
EOF

# ── Auth Context ─────────────────────────────────────────────────────────────
cat > frontend/src/contexts/AuthContext.tsx << 'AUTHCTX'
'use client';
import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import api from '@/lib/api';

interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  role: 'ADMIN' | 'FORMADOR' | 'BENEFICIARIO';
}

interface AuthContextType {
  user: User | null;
  token: string | null;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextType | null>(null);

export const AuthProvider = ({ children }: { children: ReactNode }) => {
  const [user, setUser] = useState<User | null>(null);
  const [token, setToken] = useState<string | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const savedToken = localStorage.getItem('bp_token');
    if (savedToken) {
      setToken(savedToken);
      api.defaults.headers.common['Authorization'] = `Bearer ${savedToken}`;
      api.get('/auth/me')
        .then(({ data }) => setUser(data))
        .catch(() => { localStorage.removeItem('bp_token'); })
        .finally(() => setIsLoading(false));
    } else {
      setIsLoading(false);
    }
  }, []);

  const login = async (email: string, password: string) => {
    const { data } = await api.post('/auth/login', { email, password });
    setToken(data.token);
    setUser(data.user);
    localStorage.setItem('bp_token', data.token);
    api.defaults.headers.common['Authorization'] = `Bearer ${data.token}`;
  };

  const logout = () => {
    setUser(null);
    setToken(null);
    localStorage.removeItem('bp_token');
    delete api.defaults.headers.common['Authorization'];
    window.location.href = '/login';
  };

  return (
    <AuthContext.Provider value={{ user, token, login, logout, isLoading }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
};
AUTHCTX

# ── API Client ───────────────────────────────────────────────────────────────
cat > frontend/src/lib/api.ts << 'APIEOF'
import axios from 'axios';

const api = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000/api',
  timeout: 15000,
});

api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('bp_token');
      window.location.href = '/login';
    }
    return Promise.reject(err);
  }
);

export default api;
APIEOF

# ── Root Layout ───────────────────────────────────────────────────────────────
cat > frontend/src/app/layout.tsx << 'LAYEOF'
import type { Metadata } from 'next';
import './globals.css';
import { AuthProvider } from '@/contexts/AuthContext';
import { Toaster } from 'react-hot-toast';

export const metadata: Metadata = {
  title: 'Buskando Parche LMS | Kennedy',
  description: 'Plataforma de formación para emprendedores y prestadores turísticos de Kennedy, Bogotá.',
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es">
      <body className="min-h-screen bg-surface antialiased">
        <AuthProvider>
          {children}
          <Toaster
            position="top-right"
            toastOptions={{
              style: { background: '#1E1E1E', color: '#fff', border: '1px solid #2A2A2A' },
              success: { iconTheme: { primary: '#22C55E', secondary: '#fff' } },
              error: { iconTheme: { primary: '#D62B2B', secondary: '#fff' } },
            }}
          />
        </AuthProvider>
      </body>
    </html>
  );
}
LAYEOF

# ── Root Page (redirect) ──────────────────────────────────────────────────────
cat > frontend/src/app/page.tsx << 'EOF'
import { redirect } from 'next/navigation';
export default function Home() { redirect('/login'); }
EOF

# ── Login Page ───────────────────────────────────────────────────────────────
cat > frontend/src/app/login/page.tsx << 'LOGINEOF'
'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';
import toast from 'react-hot-toast';
import { MapPin, Lock, Mail, Loader2 } from 'lucide-react';

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await login(email, password);
      const role = JSON.parse(atob(localStorage.getItem('bp_token')!.split('.')[1])).role;
      if (role === 'ADMIN') router.push('/admin');
      else if (role === 'FORMADOR') router.push('/formador');
      else router.push('/lobby');
    } catch {
      toast.error('Credenciales incorrectas. Verifica tu email y contraseña.');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-surface relative overflow-hidden">
      {/* Background decoration */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-40 -right-40 w-96 h-96 bg-primary/10 rounded-full blur-3xl" />
        <div className="absolute -bottom-40 -left-40 w-96 h-96 bg-secondary/10 rounded-full blur-3xl" />
      </div>

      <div className="relative w-full max-w-md px-6 animate-slide-up">
        {/* Logo */}
        <div className="flex flex-col items-center mb-10">
          <div className="flex items-center gap-3 mb-3">
            <div className="bg-gradient-brand p-3 rounded-2xl shadow-brand">
              <MapPin className="w-8 h-8 text-white" />
            </div>
            <div>
              <h1 className="font-display text-3xl font-bold text-white leading-tight">
                Buskando<br />
                <span className="text-secondary">Parche</span>
              </h1>
            </div>
          </div>
          <p className="text-text-secondary text-sm text-center">
            Plataforma de formación · Kennedy, Bogotá
          </p>
        </div>

        {/* Card */}
        <div className="card space-y-6">
          <div>
            <h2 className="text-xl font-semibold text-white">Iniciar sesión</h2>
            <p className="text-text-muted text-sm mt-1">Ingresa con tus credenciales asignadas</p>
          </div>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">
                Correo electrónico
              </label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted" />
                <input
                  type="email"
                  className="input pl-10"
                  placeholder="tu@correo.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">
                Contraseña
              </label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted" />
                <input
                  type="password"
                  className="input pl-10"
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
              </div>
            </div>

            <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2 mt-2">
              {loading ? <Loader2 className="w-5 h-5 animate-spin" /> : null}
              {loading ? 'Ingresando...' : 'Ingresar a la plataforma'}
            </button>
          </form>

          <p className="text-center text-text-muted text-xs">
            ¿Problemas para ingresar? Contacta al administrador del programa.
          </p>
        </div>

        <p className="text-center text-text-muted text-xs mt-6">
          © 2024 Buskando Parche · Kennedy · Bogotá
        </p>
      </div>
    </div>
  );
}
LOGINEOF

# ── Shared Layout Component ──────────────────────────────────────────────────
cat > frontend/src/components/layout/Sidebar.tsx << 'SBEOF'
'use client';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';
import {
  LayoutDashboard, BookOpen, Users, ClipboardList,
  MessageSquare, Award, LogOut, MapPin, ChevronRight, BarChart3
} from 'lucide-react';
import clsx from 'clsx';

const navByRole = {
  ADMIN: [
    { href: '/admin', icon: LayoutDashboard, label: 'Dashboard' },
    { href: '/admin/users', icon: Users, label: 'Usuarios' },
    { href: '/admin/courses', icon: BookOpen, label: 'Cursos' },
    { href: '/admin/reports', icon: BarChart3, label: 'Reportes' },
  ],
  FORMADOR: [
    { href: '/formador', icon: LayoutDashboard, label: 'Panel' },
    { href: '/formador/courses', icon: BookOpen, label: 'Mis Cursos' },
    { href: '/formador/attendance', icon: ClipboardList, label: 'Asistencia' },
  ],
  BENEFICIARIO: [
    { href: '/lobby', icon: BookOpen, label: 'Mis Cursos' },
    { href: '/lobby/forum', icon: MessageSquare, label: 'Foro' },
    { href: '/lobby/certificates', icon: Award, label: 'Certificados' },
  ],
};

export default function Sidebar() {
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const nav = user ? navByRole[user.role] || [] : [];

  return (
    <aside className="w-64 min-h-screen bg-surface-card border-r border-surface-border flex flex-col">
      {/* Logo */}
      <div className="p-6 border-b border-surface-border">
        <div className="flex items-center gap-3">
          <div className="bg-gradient-brand p-2 rounded-xl">
            <MapPin className="w-5 h-5 text-white" />
          </div>
          <div>
            <p className="font-display font-bold text-white text-sm leading-tight">Buskando Parche</p>
            <p className="text-text-muted text-xs">LMS · Kennedy</p>
          </div>
        </div>
      </div>

      {/* User info */}
      <div className="p-4 border-b border-surface-border">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-brand rounded-full flex items-center justify-center font-bold text-white text-sm">
            {user?.firstName?.[0]}{user?.lastName?.[0]}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-medium text-white truncate">{user?.firstName} {user?.lastName}</p>
            <span className={clsx('badge text-xs', {
              'badge-primary': user?.role === 'ADMIN',
              'badge-secondary': user?.role === 'FORMADOR',
              'badge-muted': user?.role === 'BENEFICIARIO',
            })}>
              {user?.role}
            </span>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-1">
        {nav.map(({ href, icon: Icon, label }) => {
          const isActive = pathname === href || pathname.startsWith(href + '/');
          return (
            <Link
              key={href}
              href={href}
              className={clsx(
                'flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group',
                isActive
                  ? 'bg-primary/20 text-primary-light border border-primary/30'
                  : 'text-text-secondary hover:bg-surface-muted hover:text-white'
              )}
            >
              <Icon className={clsx('w-5 h-5', isActive ? 'text-primary' : 'text-text-muted group-hover:text-white')} />
              {label}
              {isActive && <ChevronRight className="w-4 h-4 ml-auto text-primary" />}
            </Link>
          );
        })}
      </nav>

      {/* Logout */}
      <div className="p-4 border-t border-surface-border">
        <button onClick={logout} className="btn-ghost w-full flex items-center gap-3 text-sm">
          <LogOut className="w-5 h-5" />
          Cerrar sesión
        </button>
      </div>
    </aside>
  );
}
SBEOF

# ── Shared App Shell ─────────────────────────────────────────────────────────
cat > frontend/src/components/layout/AppShell.tsx << 'ASEOF'
'use client';
import { useAuth } from '@/contexts/AuthContext';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import Sidebar from './Sidebar';
import { Loader2 } from 'lucide-react';

export default function AppShell({
  children,
  allowedRoles,
}: {
  children: React.ReactNode;
  allowedRoles: string[];
}) {
  const { user, isLoading } = useAuth();
  const router = useRouter();

  useEffect(() => {
    if (!isLoading && !user) router.push('/login');
    if (!isLoading && user && !allowedRoles.includes(user.role)) router.push('/login');
  }, [user, isLoading]);

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-surface">
        <Loader2 className="w-8 h-8 text-primary animate-spin" />
      </div>
    );
  }

  return (
    <div className="flex min-h-screen">
      <Sidebar />
      <main className="flex-1 p-8 overflow-y-auto bg-surface animate-fade-in">
        {children}
      </main>
    </div>
  );
}
ASEOF

# ── KPI Card Component ────────────────────────────────────────────────────────
cat > frontend/src/components/ui/KpiCard.tsx << 'KPIEOF'
import { LucideIcon } from 'lucide-react';
import clsx from 'clsx';

interface Props {
  label: string;
  value: string | number;
  icon: LucideIcon;
  color?: 'primary' | 'secondary' | 'success' | 'info';
  subtitle?: string;
}

const colorMap = {
  primary: 'bg-primary/10 text-primary border-primary/20',
  secondary: 'bg-secondary/10 text-secondary border-secondary/20',
  success: 'bg-success/10 text-success border-success/20',
  info: 'bg-info/10 text-info border-info/20',
};

export default function KpiCard({ label, value, icon: Icon, color = 'primary', subtitle }: Props) {
  return (
    <div className="card flex items-start gap-4 hover:border-surface-muted transition-colors duration-200">
      <div className={clsx('p-3 rounded-xl border', colorMap[color])}>
        <Icon className="w-6 h-6" />
      </div>
      <div>
        <p className="text-text-secondary text-sm">{label}</p>
        <p className="text-2xl font-bold font-display text-white mt-0.5">{value}</p>
        {subtitle && <p className="text-text-muted text-xs mt-1">{subtitle}</p>}
      </div>
    </div>
  );
}
KPIEOF

# ── Course Card Component ─────────────────────────────────────────────────────
cat > frontend/src/components/student/CourseCard.tsx << 'CCARDEOF'
'use client';
import Link from 'next/link';
import { BookOpen, Lock, Users, CheckCircle, PlayCircle } from 'lucide-react';
import clsx from 'clsx';

interface Course {
  id: string;
  title: string;
  description: string;
  modality: string;
  formador: string;
  totalSessions: number;
  totalEnrolled: number;
  isEnrolled: boolean;
  enrollmentStatus: string | null;
}

export default function CourseCard({ course }: { course: Course }) {
  const isLocked = !course.isEnrolled;

  return (
    <div className={clsx(
      'card relative overflow-hidden transition-all duration-300 group',
      isLocked
        ? 'opacity-60 cursor-not-allowed'
        : 'hover:border-primary/40 hover:shadow-brand cursor-pointer hover:-translate-y-1'
    )}>
      {/* Top accent */}
      <div className={clsx(
        'absolute top-0 left-0 right-0 h-1',
        isLocked ? 'bg-surface-muted' : 'bg-gradient-brand'
      )} />

      <div className="flex items-start gap-4 pt-2">
        {/* Icon */}
        <div className={clsx(
          'p-3 rounded-xl flex-shrink-0',
          isLocked ? 'bg-surface-muted' : 'bg-primary/15 group-hover:bg-primary/25 transition-colors'
        )}>
          {isLocked
            ? <Lock className="w-6 h-6 text-text-muted" />
            : <BookOpen className="w-6 h-6 text-primary" />
          }
        </div>

        <div className="flex-1 min-w-0">
          <div className="flex items-start justify-between gap-2">
            <h3 className={clsx('font-semibold text-base leading-tight', isLocked ? 'text-text-muted' : 'text-white')}>
              {course.title}
            </h3>
            {course.isEnrolled && (
              <span className="badge-success flex-shrink-0">
                <CheckCircle className="w-3 h-3" /> Inscrito
              </span>
            )}
          </div>

          <p className={clsx('text-sm mt-1.5 line-clamp-2', isLocked ? 'text-text-muted' : 'text-text-secondary')}>
            {course.description}
          </p>

          <div className="flex items-center gap-4 mt-4 text-xs text-text-muted">
            <span className="flex items-center gap-1">
              <PlayCircle className="w-3.5 h-3.5" />
              {course.totalSessions} sesiones
            </span>
            <span className="flex items-center gap-1">
              <Users className="w-3.5 h-3.5" />
              {course.totalEnrolled} inscritos
            </span>
            <span className={clsx(
              'px-2 py-0.5 rounded-md font-medium',
              course.modality === 'VIRTUAL'
                ? 'bg-info/10 text-info'
                : 'bg-success/10 text-success'
            )}>
              {course.modality === 'VIRTUAL' ? 'Virtual' : 'Presencial'}
            </span>
          </div>

          <div className="flex items-center justify-between mt-4">
            <span className="text-xs text-text-muted">Formador: <span className="text-text-secondary">{course.formador}</span></span>
            {course.isEnrolled ? (
              <Link href={`/courses/${course.id}`} className="btn-primary py-2 px-4 text-sm">
                Acceder al curso
              </Link>
            ) : (
              <span className="text-xs text-text-muted flex items-center gap-1">
                <Lock className="w-3.5 h-3.5" /> Solo para inscritos
              </span>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
CCARDEOF

# ── Student Lobby Page ────────────────────────────────────────────────────────
cat > "frontend/src/app/(student)/lobby/page.tsx" << 'LOBEOF'
'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/layout/AppShell';
import CourseCard from '@/components/student/CourseCard';
import api from '@/lib/api';
import { useAuth } from '@/contexts/AuthContext';
import { BookOpen, Search, Loader2 } from 'lucide-react';

export default function LobbyPage() {
  const { user } = useAuth();
  const [courses, setCourses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  useEffect(() => {
    api.get('/courses/lobby')
      .then(({ data }) => setCourses(data))
      .finally(() => setLoading(false));
  }, []);

  const filtered = courses.filter((c: any) =>
    c.title.toLowerCase().includes(search.toLowerCase())
  );

  const enrolled = filtered.filter((c: any) => c.isEnrolled);
  const available = filtered.filter((c: any) => !c.isEnrolled);

  return (
    <AppShell allowedRoles={['BENEFICIARIO']}>
      <div className="max-w-5xl mx-auto space-y-8">
        {/* Header */}
        <div>
          <h1 className="font-display text-3xl font-bold text-white">
            Hola, <span className="text-secondary">{user?.firstName}</span> 👋
          </h1>
          <p className="text-text-secondary mt-1">
            Bienvenido a tu espacio de aprendizaje. Accede a tus cursos asignados.
          </p>
        </div>

        {/* Search */}
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-text-muted" />
          <input
            className="input pl-10"
            placeholder="Buscar cursos..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
        </div>

        {loading ? (
          <div className="flex justify-center py-20">
            <Loader2 className="w-8 h-8 text-primary animate-spin" />
          </div>
        ) : (
          <>
            {/* Mis cursos inscritos */}
            {enrolled.length > 0 && (
              <section>
                <div className="flex items-center gap-2 mb-4">
                  <BookOpen className="w-5 h-5 text-primary" />
                  <h2 className="text-lg font-semibold text-white">Mis cursos</h2>
                  <span className="badge-primary">{enrolled.length}</span>
                </div>
                <div className="grid gap-4">
                  {enrolled.map((course: any) => (
                    <CourseCard key={course.id} course={course} />
                  ))}
                </div>
              </section>
            )}

            {/* Otros cursos (bloqueados) */}
            {available.length > 0 && (
              <section>
                <div className="flex items-center gap-2 mb-4">
                  <h2 className="text-lg font-semibold text-white">Otros programas disponibles</h2>
                  <span className="badge-muted">{available.length}</span>
                </div>
                <p className="text-text-muted text-sm mb-4">
                  Estos cursos están disponibles en la plataforma. El acceso se habilita únicamente para los participantes asignados.
                </p>
                <div className="grid gap-4">
                  {available.map((course: any) => (
                    <CourseCard key={course.id} course={course} />
                  ))}
                </div>
              </section>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}
LOBEOF

# ── Admin Dashboard Page ──────────────────────────────────────────────────────
cat > "frontend/src/app/(dashboard)/admin/page.tsx" << 'ADMINEOF'
'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/layout/AppShell';
import KpiCard from '@/components/ui/KpiCard';
import api from '@/lib/api';
import { Users, BookOpen, TrendingUp, Heart, Loader2, AlertTriangle, CheckCircle } from 'lucide-react';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell } from 'recharts';

export default function AdminDashboard() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/admin/dashboard')
      .then(({ data }) => setData(data))
      .finally(() => setLoading(false));
  }, []);

  return (
    <AppShell allowedRoles={['ADMIN']}>
      <div className="max-w-6xl mx-auto space-y-8">
        <div>
          <h1 className="font-display text-3xl font-bold text-white">Dashboard Administrativo</h1>
          <p className="text-text-secondary mt-1">Monitoreo general del programa de formación</p>
        </div>

        {loading ? (
          <div className="flex justify-center py-20">
            <Loader2 className="w-8 h-8 text-primary animate-spin" />
          </div>
        ) : (
          <>
            {/* KPIs Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
              <KpiCard
                label="Total beneficiarios"
                value={data?.kpis.totalBeneficiarios}
                icon={Users}
                color="primary"
                subtitle={`de 80 cupos objetivo`}
              />
              <KpiCard
                label="% Asistencia global"
                value={data?.kpis.porcentajeAsistencia}
                icon={TrendingUp}
                color="success"
                subtitle="Todas las sesiones"
              />
              <KpiCard
                label="Cursos activos"
                value={data?.kpis.totalCourses}
                icon={BookOpen}
                color="info"
                subtitle="Programas publicados"
              />
              <KpiCard
                label="Meta género (mujeres)"
                value={data?.kpis.porcentajeMujeres}
                icon={Heart}
                color="secondary"
                subtitle={data?.kpis.metaMujeres}
              />
            </div>

            {/* Charts row */}
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {/* Inscritos por curso */}
              <div className="card">
                <h3 className="font-semibold text-white mb-4">Inscritos por curso</h3>
                <ResponsiveContainer width="100%" height={200}>
                  <BarChart data={data?.courseKpis} barSize={32}>
                    <XAxis dataKey="title" tick={{ fill: '#6B7280', fontSize: 11 }} tickLine={false} />
                    <YAxis tick={{ fill: '#6B7280', fontSize: 11 }} axisLine={false} tickLine={false} />
                    <Tooltip
                      contentStyle={{ background: '#1E1E1E', border: '1px solid #2A2A2A', borderRadius: 12, color: '#fff' }}
                      cursor={{ fill: 'rgba(214,43,43,0.05)' }}
                    />
                    <Bar dataKey="inscritos" radius={[6, 6, 0, 0]}>
                      {data?.courseKpis?.map((_: any, i: number) => (
                        <Cell key={i} fill={i % 2 === 0 ? '#D62B2B' : '#F5C518'} />
                      ))}
                    </Bar>
                  </BarChart>
                </ResponsiveContainer>
              </div>

              {/* Grupos poblacionales */}
              <div className="card">
                <h3 className="font-semibold text-white mb-4">Enfoque diferencial / Grupos poblacionales</h3>
                <div className="space-y-3">
                  {data?.populationBreakdown?.map((p: any) => (
                    <div key={p.grupo} className="flex items-center gap-3">
                      <span className="text-text-secondary text-sm w-40 truncate">{p.grupo}</span>
                      <div className="flex-1 bg-surface-muted rounded-full h-2">
                        <div
                          className="bg-gradient-brand h-2 rounded-full"
                          style={{ width: `${Math.min((p.cantidad / data.kpis.totalBeneficiarios) * 100, 100)}%` }}
                        />
                      </div>
                      <span className="text-white text-sm font-semibold w-6 text-right">{p.cantidad}</span>
                    </div>
                  ))}
                  {!data?.populationBreakdown?.length && (
                    <p className="text-text-muted text-sm">Sin datos aún</p>
                  )}
                </div>
              </div>
            </div>

            {/* Alert: meta de género */}
            <div className={`flex items-start gap-4 p-4 rounded-xl border ${
              data?.kpis.metaMujeres?.includes('✅')
                ? 'bg-success/10 border-success/30 text-success'
                : 'bg-warning/10 border-warning/30 text-warning'
            }`}>
              {data?.kpis.metaMujeres?.includes('✅')
                ? <CheckCircle className="w-5 h-5 flex-shrink-0 mt-0.5" />
                : <AlertTriangle className="w-5 h-5 flex-shrink-0 mt-0.5" />
              }
              <div>
                <p className="font-semibold text-sm">Meta de paridad de género</p>
                <p className="text-sm opacity-80 mt-0.5">
                  El contrato exige mínimo 50% de mujeres beneficiarias.
                  Actualmente: <strong>{data?.kpis.porcentajeMujeres}</strong> — {data?.kpis.metaMujeres}
                </p>
              </div>
            </div>
          </>
        )}
      </div>
    </AppShell>
  );
}
ADMINEOF

echo "✅ Frontend generado"

# =============================================================================
# README
# =============================================================================
cat > README.md << 'READEOF'
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
READEOF

echo ""
echo "═══════════════════════════════════════════════════════════════"
echo "✅  Scaffold completo generado en: ./$ROOT"
echo "═══════════════════════════════════════════════════════════════"
echo ""
echo "📋 Para iniciar:"
echo "   cd $ROOT"
echo "   docker-compose up --build"
echo ""
echo "🌐 URLs:"
echo "   Frontend  → http://localhost:3000"
echo "   Backend   → http://localhost:4000"
echo ""
