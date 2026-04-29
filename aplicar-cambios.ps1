# =============================================================================
# SCRIPT DE ACTUALIZACIÓN - Buskando Parche LMS
# Ejecutar desde: C:\Users\USUARIO\Desktop\Buskando parche Kennedy\buskando-parche-lms
# PowerShell: .\aplicar-cambios.ps1
# =============================================================================

Write-Host "🚀 Aplicando cambios al LMS Buskando Parche..." -ForegroundColor Yellow

# ── 1. SEED CON 85 USUARIOS ────────────────────────────────────────────────
Write-Host "👥 Generando seed con 80 beneficiarios + 4 formadores + 1 admin..." -ForegroundColor Cyan

@'
const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();

const beneficiarios = [
  { firstName: "Laura",      lastName: "Rodríguez Peña",      cedula: "1020301001", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Carlos",     lastName: "Martínez López",      cedula: "1020301002", gender: "MASCULINO", populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Ana María",  lastName: "Gómez Herrera",       cedula: "1020301003", gender: "FEMENINO",  populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Jhon",       lastName: "Vargas Castro",       cedula: "1020301004", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Sandra",     lastName: "Torres Morales",      cedula: "1020301005", gender: "FEMENINO",  populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Miguel",     lastName: "Díaz Ortega",         cedula: "1020301006", gender: "MASCULINO", populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Valentina",  lastName: "Ruiz Jiménez",        cedula: "1020301007", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "David",      lastName: "Sánchez Ramos",       cedula: "1020301008", gender: "MASCULINO", populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Paola",      lastName: "Romero Quintero",     cedula: "1020301009", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Andrés",     lastName: "Cárdenas Vega",       cedula: "1020301010", gender: "MASCULINO", populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Natalia",    lastName: "Mora Suárez",         cedula: "1020301011", gender: "FEMENINO",  populationGroup: "AFRODESCENDIENTE",   locality: "Kennedy" },
  { firstName: "Sebastián",  lastName: "Parra Méndez",        cedula: "1020301012", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Camila",     lastName: "Ríos Guerrero",       cedula: "1020301013", gender: "FEMENINO",  populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Fernando",   lastName: "Muñoz Salcedo",       cedula: "1020301014", gender: "MASCULINO", populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Marcela",    lastName: "Pedraza Luna",        cedula: "1020301015", gender: "FEMENINO",  populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Ricardo",    lastName: "Alvarado Niño",       cedula: "1020301016", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Diana",      lastName: "Ospina Cardona",      cedula: "1020301017", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Julián",     lastName: "Bermúdez Acosta",     cedula: "1020301018", gender: "MASCULINO", populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Luisa",      lastName: "Caballero Toro",      cedula: "1020301019", gender: "FEMENINO",  populationGroup: "AFRODESCENDIENTE",   locality: "Kennedy" },
  { firstName: "Esteban",    lastName: "Giraldo Reyes",       cedula: "1020301020", gender: "MASCULINO", populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Daniela",    lastName: "Serrano Pinto",       cedula: "1020301021", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Mauricio",   lastName: "Estrada Vidal",       cedula: "1020301022", gender: "MASCULINO", populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Adriana",    lastName: "Monsalve Cruz",       cedula: "1020301023", gender: "FEMENINO",  populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Alejandro",  lastName: "Velásquez Duarte",    cedula: "1020301024", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Gloria",     lastName: "Zapata Figueroa",     cedula: "1020301025", gender: "FEMENINO",  populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Hernando",   lastName: "Cortés Bernal",       cedula: "1020301026", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Lina",       lastName: "Medina Vargas",       cedula: "1020301027", gender: "FEMENINO",  populationGroup: "AFRODESCENDIENTE",   locality: "Kennedy" },
  { firstName: "Oscar",      lastName: "Navarro Palomino",    cedula: "1020301028", gender: "MASCULINO", populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Verónica",   lastName: "Agudelo Soto",        cedula: "1020301029", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Iván",       lastName: "Gutiérrez Triana",    cedula: "1020301030", gender: "MASCULINO", populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Carolina",   lastName: "Londoño Arias",       cedula: "1020301031", gender: "FEMENINO",  populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Felipe",     lastName: "Arbeláez Mejía",      cedula: "1020301032", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Marisol",    lastName: "Pineda Blanco",       cedula: "1020301033", gender: "FEMENINO",  populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Gustavo",    lastName: "Montoya Espinosa",    cedula: "1020301034", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Tatiana",    lastName: "Flórez Holguín",      cedula: "1020301035", gender: "FEMENINO",  populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Nicolás",    lastName: "Salazar Quintana",    cedula: "1020301036", gender: "MASCULINO", populationGroup: "AFRODESCENDIENTE",   locality: "Kennedy" },
  { firstName: "Eliana",     lastName: "Cifuentes Roa",       cedula: "1020301037", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Rodrigo",    lastName: "Pulido Barrera",      cedula: "1020301038", gender: "MASCULINO", populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Yuliana",    lastName: "Cano Herrera",        cedula: "1020301039", gender: "FEMENINO",  populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Pablo",      lastName: "Mejía Arango",        cedula: "1020301040", gender: "MASCULINO", populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Claudia",    lastName: "Vélez Ochoa",         cedula: "1020301041", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Álvaro",     lastName: "Sepúlveda Jaramillo", cedula: "1020301042", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Bibiana",    lastName: "Ossa Gallego",        cedula: "1020301043", gender: "FEMENINO",  populationGroup: "AFRODESCENDIENTE",   locality: "Kennedy" },
  { firstName: "Germán",     lastName: "Tobón Uribe",         cedula: "1020301044", gender: "MASCULINO", populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Ximena",     lastName: "Bedoya Patiño",       cedula: "1020301045", gender: "FEMENINO",  populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Luis",       lastName: "Echavarría Posada",   cedula: "1020301046", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Martha",     lastName: "Arroyave Castaño",    cedula: "1020301047", gender: "FEMENINO",  populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Joaquín",    lastName: "Restrepo Muñoz",      cedula: "1020301048", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Pilar",      lastName: "Alzate Giraldo",      cedula: "1020301049", gender: "FEMENINO",  populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Hernán",     lastName: "Cárdenas Osorio",     cedula: "1020301050", gender: "MASCULINO", populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Alejandra",  lastName: "Duque Moreno",        cedula: "1020301051", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Javier",     lastName: "Marulanda Ríos",      cedula: "1020301052", gender: "MASCULINO", populationGroup: "AFRODESCENDIENTE",   locality: "Kennedy" },
  { firstName: "Sofía",      lastName: "Henao Castillo",      cedula: "1020301053", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Harold",     lastName: "Castaño Ramírez",     cedula: "1020301054", gender: "MASCULINO", populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Nathalia",   lastName: "Lopera Vargas",       cedula: "1020301055", gender: "FEMENINO",  populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Wilmer",     lastName: "Aguilar Serna",       cedula: "1020301056", gender: "MASCULINO", populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Leidy",      lastName: "Aristizábal Gómez",   cedula: "1020301057", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "César",      lastName: "Cardona Betancur",    cedula: "1020301058", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Aura",       lastName: "Rendón Acevedo",      cedula: "1020301059", gender: "FEMENINO",  populationGroup: "AFRODESCENDIENTE",   locality: "Kennedy" },
  { firstName: "Yesid",      lastName: "Quiroz Palomino",     cedula: "1020301060", gender: "MASCULINO", populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Milena",     lastName: "Urrego Zapata",       cedula: "1020301061", gender: "FEMENINO",  populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Édgar",      lastName: "Hincapié Santamaría", cedula: "1020301062", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Lorena",     lastName: "Zuluaga Montes",      cedula: "1020301063", gender: "FEMENINO",  populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Wilfredo",   lastName: "Osorio Correa",       cedula: "1020301064", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Inés",       lastName: "Gallego Parra",       cedula: "1020301065", gender: "FEMENINO",  populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Raúl",       lastName: "Mosquera Lozano",     cedula: "1020301066", gender: "MASCULINO", populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Esperanza",  lastName: "Moncada Vergara",     cedula: "1020301067", gender: "FEMENINO",  populationGroup: "AFRODESCENDIENTE",   locality: "Kennedy" },
  { firstName: "Víctor",     lastName: "Salcedo Ortiz",       cedula: "1020301068", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Nubia",      lastName: "Garzón Ramírez",      cedula: "1020301069", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Armando",    lastName: "Tovar Medina",        cedula: "1020301070", gender: "MASCULINO", populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Helena",     lastName: "Prieto Suárez",       cedula: "1020301071", gender: "FEMENINO",  populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Eliseo",     lastName: "Vargas Herrera",      cedula: "1020301072", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Rocío",      lastName: "Peña Castañeda",      cedula: "1020301073", gender: "FEMENINO",  populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Camilo",     lastName: "Ángel Soto",          cedula: "1020301074", gender: "MASCULINO", populationGroup: "AFRODESCENDIENTE",   locality: "Kennedy" },
  { firstName: "Gladys",     lastName: "Reyes Murillo",       cedula: "1020301075", gender: "FEMENINO",  populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Fredy",      lastName: "Naranjo Cano",        cedula: "1020301076", gender: "MASCULINO", populationGroup: "MIPYME",             locality: "Kennedy" },
  { firstName: "Patricia",   lastName: "Caicedo Leal",        cedula: "1020301077", gender: "FEMENINO",  populationGroup: "VICTIMA_CONFLICTO",  locality: "Kennedy" },
  { firstName: "Dario",      lastName: "Ballén Pachón",       cedula: "1020301078", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
  { firstName: "Amparo",     lastName: "Triana Buitrago",     cedula: "1020301079", gender: "FEMENINO",  populationGroup: "PRESTADOR_TURISTICO", locality: "Kennedy" },
  { firstName: "Néstor",     lastName: "Quintero Fierro",     cedula: "1020301080", gender: "MASCULINO", populationGroup: "EMPRENDEDOR",        locality: "Kennedy" },
];

const formadores = [
  { firstName: "María",    lastName: "Ramírez Solano",   cedula: "9000000001", especialidad: "Marketing Digital" },
  { firstName: "Carlos",   lastName: "Pérez Estrada",    cedula: "9000000002", especialidad: "Inglés Turístico" },
  { firstName: "Andrea",   lastName: "Nieto Salazar",    cedula: "9000000003", especialidad: "Gestión Empresarial" },
  { firstName: "Roberto",  lastName: "Lagos Cifuentes",  cedula: "9000000004", especialidad: "Turismo Sostenible" },
];

const cursosData = [
  { title: "Marketing Digital Turístico",   description: "Posiciona tu negocio en redes sociales, SEO local y campañas digitales para atraer turistas.", modality: "VIRTUAL",    totalSessions: 20, isPublished: true },
  { title: "Inglés en el Turismo",          description: "Comunicación básica e intermedia en inglés para atención de turistas internacionales.",          modality: "VIRTUAL",    totalSessions: 20, isPublished: true },
  { title: "Gestión Empresarial",           description: "Planeación, finanzas básicas y estructura organizacional para MiPymes y emprendedores.",          modality: "PRESENCIAL", totalSessions: 20, isPublished: true },
  { title: "Turismo Sostenible",            description: "Buenas prácticas ambientales y certificación para prestadores turísticos de Kennedy.",             modality: "PRESENCIAL", totalSessions: 20, isPublished: true },
];

async function main() {
  console.log("🌱 Seeding database con 85 usuarios...");

  const hash = await bcrypt.hash("BuskandoParche2024!", 12);

  // ── Admin ──────────────────────────────────────────────────────────────────
  await prisma.user.upsert({
    where: { email: "admin@buskandoparche.com" },
    update: {},
    create: {
      email: "admin@buskandoparche.com",
      passwordHash: await bcrypt.hash("Admin2024!", 12),
      role: "ADMIN",
      firstName: "Admin",
      lastName: "Sistema",
      cedula: "8000000001",
      phone: "3001234567",
    },
  });

  // ── Formadores ─────────────────────────────────────────────────────────────
  const formadorUsers = [];
  for (let i = 0; i < formadores.length; i++) {
    const f = formadores[i];
    const num = String(i + 1).padStart(2, "0");
    const email = `formador${num}@buskandoparche.com`;
    const user = await prisma.user.upsert({
      where: { email },
      update: {},
      create: {
        email,
        passwordHash: await bcrypt.hash("Formador2024!", 12),
        role: "FORMADOR",
        firstName: f.firstName,
        lastName: f.lastName,
        cedula: f.cedula,
        phone: `310000000${i}`,
      },
    });
    formadorUsers.push(user);
  }

  // ── Cursos ─────────────────────────────────────────────────────────────────
  const cursos = [];
  for (let i = 0; i < cursosData.length; i++) {
    const c = cursosData[i];
    const existing = await prisma.course.findFirst({ where: { title: c.title } });
    let course;
    if (existing) {
      course = await prisma.course.update({
        where: { id: existing.id },
        data: { ...c, formadorId: formadorUsers[i]?.id },
      });
    } else {
      course = await prisma.course.create({
        data: { ...c, formadorId: formadorUsers[i]?.id },
      });
    }
    cursos.push(course);

    // Sesiones
    for (let s = 1; s <= 20; s++) {
      await prisma.session.upsert({
        where: { courseId_order: { courseId: course.id, order: s } },
        update: {},
        create: { courseId: course.id, title: `Sesión ${s}`, description: `Contenido sesión ${s} - ${c.title}`, order: s },
      });
    }
  }

  // ── Beneficiarios ─────────────────────────────────────────────────────────
  // 20 por curso (80 total)
  for (let i = 0; i < beneficiarios.length; i++) {
    const b = beneficiarios[i];
    const num = String(i + 1).padStart(3, "0");
    const email = `beneficiario${num}@buskandoparche.com`;
    const user = await prisma.user.upsert({
      where: { email },
      update: {},
      create: {
        email,
        passwordHash: hash,
        role: "BENEFICIARIO",
        firstName: b.firstName,
        lastName: b.lastName,
        cedula: b.cedula,
        gender: b.gender,
        populationGroup: b.populationGroup,
        locality: b.locality,
        upz: "Kennedy Central",
        phone: `3${String(100000000 + i)}`,
      },
    });

    // Inscribir cada 20 beneficiarios a un curso
    const cursoIndex = Math.floor(i / 20);
    if (cursoIndex < cursos.length) {
      await prisma.enrollment.upsert({
        where: { userId_courseId: { userId: user.id, courseId: cursos[cursoIndex].id } },
        update: {},
        create: { userId: user.id, courseId: cursos[cursoIndex].id, status: "ACTIVO" },
      });
    }
  }

  console.log("✅ Seed completado: 1 Admin + 4 Formadores + 80 Beneficiarios");
  console.log("");
  console.log("═══════════════════════════════════════════════════════");
  console.log("CREDENCIALES:");
  console.log("─────────────────────────────────────────────────────");
  console.log("ADMIN:");
  console.log("  Email:      admin@buskandoparche.com");
  console.log("  Contraseña: Admin2024!");
  console.log("");
  console.log("FORMADORES (contraseña: Formador2024!):");
  for (let i = 0; i < formadores.length; i++) {
    const num = String(i + 1).padStart(2, "0");
    console.log(`  formador${num}@buskandoparche.com → ${formadores[i].firstName} ${formadores[i].lastName} (${formadores[i].especialidad})`);
  }
  console.log("");
  console.log("BENEFICIARIOS (contraseña: BuskandoParche2024!):");
  console.log("  beneficiario001@buskandoparche.com → beneficiario080@buskandoparche.com");
  console.log("  Curso 1 (Mktg): 001-020 | Curso 2 (Inglés): 021-040");
  console.log("  Curso 3 (Gest): 041-060 | Curso 4 (Turismo): 061-080");
  console.log("═══════════════════════════════════════════════════════");
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
'@ | Set-Content "backend\prisma\seed.js"

Write-Host "✅ seed.js actualizado con 85 usuarios" -ForegroundColor Green

# ── 2. TAILWIND - COLORES BLANCOS/ROJOS como la foto ─────────────────────
Write-Host "🎨 Actualizando paleta de colores (fondo blanco, header rojo)..." -ForegroundColor Cyan

@'
/** @type {import("tailwindcss").Config} */
module.exports = {
  content: ["./src/**/*.{js,ts,jsx,tsx,mdx}"],
  theme: {
    extend: {
      colors: {
        primary:   { DEFAULT: "#C0392B", light: "#E74C3C", dark: "#922B21" },
        secondary: { DEFAULT: "#F39C12", light: "#F5C518", dark: "#D68910" },
        surface:   { DEFAULT: "#FFFFFF", card: "#FFFFFF", border: "#E5E7EB", muted: "#F3F4F6" },
        text:      { primary: "#111827", secondary: "#374151", muted: "#9CA3AF" },
        success: "#16A34A", warning: "#D97706", error: "#DC2626", info: "#2563EB",
      },
      fontFamily: {
        sans: ["Inter", "system-ui", "sans-serif"],
        display: ["Poppins", "sans-serif"],
      },
      backgroundImage: {
        "gradient-brand": "linear-gradient(135deg, #C0392B 0%, #922B21 100%)",
        "gradient-card":  "linear-gradient(135deg, #FFFFFF 0%, #F9FAFB 100%)",
        "header-red":     "linear-gradient(90deg, #C0392B 0%, #E74C3C 100%)",
      },
      boxShadow: {
        brand: "0 4px 24px rgba(192,57,43,0.25)",
        card:  "0 2px 12px rgba(0,0,0,0.08)",
        glow:  "0 0 20px rgba(243,156,18,0.3)",
      },
      animation: {
        "fade-in":  "fadeIn 0.3s ease-out",
        "slide-up": "slideUp 0.4s ease-out",
      },
      keyframes: {
        fadeIn:  { from: { opacity: 0 }, to: { opacity: 1 } },
        slideUp: { from: { transform: "translateY(20px)", opacity: 0 }, to: { transform: "translateY(0)", opacity: 1 } },
      },
    },
  },
  plugins: [],
};
'@ | Set-Content "frontend\tailwind.config.js"

Write-Host "✅ tailwind.config.js actualizado" -ForegroundColor Green

# ── 3. GLOBALS CSS ────────────────────────────────────────────────────────
@'
@import url("https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&family=Poppins:wght@600;700;800&display=swap");
@tailwind base;
@tailwind components;
@tailwind utilities;

@layer base {
  html { @apply bg-white text-text-primary; }
  body { @apply bg-gray-50; }
  * { @apply border-surface-border; }
}

@layer components {
  .btn-primary   { @apply bg-primary hover:bg-primary-dark text-white font-semibold px-6 py-3 rounded-lg transition-all duration-200 shadow-brand hover:shadow-lg active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed; }
  .btn-secondary { @apply bg-secondary hover:bg-secondary-dark text-white font-semibold px-6 py-3 rounded-lg transition-all duration-200 active:scale-95; }
  .btn-ghost     { @apply text-text-secondary hover:text-primary hover:bg-red-50 px-4 py-2 rounded-lg transition-all duration-200; }
  .card          { @apply bg-white rounded-2xl border border-surface-border shadow-card p-6; }
  .input         { @apply w-full bg-white border border-gray-300 rounded-lg px-4 py-3 text-text-primary placeholder-text-muted focus:outline-none focus:ring-2 focus:ring-primary focus:border-transparent transition-all duration-200; }
  .badge         { @apply inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold; }
  .badge-primary   { @apply badge bg-red-100 text-primary; }
  .badge-secondary { @apply badge bg-yellow-100 text-yellow-700; }
  .badge-success   { @apply badge bg-green-100 text-green-700; }
  .badge-warning   { @apply badge bg-orange-100 text-orange-700; }
  .badge-muted     { @apply badge bg-gray-100 text-gray-600; }
  .header-app    { @apply bg-gradient-brand text-white shadow-brand; }
}
'@ | Set-Content "frontend\src\app\globals.css"

Write-Host "✅ globals.css actualizado" -ForegroundColor Green

# ── 4. SIDEBAR CLARO ───────────────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\components\layout" | Out-Null

@'
"use client";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import { LayoutDashboard, BookOpen, Users, ClipboardList, MessageSquare, Award, LogOut, MapPin, ChevronRight, BarChart3 } from "lucide-react";
import clsx from "clsx";

const navByRole = {
  ADMIN: [
    { href: "/admin",          icon: LayoutDashboard, label: "Dashboard" },
    { href: "/admin/users",    icon: Users,            label: "Usuarios" },
    { href: "/admin/courses",  icon: BookOpen,         label: "Cursos" },
    { href: "/admin/reports",  icon: BarChart3,        label: "Reportes" },
  ],
  FORMADOR: [
    { href: "/formador",            icon: LayoutDashboard, label: "Panel" },
    { href: "/formador/courses",    icon: BookOpen,        label: "Mis Cursos" },
    { href: "/formador/attendance", icon: ClipboardList,   label: "Asistencia" },
  ],
  BENEFICIARIO: [
    { href: "/lobby",              icon: BookOpen,       label: "Mis Cursos" },
    { href: "/lobby/forum",        icon: MessageSquare,  label: "Foro" },
    { href: "/lobby/certificates", icon: Award,          label: "Certificados" },
  ],
};

export default function Sidebar() {
  const { user, logout } = useAuth();
  const pathname = usePathname();
  const nav = user ? navByRole[user.role] || [] : [];

  return (
    <aside className="w-64 min-h-screen bg-white border-r border-gray-200 flex flex-col shadow-sm">
      {/* Logo / Header */}
      <div className="bg-gradient-brand p-5">
        <div className="flex items-center gap-3">
          <div className="bg-white/20 p-2 rounded-xl">
            <MapPin className="w-5 h-5 text-white" />
          </div>
          <div>
            <p className="font-display font-bold text-white text-sm leading-tight">Buskando Parche</p>
            <p className="text-white/70 text-xs">LMS · Kennedy, Bogotá</p>
          </div>
        </div>
      </div>

      {/* User info */}
      <div className="p-4 border-b border-gray-100 bg-gray-50">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-gradient-brand rounded-full flex items-center justify-center font-bold text-white text-sm flex-shrink-0">
            {user?.firstName?.[0]}{user?.lastName?.[0]}
          </div>
          <div className="flex-1 min-w-0">
            <p className="text-sm font-semibold text-text-primary truncate">{user?.firstName} {user?.lastName}</p>
            <span className={clsx("badge text-xs mt-0.5", {
              "badge-primary": user?.role === "ADMIN",
              "badge-secondary": user?.role === "FORMADOR",
              "badge-muted": user?.role === "BENEFICIARIO",
            })}>
              {user?.role === "ADMIN" ? "Administrador" : user?.role === "FORMADOR" ? "Formador" : "Beneficiario"}
            </span>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 p-4 space-y-1">
        {nav.map(({ href, icon: Icon, label }) => {
          const isActive = pathname === href || pathname.startsWith(href + "/");
          return (
            <Link key={href} href={href} className={clsx(
              "flex items-center gap-3 px-3 py-2.5 rounded-xl text-sm font-medium transition-all duration-200 group",
              isActive ? "bg-red-50 text-primary border border-red-100" : "text-text-secondary hover:bg-gray-50 hover:text-primary"
            )}>
              <Icon className={clsx("w-5 h-5", isActive ? "text-primary" : "text-gray-400 group-hover:text-primary")} />
              {label}
              {isActive && <ChevronRight className="w-4 h-4 ml-auto text-primary" />}
            </Link>
          );
        })}
      </nav>

      <div className="p-4 border-t border-gray-100">
        <button onClick={logout} className="btn-ghost w-full flex items-center gap-3 text-sm text-gray-500">
          <LogOut className="w-5 h-5" /> Cerrar sesión
        </button>
      </div>
    </aside>
  );
}
'@ | Set-Content "frontend\src\components\layout\Sidebar.tsx"

Write-Host "✅ Sidebar actualizado (tema claro)" -ForegroundColor Green

# ── 5. APP SHELL ───────────────────────────────────────────────────────────
@'
"use client";
import { useAuth } from "@/contexts/AuthContext";
import { useRouter } from "next/navigation";
import { useEffect } from "react";
import Sidebar from "./Sidebar";
import { Loader2 } from "lucide-react";

export default function AppShell({ children, allowedRoles }: { children: React.ReactNode; allowedRoles: string[] }) {
  const { user, isLoading } = useAuth();
  const router = useRouter();
  useEffect(() => {
    if (!isLoading && !user) router.push("/login");
    if (!isLoading && user && !allowedRoles.includes(user.role)) router.push("/login");
  }, [user, isLoading]);
  if (isLoading) return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <Loader2 className="w-8 h-8 text-primary animate-spin" />
    </div>
  );
  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 overflow-y-auto animate-fade-in">
        {/* Top bar */}
        <div className="bg-white border-b border-gray-200 px-8 py-4 flex items-center justify-between">
          <div className="h-8 w-32 relative">
            <span className="font-display font-bold text-primary text-xl">Buskando <span className="text-secondary">Parche</span></span>
          </div>
          <span className="text-sm text-text-muted">Programa de Formación · Kennedy</span>
        </div>
        <div className="p-8">{children}</div>
      </main>
    </div>
  );
}
'@ | Set-Content "frontend\src\components\layout\AppShell.tsx"

Write-Host "✅ AppShell actualizado" -ForegroundColor Green

# ── 6. LOGIN CON VIDEO ────────────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\public\videos" | Out-Null
New-Item -ItemType Directory -Force -Path "frontend\public\images" | Out-Null

@'
"use client";
import { useState } from "react";
import { useRouter } from "next/navigation";
import { useAuth } from "@/contexts/AuthContext";
import toast from "react-hot-toast";
import { Lock, Mail, Loader2 } from "lucide-react";
import Image from "next/image";

export default function LoginPage() {
  const { login } = useAuth();
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    try {
      await login(email, password);
      const payload = JSON.parse(atob(localStorage.getItem("bp_token")!.split(".")[1]));
      if (payload.role === "ADMIN") router.push("/admin");
      else if (payload.role === "FORMADOR") router.push("/formador");
      else router.push("/lobby");
    } catch {
      toast.error("Credenciales incorrectas. Verifica tu email y contraseña.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center relative overflow-hidden">

      {/* VIDEO DE FONDO */}
      <video
        autoPlay muted loop playsInline
        className="absolute inset-0 w-full h-full object-cover z-0"
      >
        <source src="/videos/kennedy.mp4" type="video/mp4" />
      </video>

      {/* Overlay oscuro semitransparente */}
      <div className="absolute inset-0 bg-black/60 z-10" />

      {/* Contenido del login */}
      <div className="relative z-20 w-full max-w-md px-6 animate-slide-up">

        {/* Logo */}
        <div className="flex flex-col items-center mb-8">
          <div className="bg-white rounded-2xl p-4 shadow-2xl mb-4">
            <img
              src="/images/logo.png"
              alt="Buskando Parche"
              className="h-20 w-auto object-contain"
              onError={(e) => {
                (e.target as HTMLImageElement).style.display = "none";
              }}
            />
          </div>
          <h1 className="font-display text-3xl font-bold text-white text-center drop-shadow-lg">
            Buskando <span className="text-secondary">Parche</span>
          </h1>
          <p className="text-white/80 text-sm mt-1 text-center">
            Plataforma de Formación · Kennedy, Bogotá
          </p>
        </div>

        {/* Card de login */}
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <h2 className="text-xl font-bold text-text-primary mb-1">Iniciar sesión</h2>
          <p className="text-text-muted text-sm mb-6">Ingresa con tus credenciales asignadas</p>

          <form onSubmit={handleSubmit} className="space-y-4">
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Correo electrónico</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input type="email" className="input pl-10" placeholder="tu@correo.com"
                  value={email} onChange={(e) => setEmail(e.target.value)} required />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-text-secondary mb-1.5">Contraseña</label>
              <div className="relative">
                <Lock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                <input type="password" className="input pl-10" placeholder="••••••••"
                  value={password} onChange={(e) => setPassword(e.target.value)} required />
              </div>
            </div>
            <button type="submit" disabled={loading} className="btn-primary w-full flex items-center justify-center gap-2 mt-2">
              {loading && <Loader2 className="w-5 h-5 animate-spin" />}
              {loading ? "Ingresando..." : "Ingresar a la plataforma"}
            </button>
          </form>

          <p className="text-center text-text-muted text-xs mt-4">
            ¿Problemas para ingresar? Contacta al coordinador del programa.
          </p>
        </div>

        <p className="text-center text-white/50 text-xs mt-6">
          © 2024 Buskando Parche · Alcaldía de Bogotá · Kennedy
        </p>
      </div>
    </div>
  );
}
'@ | Set-Content "frontend\src\app\login\page.tsx"

Write-Host "✅ Login con video de fondo actualizado" -ForegroundColor Green

# ── 7. LOBBY ACTUALIZADO ────────────────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(student)\lobby" | Out-Null

@'
"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { useAuth } from "@/contexts/AuthContext";
import { BookOpen, Lock, Users, PlayCircle, Search, CheckCircle, Loader2, Clock } from "lucide-react";
import Link from "next/link";
import clsx from "clsx";

const courseImages: Record<string, string> = {
  "Marketing Digital Turístico": "/images/marketing.jpg",
  "Inglés en el Turismo":         "/images/ingles.jpg",
  "Gestión Empresarial":          "/images/gestion.jpg",
  "Turismo Sostenible":           "/images/turismo.jpg",
};

const courseFallback = ["#C0392B", "#2563EB", "#16A34A", "#D97706"];

export default function LobbyPage() {
  const { user } = useAuth();
  const [courses, setCourses] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState("");

  useEffect(() => {
    api.get("/courses/lobby")
      .then(({ data }) => setCourses(data))
      .finally(() => setLoading(false));
  }, []);

  const filtered = courses.filter((c: any) =>
    c.title.toLowerCase().includes(search.toLowerCase())
  );
  const enrolled = filtered.filter((c: any) => c.isEnrolled);
  const locked   = filtered.filter((c: any) => !c.isEnrolled);

  return (
    <AppShell allowedRoles={["BENEFICIARIO"]}>
      <div className="max-w-5xl mx-auto space-y-8">

        {/* Header */}
        <div className="flex items-start justify-between">
          <div>
            <h1 className="font-display text-3xl font-bold text-text-primary">
              Hola, <span className="text-primary">{user?.firstName}</span> 👋
            </h1>
            <p className="text-text-secondary mt-1">Bienvenido a tu espacio de aprendizaje en Buskando Parche.</p>
          </div>
        </div>

        {/* Buscador */}
        <div className="relative max-w-md">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
          <input className="input pl-10" placeholder="Buscar cursos..." value={search}
            onChange={(e) => setSearch(e.target.value)} />
        </div>

        {loading ? (
          <div className="flex justify-center py-20">
            <Loader2 className="w-8 h-8 text-primary animate-spin" />
          </div>
        ) : (
          <>
            {/* Mis cursos (inscritos) */}
            {enrolled.length > 0 && (
              <section>
                <div className="flex items-center gap-2 mb-5">
                  <div className="w-1 h-6 bg-primary rounded-full" />
                  <h2 className="text-xl font-bold text-text-primary">Mis Cursos</h2>
                  <span className="badge-primary ml-1">{enrolled.length} inscrito</span>
                </div>
                <div className="grid md:grid-cols-2 gap-5">
                  {enrolled.map((course: any, idx: number) => (
                    <div key={course.id} className="card overflow-hidden p-0 hover:shadow-lg transition-shadow group">
                      {/* Imagen */}
                      <div className="relative h-44 overflow-hidden">
                        <img
                          src={courseImages[course.title] || ""}
                          alt={course.title}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-300"
                          onError={(e) => {
                            const el = e.target as HTMLImageElement;
                            el.style.display = "none";
                            el.parentElement!.style.background = courseFallback[idx % 4];
                          }}
                        />
                        <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
                        <div className="absolute top-3 left-3">
                          <span className="badge-success"><CheckCircle className="w-3 h-3" /> Inscrito</span>
                        </div>
                        <div className="absolute top-3 right-3">
                          <span className={clsx("badge", course.modality === "VIRTUAL" ? "bg-blue-100 text-blue-700" : "bg-green-100 text-green-700")}>
                            {course.modality === "VIRTUAL" ? "Virtual" : "Presencial"}
                          </span>
                        </div>
                      </div>
                      <div className="p-5">
                        <h3 className="font-bold text-lg text-text-primary mb-1">{course.title}</h3>
                        <p className="text-text-muted text-sm line-clamp-2 mb-4">{course.description}</p>
                        <div className="flex items-center gap-4 text-xs text-text-muted mb-4">
                          <span className="flex items-center gap-1"><PlayCircle className="w-4 h-4" /> {course.totalSessions} sesiones</span>
                          <span className="flex items-center gap-1"><Users className="w-4 h-4" /> {course.totalEnrolled} inscritos</span>
                        </div>
                        <Link href={`/courses/${course.id}`} className="btn-primary w-full text-center block py-2.5 text-sm">
                          Acceder al curso →
                        </Link>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}

            {/* Cursos bloqueados */}
            {locked.length > 0 && (
              <section>
                <div className="flex items-center gap-2 mb-5">
                  <div className="w-1 h-6 bg-gray-300 rounded-full" />
                  <h2 className="text-xl font-bold text-text-primary">Otros programas disponibles</h2>
                  <span className="badge-muted">{locked.length}</span>
                </div>
                <p className="text-text-muted text-sm mb-4 flex items-center gap-2">
                  <Lock className="w-4 h-4" />
                  El acceso a estos programas es solo para participantes asignados por el coordinador.
                </p>
                <div className="grid md:grid-cols-2 gap-5">
                  {locked.map((course: any, idx: number) => (
                    <div key={course.id} className="card overflow-hidden p-0 opacity-60 cursor-not-allowed">
                      <div className="relative h-44 overflow-hidden bg-gray-200">
                        <img
                          src={courseImages[course.title] || ""}
                          alt={course.title}
                          className="w-full h-full object-cover grayscale"
                          onError={(e) => { (e.target as HTMLImageElement).style.display = "none"; }}
                        />
                        <div className="absolute inset-0 bg-gray-900/50 flex items-center justify-center">
                          <div className="bg-white/90 rounded-full p-3">
                            <Lock className="w-6 h-6 text-gray-500" />
                          </div>
                        </div>
                      </div>
                      <div className="p-5">
                        <h3 className="font-bold text-lg text-gray-500 mb-1">{course.title}</h3>
                        <p className="text-gray-400 text-sm line-clamp-2 mb-4">{course.description}</p>
                        <div className="bg-gray-100 rounded-lg px-4 py-2.5 text-center text-sm text-gray-500 flex items-center justify-center gap-2">
                          <Lock className="w-4 h-4" /> Solo para participantes asignados
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </section>
            )}

            {enrolled.length === 0 && !loading && (
              <div className="text-center py-16 card">
                <BookOpen className="w-12 h-12 text-gray-300 mx-auto mb-4" />
                <h3 className="font-semibold text-text-primary mb-2">Aún no tienes cursos asignados</h3>
                <p className="text-text-muted text-sm">El coordinador del programa te asignará un curso pronto.</p>
              </div>
            )}
          </>
        )}
      </div>
    </AppShell>
  );
}
'@ | Set-Content "frontend\src\app\(student)\lobby\page.tsx"

Write-Host "✅ Lobby actualizado con diseño de tarjetas" -ForegroundColor Green

# ── 8. ADMIN DASHBOARD ARREGLADO ──────────────────────────────────────────
New-Item -ItemType Directory -Force -Path "frontend\src\app\(dashboard)\admin" | Out-Null

@'
"use client";
import { useEffect, useState } from "react";
import AppShell from "@/components/layout/AppShell";
import api from "@/lib/api";
import { Users, BookOpen, TrendingUp, Heart, Loader2, AlertTriangle, CheckCircle, UserCheck } from "lucide-react";
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, Cell, PieChart, Pie, Legend } from "recharts";

function KpiCard({ label, value, icon: Icon, color, subtitle }: any) {
  const colors: any = {
    red:    "bg-red-50 text-red-600 border-red-100",
    yellow: "bg-yellow-50 text-yellow-600 border-yellow-100",
    green:  "bg-green-50 text-green-600 border-green-100",
    blue:   "bg-blue-50 text-blue-600 border-blue-100",
  };
  return (
    <div className="card flex items-start gap-4">
      <div className={`p-3 rounded-xl border flex-shrink-0 ${colors[color]}`}>
        <Icon className="w-6 h-6" />
      </div>
      <div>
        <p className="text-text-muted text-sm">{label}</p>
        <p className="text-2xl font-bold font-display text-text-primary mt-0.5">{value}</p>
        {subtitle && <p className="text-text-muted text-xs mt-1">{subtitle}</p>}
      </div>
    </div>
  );
}

const PIE_COLORS = ["#C0392B","#2563EB","#16A34A","#D97706","#7C3AED","#EC4899"];

export default function AdminDashboard() {
  const [data, setData] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    api.get("/admin/dashboard")
      .then(({ data }) => setData(data))
      .catch(() => setError("No se pudo cargar el dashboard. Verifica que el backend esté corriendo."))
      .finally(() => setLoading(false));
  }, []);

  if (loading) return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="flex justify-center py-20"><Loader2 className="w-8 h-8 text-primary animate-spin" /></div>
    </AppShell>
  );

  if (error) return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="card bg-red-50 border-red-200 text-red-700 flex items-center gap-3">
        <AlertTriangle className="w-5 h-5" />{error}
      </div>
    </AppShell>
  );

  return (
    <AppShell allowedRoles={["ADMIN"]}>
      <div className="max-w-6xl mx-auto space-y-8">
        <div>
          <h1 className="font-display text-3xl font-bold text-text-primary">Dashboard Administrativo</h1>
          <p className="text-text-secondary mt-1">Monitoreo general del programa de formación</p>
        </div>

        {/* KPIs */}
        <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
          <KpiCard label="Total beneficiarios"    value={data?.kpis.totalBeneficiarios}    icon={Users}      color="red"    subtitle="de 80 cupos objetivo" />
          <KpiCard label="% Asistencia global"    value={data?.kpis.porcentajeAsistencia}  icon={TrendingUp} color="green"  subtitle="Todas las sesiones" />
          <KpiCard label="Cursos activos"         value={data?.kpis.totalCourses}          icon={BookOpen}   color="blue"   subtitle="Programas publicados" />
          <KpiCard label="Meta género (mujeres)"  value={data?.kpis.porcentajeMujeres}     icon={Heart}      color="yellow" subtitle={data?.kpis.metaMujeres} />
        </div>

        {/* Gráficas */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="card">
            <h3 className="font-bold text-text-primary mb-4">Inscritos por curso</h3>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={data?.courseKpis} barSize={36}>
                <XAxis dataKey="title" tick={{ fill: "#6B7280", fontSize: 10 }} tickLine={false} />
                <YAxis tick={{ fill: "#6B7280", fontSize: 11 }} axisLine={false} tickLine={false} />
                <Tooltip contentStyle={{ background: "#fff", border: "1px solid #E5E7EB", borderRadius: 8 }} />
                <Bar dataKey="inscritos" radius={[6,6,0,0]}>
                  {data?.courseKpis?.map((_: any, i: number) => (
                    <Cell key={i} fill={i % 2 === 0 ? "#C0392B" : "#F39C12"} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>

          <div className="card">
            <h3 className="font-bold text-text-primary mb-4">Grupos poblacionales</h3>
            {data?.populationBreakdown?.length > 0 ? (
              <ResponsiveContainer width="100%" height={220}>
                <PieChart>
                  <Pie data={data.populationBreakdown} dataKey="cantidad" nameKey="grupo" cx="50%" cy="50%" outerRadius={80} label>
                    {data.populationBreakdown.map((_: any, i: number) => (
                      <Cell key={i} fill={PIE_COLORS[i % PIE_COLORS.length]} />
                    ))}
                  </Pie>
                  <Tooltip />
                  <Legend />
                </PieChart>
              </ResponsiveContainer>
            ) : (
              <p className="text-text-muted text-sm py-8 text-center">Sin datos de grupos poblacionales aún</p>
            )}
          </div>
        </div>

        {/* Alerta meta género */}
        <div className={`flex items-start gap-4 p-4 rounded-xl border ${
          data?.kpis.metaMujeres?.includes("✅") ? "bg-green-50 border-green-200 text-green-700" : "bg-yellow-50 border-yellow-200 text-yellow-700"
        }`}>
          {data?.kpis.metaMujeres?.includes("✅") ? <CheckCircle className="w-5 h-5 mt-0.5" /> : <AlertTriangle className="w-5 h-5 mt-0.5" />}
          <div>
            <p className="font-semibold text-sm">Meta de paridad de género</p>
            <p className="text-sm opacity-80 mt-0.5">
              El contrato exige mínimo 50% de mujeres beneficiarias. Actualmente: <strong>{data?.kpis.porcentajeMujeres}</strong> — {data?.kpis.metaMujeres}
            </p>
          </div>
        </div>
      </div>
    </AppShell>
  );
}
'@ | Set-Content "frontend\src\app\(dashboard)\admin\page.tsx"

Write-Host "✅ Admin dashboard arreglado" -ForegroundColor Green

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "✅  TODOS LOS CAMBIOS APLICADOS" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "📌 SIGUIENTE PASO - Copia el video y las imágenes:" -ForegroundColor Cyan
Write-Host "   Video:    copia 'kennedy.mp4'  → frontend\public\videos\kennedy.mp4"
Write-Host "   Logo:     copia 'LOGO_.png'    → frontend\public\images\logo.png"
Write-Host "   Imágenes: copia las demás      → frontend\public\images\"
Write-Host ""
Write-Host "Luego ejecuta:" -ForegroundColor Cyan
Write-Host "   docker-compose down" -ForegroundColor White
Write-Host "   docker-compose up --build" -ForegroundColor White
Write-Host ""
