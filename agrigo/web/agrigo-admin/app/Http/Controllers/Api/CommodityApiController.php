<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Commodity;
use Illuminate\Http\Request;

class CommodityApiController extends Controller
{
    /**
     * Get all active commodities
     */
    public function index()
    {
        $commodities = Commodity::where('is_active', true)
            ->orderBy('name', 'asc')
            ->get(['id', 'name', 'type', 'description', 'created_at', 'updated_at']);

        return response()->json([
            'success' => true,
            'message' => 'Commodities retrieved successfully',
            'data' => $commodities
        ]);
    }

    /**
     * Get commodity by ID
     */
    public function show($id)
    {
        $commodity = Commodity::find($id);

        if (!$commodity) {
            return response()->json([
                'success' => false,
                'message' => 'Commodity not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Commodity retrieved successfully',
            'data' => $commodity
        ]);
    }

    /**
     * Get commodities by type
     */
    public function getByType($type)
    {
        $commodities = Commodity::where('is_active', true)
            ->where('type', $type)
            ->orderBy('name', 'asc')
            ->get(['id', 'name', 'type', 'description']);

        return response()->json([
            'success' => true,
            'message' => 'Commodities retrieved successfully',
            'data' => $commodities
        ]);
    }

    /**
     * Get all commodity types
     */
    public function getTypes()
    {
        $types = [
            'Padi-padian',
            'Palawija',
            'Sayuran',
            'Buah-buahan',
            'Umbi-umbian',
            'Rempah-rempah'
        ];

        return response()->json([
            'success' => true,
            'message' => 'Commodity types retrieved successfully',
            'data' => $types
        ]);
    }
}
