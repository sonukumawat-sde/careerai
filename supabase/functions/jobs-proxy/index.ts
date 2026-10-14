// CareerAI - Jobs Proxy Edge Function
// JSearch (RapidAPI) se real jobs laata hai. API key server pe (safe).
// App sirf search query bhejta hai, ye jobs wapas laata hai.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const rapidKey = Deno.env.get("RAPIDAPI_KEY");
    if (!rapidKey) {
      return jsonResponse({ error: "Server not configured." }, 500);
    }

    const body = await req.json();
    // Search query (default: tech jobs in India)
    const query: string = body.query ?? "developer";
    const page: number = body.page ?? 1;

    // JSearch API call
  const url =
      `https://jsearch.p.rapidapi.com/search-v2?query=${encodeURIComponent(query + " jobs in India")}&num_pages=1&country=in&date_posted=all`;

    const res = await fetch(url, {
      method: "GET",
      headers: {
        "X-RapidAPI-Key": rapidKey,
        "X-RapidAPI-Host": "jsearch.p.rapidapi.com",
      },
    });

    if (!res.ok) {
      const errText = await res.text();
      console.error("JSearch error:", errText);
      return jsonResponse({ error: "Jobs service error. Try again." }, 502);
    }

   const data = await res.json();
    // v5 (/search-v2) me jobs "data.jobs" me hote hai
    const rawJobs = Array.isArray(data?.data?.jobs)
      ? data.data.jobs
      : (Array.isArray(data?.data) ? data.data : []);
    // Sirf zaroori fields nikaalo (clean response)
    const jobs = rawJobs.map((j: Record<string, unknown>) => ({
      id: (j.job_id ?? j.id ?? "").toString(),
      title: (j.job_title ?? j.title ?? "").toString(),
      company: (j.employer_name ?? j.company_name ?? "").toString(),
      logo: (j.employer_logo ?? j.company_logo ?? null),
      location: [j.job_city ?? j.city, j.job_state ?? j.state, j.job_country ?? j.country]
        .filter(Boolean)
        .join(", ") || "Remote",
      type: (j.job_employment_type ?? j.employment_type ?? "Full-time").toString(),
      remote: (j.job_is_remote ?? j.is_remote ?? false),
      description: (j.job_description ?? j.description ?? "").toString(),
      applyLink: (j.job_apply_link ?? j.apply_link ?? j.job_google_link ?? "").toString(),
      postedAt: (j.job_posted_at_datetime_utc ?? "").toString(),
    }));

    return jsonResponse({ jobs }, 200);
  } catch (e) {
    console.error("Function error:", e);
    return jsonResponse({ error: "Something went wrong." }, 500);
  }
});

function jsonResponse(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}