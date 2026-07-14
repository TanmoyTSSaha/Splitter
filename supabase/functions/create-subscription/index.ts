import { createClient } from "https://esm.sh/@supabase/supabase-js@2.49.1";
import { errorResponse, handleCors, jsonResponse } from "../_shared/cors.ts";
import {
  createRazorpayCustomer,
  createRazorpaySubscription,
  mapRazorpaySubscriptionStatus,
  periodEndFromUnix,
  planIdFor,
  requireEnv,
  type PlanInterval,
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

    const userId = authData.user.id;
    const body = await req.json();
    const plan = body?.plan as PlanInterval;
    if (plan !== "monthly" && plan !== "yearly") {
      return errorResponse('Invalid plan. Use "monthly" or "yearly".');
    }

    const { data: profile } = await admin
      .from("users")
      .select("firstname, lastname, user_email, phone")
      .eq("user_id", userId)
      .maybeSingle();

    const email = profile?.user_email ?? authData.user.email ?? undefined;
    const contact = profile?.phone ?? authData.user.phone ?? undefined;
    const name = [profile?.firstname, profile?.lastname].filter(Boolean).join(" ")
      .trim() || undefined;

    const { data: existing } = await admin
      .from("premium_subscriptions")
      .select("razorpay_customer_id, razorpay_subscription_id, status")
      .eq("user_id", userId)
      .maybeSingle();

    let customerId = existing?.razorpay_customer_id as string | undefined;
    if (!customerId) {
      const customer = await createRazorpayCustomer({
        email,
        contact,
        name,
        userId,
      });
      customerId = customer.id;
    }

    const planId = planIdFor(plan);
    const subscription = await createRazorpaySubscription({
      planId,
      customerId,
      interval: plan,
      userId,
    });

    const mappedStatus = mapRazorpaySubscriptionStatus(subscription.status);
    const periodEnd = periodEndFromUnix(subscription.current_end);

    await admin.from("premium_subscriptions").upsert(
      {
        user_id: userId,
        razorpay_subscription_id: subscription.id,
        razorpay_customer_id: customerId,
        razorpay_plan_id: subscription.plan_id ?? planId,
        plan_interval: plan,
        status: mappedStatus,
        current_period_end: periodEnd,
      },
      { onConflict: "user_id" },
    );

    return jsonResponse({
      subscription_id: subscription.id,
      key_id: requireEnv("RAZORPAY_KEY_ID"),
      status: mappedStatus,
    });
  } catch (error) {
    const message = error instanceof Error ? error.message : "Unknown error";
    return errorResponse(message, 500);
  }
});
