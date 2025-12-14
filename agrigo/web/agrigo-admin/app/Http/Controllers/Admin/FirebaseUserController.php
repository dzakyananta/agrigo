<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Services\FirebaseService;

class FirebaseUserController extends Controller
{
    protected $firebase;

    public function __construct(FirebaseService $firebase)
    {
        $this->firebase = $firebase;
    }

    /**
     * Display a listing of users from Firebase
     */
    public function index()
    {
        try {
            $users = $this->firebase->getAllUsers();
            
            return view('users.index', compact('users'));
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to fetch users: ' . $e->getMessage());
        }
    }

    /**
     * Display the specified user
     */
    public function show($id)
    {
        try {
            $user = $this->firebase->getUser($id);
            
            if (!$user) {
                return redirect()->route('users.index')->with('error', 'User not found');
            }

            $transactions = $this->firebase->getUserTransactions($id);

            return view('users.show', compact('user', 'transactions'));
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to fetch user: ' . $e->getMessage());
        }
    }

    /**
     * Update the specified user in Firebase
     */
    public function update(Request $request, $id)
    {
        try {
            $data = $request->validate([
                'name' => 'required|string|max:255',
                'phone' => 'nullable|string|max:20',
                'region' => 'nullable|string|max:255',
                'isActive' => 'boolean',
            ]);

            $this->firebase->updateUser($id, $data);

            return redirect()->route('users.show', $id)->with('success', 'User updated successfully');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to update user: ' . $e->getMessage());
        }
    }

    /**
     * Remove the specified user from Firebase
     */
    public function destroy($id)
    {
        try {
            $this->firebase->deleteUser($id);

            return redirect()->route('users.index')->with('success', 'User deleted successfully');
        } catch (\Exception $e) {
            return back()->with('error', 'Failed to delete user: ' . $e->getMessage());
        }
    }

    /**
     * Toggle user active status
     */
    public function toggleStatus($id)
    {
        try {
            $user = $this->firebase->getUser($id);
            
            if (!$user) {
                return response()->json(['error' => 'User not found'], 404);
            }

            $newStatus = !($user['isActive'] ?? true);
            $this->firebase->updateUser($id, ['isActive' => $newStatus]);

            return response()->json([
                'success' => true,
                'isActive' => $newStatus
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 500);
        }
    }
}
