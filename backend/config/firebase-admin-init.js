require('dotenv').config();
const admin = require('firebase-admin');
const path = require('path');

/**
 * Initialize Firebase Admin SDK
 * This allows backend to verify Firebase Auth tokens and access Firestore
 */

let firebaseApp;

function initializeFirebaseAdmin() {
    if (firebaseApp) {
        return firebaseApp;
    }

    try {
        // Check if Firebase credentials are configured
        const projectId = process.env.FIREBASE_PROJECT_ID;
        const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH;

        if (!projectId || !serviceAccountPath) {
            console.warn('⚠️  Firebase Admin SDK not configured. Authentication will be disabled.');
            console.warn('   Set FIREBASE_PROJECT_ID and FIREBASE_SERVICE_ACCOUNT_PATH in .env');
            return null;
        }

        // Load service account credentials
        const serviceAccount = require(path.resolve(serviceAccountPath));

        // Initialize Firebase Admin
        firebaseApp = admin.initializeApp({
            credential: admin.credential.cert(serviceAccount),
            projectId: projectId,
        });

        console.log('✅ Firebase Admin SDK initialized successfully');
        console.log(`   Project ID: ${projectId}`);

        return firebaseApp;
    } catch (error) {
        console.error('❌ Failed to initialize Firebase Admin SDK:', error.message);
        console.error('   Authentication features will not work.');
        return null;
    }
}

// Export initialized admin instance
const firebaseAdmin = initializeFirebaseAdmin();

module.exports = {
    admin,
    firebaseAdmin,
    isFirebaseEnabled: () => firebaseAdmin !== null,
};
