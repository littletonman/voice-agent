# Carwash Voice Agent

AI-powered voice agent for carwash customer service. Customers speak naturally to get info on services, book appointments, manage memberships, and file complaints.

## Tech Stack

- **Frontend**: React 18 + Vite + TypeScript + Tailwind CSS + shadcn/ui (deployed on Vercel)
- **Voice Agent**: Python + LiveKit Agents SDK (deployed on Railway)
- **Database**: Supabase (Postgres + pgvector)
- **LLM**: Claude (Anthropic)
- **Voice**: LiveKit (WebRTC) with Deepgram STT and ElevenLabs/Cartesia TTS

## Architecture

```
Browser (React) --WebRTC--> LiveKit Cloud ---> Python Agent ---> Claude LLM
                                                    |
                                              Supabase pgvector
                                           (RAG knowledge base)
```

## Getting Started

See [PLAN.md](./PLAN.md) for the full implementation plan with phased tasks.

## Project Structure

```
voice-agent/
├── frontend/       # React SPA
├── agent/          # Python LiveKit voice agent
├── supabase/       # Database migrations & seed data
├── PLAN.md         # Implementation plan
└── README.md
```
