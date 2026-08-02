export type ServiceAccount = {
  project_id: string;
  client_email: string;
  private_key: string;
};

function base64UrlEncode(data: Uint8Array): string {
  const base64 = btoa(String.fromCharCode(...data));
  return base64.replace(/\+/g, "-").replace(/\//g, "_").replace(/=+$/g, "");
}

async function importPrivateKey(pem: string): Promise<CryptoKey> {
  const cleaned = pem
    .replace("-----BEGIN PRIVATE KEY-----", "")
    .replace("-----END PRIVATE KEY-----", "")
    .replace(/\s+/g, "");
  const binary = Uint8Array.from(atob(cleaned), (c) => c.charCodeAt(0));
  return crypto.subtle.importKey(
    "pkcs8",
    binary.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
}

async function signJwt(
  header: Record<string, string>,
  payload: Record<string, unknown>,
  privateKeyPem: string,
): Promise<string> {
  const encoder = new TextEncoder();
  const key = await importPrivateKey(privateKeyPem);
  const headerPart = base64UrlEncode(encoder.encode(JSON.stringify(header)));
  const payloadPart = base64UrlEncode(encoder.encode(JSON.stringify(payload)));
  const unsigned = `${headerPart}.${payloadPart}`;
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    encoder.encode(unsigned),
  );
  return `${unsigned}.${base64UrlEncode(new Uint8Array(signature))}`;
}

export async function getGoogleAccessToken(
  serviceAccount: ServiceAccount,
): Promise<string> {
  const now = Math.floor(Date.now() / 1000);
  const assertion = await signJwt(
    { alg: "RS256", typ: "JWT" },
    {
      iss: serviceAccount.client_email,
      sub: serviceAccount.client_email,
      aud: "https://oauth2.googleapis.com/token",
      iat: now,
      exp: now + 3600,
      scope: "https://www.googleapis.com/auth/firebase.messaging",
    },
    serviceAccount.private_key,
  );

  const response = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion,
    }),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(`Google token exchange failed: ${text}`);
  }

  const json = await response.json() as { access_token?: string };
  if (!json.access_token) {
    throw new Error("Google token response missing access_token");
  }
  return json.access_token;
}

export type FcmSendResult = {
  ok: boolean;
  error?: string;
  invalidToken?: boolean;
};

export async function sendFcmToToken(
  serviceAccount: ServiceAccount,
  accessToken: string,
  deviceToken: string,
  notification: { title: string; body?: string },
  data: Record<string, string>,
): Promise<FcmSendResult> {
  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: deviceToken,
          notification,
          data,
          android: { priority: "HIGH" },
        },
      }),
    },
  );

  if (response.ok) {
    return { ok: true };
  }

  const text = await response.text();
  const invalidToken = text.includes("UNREGISTERED") ||
    text.includes("NOT_FOUND") ||
    text.includes("InvalidRegistration");
  return { ok: false, error: text, invalidToken };
}

export function preferenceColumnForType(type: string): string {
  switch (type) {
    case "friend_request":
      return "friend_request";
    case "group_invite":
      return "group_invite";
    case "expense_added":
      return "expense_added";
    case "settlement":
    case "settlement_request":
      return "settlement";
    case "settlement_reminder":
      return "settlement_reminder";
    case "loan_request":
      return "loan_request";
    case "budget_alert":
      return "budget_alert";
    case "general":
    case "marketing":
      return "marketing";
    default:
      return "friend_request";
  }
}

export function loadServiceAccount(): ServiceAccount {
  const raw = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!raw) {
    throw new Error("FCM_SERVICE_ACCOUNT_JSON is not configured");
  }
  return JSON.parse(raw) as ServiceAccount;
}
