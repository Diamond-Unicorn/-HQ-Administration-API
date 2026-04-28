package com.group66.hqadmin.service;

import com.group66.hqadmin.entity.Employee;
import com.group66.hqadmin.repository.EmployeeRepository;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
public class EmployeeServiceTest {

    @Mock
    private EmployeeRepository employeeRepository;

    @InjectMocks
    private EmployeeService employeeService;

    @Test
    @DisplayName("Promote: Should throw Exception when employee does not exist")
    void testPromoteEmployeeNotFound() {
        // Arrange: ID 999 doesn't exist in DB
        when(employeeRepository.findById(999L)).thenReturn(Optional.empty());

        // Act & Assert
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            employeeService.promoteEmployee(999L);
        });

        assertTrue(exception.getMessage().contains("not found"));
        verify(employeeRepository, never()).save(any());
    }

    @Test
    @DisplayName("Promote: Should throw Exception if tenure is less than 6 months")
    void testPromoteIneligibleTenure() {
        // Arrange: Employee started yesterday
        Employee newHire = new Employee();
        newHire.setId(1L);
        newHire.setStartDate(LocalDate.now().minusDays(1));
        newHire.setSalary(50000.0);

        when(employeeRepository.findById(1L)).thenReturn(Optional.of(newHire));

        // Act & Assert
        IllegalArgumentException exception = assertThrows(IllegalArgumentException.class, () -> {
            employeeService.promoteEmployee(1L);
        });

        assertEquals("Ineligible: Must work 6+ months", exception.getMessage());
        verify(employeeRepository, never()).save(any());
    }

    @Test
    @DisplayName("Promote: Should increase salary by 10% for eligible employee")
    void testPromoteSuccess() {
        // Arrange: Employee started a year ago
        Employee veteran = new Employee();
        veteran.setId(2L);
        veteran.setStartDate(LocalDate.now().minusYears(1));
        veteran.setSalary(100000.0);

        when(employeeRepository.findById(2L)).thenReturn(Optional.of(veteran));
        when(employeeRepository.save(any(Employee.class))).thenReturn(veteran);

        // Act
        employeeService.promoteEmployee(2L);

        // Assert: 100k + 10% = 110k
        assertEquals(110000.0, veteran.getSalary(), 0.001);
        verify(employeeRepository, times(1)).save(veteran);
    }
}