package com.MarryMate.models;

import java.util.ArrayList;
import java.util.List;

/**
 * Model class representing a vendor service with dynamic pricing
 * 
 * Current Date and Time: 2025-05-11 08:37:02
 * Current User: IT24102137
 */
public class VendorService {
    private String id;
    private String vendorId;
    private String name;
    private String category;
    private String description;
    private double basePrice;
    private String status;
    private String iconImage;
    private String serviceBackgroundImage;
    private String pricingModel; // "hourly", "perGuest", "fixed"
    
    // Pricing parameters
    private int baseHours;
    private double additionalHourPrice;
    private int baseGuestCount;
    private double additionalGuestPrice;
    private int guestIncrement;
    
    // Options and metadata
    private List<ServiceOption> customizationOptions;
    private boolean featured;
    private String seoKeywords;
    private String createdAt;
    private String updatedAt;
    private List<String> reviewIds;
    
    // Default constructor
    public VendorService() {
        this.customizationOptions = new ArrayList<>();
        this.reviewIds = new ArrayList<>();
    }
    
    // Constructor with required fields
    public VendorService(String id, String vendorId, String name, String category, 
                        String description, double basePrice, String status) {
        this.id = id;
        this.vendorId = vendorId;
        this.name = name;
        this.category = category;
        this.description = description;
        this.basePrice = basePrice;
        this.status = status;
        this.customizationOptions = new ArrayList<>();
        this.reviewIds = new ArrayList<>();
    }
    
    // Full constructor
    public VendorService(String id, String vendorId, String name, String category, 
                        String description, double basePrice, String status, 
                        String iconImage, String serviceBackgroundImage, 
                        String pricingModel, int baseHours, double additionalHourPrice,
                        int baseGuestCount, double additionalGuestPrice, int guestIncrement,
                        List<ServiceOption> customizationOptions, boolean featured,
                        String seoKeywords, String createdAt, String updatedAt,
                        List<String> reviewIds) {
        this.id = id;
        this.vendorId = vendorId;
        this.name = name;
        this.category = category;
        this.description = description;
        this.basePrice = basePrice;
        this.status = status;
        this.iconImage = iconImage;
        this.serviceBackgroundImage = serviceBackgroundImage;
        this.pricingModel = pricingModel;
        this.baseHours = baseHours;
        this.additionalHourPrice = additionalHourPrice;
        this.baseGuestCount = baseGuestCount;
        this.additionalGuestPrice = additionalGuestPrice;
        this.guestIncrement = guestIncrement;
        this.customizationOptions = customizationOptions != null ? 
                                   customizationOptions : new ArrayList<>();
        this.featured = featured;
        this.seoKeywords = seoKeywords;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.reviewIds = reviewIds != null ? reviewIds : new ArrayList<>();
    }
    
    // Dynamic price calculation methods
    
    /**
     * Calculate price based on guest count and hours
     * @param guestCount Number of guests
     * @param hours Number of hours
     * @return Calculated price
     */
    public double calculatePrice(int guestCount, int hours) {
        double totalPrice = basePrice;
        
        if ("hourly".equals(pricingModel) && hours > baseHours) {
            totalPrice += (hours - baseHours) * additionalHourPrice;
        }
        
        if ("perGuest".equals(pricingModel) && guestCount > baseGuestCount) {
            int additionalGuests = guestCount - baseGuestCount;
            int increments = (int) Math.ceil((double) additionalGuests / guestIncrement);
            totalPrice += increments * additionalGuestPrice;
        }
        
        return totalPrice;
    }
    
    /**
     * Calculate additional hours price
     * @param hours Total hours
     * @return Additional hours price
     */
    public double calculateAdditionalHoursPrice(int hours) {
        if (hours <= baseHours || !"hourly".equals(pricingModel)) {
            return 0.0;
        }
        return (hours - baseHours) * additionalHourPrice;
    }
    
    /**
     * Calculate additional guests price
     * @param guestCount Total guest count
     * @return Additional guests price
     */
    public double calculateAdditionalGuestsPrice(int guestCount) {
        if (guestCount <= baseGuestCount || !"perGuest".equals(pricingModel)) {
            return 0.0;
        }
        int additionalGuests = guestCount - baseGuestCount;
        int increments = (int) Math.ceil((double) additionalGuests / guestIncrement);
        return increments * additionalGuestPrice;
    }
    
    /**
     * Calculate total price including selected options
     * @param guestCount Number of guests
     * @param hours Number of hours
     * @param selectedOptionIndices Indices of selected options
     * @return Total price with options
     */
    public double calculateTotalPrice(int guestCount, int hours, List<Integer> selectedOptionIndices) {
        double totalPrice = calculatePrice(guestCount, hours);
        
        if (selectedOptionIndices != null && customizationOptions != null) {
            for (int index : selectedOptionIndices) {
                if (index >= 0 && index < customizationOptions.size()) {
                    totalPrice += customizationOptions.get(index).getPrice();
                }
            }
        }
        
        return totalPrice;
    }
    
