//src/controllers/clientes.controller.js
const pool = require('../config/db');

const obtenerClientes = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM clientes ORDER BY id');

    res.json(result.rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({
      mensaje: 'Error al obtener clientes'
    });
  }
};

const crearCliente = async (req, res) => {
  try {
    const {
      numero_cliente,
      nombre,
      apellido,
      tipo_documento,
      numero_doc,
      email,
      telefono,
      direccion,
      ciudad,
      fecha_nac
    } = req.body;

    const query = `
      INSERT INTO clientes (
        numero_cliente,
        nombre,
        apellido,
        tipo_documento,
        numero_doc,
        email,
        telefono,
        direccion,
        ciudad,
        fecha_nac
      )
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10)
      RETURNING *
    `;

    const values = [
      numero_cliente,
      nombre,
      apellido,
      tipo_documento,
      numero_doc,
      email,
      telefono,
      direccion,
      ciudad,
      fecha_nac
    ];

    const result = await pool.query(query, values);

    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error(error);

    res.status(500).json({
      mensaje: 'Error al crear cliente'
    });
  }
};

module.exports = {
  obtenerClientes,
  crearCliente
};
