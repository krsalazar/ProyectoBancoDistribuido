//src/routes/cuentas.routes.js
const { Router } = require('express');
const router = Router();

const {
  obtenerCuentas,
  crearCuenta
} = require('../controllers/cuentas.controller');

router.get('/', obtenerCuentas);
router.post('/', crearCuenta);

module.exports = router;