    /**
     * Get pricing description based on model
     * @return Human-readable pricing description
     */
    public String getPricingDescription() {
        StringBuilder description = new StringBuilder(String.format("$%.2f", basePrice));
        
        if ("hourly".equals(pricingModel)) {
            description.append(" for ").append(baseHours).append(" hours");
            if (additionalHourPrice > 0) {
                description.append(String.format(" (+$%.2f per additional hour)", additionalHourPrice));
            }
        } else if ("perGuest".equals(pricingModel)) {
            description.append(" for up to ").append(baseGuestCount).append(" guests");
            if (additionalGuestPrice > 0) {
                description.append(String.format(" (+$%.2f per additional %d guests)", 
                    additionalGuestPrice, guestIncrement));
            }
        }
        
        return description.toString();
    }
    
    // Add a review ID to the service
    public void addReviewId(String reviewId) {
        if (reviewIds == null) {
            reviewIds = new ArrayList<>();
        }
        if (!reviewIds.contains(reviewId)) {
            reviewIds.add(reviewId);
        }
    }
    
    // Add an option to the service
    public void addCustomizationOption(ServiceOption option) {
        if (customizationOptions == null) {
            customizationOptions = new ArrayList<>();
        }
        customizationOptions.add(option);
    }
    
    // String representation of the service
    @Override
    public String toString() {
        return "VendorService{" +
               "id='" + id + '\'' +
               ", vendorId='" + vendorId + '\'' +
               ", name='" + name + '\'' +
               ", category='" + category + '\'' +
               ", basePrice=" + basePrice +
               ", pricingModel='" + pricingModel + '\'' +
               ", status='" + status + '\'' +
               '}';
    }
    
    // Getters and Setters
    
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getVendorId() {
        return vendorId;
    }

    public void setVendorId(String vendorId) {
        this.vendorId = vendorId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public double getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(double basePrice) {
        this.basePrice = basePrice;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getIconImage() {
        return iconImage;
    }

    public void setIconImage(String iconImage) {
        this.iconImage = iconImage;
    }

    public String getServiceBackgroundImage() {
        return serviceBackgroundImage;
    }

    public void setServiceBackgroundImage(String serviceBackgroundImage) {
        this.serviceBackgroundImage = serviceBackgroundImage;
    }

    public String getPricingModel() {
        return pricingModel;
    }

    public void setPricingModel(String pricingModel) {
        this.pricingModel = pricingModel;
    }

    public int getBaseHours() {
        return baseHours;
    }

    public void setBaseHours(int baseHours) {
        this.baseHours = baseHours;
    }

    public double getAdditionalHourPrice() {
        return additionalHourPrice;
    }

    public void setAdditionalHourPrice(double additionalHourPrice) {
        this.additionalHourPrice = additionalHourPrice;
    }

    public int getBaseGuestCount() {
        return baseGuestCount;
    }

    public void setBaseGuestCount(int baseGuestCount) {
        this.baseGuestCount = baseGuestCount;
    }

    public double getAdditionalGuestPrice() {
        return additionalGuestPrice;
    }

    public void setAdditionalGuestPrice(double additionalGuestPrice) {
        this.additionalGuestPrice = additionalGuestPrice;
    }

    public int getGuestIncrement() {
        return guestIncrement;
    }

    public void setGuestIncrement(int guestIncrement) {
        this.guestIncrement = guestIncrement;
    }

    public List<ServiceOption> getCustomizationOptions() {
        return customizationOptions;
    }

    public void setCustomizationOptions(List<ServiceOption> customizationOptions) {
        this.customizationOptions = customizationOptions;
    }

    public boolean isFeatured() {
        return featured;
    }

    public void setFeatured(boolean featured) {
        this.featured = featured;
    }

    public String getSeoKeywords() {
        return seoKeywords;
    }

    public void setSeoKeywords(String seoKeywords) {
        this.seoKeywords = seoKeywords;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    public List<String> getReviewIds() {
        return reviewIds;
    }

    public void setReviewIds(List<String> reviewIds) {
        this.reviewIds = reviewIds;
    }
    
    /**
     * Nested class for service customization options
     */
    public static class ServiceOption {
        private String name;
        private double price;
        private String description;
        
        // Default constructor
        public ServiceOption() {}
        
        // Constructor with fields
        public ServiceOption(String name, double price, String description) {
            this.name = name;
            this.price = price;
            this.description = description;
        }
        
        // String representation
        @Override
        public String toString() {
            return name + " ($" + price + ")";
        }
        
        // Getters and Setters
        
        public String getName() {
            return name;
        }
        
        public void setName(String name) {
            this.name = name;
        }
        
        public double getPrice() {
            return price;
        }
        
        public void setPrice(double price) {
            this.price = price;
        }
        
        public String getDescription() {
            return description;
        }
        
        public void setDescription(String description) {
            this.description = description;
        }
    }
}