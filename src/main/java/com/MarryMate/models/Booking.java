package com.MarryMate.models;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * Booking model class for Marry Mate Wedding Planning System
 * Created: 2025-05-13 06:40:23
 * Author: IT24102083
 */
public class Booking {
    private String bookingId;
    private String userId;
    private String weddingDate;
    private String bookingDate;
    private String eventLocation;
    private String eventStartTime;
    private String eventEndTime;
    private int totalGuestCount;
    private int totalHours;
    private String specialRequirements;
    private String status;
    private BigDecimal totalBookingPrice;
    private boolean depositPaid;
    private BigDecimal depositAmount;
    private String paymentStatus;
    private boolean contractSigned;
    private String createdBy;
    private String lastUpdated;
    private List<ServiceBooking> bookedServices = new ArrayList<>();
    
    // Client details - not in JSON but useful for UI
    private String clientName;
    private String clientEmail;
    private String clientPhone;
    
    // Default constructor
    public Booking() {
    }
    
    // Constructor with essential fields
    public Booking(String bookingId, String userId, String weddingDate, String status) {
        this.bookingId = bookingId;
        this.userId = userId;
        this.weddingDate = weddingDate;
        this.status = status;
    }
    
    // Getters and Setters
    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getWeddingDate() {
        return weddingDate;
    }

    public void setWeddingDate(String weddingDate) {
        this.weddingDate = weddingDate;
    }

    public String getBookingDate() {
        return bookingDate;
    }

    public void setBookingDate(String bookingDate) {
        this.bookingDate = bookingDate;
    }

    public String getEventLocation() {
        return eventLocation;
    }

    public void setEventLocation(String eventLocation) {
        this.eventLocation = eventLocation;
    }

    public String getEventStartTime() {
        return eventStartTime;
    }

    public void setEventStartTime(String eventStartTime) {
        this.eventStartTime = eventStartTime;
    }

    public String getEventEndTime() {
        return eventEndTime;
    }

    public void setEventEndTime(String eventEndTime) {
        this.eventEndTime = eventEndTime;
    }

    public int getTotalGuestCount() {
        return totalGuestCount;
    }

    public void setTotalGuestCount(int totalGuestCount) {
        this.totalGuestCount = totalGuestCount;
    }

    public int getTotalHours() {
        return totalHours;
    }

    public void setTotalHours(int totalHours) {
        this.totalHours = totalHours;
    }

    public String getSpecialRequirements() {
        return specialRequirements;
    }

    public void setSpecialRequirements(String specialRequirements) {
        this.specialRequirements = specialRequirements;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public BigDecimal getTotalBookingPrice() {
        return totalBookingPrice;
    }

    public void setTotalBookingPrice(BigDecimal totalBookingPrice) {
        this.totalBookingPrice = totalBookingPrice;
    }

    public boolean isDepositPaid() {
        return depositPaid;
    }

    public void setDepositPaid(boolean depositPaid) {
        this.depositPaid = depositPaid;
    }

    public BigDecimal getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(BigDecimal depositAmount) {
        this.depositAmount = depositAmount;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public boolean isContractSigned() {
        return contractSigned;
    }

    public void setContractSigned(boolean contractSigned) {
        this.contractSigned = contractSigned;
    }

    public String getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(String createdBy) {
        this.createdBy = createdBy;
    }

    public String getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public List<ServiceBooking> getBookedServices() {
        return bookedServices;
    }

    public void setBookedServices(List<ServiceBooking> bookedServices) {
        this.bookedServices = bookedServices;
    }
    
    public void addBookedService(ServiceBooking serviceBooking) {
        if (this.bookedServices == null) {
            this.bookedServices = new ArrayList<>();
        }
        this.bookedServices.add(serviceBooking);
    }

    public String getClientName() {
        return clientName;
    }

    public void setClientName(String clientName) {
        this.clientName = clientName;
    }

    public String getClientEmail() {
        return clientEmail;
    }

    public void setClientEmail(String clientEmail) {
        this.clientEmail = clientEmail;
    }

    public String getClientPhone() {
        return clientPhone;
    }

    public void setClientPhone(String clientPhone) {
        this.clientPhone = clientPhone;
    }
    
    // Helper method to get service name (using the first booked service for simplicity)
    public String getServiceName() {
        if (bookedServices != null && !bookedServices.isEmpty()) {
            return bookedServices.get(0).getServiceName();
        }
        return null;
    }
    
    // For reporting purposes - gets total price accounting for possible null
    public BigDecimal getTotalPrice() {
        return totalBookingPrice != null ? totalBookingPrice : BigDecimal.ZERO;
    }
    
    @Override
    public String toString() {
        return "Booking{" +
                "bookingId='" + bookingId + '\'' +
                ", userId='" + userId + '\'' +
                ", weddingDate='" + weddingDate + '\'' +
                ", status='" + status + '\'' +
                ", totalBookingPrice=" + totalBookingPrice +
                '}';
    }
}