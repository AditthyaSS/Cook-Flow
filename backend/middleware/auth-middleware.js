const { admin, isFirebaseEnabled } = require('../config/firebase-admin-init');

/**
 * Authentication middleware for protected routes
 * Verifies Firebase ID token from Authorization header
 */
async function authenticateUser(req, res, next) {
    // Skip authentication if Firebase is not configured (development mode)
    if (!isFirebaseEnabled()) {
        console.warn('⚠️  Auth middleware skipped - Firebase not configured');
        req.user = { uid: 'dev-user', email: 'dev@example.com' }; // Mock user for dev
        return next();
    }

    try {
        // Extract token from Authorization header
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            return res.status(401).json({
                success: false,
                error: 'Unauthorized - Missing or invalid Authorization header',
                code: 'AUTH_MISSING_TOKEN',
            });
        }

        const idToken = authHeader.split('Bearer ')[1];

        // Verify the ID token with Firebase Admin SDK
        const decodedToken = await admin.auth().verifyIdToken(idToken);

        // Attach user info to request object
        req.user = {
            uid: decodedToken.uid,
            email: decodedToken.email,
            emailVerified: decodedToken.email_verified,
            displayName: decodedToken.name,
        };

        console.log(`✅ Authenticated user: ${req.user.email} (${req.user.uid})`);

        next();
    } catch (error) {
        console.error('❌ Token verification failed:', error.message);

        // Determine error type
        let errorCode = 'AUTH_INVALID_TOKEN';
        let errorMessage = 'Invalid or expired authentication token';

        if (error.code === 'auth/id-token-expired') {
            errorCode = 'AUTH_TOKEN_EXPIRED';
            errorMessage = 'Authentication token has expired';
        } else if (error.code === 'auth/id-token-revoked') {
            errorCode = 'AUTH_TOKEN_REVOKED';
            errorMessage = 'Authentication token has been revoked';
        } else if (error.code === 'auth/argument-error') {
            errorCode = 'AUTH_INVALID_FORMAT';
            errorMessage = 'Invalid token format';
        }

        return res.status(401).json({
            success: false,
            error: errorMessage,
            code: errorCode,
        });
    }
}

/**
 * Optional authentication middleware
 * Attempts to authenticate but doesn't fail if token is missing
 */
async function optionalAuth(req, res, next) {
    if (!isFirebaseEnabled()) {
        req.user = null;
        return next();
    }

    try {
        const authHeader = req.headers.authorization;

        if (!authHeader || !authHeader.startsWith('Bearer ')) {
            req.user = null;
            return next();
        }

        const idToken = authHeader.split('Bearer ')[1];
        const decodedToken = await admin.auth().verifyIdToken(idToken);

        req.user = {
            uid: decodedToken.uid,
            email: decodedToken.email,
            emailVerified: decodedToken.email_verified,
            displayName: decodedToken.name,
        };

        next();
    } catch (error) {
        // If token is invalid, just proceed without user
        req.user = null;
        next();
    }
}

module.exports = {
    authenticateUser,
    optionalAuth,
};
