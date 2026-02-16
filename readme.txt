Istruzioni per il RAG

1. Installate python all'ultima versione e Ollama, scaricatevi Mistral (ollama run mistral)

2. Create un ambiente virtuale python dentro la cartella: 

python3 -m venv venv

e poi eseguite

source venv/bin/activate

3. Installate i pacchetti necessari con pip

pip install langchain langchain-chroma langchain-ollama langchain-community pypdf

4. Avviate lo script

python3 rag.py



Ogni volta che avviate lo script ricordatevi di avviare l'ambiente virtuale, altrimenti non funzionerà.
