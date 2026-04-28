package com.group66.hqadmin.repository;

import com.group66.hqadmin.entity.Assignment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface AssignmentRepository extends JpaRepository<Assignment, Long> {
    // Standard CRUD methods are inherited automatically.

    // Find all assignments for a specific employee ID
    List<Assignment> findByEmployeeId(Long employeeId);

    // Find all assignments for a specific department ID
    List<Assignment> findByDepartmentId(Long departmentId);
}
