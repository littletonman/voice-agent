-- 001_initial_schema.sql
-- Crystal Clear Car Wash - Initial Database Schema

-- Enable pgvector extension for knowledge base embeddings
create extension if not exists vector;

-- ============================================================
-- Services offered
-- ============================================================
create table services (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  price_cents int not null,
  duration_minutes int not null,
  category text,                -- 'wash', 'detail', 'addon'
  is_active boolean default true
);

-- ============================================================
-- Membership plans
-- ============================================================
create table membership_plans (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  monthly_price_cents int not null,
  included_services text[],
  wash_limit int,               -- null = unlimited
  discount_percent int default 0,
  description text
);

-- ============================================================
-- Locations
-- ============================================================
create table locations (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  address text not null,
  phone text,
  hours jsonb,                  -- {"mon": "7am-8pm", ...}
  is_active boolean default true
);

-- ============================================================
-- Customers
-- ============================================================
create table customers (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  phone text unique,
  email text,
  membership_plan_id uuid references membership_plans(id),
  membership_start date,
  vehicle_info text,
  created_at timestamptz default now()
);

-- ============================================================
-- Bookings / Appointments
-- ============================================================
create table bookings (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id),
  service_id uuid references services(id),
  location_id uuid references locations(id),
  scheduled_at timestamptz not null,
  status text default 'confirmed',  -- confirmed, completed, cancelled, no-show
  vehicle_info text,
  notes text,
  created_at timestamptz default now()
);

-- ============================================================
-- Complaints / Feedback
-- ============================================================
create table complaints (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id),
  booking_id uuid references bookings(id),
  category text,                -- 'damage', 'quality', 'wait_time', 'billing', 'other'
  description text not null,
  status text default 'open',   -- open, investigating, resolved
  resolution text,
  created_at timestamptz default now()
);

-- ============================================================
-- Knowledge base for RAG (embedded documents)
-- ============================================================
create table knowledge_docs (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  content text not null,
  category text,                -- 'faq', 'policy', 'service_info', 'hours', 'location', 'promotion', 'care_tips', 'membership', 'company'
  embedding vector(1536),
  created_at timestamptz default now()
);

-- ============================================================
-- Conversation sessions (for tracking voice agent interactions)
-- ============================================================
create table conversation_sessions (
  id uuid primary key default gen_random_uuid(),
  customer_id uuid references customers(id),
  started_at timestamptz default now(),
  ended_at timestamptz,
  summary text,
  transcript jsonb,
  actions_taken text[],
  metadata jsonb
);

-- ============================================================
-- Indexes
-- ============================================================

-- IVFFlat index on knowledge_docs embeddings for fast similarity search
create index on knowledge_docs using ivfflat (embedding vector_cosine_ops) with (lists = 10);

-- Lookup indexes for common queries
create index idx_bookings_customer_id on bookings(customer_id);
create index idx_bookings_scheduled_at on bookings(scheduled_at);
create index idx_customers_phone on customers(phone);
