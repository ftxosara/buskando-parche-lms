const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

const getDashboard = async (req, res) => {
  try {
    const [totalBeneficiarios, totalCourses] = await Promise.all([
      prisma.user.count({ where: { role: "BENEFICIARIO", isActive: true } }),
      prisma.course.count({ where: { isPublished: true } }),
    ]);

    // Genero: contar FEMENINO, MASCULINO, LGBTIQ+ (NO_BINARIO + otros)
    const genderRaw = await prisma.user.groupBy({
      by: ["gender"],
      where: { role: "BENEFICIARIO", isActive: true },
      _count: { gender: true },
    });

    let mujeres = 0; let hombres = 0; let lgbtiq = 0;
    genderRaw.forEach(g => {
      const v = g._count.gender;
      const gen = (g.gender || "").toUpperCase();
      if (gen === "FEMENINO") mujeres += v;
      else if (gen === "MASCULINO") hombres += v;
      else lgbtiq += v; // NO_BINARIO, null, otros
    });

    const courseKpis = await prisma.course.findMany({
      where: { isPublished: true },
      select: {
        id: true, title: true, modality: true,
        formador: { select: { firstName: true, lastName: true } },
        enrollments: {
          where: { status: { not: "INACTIVO" } },
          select: { userId: true, user: { select: { gender: true, populationGroup: true } } }
        },
      },
    });

    const attendanceSummary = await prisma.attendance.groupBy({ by: ["status"], _count: { status: true } });
    const attMap = {};
    attendanceSummary.forEach(a => { attMap[a.status] = a._count.status; });
    const totalAtt = Object.values(attMap).reduce((a, b) => a + b, 0);
    const porcentajeAsistencia = totalAtt > 0 ? ((attMap["PRESENTE"] || 0) / totalAtt * 100).toFixed(1) : 0;

    const completados = await prisma.enrollment.count({ where: { status: "COMPLETADO" } });

    const populationBreakdown = await prisma.user.groupBy({
      by: ["populationGroup"],
      where: { role: "BENEFICIARIO", isActive: true },
      _count: { populationGroup: true },
      orderBy: { _count: { populationGroup: "desc" } },
    });

    const pMuj = totalBeneficiarios > 0 ? ((mujeres / totalBeneficiarios) * 100).toFixed(1) : 0;

    const courseData = courseKpis.map(c => {
      const inscritos = c.enrollments.length;
      let muj = 0; let hom = 0; let lbt = 0;
      c.enrollments.forEach(e => {
        const g = (e.user?.gender || "").toUpperCase();
        if (g === "FEMENINO") muj++;
        else if (g === "MASCULINO") hom++;
        else lbt++;
      });
      return {
        id: c.id,
        title: c.title.length > 18 ? c.title.substring(0,16)+".." : c.title,
        fullTitle: c.title,
        modality: c.modality,
        formador: c.formador ? c.formador.firstName+" "+c.formador.lastName : "Sin asignar",
        inscritos,
        mujeres: muj,
        hombres: hom,
        lgbtiq: lbt,
        porcentajeMujeres: inscritos > 0 ? ((muj / inscritos) * 100).toFixed(0) : "0",
        porcentajeInclusivo: inscritos > 0 ? (((muj + lbt) / inscritos) * 100).toFixed(0) : "0",
      };
    });

    return res.json({
      kpis: {
        totalBeneficiarios, mujeres, hombres, lgbtiq,
        porcentajeMujeres: pMuj + "%",
        metaMujeres: parseFloat(pMuj) >= 50 ? "Cumplida" : "En riesgo",
        totalCourses,
        completados,
        porcentajeAsistencia: porcentajeAsistencia + "%",
        porcentajeCompletados: totalBeneficiarios > 0 ? ((completados / totalBeneficiarios) * 100).toFixed(1) + "%" : "0%",
      },
      courseKpis: courseData,
      populationBreakdown: populationBreakdown.map(p => ({
        grupo: p.populationGroup || "Sin clasificar",
        cantidad: p._count.populationGroup,
      })),
    });
  } catch (err) { console.error(err); return res.status(500).json({ error: "Error" }); }
};

