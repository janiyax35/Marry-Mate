package com.MarryMate.models;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * ServiceBooking model class - represents a service booked within a booking
 * Created: 2025-05-13 06:41:15
 * Updated: 2025-05-13 11:49:53
 * Author: IT24102083
 */
public class ServiceBooking {
    private String serviceBookingId;
    private String serviceId;
    private String vendorId;
    private String serviceName;
    private BigDecimal basePrice;
    private int hours;
    private int baseHours;
    private int additionalHours;
    private BigDecimal additionalHoursPrice;
    private int guestCount;
    private int baseGuestCount;
    private int additionalGuests;
    private BigDecimal additionalGuestsPrice;
    private String priceModel;
    private List<ServiceOption> selectedOptions = new ArrayList<>();
    private BigDecimal serviceTotal;
    private String specialNotes;
    private String status = "pending"; // Default status for new service bookings
    private String lastUpdated; // Timestamp when status was last updated
    
    // Getters and Setters
    public String getServiceBookingId() {
        return serviceBookingId;
    }

    public void setServiceBookingId(String serviceBookingId) {
        this.serviceBookingId = serviceBookingId;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public String getVendorId() {
        return vendorId;
    }

    public void setVendorId(String vendorId) {
        this.vendorId = vendorId;
    }

    public String getServiceName() {
        return serviceName;
    }

    public void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    public BigDecimal getBasePrice() {
        return basePrice;
    }

    public void setBasePrice(BigDecimal basePrice) {
        this.basePrice = basePrice;
    }

    public int getHours() {
        return hours;
    }

    public void setHours(int hours) {
        this.hours = hours;
    }

    public int getBaseHours() {
        return baseHours;
    }

    public void setBaseHours(int baseHours) {
        this.baseHours = baseHours;
    }

    public int getAdditionalHours() {
        return additionalHours;
    }

    public void setAdditionalHours(int additionalHours) {
        this.additionalHours = additionalHours;
    }

    public BigDecimal getAdditionalHoursPrice() {
        return additionalHoursPrice;
    }

    public void setAdditionalHoursPrice(BigDecimal additionalHoursPrice) {
        this.additionalHoursPrice = additionalHoursPrice;
    }

    public int getGuestCount() {
        return guestCount;
    }

    public void setGuestCount(int guestCount) {
        this.guestCount = guestCount;
    }

    public int getBaseGuestCount() {
        return baseGuestCount;
    }

    public void setBaseGuestCount(int baseGuestCount) {
        this.baseGuestCount = baseGuestCount;
    }

    public int getAdditionalGuests() {
        return additionalGuests;
    }

    public void setAdditionalGuests(int additionalGuests) {
        this.additionalGuests = additionalGuests;
    }

    public BigDecimal getAdditionalGuestsPrice() {
        return additionalGuestsPrice;
    }

    public void setAdditionalGuestsPrice(BigDecimal additionalGuestsPrice) {
        this.additionalGuestsPrice = additionalGuestsPrice;
    }

    public String getPriceModel() {
        return priceModel;
    }

    public void setPriceModel(String priceModel) {
        this.priceModel = priceModel;
    }

    public List<ServiceOption> getSelectedOptions() {
        return selectedOptions;
    }

    public void setSelectedOptions(List<ServiceOption> selectedOptions) {
        this.selectedOptions = selectedOptions;
    }
    
    public void addSelectedOption(ServiceOption option) {
        if (this.selectedOptions == null) {
            this.selectedOptions = new ArrayList<>();
        }
        this.selectedOptions.add(option);
    }

    public BigDecimal getServiceTotal() {
        return serviceTotal;
    }

    public void setServiceTotal(BigDecimal serviceTotal) {
        this.serviceTotal = serviceTotal;
    }

    public String getSpecialNotes() {
        return specialNotes;
    }

    public void setSpecialNotes(String specialNotes) {
        this.specialNotes = specialNotes;
    }
    
    /**
     * Get the status of this service booking
     * @return status string ("pending", "confirmed", or "cancelled")
     */
    public String getStatus() {
        return status;
    }
    
    /**
     * Set the status of this service booking
     * @param status the new status value
     */
    public void setStatus(String status) {
        this.status = status;
    }
    
    /**
     * Get the timestamp when this service booking was last updated
     * @return last updated timestamp
     */
    public String getLastUpdated() {
        return lastUpdated;
    }
    
    /**
     * Set the timestamp when this service booking was last updated
     * @param lastUpdated the timestamp string
     */
    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
}