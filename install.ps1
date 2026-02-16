<#
.SYNOPSIS
    Script per configurare l'ambiente di sviluppo Python per il progetto RAG.
    Crea un ambiente virtuale, installa le dipendenze e avvia lo script principale.

.DESCRIPTION
    Questo script automatizza i seguenti passaggi:
    1. Verifica la presenza di Python 3.
    2. Controlla che il modulo 'venv' sia disponibile.
    3. Controlla l'esistenza del file 'requirements.txt'.
    4. Crea un ambiente virtuale se non esiste già.
    5. Installa i pacchetti Python necessari.
    6. Esegue lo script 'rag.py'.
#>

# --- Impostazioni di Sicurezza ---
# Interrompe l'esecuzione dello script immediatamente in caso di errore
$ErrorActionPreference = "Stop"

# --- Variabili di Configurazione ---
$VenvDir = "venv"
$RequirementsFile = "requirements.txt"
$MainScript = "rag.py"

# --- Funzioni di Utility per l'Output ---
function Write-Info {
    param ([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param ([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error {
    param ([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    # Esce dallo script con un codice di errore
    exit 1
}


# --- 1. Controllo dei Prerequisiti ---
Write-Info "Controllo dei prerequisiti..."

# Verifica se il comando 'python3' o 'python' esiste
$pythonExe = Get-Command python3 -ErrorAction SilentlyContinue
if (-not $pythonExe) {
    $pythonExe = Get-Command python -ErrorAction SilentlyContinue
    if (-not $pythonExe) {
        Write-Error "Python non trovato nel PATH. Per favore, installalo (consigliato Python 3.8+) e assicurati che sia nel PATH."
    }
}
Write-Info "Trovato eseguibile Python: $($pythonExe.Source)"

# Verifica se il modulo 'venv' è disponibile
try {
    & $pythonExe.Source -c "import venv"
} catch {
    Write-Error "Il modulo 'venv' di Python non è installato o non funziona correttamente."
}

# Verifica l'esistenza del file requirements.txt
if (-not (Test-Path -Path $RequirementsFile -PathType Leaf)) {
    Write-Error "File '$RequirementsFile' non trovato. Crealo con la lista dei pacchetti necessari."
}


# --- 2. Creazione dell'Ambiente Virtuale ---
Write-Info "Gestione dell'ambiente virtuale in '.\$VenvDir'..."

if (-not (Test-Path -Path $VenvDir -PathType Container)) {
    Write-Info "La directory '$VenvDir' non esiste. Creazione in corso..."
    & $pythonExe.Source -m venv $VenvDir
} else {
    Write-Info "Ambiente virtuale '$VenvDir' già esistente. Lo riutilizzo."
}


# --- 3. Installazione delle Dipendenze ---
# Costruisce il percorso per il pip dell'ambiente virtuale
$PipPath = Join-Path -Path $VenvDir -ChildPath "Scripts\pip.exe"

if (-not (Test-Path -Path $PipPath)) {
    Write-Error "Eseguibile pip non trovato in '$PipPath'. La creazione dell'ambiente virtuale potrebbe essere fallita."
}

Write-Info "Installazione dei pacchetti da '$RequirementsFile'..."
# L'operatore '&' (call operator) è usato per eseguire un comando il cui percorso è in una variabile
& $PipPath install -r $RequirementsFile


# --- 4. Esecuzione dello Script Principale ---
Write-Info "Esecuzione dello script '$MainScript'..."

if (-not (Test-Path -Path $MainScript -PathType Leaf)) {
    Write-Error "Script '$MainScript' non trovato nella directory corrente."
}

# Costruisce il percorso per il python dell'ambiente virtuale
$PythonVenvPath = Join-Path -Path $VenvDir -ChildPath "Scripts\python.exe"
& $PythonVenvPath $MainScript


# --- Messaggio Finale ---
Write-Success "Setup completato con successo!"
Write-Info "Per attivare l'ambiente virtuale per uso futuro, esegui:"
Write-Info ".\$VenvDir\Scripts\Activate.ps1"
