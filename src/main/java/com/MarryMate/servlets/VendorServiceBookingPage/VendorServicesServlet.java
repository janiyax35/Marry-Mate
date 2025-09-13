package com.MarryMate.servlets.VendorServiceBookingPage;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

/**
 * Servlet implementation class VendorServicesServlet
 * Handles the display of vendor services with filtering and sorting capabilities
 * Uses a LinkedList data structure to store services and Bubble Sort for price sorting
 */
@WebServlet("/VendorServicesServlet")
public class VendorServicesServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String VENDOR_SERVICES_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendorServices.json";
    private static final String VENDORS_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
    private static final String REVIEWS_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\reviews.json";
    private static final String CATEGORIES_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\service-categories.json";
    
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
        
        // Get all services as a list
        public List<JsonObject> toList() {
            List<JsonObject> servicesList = new ArrayList<>();
            ServiceNode current = head;
            
            while (current != null) {
                servicesList.add(current.service);
                current = current.next;
            }
            
            return servicesList;
        }
        
        // Filter services by category
        public ServiceLinkedList filterByCategory(String category) {
            if (category == null || category.isEmpty()) {
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
    }

    /**
     * @see HttpServlet#HttpServlet()
     */
    public VendorServicesServlet() {
        super();
    }

    /**
     * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Get filter parameters
        String category = request.getParameter("category");
        String priceRange = request.getParameter("priceRange");
        String sortOrder = request.getParameter("sortOrder");
        
        // Load services from JSON file
        ServiceLinkedList servicesList = loadServices();
        
        // Apply filters if provided
        if (category != null && !category.isEmpty() && !category.equals("all")) {
            servicesList = servicesList.filterByCategory(category);
        }
        
        // Parse price range and filter
        if (priceRange != null && !priceRange.isEmpty()) {
            try {
                String[] range = priceRange.split("-");
                double minPrice = Double.parseDouble(range[0]);
                double maxPrice = range.length > 1 ? Double.parseDouble(range[1]) : 0;
                servicesList = servicesList.filterByPriceRange(minPrice, maxPrice);
            } catch (Exception e) {
                // Invalid price range, ignore filter
                System.err.println("Invalid price range: " + priceRange);
            }
        }
        
        // Apply sorting
        boolean ascending = sortOrder == null || !sortOrder.equalsIgnoreCase("desc");
        servicesList = servicesList.sortByPrice(ascending);
        
        // Load vendors for additional information
        JsonObject vendorsData = loadVendorsData();
        
        // Convert results to final list with vendor information
        List<JsonObject> finalServices = enrichServicesWithVendorInfo(servicesList.toList(), vendorsData);
        
        // Store results in request attributes
        request.setAttribute("services", finalServices);
        request.setAttribute("categories", loadCategories());
        request.setAttribute("selectedCategory", category);
        request.setAttribute("selectedPriceRange", priceRange);
        request.setAttribute("sortOrder", sortOrder);
        
        // Store current user information
        HttpSession session = request.getSession();
        request.setAttribute("isLoggedIn", session.getAttribute("username") != null);
        request.setAttribute("userRole", session.getAttribute("role"));
        
        // Forward to the JSP page
        request.getRequestDispatcher("/views/vendor-services.jsp").forward(request, response);
    }

    /**
     * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
     */
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }
    
    /**
     * Load vendor services from JSON file into a linked list
     */
    private ServiceLinkedList loadServices() {
        ServiceLinkedList servicesList = new ServiceLinkedList();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(VENDOR_SERVICES_PATH))) {
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray servicesArray = jsonData.getAsJsonArray("services");
            
            for (JsonElement serviceElement : servicesArray) {
                JsonObject service = serviceElement.getAsJsonObject();
                // Only add active services
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
     * Load vendors data from JSON file
     */
    private JsonObject loadVendorsData() {
        JsonObject vendorsData = new JsonObject();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(VENDORS_PATH))) {
            JsonObject jsonData = JsonParser.parseReader(reader).getAsJsonObject();
            JsonArray vendorsArray = jsonData.getAsJsonArray("vendors");
            
            // Create a map of vendor ID to vendor object for quick lookup
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
     * Load service categories from JSON file
     */
    private List<JsonObject> loadCategories() {
        List<JsonObject> categories = new ArrayList<>();
        
        try (BufferedReader reader = new BufferedReader(new FileReader(CATEGORIES_PATH))) {
            JsonArray categoriesArray = JsonParser.parseReader(reader).getAsJsonArray();
            
            for (JsonElement categoryElement : categoriesArray) {
                JsonObject category = categoryElement.getAsJsonObject();
                if (category.has("active") && category.get("active").getAsBoolean()) {
                    categories.add(category);
                }
            }
            
        } catch (IOException e) {
            System.err.println("Error loading categories: " + e.getMessage());
        }
        
        return categories;
    }
    
    /**
     * Enrich service data with vendor information
     */
    private List<JsonObject> enrichServicesWithVendorInfo(List<JsonObject> services, JsonObject vendorsData) {
        List<JsonObject> enrichedServices = new ArrayList<>();
        
        for (JsonObject service : services) {
            if (service.has("vendorId")) {
                String vendorId = service.get("vendorId").getAsString();
                
                if (vendorsData.has(vendorId)) {
                    JsonObject vendor = vendorsData.get(vendorId).getAsJsonObject();
                    
                    // Create a new object with combined information
                    JsonObject enrichedService = new JsonObject();
                    
                    // Copy service properties
                    for (String key : service.keySet()) {
                        enrichedService.add(key, service.get(key));
                    }
                    
                    // Add selected vendor properties
                    enrichedService.addProperty("vendorName", 
                        vendor.has("businessName") ? vendor.get("businessName").getAsString() : "Unknown Vendor");
                    enrichedService.addProperty("vendorRating", 
                        vendor.has("rating") ? vendor.get("rating").getAsDouble() : 0.0);
                    
                    enrichedServices.add(enrichedService);
                } else {
                    // No vendor info found, just use the service as is
                    enrichedServices.add(service);
                }
            } else {
                // No vendor ID in service, just use the service as is
                enrichedServices.add(service);
            }
        }
        
        return enrichedServices;
    }
}