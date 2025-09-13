<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%
    // Get current session information
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    boolean isLoggedIn = (username != null && !username.isEmpty());
    
    // Current date and time for documentation
    String currentDateTime = "2025-05-18 13:27:57";
    String currentUser = "IT24100905";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Marry Mate Terms of Service - Our legal agreement for using the wedding planning platform">
    <title>Terms of Service | Marry Mate</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
    <style>
        /* Simple Terms Page Styles */
        .terms-hero {
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            padding: 120px 0 60px;
            color: white;
            text-align: center;
        }
        
        .terms-hero h1 {
            color: white;
            margin-bottom: 20px;
        }
        
        .terms-content {
            padding: 60px 0;
        }
        
        .terms-section {
            margin-bottom: 40px;
        }
        
        .terms-section h2 {
            margin-bottom: 20px;
            color: var(--primary);
            font-size: 1.8rem;
        }
        
        .terms-section h3 {
            font-size: 1.3rem;
            margin: 25px 0 15px;
            color: var(--primary);
        }
        
        .terms-section p {
            margin-bottom: 15px;
            line-height: 1.7;
        }
        
        .terms-section ul {
            padding-left: 20px;
            margin-bottom: 20px;
        }
        
        .terms-section li {
            margin-bottom: 10px;
        }
        
        .last-updated {
            color: var(--text-medium);
            margin-bottom: 30px;
            font-style: italic;
            text-align: center;
        }
    </style>
</head>

