package com.group66.hqadmin.repository;

import com.group66.hqadmin.entity.Department;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DepartmentRepository extends JpaRepository<Department, Long> {
    // Standard CRUD methods are inherited automatically.

    // Optional: Custom finder to look up a department by name
    Optional<Department> findByName(String name);
}

