import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import {
  getGoogleAccessToken,
  loadServiceAccount,
  preferenceColumnForType,
  sendFcmToToken,
} from "./fcm.ts";

export type NotificationRow = {
  id: string;
  user_id: string;
  type: string;
  title: string;
  body?: string | null;
  metadata?: Record<string, unknown> | null;
  is_read?: boolean;
  created_at?: string;
  push_dispatched_at?: string | null;
};

function stringifyData(row: NotificationRow): Record<string, string> {
  const data: Record<string, string> = {
    notification_id: row.id,
    type: row.type,
    title: row.title,
  };
  if (row.body) data.body = row.body;
  if (row.metadata) {
    for (const [key, value] of Object.entries(row.metadata)) {
      if (value == null) continue;
      data[key] = typeof value === "string" ? value : JSON.stringify(value);
    }
  }
  return data;
}

export async function dispatchNotificationPush(
  admin: ReturnType<typeof createClient>,
  row: NotificationRow,
): Promise<{ sent: number; skipped: string | null }> {
  if (row.push_dispatched_at) {
    return { sent: 0, skipped: "already_dispatched" };
  }

  const { data: prefs, error: prefsError } = await admin
    .from("push_preferences")
    .select("*")
    .eq("user_id", row.user_id)
    .maybeSingle();

  if (prefsError) throw prefsError;

  const prefColumn = preferenceColumnForType(row.type);
  if (prefs && prefs[prefColumn] === false) {
    await admin
      .from("notifications")
      .update({ push_dispatched_at: new Date().toISOString() })
      .eq("id", row.id);
    return { sent: 0, skipped: "preference_disabled" };
  }

  const { data: tokens, error: tokenError } = await admin
    .from("device_tokens")
    .select("id, token")
    .eq("user_id", row.user_id);

  if (tokenError) throw tokenError;
  if (!tokens || tokens.length === 0) {
    return { sent: 0, skipped: "no_tokens" };
  }

  const serviceAccount = loadServiceAccount();
  const accessToken = await getGoogleAccessToken(serviceAccount);
  const data = stringifyData(row);
  let sent = 0;

  for (const entry of tokens) {
    const result = await sendFcmToToken(
      serviceAccount,
      accessToken,
      entry.token,
      { title: row.title, body: row.body ?? undefined },
      data,
    );

    if (result.ok) {
      sent += 1;
    } else if (result.invalidToken) {
      await admin.from("device_tokens").delete().eq("id", entry.id);
    }
  }

  if (sent > 0) {
    await admin
      .from("notifications")
      .update({ push_dispatched_at: new Date().toISOString() })
      .eq("id", row.id);
  }

  return { sent, skipped: sent > 0 ? null : "send_failed" };
}
