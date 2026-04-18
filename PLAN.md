# Carwash Voice Agent - Implementation Plan

## Context

Build a full-service AI voice agent for a carwash company. Customers call in (via web) and speak naturally to get info on services/pricing, book appointments, manage memberships, and file complaints. The architecture adapts the Voice-Enabled RAG Agent pattern from the Vibe Builders Circle workshop, using LiveKit for real-time WebRTC voice, Claude as the LLM, and Supabase pgvector for knowledge retrieval.

## Architecture Overview

```
User (Browser)
  |
  | WebRTC audio (LiveKit Client SDK)
  v
LiveKit Cloud Server
  |
  |-- STT (Deepgram via LiveKit) --> transcribed text
  |-- Agent Server (Python, LiveKit Agents Framework)
  |     |
  |     |-- RAG: query Supabase pgvector for carwash knowledge
  |     |-- LLM: Claude (Anthropic) generates response
  |     |-- Tools: book appointment, lookup membership, file complaint
  |     |
  |     v
  |-- TTS (ElevenLabs or Cartesia via LiveKit) --> audio
  |
  v
User hears response (WebRTC)

Frontend (React SPA on Vercel) -- connects to LiveKit room
Backend Agent (Python, deployed on Railway/Fly.io/LiveKit Cloud)
Database (Supabase: Postgres + pgvector + Auth)
```

