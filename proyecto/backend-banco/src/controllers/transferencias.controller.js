const pool = require('../config/db');

const realizarTransferencia = async (req, res) => {
  try {

    const {
      cuenta_origen_id,
      cuenta_destino_id,
      monto,
      usuario_id,
      descripcion
    } = req.body;

    await pool.query(
      `CALL sp_realizar_transferencia($1,$2,$3,$4,$5)`,
      [
        cuenta_origen_id,
        cuenta_destino_id,
        monto,
        usuario_id,
        descripcion
      ]
    );

    res.json({
      mensaje: 'Transferencia realizada correctamente'
    });

  } catch (error) {

    console.error(error);

    res.status(500).json({
      mensaje: error.message
    });

  }
};

module.exports = {
  realizarTransferencia
};