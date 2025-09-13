<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%
// Generate timestamp for tracking
String accessTimestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

// Check if there's an error message from a previous login attempt
String errorMessage = (String) session.getAttribute("errorMessage");
if (errorMessage != null) {
    session.removeAttribute("errorMessage"); // Clear the message after retrieving it
}

// Check if there's a success message (e.g., from successful registration)
String successMessage = (String) session.getAttribute("successMessage");
if (successMessage != null) {
    session.removeAttribute("successMessage"); // Clear the message after retrieving it
}

// Check if there's an account status message
String accountStatusMessage = (String) session.getAttribute("accountStatusMessage");
if (accountStatusMessage != null) {
    session.removeAttribute("accountStatusMessage"); // Clear the message after retrieving it
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Marry Mate</title>
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- AOS - Animate On Scroll Library -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/aos/2.3.4/aos.css" />
    
    <!-- Google Fonts - Playfair Display and Montserrat -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/others/login.css">
</head>
<body>
    <!-- Background Overlay -->
    <div class="bg-overlay"></div>
    
    <!-- Particles.js container for floating elements -->
    <div id="particles-js"></div>
    
    <div class="container">
        <div class="login-container" data-aos="fade-up" data-aos-duration="800">
            <!-- Logo -->
            <div class="logo-container" data-aos="zoom-in" data-aos-delay="300">
                <div class="logo-icon">
                    <i class="fas fa-heart"></i>
                    <i class="fas fa-ring"></i>
                </div>
            </div>
            
            <h3>Marry Mate</h3>
            <p class="subtitle">Sign in to your account</p>
            
            <form id="loginForm" method="post" action="LoginServlet">
                <!-- Hidden Access Timestamp -->
                <input type="hidden" name="accessTimestamp" value="<%= accessTimestamp %>">
                
                <!-- Username/Email Input -->
                <div class="input-group">
                    <div class="input-icon">
                        <i class="fas fa-user"></i>
                    </div>
                    <input type="text" id="username" name="username" class="form-control" placeholder=" " required autofocus>
                    <label for="username" class="floating-label">Username or Email</label>
                </div>
                
                <!-- Password Input -->
                <div class="input-group">
                    <div class="input-icon">
                        <i class="fas fa-lock"></i>
                    </div>
                    <input type="password" id="password" name="password" class="form-control" placeholder=" " required>
                    <label for="password" class="floating-label">Password</label>
                    <div class="password-toggle" onclick="togglePassword('password')">
                        <i class="fas fa-eye"></i>
                    </div>
                </div>
                
                <!-- Remember Me & Forgot Password -->
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <div class="form-check">
                        <input class="form-check-input" type="checkbox" id="rememberMe" name="rememberMe">
                        <label class="form-check-label" for="rememberMe">
                            Remember me
                        </label>
                    </div>
                    <a href="forgot-password.jsp" class="forgot-password">Forgot Password?</a>
                </div>
                
                <!-- Submit Button -->
                <div class="d-grid mb-4">
                    <button type="submit" class="btn-login">
                        <span class="btn-text">Sign In</span>
                        <i class="fas fa-sign-in-alt"></i>
                    </button>
                </div>
                
                <!-- Divider -->
                <div class="divider">
                    <span>or</span>
                </div>
                
                <!-- Alternative Login Options with Rounded Buttons -->
                <div class="social-login">
                    <div class="social-buttons">
                        <button type="button" class="btn-social btn-google">
                            <i class="fab fa-google"></i>
                        </button>
                        <button type="button" class="btn-social btn-facebook">
                            <i class="fab fa-facebook-f"></i>
                        </button>
                    </div>
                    <p class="social-text">Continue with social media</p>
                </div>
                
                <!-- Register Link -->
                <p class="register-link">
                    Don't have an account? <a href="${pageContext.request.contextPath}/signup.jsp">Create Account</a>
                </p>
                
                <!-- Error/Success Messages Placeholder -->
                <div id="loginMessage" class="mt-3">
                    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle me-2"></i> <%= errorMessage %>
                    </div>
                    <% } %>
                    <% if (successMessage != null && !successMessage.isEmpty()) { %>
                    <div class="alert alert-success">
                        <i class="fas fa-check-circle me-2"></i> <%= successMessage %>
                    </div>
                    <% } %>
                    <% if (accountStatusMessage != null && !accountStatusMessage.isEmpty()) { %>
                    <div class="alert alert-warning">
                        <i class="fas fa-exclamation-triangle me-2"></i> <%= accountStatusMessage %>
                    </div>
                    <% } %>
                </div>
            </form>
        </div>
    </div>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- Particles.js -->
    <script src="https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js"></script>
    
    <!-- AOS - Animate On Scroll -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/aos/2.3.4/aos.js"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/others/login.js"></script>
    
    <script>
    // Initialize AOS
    AOS.init({
        duration: 800,
        easing: 'ease-out',
        once: true
    });
    
    // Toggle password visibility function
    function togglePassword(fieldId) {
        const passwordInput = document.getElementById(fieldId);
        const toggleIcon = passwordInput.parentElement.querySelector('.password-toggle i');
        
        if (passwordInput.type === 'password') {
            passwordInput.type = 'text';
            toggleIcon.classList.remove('fa-eye');
            toggleIcon.classList.add('fa-eye-slash');
        } else {
            passwordInput.type = 'password';
            toggleIcon.classList.remove('fa-eye-slash');
            toggleIcon.classList.add('fa-eye');
        }
    }
    
    // Show message function
    function showMessage(type, message) {
        const messageContainer = document.getElementById('loginMessage');
        if (!messageContainer) return;
        
        let iconClass = 'fa-exclamation-circle';
        let alertClass = 'alert-danger';
        
        if (type === 'success') {
            iconClass = 'fa-check-circle';
            alertClass = 'alert-success';
        } else if (type === 'warning') {
            iconClass = 'fa-exclamation-triangle';
            alertClass = 'alert-warning';
        }
        
        messageContainer.innerHTML = `
            <div class="alert ${alertClass}" role="alert">
                <i class="fas ${iconClass} me-2"></i> ${message}
            </div>
        `;
        
        // Scroll to message
        messageContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
    }
    </script>
</body>
</html>