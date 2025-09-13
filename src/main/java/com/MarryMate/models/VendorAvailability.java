package com.MarryMate.models;

import java.util.*;

/**
 * Model class representing vendor availability
 * 
 * Current Date and Time: 2025-05-11 15:26:57
 * Current User: IT24102137
 */
public class VendorAvailability {
    private String vendorId;
    private String timeZone;
    private Map<String, WorkingHours> defaultWorkingHours;
    private List<UnavailableDate> unavailableDates;
    private List<SpecialBusinessHours> specialBusinessHours;
    private List<BookedSlot> bookedSlots;
    private Map<String, ServiceAvailabilitySettings> serviceAvailability;
    private List<RecurrenceRule> recurrenceRules;
    private Map<String, List<BreakTime>> breakTimes;
    private List<ServiceLocation> locations;
    private String lastUpdated;
    private String updatedBy;

    // Inner class for working hours
    public static class WorkingHours {
        private String start;
        private String end;
        private boolean available;

        // Constructors
        public WorkingHours() {
        }

        public WorkingHours(String start, String end, boolean available) {
            this.start = start;
            this.end = end;
            this.available = available;
        }

        // Getters and Setters
        public String getStart() {
            return start;
        }

        public void setStart(String start) {
            this.start = start;
        }

        public String getEnd() {
            return end;
        }

        public void setEnd(String end) {
            this.end = end;
        }

        public boolean isAvailable() {
            return available;
        }

        public void setAvailable(boolean available) {
            this.available = available;
        }

        @Override
        public String toString() {
            return "WorkingHours{" +
                    "start='" + start + '\'' +
                    ", end='" + end + '\'' +
                    ", available=" + available +
                    '}';
        }
    }

    // Inner class for unavailable dates
    public static class UnavailableDate {
        private String date;
        private String reason;
        private String notes;

        // Constructors
        public UnavailableDate() {
        }

        public UnavailableDate(String date, String reason, String notes) {
            this.date = date;
            this.reason = reason;
            this.notes = notes;
        }

        // Getters and Setters
        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public String getReason() {
            return reason;
        }

        public void setReason(String reason) {
            this.reason = reason;
        }

        public String getNotes() {
            return notes;
        }

        public void setNotes(String notes) {
            this.notes = notes;
        }

        @Override
        public String toString() {
            return "UnavailableDate{" +
                    "date='" + date + '\'' +
                    ", reason='" + reason + '\'' +
                    ", notes='" + notes + '\'' +
                    '}';
        }
    }

    // Inner class for special business hours
    public static class SpecialBusinessHours {
        private String date;
        private WorkingHours workingHours;
        private boolean available;
        private String reason;
        private String notes;

        // Constructors
        public SpecialBusinessHours() {
        }

        public SpecialBusinessHours(String date, WorkingHours workingHours, boolean available, String reason, String notes) {
            this.date = date;
            this.workingHours = workingHours;
            this.available = available;
            this.reason = reason;
            this.notes = notes;
        }

        // Getters and Setters
        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public WorkingHours getWorkingHours() {
            return workingHours;
        }

        public void setWorkingHours(WorkingHours workingHours) {
            this.workingHours = workingHours;
        }

        public boolean isAvailable() {
            return available;
        }

        public void setAvailable(boolean available) {
            this.available = available;
        }

        public String getReason() {
            return reason;
        }

        public void setReason(String reason) {
            this.reason = reason;
        }

        public String getNotes() {
            return notes;
        }

        public void setNotes(String notes) {
            this.notes = notes;
        }

        @Override
        public String toString() {
            return "SpecialBusinessHours{" +
                    "date='" + date + '\'' +
                    ", workingHours=" + workingHours +
                    ", available=" + available +
                    ", reason='" + reason + '\'' +
                    ", notes='" + notes + '\'' +
                    '}';
        }
    }

    // Inner class for booked slots
    public static class BookedSlot {
        private String date;
        private String startTime;
        private String endTime;
        private String bookingId;
        private String serviceBookingId;
        private String serviceId;
        private String status;

        // Constructors
        public BookedSlot() {
        }

        public BookedSlot(String date, String startTime, String endTime, String bookingId, 
                String serviceBookingId, String serviceId, String status) {
            this.date = date;
            this.startTime = startTime;
            this.endTime = endTime;
            this.bookingId = bookingId;
            this.serviceBookingId = serviceBookingId;
            this.serviceId = serviceId;
            this.status = status;
        }

        // Getters and Setters
        public String getDate() {
            return date;
        }

