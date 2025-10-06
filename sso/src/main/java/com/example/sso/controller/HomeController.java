package com.example.sso.controller;

import java.util.Map;

import org.springframework.http.MediaType;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.oidc.user.OidcUser;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping
public class HomeController {

    @GetMapping(path = {"/", "/index"}, produces = MediaType.TEXT_PLAIN_VALUE)
    public String index() {
        return "Welcome to SSO demo. Visit /profile after logging in via /oauth2/authorization/auth0";
    }

    @GetMapping(path = "/profile", produces = MediaType.APPLICATION_JSON_VALUE)
    public Map<String, Object> profile(@AuthenticationPrincipal OidcUser oidcUser) {
        if (oidcUser == null) {
            return Map.of("error", "unauthenticated");
        }
        return Map.of(
            "name", oidcUser.getFullName(),
            "claims", oidcUser.getClaims()
        );
    }
}

