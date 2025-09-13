<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ page import="java.util.Date" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Montserrat:wght@300;400;600;700&family=Poppins:wght@300;400;500;600&display=swap" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- AOS Animations -->
    <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="error-404.css">
</head>
<body>
    <div class="error-container">
        <div class="container">
            <div class="row min-vh-100 align-items-center justify-content-center">
                <div class="col-lg-10">
                    <div class="error-content text-center" data-aos="fade-up" data-aos-duration="1000">
                        <div class="error-number" data-aos="zoom-in" data-aos-delay="200">
                            <span>4</span>
                            <i class="fa-solid fa-compass fa-spin"></i>
                            <span>4</span>
                        </div>
                        <h1 class="error-title" data-aos="fade-up" data-aos-delay="400">Page Not Found</h1>
                        <p class="error-text" data-aos="fade-up" data-aos-delay="600">
                            The page you are looking for might have been removed, had its name changed, 
                            or is temporarily unavailable.
                        </p>
                        
                        <div class="error-actions" data-aos="fade-up" data-aos-delay="800">
                            <a href="/" class="btn btn-primary btn-lg">
                                <i class="fa-solid fa-house"></i> Back to Home
                            </a>
                            <a href="javascript:history.back()" class="btn btn-outline-primary btn-lg ms-3">
                                <i class="fa-solid fa-arrow-left"></i> Go Back
                            </a>
                        </div>
                        
                        <div class="error-footer mt-5" data-aos="fade-up" data-aos-delay="1000">
                            <div class="row">
                                <div class="col-md-4" data-aos="fade-right" data-aos-delay="1200">
                                    <div class="error-help">
                                        <i class="fa-solid fa-search"></i>
                                        <h4>Search for content</h4>
                                        <p>Try finding what you need through our search feature</p>
                                    </div>
                                </div>
                                <div class="col-md-4" data-aos="fade-up" data-aos-delay="1400">
                                    <div class="error-help">
                                        <i class="fa-solid fa-sitemap"></i>
                                        <h4>Visit Sitemap</h4>
                                        <p>Browse our website structure to find what you need</p>
                                    </div>
                                </div>
                                <div class="col-md-4" data-aos="fade-left" data-aos-delay="1600">
                                    <div class="error-help">
                                        <i class="fa-solid fa-headset"></i>
                                        <h4>Contact Support</h4>
                                        <p>Get in touch with our support team for assistance</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Wave animation footer -->
        <div class="ocean">
            <div class="wave"></div>
            <div class="wave"></div>
        </div>
    </div>

    <!-- Bootstrap JS Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- AOS Animation JS -->
    <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>
    
    <!-- Custom JS -->
    <script src="error-404.js"></script>
</body>
</html>