#Script para backups completos
#!/bin/bash
DB_NAME="proyectobd2"
BACKUP_DIR="/var/backups/postgres/completos"
FECHA=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_completo_$FECHA.sql"

# Crear el directorio si no existe
mkdir -p $BACKUP_DIR

# Ejecución del backup comprimido en formato nativo de Postgres (.backup)
pg_dump -U admin -F c -b -v -f "$BACKUP_FILE" $DB_NAME

echo "Respando completo generado exitosamente en: $BACKUP_FILE"


# Restaurar en una base de datos limpia utilizando pg_restore
pg_restore -U admin -d proyectobd2 -v /var/backups/postgres/completos/proyectobd2_completo_XYZ.backup



########################################################################################################
#Respaldo incremental, para guardar automaticamente:
#!/bin/bash
BACKUP_DIR="/var/backups/postgres/base"
FECHA=$(date +%Y%m%d)

# Genera una copia física del estado actual del servidor de BD
pg_basebackup -U admin -D "$BACKUP_DIR/base_$FECHA" -F t -P -z

echo "Copia base para esquema incremental generada."