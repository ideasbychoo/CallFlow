import { NextRequest, NextResponse } from "next/server";
import { createAdminClient } from "@/lib/supabase/admin";

// A one-click, non-technical way to verify the ingest API is correctly
// configured. It makes a real request to /api/ingest/organisations (the same
// way the Claude Code prospecting routine or any other agent would), using
// the server's own CALLFLOW_INGEST_API_KEY, creates a harmless clearly-named
// test organisation, then immediately deletes it again.
export async function POST(req: NextRequest) {
  const apiKey = process.env.CALLFLOW_INGEST_API_KEY;

  if (!apiKey) {
    return NextResponse.json({
      success: false,
      message:
        "CALLFLOW_INGEST_API_KEY isn't set for this deployment yet. Add it in Vercel \u2192 Project Settings \u2192 Environment Variables, then redeploy, and try this test again.",
    });
  }

  const origin = req.nextUrl.origin;
  const testName = `__CallFlow ingest connection test__ ${Date.now()}`;

  try {
    const res = await fetch(`${origin}/api/ingest/organisations`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        created_by: "system:ingest-connection-test",
        organisation: {
          name: testName,
          notes: "Created automatically by the Settings 'Test ingest connection' button. Safe to ignore \u2014 it deletes itself immediately.",
        },
      }),
    });

    let data: { organisation_id?: string; warnings?: string[]; error?: string } = {};
    try {
      data = await res.json();
    } catch {
      // non-JSON response, fall through with data = {}
    }

    // Clean up the test organisation right away, regardless of outcome.
    if (data?.organisation_id) {
      const supabase = createAdminClient();
      await supabase.from("organisations").delete().eq("id", data.organisation_id);
    }

    if (!res.ok) {
      if (res.status === 401) {
        return NextResponse.json({
          success: false,
          message:
            "The key was rejected (401 Unauthorized). The CALLFLOW_INGEST_API_KEY set in Vercel doesn't match what this app expects \u2014 double-check you saved it and redeployed afterwards.",
        });
      }
      return NextResponse.json({
        success: false,
        message: `Request failed (HTTP ${res.status}): ${data?.error ?? "Unknown error"}`,
      });
    }

    return NextResponse.json({
      success: true,
      message:
        "Success \u2014 the ingest API accepted the key and wrote a test record, which has now been cleaned up automatically.",
      warnings: data?.warnings ?? [],
    });
  } catch (err) {
    return NextResponse.json({
      success: false,
      message:
        err instanceof Error
          ? `Couldn't reach the ingest API: ${err.message}`
          : "Couldn't reach the ingest API for an unknown reason.",
    });
  }
}