<body>
    <!-- Navigation Bar -->
    <nav class="navbar navbar-expand-lg navbar-light fixed-top">
        <div class="container">
            <!-- Logo -->
            <a class="navbar-brand" href="${pageContext.request.contextPath}/">
                <div class="logo-container">
                    <i class="fas fa-heart"></i>
                    <i class="fas fa-ring"></i>
                </div>
                <span>Marry Mate</span>
            </a>
            
            <!-- Mobile Toggle Button -->
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarContent" aria-controls="navbarContent" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <!-- Navigation Links -->
            <div class="collapse navbar-collapse" id="navbarContent">
                <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/VendorServicesServlet">Vendors</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/views/wedding-guides.jsp">Wedding Guides</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/views/about.jsp">About Us</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/views/contact.jsp">Contact</a>
                    </li>
                </ul>
                
                <!-- Authentication Buttons -->
                <div class="auth-buttons">
                    <% if (isLoggedIn) { %>
                        <div class="dropdown">
                            <button class="btn btn-outline-primary dropdown-toggle" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                <i class="fas fa-user-circle me-1"></i> <%= username %>
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="userDropdown">
                                <% if ("admin".equals(role)) { %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard.jsp">Admin Dashboard</a></li>
                                <% } else if ("super_admin".equals(role)) { %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard.jsp">Admin Dashboard</a></li>
                                <% } else if ("vendor".equals(role)) { %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/vendor/dashboard.jsp">Vendor Dashboard</a></li>
                                <% } else { %>
                                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/user/dashboard.jsp">My Dashboard</a></li>
                                <% } %>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/user/profile.jsp">Profile Settings</a></li>
                                <li><hr class="dropdown-divider"></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/LogoutServlet">Sign Out</a></li>
                            </ul>
                        </div>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline-primary me-2">Sign In</a>
                        <a href="${pageContext.request.contextPath}/signup.jsp" class="btn btn-primary">Join Now</a>
                    <% } %>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="terms-hero">
        <div class="container">
            <div class="row">
                <div class="col-lg-10 mx-auto text-center">
                    <h1>Terms of Service</h1>
                    <p class="lead">Please read these terms carefully before using our platform</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Terms Content -->
    <section class="terms-content">
        <div class="container">
            <div class="row">
                <div class="col-lg-10 mx-auto">
                    <p class="last-updated">Last Updated: April 15, 2025</p>
                    
                    <!-- Introduction -->
                    <div class="terms-section">
                        <h2>1. Introduction</h2>
                        <p>Welcome to Marry Mate! These Terms of Service ("Terms") govern your use of the Marry Mate website, mobile applications, and services (collectively, the "Platform"). By accessing or using our Platform, you agree to be bound by these Terms, our Privacy Policy, and all applicable laws and regulations. If you do not agree to these Terms, please do not use our Platform.</p>
                        <p>Marry Mate is a wedding planning platform that connects couples with wedding vendors and provides tools for planning and organizing weddings.</p>
                    </div>
                    
                    <!-- User Accounts -->
                    <div class="terms-section">
                        <h2>2. User Accounts</h2>
                        <p>To access certain features of our Platform, you must create an account. You are responsible for maintaining the confidentiality of your account information and for all activities that occur under your account. You agree to:</p>
                        <ul>
                            <li>Provide accurate, current, and complete information during registration</li>
                            <li>Maintain and promptly update your account information</li>
                            <li>Keep your password secure and confidential</li>
                            <li>Notify us immediately of any unauthorized use of your account</li>
                        </ul>
                        <p>We reserve the right to suspend or terminate accounts that violate our Terms or for any other reason at our sole discretion.</p>
                    </div>
                    
                    <!-- Use of Services -->
                    <div class="terms-section">
                        <h2>3. Use of Services</h2>
                        <p>You agree to use our Platform only for lawful purposes and in accordance with these Terms. You agree not to:</p>
                        <ul>
                            <li>Use the Platform in any way that violates any applicable law or regulation</li>
                            <li>Impersonate any person or entity, or falsely state or misrepresent your affiliation with a person or entity</li>
                            <li>Engage in any conduct that restricts or inhibits anyone's use of the Platform</li>
                            <li>Use the Platform to send spam, bulk, or unsolicited communications</li>
                            <li>Attempt to gain unauthorized access to any portion of the Platform</li>
                            <li>Use any robot, spider, or other automatic device to access the Platform</li>
                        </ul>
                    </div>
                    
                    <!-- Vendor Services -->
                    <div class="terms-section">
                        <h2>4. Vendor Services</h2>
                        <p>Marry Mate serves as a platform connecting couples with wedding vendors. While we strive to feature reputable vendors, we do not guarantee the quality, safety, or legality of vendor services. You acknowledge that:</p>
                        <ul>
                            <li>Marry Mate is not responsible for the services provided by vendors</li>
                            <li>Any contracts or agreements formed between users and vendors are solely between those parties</li>
                            <li>You should verify all information provided by vendors and conduct your own due diligence</li>
                            <li>Any payments made to vendors are processed according to the terms of our payment providers</li>
                        </ul>
                    </div>
                    
                    <!-- User-Generated Content -->
                    <div class="terms-section">
                        <h2>5. User-Generated Content</h2>
                        <p>Our Platform may allow you to post reviews, comments, and other content. You retain ownership of any content you submit, but grant Marry Mate a worldwide, non-exclusive, royalty-free license to use, reproduce, modify, publish, and display such content. You agree not to post content that:</p>
                        <ul>
                            <li>Is unlawful, harmful, threatening, abusive, or defamatory</li>
                            <li>Infringes on the intellectual property rights of others</li>
                            <li>Contains viruses, malware, or other harmful code</li>
                            <li>Violates the privacy or publicity rights of any third party</li>
                            <li>Is false, misleading, or fraudulent</li>
                        </ul>
                        <p>We reserve the right to remove any content at our sole discretion.</p>
                    </div>
                    
                    <!-- Termination -->
                    <div class="terms-section">
                        <h2>6. Termination</h2>
                        <p>We may terminate or suspend your account and access to the Platform immediately, without prior notice or liability, for any reason, including if you breach these Terms. Upon termination, your right to use the Platform will immediately cease.</p>
                    </div>
                    
                    <!-- Disclaimer of Warranties -->
                    <div class="terms-section">
                        <h2>7. Disclaimer of Warranties</h2>
                        <p>THE PLATFORM IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT ANY WARRANTIES OF ANY KIND. MARRY MATE DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.</p>
                    </div>
                    
                    <!-- Limitation of Liability -->
                    <div class="terms-section">
                        <h2>8. Limitation of Liability</h2>
                        <p>IN NO EVENT SHALL MARRY MATE BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING OUT OF OR RELATING TO YOUR USE OF THE PLATFORM.</p>
                    </div>
                    
                    <!-- Changes to Terms -->
                    <div class="terms-section">
                        <h2>9. Changes to Terms</h2>
                        <p>We may modify these Terms at any time by posting the revised Terms on our Platform. Your continued use of the Platform after any such changes constitutes your acceptance of the new Terms.</p>
                    </div>
                    
                    <!-- Contact Information -->
                    <div class="terms-section">
                        <h2>10. Contact Information</h2>
                        <p>If you have any questions about these Terms, please contact us at:</p>
                        <p>Email: support@marrymate.com<br>
                        Phone: +94 703 638 365<br>
                        Address: Sri Lanka Institute of Information Technology (SLIIT), New Kandy Road, Malabe, Sri Lanka</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Footer -->
    <footer class="main-footer">
        <div class="container">
            <div class="footer-content">
                <div class="row">
                    <div class="col-md-4 mb-4">
                        <div class="footer-logo">
                            <div class="logo-icon">
                                <i class="fas fa-heart"></i>
                                <i class="fas fa-ring"></i>
                            </div>
                            <h3>Marry Mate</h3>
                        </div>
                        <p>Your complete wedding planning and vendor booking platform. Making dream weddings come true since 2020.</p>
                        <div class="social-icons">
                            <a href="https://www.facebook.com/janith.deshan.186"><i class="fab fa-facebook-f"></i></a>
                            <a href="https://www.instagram.com/janith_deshan11/"><i class="fab fa-instagram"></i></a>
                            <a href="https://www.linkedin.com/in/janith-deshan-60089a194/"><i class="fab fa-linkedin-in"></i></a>
                        </div>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>Quick Links</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/VendorServicesServlet">Find Vendors</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/wedding-guides.jsp">Wedding Guides</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/about.jsp">About Us</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/contact.jsp">Contact</a></li>
                            
                        </ul>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>For Couples</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/signup.jsp">Sign Up</a></li>
                            <li><a href="${pageContext.request.contextPath}/user/dashboard.jsp">Wedding Dashboard</a></li>
                        </ul>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>For Vendors</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/signup.jsp">Join now</a></li>
                            <li><a href="${pageContext.request.contextPath}/vendor/dashboard.jsp">Vendor Dashboard</a></li>

                        </ul>
                    </div>
                    
                    <div class="col-md-2 col-6 mb-4">
                        <h4>Support</h4>
                        <ul class="footer-links">
                            <li><a href="${pageContext.request.contextPath}/views/terms.jsp">Terms of Service</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/privacy.jsp">Privacy Policy</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/contact.jsp">Contact Support</a></li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <div class="footer-bottom">
                <div class="row align-items-center">
                    <div class="col-md-6">
                        <p>&copy; 2025 Marry Mate. All rights reserved. | Developer: IT24102137</p>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <ul class="footer-bottom-links">
                            <li><a href="${pageContext.request.contextPath}/views/terms.jsp">Terms</a></li>
                            <li><a href="${pageContext.request.contextPath}/views/privacy.jsp">Privacy
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </footer>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/index.js"></script>
    <script>
        // Simple script to handle navbar scrolling
        document.addEventListener('DOMContentLoaded', function() {
            const navbar = document.querySelector('.navbar');
            
            function handleScroll() {
                if (window.scrollY > 100) {
                    navbar.classList.add('scrolled');
                } else {
                    navbar.classList.remove('scrolled');
                }
            }
            
            window.addEventListener('scroll', handleScroll);
            handleScroll();
        });
    </script>
</body>
</html>