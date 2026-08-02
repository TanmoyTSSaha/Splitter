import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";

type PreviewBody = {
  token?: string;
  friendUserId?: string;
};

type UserNameRow = {
  user_name?: string | null;
  firstname?: string | null;
  lastname?: string | null;
};

const RATE_LIMIT = 60;
const WINDOW_MS = 60_000;
const UUID_RE =
  /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

const hits = new Map<string, number[]>();

function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`${name} is not configured`);
  return value;
}

function rateLimitKey(req: Request): string {
  return (
    req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ||
    req.headers.get("cf-connecting-ip") ||
    "unknown"
  );
}

function checkRateLimit(key: string): boolean {
  const now = Date.now();
  const windowStart = now - WINDOW_MS;
  const times = (hits.get(key) ?? []).filter((t) => t > windowStart);
  if (times.length >= RATE_LIMIT) return false;
  times.push(now);
  hits.set(key, times);
  return true;
}

function displayName(row: UserNameRow): string {
  const userName = String(row.user_name ?? "").trim();
  if (userName) return userName;
  const full = `${String(row.firstname ?? "").trim()} ${String(row.lastname ?? "").trim()}`
    .trim();
  return full || "Splitr user";
}

function isExpired(expiresAt: string | null): boolean {
  if (!expiresAt) return false;
  const date = new Date(expiresAt);
  return !Number.isNaN(date.getTime()) && date < new Date();
}

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") {
    return errorResponse("Method not allowed", 405);
  }

  if (!checkRateLimit(rateLimitKey(req))) {
    return errorResponse("Too many requests", 429);
  }

  let body: PreviewBody;
  try {
    body = await req.json() as PreviewBody;
  } catch {
    return errorResponse("Invalid JSON body", 400);
  }

  const token = typeof body.token === "string" ? body.token.trim() : "";
  const friendUserId = typeof body.friendUserId === "string"
    ? body.friendUserId.trim()
    : "";

  if (!token && !friendUserId) {
    return errorResponse("token or friendUserId required", 400);
  }
  if (token && friendUserId) {
    return errorResponse("Provide token or friendUserId, not both", 400);
  }

  const admin = createClient(
    requireEnv("SUPABASE_URL"),
    requireEnv("SUPABASE_SERVICE_ROLE_KEY"),
  );

  try {
    if (token) {
      if (token.length < 8 || token.length > 128) {
        return jsonResponse({ kind: "group", name: "", valid: false });
      }

      const { data, error } = await admin
        .from("shareable_invites")
        .select("status, expires_at, invite_type, groups(group_name)")
        .eq("token", token)
        .eq("status", "active")
        .maybeSingle();

      if (error) {
        console.error("preview-invite group lookup failed", error.message);
        return errorResponse("Lookup failed", 500);
      }

      if (!data || data.invite_type !== "group" || isExpired(data.expires_at as string | null)) {
        return jsonResponse({ kind: "group", name: "", valid: false });
      }

      const groups = data.groups as { group_name?: string } | { group_name?: string }[] | null;
      const groupName = Array.isArray(groups)
        ? String(groups[0]?.group_name ?? "").trim()
        : String(groups?.group_name ?? "").trim();

      if (!groupName) {
        return jsonResponse({ kind: "group", name: "", valid: false });
      }

      return jsonResponse({ kind: "group", name: groupName, valid: true });
    }

    if (!UUID_RE.test(friendUserId)) {
      return jsonResponse({ kind: "friend", name: "", valid: false });
    }

    const { data: user, error: userError } = await admin
      .from("users")
      .select("user_name, firstname, lastname")
      .eq("user_id", friendUserId)
      .maybeSingle();

    if (userError) {
      console.error("preview-invite friend lookup failed", userError.message);
      return errorResponse("Lookup failed", 500);
    }

    if (!user) {
      return jsonResponse({ kind: "friend", name: "", valid: false });
    }

    return jsonResponse({
      kind: "friend",
      name: displayName(user as UserNameRow),
      valid: true,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return errorResponse(message, 500);
  }
});
