export interface ChatMessage {
  role: 'system' | 'user';
  content: string | { type: 'text' | 'image_url'; text?: string; image_url?: { url: string } }[];
}

export interface ChatResult {
  text: string;
  model: string;
}

/** Calls OpenRouter's chat completions API. Throws on transport or HTTP errors. */
export async function chat(apiKey: string, model: string, messages: ChatMessage[], opts: { maxTokens: number; temperature: number; json?: boolean }): Promise<ChatResult> {
  const res = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      authorization: `Bearer ${apiKey}`,
      'content-type': 'application/json',
      'HTTP-Referer': 'https://shotr.app',
      'X-Title': 'shotr',
    },
    body: JSON.stringify({
      model,
      messages,
      max_tokens: opts.maxTokens,
      temperature: opts.temperature,
      ...(opts.json ? { response_format: { type: 'json_object' } } : {}),
    }),
  });
  if (!res.ok) throw new Error(`openrouter ${res.status}`);
  const data = (await res.json()) as { choices?: { message?: { content?: string } }[]; model?: string };
  return { text: data.choices?.[0]?.message?.content?.trim() ?? '', model: data.model ?? model };
}
