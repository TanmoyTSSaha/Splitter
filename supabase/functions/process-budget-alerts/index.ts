import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured`);
  return value;
}

function periodBounds(period: string, now: Date): { start: string; key: string } {
  const year = now.getUTCFullYear();
  const month = now.getUTCMonth();
  if (period === "weekly") {
    const day = now.getUTCDay();
    const start = new Date(Date.UTC(year, month, now.getUTCDate() - day));
    return { start: start.toISOString(), key: `${year}-W${Math.ceil((now.getUTCDate()) / 7)}` };
  }
  if (period === "daily") {
    const start = new Date(Date.UTC(year, month, now.getUTCDate()));
    return { start: start.toISOString(), key: `${year}-${month + 1}-${now.getUTCDate()}` };
  }
  const start = new Date(Date.UTC(year, month, 1));
  return { start: start.toISOString(), key: `${year}-${month + 1}` };
}

function alertType(spent: number, limit: number, threshold: number): string | null {
  if (limit <= 0) return null;
  if (spent > limit) return "over";
  if (spent >= limit * threshold) return "near";
  return null;
}

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
    const now = new Date();

    const { data: budgets, error } = await admin
      .from("personal_budgets")
      .select("id, user_id, category, limit_amount, alert_threshold, period");

    if (error) throw error;

    let created = 0;
    for (const budget of budgets ?? []) {
      const limit = Number(budget.limit_amount ?? 0);
      const threshold = Number(budget.alert_threshold ?? 0.9);
      const { start, key } = periodBounds(budget.period ?? "monthly", now);

      let query = admin
        .from("personal_transaction")
        .select("amount")
        .eq("user_id", budget.user_id)
        .gte("transaction_date", start)
        .eq("is_credit", false);

      if (budget.category) {
        query = query.eq("category", budget.category);
      }

      const { data: txns, error: txnError } = await query;
      if (txnError) throw txnError;

      const spent = (txns ?? []).reduce(
        (sum, row) => sum + Number(row.amount ?? 0),
        0,
      );
      const type = alertType(spent, limit, threshold);
      if (!type) continue;

      const { error: logError } = await admin.from("budget_alert_log").insert({
        user_id: budget.user_id,
        budget_id: budget.id,
        period_key: key,
        alert_type: type,
      });
      if (logError) {
        if (logError.code === "23505") continue;
        throw logError;
      }

      const label = budget.category ?? "Overall budget";
      const title = type === "over" ? `Over budget: ${label}` : `Near budget: ${label}`;
      const body = `Spent ${spent.toFixed(0)} of ${limit.toFixed(0)} this period.`;

      const { error: insertError } = await admin.from("notifications").insert({
        user_id: budget.user_id,
        type: "budget_alert",
        title,
        body,
        metadata: {
          budget_id: budget.id,
          alert_type: type,
          period_key: key,
        },
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
