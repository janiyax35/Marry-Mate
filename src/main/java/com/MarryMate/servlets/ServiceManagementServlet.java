package com.MarryMate.servlets;

import com.MarryMate.services.ServiceManagementService;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * Servlet implementation class ServiceManagementServlet
 * Current Date and Time: 2025-05-18 11:06:06
 * Current User: IT24102137
 */
@WebServlet(urlPatterns = {
    "/ServiceManagementServlet",
    "/admin/ServiceManagementServlet"
})
public class ServiceManagementServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    // Fixed file paths
    private static final String SERVICES_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendorServices.json";
    private static final String CATEGORIES_FILE_PATH = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\service-categories.json";
    
    private ServiceManagementService serviceManager;
    private Gson gson;
    
    /**
     * Initialize the servlet
     */
    @Override
    public void init() throws ServletException {
        // Use the constructor with two String parameters
        serviceManager = new ServiceManagementService(SERVICES_FILE_PATH, CATEGORIES_FILE_PATH);
        gson = new GsonBuilder().setPrettyPrinting().create();
    }
    
    /**
     * Handle GET requests (retrieve services)
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(serviceManager.getAllServices()));
    }
    
    /**
     * Handle POST requests (create service)
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Implementation details omitted for brevity
        response.setContentType("application/json");
        response.getWriter().write("{\"status\":\"success\",\"message\":\"Service management is working!\"}");
    }
}