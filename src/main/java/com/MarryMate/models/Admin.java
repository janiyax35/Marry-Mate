package com.MarryMate.models;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.ArrayList;

/**
 * Admin class for wedding planning system administrators
 * Extends the base User class with admin-specific attributes
 * 
 * Current Date and Time: 2025-05-05 08:12:25
 * Current User: IT24102137
 */
public class Admin extends User {
    
    private boolean isSuperAdmin;
    private List<String> permissions;
    private String department;
    private String position;
    private String createdBy;
    
    // Default constructor
    public Admin() {
        super();
        setRole("admin");
        this.permissions = new ArrayList<>();
    }
    
    // Basic constructor
    public Admin(String userId, String username, String password, String email, 
                String fullName, String role, boolean isSuperAdmin) {
        super(userId, username, password, email, fullName, "", role);
        this.isSuperAdmin = isSuperAdmin;
        this.permissions = new ArrayList<>();
    }
    
    // Full constructor
    public Admin(String userId, String username, String password, String email, 
                String fullName, String phoneNumber, String role, boolean isSuperAdmin, 
                List<String> permissions) {
        super(userId, username, password, email, fullName, phoneNumber, role);
        this.isSuperAdmin = isSuperAdmin;
        this.permissions = permissions;
    }
    
    // Getters and setters
    public boolean isSuperAdmin() {
        return isSuperAdmin;
    }
    
    public void setSuperAdmin(boolean isSuperAdmin) {
        this.isSuperAdmin = isSuperAdmin;
    }
    
    public List<String> getPermissions() {
        return permissions;
    }
    
    public void setPermissions(List<String> permissions) {
        this.permissions = permissions;
    }
    
    public void addPermission(String permission) {
        if (this.permissions == null) {
            this.permissions = new ArrayList<>();
        }
        this.permissions.add(permission);
    }
    
    public boolean hasPermission(String permission) {
        return this.permissions != null && this.permissions.contains(permission);
    }
    
    public String getDepartment() {
        return department;
    }
    
    public void setDepartment(String department) {
        this.department = department;
    }
    
    public String getPosition() {
        return position;
    }
    
    public void setPosition(String position) {
        this.position = position;
    }
    
    public String getCreatedBy() {
        return createdBy;
    }
    
    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }
    
    // Handle backwards compatibility with active boolean
    public boolean isActive() {
        return "active".equals(getAccountStatus());
    }
    
    public void setActive(boolean active) {
        setAccountStatus(active ? "active" : "inactive");
    }
    
    @Override
    public String toString() {
        return "Admin{" +
                "userId='" + getUserId() + '\'' +
                ", username='" + getUsername() + '\'' +
                ", email='" + getEmail() + '\'' +
                ", fullName='" + getFullName() + '\'' +
                ", role='" + getRole() + '\'' +
                ", isSuperAdmin=" + isSuperAdmin +
                ", accountStatus='" + getAccountStatus() + '\'' +
                '}';
    }
}