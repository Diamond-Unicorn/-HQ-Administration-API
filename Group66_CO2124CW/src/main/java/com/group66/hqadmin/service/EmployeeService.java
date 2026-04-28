package com.group66.hqadmin.service;

import com.group66.hqadmin.entity.Employee;
import com.group66.hqadmin.repository.EmployeeRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;

@Service
public class EmployeeService {

    private final EmployeeRepository employeeRepository;

    // Constructor injection
    public EmployeeService(EmployeeRepository employeeRepository) {
        this.employeeRepository = employeeRepository;
    }

    public String promoteEmployee(Long id) {
        Employee employee = employeeRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        LocalDate sixMonthsAgo = LocalDate.now().minusMonths(6);

        // If the start date is AFTER six months ago, they are too new.
        if (employee.getStartDate().isAfter(sixMonthsAgo)) {
            throw new IllegalArgumentException("Ineligible: Must work 6+ months");
        }
        // Check eligibility
       /* if (employee.getStartDate().isAfter(LocalDate.now().minusMonths(6))) {
            return "ineligible";
        } */

        // Perform promotion (10% raise)
        employee.setSalary(employee.getSalary() * 1.1);
        employeeRepository.save(employee);
        return "success";
    }

    public void deleteEmployee(Long id) {
        if (!employeeRepository.existsById(id)) {
            throw new RuntimeException("Employee not found with id: " + id);
        }
        employeeRepository.deleteById(id);
    }
}