        public void setDate(String date) {
            this.date = date;
        }

        public String getStartTime() {
            return startTime;
        }

        public void setStartTime(String startTime) {
            this.startTime = startTime;
        }

        public String getEndTime() {
            return endTime;
        }

        public void setEndTime(String endTime) {
            this.endTime = endTime;
        }

        public String getBookingId() {
            return bookingId;
        }

        public void setBookingId(String bookingId) {
            this.bookingId = bookingId;
        }

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

        public String getStatus() {
            return status;
        }

        public void setStatus(String status) {
            this.status = status;
        }

        @Override
        public String toString() {
            return "BookedSlot{" +
                    "date='" + date + '\'' +
                    ", startTime='" + startTime + '\'' +
                    ", endTime='" + endTime + '\'' +
                    ", bookingId='" + bookingId + '\'' +
                    ", serviceBookingId='" + serviceBookingId + '\'' +
                    ", serviceId='" + serviceId + '\'' +
                    ", status='" + status + '\'' +
                    '}';
        }
    }

    // Inner class for service availability settings
    public static class ServiceAvailabilitySettings {
        private int maxBookingsPerDay;
        private int standardDuration;
        private double bufferTime;

        // Constructors
        public ServiceAvailabilitySettings() {
        }

        public ServiceAvailabilitySettings(int maxBookingsPerDay, int standardDuration, double bufferTime) {
            this.maxBookingsPerDay = maxBookingsPerDay;
            this.standardDuration = standardDuration;
            this.bufferTime = bufferTime;
        }

        // Getters and Setters
        public int getMaxBookingsPerDay() {
            return maxBookingsPerDay;
        }

        public void setMaxBookingsPerDay(int maxBookingsPerDay) {
            this.maxBookingsPerDay = maxBookingsPerDay;
        }

        public int getStandardDuration() {
            return standardDuration;
        }

        public void setStandardDuration(int standardDuration) {
            this.standardDuration = standardDuration;
        }

        public double getBufferTime() {
            return bufferTime;
        }

        public void setBufferTime(double bufferTime) {
            this.bufferTime = bufferTime;
        }

        @Override
        public String toString() {
            return "ServiceAvailabilitySettings{" +
                    "maxBookingsPerDay=" + maxBookingsPerDay +
                    ", standardDuration=" + standardDuration +
                    ", bufferTime=" + bufferTime +
                    '}';
        }
    }

    // Inner class for recurrence rules
    public static class RecurrenceRule {
        private String type;
        private String frequency;
        private int dayOfMonth;
        private String startDate;
        private String endDate;
        private String reason;
        private String notes;

        // Constructors
        public RecurrenceRule() {
        }

        public RecurrenceRule(String type, String frequency, int dayOfMonth,
                              String startDate, String endDate, String reason, String notes) {
            this.type = type;
            this.frequency = frequency;
            this.dayOfMonth = dayOfMonth;
            this.startDate = startDate;
            this.endDate = endDate;
            this.reason = reason;
            this.notes = notes;
        }

        // Getters and Setters
        public String getType() {
            return type;
        }

        public void setType(String type) {
            this.type = type;
        }

        public String getFrequency() {
            return frequency;
        }

        public void setFrequency(String frequency) {
            this.frequency = frequency;
        }

        public int getDayOfMonth() {
            return dayOfMonth;
        }

        public void setDayOfMonth(int dayOfMonth) {
            this.dayOfMonth = dayOfMonth;
        }

        public String getStartDate() {
            return startDate;
        }

        public void setStartDate(String startDate) {
            this.startDate = startDate;
        }

        public String getEndDate() {
            return endDate;
        }

        public void setEndDate(String endDate) {
            this.endDate = endDate;
        }

        public String getReason() {
            return reason;
        }

        public void setReason(String reason) {
            this.reason = reason;
        }

        public String getNotes() {
            return notes;
        }

        public void setNotes(String notes) {
            this.notes = notes;
        }

        @Override
        public String toString() {
            return "RecurrenceRule{" +
                    "type='" + type + '\'' +
                    ", frequency='" + frequency + '\'' +
                    ", dayOfMonth=" + dayOfMonth +
                    ", startDate='" + startDate + '\'' +
                    ", endDate='" + endDate + '\'' +
                    ", reason='" + reason + '\'' +
                    ", notes='" + notes + '\'' +
                    '}';
        }
    }

    // Inner class for break times
    public static class BreakTime {
        private String start;
        private String end;
        private String description;

