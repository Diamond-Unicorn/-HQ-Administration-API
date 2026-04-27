package com.group66.hqadmin.controller;

import com.group66.hqadmin.entity.Employee;
import com.group66.hqadmin.repository.EmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/home")
public class HomeController {

    @Autowired
    private EmployeeRepository employeeRepository;

    @GetMapping("/")
    public String index() {
        return "index"; // This serves the "Shell" page
    }

    // Returns all data needed for the initial dashboard load
    @GetMapping("/summary")
    public ResponseEntity<Map<String, Object>> getHomeSummary() {
        List<Employee> employees = employeeRepository.findAll();
        Map<String, Object> data = new HashMap<>();
        data.put("employees", employees);
        data.put("employeeCount", employees.size());
        return ResponseEntity.ok(data);
    }

    // RESTful Search Endpoint
    @GetMapping("/search")
    public ResponseEntity<List<Employee>> searchEmployees(@RequestParam("query") String query) {
        List<Employee> results = employeeRepository.findByNameContainingIgnoreCase(query);
        return ResponseEntity.ok(results);
    }

    @GetMapping("/api/employees/me")
    public ResponseEntity<?> getCurrentUser(Authentication authentication) {
        if (authentication == null || !authentication.isAuthenticated()) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }
        return ResponseEntity.ok(Map.of("username", authentication.getName()));
    }
}