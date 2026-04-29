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