        // Constructors
        public BreakTime() {
        }

        public BreakTime(String start, String end, String description) {
            this.start = start;
            this.end = end;
            this.description = description;
        }

        // Getters and Setters
        public String getStart() {
            return start;
        }

        public void setStart(String start) {
            this.start = start;
        }

        public String getEnd() {
            return end;
        }

        public void setEnd(String end) {
            this.end = end;
        }

        public String getDescription() {
            return description;
        }

        public void setDescription(String description) {
            this.description = description;
        }

        @Override
        public String toString() {
            return "BreakTime{" +
                    "start='" + start + '\'' +
                    ", end='" + end + '\'' +
                    ", description='" + description + '\'' +
                    '}';
        }
    }

    // Inner class for service locations
    public static class ServiceLocation {
        private String locationId;
        private String name;
        private String address;
        private List<String> services;

        // Constructors
        public ServiceLocation() {
            this.services = new ArrayList<>();
        }

        public ServiceLocation(String locationId, String name, String address) {
            this.locationId = locationId;
            this.name = name;
            this.address = address;
            this.services = new ArrayList<>();
        }

        // Getters and Setters
        public String getLocationId() {
            return locationId;
        }

        public void setLocationId(String locationId) {
            this.locationId = locationId;
        }

        public String getName() {
            return name;
        }

        public void setName(String name) {
            this.name = name;
        }

        public String getAddress() {
            return address;
        }

        public void setAddress(String address) {
            this.address = address;
        }

        public List<String> getServices() {
            return services;
        }

        public void setServices(List<String> services) {
            this.services = services;
        }
        
        public void addService(String serviceId) {
            this.services.add(serviceId);
        }
        
        public void removeService(String serviceId) {
            this.services.remove(serviceId);
        }

        @Override
        public String toString() {
            return "ServiceLocation{" +
                    "locationId='" + locationId + '\'' +
                    ", name='" + name + '\'' +
                    ", address='" + address + '\'' +
                    ", services=" + services +
                    '}';
        }
    }

    // Constructor for VendorAvailability
    public VendorAvailability() {
        this.defaultWorkingHours = new HashMap<>();
        this.unavailableDates = new ArrayList<>();
        this.specialBusinessHours = new ArrayList<>();
        this.bookedSlots = new ArrayList<>();
        this.serviceAvailability = new HashMap<>();
        this.recurrenceRules = new ArrayList<>();
        this.breakTimes = new HashMap<>();
        this.locations = new ArrayList<>();
    }

    // Helper method to initialize default working hours
    public void initializeDefaultWorkingHours() {
        String[] days = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"};
        for (String day : days) {
            if (day.equals("Sunday")) {
                defaultWorkingHours.put(day, new WorkingHours(null, null, false));
            } else if (day.equals("Saturday")) {
                defaultWorkingHours.put(day, new WorkingHours("10:00", "16:00", true));
            } else {
                defaultWorkingHours.put(day, new WorkingHours("09:00", "17:00", true));
            }
        }
    }
    
    // Method to check if date is available
    public boolean isDateAvailable(String date) {
        // Check if date is in unavailable dates
        for (UnavailableDate unavailableDate : unavailableDates) {
            if (unavailableDate.getDate().equals(date)) {
                return false;
            }
        }
        
        // Check if date has special business hours and is marked unavailable
        for (SpecialBusinessHours specialHours : specialBusinessHours) {
            if (specialHours.getDate().equals(date) && !specialHours.isAvailable()) {
                return false;
            }
        }
        
        // Check if date falls on recurring unavailable pattern
        for (RecurrenceRule rule : recurrenceRules) {
            if ("unavailable".equals(rule.getType())) {
                // Here would be logic to check if date matches recurrence pattern
                // This is a simplified placeholder - actual implementation would need date parsing
                if (date.equals(rule.getStartDate())) {
                    return false;
                }
            }
        }
        
        return true;
    }
    
    // Method to get all booked slots for a specific date
    public List<BookedSlot> getBookedSlotsForDate(String date) {
        List<BookedSlot> slots = new ArrayList<>();
        
        for (BookedSlot slot : bookedSlots) {
            if (slot.getDate().equals(date)) {
                slots.add(slot);
            }
        }
        
        return slots;
    }
    
    // Method to get available time slots for a given date and service
    public List<Map<String, String>> getAvailableTimeSlotsForDate(String date, String serviceId) {
        List<Map<String, String>> availableSlots = new ArrayList<>();
        
        // Implement time slot calculation logic here
        // This would check working hours, booked slots, and break times
        // to determine what slots are available
        
        return availableSlots;
    }

