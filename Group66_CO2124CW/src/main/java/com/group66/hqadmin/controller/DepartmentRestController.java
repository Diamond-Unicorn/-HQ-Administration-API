package com.group66.hqadmin.controller;

import com.group66.hqadmin.entity.Department;
import com.group66.hqadmin.repository.DepartmentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;


@RestController
    @RequestMapping("/api/departments")
    public class DepartmentRestController {
        @Autowired
        private DepartmentRepository departmentRepository;

        @GetMapping
        public List<Department> getAll() {
            return departmentRepository.findAll();

        }

        @PostMapping
        @PreAuthorize("hasRole('HR')") // Creates only for HR
        public ResponseEntity<?> createDept(@RequestBody Department dept) {
            // 2. Backend Validation: Budget must be positive
            if (dept.getBudget() <= 0) {
                return ResponseEntity.badRequest()
                        .body(Map.of("error", "Budget validation failed: Must be positive."));
            }

            Department saved = departmentRepository.save(dept);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        }
}






