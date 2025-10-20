package com.example.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.InetAddress;
import java.net.UnknownHostException;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class HealthController {

    @GetMapping("/health")
    public Map<String, String> health() throws UnknownHostException {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("hostname", InetAddress.getLocalHost().getHostName());
        response.put("message", "Application is running successfully");
        return response;
    }

    @GetMapping("/info")
    public Map<String, String> info() throws UnknownHostException {
        Map<String, String> response = new HashMap<>();
        response.put("application", "K8s Demo Application");
        response.put("version", "1.0.0");
        response.put("hostname", InetAddress.getLocalHost().getHostName());
        response.put("java_version", System.getProperty("java.version"));
        return response;
    }
}
