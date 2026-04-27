package com.group66.hqadmin.controller;

import com.group66.hqadmin.entity.Assignment;
import com.group66.hqadmin.entity.Department;
import com.group66.hqadmin.entity.Employee;
import com.group66.hqadmin.repository.AssignmentRepository;
import com.group66.hqadmin.repository.DepartmentRepository;
import com.group66.hqadmin.repository.EmployeeRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
    @RequestMapping("/api/assignments")
    public class AssignmentRestController {
        @Autowired
        private AssignmentRepository assignmentRepository;

        @Autowired
        private EmployeeRepository employeeRepository;

        @Autowired
        private DepartmentRepository departmentRepository;

        @GetMapping
        public List<Assignment> getAll() {
            return assignmentRepository.findAll();
        }

        @PostMapping
        @PreAuthorize("hasRole('HR')") // Fulfills "Role: HR Only"
        public ResponseEntity<?> assignToDepartment(@RequestBody Map<String, Long> request) {
            Long empId = request.get("employeeId");
            Long deptId = request.get("departmentId");

            Employee employee = employeeRepository.findById(empId)
                    .orElseThrow(() -> new RuntimeException("Employee not found"));
            Department department = departmentRepository.findById(deptId)
                    .orElseThrow(() -> new RuntimeException("Department not found"));

            employee.setDepartment(department);
            employeeRepository.save(employee);

            return ResponseEntity.ok().build();
        }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('HR')") // Fulfills "Role: HR Only"
    public ResponseEntity<?> removeAssignment(@PathVariable Long id) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        // Remove the association
        employee.setDepartment(null);
        employeeRepository.save(employee);

        return ResponseEntity.ok().build();
        }
}

