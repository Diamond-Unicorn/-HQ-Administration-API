package com.group66.hqadmin.service;

import com.group66.hqadmin.entity.Employee;
import com.group66.hqadmin.repository.EmployeeRepository;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.when;

class EmployeeServiceTest {

    @Mock
    private EmployeeRepository employeeRepository;

    @InjectMocks
    private EmployeeService employeeService;

    public EmployeeServiceTest() {
        MockitoAnnotations.openMocks(this); // initialize @Mock and @InjectMocks
    }

    @Test
    void shouldThrowExceptionWhenPromotingNonExistingEmployee() {
        // Arrange
        when(employeeRepository.findById(1L)).thenReturn(Optional.empty());

        // Act & Assert
        assertThrows(RuntimeException.class,
                () -> employeeService.promoteEmployee(1L));
    }
}
