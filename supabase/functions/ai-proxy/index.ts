// CareerAI - AI Proxy Edge Function (OpenRouter version)
// Ye server pe chalta hai. OpenRouter key yahi rehti hai (app me nahi = safe).
// App sirf { task, payload } bhejta hai, ye OpenRouter se jawab laata hai.

import "jsr:@supabase/functions-js/edge-runtime.d.ts";

// CORS headers (app se request allow karne ke liye)
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// OpenRouter endpoint (OpenAI-compatible)
const OPENROUTER_URL = "https://openrouter.ai/api/v1/chat/completions";

// Free models list — pehla try hoga, fail hua toh agla (fallback).
// Rate-limit / down hone pe agla model auto try hota hai.
const MODELS = [
  "meta-llama/llama-3.3-70b-instruct:free",
  "meta-llama/llama-3.1-8b-instruct:free",
  "google/gemma-2-9b-it:free",
];

/**
 * Har task ke liye alag system prompt + user message.
 * Return: { system, user }
 */
function buildMessages(
  task: string,
  payload: Record<string, unknown>,
): { system: string; user: string } {
  switch (task) {
    case "coach_chat": {
      const message = String(payload.message ?? "");
      const history = String(payload.history ?? "");
      return {
        system:
          "You are CareerAI, a friendly and encouraging AI career coach for job seekers in India. " +
          "Give practical, concise, actionable advice. Keep responses under 150 words unless asked for detail. " +
          "Use simple language. Be warm and motivating.",
        user: `${history ? `Previous conversation:\n${history}\n\n` : ""}${message}`,
      };
    }

    case "analyze_resume": {
      const resumeText = String(payload.resume_text ?? "");
      return {
        system:
          "You are an expert resume reviewer and ATS specialist. " +
          "Respond ONLY in valid JSON format (no markdown, no code fences, no extra text) with this exact structure:\n" +
          `{
  "score": <number 0-100>,
  "ats_score": <number 0-100>,
  "strengths": ["point1", "point2", "point3"],
  "weaknesses": ["point1", "point2", "point3"],
  "suggestions": ["suggestion1", "suggestion2", "suggestion3"]
}`,
        user: `Analyze this resume:\n\n${resumeText}`,
      };
    }

    default: {
      return {
        system: "You are a helpful assistant.",
        user: String(payload.message ?? "Hello"),
      };
    }
  }
}

Deno.serve(async (req: Request) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const apiKey = Deno.env.get("OPENROUTER_API_KEY");
    if (!apiKey) {
      return jsonResponse(
        { error: "Server not configured (no API key)." },
        500,
      );
    }

    const body = await req.json();
    const task: string = body.task ?? "coach_chat";
    const payload: Record<string, unknown> = body.payload ?? {};

    const { system, user } = buildMessages(task, payload);

    // Model fallback loop — koi ek chal jaye
    let aiText = "";
    let lastError = "";

    for (const model of MODELS) {
      try {
        const res = await fetch(OPENROUTER_URL, {
          method: "POST",
          headers: {
            "Authorization": `Bearer ${apiKey}`,
            "Content-Type": "application/json",
            "HTTP-Referer": "https://careerai.app",
            "X-Title": "CareerAI",
          },
          body: JSON.stringify({
            model,
            messages: [
              { role: "system", content: system },
              { role: "user", content: user },
            ],
            temperature: 0.7,
            max_tokens: 800,
          }),
        });

        if (!res.ok) {
          lastError = `${model}: ${res.status} ${await res.text()}`;
          console.error("OpenRouter error:", lastError);
          continue; // agla model try karo
        }

        const data = await res.json();
        const text = data?.choices?.[0]?.message?.content ?? "";
        if (text && text.trim()) {
          aiText = text.trim();
          break; // mil gaya, loop rok do
        }
        lastError = `${model}: empty response`;
      } catch (e) {
        lastError = `${model}: ${e}`;
        console.error("Model fetch failed:", lastError);
        continue;
      }
    }

    if (!aiText) {
      console.error("All models failed:", lastError);
      return jsonResponse({ error: "AI service error. Try again." }, 502);
    }

    return jsonResponse({ result: aiText }, 200);
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