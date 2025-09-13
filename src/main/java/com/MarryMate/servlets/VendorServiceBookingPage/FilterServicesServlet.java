package com.MarryMate.servlets.VendorServiceBookingPage;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * Servlet implementation class FilterServicesServlet
 * Handles AJAX requests for filtering and sorting services
 */
@WebServlet("/FilterServicesServlet")
public class FilterServicesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VENDOR_SERVICES_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendorServices.json";
    private static final String VENDORS_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
    private static final Gson gson = new Gson();
    
    // LinkedList node class for services
    private class ServiceNode {
        JsonObject service;
        ServiceNode next;
        
        public ServiceNode(JsonObject service) {
            this.service = service;
            this.next = null;
        }
    }
    
    // LinkedList implementation for services
    private class ServiceLinkedList {
        private ServiceNode head;
        
        public ServiceLinkedList() {
            this.head = null;
        }
        
        // Add a service to the linked list
        public void add(JsonObject service) {
            ServiceNode newNode = new ServiceNode(service);
            
            if (head == null) {
                head = newNode;
            } else {
                ServiceNode current = head;
                while (current.next != null) {
                    current = current.next;
                }
                current.next = newNode;
            }
        }
        
        // Convert linked list to JSON array
        public JsonArray toJsonArray() {
            JsonArray array = new JsonArray();
            ServiceNode current = head;
            
            while (current != null) {
                array.add(current.service);
                current = current.next;
            }
            
            return array;
        }
        
        // Filter services by category
        public ServiceLinkedList filterByCategory(String category) {
            if (category == null || category.isEmpty() || category.equals("all")) {
                return this;
            }
            
            ServiceLinkedList filteredList = new ServiceLinkedList();
            ServiceNode current = head;
            
            while (current != null) {
                if (current.service.has("category") && 
                    current.service.get("category").getAsString().equalsIgnoreCase(category)) {
                    filteredList.add(current.service);
                }
                current = current.next;
            }
            
            return filteredList;
        }
        
        // Filter services by price range
        public ServiceLinkedList filterByPriceRange(double minPrice, double maxPrice) {
            ServiceLinkedList filteredList = new ServiceLinkedList();
            ServiceNode current = head;
            
            while (current != null) {
                if (current.service.has("basePrice")) {
                    double price = current.service.get("basePrice").getAsDouble();
                    if (price >= minPrice && (maxPrice <= 0 || price <= maxPrice)) {
                        filteredList.add(current.service);
                    }
                }
                current = current.next;
            }
            
            return filteredList;
        }
        
        // Filter services by rating
        public ServiceLinkedList filterByRating(double minRating) {
            ServiceLinkedList filteredList = new ServiceLinkedList();
            ServiceNode current = head;
            
            while (current != null) {
                // For vendor rating, we need to check the vendor
                if (current.service.has("vendorRating") && 
                    current.service.get("vendorRating").getAsDouble() >= minRating) {
                    filteredList.add(current.service);
                } else if (!current.service.has("vendorRating") && current.service.has("vendorId")) {
                    // No rating in the enriched service, try to get from vendor data
                    String vendorId = current.service.get("vendorId").getAsString();
                    double rating = getVendorRating(vendorId);
                    
                    if (rating >= minRating) {
                        filteredList.add(current.service);
                    }
                }
                current = current.next;
            }
            
            return filteredList;
        }
        
        // Sort services by price using bubble sort
        public ServiceLinkedList sortByPrice(boolean ascending) {
            if (head == null || head.next == null) {
                return this;
            }
            
            boolean swapped;
            ServiceNode current;
            ServiceNode last = null;
            
            do {
                swapped = false;
                current = head;
                
                while (current.next != last) {
                    double price1 = current.service.has("basePrice") ? 
                                   current.service.get("basePrice").getAsDouble() : 0;
                    double price2 = current.next.service.has("basePrice") ? 
                                   current.next.service.get("basePrice").getAsDouble() : 0;
                    
                    // Swap if needed based on sort direction
                    if ((ascending && price1 > price2) || (!ascending && price1 < price2)) {
                        // Swap services
                        JsonObject temp = current.service;
                        current.service = current.next.service;
                        current.next.service = temp;
                        swapped = true;
                    }
                    
                    current = current.next;
                }
                
                last = current;
            } while (swapped);
            
            return this;
        }
        
        // Sort services by rating
        public ServiceLinkedList sortByRating(boolean ascending) {
            if (head == null || head.next == null) {
                return this;
            }
            
            boolean swapped;
            ServiceNode current;
            ServiceNode last = null;
            
            do {
                swapped = false;
                current = head;
                
                while (current.next != last) {
                    double rating1 = current.service.has("vendorRating") ? 
                                    current.service.get("vendorRating").getAsDouble() : 0;
                    double rating2 = current.next.service.has("vendorRating") ? 
                                    current.next.service.get("vendorRating").getAsDouble() : 0;
                    
                    // Swap if needed based on sort direction
                    if ((ascending && rating1 > rating2) || (!ascending && rating1 < rating2)) {
                        // Swap services
                        JsonObject temp = current.service;
                        current.service = current.next.service;
                        current.next.service = temp;
                        swapped = true;
                    }
                    
                    current = current.next;
                }
                
                last = current;
            } while (swapped);
            
            return this;
        }
    }
    
    /**
     * @see HttpServlet#HttpServlet()
     */
    public FilterServicesServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        
        // Get filter parameters from request
        String category = request.getParameter("category");
        String priceRange = request.getParameter("priceRange");
        String minRating = request.getParameter("minRating");
        String sortBy = request.getParameter("sortBy");
        String sortOrder = request.getParameter("sortOrder");
        
        // Load services from JSON file
        ServiceLinkedList servicesList = loadServices();
        
        // Apply category filter
        if (category != null && !category.isEmpty() && !category.equals("all")) {
            servicesList = servicesList.filterByCategory(category);
        }
        
        // Apply price range filter
        if (priceRange != null && !priceRange.isEmpty()) {
            try {
                String[] range = priceRange.split("-");
                double minPrice = Double.parseDouble(range[0]);
                double maxPrice = range.length > 1 ? Double.parseDouble(range[1]) : 0;
                servicesList = servicesList.filterByPriceRange(minPrice, maxPrice);
            } catch (Exception e) {
                System.err.println("Invalid price range: " + priceRange);
            }
        }
        
        // Apply rating filter
        if (minRating != null && !minRating.isEmpty()) {
            try {
                double ratingValue = Double.parseDouble(minRating);
                servicesList = servicesList.filterByRating(ratingValue);
            } catch (Exception e) {
                System.err.println("Invalid rating value: " + minRating);
            }
        }
        
        // Apply sorting
        boolean ascending = sortOrder == null || !sortOrder.equalsIgnoreCase("desc");
        
        if (sortBy != null && sortBy.equalsIgnoreCase("rating")) {
            servicesList = servicesList.sortByRating(ascending);
        } else {
            // Default sort by price
            servicesList = servicesList.sortByPrice(ascending);
        }
        
        // Load vendors data for enrichment
        JsonObject vendorsData = loadVendorsData();
        
        // Enrich services with vendor info
        ServiceLinkedList enrichedServices = enrichServicesWithVendorInfo(servicesList, vendorsData);
        
        // Create response JSON object
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", true);
        jsonResponse.add("services", enrichedServices.toJsonArray());
        
        // Add metadata
        JsonObject metadata = new JsonObject();
        metadata.addProperty("totalResults", enrichedServices.toJsonArray().size());
        metadata.addProperty("category", category);
        metadata.addProperty("priceRange", priceRange);
        metadata.addProperty("minRating", minRating);
        metadata.addProperty("sortBy", sortBy);
        metadata.addProperty("sortOrder", sortOrder);
        jsonResponse.add("metadata", metadata);
        
        // Send response
        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
    
    /**
     * Load services from JSON file
     */
    private ServiceLinkedList loadServices() {
        ServiceLinkedList servicesList = new ServiceLinkedList();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(VENDOR_SERVICES_PATH))) {
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray servicesArray = jsonData.getAsJsonArray("services");
            
            for (JsonElement serviceElement : servicesArray) {
                JsonObject service = serviceElement.getAsJsonObject();
                // Only include active services
                if (service.has("status") && 
                    service.get("status").getAsString().equalsIgnoreCase("active")) {
                    servicesList.add(service);
                }
            }
        } catch (IOException e) {
            System.err.println("Error loading services: " + e.getMessage());
        }
        
        return servicesList;
    }
    
    /**
     * Load vendors data
     */
    private JsonObject loadVendorsData() {
        JsonObject vendorsData = new JsonObject();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(VENDORS_PATH))) {
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray vendorsArray = jsonData.getAsJsonArray("vendors");
            
            for (JsonElement vendorElement : vendorsArray) {
                JsonObject vendor = vendorElement.getAsJsonObject();
                if (vendor.has("userId")) {
                    String vendorId = vendor.get("userId").getAsString();
                    vendorsData.add(vendorId, vendor);
                }
            }
        } catch (IOException e) {
            System.err.println("Error loading vendors: " + e.getMessage());
        }
        
        return vendorsData;
    }
    
    /**
     * Get vendor rating by ID
     */
    private double getVendorRating(String vendorId) {
        try (BufferedReader reader = new BufferedReader(new FileReader(VENDORS_PATH))) {
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray vendorsArray = jsonData.getAsJsonArray("vendors");
            
            for (JsonElement vendorElement : vendorsArray) {
                JsonObject vendor = vendorElement.getAsJsonObject();
                if (vendor.has("userId") && vendor.get("userId").getAsString().equals(vendorId)) {
                    return vendor.has("rating") ? vendor.get("rating").getAsDouble() : 0.0;
                }
            }
        } catch (IOException e) {
            System.err.println("Error getting vendor rating: " + e.getMessage());
        }
        
        return 0.0;
    }
    
    /**
     * Enrich services with vendor information
     */
    private ServiceLinkedList enrichServicesWithVendorInfo(ServiceLinkedList servicesList, JsonObject vendorsData) {
        ServiceLinkedList enrichedServices = new ServiceLinkedList();
        JsonArray services = servicesList.toJsonArray();
        
        for (JsonElement serviceElement : services) {
            JsonObject service = serviceElement.getAsJsonObject();
            
            if (service.has("vendorId")) {
                String vendorId = service.get("vendorId").getAsString();
                
                if (vendorsData.has(vendorId)) {
                    JsonObject vendor = vendorsData.get(vendorId).getAsJsonObject();
                    
                    // Create enriched service object
                    JsonObject enriched = new JsonObject();
                    
                    // Copy service properties
                    for (String key : service.keySet()) {
                        enriched.add(key, service.get(key));
                    }
                    
                    // Add vendor properties
                    if (vendor.has("businessName")) {
                        enriched.addProperty("vendorName", vendor.get("businessName").getAsString());
                    }
                    
                    if (vendor.has("rating")) {
                        enriched.addProperty("vendorRating", vendor.get("rating").getAsDouble());
                    }
                    
                    if (vendor.has("profilePictureUrl")) {
                        enriched.addProperty("vendorImage", vendor.get("profilePictureUrl").getAsString());
                    }
                    
                    enrichedServices.add(enriched);
                } else {
                    // No vendor info, just use the service as is
                    enrichedServices.add(service);
                }
            } else {
                // No vendor ID, just use the service as is
                enrichedServices.add(service);
            }
        }
        
        return enrichedServices;
    }
}