import { createRemoteJWKSet, jwtVerify } from 'jose';

// Firebase ID tokens are RS256 JWTs signed by Google's securetoken service.
const JWKS = createRemoteJWKSet(new URL('https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com'));

/** Verifies the Firebase ID token on every call (SPEC tech). Returns the UID or null. */
export async function verifyFirebaseToken(token: string, projectId: string): Promise<string | null> {
  try {
    const { payload } = await jwtVerify(token, JWKS, {
      issuer: `https://securetoken.google.com/${projectId}`,
      audience: projectId,
      algorithms: ['RS256'],
    });
    const uid = payload.sub;
    if (!uid || typeof uid !== 'string' || uid.length > 128) return null;
    if (typeof payload.auth_time === 'number' && payload.auth_time * 1000 > Date.now() + 60_000) return null;
    return uid;
  } catch {
    return null;
  }
}
