import logging
import os

from dotenv import load_dotenv
from livekit import agents
from livekit.agents import JobContext, WorkerOptions, cli
from livekit.agents.voice import AgentSession, Agent
from livekit.plugins import anthropic, cartesia, deepgram, silero

from prompts import SYSTEM_PROMPT

load_dotenv()

logger = logging.getLogger("carwash-agent")
logger.setLevel(logging.INFO)


async def entrypoint(ctx: JobContext):
    """Main entrypoint called by the LiveKit worker for each session."""
    await ctx.connect()

    logger.info(
        "Session started — room=%s, participant=%s",
        ctx.room.name,
        ctx.room.local_participant.identity if ctx.room.local_participant else "unknown",
    )

    # Lazy import tools to avoid crash if Supabase env vars are missing at import time
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
    from rag import retrieve_knowledge

    # Build tool list
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

    # Create the agent session with STT, LLM, TTS
    session = AgentSession(
        vad=silero.VAD.load(),
        stt=deepgram.STT(),
        llm=anthropic.LLM(model="claude-sonnet-4-6"),
        tts=cartesia.TTS(),
    )

    # Start the agent
    await session.start(
        room=ctx.room,
        agent=Agent(
            instructions=SYSTEM_PROMPT,
            tools=tool_functions,
        ),
    )

    # Greet the customer
    await session.say(
        "Hi there! Thanks for calling Crystal Clear Car Wash. "
        "This is Sparkle — how can I help you today?"
    )

    logger.info("Agent is running and ready for conversation.")


if __name__ == "__main__":
    cli.run_app(WorkerOptions(entrypoint_fnc=entrypoint))
