package com.example.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.net.InetAddress;
import java.net.UnknownHostException;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home(Model model) throws UnknownHostException {
        model.addAttribute("hostname", InetAddress.getLocalHost().getHostName());
        model.addAttribute("appName", "K8s Demo Application");
        model.addAttribute("version", "1.0.0");
        return "index";
    }
}
