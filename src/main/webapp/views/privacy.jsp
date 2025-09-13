<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%
    // Get current session information
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    boolean isLoggedIn = (username != null && !username.isEmpty());
    
    // Current date and time for documentation
    String currentDateTime = "2025-05-18 13:31:51";
    String currentUser = "IT24100905";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Marry Mate Privacy Policy - Learn how we protect your personal information">
    <title>Privacy Policy | Marry Mate</title>
    
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
        /* Simple Privacy Page Styles */
        .privacy-hero {
            background: linear-gradient(135deg, #2d5a92, #1a365d);
            padding: 120px 0 60px;
            color: white;
            text-align: center;
            position: relative;
            overflow: hidden;
        }
        
        .privacy-hero:before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background-image: url('https://images.unsplash.com/photo-1515934751635-c81c6bc9a2d8?ixlib=rb-1.2.1&auto=format&fit=crop&w=1950&q=80');
            background-size: cover;
            background-position: center;
            opacity: 0.1;
            z-index: 0;
        }
        
        .privacy-hero .container {
            position: relative;
            z-index: 1;
        }
        
        .privacy-hero h1 {
            color: white;
            margin-bottom: 20px;
        }
        
        .privacy-content {
            padding: 60px 0;
        }
        
        .policy-section {
            background: white;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 5px 20px rgba(0, 0, 0, 0.05);
            transition: transform 0.3s;
        }
        
        .policy-section:hover {
            transform: translateY(-5px);
            box-shadow: 0 8px 25px rgba(0, 0, 0, 0.1);
        }
        
        .policy-section h2 {
            margin-bottom: 20px;
            color: var(--primary);
            font-size: 1.8rem;
            padding-bottom: 10px;
            border-bottom: 2px solid rgba(26, 54, 93, 0.1);
        }
        
        .policy-section h3 {
            font-size: 1.3rem;
            margin: 25px 0 15px;
            color: var(--primary);
        }
        
        .policy-section p {
            margin-bottom: 15px;
            line-height: 1.7;
        }
        
        .policy-section ul {
            padding-left: 20px;
            margin-bottom: 20px;
        }
        
        .policy-section li {
            margin-bottom: 10px;
        }
        
        .policy-icon {
            display: inline-block;
            width: 60px;
            height: 60px;
            background: linear-gradient(135deg, rgba(26, 54, 93, 0.1), rgba(26, 54, 93, 0.05));
            border-radius: 50%;
            text-align: center;
            line-height: 60px;
            margin-right: 15px;
            float: left;
        }
        
        .policy-icon i {
            font-size: 1.5rem;
            color: var(--primary);
        }
        
        .policy-header {
            display: flex;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .policy-header h2 {
            margin-bottom: 0;
            border-bottom: none;
            padding-bottom: 0;
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
    <section class="privacy-hero">
        <div class="container">
            <div class="row">
                <div class="col-lg-10 mx-auto text-center">
                    <h1>Privacy Policy</h1>
                    <p class="lead">How we collect, use, and protect your personal information</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Privacy Content -->
    <section class="privacy-content">
        <div class="container">
            <div class="row">
                <div class="col-lg-10 mx-auto">
                    <p class="last-updated">Last Updated: April 15, 2025</p>
                    
                    <!-- Introduction -->
                    <div class="policy-section">
                        <div class="policy-header">
                            <div class="policy-icon">
                                <i class="fas fa-shield-alt"></i>
                            </div>
                            <h2>Introduction</h2>
                        </div>
                        <p>At Marry Mate, we respect your privacy and are committed to protecting your personal data. This Privacy Policy explains how we collect, use, disclose, and safeguard your information when you use our wedding planning platform.</p>
                        <p>Please read this Privacy Policy carefully. By using our services, you consent to the practices described in this policy.</p>
                    </div>
                    
                    <!-- Information We Collect -->
                    <div class="policy-section">
                        <div class="policy-header">
                            <div class="policy-icon">
                                <i class="fas fa-database"></i>
                            </div>
                            <h2>Information We Collect</h2>
                        </div>
                        <p>We collect several types of information from and about users of our platform:</p>
                        <ul>
                            <li><strong>Account Information:</strong> When you register, we collect your name, email address, phone number, and account credentials.</li>
                            <li><strong>Profile Information:</strong> Wedding date, location, budget, and preferences.</li>
                            <li><strong>Usage Data:</strong> Information about how you use our platform, including pages visited and features used.</li>
                            <li><strong>Device Information:</strong> IP address, browser type, operating system, and device identifiers.</li>
                            <li><strong>Communication Data:</strong> Messages exchanged between you and vendors or our support team.</li>
                        </ul>
                    </div>
                    
                    <!-- How We Use Information -->
                    <div class="policy-section">
                        <div class="policy-header">
                            <div class="policy-icon">
                                <i class="fas fa-cogs"></i>
                            </div>
                            <h2>How We Use Your Information</h2>
                        </div>
                        <p>We use your information for various purposes, including:</p>
                        <ul>
                            <li>Creating and managing your account</li>
                            <li>Connecting you with wedding vendors</li>
                            <li>Providing and improving our planning tools</li>
                            <li>Personalizing your experience</li>
                            <li>Communicating with you about our services</li>
                            <li>Processing payments and transactions</li>
                            <li>Analyzing usage to improve our platform</li>
                            <li>Protecting against fraudulent or unauthorized activity</li>
                        </ul>
                    </div>
                    
                    <!-- Information Sharing -->
                    <div class="policy-section">
                        <div class="policy-header">
                            <div class="policy-icon">
                                <i class="fas fa-share-alt"></i>
                            </div>
                            <h2>Information Sharing</h2>
                        </div>
                        <p>We may share your information with:</p>
                        <ul>
                            <li><strong>Vendors:</strong> When you express interest in or book services, we share relevant information with the vendors.</li>
                            <li><strong>Service Providers:</strong> Third parties that help us operate our platform (payment processors, analytics providers, etc.).</li>
                            <li><strong>Legal Requirements:</strong> When required by law or to protect our rights.</li>
                        </ul>
                        <p>We do not sell your personal information to third parties.</p>
                    </div>
                    
                    <!-- Cookies -->
                    <div class="policy-section">
                        <div class="policy-header">
                            <div class="policy-icon">
                                <i class="fas fa-cookie-bite"></i>
                            </div>
                            <h2>Cookies and Tracking</h2>
                        </div>
                        <p>We use cookies and similar technologies to enhance your experience, gather information about how users interact with our platform, and improve our services.</p>
                        <p>Types of cookies we use:</p>
                        <ul>
                            <li><strong>Essential Cookies:</strong> Required for the platform to function.</li>
                            <li><strong>Functional Cookies:</strong> Remember your preferences and settings.</li>
                            <li><strong>Analytics Cookies:</strong> Help us understand how users navigate our platform.</li>
                        </ul>
                        <p>You can manage your cookie preferences through your browser settings.</p>
                    </div>
                    
                    <!-- Data Security -->
                    <div class="policy-section">
                        <div class="policy-header">
                            <div class="policy-icon">
                                <i class="fas fa-lock"></i>
                            </div>
                            <h2>Data Security</h2>
                        </div>
                        <p>We implement appropriate technical and organizational measures to protect your personal information. However, no method of transmission over the Internet or electronic storage is 100% secure.</p>
                        <p>We regularly review our security practices and update them as necessary.</p>
                    </div>
                    
                    <!-- Your Rights -->
                    <div class="policy-section">
                        <div class="policy-header">
                            <div class="policy-icon">
                                <i class="fas fa-user-shield"></i>
                            </div>
                            <h2>Your Privacy Rights</h2>
                        </div>
                        <p>Depending on your location, you may have the following rights:</p>
                        <ul>
                            <li>Access your personal information</li>
                            <li>Correct inaccurate information</li>
                            <li>Delete your information</li>
                            <li>Object to certain processing activities</li>
                            <li>Data portability</li>
                            <li>Withdraw consent</li>
                        </ul>
                        <p>To exercise these rights, please contact us using the information provided below.</p>
                    </div>
                    
                    <!-- Changes to Privacy Policy -->
                    <div class="policy-section">
                        <div class="policy-header">
                            <div class="policy-icon">
                                <i class="fas fa-sync-alt"></i>
                            </div>
                            <h2>Changes to This Policy</h2>
                        </div>
                        <p>We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page and updating the "Last Updated" date.</p>
                        <p>We encourage you to review this Privacy Policy periodically for any changes.</p>
                    </div>
                    
                    <!-- Contact Information -->
                    <div class="policy-section">
                        <div class="policy-header">
                            <div class="policy-icon">
                                <i class="fas fa-envelope"></i>
                            </div>
                            <h2>Contact Us</h2>
                        </div>
                        <p>If you have any questions about this Privacy Policy, please contact us at:</p>
                        <p>
                            <strong>Marry Mate</strong><br>
                            Sri Lanka Institute of Information Technology (SLIIT)<br>
                            New Kandy Road, Malabe<br>
                            Sri Lanka
                        </p>
                        <p>
                            <strong>Email:</strong> privacy@marrymate.com<br>
                            <strong>Phone:</strong> +94 703 638 365
                        </p>
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