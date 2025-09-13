<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%
    // Get current session information
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    boolean isLoggedIn = (username != null && !username.isEmpty());
    
    // Generate timestamp for analytics
    String accessTimestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    
    // Current date and time for documentation
    String currentDateTime = "2025-05-18 13:16:36";
    String currentUser = "IT24100905";
    
    // Page parameters
    String category = request.getParameter("category");
    if (category == null) category = "all";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Marry Mate Wedding Guides - Comprehensive wedding planning resources, tips, and inspiration for your perfect day">
    <title>Wedding Guides | Marry Mate</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- AOS - Animate On Scroll -->
    <link rel="stylesheet" href="https://unpkg.com/aos@next/dist/aos.css" />
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/index.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/others/wedding-guides.css">
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/views/wedding-guides.jsp">Wedding Guides</a>
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
    <section class="guide-hero">
        <div class="overlay"></div>
        <div class="container">
            <div class="row">
                <div class="col-lg-8 mx-auto text-center" data-aos="fade-up">
                    <h1>Wedding Planning Guides</h1>
                    <p class="lead">Expert advice, inspiration, and checklists to help you create your perfect day.</p>
                    
                    <!-- Search Form -->
                    <div class="search-container mt-4">
                        <form action="${pageContext.request.contextPath}/views/wedding-guides.jsp" method="get" class="guide-search-form">
                            <div class="input-group">
                                <input type="text" class="form-control" placeholder="Search for guides, tips, or topics..." name="search" aria-label="Search for guides">
                                <button class="btn btn-primary" type="submit">
                                    <i class="fas fa-search"></i>
                                    <span class="d-none d-md-inline ms-2">Search</span>
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Guide Categories -->
    <section class="guide-categories section-padding">
        <div class="container">
            <div class="section-header text-center" data-aos="fade-up">
                <h2>Explore Planning Topics</h2>
                <p>Find guidance for every aspect of your wedding journey</p>
            </div>
            
            <div class="category-filters text-center mb-5" data-aos="fade-up">
                <a href="${pageContext.request.contextPath}/views/wedding-guides.jsp" class="category-filter-btn <%= "all".equals(category) ? "active" : "" %>">All Guides</a>
                <a href="${pageContext.request.contextPath}/views/wedding-guides.jsp?category=planning" class="category-filter-btn <%= "planning".equals(category) ? "active" : "" %>">Planning</a>
                <a href="${pageContext.request.contextPath}/views/wedding-guides.jsp?category=budget" class="category-filter-btn <%= "budget".equals(category) ? "active" : "" %>">Budget</a>
                <a href="${pageContext.request.contextPath}/views/wedding-guides.jsp?category=venues" class="category-filter-btn <%= "venues".equals(category) ? "active" : "" %>">Venues</a>
                <a href="${pageContext.request.contextPath}/views/wedding-guides.jsp?category=fashion" class="category-filter-btn <%= "fashion".equals(category) ? "active" : "" %>">Fashion</a>
                <a href="${pageContext.request.contextPath}/views/wedding-guides.jsp?category=decor" class="category-filter-btn <%= "decor".equals(category) ? "active" : "" %>">Decor & Themes</a>
                <a href="${pageContext.request.contextPath}/views/wedding-guides.jsp?category=etiquette" class="category-filter-btn <%= "etiquette".equals(category) ? "active" : "" %>">Etiquette</a>
            </div>
            
            <!-- Featured Planning Guide -->
            <div class="featured-guide mb-5" data-aos="fade-up">
                <div class="row align-items-center">
                    <div class="col-lg-6 mb-4 mb-lg-0">
                        <div class="featured-guide-img">
                            <img src="https://images.unsplash.com/photo-1465495976277-4387d4b0b4c6?ixlib=rb-1.2.1&auto=format&fit=crop&w=1000&q=80" alt="12-Month Wedding Planning Timeline" class="img-fluid">
                            <div class="featured-badge">
                                <i class="fas fa-star"></i> Featured Guide
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-6">
                        <div class="featured-guide-content">
                            <div class="guide-category">Planning Essentials</div>
                            <h3>The Complete 12-Month Wedding Planning Timeline</h3>
                            <p>Stay on track with our comprehensive month-by-month wedding checklist, from engagement to your big day. Our expert planners guide you through each step to ensure nothing is overlooked.</p>
                            <ul class="guide-highlights">
                                <li><i class="fas fa-check-circle"></i> Printable 12-month checklist</li>
                                <li><i class="fas fa-check-circle"></i> Budget allocation guidelines</li>
                                <li><i class="fas fa-check-circle"></i> Vendor booking timelines</li>
                                <li><i class="fas fa-check-circle"></i> Last-minute preparation tips</li>
                            </ul>
                            <a href="${pageContext.request.contextPath}/views/guide-details.jsp?id=1" class="btn btn-primary">Read Full Guide</a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Guides Grid -->
            <div class="row g-4">
                <!-- Guide 1 -->
                <div class="col-md-6 col-lg-4" data-aos="fade-up" data-aos-delay="100">
                    <div class="guide-card">
                        <div class="guide-img">
                            <img src="https://images.unsplash.com/photo-1532712938310-34cb3982ef74?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80" alt="Wedding Budget Guide" class="img-fluid">
                            <div class="guide-category">Budget</div>
                        </div>
                        <div class="guide-content">
                            <h3>How to Create Your Wedding Budget (With Sample Breakdowns)</h3>
                            <p>Learn how to allocate your funds wisely and create a realistic wedding budget that works for your dream celebration.</p>
                            <div class="guide-meta">
                                <span><i class="far fa-clock"></i> 12 min read</span>
                                <span><i class="far fa-calendar-alt"></i> Updated May 2025</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/views/guide-details.jsp?id=2" class="read-more">Read More <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
                
                <!-- Guide 2 -->
                <div class="col-md-6 col-lg-4" data-aos="fade-up" data-aos-delay="200">
                    <div class="guide-card">
                        <div class="guide-img">
                            <img src="https://images.unsplash.com/photo-1511795409834-ef04bbd61622?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80" alt="Choosing Wedding Venue" class="img-fluid">
                            <div class="guide-category">Venues</div>
                        </div>
                        <div class="guide-content">
                            <h3>10 Questions to Ask Before Booking Your Wedding Venue</h3>
                            <p>Ensure you're making the right choice by asking these essential questions when touring potential wedding venues.</p>
                            <div class="guide-meta">
                                <span><i class="far fa-clock"></i> 8 min read</span>
                                <span><i class="far fa-calendar-alt"></i> Updated April 2025</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/views/guide-details.jsp?id=3" class="read-more">Read More <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
                
                <!-- Guide 3 -->
                <div class="col-md-6 col-lg-4" data-aos="fade-up" data-aos-delay="300">
                    <div class="guide-card">
                        <div class="guide-img">
                            <img src="https://images.unsplash.com/photo-1460978812857-470ed1c77af0?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80" alt="Wedding Dress Shopping" class="img-fluid">
                            <div class="guide-category">Fashion</div>
                        </div>
                        <div class="guide-content">
                            <h3>Wedding Dress Shopping: A Complete Guide for Brides</h3>
                            <p>Tips for finding your perfect wedding dress, including when to shop, what to bring, and how to choose the right silhouette.</p>
                            <div class="guide-meta">
                                <span><i class="far fa-clock"></i> 15 min read</span>
                                <span><i class="far fa-calendar-alt"></i> Updated March 2025</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/views/guide-details.jsp?id=4" class="read-more">Read More <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
                
                <!-- Guide 4 -->
                <div class="col-md-6 col-lg-4" data-aos="fade-up" data-aos-delay="400">
                    <div class="guide-card">
                        <div class="guide-img">
                            <img src="https://images.unsplash.com/photo-1501901609772-df0848060b33?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80" alt="Wedding Guest List" class="img-fluid">
                            <div class="guide-category">Planning</div>
                        </div>
                        <div class="guide-content">
                            <h3>Creating and Managing Your Wedding Guest List</h3>
                            <p>Learn how to navigate the often challenging process of creating your guest list, with tips for managing family expectations.</p>
                            <div class="guide-meta">
                                <span><i class="far fa-clock"></i> 10 min read</span>
                                <span><i class="far fa-calendar-alt"></i> Updated May 2025</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/views/guide-details.jsp?id=5" class="read-more">Read More <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
                
                <!-- Guide 5 -->
                <div class="col-md-6 col-lg-4" data-aos="fade-up" data-aos-delay="500">
                    <div class="guide-card">
                        <div class="guide-img">
                            <img src="https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80" alt="Wedding Catering" class="img-fluid">
                            <div class="guide-category">Food & Drink</div>
                        </div>
                        <div class="guide-content">
                            <h3>The Ultimate Guide to Wedding Catering Options</h3>
                            <p>Explore different catering styles and service options to create the perfect dining experience for your wedding reception.</p>
                            <div class="guide-meta">
                                <span><i class="far fa-clock"></i> 11 min read</span>
                                <span><i class="far fa-calendar-alt"></i> Updated February 2025</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/views/guide-details.jsp?id=6" class="read-more">Read More <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
                
                <!-- Guide 6 -->
                <div class="col-md-6 col-lg-4" data-aos="fade-up" data-aos-delay="600">
                    <div class="guide-card">
                        <div class="guide-img">
                            <img src="https://images.unsplash.com/photo-1509610973147-232dfea52a97?ixlib=rb-1.2.1&auto=format&fit=crop&w=600&q=80" alt="Wedding Rings" class="img-fluid">
                            <div class="guide-category">Etiquette</div>
                        </div>
                        <div class="guide-content">
                            <h3>Modern Wedding Etiquette for Today's Couples</h3>
                            <p>Navigate traditional expectations and modern practices with our comprehensive guide to contemporary wedding etiquette.</p>
                            <div class="guide-meta">
                                <span><i class="far fa-clock"></i> 9 min read</span>
                                <span><i class="far fa-calendar-alt"></i> Updated April 2025</span>
                            </div>
                            <a href="${pageContext.request.contextPath}/views/guide-details.jsp?id=7" class="read-more">Read More <i class="fas fa-arrow-right"></i></a>
                        </div>
                    </div>
                </div>
            </div>
            
            <!-- Pagination -->
            <div class="guides-pagination mt-5" data-aos="fade-up">
                <nav aria-label="Wedding guides pagination">
                    <ul class="pagination justify-content-center">
                        <li class="page-item disabled">
                            <a class="page-link" href="#" tabindex="-1" aria-disabled="true">
                                <i class="fas fa-chevron-left"></i>
                            </a>
                        </li>
                        <li class="page-item active"><a class="page-link" href="#">1</a></li>
                        <li class="page-item"><a class="page-link" href="#">2</a></li>
                        <li class="page-item"><a class="page-link" href="#">3</a></li>
                        <li class="page-item">
                            <a class="page-link" href="#">
                                <i class="fas fa-chevron-right"></i>
                            </a>
                        </li>
                    </ul>
                </nav>
            </div>
        </div>
    </section>

    <!-- Curated Collections -->
    <section class="guide-collections section-padding bg-light">
        <div class="container">
            <div class="section-header text-center" data-aos="fade-up">
                <h2>Curated Guide Collections</h2>
                <p>Expertly assembled resources for every wedding planning stage</p>
            </div>
            
            <div class="row g-4">
                <!-- Collection 1 -->
                <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="100">
                    <div class="collection-card">
                        <div class="collection-icon">
                            <i class="fas fa-calendar-check"></i>
                        </div>
                        <h3>Just Engaged</h3>
                        <p>Essential first steps for newly engaged couples, from announcing your engagement to setting the date.</p>
                        <a href="${pageContext.request.contextPath}/views/guide-collection.jsp?collection=engaged" class="btn btn-outline-primary">View Collection</a>
                    </div>
                </div>
                
                <!-- Collection 2 -->
                <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="200">
                    <div class="collection-card">
                        <div class="collection-icon">
                            <i class="fas fa-dollar-sign"></i>
                        </div>
                        <h3>Budget Savvy</h3>
                        <p>Money-saving tips and strategies for planning a beautiful wedding without breaking the bank.</p>
                        <a href="${pageContext.request.contextPath}/views/guide-collection.jsp?collection=budget" class="btn btn-outline-primary">View Collection</a>
                    </div>
                </div>
                
                <!-- Collection 3 -->
                <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="300">
                    <div class="collection-card">
                        <div class="collection-icon">
                            <i class="fas fa-paint-brush"></i>
                        </div>
                        <h3>Decor & Themes</h3>
                        <p>Inspiration and practical advice for creating a cohesive and beautiful wedding aesthetic.</p>
                        <a href="${pageContext.request.contextPath}/views/guide-collection.jsp?collection=decor" class="btn btn-outline-primary">View Collection</a>
                    </div>
                </div>
                
                <!-- Collection 4 -->
                <div class="col-md-6 col-lg-3" data-aos="fade-up" data-aos-delay="400">
                    <div class="collection-card">
                        <div class="collection-icon">
                            <i class="fas fa-clock"></i>
                        </div>
                        <h3>Last Minute</h3>
                        <p>Crucial checklists and advice for couples in the final countdown to their wedding day.</p>
                        <a href="${pageContext.request.contextPath}/views/guide-collection.jsp?collection=lastminute" class="btn btn-outline-primary">View Collection</a>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Planning Tools Section -->
    <section class="planning-tools section-padding">
        <div class="container">
            <div class="section-header text-center" data-aos="fade-up">
                <h2>Wedding Planning Tools</h2>
                <p>Interactive resources to streamline your wedding planning process</p>
            </div>
            
            <div class="row g-4">
                <!-- Tool 1 -->
                <div class="col-md-6 col-lg-4" data-aos="fade-up" data-aos-delay="100">
                    <div class="tool-card">
                        <div class="tool-icon">
                            <i class="fas fa-tasks"></i>
                        </div>
                        <h3>Interactive Checklist</h3>
                        <p>A comprehensive, customizable checklist with deadline reminders to keep your planning on track.</p>
                        <a href="${pageContext.request.contextPath}/user/checklist.jsp" class="btn btn-primary">Access Tool</a>
                    </div>
                </div>
                
                <!-- Tool 2 -->
                <div class="col-md-6 col-lg-4" data-aos="fade-up" data-aos-delay="200">
                    <div class="tool-card">
                        <div class="tool-icon">
                            <i class="fas fa-calculator"></i>
                        </div>
                        <h3>Budget Calculator</h3>
                        <p>Allocate your wedding budget across different categories and track your spending in real time.</p>
                        <a href="${pageContext.request.contextPath}/user/budget.jsp" class="btn btn-primary">Access Tool</a>
                    </div>
                </div>
                
                <!-- Tool 3 -->
                <div class="col-md-6 col-lg-4" data-aos="fade-up" data-aos-delay="300">
                    <div class="tool-card">
                        <div class="tool-icon">
                            <i class="fas fa-users"></i>
                        </div>
                        <h3>Guest List Manager</h3>
                        <p>Organize your guest list, track RSVPs, and manage table arrangements with ease.</p>
                        <a href="${pageContext.request.contextPath}/user/guest-list.jsp" class="btn btn-primary">Access Tool</a>
                    </div>
                </div>
            </div>
            
            <div class="tool-cta text-center mt-5" data-aos="fade-up">
                <p>Our planning tools are available to all registered users. Create your free account to access these and more resources.</p>
                <a href="${pageContext.request.contextPath}/signup.jsp" class="btn btn-primary btn-lg">Create Free Account</a>
            </div>
        </div>
    </section>

    <!-- Expert Advice Section -->
    <section class="expert-advice section-padding bg-light">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6 mb-4 mb-lg-0" data-aos="fade-right">
                    <img src="https://images.unsplash.com/photo-1511401139252-f158d3209c17?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80" alt="Wedding Planning Expert" class="img-fluid rounded">
                </div>
                <div class="col-lg-6" data-aos="fade-left">
                    <div class="section-header mb-4">
                        <h2>Ask Our Wedding Experts</h2>
                    </div>
                    <p class="highlight-text">Have a specific wedding planning question?</p>
                    <p>Our team of professional wedding planners and industry experts are here to help! Submit your questions and receive personalized advice tailored to your unique situation.</p>
                    <div class="expert-form mt-4">
                        <form id="expertQuestionForm">
                            <div class="mb-3">
                                <input type="text" class="form-control" placeholder="Your Name" required>
                            </div>
                            <div class="mb-3">
                                <input type="email" class="form-control" placeholder="Your Email" required>
                            </div>
                            <div class="mb-3">
                                <textarea class="form-control" rows="4" placeholder="Your Wedding Planning Question" required></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary">Submit Question</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Subscribe Section -->
    <section class="subscribe-section section-padding">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8 text-center" data-aos="fade-up">
                    <h2>Get Weekly Planning Tips</h2>
                    <p class="mb-4">Sign up for our newsletter to receive expert wedding planning advice, seasonal inspiration, and exclusive offers directly to your inbox.</p>
                    <form class="subscribe-form">
                        <div class="input-group">
                            <input type="email" class="form-control" placeholder="Your Email Address" required>
                            <button class="btn btn-primary" type="submit">Subscribe</button>
                        </div>
                        <div class="form-check mt-2 text-start">
                            <input class="form-check-input" type="checkbox" value="" id="privacyCheck" required>
                            <label class="form-check-label" for="privacyCheck">
                                I agree to receive emails and accept the <a href="${pageContext.request.contextPath}/views/privacy.jsp">privacy policy</a>
                            </label>
                        </div>
                    </form>
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
    
    <!-- Back to Top Button -->
    <button id="back-to-top" class="back-to-top">
        <i class="fas fa-arrow-up"></i>
    </button>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- AOS - Animate On Scroll -->
    <script src="https://unpkg.com/aos@next/dist/aos.js"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/index.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/others/wedding-guides.js"></script>
</body>
</html>