import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";
import { dispatchNotificationPush } from "../_shared/push_dispatch.ts";

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured`);
  return value;
}

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  const cronSecret = Deno.env.get("PUSH_CRON_SECRET");
  if (cronSecret) {
    const provided = req.headers.get("X-Cron-Secret");
    if (provided !== cronSecret) {
      return errorResponse("Unauthorized", 401);
    }
  }

  try {
    const admin = createClient(
      requireEnv("SUPABASE_URL"),
      requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    );

    const { data: pending, error } = await admin
      .from("notifications")
      .select("id, user_id, type, title, body, metadata, is_read, created_at, push_dispatched_at")
      .is("push_dispatched_at", null)
      .gte("created_at", new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString())
      .order("created_at", { ascending: true })
      .limit(100);

    if (error) throw error;

    let sentTotal = 0;
    for (const row of pending ?? []) {
      const result = await dispatchNotificationPush(admin, row);
      sentTotal += result.sent;
    }

    return jsonResponse({
      ok: true,
      processed: pending?.length ?? 0,
      sent: sentTotal,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return errorResponse(message, 500);
  }
});
