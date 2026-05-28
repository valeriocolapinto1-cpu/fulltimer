-- FullTimer: daily competition results
-- Run this in the Supabase SQL Editor (https://supabase.com/dashboard/project/btammoapputkbnbbscej/sql/new)

-- 1. Create the table
create table if not exists competition_results (
  user_id      text        not null,
  event_id     text        not null,
  date         text        not null,
  display_name text        not null default 'Anonimo',
  times        int[]       not null default '{}',
  ao5          int         not null default 0,
  submitted_at timestamptz not null default now(),
  constraint pk_competition_results primary key (user_id, event_id, date)
);

-- 2. Indexes for common queries
create index if not exists idx_comp_event_date
  on competition_results (event_id, date, ao5);

create index if not exists idx_comp_user
  on competition_results (user_id, submitted_at);

-- 3. Row Level Security
alter table competition_results enable row level security;

-- Allow anonymous and authenticated users to insert their own rows
create policy "Anyone can insert their own results"
  on competition_results for insert
  with check (true);

-- Allow everyone to read all results (for leaderboard)
create policy "Anyone can read results"
  on competition_results for select
  using (true);

-- Allow users to update only their own rows
create policy "Users can update their own results"
  on competition_results for update
  using (user_id = current_setting('request.jwt.claims', true)::json->>'sub'
    or user_id = current_setting('request.jwt.claims', true)::json->>'anon_id');
