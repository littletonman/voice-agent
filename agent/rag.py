import os
from typing import Optional

from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()

supabase: Client = create_client(
    os.environ["SUPABASE_URL"],
    os.environ["SUPABASE_SERVICE_ROLE_KEY"],
)


def _generate_embedding(text: str) -> list[float]:
    """Generate an embedding vector for the given text.

    TODO: Replace this placeholder with a real embedding model call.
    Options include:
      - OpenAI text-embedding-3-small
      - Anthropic Voyager
      - A local sentence-transformers model
      - Deepgram or another provider

    For now, returns a zero vector of dimension 1536 as a placeholder.
    """
    embedding_dim = 1536
    return [0.0] * embedding_dim


def retrieve_knowledge(query: str, top_k: int = 5) -> list[dict]:
    """Retrieve relevant knowledge documents using pgvector cosine similarity.

    Calls a Supabase RPC function that performs a vector similarity search
    against the knowledge_docs table.

    Args:
        query: The user's question or search query.
        top_k: Number of top results to return. Defaults to 5.

    Returns:
        A list of dicts, each containing "content", "metadata", and "similarity".
    """
    query_embedding = _generate_embedding(query)

    result = supabase.rpc(
        "match_knowledge_docs",
        {
            "query_embedding": query_embedding,
            "match_count": top_k,
        },
    ).execute()

    documents = []
    for row in result.data or []:
        documents.append(
            {
                "content": row.get("content", ""),
                "metadata": row.get("metadata", {}),
                "similarity": row.get("similarity", 0.0),
            }
        )

    return documents
