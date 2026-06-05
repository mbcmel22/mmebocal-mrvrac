-- =====================================================================
--  Mme Bocal & Mr Vrac — Schéma base de données (Supabase / PostgreSQL)
--  À exécuter UNE SEULE FOIS dans : Supabase > SQL Editor > New query > Run
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) Table des produits
-- ---------------------------------------------------------------------
create table if not exists public.products (
  id          uuid primary key default gen_random_uuid(),
  name        text    not null,
  category    text    not null default 'Épicerie',
  price       numeric(10,2),                 -- prix indicatif
  unit        text    default '/kg',         -- /kg, /pièce, 75cl, etc.
  qty         integer not null default 0,    -- stock (sert aux badges de dispo)
  image_url   text,                          -- URL de la photo (Supabase Storage)
  local       boolean not null default false,-- badge "Local / circuit-court"
  description text,
  visible     boolean not null default true, -- masquer sans supprimer
  created_at  timestamptz default now()
);

-- ---------------------------------------------------------------------
-- 2) Table des réglages éditables (horaires, tél, adresse...)
--    Permet au gérant de modifier les infos du site SANS toucher au code
-- ---------------------------------------------------------------------
create table if not exists public.settings (
  key   text primary key,
  value text
);

-- ---------------------------------------------------------------------
-- 3) Sécurité (Row Level Security)
--    Lecture publique = OK (site vitrine)
--    Écriture = uniquement utilisateurs connectés (le gérant via le back-office)
-- ---------------------------------------------------------------------
alter table public.products enable row level security;
alter table public.settings enable row level security;

-- PRODUCTS
drop policy if exists "lecture publique produits"   on public.products;
drop policy if exists "ecriture connectee produits" on public.products;
create policy "lecture publique produits"
  on public.products for select to anon, authenticated using (true);
create policy "ecriture connectee produits"
  on public.products for all to authenticated using (true) with check (true);

-- SETTINGS
drop policy if exists "lecture publique settings"   on public.settings;
drop policy if exists "ecriture connectee settings" on public.settings;
create policy "lecture publique settings"
  on public.settings for select to anon, authenticated using (true);
create policy "ecriture connectee settings"
  on public.settings for all to authenticated using (true) with check (true);

-- ---------------------------------------------------------------------
-- 4) Réglages par défaut (modifiables ensuite depuis le back-office)
-- ---------------------------------------------------------------------
insert into public.settings (key, value) values
  ('adresse',   '90 rue Nationale, 49300 Cholet'),
  ('telephone', '09 81 34 40 50'),
  ('email',     'mmebocaletmrvrac@hotmail.com'),
  ('horaires',  'Mardi au Samedi : 10h00–13h30 / 15h00–19h00 — Fermé dimanche et lundi'),
  ('instagram', 'https://www.instagram.com/mmebocaletmrvrac/'),
  ('facebook',  'https://www.facebook.com/mmebocaletmrvrac')
on conflict (key) do nothing;

