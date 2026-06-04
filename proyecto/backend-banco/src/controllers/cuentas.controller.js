//src/controllers/cuentas.controller.js
const pool = require('../config/db');

const obtenerCuentas = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT
        c.id,
        c.numero_cuenta,
        c.saldo,
        c.estado,
        cl.nombre,
        cl.apellido
      FROM cuentas c
      INNER JOIN clientes cl
      ON c.cliente_id = cl.id
      ORDER BY c.id
    `);

    res.json(result.rows);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      mensaje: 'Error al obtener cuentas'
    });
  }
};

const crearCuenta = async (req, res) => {
  try {
    const {
      numero_cuenta,
      cliente_id,
      tipo_cuenta_id,
      sucursal_id,
      saldo,
      limite_sobregiro
    } = req.body;

    const result = await pool.query(
      `
      INSERT INTO cuentas (
        numero_cuenta,
        cliente_id,
        tipo_cuenta_id,
        sucursal_id,
        saldo,
        limite_sobregiro
      )
      VALUES ($1,$2,$3,$4,$5,$6)
      RETURNING *
      `,
      [
        numero_cuenta,
        cliente_id,
        tipo_cuenta_id,
        sucursal_id,
        saldo,
        limite_sobregiro
      ]
    );

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      mensaje: 'Error al crear cuenta'
    });
  }
};

module.exports = {
  obtenerCuentas,
  crearCuenta
};
