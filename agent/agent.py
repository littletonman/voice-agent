import logging

from dotenv import load_dotenv
from livekit import agents
from livekit.agents import JobContext, WorkerOptions, cli
from livekit.agents.voice import VoicePipelineAgent
from livekit.plugins import anthropic, cartesia, deepgram

from prompts import SYSTEM_PROMPT
from rag import retrieve_knowledge
from tools import (
    book_appointment,
    cancel_appointment,
    check_availability,
    file_complaint,
    get_membership_info,
    get_operating_hours,
    get_services,
    lookup_customer,
)

load_dotenv()

logger = logging.getLogger("carwash-agent")
logger.setLevel(logging.INFO)


def _build_tools() -> list[agents.llm.FunctionTool]:
    """Wrap each tool function as a FunctionTool for the LLM."""
    tool_functions = [
        get_services,
        get_membership_info,
        check_availability,
        book_appointment,
        cancel_appointment,
        lookup_customer,
        file_complaint,
        get_operating_hours,
    ]
    return [agents.llm.FunctionTool.create(fn) for fn in tool_functions]


async def entrypoint(ctx: JobContext):
    """Main entrypoint called by the LiveKit worker for each session."""
    await ctx.connect()

    logger.info(
        "Session started — room=%s, participant=%s",
        ctx.room.name,
        ctx.room.local_participant.identity if ctx.room.local_participant else "unknown",
    )

    # Chat history maintained across the session
    chat_history: list[agents.llm.ChatMessage] = []

    # Build the enriched system prompt with RAG context
    async def _enrich_system_prompt(
        assistant: VoicePipelineAgent,
        chat_ctx: agents.llm.ChatContext,
    ):
        """Before each LLM call, inject relevant knowledge from RAG."""
        # Extract the latest user message for RAG query
        user_messages = [
            msg for msg in chat_ctx.messages if msg.role == "user"
        ]
        if not user_messages:
            return

        latest_query = user_messages[-1].text_content or ""
        if not latest_query.strip():
            return

        # Retrieve relevant knowledge docs
        docs = retrieve_knowledge(latest_query, top_k=3)
        if docs:
            context_block = "\n\n".join(
                f"[Knowledge {i+1}]: {doc['content']}"
                for i, doc in enumerate(docs)
                if doc.get("content")
            )
            if context_block:
                # Prepend knowledge context to the system message
                enriched_prompt = (
                    f"{SYSTEM_PROMPT}\n\n"
                    f"## Relevant Knowledge Base Context\n"
                    f"Use the following information to answer the customer's question "
                    f"if relevant:\n\n{context_block}"
                )
                # Update the system message in the chat context
                if chat_ctx.messages and chat_ctx.messages[0].role == "system":
                    chat_ctx.messages[0].text_content = enriched_prompt

    # Initialize STT, LLM, and TTS plugins
    stt = deepgram.STT()
    llm = anthropic.LLM(model="claude-sonnet-4-20250514")
    tts = cartesia.TTS()

    # Create the voice pipeline agent
    assistant = VoicePipelineAgent(
        vad=agents.vad.load(),
        stt=stt,
        llm=llm,
        tts=tts,
        chat_ctx=agents.llm.ChatContext().append(
            role="system",
            text=SYSTEM_PROMPT,
        ),
        tools=_build_tools(),
        before_llm_cb=_enrich_system_prompt,
    )

    # Start the agent — it will listen for audio and respond
    assistant.start(ctx.room)

    # Greet the customer
    await assistant.say(
        "Hi there! Thanks for calling Crystal Clear Car Wash. "
        "This is Sparkle — how can I help you today?"
    )

    logger.info("Agent is running and ready for conversation.")


if __name__ == "__main__":
    cli.run_app(WorkerOptions(entrypoint_fnc=entrypoint))
