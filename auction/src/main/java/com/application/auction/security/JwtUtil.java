package com.application.auction.security;

import com.nimbusds.jose.*;
import com.nimbusds.jose.crypto.MACSigner;
import com.nimbusds.jose.crypto.MACVerifier;
import com.nimbusds.jwt.JWTClaimsSet;
import com.nimbusds.jwt.SignedJWT;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Component;

import java.text.ParseException;
import java.util.Date;
import java.util.function.Function;

@Component
public class JwtUtil {

    // !!! IMPORTANT !!!
    // The secret key is injected from application.properties.
    // Ensure you have a secure, randomly generated string for 'jwt.secret' in your properties.
    // It should be at least 256 bits (32 bytes) for HS256.
    @Value("${jwt.secret}")
    private String secretKey;

    private final JWSAlgorithm algorithm = JWSAlgorithm.HS256;

    // Token validity in milliseconds (e.g., 10 hours)
    private static final long JWT_TOKEN_VALIDITY = 10 * 60 * 60 * 1000;

    /**
     * Generates a JWT for a given user.
     * @param userDetails The user details from which to create the token.
     * @return A signed JWT as a String.
     */
    public String generateToken(UserDetails userDetails) {
        try {
            // Create a signer with the secret key.
            JWSSigner signer = new MACSigner(secretKey.getBytes());

            // Prepare JWT claims: subject, issue time, expiration time.
            JWTClaimsSet claimsSet = new JWTClaimsSet.Builder()
                    .subject(userDetails.getUsername())
                    .issueTime(new Date())
                    .expirationTime(new Date(System.currentTimeMillis() + JWT_TOKEN_VALIDITY))
                    .build();

            // Create a new SignedJWT with the JWSHeader and the JWTClaimsSet.
            SignedJWT signedJWT = new SignedJWT(new JWSHeader(algorithm), claimsSet);

            // Sign the JWT with the signer.
            signedJWT.sign(signer);

            // Serialize to a compact, URL-safe string.
            return signedJWT.serialize();

        } catch (JOSEException e) {
            // In a real application, proper logging is crucial here.
            throw new RuntimeException("Error generating JWT token", e);
        }
    }

    /**
     * Validates a JWT. Checks signature, expiration, and if the username matches.
     * @param token The JWT string.
     * @param userDetails The user details to validate against.
     * @return true if the token is valid, false otherwise.
     */
    public Boolean validateToken(String token, UserDetails userDetails) {
        try {
            final String username = extractUsername(token);
            return (username.equals(userDetails.getUsername()) && !isTokenExpired(token));
        } catch (Exception e) {
            // If any exception occurs during parsing or validation, the token is invalid.
            return false;
        }
    }

    /**
     * Extracts the username (subject) from the JWT.
     * @param token The JWT string.
     * @return The username.
     */
    public String extractUsername(String token) {
        return extractClaim(token, JWTClaimsSet::getSubject);
    }

    /**
     * Extracts the expiration date from the JWT.
     * @param token The JWT string.
     * @return The expiration date.
     */
    public Date extractExpiration(String token) {
        return extractClaim(token, JWTClaimsSet::getExpirationTime);
    }

    /**
     * A generic function to extract a specific claim from the JWT.
     * @param token The JWT string.
     * @param claimsResolver A function to apply on the claims set.
     * @return The extracted claim.
     */
    public <T> T extractClaim(String token, Function<JWTClaimsSet, T> claimsResolver) {
        final JWTClaimsSet claims = extractAllClaims(token);
        return claimsResolver.apply(claims);
    }

    /**
     * Parses the JWT, verifies its signature, and returns all claims.
     * This is the core validation step.
     * @param token The JWT string.
     * @return The set of claims from the JWT.
     */
    private JWTClaimsSet extractAllClaims(String token) {
        try {
            SignedJWT signedJWT = SignedJWT.parse(token);
            JWSVerifier verifier = new MACVerifier(secretKey.getBytes());

            // Verify the signature. If it fails, an exception should be thrown or handled.
            if (!signedJWT.verify(verifier)) {
                throw new JOSEException("JWT signature verification failed.");
            }

            return signedJWT.getJWTClaimsSet();
        } catch (ParseException | JOSEException e) {
            // In a real application, log this error for security auditing.
            throw new RuntimeException("Failed to parse or verify JWT", e);
        }
    }

    /**
     * Checks if the token has expired.
     * @param token The JWT string.
     * @return true if the token is expired, false otherwise.
     */
    private Boolean isTokenExpired(String token) {
        final Date expiration = extractExpiration(token);
        return expiration.before(new Date());
    }
}
