package com.group66.hqadmin.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class ViewController {

    // This is the "Entry Point" for your entire application
    @GetMapping("/")
    public String index() {
        // This looks for /WEB-INF/jsp/index.jsp
        // (Make sure your file is named index.jsp!)
        return "index";
    }
}