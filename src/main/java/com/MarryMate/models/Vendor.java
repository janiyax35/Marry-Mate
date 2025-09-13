package com.MarryMate.models;

import java.util.ArrayList;
import java.util.List;

/**
 * Vendor class for wedding planning service providers
 * Extends the base User class with vendor-specific attributes
 * 
 * Current Date and Time: 2025-05-11 14:03:51
 * Current User: IT24102137
 */
public class Vendor extends User {
    
    private List<String> serviceIds;
    private String businessName;
    private String contactName;
    private List<String> categories;
    private String description;
    private String servicesOffered;
    private String priceRange;
    private String websiteUrl;
    private String coverPhotoUrl;
    private double rating;
    private int reviewCount;
    private boolean featured;
    private String memberSince;
    
    // Default constructor
    public Vendor() {
        super();
        setRole("vendor");
        this.serviceIds = new ArrayList<>();
        this.categories = new ArrayList<>();
        this.rating = 0.0;
        this.reviewCount = 0;
        this.featured = false;
        this.memberSince = getRegistrationDate();
    }
    
    // Basic parameterized constructor
    public Vendor(String userId, String username, String password, String email, 
                 String fullName, String phoneNumber, String businessName) {
        super(userId, username, password, email, fullName, phoneNumber, "vendor");
        this.businessName = businessName;
        this.serviceIds = new ArrayList<>();
        this.categories = new ArrayList<>();
        this.rating = 0.0;
        this.reviewCount = 0;
        this.featured = false;
        this.memberSince = getRegistrationDate();
    }
    
    // Extended parameterized constructor
    public Vendor(String userId, String username, String password, String email, 
                 String fullName, String phoneNumber, String address, String businessName,
                 String contactName, List<String> categories, String description) {
        super(userId, username, password, email, fullName, phoneNumber, address, 
             null, "vendor", "active");
        this.businessName = businessName;
        this.contactName = contactName;
        this.categories = categories;
        this.description = description;
        this.serviceIds = new ArrayList<>();
        this.rating = 0.0;
        this.reviewCount = 0;
        this.featured = false;
        this.memberSince = getRegistrationDate();
    }
    
    // Full parameterized constructor
    public Vendor(String userId, String username, String password, String email, 
                 String fullName, String phoneNumber, String address, String profilePictureURL,
                 List<String> serviceIds, String businessName, String contactName, 
                 List<String> categories, String description, String servicesOffered,
                 String priceRange, String websiteUrl, String coverPhotoUrl, 
                 double rating, int reviewCount, boolean featured) {
        super(userId, username, password, email, fullName, phoneNumber, address, 
             profilePictureURL, "vendor", "active");
        this.serviceIds = serviceIds;
        this.businessName = businessName;
        this.contactName = contactName;
        this.categories = categories;
        this.description = description;
        this.servicesOffered = servicesOffered;
        this.priceRange = priceRange;
        this.websiteUrl = websiteUrl;
        this.coverPhotoUrl = coverPhotoUrl;
        this.rating = rating;
        this.reviewCount = reviewCount;
        this.featured = featured;
        this.memberSince = getRegistrationDate();
    }
    
    // Getters and setters
    public List<String> getServiceIds() {
        return serviceIds;
    }
    
    public void setServiceIds(List<String> serviceIds) {
        this.serviceIds = serviceIds;
    }
    
    public void addServiceId(String serviceId) {
        if (this.serviceIds == null) {
            this.serviceIds = new ArrayList<>();
        }
        this.serviceIds.add(serviceId);
    }
    
    public String getBusinessName() {
        return businessName;
    }
    
    public void setBusinessName(String businessName) {
        this.businessName = businessName;
    }
    
    public String getContactName() {
        return contactName;
    }
    
    public void setContactName(String contactName) {
        this.contactName = contactName;
    }
    
    public List<String> getCategories() {
        return categories;
    }
    
    public void setCategories(List<String> categories) {
        this.categories = categories;
    }
    
    public void addCategory(String category) {
        if (this.categories == null) {
            this.categories = new ArrayList<>();
        }
        this.categories.add(category);
    }
    
    public boolean hasCategory(String category) {
        return this.categories != null && this.categories.contains(category);
    }
    
    public String getDescription() {
        return description;
    }
    
    public void setDescription(String description) {
        this.description = description;
    }
    
    public String getServicesOffered() {
        return servicesOffered;
    }
    
    public void setServicesOffered(String servicesOffered) {
        this.servicesOffered = servicesOffered;
    }
    
    public String getPriceRange() {
        return priceRange;
    }
    
    public void setPriceRange(String priceRange) {
        this.priceRange = priceRange;
    }
    
    public String getWebsiteUrl() {
        return websiteUrl;
    }
    
    public void setWebsiteUrl(String websiteUrl) {
        this.websiteUrl = websiteUrl;
    }
    
    public String getCoverPhotoUrl() {
        return coverPhotoUrl;
    }
    
    public void setCoverPhotoUrl(String coverPhotoUrl) {
        this.coverPhotoUrl = coverPhotoUrl;
    }
    
    public double getRating() {
        return rating;
    }
    
    public void setRating(double rating) {
        this.rating = rating;
    }
    
    public int getReviewCount() {
        return reviewCount;
    }
    
    public void setReviewCount(int reviewCount) {
        this.reviewCount = reviewCount;
    }
    
    public boolean isFeatured() {
        return featured;
    }
    
    public void setFeatured(boolean featured) {
        this.featured = featured;
    }
    
    public String getMemberSince() {
        return memberSince;
    }
    
    public void setMemberSince(String memberSince) {
        this.memberSince = memberSince;
    }
    
    // For backward compatibility with JSON structure
    public String getPhone() {
        return getPhoneNumber();
    }
    
    public void setPhone(String phone) {
        setPhoneNumber(phone);
    }
    
    public String getProfilePictureUrl() {
        return getProfilePictureURL();
    }
    
    public void setProfilePictureUrl(String profilePictureUrl) {
        setProfilePictureURL(profilePictureUrl);
    }
    
    public String getStatus() {
        return getAccountStatus();
    }
    
    public void setStatus(String status) {
        setAccountStatus(status);
    }
    
    // Vendor-specific methods
    public boolean isTopRated() {
        return this.rating >= 4.5 && this.reviewCount >= 50;
    }
    
    public boolean hasActiveServices() {
        return this.serviceIds != null && !this.serviceIds.isEmpty();
    }
    
    @Override
    public String toString() {
        return "Vendor{" +
                "userId='" + getUserId() + '\'' +
                ", username='" + getUsername() + '\'' +
                ", email='" + getEmail() + '\'' +
                ", businessName='" + businessName + '\'' +
                ", contactName='" + contactName + '\'' +
                ", categories=" + categories +
                ", rating=" + rating +
                ", reviewCount=" + reviewCount +
                ", status='" + getAccountStatus() + '\'' +
                ", featured=" + featured +
                '}';
    }
}