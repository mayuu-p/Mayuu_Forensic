-- PROPOSED ONLY. Do not apply until the existing Supabase project is inspected.
-- Backend service writes evidence/metadata/audit rows. Clients receive read-only access
-- to their own rows. Never expose a service-role key in client applications.

create extension if not exists pgcrypto;

create table if not exists public.mdfl_evidence (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete restrict,
  original_filename text not null,
  storage_path text not null unique,
  mime_type text not null check (mime_type in ('image/jpeg','image/png','image/heic','image/heif')),
  file_size_bytes bigint not null check (file_size_bytes > 0 and file_size_bytes <= 26214400),
  sha256_original char(64) not null check (sha256_original ~ '^[0-9a-f]{64}$'),
  sha256_stored char(64),
  integrity_status text not null default 'pending'
    check (integrity_status in ('pending','match','mismatch','failed')),
  processing_status text not null default 'pending'
    check (processing_status in ('pending','processing','completed','failed')),
  server_received_at timestamptz not null default now(),
  processed_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists mdfl_evidence_owner_created_idx
  on public.mdfl_evidence(owner_id, created_at desc);

create table if not exists public.mdfl_metadata (
  evidence_id uuid primary key references public.mdfl_evidence(id) on delete cascade,
  exif jsonb not null default '{}'::jsonb,
  capture_time_raw text,
  capture_time_normalized timestamptz,
  camera_make text,
  camera_model text,
  software text,
  gps_latitude double precision check (gps_latitude is null or gps_latitude between -90 and 90),
  gps_longitude double precision check (gps_longitude is null or gps_longitude between -180 and 180),
  gps_altitude double precision,
  gps_timestamp_raw text,
  gps_present boolean not null default false,
  extraction_warnings jsonb not null default '[]'::jsonb,
  extracted_at timestamptz not null default now(),
  check (
    (gps_latitude is null and gps_longitude is null)
    or (gps_latitude is not null and gps_longitude is not null)
  )
);

create table if not exists public.mdfl_audit_logs (
  id bigint generated always as identity primary key,
  evidence_id uuid references public.mdfl_evidence(id) on delete set null,
  actor_id uuid references auth.users(id) on delete set null,
  action text not null check (action in (
    'upload_received','metadata_extracted','integrity_verified',
    'evidence_viewed','evidence_downloaded','report_exported','evidence_deleted'
  )),
  details jsonb not null default '{}'::jsonb,
  occurred_at timestamptz not null default now()
);

create index if not exists mdfl_audit_evidence_time_idx
  on public.mdfl_audit_logs(evidence_id, occurred_at desc);

alter table public.mdfl_evidence enable row level security;
alter table public.mdfl_metadata enable row level security;
alter table public.mdfl_audit_logs enable row level security;

-- Read-only client policies. Inserts/updates/deletes are reserved for trusted backend.
drop policy if exists "mdfl owner reads evidence" on public.mdfl_evidence;
create policy "mdfl owner reads evidence"
  on public.mdfl_evidence for select to authenticated
  using ((select auth.uid()) = owner_id);

drop policy if exists "mdfl owner reads metadata" on public.mdfl_metadata;
create policy "mdfl owner reads metadata"
  on public.mdfl_metadata for select to authenticated
  using (exists (
    select 1 from public.mdfl_evidence e
    where e.id = evidence_id and e.owner_id = (select auth.uid())
  ));

drop policy if exists "mdfl owner reads audit" on public.mdfl_audit_logs;
create policy "mdfl owner reads audit"
  on public.mdfl_audit_logs for select to authenticated
  using (
    actor_id = (select auth.uid())
    or exists (
      select 1 from public.mdfl_evidence e
      where e.id = evidence_id and e.owner_id = (select auth.uid())
    )
  );

-- Least privilege: no anon access; authenticated clients can only read rows allowed by RLS.
revoke all on public.mdfl_evidence from anon, authenticated;
revoke all on public.mdfl_metadata from anon, authenticated;
revoke all on public.mdfl_audit_logs from anon, authenticated;
grant select on public.mdfl_evidence to authenticated;
grant select on public.mdfl_metadata to authenticated;
grant select on public.mdfl_audit_logs to authenticated;
