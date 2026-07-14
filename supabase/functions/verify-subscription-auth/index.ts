import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";
import {
  requireEnv,
  verifySubscriptionPaymentSignature,
} from "../_shared/razorpay.ts";

Deno.serve(async (req) => {
  const cors = handleCors(req);
  if (cors) return cors;

  if (req.method !== "POST") {
    return errorResponse("Method not allowed", 405);
  }

  try {
    const authHeader = req.headers.get("Authorization");
    if (!authHeader) return errorResponse("Unauthorized", 401);

    const supabaseUrl = requireEnv("SUPABASE_URL");
    const serviceKey = requireEnv("SUPABASE_SERVICE_ROLE_KEY");
    const anonKey = requireEnv("SUPABASE_ANON_KEY");

    const userClient = createClient(supabaseUrl, anonKey, {
      global: { headers: { Authorization: authHeader } },
    });
    const admin = createClient(supabaseUrl, serviceKey);

    const { data: authData, error: authError } = await userClient.auth.getUser();
    if (authError || !authData.user) {
      return errorResponse("Unauthorized", 401);
    }

    const body = await req.json();
    const subscriptionId = body?.subscription_id as string | undefined;
    const paymentId = body?.payment_id as string | undefined;
    const signature = body?.signature as string | undefined;

    if (!subscriptionId || !paymentId || !signature) {
      return errorResponse("subscription_id, payment_id, and signature are required");
    }

    const valid = await verifySubscriptionPaymentSignature({
      paymentId,
      subscriptionId,
      signature,
    });
    if (!valid) {
      return errorResponse("Invalid payment signature", 403);
    }

    const { data: row } = await admin
      .from("premium_subscriptions")
      .select("user_id")
      .eq("razorpay_subscription_id", subscriptionId)
      .eq("user_id", authData.user.id)
      .maybeSingle();

    if (!row) {
      return errorResponse("Subscription not found for user", 404);
    }

    await admin
      .from("premium_subscriptions")
      .update({
        status: "authenticated",
        updated_at: new Date().toISOString(),
      })
      .eq("razorpay_subscription_id", subscriptionId);

    return jsonResponse({ verified: true, status: "authenticated" });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return errorResponse(message, 500);
  }
});
