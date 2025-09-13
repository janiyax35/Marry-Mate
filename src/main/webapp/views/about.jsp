<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter, java.io.*, java.util.*, java.util.stream.Collectors, com.google.gson.Gson, com.google.gson.JsonObject, com.google.gson.JsonArray, com.google.gson.JsonElement" %>
<%
    // Get current session information
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");
    boolean isLoggedIn = (username != null && !username.isEmpty());
    
    // Generate timestamp for analytics
    String accessTimestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    
    // Current date and time for documentation (as requested)
    String currentDateTime = "2025-05-18 12:06:25";
    String currentUser = "IT24100905";
    
    // Initialize statistics data
    int userCount = 0;
    int vendorCount = 0;
    int satisfactionRate = 0;
    
    // Initialize reviews data
    List<Map<String, Object>> reviewsList = new ArrayList<>();
    
    // Read vendor data
    try {
        // Hard-coded file path as requested
        String vendorFilePath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\vendors.json";
        BufferedReader vendorReader = new BufferedReader(new FileReader(vendorFilePath));
        Gson gson = new Gson();
        JsonObject vendorData = gson.fromJson(vendorReader, JsonObject.class);
        
        // Get vendor count based on userId count
        JsonArray vendors = vendorData.getAsJsonArray("vendors");
        vendorCount = vendors.size();
        
        vendorReader.close();
    } catch (Exception e) {
        // If error, use default value
        vendorCount = 7; // Default from what we saw in the JSON data
    }
    
    // Read user data
    try {
        // Hard-coded file path as requested
        String userFilePath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\users.json";
        BufferedReader userReader = new BufferedReader(new FileReader(userFilePath));
        Gson gson = new Gson();
        JsonObject userData = gson.fromJson(userReader, JsonObject.class);
        
        // Get user count based on userId count
        JsonArray users = userData.getAsJsonArray("users");
        userCount = users.size();
        
        userReader.close();
    } catch (Exception e) {
        // If error, use default value
        userCount = 8; // Default from what we saw in the JSON data
    }
    
    // Read reviews for testimonials and satisfaction rate
    try {
        // Hard-coded file path as requested
        String reviewFilePath = "H:\\SLIIT\\Sem 2\\OOP Project 01\\MarryMate\\src\\main\\webapp\\WEB-INF\\data\\reviews.json";
        BufferedReader reviewReader = new BufferedReader(new FileReader(reviewFilePath));
        Gson gson = new Gson();
        JsonObject reviewData = gson.fromJson(reviewReader, JsonObject.class);
        
        // Get reviews
        JsonArray reviews = reviewData.getAsJsonArray("reviews");
        
        // Calculate satisfaction rate from average rating
        double totalRating = 0;
        int ratingCount = 0;
        
        for (JsonElement element : reviews) {
            JsonObject review = element.getAsJsonObject();
            
            if (review.has("rating") && !review.get("rating").isJsonNull()) {
                totalRating += review.get("rating").getAsDouble();
                ratingCount++;
            }
            
            // Only use published reviews with high ratings for testimonials
            if (review.has("status") && "published".equals(review.get("status").getAsString()) && 
                review.has("rating") && review.get("rating").getAsDouble() >= 4.5) {
                
                Map<String, Object> reviewMap = new HashMap<>();
                reviewMap.put("userName", review.get("userName").getAsString());
                
                // Get comment (ensure it's not too long for display)
                String comment = review.get("comment").getAsString();
                if (comment.length() > 300) {
                    comment = comment.substring(0, 297) + "...";
                }
                reviewMap.put("comment", comment);
                
                // Get review date
                reviewMap.put("reviewDate", review.get("reviewDate").getAsString());
                
                // Get vendor name if available
                String vendorId = review.get("vendorId").getAsString();
                reviewMap.put("vendorId", vendorId);
                
                reviewsList.add(reviewMap);
                
                // Limit to 3 reviews for the testimonial slider
                if (reviewsList.size() >= 3) break;
            }
        }
        
        // Convert average rating to percentage (assuming 5-star scale)
        if (ratingCount > 0) {
            double averageRating = totalRating / ratingCount;
            satisfactionRate = (int) Math.round(averageRating * 20); // Convert to percentage (5 stars = 100%)
        } else {
            satisfactionRate = 95; // Default if no ratings
        }
        
        reviewReader.close();
    } catch (Exception e) {
        // If error, use default value
        satisfactionRate = 95;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="About Marry Mate - Learn more about our wedding planning platform, our mission, and the team behind it">
    <title>About Us | Marry Mate</title>
    
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/others/about.css">
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/views/about.jsp">About Us</a>
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
    <section class="about-hero">
        <div class="overlay"></div>
        <div class="container">
            <div class="row">
                <div class="col-lg-8 mx-auto text-center" data-aos="fade-up">
                    <h1>About Marry Mate</h1>
                    <p class="lead">We're on a mission to make wedding planning simpler, more enjoyable, and accessible to all couples.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Our Story Section -->
    <section class="our-story section-padding">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-6 mb-5 mb-lg-0" data-aos="fade-right">
                    <div class="about-image-container">
                        <img src="https://images.unsplash.com/photo-1511795409834-ef04bbd61622?ixlib=rb-1.2.1&auto=format&fit=crop&w=800&q=80" alt="Marry Mate Founders" class="img-fluid main-image">
                        <img src="https://images.unsplash.com/photo-1522673607200-164d1b6ce486?ixlib=rb-1.2.1&auto=format&fit=crop&w=400&q=80" alt="Happy Couple Planning Wedding" class="img-fluid accent-image">
                        <div class="experience-badge">
                            <span class="number">5+</span>
                            <span class="text">Years of Experience</span>
                        </div>
                    </div>
                </div>
                <div class="col-lg-6" data-aos="fade-left">
                    <div class="section-header mb-4">
                        <h2>Our Story</h2>
                    </div>
                    <p class="highlight-text">Marry Mate was born from a simple idea: wedding planning should be joyful, not stressful.</p>
                    <p>Founded in 2020, our platform emerged when our founders experienced firsthand the challenges of finding reliable vendors and organizing their own weddings. They realized there had to be a better way.</p>
                    <p>What started as a small directory of trusted vendors has evolved into a comprehensive wedding planning platform used by thousands of couples across the country. Today, Marry Mate connects couples with pre-screened professionals while providing innovative planning tools that simplify the entire wedding journey.</p>
                    <p>Our success comes from our commitment to excellence and our deep understanding of what matters most to couples during this special time in their lives.</p>
                    <a href="${pageContext.request.contextPath}/views/contact.jsp" class="btn btn-primary mt-4">Get in Touch</a>
                </div>
            </div>
        </div>
    </section>

    <!-- Mission & Values Section -->
    <section class="mission-values section-padding bg-light">
        <div class="container">
            <div class="row">
                <div class="col-12 text-center" data-aos="fade-up">
                    <div class="section-header mb-5">
                        <h2>Our Mission & Values</h2>
                        <p>The principles that guide everything we do</p>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-lg-6 mb-5" data-aos="fade-up">
                    <div class="mission-card">
                        <div class="mission-icon">
                            <i class="fas fa-heart"></i>
                        </div>
                        <h3>Our Mission</h3>
                        <p>To transform wedding planning into a joyful experience by connecting couples with exceptional vendors and providing intuitive planning tools, enabling them to create their dream celebration without the stress.</p>
                    </div>
                </div>
                <div class="col-lg-6 mb-5" data-aos="fade-up" data-aos-delay="100">
                    <div class="mission-card">
                        <div class="mission-icon">
                            <i class="fas fa-bullseye"></i>
                        </div>
                        <h3>Our Vision</h3>
                        <p>To become the most trusted wedding planning platform globally, known for excellence, innovation, and creating meaningful connections between couples and vendors that result in perfect weddings and lasting relationships.</p>
                    </div>
                </div>
            </div>
            <div class="row mt-4">
                <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="200">
                    <div class="value-card">
                        <div class="value-icon">
                            <i class="fas fa-gem"></i>
                        </div>
                        <h4>Excellence</h4>
                        <p>We are committed to quality in everything we do, from the vendors we feature to the tools we build.</p>
                    </div>
                </div>
                <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="300">
                    <div class="value-card">
                        <div class="value-icon">
                            <i class="fas fa-handshake"></i>
                        </div>
                        <h4>Trust</h4>
                        <p>We build relationships based on transparency, honesty, and reliability with both couples and vendors.</p>
                    </div>
                </div>
                <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="400">
                    <div class="value-card">
                        <div class="value-icon">
                            <i class="fas fa-lightbulb"></i>
                        </div>
                        <h4>Innovation</h4>
                        <p>We constantly improve our platform with creative solutions that make wedding planning easier.</p>
                    </div>
                </div>
                <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="500">
                    <div class="value-card">
                        <div class="value-icon">
                            <i class="fas fa-heart"></i>
                        </div>
                        <h4>Inclusivity</h4>
                        <p>We celebrate love in all its forms and create a platform where everyone feels welcome and valued.</p>
                    </div>
                </div>
                <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="600">
                    <div class="value-card">
                        <div class="value-icon">
                            <i class="fas fa-users"></i>
                        </div>
                        <h4>Community</h4>
                        <p>We foster connections between couples, vendors, and wedding professionals to create a supportive ecosystem.</p>
                    </div>
                </div>
                <div class="col-md-4 mb-4" data-aos="fade-up" data-aos-delay="700">
                    <div class="value-card">
                        <div class="value-icon">
                            <i class="fas fa-star"></i>
                        </div>
                        <h4>Excellence</h4>
                        <p>We strive for the highest standards in our service, support, and the experiences we create.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Team Section -->
    <section class="team-section section-padding">
        <div class="container">
            <div class="row">
                <div class="col-12 text-center" data-aos="fade-up">
                    <div class="section-header mb-5">
                        <h2>Meet Our Team</h2>
                        <p>The passionate people behind Marry Mate</p>
                    </div>
                </div>
            </div>
            <div class="row">
                <!-- Team Member 1 -->
                <div class="col-lg-3 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="100">
                    <div class="team-card">
                        <div class="team-image">
                            <img src="https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" alt="Emily Johnson" class="img-fluid">
                            <div class="team-social">
                                <a href="#"><i class="fab fa-linkedin-in"></i></a>
                                <a href="#"><i class="fab fa-twitter"></i></a>
                                <a href="#"><i class="fas fa-envelope"></i></a>
                            </div>
                        </div>
                        <div class="team-info">
                            <h4>Emily Johnson</h4>
                            <p class="position">Co-Founder & CEO</p>
                            <p class="description">Former wedding planner with 10+ years of experience in the wedding industry.</p>
                        </div>
                    </div>
                </div>
                
                <!-- Team Member 2 -->
                <div class="col-lg-3 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="200">
                    <div class="team-card">
                        <div class="team-image">
                            <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" alt="Daniel Carter" class="img-fluid">
                            <div class="team-social">
                                <a href="#"><i class="fab fa-linkedin-in"></i></a>
                                <a href="#"><i class="fab fa-twitter"></i></a>
                                <a href="#"><i class="fas fa-envelope"></i></a>
                            </div>
                        </div>
                        <div class="team-info">
                            <h4>Daniel Carter</h4>
                            <p class="position">Co-Founder & CTO</p>
                            <p class="description">Tech enthusiast with a passion for creating user-friendly digital experiences.</p>
                        </div>
                    </div>
                </div>
                
                <!-- Team Member 3 -->
                <div class="col-lg-3 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="300">
                    <div class="team-card">
                        <div class="team-image">
                            <img src="https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" alt="Sophia Martinez" class="img-fluid">
                            <div class="team-social">
                                <a href="#"><i class="fab fa-linkedin-in"></i></a>
                                <a href="#"><i class="fab fa-twitter"></i></a>
                                <a href="#"><i class="fas fa-envelope"></i></a>
                            </div>
                        </div>
                        <div class="team-info">
                            <h4>Sophia Martinez</h4>
                            <p class="position">Head of Vendor Relations</p>
                            <p class="description">Building strong partnerships with the best wedding professionals nationwide.</p>
                        </div>
                    </div>
                </div>
                
                <!-- Team Member 4 -->
                <div class="col-lg-3 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="400">
                    <div class="team-card">
                        <div class="team-image">
                            <img src="https://images.unsplash.com/photo-1531427186611-ecfd6d936c79?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" alt="James Wilson" class="img-fluid">
                            <div class="team-social">
                                <a href="#"><i class="fab fa-linkedin-in"></i></a>
                                <a href="#"><i class="fab fa-twitter"></i></a>
                                <a href="#"><i class="fas fa-envelope"></i></a>
                            </div>
                        </div>
                        <div class="team-info">
                            <h4>James Wilson</h4>
                            <p class="position">Customer Success Lead</p>
                            <p class="description">Ensuring couples have the support they need throughout their planning journey.</p>
                        </div>
                    </div>
                </div>
            </div>
            <div class="row mt-4">
                <div class="col-12 text-center" data-aos="fade-up">
                    <p class="team-note">We're a diverse team of wedding industry experts, technology specialists, and creative minds united by our passion for making wedding planning better.</p>
                    <a href="${pageContext.request.contextPath}/views/careers.jsp" class="btn btn-outline-primary mt-3">Join Our Team</a>
                </div>
            </div>
        </div>
    </section>

    <!-- Milestones Section -->
    <section class="milestones-section section-padding bg-light">
        <div class="container">
            <div class="row">
                <div class="col-12 text-center" data-aos="fade-up">
                    <div class="section-header mb-5">
                        <h2>Our Journey</h2>
                        <p>Key milestones in our growth story</p>
                    </div>
                </div>
            </div>
            <div class="timeline" data-aos="fade-up">
                <div class="timeline-item">
                    <div class="timeline-dot">
                        <i class="fas fa-flag"></i>
                    </div>
                    <div class="timeline-content" data-aos="fade-right">
                        <div class="timeline-date">2020</div>
                        <h3>Foundation</h3>
                        <p>Marry Mate was founded with a vision to transform wedding planning. We launched our initial platform with 50 trusted vendors.</p>
                    </div>
                </div>
                
                <div class="timeline-item right">
                    <div class="timeline-dot">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="timeline-content" data-aos="fade-left">
                        <div class="timeline-date">2021</div>
                        <h3>Growth Phase</h3>
                        <p>Expanded to 5 major cities with over 500 vendors. Introduced our innovative wedding planning tools and checklists.</p>
                    </div>
                </div>
                
                <div class="timeline-item">
                    <div class="timeline-dot">
                        <i class="fas fa-trophy"></i>
                    </div>
                    <div class="timeline-content" data-aos="fade-right">
                        <div class="timeline-date">2022</div>
                        <h3>Award Recognition</h3>
                        <p>Named "Best Wedding Planning Platform" at the National Wedding Industry Awards. Reached 10,000 registered couples.</p>
                    </div>
                </div>
                
                <div class="timeline-item right">
                    <div class="timeline-dot">
                        <i class="fas fa-globe"></i>
                    </div>
                    <div class="timeline-content" data-aos="fade-left">
                        <div class="timeline-date">2023</div>
                        <h3>National Expansion</h3>
                        <p>Expanded nationwide with over 2,000 vendors. Launched our mobile app to make planning on-the-go easier.</p>
                    </div>
                </div>
                
                <div class="timeline-item">
                    <div class="timeline-dot">
                        <i class="fas fa-rocket"></i>
                    </div>
                    <div class="timeline-content" data-aos="fade-right">
                        <div class="timeline-date">2024</div>
                        <h3>Innovation & Growth</h3>
                        <p>Introduced AI-powered recommendations and virtual consultations. Reached the milestone of 50,000 successful weddings.</p>
                    </div>
                </div>
                
                <div class="timeline-item right">
                    <div class="timeline-dot">
                        <i class="fas fa-heart"></i>
                    </div>
                    <div class="timeline-content" data-aos="fade-left">
                        <div class="timeline-date">2025</div>
                        <h3>Today</h3>
                        <p>Continuing to innovate and grow with a focus on personalized wedding experiences and supporting diverse celebrations.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Stats Section -->
    <section class="stats-section section-padding">
        <div class="container">
            <div class="row">
                <div class="col-12 text-center" data-aos="fade-up">
                    <div class="section-header mb-5">
                        <h2>Marry Mate By The Numbers</h2>
                        <p>Our impact on the wedding industry</p>
                    </div>
                </div>
            </div>
            <div class="row">
                <div class="col-md-4 col-6 mb-4 mb-md-0" data-aos="fade-up" data-aos-delay="100">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-users"></i>
                        </div>
                        <div class="stat-number" data-count="<%= userCount %>">0</div>
                        <div class="stat-label">Happy Couples</div>
                    </div>
                </div>
                
                <div class="col-md-4 col-6 mb-4 mb-md-0" data-aos="fade-up" data-aos-delay="200">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-store"></i>
                        </div>
                        <div class="stat-number" data-count="<%= vendorCount %>">0</div>
                        <div class="stat-label">Trusted Vendors</div>
                    </div>
                </div>
                
                <div class="col-md-4 col-6" data-aos="fade-up" data-aos-delay="400">
                    <div class="stat-card">
                        <div class="stat-icon">
                            <i class="fas fa-star"></i>
                        </div>
                        <div class="stat-number" data-count="<%= satisfactionRate %>">0</div>
                        <div class="stat-label">Satisfaction Rate %</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Testimonials Section -->
    <section class="testimonials-about section-padding bg-light">
        <div class="container">
            <div class="row">
                <div class="col-12 text-center" data-aos="fade-up">
                    <div class="section-header mb-5">
                        <h2>What People Say About Us</h2>
                        <p>Stories from couples, vendors, and industry experts</p>
                    </div>
                </div>
            </div>
            
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="testimonial-slider" data-aos="fade-up">
                        <% if (reviewsList.size() > 0) { %>
                            <% for (int i = 0; i < reviewsList.size(); i++) { %>
                                <% Map<String, Object> review = reviewsList.get(i); %>
                                <div class="testimonial-about-item <%= i == 0 ? "active" : "" %>">
                                    <div class="testimonial-content">
                                        <p>"<%= review.get("comment") %>"</p>
                                    </div>
                                    <div class="testimonial-author">
                                        <img src="https://images.unsplash.com/photo-1524623252636-db510bfb4128?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="<%= review.get("userName") %>">
                                        <div>
                                            <h4><%= review.get("userName") %></h4>
                                            <p>Married <%= review.get("reviewDate").toString().substring(0, 10) %></p>
                                        </div>
                                    </div>
                                </div>
                            <% } %>
                        <% } else { %>
                            <!-- Fallback testimonials if no reviews were loaded -->
                            <div class="testimonial-about-item active">
                                <div class="testimonial-content">
                                    <p>"Marry Mate transformed our wedding planning experience. We found all our vendors through the platform, and the planning tools kept us on track. The team was responsive and supportive throughout the process. Our wedding was perfect, and we owe much of that to Marry Mate!"</p>
                                </div>
                                <div class="testimonial-author">
                                    <img src="https://images.unsplash.com/photo-1524623252636-db510bfb4128?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="Anna & Michael">
                                    <div>
                                        <h4>Anna & Michael</h4>
                                        <p>Married October 2024</p>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="testimonial-about-item">
                                <div class="testimonial-content">
                                    <p>"As a wedding photographer, joining Marry Mate has been game-changing for my business. The platform brings me high-quality leads and makes managing bookings effortless. I've connected with amazing couples who value creativity and quality."</p>
                                </div>
                                <div class="testimonial-author">
                                    <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="Robert Chen">
                                    <div>
                                        <h4>Robert Chen</h4>
                                        <p>Wedding Photographer</p>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="testimonial-about-item">
                                <div class="testimonial-content">
                                    <p>"Marry Mate is setting new standards in the wedding industry. Their commitment to quality and innovation stands out. They've created a platform that truly understands what modern couples need while supporting vendors with powerful tools."</p>
                                </div>
                                <div class="testimonial-author">
                                    <img src="https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=100&q=80" alt="Lisa Thompson">
                                    <div>
                                        <h4>Lisa Thompson</h4>
                                        <p>Wedding Industry Expert</p>
                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                    
                    <div class="testimonial-controls">
                        <button class="prev-testimonial"><i class="fas fa-chevron-left"></i></button>
                        <div class="testimonial-indicators">
                            <% int indicatorCount = Math.max(reviewsList.size(), 3); %>
                            <% for (int i = 0; i < indicatorCount; i++) { %>
                                <span class="indicator <%= i == 0 ? "active" : "" %>"></span>
                            <% } %>
                        </div>
                        <button class="next-testimonial"><i class="fas fa-chevron-right"></i></button>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- CTA Section -->
    <section class="cta-section section-padding">
        <div class="container">
            <div class="row">
                <div class="col-lg-8 mx-auto text-center" data-aos="fade-up">
                    <h2>Ready to Start Your Wedding Journey?</h2>
                    <p class="mb-4">Join thousands of couples who have found their perfect vendors and planned their dream weddings with Marry Mate.</p>
                    <div class="cta-buttons">
                        <a href="${pageContext.request.contextPath}/signup.jsp" class="btn btn-primary btn-lg me-2 mb-2 mb-md-0">Start Planning</a>
                        <a href="${pageContext.request.contextPath}/VendorServicesServlet" class="btn btn-outline-primary btn-lg mb-2 mb-md-0">Find Vendors</a>
                        <a href="${pageContext.request.contextPath}/signup.jsp?role=vendor" class="btn btn-outline-primary btn-lg">Join as Vendor</a>
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
    <script src="${pageContext.request.contextPath}/assets/js/others/about.js"></script>
</body>
</html>