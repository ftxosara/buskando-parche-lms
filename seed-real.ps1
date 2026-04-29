Write-Host "=== SEED CON BENEFICIARIOS REALES ===" -ForegroundColor Yellow

# Seed con los 47 beneficiarios reales de la lista
$seedContent = 'const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();

const CURSOS = [
  { title: "Ingles",               description: "Ingles para el turismo.", modality: "VIRTUAL",    totalSessions: 20 },
  { title: "Gestion Empresarial",  description: "Planeacion y finanzas para MiPymes.", modality: "PRESENCIAL", totalSessions: 20 },
  { title: "Gestion Turistica",    description: "Herramientas para prestadores turisticos.", modality: "PRESENCIAL", totalSessions: 20 },
  { title: "Marketing Digital",    description: "Redes sociales y SEO para tu negocio.", modality: "VIRTUAL",    totalSessions: 20 },
];

const FORMADORES = [
  { firstName:"Maria",   lastName:"Ramirez Solano",  cedula:"9000000001", email:"formador01@buskandoparche.com" },
  { firstName:"Carlos",  lastName:"Perez Estrada",   cedula:"9000000002", email:"formador02@buskandoparche.com" },
  { firstName:"Andrea",  lastName:"Nieto Salazar",   cedula:"9000000003", email:"formador03@buskandoparche.com" },
  { firstName:"Roberto", lastName:"Lagos Cifuentes", cedula:"9000000004", email:"formador04@buskandoparche.com" },
];

