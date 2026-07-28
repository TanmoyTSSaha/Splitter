import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";
import {
  dispatchNotificationPush,
  type NotificationRow,
} from "../_shared/push_dispatch.ts";

type WebhookPayload = {
  type?: string;
  table?: string;
  record?: NotificationRow;
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

  const secret = Deno.env.get("PUSH_WEBHOOK_SECRET");
  if (secret) {
    const provided = req.headers.get("X-Push-Secret");
    if (provided !== secret) {
      return errorResponse("Unauthorized", 401);
    }
  }

  try {
    const payload = await req.json() as WebhookPayload;
    const row = payload.record;
    if (!row?.id) {
      return errorResponse("Missing notification record", 400);
    }

    const admin = createClient(
      requireEnv("SUPABASE_URL"),
      requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    );

    const result = await dispatchNotificationPush(admin, row);
    return jsonResponse({ ok: true, ...result });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return errorResponse(message, 500);
  }
});
