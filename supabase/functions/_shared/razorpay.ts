const RAZORPAY_API = "https://api.razorpay.com/v1";

export type PlanInterval = "monthly" | "yearly";

export function requireEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) throw new Error(`Missing env: ${name}`);
  return value;
}

export function planIdFor(interval: PlanInterval): string {
  if (interval === "monthly") {
    return requireEnv("RAZORPAY_PLAN_MONTHLY_ID");
  }
  return requireEnv("RAZORPAY_PLAN_YEARLY_ID");
}

export function totalCountFor(interval: PlanInterval): number {
  return interval === "monthly" ? 120 : 10;
}

function basicAuthHeader(): string {
  const keyId = requireEnv("RAZORPAY_KEY_ID");
  const keySecret = requireEnv("RAZORPAY_KEY_SECRET");
  return `Basic ${btoa(`${keyId}:${keySecret}`)}`;
}

export async function razorpayRequest<T>(
  path: string,
  init: RequestInit = {},
): Promise<T> {
  const response = await fetch(`${RAZORPAY_API}${path}`, {
    ...init,
    headers: {
      Authorization: basicAuthHeader(),
      "Content-Type": "application/json",
      ...(init.headers ?? {}),
    },
  });

  const text = await response.text();
  const data = text ? JSON.parse(text) : {};

  if (!response.ok) {
    const message = data?.error?.description ?? data?.error ?? response.statusText;
    throw new Error(`Razorpay ${path}: ${message}`);
  }

  return data as T;
}

export async function createRazorpayCustomer(input: {
  email?: string;
  contact?: string;
  name?: string;
  userId: string;
}) {
  return razorpayRequest<{ id: string }>("/customers", {
    method: "POST",
    body: JSON.stringify({
      email: input.email,
      contact: input.contact,
      name: input.name,
      notes: { user_id: input.userId },
    }),
  });
}

export async function createRazorpaySubscription(input: {
  planId: string;
  customerId: string;
  interval: PlanInterval;
  userId: string;
}) {
  return razorpayRequest<{
    id: string;
    status: string;
    current_end?: number;
    plan_id: string;
  }>("/subscriptions", {
    method: "POST",
    body: JSON.stringify({
      plan_id: input.planId,
      customer_id: input.customerId,
      customer_notify: 1,
      total_count: totalCountFor(input.interval),
      notes: { user_id: input.userId, plan_interval: input.interval },
    }),
  });
}

export async function cancelRazorpaySubscription(
  subscriptionId: string,
  cancelAtCycleEnd = true,
) {
  return razorpayRequest(`/subscriptions/${subscriptionId}/cancel`, {
    method: "POST",
    body: JSON.stringify({ cancel_at_cycle_end: cancelAtCycleEnd ? 1 : 0 }),
  });
}

export async function verifySubscriptionPaymentSignature(input: {
  paymentId: string;
  subscriptionId: string;
  signature: string;
}): Promise<boolean> {
  const secret = requireEnv("RAZORPAY_KEY_SECRET");
  const body = `${input.paymentId}|${input.subscriptionId}`;
  const expected = await hmacSha256Hex(secret, body);
  return timingSafeEqual(expected, input.signature);
}

export async function verifyWebhookSignature(
  body: string,
  signature: string | null,
): Promise<boolean> {
  if (!signature) return false;
  const secret = requireEnv("RAZORPAY_WEBHOOK_SECRET");
  const expected = await hmacSha256Hex(secret, body);
  return timingSafeEqual(expected, signature);
}

async function hmacSha256Hex(secret: string, message: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    "raw",
    new TextEncoder().encode(secret),
    { name: "HMAC", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "HMAC",
    key,
    new TextEncoder().encode(message),
  );
  return Array.from(new Uint8Array(signature))
    .map((b) => b.toString(16).padStart(2, "0"))
    .join("");
}

function timingSafeEqual(a: string, b: string): boolean {
  if (a.length !== b.length) return false;
  let result = 0;
  for (let i = 0; i < a.length; i++) {
    result |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return result === 0;
}

export function mapRazorpaySubscriptionStatus(status: string): string {
  switch (status) {
    case "created":
    case "authenticated":
    case "active":
    case "pending":
    case "halted":
    case "cancelled":
    case "completed":
      return status;
    default:
      return "pending";
  }
}

export function periodEndFromUnix(seconds?: number | null): string | null {
  if (!seconds) return null;
  return new Date(seconds * 1000).toISOString();
}
