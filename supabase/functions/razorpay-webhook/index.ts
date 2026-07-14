import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";
import {
  mapRazorpaySubscriptionStatus,
  periodEndFromUnix,
  requireEnv,
  verifyWebhookSignature,
} from "../_shared/razorpay.ts";

type RazorpayWebhookPayload = {
  event?: string;
  id?: string;
  payload?: {
    subscription?: {
      entity?: {
        id?: string;
        status?: string;
        current_end?: number;
        plan_id?: string;
        notes?: { user_id?: string; plan_interval?: string };
        customer_id?: string;
      };
    };
    payment?: {
      entity?: {
        id?: string;
        subscription_id?: string;
      };
    };
  };
};

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") {
    return errorResponse("Method not allowed", 405);
  }

  try {
    const rawBody = await req.text();
    const signature = req.headers.get("X-Razorpay-Signature");

    const valid = await verifyWebhookSignature(rawBody, signature);
    if (!valid) {
      return errorResponse("Invalid webhook signature", 403);
    }

    const payload = JSON.parse(rawBody) as RazorpayWebhookPayload;
    const eventId = payload.id;
    const eventType = payload.event ?? "unknown";

    if (!eventId) {
      return errorResponse("Missing event id", 400);
    }

    const supabaseUrl = requireEnv("SUPABASE_URL");
    const serviceKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
    const admin = createClient(supabaseUrl, serviceKey);

    const { error: dedupeError } = await admin.from("webhook_events").insert({
      provider: "razorpay",
      event_id: eventId,
      event_type: eventType,
      payload: JSON.parse(rawBody),
    });

    if (dedupeError?.code === "23505") {
      return jsonResponse({ received: true, duplicate: true });
    }
    if (dedupeError) {
      throw dedupeError;
    }

    const entity = payload.payload?.subscription?.entity;
    const subscriptionId = entity?.id ??
      payload.payload?.payment?.entity?.subscription_id;

    if (!subscriptionId) {
      return jsonResponse({ received: true, skipped: "no subscription" });
    }

    const status = entity?.status
      ? mapRazorpaySubscriptionStatus(entity.status)
      : mapEventToStatus(eventType);

    const periodEnd = periodEndFromUnix(entity?.current_end);
    const userId = entity?.notes?.user_id;
    const planInterval = entity?.notes?.plan_interval;

    const update: Record<string, unknown> = {
      status,
      updated_at: new Date().toISOString(),
    };
    if (periodEnd) update.current_period_end = periodEnd;
    if (entity?.plan_id) update.razorpay_plan_id = entity.plan_id;
    if (entity?.customer_id) update.razorpay_customer_id = entity.customer_id;
    if (planInterval === "monthly" || planInterval === "yearly") {
      update.plan_interval = planInterval;
    }

    const { data: existing } = await admin
      .from("premium_subscriptions")
      .select("user_id")
      .eq("razorpay_subscription_id", subscriptionId)
      .maybeSingle();

    if (existing) {
      await admin
        .from("premium_subscriptions")
        .update(update)
        .eq("razorpay_subscription_id", subscriptionId);
    } else if (userId) {
      await admin.from("premium_subscriptions").upsert(
        {
          user_id: userId,
          razorpay_subscription_id: subscriptionId,
          razorpay_plan_id: entity?.plan_id ?? "unknown",
          plan_interval: planInterval ?? "monthly",
          ...update,
        },
        { onConflict: "user_id" },
      );
    }

    return jsonResponse({ received: true, event: eventType });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return errorResponse(message, 500);
  }
});

function mapEventToStatus(eventType: string): string {
  switch (eventType) {
    case "subscription.authenticated":
      return "authenticated";
    case "subscription.activated":
    case "subscription.charged":
      return "active";
    case "subscription.cancelled":
      return "cancelled";
    case "subscription.halted":
      return "halted";
    case "subscription.completed":
      return "completed";
    case "subscription.pending":
      return "pending";
    default:
      return "pending";
  }
}
