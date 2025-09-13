package com.MarryMate.models;

import java.math.BigDecimal;

/**
 * ServiceOption model class - represents a selected option in a service booking
 * Created: 2025-05-13 06:41:45
 * Author: IT24102083
 */
public class ServiceOption {
    private String optionId;
    private String name;
    private BigDecimal price;
    
    // Constructors
    public ServiceOption() {
    }
    
    public ServiceOption(String optionId, String name, BigDecimal price) {
        this.optionId = optionId;
        this.name = name;
        this.price = price;
    }

    // Getters and Setters
    public String getOptionId() {
        return optionId;
    }

    public void setOptionId(String optionId) {
        this.optionId = optionId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = price;
    }
}