    // Getters and Setters for VendorAvailability
    public String getVendorId() {
        return vendorId;
    }

    public void setVendorId(String vendorId) {
        this.vendorId = vendorId;
    }

    public String getTimeZone() {
        return timeZone;
    }

    public void setTimeZone(String timeZone) {
        this.timeZone = timeZone;
    }

    public Map<String, WorkingHours> getDefaultWorkingHours() {
        return defaultWorkingHours;
    }

    public void setDefaultWorkingHours(Map<String, WorkingHours> defaultWorkingHours) {
        this.defaultWorkingHours = defaultWorkingHours;
    }

    public List<UnavailableDate> getUnavailableDates() {
        return unavailableDates;
    }

    public void setUnavailableDates(List<UnavailableDate> unavailableDates) {
        this.unavailableDates = unavailableDates;
    }
    
    public void addUnavailableDate(UnavailableDate unavailableDate) {
        this.unavailableDates.add(unavailableDate);
    }

    public List<SpecialBusinessHours> getSpecialBusinessHours() {
        return specialBusinessHours;
    }

    public void setSpecialBusinessHours(List<SpecialBusinessHours> specialBusinessHours) {
        this.specialBusinessHours = specialBusinessHours;
    }
    
    public void addSpecialBusinessHours(SpecialBusinessHours specialHours) {
        this.specialBusinessHours.add(specialHours);
    }

    public List<BookedSlot> getBookedSlots() {
        return bookedSlots;
    }

    public void setBookedSlots(List<BookedSlot> bookedSlots) {
        this.bookedSlots = bookedSlots;
    }
    
    public void addBookedSlot(BookedSlot bookedSlot) {
        this.bookedSlots.add(bookedSlot);
    }
    
    public void removeBookedSlot(String serviceBookingId) {
        this.bookedSlots.removeIf(slot -> slot.getServiceBookingId().equals(serviceBookingId));
    }

    public Map<String, ServiceAvailabilitySettings> getServiceAvailability() {
        return serviceAvailability;
    }

    public void setServiceAvailability(Map<String, ServiceAvailabilitySettings> serviceAvailability) {
        this.serviceAvailability = serviceAvailability;
    }
    
    public void addServiceAvailabilitySetting(String serviceId, ServiceAvailabilitySettings settings) {
        this.serviceAvailability.put(serviceId, settings);
    }

    public List<RecurrenceRule> getRecurrenceRules() {
        return recurrenceRules;
    }

    public void setRecurrenceRules(List<RecurrenceRule> recurrenceRules) {
        this.recurrenceRules = recurrenceRules;
    }
    
    public void addRecurrenceRule(RecurrenceRule rule) {
        this.recurrenceRules.add(rule);
    }

    public Map<String, List<BreakTime>> getBreakTimes() {
        return breakTimes;
    }

    public void setBreakTimes(Map<String, List<BreakTime>> breakTimes) {
        this.breakTimes = breakTimes;
    }
    
    public void addBreakTime(String day, BreakTime breakTime) {
        if (!this.breakTimes.containsKey(day)) {
            this.breakTimes.put(day, new ArrayList<>());
        }
        this.breakTimes.get(day).add(breakTime);
    }

    public List<ServiceLocation> getLocations() {
        return locations;
    }

    public void setLocations(List<ServiceLocation> locations) {
        this.locations = locations;
    }
    
    public void addLocation(ServiceLocation location) {
        this.locations.add(location);
    }

    public String getLastUpdated() {
        return lastUpdated;
    }

    public void setLastUpdated(String lastUpdated) {
        this.lastUpdated = lastUpdated;
    }

    public String getUpdatedBy() {
        return updatedBy;
    }

    public void setUpdatedBy(String updatedBy) {
        this.updatedBy = updatedBy;
    }

    @Override
    public String toString() {
        return "VendorAvailability{" +
                "vendorId='" + vendorId + '\'' +
                ", timeZone='" + timeZone + '\'' +
                ", unavailableDates=" + unavailableDates.size() +
                ", specialBusinessHours=" + specialBusinessHours.size() +
                ", bookedSlots=" + bookedSlots.size() +
                ", serviceAvailability=" + serviceAvailability.size() +
                ", recurrenceRules=" + recurrenceRules.size() +
                ", locations=" + locations.size() +
                ", lastUpdated='" + lastUpdated + '\'' +
                '}';
    }
}