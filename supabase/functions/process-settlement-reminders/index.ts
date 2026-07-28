import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured`);
  return value;
}

function cadenceDue(cadence: string, updatedAt: string): boolean {
  const updated = new Date(updatedAt).getTime();
  const now = Date.now();
  const dayMs = 24 * 60 * 60 * 1000;
  switch (cadence) {
    case "daily":
      return now - updated >= dayMs;
    case "weekly":
      return now - updated >= 7 * dayMs;
    case "biweekly":
      return now - updated >= 14 * dayMs;
    case "monthly":
      return now - updated >= 30 * dayMs;
    default:
      return false;
  }
}

type BalanceEntry = {
  donor_id?: string;
  receiver_id?: string;
  amount?: number | string;
};

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  const cronSecret = Deno.env.get("PUSH_CRON_SECRET");
  if (cronSecret && req.headers.get("X-Cron-Secret") !== cronSecret) {
    return errorResponse("Unauthorized", 401);
  }

  try {
    const admin = createClient(
      requireEnv("SUPABASE_URL"),
      requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
    );

    const { data: settings, error } = await admin
      .from("reminder_settings")
      .select("user_id, group_id, cadence, updated_at, muted_member_ids")
      .neq("cadence", "off");

    if (error) throw error;

    let created = 0;
    for (const setting of settings ?? []) {
      if (!cadenceDue(setting.cadence, setting.updated_at)) continue;

      const { data: group, error: groupError } = await admin
        .from("groups")
        .select("group_name, group_balance")
        .eq("group_id", setting.group_id)
        .maybeSingle();
      if (groupError || !group) continue;

      const balances = (group.group_balance ?? []) as BalanceEntry[];
      const muted = new Set<string>(
        Array.isArray(setting.muted_member_ids) ? setting.muted_member_ids : [],
      );

      for (const entry of balances) {
        const debtorId = entry.receiver_id;
        const creditorId = entry.donor_id;
        const amount = Number(entry.amount ?? 0);
        if (!debtorId || !creditorId || amount <= 0) continue;
        if (debtorId !== setting.user_id) continue;
        if (muted.has(creditorId)) continue;

        const { error: logError } = await admin.from("settlement_reminder_log")
          .insert({
            user_id: debtorId,
            group_id: setting.group_id,
            counterparty_id: creditorId,
          });
        if (logError) {
          if (logError.code === "23505") continue;
          throw logError;
        }

        const title = "Settlement reminder";
        const body =
          `You still owe in ${group.group_name ?? "a group"}. Tap to review balances.`;

        const { error: insertError } = await admin.from("notifications").insert({
          user_id: debtorId,
          type: "settlement_reminder",
          title,
          body,
          metadata: {
            group_id: setting.group_id,
            counterparty_id: creditorId,
            amount,
          },
          is_read: false,
        });
        if (insertError) throw insertError;
        created += 1;
      }

      await admin
        .from("reminder_settings")
        .update({ updated_at: new Date().toISOString() })
        .eq("user_id", setting.user_id)
        .eq("group_id", setting.group_id);
    }

    return jsonResponse({ ok: true, created });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return errorResponse(message, 500);
  }
});
