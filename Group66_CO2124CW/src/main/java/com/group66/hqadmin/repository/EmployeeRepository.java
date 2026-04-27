package com.group66.hqadmin.repository;

import com.group66.hqadmin.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    // For filtering by department name
    List<Employee> findByAssignmentDepartmentName(String name);
    List<Employee> findByNameContainingIgnoreCase(String name);
    List<Employee> findByAssignment_Department_Name(String name);
}
