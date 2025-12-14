<?php

require __DIR__ . '/vendor/autoload.php';

use Kreait\Firebase\Factory;

try {
    echo "Testing Firebase Connection...\n\n";
    
    $credentialsPath = __DIR__ . '/storage/firebase-credentials.json';
    
    if (!file_exists($credentialsPath)) {
        die("❌ Credentials file not found at: $credentialsPath\n");
    }
    
    echo "✅ Credentials file found\n";
    echo "📄 Path: $credentialsPath\n\n";
    
    $factory = (new Factory)
        ->withServiceAccount($credentialsPath);
    
    echo "✅ Factory created\n\n";
    
    // Test Firebase Auth
    $auth = $factory->createAuth();
    echo "✅ Firebase Auth initialized\n\n";
    
    // List users
    echo "📋 Fetching users from Firebase Authentication...\n";
    $users = $auth->listUsers($maxResults = 5);
    
    $count = 0;
    foreach ($users as $user) {
        $count++;
        echo "\n👤 User $count:\n";
        echo "   UID: {$user->uid}\n";
        echo "   Email: {$user->email}\n";
        echo "   Display Name: {$user->displayName}\n";
        echo "   Email Verified: " . ($user->emailVerified ? 'Yes' : 'No') . "\n";
    }
    
    echo "\n\n✅ SUCCESS! Firebase connection working!\n";
    echo "Total users fetched: $count\n";
    
} catch (\Exception $e) {
    echo "\n❌ ERROR: " . $e->getMessage() . "\n";
    echo "\nStack trace:\n" . $e->getTraceAsString() . "\n";
}
