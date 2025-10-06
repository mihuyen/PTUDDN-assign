# SSO Demo (Auth0 + Spring Boot OIDC)

This sample demonstrates integrating Auth0 (OIDC) with a Spring Boot application using Spring Security OAuth2 Client. It requests OpenID Connect ID token and includes `offline_access` scope so a refresh token is returned.

## What I added

- Spring Security + OAuth2 Client dependencies in `pom.xml`.
- `SecurityConfig` to enable OAuth2 login and an in-memory authorized client service.
- `HomeController` with endpoints `/` and `/profile`.
- `application.properties` placeholders for Auth0 configuration.

## Configure Auth0

1. Create an Application (Regular Web Application) in your Auth0 tenant.
2. In the application settings, set the **Allowed Callback URLs** to `http://localhost:8080/login/oauth2/code/auth0` and **Allowed Logout URLs** to `http://localhost:8080/`.
3. Enable the `offline_access` scope for your application if necessary (Auth0 issues refresh tokens when `offline_access` is requested and allowed).
4. Copy your Domain, Client ID and Client Secret.

## application.properties

Fill these values in `src/main/resources/application.properties`:

spring.security.oauth2.client.registration.auth0.client-id=YOUR_AUTH0_CLIENT_ID
spring.security.oauth2.client.registration.auth0.client-secret=YOUR_AUTH0_CLIENT_SECRET
spring.security.oauth2.client.provider.auth0.issuer-uri=https://YOUR_AUTH0_DOMAIN/

Example issuer URI: `https://dev-xxxxx.us.auth0.com/`

## Run

From the project root:

```powershell
./mvnw spring-boot:run
```

Then visit `http://localhost:8080/` and click the login link (or open `http://localhost:8080/oauth2/authorization/auth0`). After login you'll be redirected to the app. Visit `/profile` to see ID token claims.

![alt text](images\image-1.png)

![alt text](images\image.png)


## Notes and next steps

- This example stores access and refresh tokens in memory. To persist refresh tokens across restarts, implement a persistent `OAuth2AuthorizedClientService` (e.g., JDBC-backed).
- For production, secure secrets (client secret) via environment variables or a secrets manager.
- You can also enable PKCE and additional security measures if needed.


