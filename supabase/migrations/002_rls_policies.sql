-- 002_rls_policies.sql
-- Row Level Security policies for Crystal Clear Car Wash

-- ============================================================
-- Enable RLS on all tables
-- ============================================================
alter table services enable row level security;
alter table membership_plans enable row level security;
alter table locations enable row level security;
alter table customers enable row level security;
alter table bookings enable row level security;
alter table complaints enable row level security;
alter table knowledge_docs enable row level security;
alter table conversation_sessions enable row level security;

-- ============================================================
-- Public read access (anon + authenticated can SELECT)
-- ============================================================

-- Services: anyone can browse services
create policy "Public read access on services"
  on services for select
  to anon, authenticated
  using (true);

-- Membership plans: anyone can view plans
create policy "Public read access on membership_plans"
  on membership_plans for select
  to anon, authenticated
  using (true);

-- Locations: anyone can view locations
create policy "Public read access on locations"
  on locations for select
  to anon, authenticated
  using (true);

-- Knowledge docs: anyone can query the knowledge base
create policy "Public read access on knowledge_docs"
  on knowledge_docs for select
  to anon, authenticated
  using (true);

-- ============================================================
-- Service role full access (for the voice agent backend)
-- ============================================================

-- Customers: service role can do everything
create policy "Service role full access on customers"
  on customers for all
  to service_role
  using (true)
  with check (true);

-- Bookings: service role can do everything
create policy "Service role full access on bookings"
  on bookings for all
  to service_role
  using (true)
  with check (true);

-- Complaints: service role can do everything
create policy "Service role full access on complaints"
  on complaints for all
  to service_role
  using (true)
  with check (true);

-- Conversation sessions: service role can do everything
create policy "Service role full access on conversation_sessions"
  on conversation_sessions for all
  to service_role
  using (true)
  with check (true);

-- ============================================================
-- Service role also needs full access on public-read tables
-- (for inserts/updates/deletes via admin operations)
-- ============================================================

create policy "Service role full access on services"
  on services for all
  to service_role
  using (true)
  with check (true);

create policy "Service role full access on membership_plans"
  on membership_plans for all
  to service_role
  using (true)
  with check (true);

create policy "Service role full access on locations"
  on locations for all
  to service_role
  using (true)
  with check (true);

create policy "Service role full access on knowledge_docs"
  on knowledge_docs for all
  to service_role
  using (true)
  with check (true);
