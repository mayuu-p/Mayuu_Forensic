-- MDFL browser-client integration. Run after 0001_mdfl_core.sql.
-- This enables owner-scoped client uploads; service-role keys are never used in browsers.
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types)
values ('mdfl-evidence','mdfl-evidence',false,26214400,array['image/jpeg','image/png','image/heic','image/heif'])
on conflict (id) do update set public=false,file_size_limit=26214400,allowed_mime_types=excluded.allowed_mime_types;

drop policy if exists "mdfl owner uploads own originals" on storage.objects;
create policy "mdfl owner uploads own originals" on storage.objects
for insert to authenticated with check (bucket_id='mdfl-evidence' and (storage.foldername(name))[1]=(select auth.uid())::text);

drop policy if exists "mdfl owner reads own originals" on storage.objects;
create policy "mdfl owner reads own originals" on storage.objects
for select to authenticated using (bucket_id='mdfl-evidence' and (storage.foldername(name))[1]=(select auth.uid())::text);

drop policy if exists "mdfl owner deletes own originals" on storage.objects;
create policy "mdfl owner deletes own originals" on storage.objects
for delete to authenticated using (bucket_id='mdfl-evidence' and (storage.foldername(name))[1]=(select auth.uid())::text);

drop policy if exists "mdfl owner inserts evidence" on public.mdfl_evidence;
create policy "mdfl owner inserts evidence" on public.mdfl_evidence
for insert to authenticated with check ((select auth.uid())=owner_id);
drop policy if exists "mdfl owner deletes evidence" on public.mdfl_evidence;
create policy "mdfl owner deletes evidence" on public.mdfl_evidence
for delete to authenticated using ((select auth.uid())=owner_id);

drop policy if exists "mdfl owner inserts metadata" on public.mdfl_metadata;
create policy "mdfl owner inserts metadata" on public.mdfl_metadata
for insert to authenticated with check (exists (
  select 1 from public.mdfl_evidence e where e.id=evidence_id and e.owner_id=(select auth.uid())
));

grant insert, delete on public.mdfl_evidence to authenticated;
grant insert on public.mdfl_metadata to authenticated;
