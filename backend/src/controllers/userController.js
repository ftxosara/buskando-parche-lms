const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcryptjs");
const prisma = new PrismaClient();

const listUsers = async (req, res) => {
  const { role, page = 1, limit = 20, search } = req.query;
  const where = {};
  if (role) where.role = role;
  if (search) {
    where.OR = [
      { firstName: { contains: search, mode: "insensitive" } },
      { lastName: { contains: search, mode: "insensitive" } },
      { cedula: { contains: search } },
      { email: { contains: search, mode: "insensitive" } },
    ];
  }
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip: (page - 1) * Number(limit),
      take: Number(limit),
      select: {
        id: true, email: true, firstName: true, lastName: true,
        cedula: true, phone: true, role: true, gender: true,
        populationGroup: true, locality: true, isActive: true, createdAt: true,
        enrollments: { select: { courseId: true, status: true, course: { select: { id: true, title: true } } } },
      },
      orderBy: { firstName: "asc" },
    }),
    prisma.user.count({ where }),
  ]);
  return res.json({ data: users, total, page: Number(page), limit: Number(limit) });
};

const createUser = async (req, res) => {
  try {
    const { email, password, role, firstName, lastName, cedula, phone, gender, populationGroup, upz, locality, courseId } = req.body;
    const hash = await bcrypt.hash(password || "BuskandoParche2024!", 12);
    const user = await prisma.user.create({
      data: { email: email.toLowerCase(), passwordHash: hash, role: role || "BENEFICIARIO", firstName, lastName, cedula, phone, gender, populationGroup, upz, locality },
    });
    // Inscribir en curso si se especifica
    if (courseId && role === "BENEFICIARIO") {
      await prisma.enrollment.create({ data: { userId: user.id, courseId, status: "ACTIVO" } });
    }
    const { passwordHash, ...safe } = user;
    return res.status(201).json(safe);
  } catch (err) {
    if (err.code === "P2002") return res.status(409).json({ error: "Email o cedula ya registrado" });
    return res.status(500).json({ error: "Error al crear usuario: " + err.message });
  }
};

const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const { password, courseId, currentCourseId, ...data } = req.body;
    delete data.passwordHash;
    if (password) data.passwordHash = await bcrypt.hash(password, 12);
    const user = await prisma.user.update({ where: { id }, data });
    // Cambiar curso si se especifica
    if (courseId && currentCourseId && courseId !== currentCourseId) {
      // Desactivar inscripcion anterior
      await prisma.enrollment.updateMany({ where: { userId: id, courseId: currentCourseId }, data: { status: "INACTIVO" } });
      // Crear nueva inscripcion
      await prisma.enrollment.upsert({
        where: { userId_courseId: { userId: id, courseId } },
        update: { status: "ACTIVO" },
        create: { userId: id, courseId, status: "ACTIVO" }
      });
    } else if (courseId && !currentCourseId) {
      await prisma.enrollment.upsert({
        where: { userId_courseId: { userId: id, courseId } },
        update: { status: "ACTIVO" },
        create: { userId: id, courseId, status: "ACTIVO" }
      });
    }
    const { passwordHash, ...safe } = user;
    return res.json(safe);
  } catch (err) { return res.status(500).json({ error: "Error al actualizar: " + err.message }); }
};

const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    // Soft delete
    await prisma.user.update({ where: { id }, data: { isActive: false } });
    return res.json({ message: "Usuario desactivado" });
  } catch { return res.status(500).json({ error: "Error" }); }
};

const hardDeleteUser = async (req, res) => {
  try {
    const { id } = req.params;
    await prisma.enrollment.deleteMany({ where: { userId: id } });
    await prisma.attendance.deleteMany({ where: { userId: id } });
    await prisma.submission.deleteMany({ where: { userId: id } });
    await prisma.user.delete({ where: { id } });
    return res.json({ message: "Usuario eliminado permanentemente" });
  } catch { return res.status(500).json({ error: "Error al eliminar" }); }
};

module.exports = { listUsers, createUser, updateUser, deactivateUser: deleteUser, hardDeleteUser };
