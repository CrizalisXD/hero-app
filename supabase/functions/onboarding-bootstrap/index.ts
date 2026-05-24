// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0'
import { corsHeaders } from '../_shared/cors.ts'

// ── Allowlists (must match TZ spec & server RPC) ─────────────────────
const ALLOWED_LIFE_AREAS = new Set([
  'health', 'mind', 'strength', 'endurance', 'finance', 'social', 'creativity', 'discipline',
])
const ALLOWED_FAILURE_REASONS = new Set([
  'lose_motivation', 'too_hard', 'no_time', 'no_structure', 'boredom', 'perfectionism',
])
const ALLOWED_SUPPORT_STYLES = new Set(['direct', 'gentle', 'strict', 'analytical'])
const ALLOWED_HABITS = new Set(['drink_water', 'read_10_pages', 'walk_10_min'])

interface OnboardingPayload {
  life_change_areas: string[]
  main_obstacle: string
  energy_level: number
  time_commitment_minutes: number
  failure_reasons: string[]
  support_style: string
  starter_habits: string[]
}

// ── Helpers ──────────────────────────────────────────────────────────
function bad(message: string, status = 400): Response {
  return new Response(
    JSON.stringify({ ok: false, error: message }),
    { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
  )
}

function ok(body: any): Response {
  return new Response(
    JSON.stringify(body),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
  )
}

// ── Entry point ───────────────────────────────────────────────────────
serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers: corsHeaders })
  }

  if (req.method !== 'POST') {
    return bad('Method not allowed', 405)
  }

  // ── Auth ────────────────────────────────────────────────────────────
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return bad('Missing authorization header', 401)
  }

  // User-scoped client — auth.uid() will work correctly in the RPC.
  const userClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_ANON_KEY')!,
    {
      global: { headers: { Authorization: authHeader } },
      auth: { persistSession: false },
    },
  )

  // Verify JWT is valid before doing any work.
  const { data: { user }, error: authError } = await userClient.auth.getUser()
  if (authError || !user) {
    return bad('Unauthorized', 401)
  }

  // ── Parse payload ───────────────────────────────────────────────────
  let payload: OnboardingPayload
  try {
    payload = await req.json()
  } catch {
    return bad('Invalid JSON')
  }

  // ── Validate required fields ────────────────────────────────────────
  if (!Array.isArray(payload.life_change_areas) || payload.life_change_areas.length === 0) {
    return bad('life_change_areas must be a non-empty array')
  }
  if (typeof payload.support_style !== 'string' || !payload.support_style) {
    return bad('support_style is required')
  }

  // ── Validate allowlists ─────────────────────────────────────────────
  const invalidAreas = payload.life_change_areas.filter((a) => !ALLOWED_LIFE_AREAS.has(a))
  if (invalidAreas.length > 0) {
    return bad(`Invalid life_change_areas: ${invalidAreas.join(', ')}`)
  }

  if (!ALLOWED_SUPPORT_STYLES.has(payload.support_style)) {
    return bad(`Invalid support_style: ${payload.support_style}`)
  }

  // Strip any unknown failure reasons / habits silently instead of rejecting.
  const failureReasons = (Array.isArray(payload.failure_reasons) ? payload.failure_reasons : [])
    .filter((r) => ALLOWED_FAILURE_REASONS.has(r))

  const starterHabits = (Array.isArray(payload.starter_habits) ? payload.starter_habits : [])
    .filter((h) => ALLOWED_HABITS.has(h))

  // ── Build sanitised payload ─────────────────────────────────────────
  const sanitised = {
    life_change_areas: payload.life_change_areas,
    main_obstacle: String(payload.main_obstacle ?? '').slice(0, 200),
    energy_level: Math.min(5, Math.max(1, Math.round(Number(payload.energy_level) || 3))),
    time_commitment_minutes: Math.min(120, Math.max(5, Math.round(Number(payload.time_commitment_minutes) || 15))),
    failure_reasons: failureReasons,
    support_style: payload.support_style,
    starter_habits: starterHabits,
  }

  // ── Call RPC ────────────────────────────────────────────────────────
  const { data, error } = await userClient.rpc('onboarding_bootstrap', {
    p_payload: sanitised,
  })

  if (error) {
    console.error('[onboarding-bootstrap] RPC error:', error)
    return bad(`Bootstrap failed: ${error.message}`, 500)
  }

  // Guard: RPC must confirm completion — never return ok=true without it.
  if (!data?.ok || !data?.onboarding_done) {
    console.error('[onboarding-bootstrap] RPC did not confirm completion:', data)
    return bad('Bootstrap did not complete successfully', 500)
  }

  return ok(data)
})
