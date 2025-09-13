package com.MarryMate.models;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * Base User class for the Marry Mate Wedding Planning System
 * Contains common attributes and behaviors for all user types
 * 
 * Current Date and Time: 2025-05-05 05:57:17
 * Current User: IT24102137
 */
public class User {
    
    // Common attributes for all user types
    private String userId;
    private String username;
    private String password;
    private String email;
    private String fullName;
    private String phoneNumber;
    private String address;
    private String profilePictureURL;
    private String role;
    private String registrationDate;
    private String lastLogin;
    private String accountStatus;  // active, inactive, suspended, pending
    private int failedLoginAttempts;
    private String updatedAt;
    private String updatedBy;
    
    // Default constructor
    public User() {
        this.accountStatus = "active";
        this.failedLoginAttempts = 0;
        this.registrationDate = getCurrentDateTime();
        this.lastLogin = getCurrentDateTime();
        this.updatedAt = getCurrentDateTime();
        this.profilePictureURL = "/assets/images/profiles/default-profile.jpg";
    }
    
    // Parameterized constructor
    public User(String userId, String username, String password, String email, 
                String fullName, String phoneNumber, String role) {
        this();
        this.userId = userId;
        this.username = username;
        this.password = password;
        this.email = email;
        this.fullName = fullName;
        this.phoneNumber = phoneNumber;
        this.role = role;
    }
    
    // Extended parameterized constructor with all fields
    public User(String userId, String username, String password, String email, 
                String fullName, String phoneNumber, String address, String profilePictureURL, 
                String role, String accountStatus) {
        this(userId, username, password, email, fullName, phoneNumber, role);
        this.address = address;
        
        if (profilePictureURL != null && !profilePictureURL.isEmpty()) {
            this.profilePictureURL = profilePictureURL;
        }
        
        if (accountStatus != null && !accountStatus.isEmpty()) {
            this.accountStatus = accountStatus;
        }
    }
    
    // Getters and setters - encapsulation
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public String getPassword() {
        return password;
    }
    
    public void setPassword(String password) {
        this.password = password;
    }
    
    public String getEmail() {
        return email;
    }
    
    public void setEmail(String email) {
        this.email = email;
    }
    
    public String getFullName() {
        return fullName;
    }
    
    public void setFullName(String fullName) {
        this.fullName = fullName;
    }
    
    public String getPhoneNumber() {
        return phoneNumber;
    }
    
    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }
    
    public String getAddress() {
        return address;
    }
    
    public void setAddress(String address) {
        this.address = address;
    }
    
    public String getProfilePictureURL() {
        return profilePictureURL;
    }
    
    public void setProfilePictureURL(String profilePictureURL) {
        this.profilePictureURL = profilePictureURL;
    }
    
    public String getRole() {
        return role;
    }
    
    public void setRole(String role) {
        this.role = role;
    }
    
    public String getRegistrationDate() {
        return registrationDate;
    }
    
    public void setRegistrationDate(String registrationDate) {
        this.registrationDate = registrationDate;
    }
    
    public String getLastLogin() {
        return lastLogin;
    }
    
    public void setLastLogin(String lastLogin) {
        this.lastLogin = lastLogin;
    }
    
    public String getAccountStatus() {
        return accountStatus;
    }
    
    public void setAccountStatus(String accountStatus) {
        this.accountStatus = accountStatus;
        // Update the updatedAt timestamp when status changes
        this.updatedAt = getCurrentDateTime();
    }
    
    public int getFailedLoginAttempts() {
        return failedLoginAttempts;
    }
    
    public void setFailedLoginAttempts(int failedLoginAttempts) {
        this.failedLoginAttempts = failedLoginAttempts;
    }
    
    public void incrementFailedLoginAttempts() {
        this.failedLoginAttempts++;
    }
    
    public void resetFailedLoginAttempts() {
        this.failedLoginAttempts = 0;
    }
    
    public String getUpdatedAt() {
        return updatedAt;
    }
    
    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }
    
    public String getUpdatedBy() {
        return updatedBy;
    }
    
    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }
    
    // For backward compatibility with code that uses isActive()
    public boolean isActive() {
        return "active".equals(this.accountStatus);
    }
    
    public void setActive(boolean active) {
        this.accountStatus = active ? "active" : "inactive";
    }
    
    // Common functionality for all user types
    public boolean authenticate(String enteredPassword) {
        return this.password.equals(enteredPassword);
    }
    
    // Method to check if a user has specific role - polymorphism
    public boolean hasRole(String roleName) {
        return this.role.equalsIgnoreCase(roleName);
    }
    
    // Helper method to get current date time string
    private String getCurrentDateTime() {
        return LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    }
    
    @Override
    public String toString() {
        return "User{" + 
                "userId='" + userId + '\'' +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                ", fullName='" + fullName + '\'' +
                ", role='" + role + '\'' +
                ", accountStatus='" + accountStatus + '\'' +
                '}';
    }
}