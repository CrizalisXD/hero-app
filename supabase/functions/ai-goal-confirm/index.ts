// deno-lint-ignore-file no-explicit-any
import { serve } from 'https://deno.land/std@0.224.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.45.0'
import { corsHeaders } from '../_shared/cors.ts'

const ALLOWED_CATEGORIES = new Set([
  'strength', 'mind', 'endurance', 'health', 'social', 'finance', 'creativity',
])

function bad(message: string, status = 400) {
  return new Response(
    JSON.stringify({ ok: false, error: message }),
    { status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
  )
}

function ok(body: any) {
  return new Response(
    JSON.stringify(body),
    { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
  )
}

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders })
  if (req.method !== 'POST') return bad('method_not_allowed', 405)

  const auth = req.headers.get('Authorization')
  if (!auth) return bad('missing_auth', 401)

  const supabaseUrl = Deno.env.get('SUPABASE_URL')
  const anonKey    = Deno.env.get('SUPABASE_ANON_KEY')
  if (!supabaseUrl || !anonKey) return bad('server_misconfigured', 500)

  const client = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: auth } },
    auth:   { persistSession: false, autoRefreshToken: false },
  })

  let payload: any
  try { payload = await req.json() } catch { return bad('invalid_json') }

  // ── Validate ──────────────────────────────────────────────────────
  if (!payload?.goal_title || String(payload.goal_title).trim().length < 2) {
    return bad('invalid_title')
  }
  if (!ALLOWED_CATEGORIES.has(payload.main_category)) {
    return bad('invalid_main_category')
  }
  // Phase 19 — 'own'/'mixed' plans may legitimately start with zero steps
  // (user fills them in over time). Only AI plans must carry steps.
  const planMode = (payload.plan_mode ?? 'ai').toString()
  if (!Array.isArray(payload.steps)) {
    payload.steps = []
  }
  if (planMode === 'ai' && payload.steps.length === 0) {
    return bad('no_steps')
  }

  // ── Sanitise secondary_categories: always an array, never null ───
  if (!Array.isArray(payload.secondary_categories)) {
    payload.secondary_categories = []
  }

  // ── Call RPC (runs atomically in one transaction) ─────────────────
  const { data, error } = await client.rpc('create_goal_with_plan', {
    p_payload: payload,
  })

  if (error) {
    console.error('create_goal_with_plan rpc error', error)
    return bad(error.message ?? 'rpc_failed', 500)
  }

  return ok(data)
})
