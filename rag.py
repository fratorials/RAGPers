import os
from pathlib import Path
from langchain_chroma import Chroma
from langchain_ollama import OllamaLLM, OllamaEmbeddings
from langchain_community.document_loaders import PyPDFLoader, TextLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain.prompts import PromptTemplate
from langchain_core.output_parsers import StrOutputParser

# LA RIGA PROBLEMATICA È STATA ELIMINATA
# from langchain_core.runnable import RunnablePassthrough 

# --- CONFIGURAZIONE ---
SCRIPT_DIR = Path(__file__).parent
DATA_DIR = SCRIPT_DIR / "dati"
DB_DIR = SCRIPT_DIR / "chroma_db"
MODEL_NAME = "mistral"
CHUNK_SIZE = 1000
RETRIEVER_K = 5

def load_or_create_vector_store():
    embeddings_function = OllamaEmbeddings(model=MODEL_NAME)
    
    if DB_DIR.exists() and os.listdir(DB_DIR):
        print(f"Caricamento del database vettoriale esistente da '{DB_DIR}'...")
        vector_store = Chroma(
            persist_directory=str(DB_DIR),
            embedding_function=embeddings_function
        )
        print("Database caricato con successo.")
        return vector_store
    else:
        print(f"Nessun database trovato. Creazione in corso da i file in '{DATA_DIR}'...")
        
        if not DATA_DIR.exists() or not any(DATA_DIR.iterdir()):
            print(f"Errore: La cartella '{DATA_DIR}' non esiste o è vuota.")
            print("Per favore, crea la cartella 'dati' e mettici dentro i tuoi documenti (.pdf, .txt).")
            return None

        doc_files = list(DATA_DIR.glob("*.pdf")) + list(DATA_DIR.glob("*.txt"))
        if not doc_files:
            print(f"Errore: Nessun file .pdf o .txt trovato nella cartella '{DATA_DIR}'.")
            return None
        
        print(f"Trovati {len(doc_files)} documenti da processare.")
        
        docs_list = []
        for file_path in doc_files:
            print(f"  - Caricamento di '{file_path.name}'...")
            if file_path.suffix == '.pdf':
                loader = PyPDFLoader(str(file_path))
            elif file_path.suffix == '.txt':
                loader = TextLoader(str(file_path), encoding='utf-8')
            docs_list.extend(loader.load())

        print("Suddivisione dei documenti in chunks...")
        text_splitter = RecursiveCharacterTextSplitter(chunk_size=CHUNK_SIZE, chunk_overlap=150)
        chunks = text_splitter.split_documents(docs_list)
        print(f"Creati {len(chunks)} chunks di testo.")

        print("Creazione degli embeddings e salvataggio del database...")
        vector_store = Chroma.from_documents(
            documents=chunks,
            embedding=embeddings_function,persist_directory=str(DB_DIR)
        )
        print("Database creato e salvato con successo.")
        return vector_store

def main():
    vector_store = load_or_create_vector_store()
    
    if vector_store is None:
        return

    llm = OllamaLLM(model=MODEL_NAME)
    retriever = vector_store.as_retriever(search_kwargs={'k': RETRIEVER_K})
    
    template = """
    Personalità:
        Sei coerente e coinciso, prediligi i prompt, formule e poi il concetto, NON PROCESSARE MAI I LINK (non esistono)
        Un eseperto delle tecniche di cybersecurity, DevOps, DFIR, CVE, ROI, Normativa della cybersec
        Includere formule e comandi quando rilevanti.
        Nei blocchi tecnici mantenere chiarezza (liste, tabelle, codice).
    
    Contesto:
    {context}

    Domanda: {question}

    Blocco di comandi e configurazione:
    """
    prompt = PromptTemplate.from_template(template)
    
    # --- WORKAROUND PER L'ERRORE DI IMPORT ---
    # Sostituiamo RunnablePassthrough() con una semplice funzione lambda
    # che fa esattamente la stessa cosa: passa l'input senza modificarlo.
    rag_chain = (
        {"context": retriever, "question": (lambda x: x)}
        | prompt
        | llm
        | StrOutputParser()
    )

    print("\n--- Sistema RAG pronto. Scrivi 'esci' per terminare. ---")
    
    while True:
        try:
            query = input("\nFai la tua domanda: ")
            if query.lower().strip() == 'esci':
                break
            if not query.strip():
                continue
            
            print("\nRisposta: ", end="", flush=True)

            for chunk in rag_chain.stream(query):
                print(chunk, end="", flush=True)
            
            print()

        except KeyboardInterrupt:
            print("\nUscita in corso...")
            break

if __name__ == "__main__":
    main()