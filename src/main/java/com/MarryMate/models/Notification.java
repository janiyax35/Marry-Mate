package com.MarryMate.models;

import java.util.Objects;

/**
 * Notification model class for vendor notifications
 * Current Date and Time: 2025-05-07 10:03:26
 * Current User: IT24102137
 */
public class Notification {
    
    private String notificationId;
    private String userId;
    private String type; // booking_request, review, system_message, etc.
    private String title;
    private String message;
    private String relatedId; // ID of related entity (booking, review, etc.)
    private String dateCreated;
    private boolean isRead;
    private String actionUrl;
    private String priority; // high, medium, low
    
    /**
     * Default constructor
     */
    public Notification() {
        this.isRead = false;
        this.priority = "medium";
    }
    
    /**
     * Basic constructor
     */
    public Notification(String notificationId, String userId, String type, 
                       String title, String message) {
        this();
        this.notificationId = notificationId;
        this.userId = userId;
        this.type = type;
        this.title = title;
        this.message = message;
    }
    
    /**
     * Full constructor
     */
    public Notification(String notificationId, String userId, String type, 
                       String title, String message, String relatedId, 
                       String dateCreated, boolean isRead, String actionUrl, 
                       String priority) {
        this.notificationId = notificationId;
        this.userId = userId;
        this.type = type;
        this.title = title;
        this.message = message;
        this.relatedId = relatedId;
        this.dateCreated = dateCreated;
        this.isRead = isRead;
        this.actionUrl = actionUrl;
        this.priority = priority;
    }
    
    // Getters and Setters
    
    public String getNotificationId() {
        return notificationId;
    }
    
    public void setNotificationId(String notificationId) {
        this.notificationId = notificationId;
    }
    
    public String getUserId() {
        return userId;
    }
    
    public void setUserId(String userId) {
        this.userId = userId;
    }
    
    public String getType() {
        return type;
    }
    
    public void setType(String type) {
        this.type = type;
    }
    
    public String getTitle() {
        return title;
    }
    
    public void setTitle(String title) {
        this.title = title;
    }
    
    public String getMessage() {
        return message;
    }
    
    public void setMessage(String message) {
        this.message = message;
    }
    
    public String getRelatedId() {
        return relatedId;
    }
    
    public void setRelatedId(String relatedId) {
        this.relatedId = relatedId;
    }
    
    public String getDateCreated() {
        return dateCreated;
    }
    
    public void setDateCreated(String dateCreated) {
        this.dateCreated = dateCreated;
    }
    
    public boolean isRead() {
        return isRead;
    }
    
    public void setRead(boolean isRead) {
        this.isRead = isRead;
    }
    
    public String getActionUrl() {
        return actionUrl;
    }
    
    public void setActionUrl(String actionUrl) {
        this.actionUrl = actionUrl;
    }
    
    public String getPriority() {
        return priority;
    }
    
    public void setPriority(String priority) {
        this.priority = priority;
    }
    
    // Business Methods
    
    /**
     * Mark the notification as read
     */
    public void markAsRead() {
        this.isRead = true;
    }
    
    /**
     * Check if this notification is high priority
     * @return true if high priority, false otherwise
     */
    public boolean isHighPriority() {
        return "high".equals(priority);
    }
    
    /**
     * Get the CSS class based on notification type
     * @return CSS class name
     */
    public String getNotificationIconClass() {
        switch (type) {
            case "booking_request":
                return "fa-calendar-check";
            case "review":
                return "fa-star";
            case "payment":
                return "fa-credit-card";
            case "system_message":
                return "fa-bell";
            default:
                return "fa-info-circle";
        }
    }
    
    /**
     * Get color class based on priority
     * @return Bootstrap color class
     */
    public String getPriorityColorClass() {
        switch (priority) {
            case "high":
                return "bg-danger";
            case "medium":
                return "bg-warning";
            case "low":
                return "bg-info";
            default:
                return "bg-secondary";
        }
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Notification that = (Notification) o;
        return Objects.equals(notificationId, that.notificationId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(notificationId);
    }
    
    @Override
    public String toString() {
        return "Notification{" +
                "notificationId='" + notificationId + '\'' +
                ", userId='" + userId + '\'' +
                ", type='" + type + '\'' +
                ", title='" + title + '\'' +
                ", isRead=" + isRead +
                ", priority='" + priority + '\'' +
                '}';
    }
}