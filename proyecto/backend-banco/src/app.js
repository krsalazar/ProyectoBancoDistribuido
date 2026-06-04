const express = require('express');
const cors = require('cors');

const clientesRoutes = require('./routes/clientes.routes');
const cuentasRoutes = require('./routes/cuentas.routes');
const transferenciasRoutes = require('./routes/transferencias.routes');

const app = express();

app.use(cors());
app.use(express.json());

app.use('/api/clientes', clientesRoutes);
app.use('/api/cuentas', cuentasRoutes);
app.use('/api/transferencias', transferenciasRoutes);

module.exports = app;