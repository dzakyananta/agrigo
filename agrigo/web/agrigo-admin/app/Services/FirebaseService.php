<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Contract\Firestore;
use Kreait\Firebase\Contract\Auth;
use Kreait\Firebase\Contract\Storage;

class FirebaseService
{
    protected $firestore;
    protected $auth;
    protected $storage;

    public function __construct()
    {
        $credentialsPath = base_path(env('FIREBASE_CREDENTIALS'));
        
        $factory = (new Factory)
            ->withServiceAccount($credentialsPath);

        $this->firestore = $factory->createFirestore();
        $this->auth = $factory->createAuth();
        $this->storage = $factory->createStorage();
    }

    /**
     * Get Firestore database instance
     */
    public function firestore(): Firestore
    {
        return $this->firestore->database();
    }

    /**
     * Get Auth instance
     */
    public function auth(): Auth
    {
        return $this->auth;
    }

    /**
     * Get Storage instance
     */
    public function storage(): Storage
    {
        return $this->storage;
    }

    /**
     * Get all users from Firestore
     */
    public function getAllUsers($limit = 100)
    {
        $collection = $this->firestore()->collection('users');
        $documents = $collection->limit($limit)->documents();

        $users = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $users[] = array_merge(
                    ['id' => $document->id()],
                    $document->data()
                );
            }
        }

        return $users;
    }

    /**
     * Get user by ID
     */
    public function getUser($userId)
    {
        $document = $this->firestore()->collection('users')->document($userId)->snapshot();

        if ($document->exists()) {
            return array_merge(
                ['id' => $document->id()],
                $document->data()
            );
        }

        return null;
    }

    /**
     * Create new user in Firestore
     */
    public function createUser($data)
    {
        $collection = $this->firestore()->collection('users');
        $newDocument = $collection->add($data);

        return $newDocument->id();
    }

    /**
     * Update user in Firestore
     */
    public function updateUser($userId, $data)
    {
        $this->firestore()
            ->collection('users')
            ->document($userId)
            ->set($data, ['merge' => true]);

        return true;
    }

    /**
     * Delete user from Firestore
     */
    public function deleteUser($userId)
    {
        $this->firestore()
            ->collection('users')
            ->document($userId)
            ->delete();

        return true;
    }

    /**
     * Get all transactions
     */
    public function getAllTransactions($limit = 100)
    {
        $collection = $this->firestore()->collection('transactions');
        $documents = $collection->limit($limit)->documents();

        $transactions = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $transactions[] = array_merge(
                    ['id' => $document->id()],
                    $document->data()
                );
            }
        }

        return $transactions;
    }

    /**
     * Get transactions by user ID
     */
    public function getUserTransactions($userId)
    {
        $documents = $this->firestore()
            ->collection('transactions')
            ->where('userId', '=', $userId)
            ->documents();

        $transactions = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $transactions[] = array_merge(
                    ['id' => $document->id()],
                    $document->data()
                );
            }
        }

        return $transactions;
    }

    /**
     * Get collection data (generic)
     */
    public function getCollection($collectionName, $limit = 100)
    {
        $collection = $this->firestore()->collection($collectionName);
        $documents = $collection->limit($limit)->documents();

        $items = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $items[] = array_merge(
                    ['id' => $document->id()],
                    $document->data()
                );
            }
        }

        return $items;
    }

    /**
     * Query collection with where condition
     */
    public function queryCollection($collectionName, $field, $operator, $value)
    {
        $documents = $this->firestore()
            ->collection($collectionName)
            ->where($field, $operator, $value)
            ->documents();

        $items = [];
        foreach ($documents as $document) {
            if ($document->exists()) {
                $items[] = array_merge(
                    ['id' => $document->id()],
                    $document->data()
                );
            }
        }

        return $items;
    }
}