const getReport = async (req, res) => {
  try {
    const PDFDocument = require("pdfkit");
    const path = require("path");
    const fs = require("fs");
    const doc = new PDFDocument({ size:"A4", margin:50, bufferPages:true });
    res.setHeader("Content-Type","application/pdf");
    res.setHeader("Content-Disposition","attachment; filename=reporte-buskando-parche.pdf");
    doc.pipe(res);
    const PUB = path.join(__dirname,"../../frontend/public/images");
    const W = doc.page.width;
    doc.rect(0,0,W+100,90).fill("#C0392B");
    const lp = path.join(PUB,"logo.png");
    if (fs.existsSync(lp)) doc.image(lp,45,15,{height:60});
    doc.font("Helvetica-Bold").fontSize(20).fillColor("white").text("BUSKANDO PARCHE - KENNEDY",120,22);
    doc.font("Helvetica").fontSize(11).fillColor("white").text("Reporte General del Programa de Formacion",120,46);
    doc.font("Helvetica").fontSize(9).fillColor("rgba(255,255,255,0.7)").text("Alcaldia Local de Kennedy - Bogota, Colombia",120,63);
    let y = 110;
    doc.font("Helvetica").fontSize(9).fillColor("#888").text("Generado el: "+new Date().toLocaleDateString("es-CO",{year:"numeric",month:"long",day:"numeric"}),50,y); y+=25;
    const [bens,cursos,asist] = await Promise.all([
      prisma.user.findMany({where:{role:"BENEFICIARIO",isActive:true},include:{enrollments:{include:{course:{select:{title:true}}}}},orderBy:{lastName:"asc"}}),
      prisma.course.findMany({where:{isPublished:true},include:{enrollments:{include:{user:{select:{gender:true}}}},formador:{select:{firstName:true,lastName:true}}}}),
      prisma.attendance.groupBy({by:["status"],_count:{status:true}}),
    ]);
    const am={}; asist.forEach(a=>{am[a.status]=a._count.status;});
    const ta=Object.values(am).reduce((a,b)=>a+b,0);
    const pa=ta>0?((am["PRESENTE"]||0)/ta*100).toFixed(1):0;
    const muj=bens.filter(b=>b.gender==="FEMENINO").length;
    const hom=bens.filter(b=>b.gender==="MASCULINO").length;
    const lbt=bens.filter(b=>b.gender!=="FEMENINO"&&b.gender!=="MASCULINO").length;
    doc.rect(50,y,W-100,22).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("RESUMEN EJECUTIVO",60,y+5); y+=30;
    [[" Total beneficiarios",bens.length,"de 50 cupos"],[" Mujeres",muj,((muj/Math.max(bens.length,1))*100).toFixed(1)+"%"],[" Hombres",hom,((hom/Math.max(bens.length,1))*100).toFixed(1)+"%"],[" LGBTIQ+",lbt,((lbt/Math.max(bens.length,1))*100).toFixed(1)+"%"],[" Asistencia global",pa+"%",ta+" registros"]].forEach(([l,v,s])=>{
      doc.font("Helvetica-Bold").fontSize(10).fillColor("#111").text(l+": ",60,y,{continued:true});
      doc.font("Helvetica").fillColor("#333").text(String(v)+"   ",{continued:true});
      doc.fillColor("#888").text("("+s+")"); y+=17;
    }); y+=15;
    doc.rect(50,y,W-100,22).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("DETALLE POR CURSO",60,y+5); y+=30;
    cursos.forEach(c=>{
      if(y>700){doc.addPage();y=50;}
      const ins=c.enrollments.length;const mj=c.enrollments.filter(e=>e.user?.gender==="FEMENINO").length;
      doc.fontSize(11).font("Helvetica-Bold").fillColor("#111").text(c.title,60,y);y+=15;
      doc.fontSize(9).font("Helvetica").fillColor("#555").text("Formador: "+(c.formador?c.formador.firstName+" "+c.formador.lastName:"N/A")+"  |  Inscritos: "+ins+"  |  Mujeres: "+mj+" ("+((ins>0?(mj/ins*100).toFixed(0):0))+"%)",70,y);y+=20;
    }); y+=10;
    if(y>650){doc.addPage();y=50;}
    doc.rect(50,y,W-100,22).fill("#F3F4F6");
    doc.font("Helvetica-Bold").fontSize(12).fillColor("#C0392B").text("LISTADO BENEFICIARIOS",60,y+5);y+=30;
    doc.fontSize(8).font("Helvetica-Bold").fillColor("#666");
    doc.text("NOMBRE",60,y);doc.text("CEDULA",210,y);doc.text("GENERO",300,y);doc.text("CURSO",365,y);doc.text("ESTADO",495,y);y+=13;
    doc.moveTo(50,y).lineTo(W-50,y).lineWidth(0.5).stroke("#ddd");y+=7;
    bens.forEach(b=>{
      if(y>760){doc.addPage();y=50;}
      const curso=b.enrollments[0]?.course?.title?.substring(0,20)||"Sin curso";
      doc.fontSize(7.5).font("Helvetica").fillColor("#111");
      doc.text(b.firstName+" "+b.lastName,60,y,{width:142});
      doc.text(b.cedula,210,y);doc.text(b.gender||"-",300,y);
      doc.text(curso,365,y,{width:122});doc.text(b.enrollments[0]?.status||"-",495,y);y+=14;
    });
    const rg=doc.bufferedPageRange();
    for(let i=0;i<rg.count;i++){
      doc.switchToPage(i);
      doc.rect(0,doc.page.height-28,doc.page.width+100,28).fill("#C0392B");
      doc.font("Helvetica").fontSize(8).fillColor("white").text("Buskando Parche - Alcaldia Local de Kennedy",50,doc.page.height-16);
      doc.text("Pagina "+(i+1)+" de "+rg.count,doc.page.width-100,doc.page.height-16,{align:"right"});
    }
    doc.end();
  } catch(err){ console.error(err); if(!res.headersSent) res.status(500).json({error:"Error"}); }
};

module.exports = { getDashboard, getReport };