-- ---------------------------------------------------------------------
-- 5) Produits de démonstration (vrais produits + prix indicatifs du site)
--    Le gérant ajustera/complétera depuis le back-office.
-- ---------------------------------------------------------------------
insert into public.products (name, category, price, unit, qty, local, description) values
  -- Riz, pâtes & céréales
  ('Fusilli',                 'Riz, pâtes & céréales', 3.90, '/kg', 12, true,  'Pâtes bio en vrac.'),
  ('Coquillettes',            'Riz, pâtes & céréales', 3.90, '/kg', 8,  true,  'Pâtes bio en vrac.'),
  ('Conchiglie',              'Riz, pâtes & céréales', 3.90, '/kg', 3,  true,  'Pâtes bio en vrac.'),
  ('Millet décortiqué',       'Riz, pâtes & céréales', 5.90, '/kg', 6,  true,  'Céréale bio en vrac.'),
  -- Légumineuses
  ('Lentilles vertes',        'Légumineuses',          5.90, '/kg', 15, true,  'Lentilles bio en vrac.'),
  ('Pois cassés',             'Légumineuses',          5.90, '/kg', 9,  true,  'Pois cassés bio en vrac.'),
  ('Haricots rouges',         'Légumineuses',          3.90, '/kg', 0,  true,  'Haricots rouges bio en vrac.'),
  ('Haricots blancs lingot',  'Légumineuses',          6.90, '/kg', 4,  true,  'Haricots lingot bio en vrac.'),
  -- Fruits secs & oléagineux
  ('Graines de courge',       'Fruits secs & oléagineux', 20.90, '/kg', 5, true, 'Graines bio en vrac.'),
  -- Épices & condiments
  ('Poivre noir',             'Épices & condiments',   52.90, '/kg', 2,  false, 'Poivre noir bio en vrac.'),
  ('Poivre blanc de Madagascar','Épices & condiments', 69.50, '/kg', 1,  false, 'Poivre blanc bio en vrac.'),
  ('Mélange 5 baies',         'Épices & condiments',   77.50, '/kg', 2,  false, 'Mélange de baies bio.'),
  ('Curry indien',            'Épices & condiments',   43.90, '/kg', 3,  false, 'Curry bio en vrac.'),
  ('Curry rouge Spicy Bombay','Épices & condiments',   43.90, '/kg', 0,  false, 'Curry rouge bio en vrac.'),
  ('Gomasio aux épices',      'Épices & condiments',   21.90, '/kg', 4,  false, 'Condiment sésame & épices bio.'),
  ('Sel 3 poivres',           'Épices & condiments',   14.90, '/kg', 6,  false, 'Sel aromatisé en vrac.'),
  -- Cafés, thés & infusions
  ('Rooïbos nature',          'Cafés, thés & infusions', 42.50, '/kg', 5, false, 'Rooïbos bio en vrac.'),
  ('Rooïbos fruits rouges',   'Cafés, thés & infusions', 45.90, '/kg', 3, false, 'Rooïbos parfumé bio.'),
  ('Rooïbos Soleil du Cap',   'Cafés, thés & infusions', 49.50, '/kg', 2, false, 'Rooïbos bio en vrac.'),
  -- Jus, sirops & boissons (consigne)
  ('Li''Mousse pin 75cl',     'Jus, sirops & boissons', 4.90, '/btl', 10, true, 'Boisson locale — bouteille consignée.'),
  ('Li''Mousse verveine 75cl','Jus, sirops & boissons', 4.90, '/btl', 7,  true, 'Boisson locale — bouteille consignée.'),
  ('Bière Estiv''ale 75cl',   'Jus, sirops & boissons', 7.90, '/btl', 6,  true, 'Bière locale — bouteille consignée.'),
  ('Infusion pétillante Relaxante 75cl','Jus, sirops & boissons', 5.90, '/btl', 4, false, 'Infusion pétillante.'),
  -- Entretien & hygiène
  ('Lessive en vrac',         'Produits d''entretien', 4.50, '/L', 20, false, 'Lessive éco-conçue, au litre.'),
  ('Savon solide',            'Hygiène & cosmétique',  6.50, '/pièce', 14, true, 'Savon naturel local.'),
  ('Shampoing solide',        'Hygiène & cosmétique',  8.90, '/pièce', 9,  false,'Shampoing solide zéro-déchet.'),
  -- Accessoires zéro-déchet
  ('Sac à vrac en coton bio', 'Accessoires zéro-déchet', 5.90, '/pièce', 25, false, 'Sac réutilisable pour le vrac.'),
  ('Gourde inox 500ml',       'Gourdes & thermos',     18.90, '/pièce', 8,  false, 'Gourde inox réutilisable.')
on conflict do nothing;

-- =====================================================================
--  FIN — Vérifie ensuite dans Table Editor que "products" et "settings"
--  sont bien remplies.
-- =====================================================================
