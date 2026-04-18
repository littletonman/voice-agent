import os
from typing import Optional

from dotenv import load_dotenv
from supabase import create_client, Client

load_dotenv()


def _get_supabase() -> Client:
    """Lazy Supabase client — only connects when RAG is actually called."""
    url = os.environ.get("SUPABASE_URL", "")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
    if not url or not key:
        raise RuntimeError("SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY must be set")
    return create_client(url, key)


def retrieve_knowledge(query: str, top_k: int = 5) -> list[dict]:
    """Retrieve relevant knowledge documents using text search.

    Uses PostgreSQL full-text search as a fallback until embeddings are generated.
    Once embeddings are populated, this can be upgraded to pgvector cosine similarity.

    Args:
        query: The user's question or search query.
        top_k: Number of top results to return. Defaults to 5.

    Returns:
        A list of dicts, each containing "content", "title", and "category".
    """
    sb = _get_supabase()

    # Use ilike text search as a simple fallback (works without embeddings)
    # Split query into keywords and search for any match
    keywords = [w.strip() for w in query.lower().split() if len(w.strip()) > 2]

    if not keywords:
        # Return general FAQ docs if no meaningful keywords
        result = (
            sb.table("knowledge_docs")
            .select("title, content, category")
            .limit(top_k)
            .execute()
        )
        return [{"content": r["content"], "title": r["title"], "category": r["category"]} for r in result.data]

    # Search for docs matching any keyword in title or content
    # Use the first few keywords for a broader search
    search_term = " ".join(keywords[:3])
    result = (
        sb.table("knowledge_docs")
        .select("title, content, category")
        .or_(f"title.ilike.%{search_term}%,content.ilike.%{search_term}%")
        .limit(top_k)
        .execute()
    )

    # If no results with combined keywords, try individual keywords
    if not result.data and len(keywords) > 1:
        for kw in keywords[:3]:
            result = (
                sb.table("knowledge_docs")
                .select("title, content, category")
                .or_(f"title.ilike.%{kw}%,content.ilike.%{kw}%")
                .limit(top_k)
                .execute()
            )
            if result.data:
                break

    documents = []
    for row in result.data or []:
        documents.append({
            "content": row.get("content", ""),
            "title": row.get("title", ""),
            "category": row.get("category", ""),
        })

    return documents
