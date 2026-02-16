#!/bin/bash

# --- Sicurezza e robustezza ---
# set -e: Esce immediatamente se un comando fallisce.
# set -u: Esce se si tenta di usare una variabile non definita.
# set -o pipefail: Fa sì che l'errore in una pipeline venga propagato.
set -euo pipefail

# --- Variabili ---
# Definiamo il nome della directory dell'ambiente virtuale
VENV_DIR="venv"
# Definiamo il file con i requisiti
REQUIREMENTS_FILE="requirements.txt"

# --- Funzioni di utilità per messaggi colorati ---
info() {
    echo -e "\033[34m[INFO]\033[0m $1"
}

success() {
    echo -e "\033[32m[SUCCESS]\033[0m $1"
}

error() {
    echo -e "\033[31m[ERROR]\033[0m $1" >&2
    exit 1
}

# --- 1. Controllo dei prerequisiti ---
info "Controllo dei prerequisiti..."
if ! command -v python3 &> /dev/null; then
    error "Python3 non trovato. Per favore, installalo prima di eseguire questo script."
fi

# Controlla che il modulo 'venv' sia disponibile
if ! python3 -c "import venv" &> /dev/null; then
   error "Il modulo 'venv' di Python3 non è installato. Su Debian/Ubuntu, installalo con: sudo apt install python3-venv"
fi

# Controlla che esista il file requirements.txt
if [ ! -f "$REQUIREMENTS_FILE" ]; then
    error "File '$REQUIREMENTS_FILE' non trovato. Crealo con la lista dei pacchetti necessari."
fi

# --- 2. Creazione dell'ambiente virtuale ---
info "Gestione dell'ambiente virtuale in './${VENV_DIR}'..."
if [ ! -d "$VENV_DIR" ]; then
    info "La directory '${VENV_DIR}' non esiste. Creazione in corso..."
    python3 -m venv "$VENV_DIR"
else
    info "Ambiente virtuale '${VENV_DIR}' già esistente. Lo riutilizzo."
fi

# --- 3. Installazione delle dipendenze ---
# Usiamo il pip specifico dell'ambiente virtuale per essere espliciti e sicuri
info "Installazione dei pacchetti da '${REQUIREMENTS_FILE}'..."
"${VENV_DIR}/bin/pip" install -r "$REQUIREMENTS_FILE"

# --- 4. Esecuzione dello script principale ---
info "Esecuzione dello script rag.py..."
if [ ! -f "rag.py" ]; then
    error "Script 'rag.py' non trovato nella directory corrente."
fi
"${VENV_DIR}/bin/python3" rag.py

# --- Messaggio Finale ---
success "Setup completato con successo!"
info "Per attivare l'ambiente virtuale per uso futuro, esegui:"
info "source ${VENV_DIR}/bin/activate"
