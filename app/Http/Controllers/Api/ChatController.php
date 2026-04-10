<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ChatController extends Controller
{
    public function send(Request $request)
    {
        $request->validate([
            'message' => 'required|string',
            'language' => 'nullable|in:ar,en',
        ]);

        $response = Http::timeout(30)->post('http://localhost:5678/webhook/chatbot', [
            'message'   => $request->message,
            'language'  => $request->language ?? 'ar',
            'sessionId' => auth()->id(),
        ]);

        if ($response->failed()) {
            return response()->json([
                'reply' => 'عذراً، الخدمة غير متاحة حالياً.'
            ], 503);
        }

        return response()->json([
            'reply' => $response->json('response')
        ]);
    }
}
