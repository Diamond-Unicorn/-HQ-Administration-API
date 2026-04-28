package com.group66.hqadmin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ViewController {

    // Entry Point for application
    @GetMapping("/")
    public String index() {
        // looks for /WEB-INF/jsp/index.jsp
        return "index";
    }
}