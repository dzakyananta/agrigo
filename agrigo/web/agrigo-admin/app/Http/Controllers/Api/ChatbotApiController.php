<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ChatbotFaq;
use Illuminate\Http\Request;

class ChatbotApiController extends Controller
{
    /**
     * Get all active FAQs
     */
    public function index()
    {
        $faqs = ChatbotFaq::active()
            ->orderBy('category')
            ->orderBy('usage_count', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'FAQs retrieved successfully',
            'data' => $faqs
        ]);
    }

    /**
     * Get FAQs by category
     */
    public function getByCategory($category)
    {
        $faqs = ChatbotFaq::active()
            ->byCategory($category)
            ->orderBy('usage_count', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'FAQs retrieved successfully',
            'data' => $faqs
        ]);
    }

    /**
     * Get all categories
     */
    public function getCategories()
    {
        $categories = ChatbotFaq::active()
            ->distinct()
            ->pluck('category');

        return response()->json([
            'success' => true,
            'message' => 'Categories retrieved successfully',
            'data' => $categories
        ]);
    }

    /**
     * Search FAQs by keyword or question
     */
    public function search(Request $request)
    {
        $query = $request->input('q', '');
        
        if (empty($query)) {
            return response()->json([
                'success' => false,
                'message' => 'Query parameter is required'
            ], 400);
        }

        // Search in question, answer, and keywords
        $faqs = ChatbotFaq::active()
            ->where(function($q) use ($query) {
                $q->where('question', 'like', "%{$query}%")
                  ->orWhere('answer', 'like', "%{$query}%")
                  ->orWhereJsonContains('keywords', $query);
            })
            ->orderBy('usage_count', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'message' => 'Search results retrieved successfully',
            'data' => $faqs
        ]);
    }

    /**
     * Get FAQ by ID and increment usage
     */
    public function show($id)
    {
        $faq = ChatbotFaq::active()->find($id);

        if (!$faq) {
            return response()->json([
                'success' => false,
                'message' => 'FAQ not found'
            ], 404);
        }

        // Increment usage count
        $faq->incrementUsage();

        return response()->json([
            'success' => true,
            'message' => 'FAQ retrieved successfully',
            'data' => $faq
        ]);
    }

    /**
     * Smart search - find best matching FAQ
     */
    public function smartSearch(Request $request)
    {
        $query = strtolower($request->input('q', ''));
        
        if (empty($query)) {
            return response()->json([
                'success' => false,
                'message' => 'Query parameter is required'
            ], 400);
        }

        // Get all active FAQs
        $faqs = ChatbotFaq::active()->get();

        // Score each FAQ based on keyword matches
        $scoredFaqs = $faqs->map(function($faq) use ($query) {
            $score = 0;
            
            // Check if query matches keywords
            foreach ($faq->keywords as $keyword) {
                if (stripos($query, strtolower($keyword)) !== false) {
                    $score += 10;
                }
            }
            
            // Check if query matches question
            if (stripos(strtolower($faq->question), $query) !== false) {
                $score += 5;
            }
            
            // Check if query matches answer
            if (stripos(strtolower($faq->answer), $query) !== false) {
                $score += 3;
            }
            
            $faq->match_score = $score;
            return $faq;
        })
        ->filter(function($faq) {
            return $faq->match_score > 0;
        })
        ->sortByDesc('match_score')
        ->values();

        // Increment usage for best match
        if ($scoredFaqs->isNotEmpty()) {
            $scoredFaqs->first()->incrementUsage();
        }

        return response()->json([
            'success' => true,
            'message' => 'Smart search completed',
            'data' => $scoredFaqs
        ]);
    }
}
