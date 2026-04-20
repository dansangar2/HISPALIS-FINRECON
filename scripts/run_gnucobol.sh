#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC_FILE="${ROOT_DIR}/src/FINRECON.cbl"
COPY_DIR="${ROOT_DIR}/copybooks"
BIN_DIR="${ROOT_DIR}/output/bin"
PROGRAM_NAME="FINRECON"

GNUCOBOL_HOME_MSYS="/d/Program Files (x86)/OpenCobolIDE/GnuCOBOL"
GNUCOBOL_HOME_WIN='D:\Program Files (x86)\OpenCobolIDE\GnuCOBOL'
COBC_EXE="${GNUCOBOL_HOME_MSYS}/bin/cobc.exe"

error() {
  echo "[ERROR] $*" >&2
}

info() {
  echo "[INFO] $*"
}

if [[ ! -x "${COBC_EXE}" ]]; then
  error "No existe el compilador esperado: ${COBC_EXE}"
  exit 127
fi

if [[ ! -f "${SRC_FILE}" ]]; then
  error "No existe el fuente principal: ${SRC_FILE}"
  exit 1
fi

if [[ ! -d "${COPY_DIR}" ]]; then
  error "No existe la carpeta de copybooks: ${COPY_DIR}"
  exit 1
fi

mkdir -p "${BIN_DIR}"

if command -v cygpath >/dev/null 2>&1; then
  SRC_FILE_WIN="$(cygpath -w "${SRC_FILE}")"
  COPY_DIR_WIN="$(cygpath -w "${COPY_DIR}")"
  BIN_DIR_WIN="$(cygpath -w "${BIN_DIR}")"
else
  error "No se encuentra 'cygpath'. Ejecuta este script desde Git Bash."
  exit 1
fi

BINARY_PATH_WIN="${BIN_DIR_WIN}\\${PROGRAM_NAME}.exe"
BINARY_PATH_MSYS="${BIN_DIR}/${PROGRAM_NAME}.exe"

export PATH="${GNUCOBOL_HOME_MSYS}/bin:$PATH"
export COB_CONFIG_DIR="${GNUCOBOL_HOME_WIN}\\config"
export COB_COPY_DIR="${GNUCOBOL_HOME_WIN}\\copy"
export COB_INCLUDE_PATH="${GNUCOBOL_HOME_WIN}\\include"
export COB_LIB_PATH="${GNUCOBOL_HOME_WIN}\\lib"
export COB_RUNTIME_CONFIG="${GNUCOBOL_HOME_WIN}\\config\\runtime.cfg"

info "Compilando ${SRC_FILE} ..."
if ! "${COBC_EXE}" -x -fixed -I "${COPY_DIR_WIN}" -o "${BINARY_PATH_WIN}" "${SRC_FILE_WIN}"; then
  error "La compilación ha fallado. Revisa los mensajes de cobc y corrige el fuente antes de reintentar."
  exit 1
fi

if [[ ! -f "${BINARY_PATH_MSYS}" ]]; then
  error "La compilación terminó, pero no se generó el binario esperado en: ${BINARY_PATH_MSYS}"
  exit 1
fi

info "Ejecutando ${BINARY_PATH_MSYS} ..."
(
  cd "${BIN_DIR}"
  "./${PROGRAM_NAME}.exe"
)

info "Ejecución finalizada. Revisa los ficheros de salida:"
echo "  ${ROOT_DIR}/output/RESULTS.DAT"
echo "  ${ROOT_DIR}/output/ERRORS.DAT"
echo "  ${ROOT_DIR}/output/REPORT.TXT"