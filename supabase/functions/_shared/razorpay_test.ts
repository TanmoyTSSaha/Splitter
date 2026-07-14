import { assertEquals } from "https://deno.land/std@0.224.0/assert/assert_equals.ts";
import { mapRazorpaySubscriptionStatus } from "../_shared/razorpay.ts";

Deno.test("mapRazorpaySubscriptionStatus maps known statuses", () => {
  assertEquals(mapRazorpaySubscriptionStatus("active"), "active");
  assertEquals(mapRazorpaySubscriptionStatus("authenticated"), "authenticated");
  assertEquals(mapRazorpaySubscriptionStatus("cancelled"), "cancelled");
  assertEquals(mapRazorpaySubscriptionStatus("unknown"), "pending");
});
