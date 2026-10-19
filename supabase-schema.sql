-- 문장: 작품, 회차, 표지 저장을 위한 Supabase 초기 스키마
-- Supabase Dashboard > SQL Editor에서 이 파일 전체를 실행하세요.

create table if not exists public.stories (
  id text primary key,
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null default '',
  genre text not null default '단편',
  author text not null,
  cover text not null default 'c1',
  cover_path text,
  cover_url text,
  updated text not null default '오늘',
  views bigint not null default 0,
  likes bigint not null default 0,
  hidden boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.episodes (
  id text primary key,
  story_id text not null references public.stories(id) on delete cascade,
  title text not null,
  body text not null default '',
  date text not null default '오늘',
  published boolean not null default false,
  hidden boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists stories_owner_id_idx on public.stories(owner_id);
create index if not exists stories_updated_at_idx on public.stories(updated_at desc);
create index if not exists episodes_story_id_idx on public.episodes(story_id);
create index if not exists episodes_public_idx on public.episodes(story_id, published) where hidden = false;

create or replace function public.munjang_set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists munjang_stories_updated_at on public.stories;
create trigger munjang_stories_updated_at
before update on public.stories
for each row execute function public.munjang_set_updated_at();

drop trigger if exists munjang_episodes_updated_at on public.episodes;
create trigger munjang_episodes_updated_at
before update on public.episodes
for each row execute function public.munjang_set_updated_at();

-- SECURITY DEFINER avoids recursive RLS checks between stories and episodes.
create or replace function public.munjang_story_is_public(target_story_id text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.stories s
    where s.id = target_story_id
      and s.hidden = false
      and exists (
        select 1 from public.episodes e
        where e.story_id = s.id and e.published = true and e.hidden = false
      )
  );
$$;

revoke all on function public.munjang_story_is_public(text) from public;
grant execute on function public.munjang_story_is_public(text) to anon, authenticated;

alter table public.stories enable row level security;
alter table public.episodes enable row level security;

grant select on public.stories, public.episodes to anon, authenticated;
grant insert, update, delete on public.stories, public.episodes to authenticated;

drop policy if exists "read published stories or own stories" on public.stories;
create policy "read published stories or own stories"
on public.stories for select to anon, authenticated
using (owner_id = (select auth.uid()) or public.munjang_story_is_public(id));

drop policy if exists "authors insert own stories" on public.stories;
create policy "authors insert own stories"
on public.stories for insert to authenticated
with check (owner_id = (select auth.uid()));

drop policy if exists "authors update own stories" on public.stories;
create policy "authors update own stories"
on public.stories for update to authenticated
using (owner_id = (select auth.uid()))
with check (owner_id = (select auth.uid()));

drop policy if exists "authors delete own stories" on public.stories;
create policy "authors delete own stories"
on public.stories for delete to authenticated
using (owner_id = (select auth.uid()));

drop policy if exists "read published episodes or own episodes" on public.episodes;
create policy "read published episodes or own episodes"
on public.episodes for select to anon, authenticated
using (
  exists (
    select 1 from public.stories s
    where s.id = episodes.story_id and s.owner_id = (select auth.uid())
  )
  or (episodes.published = true and episodes.hidden = false and public.munjang_story_is_public(story_id))
);

drop policy if exists "authors insert episodes in own stories" on public.episodes;
create policy "authors insert episodes in own stories"
on public.episodes for insert to authenticated
with check (exists (
  select 1 from public.stories s
  where s.id = episodes.story_id and s.owner_id = (select auth.uid())
));

drop policy if exists "authors update episodes in own stories" on public.episodes;
create policy "authors update episodes in own stories"
on public.episodes for update to authenticated
using (exists (
  select 1 from public.stories s
  where s.id = episodes.story_id and s.owner_id = (select auth.uid())
))
with check (exists (
  select 1 from public.stories s
  where s.id = episodes.story_id and s.owner_id = (select auth.uid())
));

drop policy if exists "authors delete episodes in own stories" on public.episodes;
create policy "authors delete episodes in own stories"
on public.episodes for delete to authenticated
using (exists (
  select 1 from public.stories s
  where s.id = episodes.story_id and s.owner_id = (select auth.uid())
));

-- Private bucket: only the owner may read drafts; published covers can be signed for readers.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('covers', 'covers', false, 5242880, array['image/jpeg', 'image/png', 'image/webp', 'image/gif'])
on conflict (id) do update set
  public = false,
  file_size_limit = 5242880,
  allowed_mime_types = array['image/jpeg', 'image/png', 'image/webp', 'image/gif'];

drop policy if exists "read own or published story covers" on storage.objects;
create policy "read own or published story covers"
on storage.objects for select to anon, authenticated
using (
  bucket_id = 'covers'
  and (
    (select auth.uid())::text = (storage.foldername(name))[1]
    or public.munjang_story_is_public((storage.foldername(name))[2])
  )
);

drop policy if exists "authors upload covers to own folder" on storage.objects;
create policy "authors upload covers to own folder"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'covers'
  and (select auth.uid())::text = (storage.foldername(name))[1]
);

drop policy if exists "authors update covers in own folder" on storage.objects;
create policy "authors update covers in own folder"
on storage.objects for update to authenticated
using (
  bucket_id = 'covers'
  and (select auth.uid())::text = (storage.foldername(name))[1]
)
with check (
  bucket_id = 'covers'
  and (select auth.uid())::text = (storage.foldername(name))[1]
);

drop policy if exists "authors delete covers in own folder" on storage.objects;
create policy "authors delete covers in own folder"
on storage.objects for delete to authenticated
using (
  bucket_id = 'covers'
  and (select auth.uid())::text = (storage.foldername(name))[1]
);

