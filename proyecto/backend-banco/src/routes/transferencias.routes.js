const { Router } = require('express');
const router = Router();

const {
  realizarTransferencia
} = require('../controllers/transferencias.controller');

router.post('/', realizarTransferencia);

module.exports = router;