**Key architectural decision**: LiveKit Agents Framework is Python-based and runs as a long-lived process (not serverless). It cannot run on Vercel or as a Supabase Edge Function. It needs a separate deployment target (Railway, Fly.io, or LiveKit Cloud's hosted agents).

## Two-Service Architecture

| Service | Tech | Deployed On | Purpose |
|---------|------|------------|---------|
| **Frontend** | React 18 + Vite + TypeScript | Vercel | Voice UI, transcript display, booking forms |
| **Voice Agent** | Python + LiveKit Agents SDK | Railway or Fly.io | STT/TTS pipeline, LLM orchestration, RAG, tool execution |
| **Database** | Supabase (Postgres + pgvector) | Supabase Cloud | Knowledge base, bookings, memberships, complaints |

---

## Data Model (Carwash Entities)

```sql
-- Services offered
create table services (
  id uuid primary key default gen_random_uuid(),
  name text not null,           -- 'Basic Wash', 'Premium Detail', etc.
  description text,
  price_cents int not null,
  duration_minutes int not null,
  category text,                -- 'wash', 'detail', 'addon'
  is_active boolean default true
);

-- Membership plans
create table membership_plans (
  id uuid primary key default gen_random_uuid(),
  name text not null,           -- 'Silver', 'Gold', 'Platinum'
  monthly_price_cents int not null,
  included_services text[],     -- array of service names
  wash_limit int,               -- null = unlimited
  description text
);

-- Customers
create table customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text unique,
  email text,
  membership_plan_id uuid references membership_plans(id),
  membership_start date,
  created_at timestamptz default now()
);

-- Appointments / Bookings
create table bookings (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id),
  service_id uuid references services(id),
  scheduled_at timestamptz not null,
  status text default 'confirmed',  -- confirmed, completed, cancelled, no-show
  vehicle_info text,                  -- 'Red Toyota Camry'
  notes text,
  created_at timestamptz default now()
);

-- Complaints / Feedback
create table complaints (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id),
  booking_id uuid references bookings(id),
  category text,              -- 'damage', 'quality', 'wait_time', 'billing', 'other'
  description text not null,
  status text default 'open', -- open, investigating, resolved
  resolution text,
  created_at timestamptz default now()
);

-- Knowledge base for RAG (embedded docs)
create table knowledge_docs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  content text not null,
  category text,              -- 'faq', 'policy', 'service_info', 'hours', 'location'
  embedding vector(1536),     -- for pgvector similarity search
  created_at timestamptz default now()
);

-- Locations
create table locations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text not null,
  phone text,
  hours jsonb,                -- {"mon": "7am-8pm", "tue": "7am-8pm", ...}
  is_active boolean default true
);
```

---

## Project Structure

```
voice-agent/
├── frontend/                    # React SPA (deployed to Vercel)
│   ├── src/
│   │   ├── components/
│   │   │   ├── VoiceAgent.tsx       # Main voice interface
│   │   │   ├── TranscriptPanel.tsx  # Live conversation transcript
│   │   │   ├── StatusIndicator.tsx  # Connection/agent status
│   │   │   ├── ServiceCard.tsx      # Display service info
│   │   │   └── ui/                  # shadcn/ui components
│   │   ├── hooks/
│   │   │   └── useLiveKitRoom.ts    # LiveKit room connection
│   │   ├── lib/
│   │   │   ├── supabase.ts          # Supabase client
│   │   │   └── livekit.ts           # LiveKit token fetcher
│   │   ├── pages/
│   │   │   ├── Home.tsx             # Landing page
│   │   │   └── Agent.tsx            # Voice agent page
│   │   ├── App.tsx
│   │   └── main.tsx
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.ts
│   └── tsconfig.json
│
├── agent/                       # Python LiveKit Agent (deployed to Railway)
│   ├── agent.py                 # Main agent: STT -> LLM -> TTS pipeline
│   ├── tools.py                 # Tool definitions (book, lookup, complain)
│   ├── rag.py                   # RAG retrieval from Supabase pgvector
│   ├── prompts.py               # System prompt for carwash persona
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
│
├── supabase/                    # Database setup
│   ├── migrations/
│   │   └── 001_initial_schema.sql
│   ├── seed.sql                 # Sample carwash data
│   └── functions/
│       └── livekit-token/       # Edge function to generate LiveKit tokens
│           └── index.ts
│
├── PLAN.md                      # This file
└── README.md
```

---

## Phased Implementation Plan

### Phase 0: Account Setup & Project Scaffolding

| # | Task | Owner | Details |
|---|------|-------|---------|
| 0.1 | Create Supabase project | **[HUMAN]** | Go to supabase.com, create project, note URL + anon key + service role key |
| 0.2 | Create LiveKit Cloud account | **[HUMAN]** | Go to livekit.io, create project, get API key + secret + WebSocket URL |
| 0.3 | Get Anthropic API key | **[HUMAN]** | From console.anthropic.com (for the Python agent) |
| 0.4 | Get ElevenLabs API key (optional) | **[HUMAN]** | For premium TTS voices; LiveKit has built-in TTS alternatives |
| 0.5 | Create Railway/Fly.io account | **[HUMAN]** | For deploying the Python agent service |
| 0.6 | Scaffold React frontend (Vite + TS) | **[AGENT]** | `npm create vite@latest`, install deps, configure Tailwind + shadcn |
| 0.7 | Scaffold Python agent project | **[AGENT]** | Create agent/, requirements.txt, Dockerfile, .env.example |
| 0.8 | Initialize Supabase schema | **[AGENT]** | Write migration SQL, enable pgvector extension |
| 0.9 | Create seed data | **[AGENT]** | Sample services, plans, customers, locations, knowledge docs |
| 0.10 | Set up git repo | **[AGENT]** | Init repo, .gitignore, initial commit |

### Phase 1: Database & Knowledge Base

| # | Task | Owner | Details |
|---|------|-------|---------|
| 1.1 | Run schema migration on Supabase | **[HUMAN]** | Apply the migration SQL via Supabase dashboard or CLI |
| 1.2 | Enable pgvector extension | **[AGENT]** | Include `create extension vector` in migration |
| 1.3 | Write seed data script | **[AGENT]** | 10+ services, 3 membership plans, 5 sample customers, 2 locations, 20+ knowledge docs |
| 1.4 | Run seed data | **[HUMAN]** | Execute seed.sql via Supabase SQL editor |
| 1.5 | Generate embeddings for knowledge docs | **[AGENT]** | Python script using Anthropic/OpenAI embeddings API to populate the `embedding` column |
| 1.6 | Run embedding script | **[HUMAN]** | `python embed_docs.py` (requires API key) |
| 1.7 | Set up RLS policies | **[AGENT]** | Write Row Level Security policies for each table |

### Phase 2: Python Voice Agent (Core)

| # | Task | Owner | Details |
|---|------|-------|---------|
| 2.1 | Build agent.py with LiveKit Agents SDK | **[AGENT]** | Voice pipeline: STT (Deepgram) -> Claude LLM -> TTS (Cartesia/ElevenLabs) |
| 2.2 | Write system prompt (prompts.py) | **[AGENT]** | Carwash customer service persona, tone, guardrails |
| 2.3 | Implement RAG retrieval (rag.py) | **[AGENT]** | Query Supabase pgvector, return top-k relevant docs |
| 2.4 | Implement tool definitions (tools.py) | **[AGENT]** | `book_appointment`, `lookup_membership`, `check_availability`, `file_complaint`, `get_services`, `get_hours` |
| 2.5 | Add conversation memory | **[AGENT]** | Session-scoped chat history passed to Claude |
| 2.6 | Test agent locally | **[HUMAN]** | `python agent.py dev` -- speak to it, verify responses |
| 2.7 | Iterate on prompt & tools | **[HUMAN]** | Tune the persona, fix edge cases in tool behavior |

### Phase 3: Frontend - Voice UI

| # | Task | Owner | Details |
|---|------|-------|---------|
| 3.1 | Build LiveKit token endpoint | **[AGENT]** | Supabase Edge Function that generates LiveKit room tokens |
| 3.2 | Deploy token endpoint | **[HUMAN]** | Deploy edge function via Supabase CLI |
| 3.3 | Build VoiceAgent component | **[AGENT]** | LiveKit React SDK: connect to room, mic controls, agent status |
| 3.4 | Build TranscriptPanel component | **[AGENT]** | Real-time display of user + agent speech (using LiveKit transcription events) |
| 3.5 | Build StatusIndicator component | **[AGENT]** | Shows: connecting, listening, thinking, speaking |
| 3.6 | Build Home/Landing page | **[AGENT]** | Simple page with "Start Call" button, carwash branding |
| 3.7 | Style with Tailwind + shadcn | **[AGENT]** | Clean, professional carwash theme |
| 3.8 | Install AI Elements (persona, speech-input) | **[AGENT]** | Animated agent visual + voice capture components |
| 3.9 | Wire up end-to-end | **[AGENT]** | Frontend -> LiveKit -> Agent -> response |
| 3.10 | Test full flow in browser | **[HUMAN]** | Verify voice input/output, transcript, tool calls work |

### Phase 4: Deployment

| # | Task | Owner | Details |
|---|------|-------|---------|
| 4.1 | Deploy frontend to Vercel | **[HUMAN]** | Connect GitHub repo, set env vars (Supabase URL, LiveKit URL) |
| 4.2 | Write Dockerfile for agent | **[AGENT]** | Python agent containerized with all deps |
| 4.3 | Deploy agent to Railway | **[HUMAN]** | Push to Railway, set env vars (LiveKit keys, Anthropic key, Supabase keys) |
| 4.4 | Configure env vars on all platforms | **[HUMAN]** | Ensure all services can talk to each other |
| 4.5 | End-to-end production test | **[HUMAN]** | Call the agent from the deployed URL, test all features |

### Phase 5 (Stretch): Enhancements

| # | Task | Owner | Details |
|---|------|-------|---------|
| 5.1 | Add phone number via LiveKit SIP | **[HUMAN]** | Connect a real phone number so customers can call in |
| 5.2 | Add booking confirmation SMS | **[AGENT]** | Use Twilio/Supabase to send SMS confirmations |
| 5.3 | Admin dashboard | **[AGENT]** | View bookings, complaints, call logs |
| 5.4 | Analytics | **[AGENT]** | Track call duration, resolution rate, common questions |

---

## Work Split Summary

| Category | [HUMAN] Tasks | [AGENT] Tasks |
|----------|--------------|---------------|
| **Setup** | Create accounts (Supabase, LiveKit, Anthropic, Railway), get API keys | Scaffold projects, configure build tools |
| **Database** | Run migrations, run seeds, run embedding script | Write schema, seed data, embedding script, RLS policies |
| **Agent** | Test locally, iterate on prompt, tune behavior | Build entire Python agent (pipeline, RAG, tools, prompt) |
| **Frontend** | Deploy edge function | Build all React components, styling, LiveKit integration |
| **Deploy** | Deploy to Vercel + Railway, configure env vars | Write Dockerfile, deployment configs |
| **Review** | Review & approve all code changes | Write all code |

**In short**: You handle accounts/keys/deployments/testing. The agent handles all code.

---

## Environment Variables Needed

```
# Frontend (.env)
VITE_SUPABASE_URL=
VITE_SUPABASE_ANON_KEY=
VITE_LIVEKIT_URL=             # wss://your-project.livekit.cloud

# Supabase Edge Function (livekit-token)
LIVEKIT_API_KEY=
LIVEKIT_API_SECRET=

# Python Agent (.env)
LIVEKIT_URL=
LIVEKIT_API_KEY=
LIVEKIT_API_SECRET=
ANTHROPIC_API_KEY=
SUPABASE_URL=
SUPABASE_SERVICE_ROLE_KEY=
ELEVENLABS_API_KEY=           # optional, for premium TTS
DEEPGRAM_API_KEY=             # for STT
```

---

## Verification Strategy

1. **Database**: Run `select count(*) from services;` etc. to verify seed data loaded
2. **Embeddings**: Run `select id, title, 1 - (embedding <=> query_embedding) as similarity from knowledge_docs order by similarity desc limit 5;` to verify RAG works
3. **Agent locally**: `python agent.py dev` and test voice conversation
4. **Frontend locally**: `npm run dev`, click "Start Call", verify LiveKit connection
5. **End-to-end**: Deployed frontend -> LiveKit Cloud -> Agent on Railway -> Supabase -> response back to user
6. **Test scenarios**:
   - "What services do you offer?" (knowledge retrieval)
   - "I'd like to book a premium wash for tomorrow at 2pm" (tool: book_appointment)
   - "What's included in the Gold membership?" (tool: lookup_membership)
   - "I want to file a complaint about my last visit" (tool: file_complaint)
   - "What are your hours?" (knowledge retrieval)
