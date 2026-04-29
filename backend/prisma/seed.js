const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();

const CURSOS = [
  { title:"Ingles",               description:"Ingles para el turismo.",                        modality:"VIRTUAL",    totalSessions:20 },
  { title:"Gestion Empresarial",  description:"Planeacion y finanzas para MiPymes.",            modality:"PRESENCIAL", totalSessions:20 },
  { title:"Gestion Turistica",    description:"Herramientas para prestadores turisticos.",      modality:"PRESENCIAL", totalSessions:20 },
  { title:"Marketing Digital",    description:"Redes sociales y SEO para tu negocio.",          modality:"VIRTUAL",    totalSessions:20 },
];

const FORMADORES = [
  { firstName:"Maria",   lastName:"Ramirez Solano",  cedula:"9000000001", email:"formador01@buskandoparche.com" },
  { firstName:"Carlos",  lastName:"Perez Estrada",   cedula:"9000000002", email:"formador02@buskandoparche.com" },
  { firstName:"Andrea",  lastName:"Nieto Salazar",   cedula:"9000000003", email:"formador03@buskandoparche.com" },
  { firstName:"Roberto", lastName:"Lagos Cifuentes", cedula:"9000000004", email:"formador04@buskandoparche.com" },
];

// genero: FEMENINO | MASCULINO | NO_BINARIO (incluye LGBTIQ+)
// curso:  I=Ingles | GE=Gestion Empresarial | GT=Gestion Turistica | MD=Marketing Digital
const BENS = [
  // --- MIPYMES ---
  { fn:"Victor Hugo",     ln:"Acosta Franco",       email:"reservas@adrenalinecolombia.com",      cel:"3134849255", upz:"Carvajal",       g:"MASCULINO",  p:"MIPYME", curso:"MD" },
  { fn:"German Arnulfo",  ln:"Antonio",              email:"instintoexperiencias@gmail.com",       cel:"3125109917", upz:"Calandaima",     g:"NO_BINARIO", p:"MIPYME", curso:"MD" },
  { fn:"Yesid Orlando",   ln:"Moreno Carrillo",      email:"quimeralibre@gmail.com",               cel:"3197839256", upz:"Americas",       g:"MASCULINO",  p:"MIPYME", curso:"GE" },
  { fn:"Sandra",          ln:"Moreno",               email:"ecososgotravel@gmail.com",             cel:"3134448112", upz:"Tintal Norte",   g:"FEMENINO",   p:"MIPYME", curso:"I"  },
  { fn:"Daniel",          ln:"Eraso Ricaurte",       email:"nakumacc@gmail.com",                   cel:"3219598243", upz:"Castilla",       g:"MASCULINO",  p:"MIPYME", curso:"GT" },
  { fn:"David Alejandro", ln:"Guerrero Perez",       email:"pajaro.cosedor@gmail.com",             cel:"3246527150", upz:"Tintal Norte",   g:"MASCULINO",  p:"MIPYME", curso:"GT" },
  { fn:"Rocio Jackeline", ln:"Gutierrez Garcia",     email:"penumbral.cafe@gmail.com",             cel:"3203158327", upz:"Timiza",         g:"FEMENINO",   p:"MIPYME", curso:"GT" },
  { fn:"Luisa Juliana",   ln:"Diaz Sanchez",         email:"tour24.07@gmail.com",                  cel:"3003577846", upz:"Kennedy Central",g:"FEMENINO",   p:"MIPYME", curso:"MD" },
  { fn:"Adriana Cecilia", ln:"Rodriguez Sanchez",    email:"thehivesuite2025@gmail.com",           cel:"3152980897", upz:"Castilla",       g:"FEMENINO",   p:"MIPYME", curso:"MD" },
  { fn:"Liliana Marcela", ln:"Ospina Sanchez",       email:"rprofundas@gmail.com",                 cel:"3144100081", upz:"Calandaima",     g:"FEMENINO",   p:"MIPYME", curso:"MD" },
  { fn:"Vallery Michel",  ln:"Lindo Garcia",         email:"vallerygarcia22@gmail.com",            cel:"3144050657", upz:"Kennedy Central",g:"FEMENINO",   p:"MIPYME", curso:"GT" },
  { fn:"Edith Yeraldin",  ln:"Villamil Ortiz",       email:"viajesmillasmil@gmail.com",            cel:"3024126694", upz:"Tintal Norte",   g:"FEMENINO",   p:"MIPYME", curso:"I"  },
  { fn:"Nelson",          ln:"Reina Gomez",          email:"aviajar1a@gmail.com",                  cel:"3103268849", upz:"Kennedy Central",g:"MASCULINO",  p:"MIPYME", curso:"MD" },
  { fn:"Nicolle",         ln:"Jaraba Vides",         email:"nijavi9508@gmail.com",                 cel:"3103758335", upz:"Las Margaritas", g:"FEMENINO",   p:"MIPYME", curso:"MD" },
  { fn:"Luis Miguel",     ln:"Galindo Nino",         email:"migalindon@gmail.com",                 cel:"3112777381", upz:"Bavaria",        g:"MASCULINO",  p:"MIPYME", curso:"GT" },
  // --- EMPRENDEDORES ---
  { fn:"Sandra Elizabeth",ln:"Matallana Ripe",       email:"sandymatallana@yahoo.com",             cel:"3124134942", upz:"Carvajal",       g:"FEMENINO",   p:"EMPRENDEDOR", curso:"MD" },
  { fn:"Michelle",        ln:"Gaviria Juzga",        email:"michellegaviri3@hotmail.com",          cel:"3152193269", upz:"Castilla",       g:"FEMENINO",   p:"EMPRENDEDOR", curso:"MD" },
  { fn:"Jose Alejandro",  ln:"Gil Garcia",           email:"ruidolabcolectivo@gmail.com",          cel:"3213682168", upz:"Timiza",         g:"MASCULINO",  p:"EMPRENDEDOR", curso:"GT" },
  { fn:"Miguel Angel",    ln:"Guerrero Ortega",      email:"guerreroortegamiguelangel@gmail.com",  cel:"3186557851", upz:"Corabastos",     g:"MASCULINO",  p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Luz Angela",      ln:"Susatama Patino",      email:"langelasp@gmail.com",                  cel:"3212843939", upz:"Kennedy Central",g:"FEMENINO",   p:"EMPRENDEDOR", curso:"MD" },
  { fn:"Diana Marcela",   ln:"Gonzalez Garzon",      email:"dianagonzalezgarzon@hotmail.com",      cel:"3046016657", upz:"Tintal Norte",   g:"FEMENINO",   p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Natalia",         ln:"Bermudez",             email:"nata.alf123@hotmail.com",              cel:"3017621999", upz:"Castilla",       g:"FEMENINO",   p:"EMPRENDEDOR", curso:"GT" },
  { fn:"Eduardo",         ln:"Pinzon Avendano",      email:"peacepathscolombia@gmail.com",         cel:"3202804880", upz:"Patio Bonito",   g:"MASCULINO",  p:"EMPRENDEDOR", curso:"MD" },
  { fn:"Jose Gabriel",    ln:"Mesa Rodriguez",       email:"jogamero@hotmail.com",                 cel:"3115723566", upz:"Timiza",         g:"MASCULINO",  p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Sandra",          ln:"Daza Barrera",         email:"sdaza2014@gmail.com",                  cel:"3053553188", upz:"Bavaria",        g:"FEMENINO",   p:"EMPRENDEDOR", curso:"MD" },
  { fn:"Gladys Fabiola",  ln:"Revelo Grijalba",      email:"saturia18@hotmail.com",                cel:"3204099589", upz:"Kennedy Central",g:"FEMENINO",   p:"EMPRENDEDOR", curso:"GT" },
  { fn:"Johanys",         ln:"Sanchez Ramirez",      email:"johanysworkout@gmail.com",             cel:"3022753685", upz:"Gran Britalia",  g:"MASCULINO",  p:"EMPRENDEDOR", curso:"MD" },
  { fn:"Beatriz Elena",   ln:"Zapata Lopez",         email:"postresyregalosimperio@gmail.com",     cel:"3222276661", upz:"Kennedy Central",g:"FEMENINO",   p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Jorge",           ln:"Henech",               email:"almejatours@gmail.com",                cel:"3003148451", upz:"Castilla",       g:"MASCULINO",  p:"EMPRENDEDOR", curso:"MD" },
  { fn:"Angela Johanna",  ln:"Duran Rodriguez",      email:"angeladuranr05@gmail.com",             cel:"3168040445", upz:"Calandaima",     g:"FEMENINO",   p:"EMPRENDEDOR", curso:"GE" },
  { fn:"Paola Andrea",    ln:"Riveros Rengifo",      email:"paola.riveros.rengifo@hotmail.com",    cel:"3212113663", upz:"Americas",       g:"FEMENINO",   p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Jeimmy Andrea",   ln:"Jimenez Carranza",     email:"jeimmyjimenezc1@gmail.com",            cel:"3112810125", upz:"Calandaima",     g:"FEMENINO",   p:"EMPRENDEDOR", curso:"GE" },
  // LQTBIQ+ en columna Sexo - genero NO_BINARIO
  { fn:"Jesus David",     ln:"Ramirez Alvarez",      email:"davidramirez21102015@gmail.com",       cel:"3227262124", upz:"Timiza",         g:"NO_BINARIO", p:"EMPRENDEDOR", curso:"MD" },
  // LQTBIQ+ en columna Sexo - genero NO_BINARIO
  { fn:"Gloria Esperanza",ln:"Gomez Marin",          email:"glorianita20@gmail.com",               cel:"3118462838", upz:"Castilla",       g:"NO_BINARIO", p:"EMPRENDEDOR", curso:"GE" },
  // LQTBIQ+ en columna Sexo - genero NO_BINARIO
  { fn:"Alberto Ruiz",    ln:"Ruiz Pardo",           email:"alruiz452000@hotmail.com",             cel:"3112744499", upz:"Timiza",         g:"NO_BINARIO", p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Eczal Lucia",     ln:"Perez Caro",           email:"eczalluciaperezcaro@gmail.com",        cel:"3212921172", upz:"Kennedy Central",g:"FEMENINO",   p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Luisa Fernanda",  ln:"Ruiz Moreno",          email:"luisa071622@gmail.com",                cel:"3223909876", upz:"Kennedy Central",g:"FEMENINO",   p:"EMPRENDEDOR", curso:"GT" },
  { fn:"Sandra Milena",   ln:"Ariza Osma",           email:"atataosma@gmail.com",                  cel:"3174086671", upz:"Calandaima",     g:"FEMENINO",   p:"EMPRENDEDOR", curso:"GE" },
  { fn:"Angela Maria",    ln:"Lopez Castano",        email:"tatianaparraga1@hotmail.com",          cel:"3246744725", upz:"Calandaima",     g:"FEMENINO",   p:"EMPRENDEDOR", curso:"GE" },
  // LQTBIQ+ en columna Sexo - genero NO_BINARIO
  { fn:"Maria Adalyde",   ln:"Pena Gamboa",          email:"adalydepena2@gmail.com",               cel:"3142139747", upz:"Kennedy Central",g:"NO_BINARIO", p:"EMPRENDEDOR", curso:"GT" },
  { fn:"Jose Daniel",     ln:"Urrego Ramirez",       email:"talentosmusicales2022@gmail.com",      cel:"3155150733", upz:"Kennedy Central",g:"MASCULINO",  p:"EMPRENDEDOR", curso:"GE" },
  { fn:"Natalia",         ln:"Otalora Munoz",        email:"nataotalora@gmail.com",                cel:"3192357828", upz:"Timiza",         g:"FEMENINO",   p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Mariana",         ln:"Vanegas Munoz",        email:"briznadefe@gmail.com",                 cel:"3245808409", upz:"Tintal Norte",   g:"FEMENINO",   p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Katherine",       ln:"Baron",                email:"katicospawn@yahoo.com",                cel:"3115708910", upz:"Carvajal",       g:"FEMENINO",   p:"EMPRENDEDOR", curso:"GT" },
  { fn:"Ruth",            ln:"Beltran",              email:"pastoraruth05@gmail.com",              cel:"3107506276", upz:"Patio Bonito",   g:"FEMENINO",   p:"EMPRENDEDOR", curso:"I"  },
  // LQTBIQ+ en columna Sexo - genero NO_BINARIO
  { fn:"Karen",           ln:"Castano Aventours",    email:"kasthelves@gmail.com",                 cel:"3115792840", upz:"Kennedy Central",g:"NO_BINARIO", p:"EMPRENDEDOR", curso:"I"  },
  { fn:"Maite",           ln:"Moreno MM Creaciones", email:"aceromiam@hotmail.com",                cel:"3203930849", upz:"Kennedy Central",g:"FEMENINO",   p:"EMPRENDEDOR", curso:"GE" },
];

// Resumen para verificar:
// FEMENINO: Victor-No, German-No, Yesid-No, Sandra Moreno-Si, Daniel-No, David-No, Rocio-Si, Luisa Jul-Si
// Adriana-Si, Liliana-Si, Vallery-Si, Edith-Si, Nelson-No, Nicolle-Si, Luis-No, Sandra E-Si, Michelle-Si
// Jose A-No, Miguel A-No, Luz Angela-Si, Diana-Si, Natalia B-Si, Eduardo-No, Jose G-No, Sandra D-Si
// Gladys-Si, Johanys-No, Beatriz-Si, Jorge-No, Angela J-Si, Paola-Si, Jeimmy-Si
// Jesus-NO_BINARIO, Gloria-NO_BINARIO, Alberto-NO_BINARIO, Eczal-Si, Luisa F-Si, Sandra M-Si, Angela M-Si
// Maria Adalyde-NO_BINARIO, Jose Daniel-No, Natalia O-Si, Mariana-Si, Katherine-Si, Ruth-Si
// Karen-NO_BINARIO, Maite-Si
// NO_BINARIO (6): German, Jesus, Gloria, Alberto, Maria Adalyde, Karen

async function main() {
  console.log("Eliminando beneficiarios anteriores...");
  const oldBens = await prisma.user.findMany({ where: { role:"BENEFICIARIO" } });
  for (const u of oldBens) {
    await prisma.enrollment.deleteMany({ where:{ userId:u.id } });
    await prisma.attendance.deleteMany({ where:{ userId:u.id } });
    await prisma.submission.deleteMany({ where:{ userId:u.id } });
    await prisma.user.delete({ where:{ id:u.id } });
  }
  console.log("Anteriores eliminados.");

  await prisma.user.upsert({ where:{email:"admin@buskandoparche.com"}, update:{}, create:{
    email:"admin@buskandoparche.com", passwordHash: await bcrypt.hash("Admin2024!",12),
    role:"ADMIN", firstName:"Admin", lastName:"Sistema", cedula:"8000000001"
  }});

  const fUsers = [];
  for (let i=0; i<FORMADORES.length; i++) {
    const f = FORMADORES[i];
    const u = await prisma.user.upsert({ where:{email:f.email}, update:{}, create:{
      email:f.email, passwordHash: await bcrypt.hash("Formador2024!",12),
      role:"FORMADOR", firstName:f.firstName, lastName:f.lastName, cedula:f.cedula
    }});
    fUsers.push(u);
  }

  const cursoMap = { I:null, GE:null, GT:null, MD:null };
  const keys = ["I","GE","GT","MD"];
  for (let i=0; i<CURSOS.length; i++) {
    const c = CURSOS[i];
    const ex = await prisma.course.findFirst({ where:{title:c.title} });
    const course = ex
      ? await prisma.course.update({ where:{id:ex.id}, data:{...c, isPublished:true, formadorId:fUsers[i].id} })
      : await prisma.course.create({ data:{...c, isPublished:true, formadorId:fUsers[i].id} });
    cursoMap[keys[i]] = course;
    const cnt = await prisma.session.count({ where:{courseId:course.id} });
    if (cnt === 0) {
      for (let s=1; s<=20; s++) {
        await prisma.session.create({ data:{courseId:course.id, title:"Sesion "+s, description:"Contenido sesion "+s, order:s} });
      }
    }
  }

  const hashB = await bcrypt.hash("BuskandoParche2024!", 12);
  let countF=0, countM=0, countL=0;
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
    if (course) await prisma.enrollment.create({ data:{ userId:u.id, courseId:course.id, status:"ACTIVO" } });
    if (b.g==="FEMENINO") countF++;
    else if (b.g==="MASCULINO") countM++;
    else countL++;
  }

  const totI = BENS.filter(b=>b.curso==="I").length;
  const totGE = BENS.filter(b=>b.curso==="GE").length;
  const totGT = BENS.filter(b=>b.curso==="GT").length;
  const totMD = BENS.filter(b=>b.curso==="MD").length;

  console.log("===========================================");
  console.log("SEED OK - " + BENS.length + " beneficiarios reales");
  console.log("  Mujeres (FEMENINO):  " + countF);
  console.log("  Hombres (MASCULINO): " + countM);
  console.log("  LGBTIQ+ (NO_BINARIO):" + countL);
  console.log("Personas LGBTIQ+: German Arnulfo, Jesus David, Gloria Esperanza, Alberto Ruiz, Maria Adalyde, Karen Castano");
  console.log("Por curso:");
  console.log("  Ingles:              " + totI);
  console.log("  Gestion Empresarial: " + totGE);
  console.log("  Gestion Turistica:   " + totGT);
  console.log("  Marketing Digital:   " + totMD);
  console.log("===========================================");
}

main().catch(e=>{console.error(e);process.exit(1);}).finally(()=>prisma.$disconnect());
