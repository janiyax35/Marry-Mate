/**
 * Login Page JavaScript - Marry Mate Wedding Planning System
 * 
 * Current Date and Time: 2025-04-26 15:26:01
 * Current User: IT24102137
 */

// Wait for document to be fully loaded before running scripts
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Animation On Scroll (AOS) for smooth animations
    AOS.init({
        duration: 800,
        easing: 'ease-out',
        once: true
    });
    
    // Initialize particles.js for background floating elements
    particlesJS('particles-js', {
        "particles": {
            "number": {
                "value": 15,
                "density": {
                    "enable": true,
                    "value_area": 800
                }
            },
            "color": {
                "value": ["#c8b273", "#ffffff", "#1a365d"]
            },
            "shape": {
                "type": ["circle", "polygon"],
                "stroke": {
                    "width": 0,
                    "color": "#000000"
                },
                "polygon": {
                    "nb_sides": 6
                }
            },
            "opacity": {
                "value": 0.3,
                "random": true,
                "anim": {
                    "enable": false,
                    "speed": 1,
                    "opacity_min": 0.1,
                    "sync": false
                }
            },
            "size": {
                "value": 5,
                "random": true,
                "anim": {
                    "enable": false,
                    "speed": 40,
                    "size_min": 0.1,
                    "sync": false
                }
            },
            "line_linked": {
                "enable": false
            },
            "move": {
                "enable": true,
                "speed": 1.5,
                "direction": "top",
                "random": true,
                "straight": false,
                "out_mode": "out",
                "bounce": false,
                "attract": {
                    "enable": false,
                    "rotateX": 600,
                    "rotateY": 1200
                }
            }
        },
        "interactivity": {
            "detect_on": "canvas",
            "events": {
                "onhover": {
                    "enable": true,
                    "mode": "repulse"
                },
                "onclick": {
                    "enable": false
                },
                "resize": true
            },
            "modes": {
                "repulse": {
                    "distance": 100,
                    "duration": 0.4
                }
            }
        },
        "retina_detect": true
    });
    
    // =============================
    // Form Validation and Submission
    // =============================
    
    // Get form elements
    const loginForm = document.getElementById('loginForm');
    const usernameInput = document.getElementById('username');
    const passwordInput = document.getElementById('password');
    
    // Handle form submission
    if (loginForm) {
        loginForm.addEventListener('submit', function(event) {
            // Prevent default form submission to handle with AJAX
            event.preventDefault();
            
            // Validate form
            let isValid = true;
            
            if (!usernameInput.value.trim()) {
                isValid = false;
                highlightError(usernameInput);
            }
            
            if (!passwordInput.value.trim()) {
                isValid = false;
                highlightError(passwordInput);
            }
            
            if (!isValid) {
                showMessage('error', 'Please enter both username/email and password.');
                return;
            }
            
            // Add current timestamp
            const accessTimestampInput = document.createElement('input');
            accessTimestampInput.type = 'hidden';
            accessTimestampInput.name = 'accessTimestamp';
            accessTimestampInput.value = new Date().toISOString();
            this.appendChild(accessTimestampInput);
            
            // Show loading state
            const submitBtn = document.querySelector('.btn-login');
            const btnText = submitBtn.querySelector('.btn-text');
            const btnIcon = submitBtn.querySelector('i');
            
            btnText.textContent = 'Signing In...';
            btnIcon.className = 'fas fa-spinner fa-spin';
            submitBtn.disabled = true;
            
            // Submit the form via AJAX
            $.ajax({
                type: 'POST',
                url: 'LoginServlet',
                data: $(this).serialize(),
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        showMessage('success', response.message || 'Login successful! Redirecting...');
                        
                        // Redirect after successful login
                        setTimeout(() => {
                            window.location.href = response.redirect || 'dashboard.jsp';
                        }, 1000);
                    } else {
                        showMessage('error', response.message || 'Invalid username or password. Please try again.');
                        
                        // Reset button state
                        btnText.textContent = 'Sign In';
                        btnIcon.className = 'fas fa-sign-in-alt';
                        submitBtn.disabled = false;
                    }
                },
                error: function(xhr, status, error) {
                    // Try to parse error message if available
                    let errorMsg = 'Login failed. Please try again.';
                    try {
                        const response = JSON.parse(xhr.responseText);
                        if (response && response.message) {
                            errorMsg = response.message;
                        }
                    } catch (e) {
                        console.error('Error parsing response:', e);
                    }
                    
                    showMessage('error', errorMsg);
                    
                    // Reset button state
                    btnText.textContent = 'Sign In';
                    btnIcon.className = 'fas fa-sign-in-alt';
                    submitBtn.disabled = false;
                }
            });
        });
    }
    
    // Function to highlight error field
    function highlightError(inputField) {
        const inputGroup = inputField.closest('.input-group');
        inputGroup.classList.add('shake');
        setTimeout(() => {
            inputGroup.classList.remove('shake');
        }, 600);
    }
    
    // Show message function
    window.showMessage = function(type, message) {
        const messageContainer = document.getElementById('loginMessage');
        if (!messageContainer) return;
        
        const iconClass = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
        const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        
        // Create animated message
        messageContainer.innerHTML = `
            <div class="alert ${alertClass}" role="alert" style="opacity: 0; transform: translateY(20px);">
                <i class="fas ${iconClass} me-2"></i> ${message}
            </div>
        `;
        
        // Animate in
        const alertElement = messageContainer.querySelector('.alert');
        setTimeout(() => {
            alertElement.style.transition = 'all 0.5s ease';
            alertElement.style.opacity = '1';
            alertElement.style.transform = 'translateY(0)';
        }, 10);
        
        // Scroll to message
        messageContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
    };
    
    // Check for URL parameters to show messages
    function checkForUrlMessages() {
        const urlParams = new URLSearchParams(window.location.search);
        const message = urlParams.get('message');
        const messageType = urlParams.get('messageType') || 'error';
        
        if (message) {
            showMessage(messageType, decodeURIComponent(message));
        }
    }
    
    // Run on page load
    checkForUrlMessages();
    
    // Handle social login buttons (can be implemented later with OAuth)
    const socialButtons = document.querySelectorAll('.btn-social');
    if (socialButtons) {
        socialButtons.forEach(button => {
            button.addEventListener('click', function(event) {
                event.preventDefault();
                const provider = this.classList.contains('btn-google') ? 'Google' : 'Facebook';
                alert(`${provider} authentication will be implemented in a future update.`);
            });
        });
    }
});