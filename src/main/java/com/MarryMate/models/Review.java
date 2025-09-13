package com.MarryMate.models;

import java.util.ArrayList;
import java.util.List;

/**
 * Model class representing a service review
 * 
 * Current Date and Time: 2025-05-11 14:49:57
 * Current User: IT24102137
 */
public class Review {
    private String reviewId;
    private String userId;
    private String vendorId;
    private String serviceId;
    private String bookingId;
    private double rating;
    private String comment;
    private String reviewDate;
    private VendorResponse vendorResponse;
    private String status;
    private int helpfulCount;
    private boolean flagged;
    private List<String> photoUrls;
    private DetailedRatings detailedRatings;
    private String userName;
    private String userPhotoUrl;
    private boolean verifiedBooking;
    private String lastUpdated;
    
    // Inner class for detailed category ratings
    public static class DetailedRatings {
        private double quality;
        private double value;
        private double responsiveness;
        private double professionalism;
        private double flexibility;
        
        // Constructor
        public DetailedRatings() {
        }
        
        // Calculate average detailed rating
        public double getAverage() {
            return (quality + value + responsiveness + professionalism + flexibility) / 5.0;
        }

        // Getters and Setters
        public double getQuality() {
            return quality;
        }

        public void setQuality(double quality) {
            this.quality = quality;
        }

        public double getValue() {
            return value;
        }

        public void setValue(double value) {
            this.value = value;
        }

        public double getResponsiveness() {
            return responsiveness;
        }

        public void setResponsiveness(double responsiveness) {
            this.responsiveness = responsiveness;
        }

        public double getProfessionalism() {
            return professionalism;
        }

        public void setProfessionalism(double professionalism) {
            this.professionalism = professionalism;
        }

        public double getFlexibility() {
            return flexibility;
        }

        public void setFlexibility(double flexibility) {
            this.flexibility = flexibility;
        }
    }
    
    // Inner class for vendor responses to reviews
    public static class VendorResponse {
        private String text;
        private String responseDate;
        
        // Constructor
        public VendorResponse() {
        }

        // Getters and Setters
        public String getText() {
            return text;
        }

        public void setText(String text) {
            this.text = text;
        }

        public String getResponseDate() {
            return responseDate;
        }

        public void setResponseDate(String responseDate) {
            this.responseDate = responseDate;
        }
    }
    
    // Constructor
    public Review() {
        this.photoUrls = new ArrayList<>();
        this.detailedRatings = new DetailedRatings();
    }
    
    // Getters and Setters
    public String getReviewId() {
        return reviewId;
    }

    public void setReviewId(String reviewId) {
        this.reviewId = reviewId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getVendorId() {
        return vendorId;
    }

    public void setVendorId(String vendorId) {
        this.vendorId = vendorId;
    }

    public String getServiceId() {
        return serviceId;
    }

    public void setServiceId(String serviceId) {
        this.serviceId = serviceId;
    }

    public String getBookingId() {
        return bookingId;
    }

    public void setBookingId(String bookingId) {
        this.bookingId = bookingId;
    }

    public double getRating() {
        return rating;
    }

    public void setRating(double rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public String getReviewDate() {
        return reviewDate;
    }

    public void setReviewDate(String reviewDate) {
        this.reviewDate = reviewDate;
    }

    public VendorResponse getVendorResponse() {
        return vendorResponse;
    }

    public void setVendorResponse(VendorResponse vendorResponse) {
        this.vendorResponse = vendorResponse;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getHelpfulCount() {
        return helpfulCount;
    }

    public void setHelpfulCount(int helpfulCount) {
        this.helpfulCount = helpfulCount;
    }

    public boolean isFlagged() {
        return flagged;
    }

    public void setFlagged(boolean flagged) {
        this.flagged = flagged;
    }

    public List<String> getPhotoUrls() {
        return photoUrls;
    }

    public void setPhotoUrls(List<String> photoUrls) {
        this.photoUrls = photoUrls;
    }
    
    public void addPhotoUrl(String photoUrl) {
        this.photoUrls.add(photoUrl);
    }

    public DetailedRatings getDetailedRatings() {
        return detailedRatings;
    }

    public void setDetailedRatings(DetailedRatings detailedRatings) {
        this.detailedRatings = detailedRatings;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserPhotoUrl() {
        return userPhotoUrl;
    }

    public void setUserPhotoUrl(String userPhotoUrl) {
        this.userPhotoUrl = userPhotoUrl;
    }

    public boolean isVerifiedBooking() {
        return verifiedBooking;
    }

    public void setVerifiedBooking(boolean verifiedBooking) {
        this.verifiedBooking = verifiedBooking;
    }

    public String getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }
    
    @Override
    public String toString() {
        return "Review{" +
                "reviewId='" + reviewId + '\'' +
                ", userId='" + userId + '\'' +
                ", vendorId='" + vendorId + '\'' +
                ", serviceId='" + serviceId + '\'' +
                ", rating=" + rating +
                ", status='" + status + '\'' +
                '}';
    }
}