// 47 beneficiarios reales del programa
// curso: I=Ingles, GE=Gestion Empresarial, GT=Gestion Turistica, MD=Marketing Digital
const BENS = [
  { fn:"Victor Hugo",    ln:"Acosta Franco",        email:"reservas@adrenalinecolombia.com",         cel:"3134849255", upz:"Carvajal",         g:"MASCULINO", p:"MIPYME",        curso:"MD" },
  { fn:"German Arnulfo", ln:"Antonio",               email:"instintoexperiencias@gmail.com",          cel:"3125109917", upz:"Calandaima",        g:"NO_BINARIO", p:"MIPYME",       curso:"MD" },
  { fn:"Yesid Orlando",  ln:"Moreno Carrillo",       email:"quimeralibre@gmail.com",                  cel:"3197839256", upz:"Americas",          g:"MASCULINO", p:"MIPYME",        curso:"GE" },
  { fn:"Sandra",         ln:"Moreno",                email:"ecososgotravel@gmail.com",                cel:"3134448112", upz:"Tintal Norte",      g:"FEMENINO",  p:"MIPYME",        curso:"I"  },
  { fn:"Daniel",         ln:"Eraso Ricaurte",        email:"nakumacc@gmail.com",                      cel:"3219598243", upz:"Castilla",          g:"MASCULINO", p:"MIPYME",        curso:"GT" },
  { fn:"David Alejandro",ln:"Guerrero Perez",        email:"pajaro.cosedor@gmail.com",                cel:"3246527150", upz:"Tintal Norte",      g:"MASCULINO", p:"MIPYME",        curso:"GT" },
  { fn:"Rocio Jackeline",ln:"Gutierrez Garcia",      email:"penumbral.cafe@gmail.com",                cel:"3203158327", upz:"Timiza",            g:"FEMENINO",  p:"MIPYME",        curso:"GT" },
  { fn:"Luisa Juliana",  ln:"Diaz Sanchez",          email:"tour24.07@gmail.com",                     cel:"3003577846", upz:"Kennedy Central",   g:"FEMENINO",  p:"MIPYME",        curso:"MD" },
  { fn:"Adriana Cecilia",ln:"Rodriguez Sanchez",     email:"thehivesuite2025@gmail.com",              cel:"3152980897", upz:"Castilla",          g:"FEMENINO",  p:"MIPYME",        curso:"MD" },
  { fn:"Liliana Marcela",ln:"Ospina Sanchez",        email:"rprofundas@gmail.com",                    cel:"3144100081", upz:"Calandaima",        g:"FEMENINO",  p:"MIPYME",        curso:"MD" },
  { fn:"Vallery Michel", ln:"Lindo Garcia",          email:"vallerygarcia22@gmail.com",               cel:"3144050657", upz:"Kennedy Central",   g:"FEMENINO",  p:"MIPYME",        curso:"GT" },
  { fn:"Edith Yeraldin", ln:"Villamil Ortiz",        email:"viajesmillasmil@gmail.com",               cel:"3024126694", upz:"Tintal Norte",      g:"FEMENINO",  p:"MIPYME",        curso:"I"  },
  { fn:"Nelson",         ln:"Reina Gomez",           email:"aviajar1a@gmail.com",                     cel:"3103268849", upz:"Kennedy Central",   g:"MASCULINO", p:"MIPYME",        curso:"MD" },
  { fn:"Nicolle",        ln:"Jaraba Vides",          email:"nijavi9508@gmail.com",                    cel:"3103758335", upz:"Las Margaritas",    g:"FEMENINO",  p:"MIPYME",        curso:"MD" },
  { fn:"Luis Miguel",    ln:"Galindo Nino",          email:"migalindon@gmail.com",                    cel:"3112777381", upz:"Bavaria",           g:"MASCULINO", p:"MIPYME",        curso:"GT" },
  { fn:"Sandra Elizabeth",ln:"Matallana Ripe",       email:"sandymatallana@yahoo.com",                cel:"3124134942", upz:"Carvajal",          g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"MD" },
  { fn:"Michelle",       ln:"Gaviria Juzga",         email:"michellegaviri3@hotmail.com",             cel:"3152193269", upz:"Castilla",          g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"MD" },
  { fn:"Jose Alejandro", ln:"Gil Garcia",            email:"ruidolabcolectivo@gmail.com",             cel:"3213682168", upz:"Timiza",            g:"MASCULINO", p:"EMPRENDEDOR",   curso:"GT" },
  { fn:"Miguel Angel",   ln:"Guerrero Ortega",       email:"guerreroortegamiguelangel@gmail.com",     cel:"3186557851", upz:"Corabastos",        g:"MASCULINO", p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Luz Angela",     ln:"Susatama Patino",       email:"langelasp@gmail.com",                     cel:"3212843939", upz:"Kennedy Central",   g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"MD" },
  { fn:"Diana Marcela",  ln:"Gonzalez Garzon",       email:"dianagonzalezgarzon@hotmail.com",         cel:"3046016657", upz:"Tintal Norte",      g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Natalia",        ln:"Bermudez",              email:"nata.alf123@hotmail.com",                 cel:"3017621999", upz:"Castilla",          g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GT" },
  { fn:"Eduardo",        ln:"Pinzon Avendano",       email:"peacepathscolombia@gmail.com",            cel:"3202804880", upz:"Patio Bonito",      g:"MASCULINO", p:"EMPRENDEDOR",   curso:"MD" },
  { fn:"Jose Gabriel",   ln:"Mesa Rodriguez",        email:"jogamero@hotmail.com",                    cel:"3115723566", upz:"Timiza",            g:"MASCULINO", p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Sandra",         ln:"Daza Barrera",          email:"sdaza2014@gmail.com",                     cel:"3053553188", upz:"Bavaria",           g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"MD" },
  { fn:"Gladys Fabiola", ln:"Revelo Grijalba",       email:"saturia18@hotmail.com",                   cel:"3204099589", upz:"Kennedy Central",   g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GT" },
  { fn:"Johanys",        ln:"Sanchez Ramirez",       email:"johanysworkout@gmail.com",                cel:"3022753685", upz:"Gran Britalia",     g:"MASCULINO", p:"EMPRENDEDOR",   curso:"MD" },
  { fn:"Beatriz Elena",  ln:"Zapata Lopez",          email:"postresyregalosimperio@gmail.com",        cel:"3222276661", upz:"Kennedy Central",   g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Jorge",          ln:"Henech",                email:"almejatours@gmail.com",                   cel:"3003148451", upz:"Castilla",          g:"MASCULINO", p:"EMPRENDEDOR",   curso:"MD" },
  { fn:"Angela Johanna", ln:"Duran Rodriguez",       email:"angeladuranr05@gmail.com",                cel:"3168040445", upz:"Calandaima",        g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GE" },
  { fn:"Paola Andrea",   ln:"Riveros Rengifo",       email:"paola.riveros.rengifo@hotmail.com",       cel:"3212113663", upz:"Americas",          g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Jeimmy Andrea",  ln:"Jimenez Carranza",      email:"jeimmyjimenezc1@gmail.com",               cel:"3112810125", upz:"Calandaima",        g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GE" },
  { fn:"Jesus David",    ln:"Ramirez Alvarez",       email:"davidramirez21102015@gmail.com",          cel:"3227262124", upz:"Timiza",            g:"MASCULINO", p:"EMPRENDEDOR",   curso:"MD" },
  { fn:"Gloria Esperanza",ln:"Gomez Marin",          email:"glorianita20@gmail.com",                  cel:"3118462838", upz:"Castilla",          g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GE" },
  { fn:"Alberto Ruiz",   ln:"Ruiz Pardo",            email:"alruiz452000@hotmail.com",                cel:"3112744499", upz:"Timiza",            g:"MASCULINO", p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Eczal Lucia",    ln:"Perez Caro",            email:"eczalluciaperezcaro@gmail.com",           cel:"3212921172", upz:"Kennedy Central",   g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Luisa Fernanda", ln:"Ruiz Moreno",           email:"luisa071622@gmail.com",                   cel:"3223909876", upz:"Kennedy Central",   g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GT" },
  { fn:"Sandra Milena",  ln:"Ariza Osma",            email:"atataosma@gmail.com",                     cel:"3174086671", upz:"Calandaima",        g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GE" },
  { fn:"Angela Maria",   ln:"Lopez Castano",         email:"tatianaparraga1@hotmail.com",             cel:"3246744725", upz:"Calandaima",        g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GE" },
  { fn:"Maria Adalyde",  ln:"Pena Gamboa",           email:"adalydepena2@gmail.com",                  cel:"3142139747", upz:"Kennedy Central",   g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GT" },
  { fn:"Jose Daniel",    ln:"Urrego Ramirez",        email:"talentosmusicales2022@gmail.com",         cel:"3155150733", upz:"Kennedy Central",   g:"MASCULINO", p:"EMPRENDEDOR",   curso:"GE" },
  { fn:"Natalia",        ln:"Otalora Munoz",         email:"nataotalora@gmail.com",                   cel:"3192357828", upz:"Timiza",            g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Mariana",        ln:"Vanegas Munoz",         email:"briznadefe@gmail.com",                    cel:"3245808409", upz:"Tintal Norte",      g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Katherine",      ln:"Baron",                 email:"katicospawn@yahoo.com",                   cel:"3115708910", upz:"Carvajal",          g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GT" },
  { fn:"Ruth",           ln:"Beltran",               email:"pastoraruth05@gmail.com",                 cel:"3107506276", upz:"Patio Bonito",      g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Karen",          ln:"Castano Aventours",     email:"kasthelves@gmail.com",                    cel:"3115792840", upz:"Kennedy Central",   g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"I"  },
  { fn:"Maite",          ln:"Moreno MM Creaciones",  email:"aceromiam@hotmail.com",                   cel:"3203930849", upz:"Kennedy Central",   g:"FEMENINO",  p:"EMPRENDEDOR",   curso:"GE" },
];

async function main() {
  console.log("Eliminando TODOS los beneficiarios anteriores...");
  const oldBens = await prisma.user.findMany({ where: { role: "BENEFICIARIO" } });
  for (const u of oldBens) {
    await prisma.enrollment.deleteMany({ where: { userId: u.id } });
    await prisma.attendance.deleteMany({ where: { userId: u.id } });
    await prisma.submission.deleteMany({ where: { userId: u.id } });
    await prisma.forumPost.deleteMany({ where: { authorId: u.id } }).catch(()=>{});
    await prisma.user.delete({ where: { id: u.id } });
  }
  console.log("Beneficiarios anteriores eliminados.");

  // Admin
  await prisma.user.upsert({ where:{email:"admin@buskandoparche.com"}, update:{}, create:{
    email:"admin@buskandoparche.com", passwordHash: await bcrypt.hash("Admin2024!",12),
    role:"ADMIN", firstName:"Admin", lastName:"Sistema", cedula:"8000000001"
  }});

  // 4 Formadores
  const fUsers = [];
  for (let i=0; i<FORMADORES.length; i++) {
    const f = FORMADORES[i];
    const u = await prisma.user.upsert({ where:{email:f.email}, update:{}, create:{
      email:f.email, passwordHash: await bcrypt.hash("Formador2024!",12),
      role:"FORMADOR", firstName:f.firstName, lastName:f.lastName, cedula:f.cedula
    }});
    fUsers.push(u);
  }

  // 4 Cursos
  const cursoMap = { I:null, GE:null, GT:null, MD:null };
  const cursoKeys = ["I","GE","GT","MD"];
  for (let i=0; i<CURSOS.length; i++) {
    const c = CURSOS[i];
    const ex = await prisma.course.findFirst({ where:{title:c.title} });
    const course = ex
      ? await prisma.course.update({ where:{id:ex.id}, data:{...c, isPublished:true, formadorId:fUsers[i].id} })
      : await prisma.course.create({ data:{...c, isPublished:true, formadorId:fUsers[i].id} });
    cursoMap[cursoKeys[i]] = course;
    const existing = await prisma.session.count({ where:{courseId:course.id} });
    if (existing === 0) {
      for (let s=1; s<=20; s++) {
        await prisma.session.create({ data:{courseId:course.id, title:"Sesion "+s, description:"Contenido sesion "+s, order:s} });
      }
    }
  }

  // 47 Beneficiarios reales
  const hashB = await bcrypt.hash("BuskandoParche2024!", 12);
  let count = 0;
  for (let i=0; i<BENS.length; i++) {
    const b = BENS[i];
    const cedula = "20260" + String(i+1).padStart(3,"0");
    const u = await prisma.user.create({ data:{
      email: b.email.toLowerCase().trim(),
      passwordHash: hashB,
      role: "BENEFICIARIO",
      firstName: b.fn,
      lastName: b.ln,
      cedula: cedula,
      phone: b.cel,
      gender: b.g,
      populationGroup: b.p,
      locality: "Kennedy",
      upz: b.upz,
    }});
    const course = cursoMap[b.curso];
    if (course) {
      await prisma.enrollment.create({ data:{ userId:u.id, courseId:course.id, status:"ACTIVO" } });
    }
    count++;
  }

  console.log("SEED OK - " + count + " beneficiarios reales cargados");
  console.log("Distribucion de cursos:");
  const ci = BENS.filter(b=>b.curso==="I").length;
  const cge = BENS.filter(b=>b.curso==="GE").length;
  const cgt = BENS.filter(b=>b.curso==="GT").length;
  const cmd = BENS.filter(b=>b.curso==="MD").length;
  console.log("  Ingles: " + ci);
  console.log("  Gestion Empresarial: " + cge);
  console.log("  Gestion Turistica: " + cgt);
  console.log("  Marketing Digital: " + cmd);
  console.log("Credenciales beneficiarios: email real / BuskandoParche2024!");
  console.log("Admin: admin@buskandoparche.com / Admin2024!");
}

main().catch(e=>{console.error(e);process.exit(1);}).finally(()=>prisma.$disconnect());
'
[System.IO.File]::WriteAllText("$PWD\backend\prisma\seed.js", $seedContent, [System.Text.Encoding]::UTF8)
Write-Host "seed.js con 47 beneficiarios reales OK" -ForegroundColor Green

Write-Host ""
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host "SEED REAL LISTO" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Yellow
Write-Host ""
Write-Host "Este seed:" -ForegroundColor Cyan
Write-Host "  - ELIMINA todos los beneficiarios de prueba"
Write-Host "  - Carga los 47 beneficiarios reales del Excel"
Write-Host "  - Usa su email real como usuario de login"
Write-Host "  - Clave unica: BuskandoParche2024!"
Write-Host ""
Write-Host "Distribucion por curso:"
Write-Host "  Ingles:              13 personas"
Write-Host "  Gestion Empresarial:  8 personas"
Write-Host "  Gestion Turistica:   11 personas"
Write-Host "  Marketing Digital:   15 personas"
Write-Host "  Total: 47 (los 3 faltantes los agregas desde el admin)"
Write-Host ""
Write-Host "EJECUTA:" -ForegroundColor Red
Write-Host "  docker-compose down -v" -ForegroundColor White
Write-Host "  docker-compose up --build" -ForegroundColor White
