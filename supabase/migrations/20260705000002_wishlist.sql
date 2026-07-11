-- ════════════════════════════════════════════════════════════════════
-- Hero — «Хочу попробовать» (wishlist): бэклог идей без лимита.
-- Захват мгновенный (критично для СДВГ-аудитории), идея позже либо
-- превращается в задачу (converted_task_id), либо помечается
-- «попробовано» (tried_at), либо тихо живёт в списке.
-- ════════════════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS public.wishlist_items (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id           UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title             TEXT NOT NULL,
  tried_at          TIMESTAMPTZ,
  converted_task_id UUID REFERENCES public.tasks(id) ON DELETE SET NULL,
  is_deleted        BOOLEAN NOT NULL DEFAULT false,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at        TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_wishlist_user_created
  ON public.wishlist_items (user_id, created_at DESC) WHERE is_deleted = false;

DROP TRIGGER IF EXISTS tg_wishlist_updated_at ON public.wishlist_items;
CREATE TRIGGER tg_wishlist_updated_at
  BEFORE UPDATE ON public.wishlist_items
  FOR EACH ROW EXECUTE FUNCTION public.tg_set_updated_at();

ALTER TABLE public.wishlist_items ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS p_wishlist_own ON public.wishlist_items;
CREATE POLICY p_wishlist_own ON public.wishlist_items
  FOR ALL USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
