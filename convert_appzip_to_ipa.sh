#!/usr/bin/env bash
# convert_appzip_to_ipa.sh
# Uso:
#   ./convert_appzip_to_ipa.sh Runner.app.zip
#
# Convierte:
#   *.app.zip -> *.ipa

set -e

if [ $# -lt 1 ]; then
    echo "Uso: $0 archivo.app.zip"
    exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
    echo "Error: archivo no encontrado: $INPUT"
    exit 1
fi

TMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TMP_DIR"
}

trap cleanup EXIT

echo "[+] Extrayendo ZIP..."
unzip -q "$INPUT" -d "$TMP_DIR"

APP_DIR=$(find "$TMP_DIR" -maxdepth 2 -type d -name "*.app" | head -n 1)

if [ -z "$APP_DIR" ]; then
    echo "Error: no se encontró ninguna carpeta .app dentro del ZIP"
    exit 1
fi

APP_NAME=$(basename "$APP_DIR")
BASE_NAME="${APP_NAME%.app}"

PAYLOAD_DIR="$TMP_DIR/Payload"

mkdir -p "$PAYLOAD_DIR"

mv "$APP_DIR" "$PAYLOAD_DIR/"

OUTPUT_IPA="${BASE_NAME}.ipa"

echo "[+] Creando IPA..."
(
    cd "$TMP_DIR"
    zip -qry "$OLDPWD/$OUTPUT_IPA" Payload
)

echo "[+] IPA creada correctamente:"
echo "    $OUTPUT_IPA"
