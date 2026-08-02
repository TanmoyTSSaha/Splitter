import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";

type MarketingPayload = {
  title: string;
  body: string;
  user_ids?: string[];
};

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured`);
  return value;
}

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") {
    return errorResponse("Method not allowed", 405);
  }

  const adminSecret = Deno.env.get("ADMIN_PUSH_SECRET");
  if (!adminSecret || req.headers.get("X-Admin-Push-Secret") !== adminSecret) {
    return errorResponse("Unauthorized", 401);
  }

  try {
    const payload = await req.json() as MarketingPayload;
    if (!payload.title?.trim()) {
      return errorResponse("title is required", 400);
    }

    const admin = createClient(
      requireEnv("SUPABASE_URL"),
      requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    );

    let targetUserIds = payload.user_ids ?? [];
    if (targetUserIds.length === 0) {
      const { data: prefs, error } = await admin
        .from("push_preferences")
        .select("user_id")
        .eq("marketing", true);
      if (error) throw error;
      targetUserIds = (prefs ?? []).map((row) => row.user_id as string);
    }

    let created = 0;
    for (const userId of targetUserIds) {
      const { data: pref } = await admin
        .from("push_preferences")
        .select("marketing")
        .eq("user_id", userId)
        .maybeSingle();
      if (pref && pref.marketing === false) continue;

      const { error: insertError } = await admin.from("notifications").insert({
        user_id: userId,
        type: "marketing",
        title: payload.title,
        body: payload.body ?? null,
        metadata: { channel: "marketing_broadcast" },
        is_read: false,
      });
      if (insertError) throw insertError;
      created += 1;
    }

    return jsonResponse({ ok: true, created });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return errorResponse(message, 500);
  }
});
