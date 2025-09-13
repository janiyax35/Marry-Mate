<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.io.*, java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%
// Generate timestamp for tracking
String accessTimestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

// Check if there's an error message from a previous registration attempt
String errorMessage = (String) session.getAttribute("errorMessage");
if (errorMessage != null) {
    session.removeAttribute("errorMessage"); // Clear the message after retrieving it
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sign Up | Marry Mate</title>
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- AOS - Animate On Scroll Library -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/aos/2.3.4/aos.css" />
    
    <!-- Google Fonts - Playfair Display and Montserrat -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <!-- International Telephone Input CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/css/intlTelInput.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/others/registration.css">
</head>
<body>
    <!-- Background Overlay -->
    <div class="bg-overlay"></div>
    
    <!-- Particles.js container for floating elements -->
    <div id="particles-js"></div>
    
    <div class="container">
        <div class="register-container" data-aos="fade-up" data-aos-duration="800">
            <!-- Logo -->
            <div class="logo-container" data-aos="zoom-in" data-aos-delay="300">
                <div class="logo-icon">
                    <i class="fas fa-heart"></i>
                    <i class="fas fa-ring"></i>
                </div>
            </div>
            
            <h3>Marry Mate</h3>
            <p class="subtitle">Create your wedding planning account</p>
            
            <form id="registerForm" method="post" action="RegisterServlet">
                <!-- Hidden Access Timestamp -->
                <input type="hidden" name="accessTimestamp" value="<%= accessTimestamp %>">
                
                <!-- Username Input -->
                <div class="input-group">
                    <div class="input-icon">
                        <i class="fas fa-user"></i>
                    </div>
                    <input type="text" id="username" name="username" class="form-control" placeholder=" " required>
                    <label for="username" class="floating-label">Username</label>
                    <div class="validation-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                </div>
                
                <!-- Full Name Input -->
                <div class="input-group">
                    <div class="input-icon">
                        <i class="fas fa-user-circle"></i>
                    </div>
                    <input type="text" id="fullName" name="fullName" class="form-control" placeholder=" " required>
                    <label for="fullName" class="floating-label">Full Name</label>
                    <div class="validation-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                </div>
                
                <!-- Email Input -->
                <div class="input-group">
                    <div class="input-icon">
                        <i class="fas fa-envelope"></i>
                    </div>
                    <input type="email" id="email" name="email" class="form-control" placeholder=" " required>
                    <label for="email" class="floating-label">Email Address</label>
                    <div class="validation-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                </div>
                
                <!-- Phone Input with Country Code -->
                <div class="input-group phone-group">
                    <!-- The phone icon is hidden because it overlaps with country flag -->
                    <div class="input-icon phone-icon" style="visibility: hidden">
                        <i class="fas fa-phone"></i>
                    </div>
                    <input type="tel" id="phone" name="phone" class="form-control phone-input" placeholder=" ">
                    <label for="phone" class="floating-label phone-label">Phone Number (Optional)</label>
                    <div class="validation-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                </div>
                
                <!-- Address Input -->
                <div class="input-group">
                    <div class="input-icon">
                        <i class="fas fa-home"></i>
                    </div>
                    <input type="text" id="address" name="address" class="form-control" placeholder=" ">
                    <label for="address" class="floating-label">Address (Optional)</label>
                    <div class="validation-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
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
                    <div class="validation-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                </div>
                
                <!-- Confirm Password Input -->
                <div class="input-group">
                    <div class="input-icon">
                        <i class="fas fa-shield-alt"></i>
                    </div>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" placeholder=" " required>
                    <label for="confirmPassword" class="floating-label">Confirm Password</label>
                    <div class="password-toggle" onclick="togglePassword('confirmPassword')">
                        <i class="fas fa-eye"></i>
                    </div>
                    <div class="validation-icon">
                        <i class="fas fa-check-circle"></i>
                    </div>
                </div>
                
                <!-- Password Strength Indicator -->
                <div class="password-strength mt-2 mb-3">
                    <div class="progress">
                        <div class="progress-bar bg-danger" role="progressbar" style="width: 0%" id="passwordStrengthBar"></div>
                    </div>
                    <small class="text-muted" id="passwordStrengthText">Password strength: Too weak</small>
                </div>
                
                <!-- Account Type Selection -->
                <div class="account-type-container">
                    <div class="form-label mb-2">I want to register as:</div>
                    <div class="account-type-options">
                        <div class="account-type-option">
                            <input type="radio" name="role" id="user" value="user" class="account-type-input" checked>
                            <label for="user" class="account-type-label">
                               <i class="fa-solid fa-heart"></i>
                                <span>User</span>
                            </label>
                        </div>
                        <div class="account-type-option">
                            <input type="radio" name="role" id="vendor" value="vendor" class="account-type-input">
                            <label for="vendor" class="account-type-label">
                                <i class="fas fa-store"></i>
                                <span>Vendor</span>
                            </label>
                        </div>
                    </div>
                </div>
                
                <!-- Terms & Conditions -->
                <div class="form-check text-start mb-4">
                    <input class="form-check-input" type="checkbox" id="terms" name="terms" required>
                    <label class="form-check-label" for="terms">
                        I agree to the <a href="#">Terms of Service</a> and <a href="#">Privacy Policy</a>
                    </label>
                </div>
                
                <!-- Submit Button -->
                <div class="d-grid mb-3">
                    <button type="submit" class="btn-register">
                        <span class="btn-text">Create Account</span>
                        <i class="fas fa-arrow-right"></i>
                    </button>
                </div>
                
                <!-- Login Link -->
                <p class="login-link">
                    Already have an account? <a href="login.jsp">Log In</a>
                </p>
                
                <!-- Error/Success Messages Placeholder -->
                <div id="registerMessage" class="mt-3">
                    <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle me-2"></i> <%= errorMessage %>
                    </div>
                    <% } %>
                </div>
            </form>
        </div>
    </div>

    <!-- jQuery for AJAX -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <!-- International Telephone Input Library -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/intlTelInput.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js"></script>
    
    <!-- Particles.js -->
    <script src="https://cdn.jsdelivr.net/npm/particles.js@2.0.0/particles.min.js"></script>
    
    <!-- AOS - Animate On Scroll -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/aos/2.3.4/aos.js"></script>
    
    <!-- Custom JS -->
    <script src="${pageContext.request.contextPath}/assets/js/others/registration-animations.js"></script>
	<script src="${pageContext.request.contextPath}/assets/js/others/registration-functions.js"></script>
    
    <script>
    // Initialize phone input with country selector
    const phoneInput = document.querySelector("#phone");
    const iti = window.intlTelInput(phoneInput, {
        utilsScript: "https://cdnjs.cloudflare.com/ajax/libs/intl-tel-input/17.0.8/js/utils.js",
        preferredCountries: ['us', 'gb', 'ca', 'au'],
        separateDialCode: true,
        autoPlaceholder: "aggressive"
    });
    
    // Fix label placement and handle display of example number
    setTimeout(() => {
        // Hide the example number initially when the field is empty
        if (phoneInput.value === '') {
            // Clear placeholder to hide example number
            phoneInput.setAttribute('placeholder', ' ');
        }
    }, 100);
    
    // Handle phone input focus
    phoneInput.addEventListener('focus', function() {
        document.querySelector('.phone-label').classList.add('phone-label-focused');
        
        // Show example number when focused
        const phonePhaceholder = iti.getPlaceholder();
        setTimeout(() => {
            this.setAttribute('placeholder', phonePhaceholder);
        }, 100);
    });
    
    // Handle phone input blur
    phoneInput.addEventListener('blur', function() {
        if (this.value === '') {
            document.querySelector('.phone-label').classList.remove('phone-label-focused');
            
            // Hide example number when empty
            this.setAttribute('placeholder', ' ');
        } else {
            // Keep example number when there's content
            const phonePhaceholder = iti.getPlaceholder();
            this.setAttribute('placeholder', phonePhaceholder);
        }
    });
    
    // Update hidden input with full number before form submission
    document.getElementById("registerForm").addEventListener("submit", function(e) {
        // Only if phone has a value (since it's optional)
        if (phoneInput.value.trim()) {
            const fullNumber = iti.getNumber();
            phoneInput.value = fullNumber;
        }
    });
    
    // Ensure correct placeholder behavior when validation runs
    phoneInput.addEventListener('input', function() {
        if (this.value === '') {
            // If user clears the field but it's still focused, show the example
            if (document.activeElement === this) {
                const phonePhaceholder = iti.getPlaceholder();
                this.setAttribute('placeholder', phonePhaceholder);
            } else {
                this.setAttribute('placeholder', ' ');
            }
        }
    });
    </script>
</body>
</html>