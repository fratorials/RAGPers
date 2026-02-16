# RAGPers
Un RAG personale per studiare, totalmente offline, molto basico.
Crea una cartella dove mettere i documenti che lui deve imparare, è molto specifico ma a volte può sbagliare.

## Istruzioni per il RAG

1. Installate python all'ultima versione e Ollama, scaricatevi Mistral

  ` ollama run mistral `

3. Create un ambiente virtuale python dentro la cartella: 

  `python3 -m venv venv`

e poi eseguite

  `source venv/bin/activate`

3. Installate i pacchetti necessari con pip

  `pip install langchain langchain-chroma langchain-ollama langchain-community pypdf`

4. Avviate lo script

  `python3 rag.py`

___

*Ogni volta che avviate lo script ricordatevi di avviare l'ambiente virtuale, altrimenti non funzionerà.*
