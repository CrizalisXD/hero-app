-- ════════════════════════════════════════════════════════════════════
-- Hero — challenge leaderboard
--
-- Sprint 3 (challenge detail redesign): show a ranked leaderboard on the
-- challenge detail screen — top participants by progress, the caller's own
-- rank, and the total participant count.
--
-- RLS on challenge_participants (p_cp_own) only exposes the caller's own
-- row, so ranking across all participants must go through this
-- SECURITY DEFINER function. It returns only public-ish fields
-- (display_name + progress) — the same data already surfaced by the app's
-- public profiles / friends feed — never email or auth identifiers beyond
-- the user_id needed to deep-link a profile.
-- ════════════════════════════════════════════════════════════════════

CREATE OR REPLACE FUNCTION public.get_challenge_leaderboard(
  p_challenge_id UUID,
  p_limit        INT DEFAULT 20
)
RETURNS JSONB
LANGUAGE plpgsql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user     UUID := auth.uid();
  v_entries  JSONB;
  v_my_rank  INT;
  v_total    INT;
BEGIN
  IF v_user IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  WITH ranked AS (
    SELECT
      cp.user_id,
      cp.progress_value,
      RANK() OVER (
        ORDER BY cp.progress_value DESC,
                 cp.completed_at ASC NULLS LAST,
                 cp.joined_at ASC
      ) AS rnk
    FROM public.challenge_participants cp
    WHERE cp.challenge_id = p_challenge_id
      AND cp.status IN ('joined', 'completed')
  ),
  agg AS (
    SELECT
      COALESCE(
        jsonb_agg(
          jsonb_build_object(
            'rank',         r.rnk,
            'user_id',      r.user_id,
            'display_name', COALESCE(u.display_name, 'Hero'),
            'progress',     r.progress_value,
            'is_me',        (r.user_id = v_user)
          )
          ORDER BY r.rnk
        ) FILTER (WHERE r.rnk <= p_limit),
        '[]'::jsonb
      ) AS entries
    FROM ranked r
    LEFT JOIN public.users u ON u.id = r.user_id
  )
  SELECT
    (SELECT entries FROM agg),
    (SELECT rnk FROM ranked WHERE user_id = v_user),
    (SELECT COUNT(*)::int FROM ranked)
  INTO v_entries, v_my_rank, v_total;

  RETURN jsonb_build_object(
    'total',   COALESCE(v_total, 0),
    'my_rank', v_my_rank,
    'entries', COALESCE(v_entries, '[]'::jsonb)
  );
END $$;

REVOKE ALL    ON FUNCTION public.get_challenge_leaderboard(UUID, INT) FROM public;
GRANT EXECUTE ON FUNCTION public.get_challenge_leaderboard(UUID, INT) TO authenticated;
