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
