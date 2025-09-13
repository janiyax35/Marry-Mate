package com.MarryMate.models;

/**
 * RegularUser class for wedding planning clients
 * Extends the base User class with client-specific attributes
 * 
 * Current Date and Time: 2025-05-05 05:57:17
 * Current User: IT24102137
 */
public class RegularUser extends User {

    // Default constructor
    public RegularUser() {
        super();
        setRole("user");
    }
    
    // Basic parameterized constructor
    public RegularUser(String userId, String username, String password, String email, 
                      String fullName, String phoneNumber, String address) {
        super(userId, username, password, email, fullName, phoneNumber, "user");
        setAddress(address);
    }
    
    // Full parameterized constructor
    public RegularUser(String userId, String username, String password, String email, 
                      String fullName, String phoneNumber, String address, 
                      String profilePictureURL, String accountStatus) {
        super(userId, username, password, email, fullName, phoneNumber, address, 
               profilePictureURL, "user", accountStatus);
    }
    
    // Regular user specific functionality
    public boolean isEligibleForLoyaltyDiscount() {
        // This would check if user is eligible for a loyalty discount
        // Implementation would depend on business rules
        return false;
    }
    
    @Override
    public String toString() {
        return "RegularUser{" +
                "userId='" + getUserId() + '\'' +
                ", username='" + getUsername() + '\'' +
                ", email='" + getEmail() + '\'' +
                ", fullName='" + getFullName() + '\'' +
                ", address='" + getAddress() + '\'' +
                ", accountStatus='" + getAccountStatus() + '\'' +
                '}';
    }
}