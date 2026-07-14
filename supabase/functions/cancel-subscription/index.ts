import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";
import {
  cancelRazorpaySubscription,
  requireEnv,
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

    const { data: row } = await admin
      .from("premium_subscriptions")
      .select("razorpay_subscription_id, status")
      .eq("user_id", authData.user.id)
      .maybeSingle();

    if (!row?.razorpay_subscription_id) {
      return errorResponse("No active subscription found", 404);
    }

    await cancelRazorpaySubscription(row.razorpay_subscription_id, true);

    return jsonResponse({
      cancelled: true,
      cancel_at_cycle_end: true,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return errorResponse(message, 500);
  }
});
