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
    String currentDateTime = "2025-05-18 12:16:08";
    String currentUser = "IT24100905";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Contact Marry Mate - Reach out to our team for wedding planning assistance, partnership opportunities, or general inquiries">
    <title>Contact Us | Marry Mate</title>
    
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
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/others/contact.css">
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/views/contact.jsp">Contact</a>
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
    <section class="contact-hero">
        <div class="overlay"></div>
        <div class="container">
            <div class="row">
                <div class="col-lg-8 mx-auto text-center" data-aos="fade-up">
                    <h1>Contact Us</h1>
                    <p class="lead">We'd love to hear from you. Get in touch with our wedding planning experts.</p>
                </div>
            </div>
        </div>
    </section>

    <!-- Contact Information -->
    <section class="contact-info section-padding">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="row">
                        <div class="col-md-4 mb-4 mb-md-0" data-aos="fade-up" data-aos-delay="100">
                            <div class="contact-card">
                                <div class="contact-icon">
                                    <i class="fas fa-map-marker-alt"></i>
                                </div>
                                <h3>Our Location</h3>
                                <p>Sri Lanka Institute of Information Technology (SLIIT)</p>
                                <p>New Kandy Road, Malabe</p>
                                <p>Sri Lanka</p>
                                <a href="https://maps.app.goo.gl/wHdVhSJ4FxZy2pdz8" target="_blank" class="btn btn-outline-primary btn-sm mt-2">View on Map</a>
                            </div>
                        </div>
                        
                        <div class="col-md-4 mb-4 mb-md-0" data-aos="fade-up" data-aos-delay="200">
                            <div class="contact-card">
                                <div class="contact-icon">
                                    <i class="fas fa-phone-alt"></i>
                                </div>
                                <h3>Phone</h3>
                                <p><a href="tel:0703638365">+94 703 638 365</a></p>
                                <p class="contact-available">Available Monday-Friday, 9AM-6PM</p>
                                <p class="contact-available">Weekends, 10AM-2PM</p>
                            </div>
                        </div>
                        
                        <div class="col-md-4" data-aos="fade-up" data-aos-delay="300">
                            <div class="contact-card">
                                <div class="contact-icon">
                                    <i class="fas fa-envelope"></i>
                                </div>
                                <h3>Email</h3>
                                <p><a href="mailto:IT24102137@my.sliit.lk">IT24102137@my.sliit.lk</a></p>
                                <p class="contact-available">We'll respond as soon as possible</p>
                                <div class="social-links mt-3">
                                    <a href="https://www.facebook.com/janith.deshan.186" class="social-icon"><i class="fab fa-facebook-f"></i></a>
                                    <a href="https://www.instagram.com/janith_deshan11/" class="social-icon"><i class="fab fa-instagram"></i></a>
                                    <a href="https://www.linkedin.com/in/janith-deshan-60089a194/" class="social-icon"><i class="fab fa-linkedin-in"></i></a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Map & Contact Form Section -->
    <section class="contact-form-section section-padding bg-light">
        <div class="container">
            <div class="row">
                <div class="col-12 text-center" data-aos="fade-up">
                    <div class="section-header mb-5">
                        <h2>Get In Touch</h2>
                        <p>We're here to help with your wedding planning needs</p>
                    </div>
                </div>
            </div>
            
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="row">
                        <div class="col-lg-6 mb-5 mb-lg-0" data-aos="fade-right">
                            <div class="map-container">
                                <iframe src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3960.798467512254!2d79.97024817462094!3d6.914677618472952!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x3ae256db1a6771c5%3A0x2c63e344ab9a7536!2sSri%20Lanka%20Institute%20of%20Information%20Technology!5e0!3m2!1sen!2sus!4v1684416358522!5m2!1sen!2sus" width="100%" height="450" style="border:0;" allowfullscreen="" loading="lazy" referrerpolicy="no-referrer-when-downgrade"></iframe>
                                <div class="map-info">
                                    <h4>Marry Mate</h4>
                                    <p><i class="fas fa-user me-2"></i> Janith Deshan</p>
                                    <p><i class="fas fa-id-card me-2"></i> IT24102137</p>
                                </div>
                            </div>
                        </div>
                        
                        <div class="col-lg-6" data-aos="fade-left">
                            <div class="contact-form-container">
                                <h3>Send Us a Message</h3>
                                <form id="contactForm">
                                    <div class="form-group mb-3">
                                        <label for="name" class="form-label">Your Name*</label>
                                        <input type="text" class="form-control" id="name" placeholder="Enter your name" required>
                                    </div>
                                    
                                    <div class="form-group mb-3">
                                        <label for="email" class="form-label">Email Address*</label>
                                        <input type="email" class="form-control" id="email" placeholder="Enter your email" required>
                                    </div>
                                    
                                    <div class="form-group mb-3">
                                        <label for="subject" class="form-label">Subject*</label>
                                        <input type="text" class="form-control" id="subject" placeholder="Enter subject" required>
                                    </div>
                                    
                                    <div class="form-group mb-4">
                                        <label for="message" class="form-label">Message*</label>
                                        <textarea class="form-control" id="message" rows="5" placeholder="Enter your message" required></textarea>
                                    </div>
                                    
                                    <div class="form-check mb-4">
                                        <input class="form-check-input" type="checkbox" value="" id="agreeTerms" required>
                                        <label class="form-check-label" for="agreeTerms">
                                            I agree to the <a href="${pageContext.request.contextPath}/views/privacy.jsp">privacy policy</a> and <a href="${pageContext.request.contextPath}/views/terms.jsp">terms of service</a>.
                                        </label>
                                    </div>
                                    
                                    <button type="submit" class="btn btn-primary w-100" id="submitBtn">Send Message</button>
                                </form>
                                <div id="formStatus" class="mt-4 text-center"></div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- FAQ Section -->
    <section class="faq-section section-padding">
        <div class="container">
            <div class="row">
                <div class="col-12 text-center" data-aos="fade-up">
                    <div class="section-header mb-5">
                        <h2>Frequently Asked Questions</h2>
                        <p>Find quick answers to common inquiries</p>
                    </div>
                </div>
            </div>
            
            <div class="row justify-content-center">
                <div class="col-lg-10">
                    <div class="accordion" id="contactFAQ">
                        <div class="accordion-item" data-aos="fade-up" data-aos-delay="100">
                            <h2 class="accordion-header" id="headingOne">
                                <button class="accordion-button" type="button" data-bs-toggle="collapse" data-bs-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
                                    How quickly can I expect a response after contacting you?
                                </button>
                            </h2>
                            <div id="collapseOne" class="accordion-collapse collapse show" aria-labelledby="headingOne" data-bs-parent="#contactFAQ">
                                <div class="accordion-body">
                                    We aim to respond to all inquiries within 24 hours during business days. For urgent matters, we recommend calling our customer service line directly at +94 703 638 365.
                                </div>
                            </div>
                        </div>
                        
                        <div class="accordion-item" data-aos="fade-up" data-aos-delay="200">
                            <h2 class="accordion-header" id="headingTwo">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseTwo" aria-expanded="false" aria-controls="collapseTwo">
                                    Do you offer in-person consultations for wedding planning?
                                </button>
                            </h2>
                            <div id="collapseTwo" class="accordion-collapse collapse" aria-labelledby="headingTwo" data-bs-parent="#contactFAQ">
                                <div class="accordion-body">
                                    Yes, we do offer in-person consultations at our office in Malabe. You can schedule an appointment through our contact form or by calling us directly. We also provide virtual consultations via Zoom or Google Meet for your convenience.
                                </div>
                            </div>
                        </div>
                        
                        <div class="accordion-item" data-aos="fade-up" data-aos-delay="300">
                            <h2 class="accordion-header" id="headingThree">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseThree" aria-expanded="false" aria-controls="collapseThree">
                                    How can I submit my wedding venue or service to be listed on Marry Mate?
                                </button>
                            </h2>
                            <div id="collapseThree" class="accordion-collapse collapse" aria-labelledby="headingThree" data-bs-parent="#contactFAQ">
                                <div class="accordion-body">
                                    Vendors can join our platform by creating a vendor account on our website. Simply click on "Join as Vendor" in the navigation menu, fill out the application form, and our team will review your submission. For premium listings or special partnerships, please contact us directly.
                                </div>
                            </div>
                        </div>
                        
                        <div class="accordion-item" data-aos="fade-up" data-aos-delay="400">
                            <h2 class="accordion-header" id="headingFour">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseFour" aria-expanded="false" aria-controls="collapseFour">
                                    Is there a cost to create a wedding planning account on Marry Mate?
                                </button>
                            </h2>
                            <div id="collapseFour" class="accordion-collapse collapse" aria-labelledby="headingFour" data-bs-parent="#contactFAQ">
                                <div class="accordion-body">
                                    No, creating a wedding planning account is completely free for couples. We offer a range of complimentary planning tools including checklists, guest list management, and basic budget tracking. Premium features are available through our subscription plans, which you can learn more about on our pricing page.
                                </div>
                            </div>
                        </div>
                        
                        <div class="accordion-item" data-aos="fade-up" data-aos-delay="500">
                            <h2 class="accordion-header" id="headingFive">
                                <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#collapseFive" aria-expanded="false" aria-controls="collapseFive">
                                    I've found an issue with the website. How can I report it?
                                </button>
                            </h2>
                            <div id="collapseFive" class="accordion-collapse collapse" aria-labelledby="headingFive" data-bs-parent="#contactFAQ">
                                <div class="accordion-body">
                                    We appreciate your feedback! If you've encountered a technical issue or have suggestions for improvement, please use our contact form and select "Technical Support" as the subject. Include as much detail as possible, including screenshots if applicable, to help our development team address the issue promptly.
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Support Team -->
    <section class="support-team section-padding bg-light">
        <div class="container">
            <div class="row">
                <div class="col-12 text-center" data-aos="fade-up">
                    <div class="section-header mb-5">
                        <h2>Our Support Team</h2>
                        <p>Meet the people ready to assist you</p>
                    </div>
                </div>
            </div>
            
            <div class="row justify-content-center">
                <div class="col-lg-3 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="100">
                    <div class="team-member-card">
                        <div class="member-image">
                            <img src="https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" alt="Emily Rodriguez" class="img-fluid">
                        </div>
                        <div class="member-info">
                            <h4>Emily Rodriguez</h4>
                            <p class="position">Customer Success Manager</p>
                            <a href="mailto:support@marrymate.com" class="contact-link"><i class="fas fa-envelope me-2"></i>Email</a>
                        </div>
                    </div>
                </div>
                
                <div class="col-lg-3 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="200">
                    <div class="team-member-card">
                        <div class="member-image">
                            <img src="https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" alt="Michael Johnson" class="img-fluid">
                        </div>
                        <div class="member-info">
                            <h4>Michael Johnson</h4>
                            <p class="position">Technical Support Lead</p>
                            <a href="mailto:tech@marrymate.com" class="contact-link"><i class="fas fa-envelope me-2"></i>Email</a>
                        </div>
                    </div>
                </div>
                
                <div class="col-lg-3 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="300">
                    <div class="team-member-card">
                        <div class="member-image">
                            <img src="https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" alt="Sarah Kim" class="img-fluid">
                        </div>
                        <div class="member-info">
                            <h4>Sarah Kim</h4>
                            <p class="position">Vendor Relations</p>
                            <a href="mailto:vendors@marrymate.com" class="contact-link"><i class="fas fa-envelope me-2"></i>Email</a>
                        </div>
                    </div>
                </div>
                
                <div class="col-lg-3 col-md-6 mb-4" data-aos="fade-up" data-aos-delay="400">
                    <div class="team-member-card">
                        <div class="member-image">
                            <img src="https://images.unsplash.com/photo-1567515004624-219c11d31f2e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=80" alt="Janith Deshan" class="img-fluid">
                        </div>
                        <div class="member-info">
                            <h4>Janith Deshan</h4>
                            <p class="position">Lead Developer</p>
                            <a href="mailto:IT24102137@my.sliit.lk" class="contact-link"><i class="fas fa-envelope me-2"></i>Email</a>
                        </div>
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
    <script src="${pageContext.request.contextPath}/assets/js/others/contact.js"></script>
</body>
</html>