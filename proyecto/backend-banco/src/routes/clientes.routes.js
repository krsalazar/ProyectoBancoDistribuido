//src/routes/clientes.routes.js
const { Router } = require('express');
const router = Router();

const {
  obtenerClientes,
  crearCliente
} = require('../controllers/clientes.controller');

router.get('/', obtenerClientes);
router.post('/', crearCliente);

module.exports = router;
