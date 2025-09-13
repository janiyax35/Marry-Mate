package com.MarryMate.servlets;

import com.MarryMate.models.Vendor;
import com.MarryMate.services.VendorManagementService;
import com.MarryMate.services.AuthService;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Servlet handling Vendor Management operations
 * Maps to /VendorManagementServlet endpoint
 * 
 * Current Date and Time: 2025-05-18 17:44:58
 * Current User: IT24102137
 */
@WebServlet("/VendorManagementServlet/*")
public class VendorManagementServlet extends HttpServlet {
    
    private static final long serialVersionUID = 1L;
    private VendorManagementService vendorService;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        super.init();
        vendorService = new VendorManagementService();
        gson = new Gson();
    }
    
    /**
     * Handle GET requests for retrieving vendor data
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        
        // Handle export requests
        if (pathInfo != null && pathInfo.equals("/export")) {
            processExportVendors(request, response);
            return;
        }
        
        // Get a specific vendor by ID
        String vendorId = request.getParameter("vendorId");
        if (vendorId != null && !vendorId.trim().isEmpty()) {
            processGetVendorById(vendorId, response);
            return;
        }
        
        // Handle filtering and search
        String status = request.getParameter("status");
        String category = request.getParameter("category");
        String dateRange = request.getParameter("dateRange");
        String search = request.getParameter("search");
        
        if (status != null || category != null || dateRange != null || search != null) {
            processFilterVendors(status, category, dateRange, search, response);
        } else {
            // Get all vendors
            processGetAllVendors(response);
        }
    }
    
    /**
     * Handle POST requests for creating new vendors
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Read the request body to get JSON data
        String requestBody = readRequestBody(request);
        
        try {
            // Convert JSON to a map of vendor data
            Map<String, Object> vendorData = parseJsonToMap(requestBody);
            
            // Create the vendor
            Vendor newVendor = vendorService.createVendor(vendorData);
            
            // Reload data in AuthService to synchronize changes
            try {
                AuthService authService = AuthService.getInstance(getServletContext());
                authService.reloadData();
                System.out.println("VendorManagementServlet: AuthService data reloaded after vendor creation");
            } catch (Exception e) {
                // Log the error but continue with the response
                System.err.println("Error reloading AuthService data: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Send success response
            sendJsonResponse(response, HttpServletResponse.SC_CREATED, 
                    createSuccessResponse("Vendor created successfully", newVendor));
                    
        } catch (Exception e) {
            // Handle errors
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, 
                    "Failed to create vendor: " + e.getMessage());
        }
    }
    
    /**
     * Handle PUT requests for updating existing vendors
     */
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Read the request body to get JSON data
        String requestBody = readRequestBody(request);
        
        try {
            // Convert JSON to a map of vendor data
            Map<String, Object> vendorData = parseJsonToMap(requestBody);
            
            // Extract vendorId from the data
            String vendorId = (String) vendorData.get("vendorId");
            if (vendorId == null || vendorId.trim().isEmpty()) {
                throw new IllegalArgumentException("Vendor ID is required");
            }
            
            // Update the vendor
            Vendor updatedVendor = vendorService.updateVendor(vendorId, vendorData);
            
            // Reload data in AuthService to synchronize changes
            try {
                AuthService authService = AuthService.getInstance(getServletContext());
                authService.reloadData();
                System.out.println("VendorManagementServlet: AuthService data reloaded after vendor update");
            } catch (Exception e) {
                // Log the error but continue with the response
                System.err.println("Error reloading AuthService data: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Send success response
            sendJsonResponse(response, HttpServletResponse.SC_OK, 
                    createSuccessResponse("Vendor updated successfully", updatedVendor));
                    
        } catch (Exception e) {
            // Handle errors
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, 
                    "Failed to update vendor: " + e.getMessage());
        }
    }
    
    /**
     * Handle DELETE requests for removing vendors
     */
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get the vendor ID from the request
        String vendorId = request.getParameter("vendorId");
        
        if (vendorId == null || vendorId.trim().isEmpty()) {
            sendErrorResponse(response, HttpServletResponse.SC_BAD_REQUEST, 
                    "Vendor ID is required");
            return;
        }
        
        try {
            // Delete the vendor
            boolean deleted = vendorService.deleteVendor(vendorId);
            
            if (deleted) {
                // Reload data in AuthService to synchronize changes
                try {
                    AuthService authService = AuthService.getInstance(getServletContext());
                    authService.reloadData();
                    System.out.println("VendorManagementServlet: AuthService data reloaded after vendor deletion");
                } catch (Exception e) {
                    // Log the error but continue with the response
                    System.err.println("Error reloading AuthService data: " + e.getMessage());
                    e.printStackTrace();
                }
                
                // Send success response
                sendJsonResponse(response, HttpServletResponse.SC_OK, 
                        createSuccessResponse("Vendor deleted successfully", null));
            } else {
                // Vendor not found
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, 
                        "Vendor with ID " + vendorId + " not found");
            }
            
        } catch (Exception e) {
            // Handle errors
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    "Failed to delete vendor: " + e.getMessage());
        }
    }
    
    /**
     * Process a request to get all vendors
     * @param response HTTP response
     * @throws IOException If an I/O error occurs
     */
    private void processGetAllVendors(HttpServletResponse response) throws IOException {
        try {
            List<Vendor> vendors = vendorService.getAllVendors();
            sendJsonResponse(response, HttpServletResponse.SC_OK, vendors);
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    "Failed to retrieve vendors: " + e.getMessage());
        }
    }
    
    /**
     * Process a request to get a specific vendor by ID
     * @param vendorId Vendor ID to retrieve
     * @param response HTTP response
     * @throws IOException If an I/O error occurs
     */
    private void processGetVendorById(String vendorId, HttpServletResponse response) throws IOException {
        try {
            Optional<Vendor> vendor = vendorService.getVendorById(vendorId);
            
            if (vendor.isPresent()) {
                sendJsonResponse(response, HttpServletResponse.SC_OK, vendor.get());
            } else {
                sendErrorResponse(response, HttpServletResponse.SC_NOT_FOUND, 
                        "Vendor with ID " + vendorId + " not found");
            }
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    "Failed to retrieve vendor: " + e.getMessage());
        }
    }
    
    /**
     * Process a request to filter vendors
     * @param status Status filter criteria
     * @param category Category filter criteria
     * @param dateRange Date range filter criteria
     * @param search Search term filter criteria
     * @param response HTTP response
     * @throws IOException If an I/O error occurs
     */
    private void processFilterVendors(String status, String category, String dateRange, String search, 
            HttpServletResponse response) throws IOException {
        try {
            List<Vendor> filteredVendors = vendorService.filterVendors(status, category, dateRange, search);
            sendJsonResponse(response, HttpServletResponse.SC_OK, filteredVendors);
        } catch (Exception e) {
            sendErrorResponse(response, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, 
                    "Failed to filter vendors: " + e.getMessage());
        }
    }
    
    /**
     * Process a request to export vendors
     * @param request HTTP request
     * @param response HTTP response
     * @throws IOException If an I/O error occurs
     */
    private void processExportVendors(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        
        String format = request.getParameter("format");
        String status = request.getParameter("status");
        String category = request.getParameter("category");
        String dateRange = request.getParameter("dateRange");
        String search = request.getParameter("search");
        
        if (format == null || format.trim().isEmpty()) {
            format = "csv"; // Default format
        }
        
        try {
            // Get filtered vendors
            List<Vendor> vendors = vendorService.filterVendors(status, category, dateRange, search);
            
            // Set response headers based on format
            switch (format.toLowerCase()) {
                case "excel":
                    response.setContentType("application/vnd.ms-excel");
                    response.setHeader("Content-Disposition", "attachment; filename=vendors.xls");
                    vendorService.exportVendorsToExcel(vendors, response.getOutputStream());
                    break;
                    
                case "pdf":
                    response.setContentType("application/pdf");
                    response.setHeader("Content-Disposition", "attachment; filename=vendors.pdf");
                    vendorService.exportVendorsToPDF(vendors, response.getOutputStream());
                    break;
                    
                case "csv":
                default:
                    response.setContentType("text/csv");
                    response.setHeader("Content-Disposition", "attachment; filename=vendors.csv");
                    vendorService.exportVendorsToCSV(vendors, response.getOutputStream());
                    break;
            }
            
        } catch (Exception e) {
            response.setContentType("text/plain");
            PrintWriter out = response.getWriter();
            out.println("Error exporting vendors: " + e.getMessage());
        }
    }
    
    /**
     * Read the request body into a string
     * @param request HTTP request
     * @return Request body as string
     * @throws IOException If an I/O error occurs
     */
    private String readRequestBody(HttpServletRequest request) throws IOException {
        StringBuilder sb = new StringBuilder();
        String line;
        
        try (BufferedReader reader = request.getReader()) {
            while ((line = reader.readLine()) != null) {
                sb.append(line);
            }
        }
        
        return sb.toString();
    }
    
    /**
     * Parse JSON string to a map of objects
     * @param json JSON string
     * @return Map of key-value pairs
     */
    private Map<String, Object> parseJsonToMap(String json) {
        Map<String, Object> map = new HashMap<>();
        
        JsonObject jsonObject = JsonParser.parseString(json).getAsJsonObject();
        
        for (String key : jsonObject.keySet()) {
            if (!jsonObject.get(key).isJsonNull()) {
                if (jsonObject.get(key).isJsonPrimitive()) {
                    map.put(key, jsonObject.get(key).getAsString());
                } else if (jsonObject.get(key).isJsonArray()) {
                    // Handle arrays (like categories and serviceIds)
                    map.put(key, gson.fromJson(jsonObject.get(key), List.class));
                } else {
                    // For complex objects
                    map.put(key, gson.fromJson(jsonObject.get(key), Object.class));
                }
            }
        }
        
        return map;
    }
    
    /**
     * Send a JSON response
     * @param response HTTP response
     * @param status HTTP status code
     * @param data Data object to convert to JSON
     * @throws IOException If an I/O error occurs
     */
    private void sendJsonResponse(HttpServletResponse response, int status, Object data) 
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(status);
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(data));
        out.flush();
    }
    
    /**
     * Send an error response
     * @param response HTTP response
     * @param status HTTP status code
     * @param message Error message
     * @throws IOException If an I/O error occurs
     */
    private void sendErrorResponse(HttpServletResponse response, int status, String message) 
            throws IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        response.setStatus(status);
        
        JsonObject errorJson = new JsonObject();
        errorJson.addProperty("success", false);
        errorJson.addProperty("message", message);
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(errorJson));
        out.flush();
    }
    
    /**
     * Create a success response object
     * @param message Success message
     * @param data Data to include (optional)
     * @return Map representing the response
     */
    private Map<String, Object> createSuccessResponse(String message, Object data) {
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", message);
        
        if (data != null) {
            response.put("data", data);
        }
        
        return response;
    }
}