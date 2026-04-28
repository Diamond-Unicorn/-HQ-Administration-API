package com.group66.hqadmin.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;

import java.time.LocalDate;
import java.util.List;

@Entity
public class Employee {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotNull
    private String name;

    private String contractType;
    private LocalDate startDate;
    private double salary;

    private String email;


    @ManyToOne
    @JsonIgnoreProperties({"employee", "department"}) // prevents infinite json output loop
    @JoinColumn(name = "assignment_id")
    private Assignment assignment;

    @Column(name = "address")
    private String address;

    @ManyToOne // This tells Hibernate this is an entity not a string
    @JsonIgnoreProperties("assignments")
    //@JsonBackReference // sets this as the child half. prevents infinite loop in json output
    //@JsonIgnoreProperties("employees") // prevents infinnte json loop on logging in
    @JoinColumn(name = "department_id") // This creates the FK in MySQL table
    private Department department;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getContractType() {
        return contractType;
    }

    public void setContractType(String contractType) {
        this.contractType = contractType;
    }

    public LocalDate getStartDate() {
        return startDate;
    }

    public void setStartDate(LocalDate startDate) {
        this.startDate = startDate;
    }

    public double getSalary() {
        return salary;
    }

    public void setSalary(double salary) {
        this.salary = salary;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public Department getDepartment() {
        return department;
    }

    public void setDepartment(Department department) {
        this.department = department;
    }


    public Assignment getAssignment() {
        return assignment;
    }

    public void setAssignment(Assignment realAsgn) {
        this.assignment = realAsgn;
    }

    // Regex for: characters + '@' + characters + '.com'
    @Pattern(regexp = "^[^@]+@[^@]+\\.com$", message = "Email must contain '@' and end with '.com'")
    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }
}
