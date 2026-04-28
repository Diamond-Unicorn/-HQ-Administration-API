package com.group66.hqadmin.controller;

import com.group66.hqadmin.entity.Assignment;
import com.group66.hqadmin.entity.Department;
import com.group66.hqadmin.entity.Employee;
import com.group66.hqadmin.repository.AssignmentRepository;
import com.group66.hqadmin.repository.DepartmentRepository;
import com.group66.hqadmin.repository.EmployeeRepository;
import com.group66.hqadmin.service.EmployeeService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/employees")
public class EmployeeController {

    @Autowired
    private EmployeeRepository employeeRepository;
    @Autowired
    private DepartmentRepository departmentRepository;
    @Autowired
    private AssignmentRepository assignmentRepository;

    private final EmployeeService employeeService;

    public EmployeeController(EmployeeService employeeService) {
        this.employeeService = employeeService;
    }

    // 1. Promote Employee
    @PutMapping("/{id}/promote")
    @PreAuthorize("hasRole('HR')")
    public ResponseEntity<?> promoteEmployee(@PathVariable Long id) {
        Employee emp = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        // Requirement: Returns 400 Bad Request if started < 6 months ago
        if (emp.getStartDate().isAfter(LocalDate.now().minusMonths(6))) {
            /*return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Employee has not reached the 6-month requirement."); */
            throw new IllegalArgumentException("Ineligible: Must work 6+ months");
        }


        // Business Logic: 10% raise
        emp.setSalary(emp.getSalary() * 1.10);

        employeeRepository.save(emp);
        return ResponseEntity.ok("Promoted! Salary is now " + emp.getSalary());
    }
    // 2. Get Data for Forms
    @GetMapping("/form-data")
    public ResponseEntity<Map<String, Object>> getFormData() {
        Map<String, Object> response = new HashMap<>();
        response.put("departments", departmentRepository.findAll());
        response.put("assignments", assignmentRepository.findAll());
        return ResponseEntity.ok(response);
    }

    // 3. Process the Creation (POST)
    @PostMapping("/")
    public ResponseEntity<Employee> saveEmployee(@RequestBody Employee employee,
                                                 @RequestParam("departmentId") Long deptId,
                                                 @RequestParam("assignmentId") Long asgnId) {

        Department dept = departmentRepository.findById(deptId)
                .orElseThrow(() -> new RuntimeException("Department not found"));
        Assignment asgn = assignmentRepository.findById(asgnId)
                .orElseThrow(() -> new RuntimeException("Assignment not found"));

        employee.setDepartment(dept);
        employee.setAssignment(asgn);

        Employee savedEmployee = employeeRepository.save(employee);
        return new ResponseEntity<>(savedEmployee, HttpStatus.CREATED);

    }

    // 4. Delete Employee
    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteEmployee(@PathVariable Long id) {
        return employeeRepository.findById(id)
                .map(employee -> {
                    employeeRepository.delete(employee);
                    return ResponseEntity.ok().build();
                })
                .orElse(ResponseEntity.notFound().build());
    }

    // 5. Get Single Employee for Editing (GET)
// helps fulfill 2. GET /api/employees/{id} (Roles: Manager, HR)
//o Retrieves details of a single employee. Returns 404 if not found.
    // Handles both the ID Lookup search and the Edit Modal data fetch
    @GetMapping("/{id}")
    public ResponseEntity<Employee> getEmployeeById(@PathVariable Long id) {
        return employeeRepository.findById(id)
                .map(employee -> ResponseEntity.ok(employee)) // Returns 200 + JSON if found
                .orElseGet(() -> ResponseEntity.notFound().build()); // Returns 404 if missing
    }

    // 6. Process the Update
    @PutMapping("/{id}")
    public ResponseEntity<Employee> updateEmployee(@PathVariable Long id,
                                                   @RequestBody Employee updatedDetails,
                                                   @RequestParam(value = "departmentId", required = false) Long deptId,
                                                   @RequestParam(value = "assignmentId", required = false) Long asgnId) {

        Employee existingEmployee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        existingEmployee.setName(updatedDetails.getName());
        existingEmployee.setAddress(updatedDetails.getAddress());
        existingEmployee.setSalary(updatedDetails.getSalary());
        existingEmployee.setContractType(updatedDetails.getContractType());
        existingEmployee.setStartDate(updatedDetails.getStartDate());

        if (deptId != null) {
            existingEmployee.setDepartment(departmentRepository.findById(deptId).orElse(null));
        }
        if (asgnId != null) {
            existingEmployee.setAssignment(assignmentRepository.findById(asgnId).orElse(null));
        }

        Employee savedEmployee = employeeRepository.save(existingEmployee);
        return ResponseEntity.ok(savedEmployee);
    }

   /* @GetMapping("/")
    public ResponseEntity<List<Employee>> getAllEmployees() {
        return ResponseEntity.ok(employeeRepository.findAll());
    } */


    //RESTful capabilities, Employee management 1st of 10 endpoints
    @GetMapping("")
    public ResponseEntity<List<Employee>> getAllEmployees() {
        return ResponseEntity.ok(employeeRepository.findAll());
    }
}