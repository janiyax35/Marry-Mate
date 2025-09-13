/**
 * Registration Functions - Marry Mate Wedding Planning System
 * 
 * This file contains validation and functionality for the registration page
 * 
 * Current Date and Time: 2025-05-05 06:01:41
 * Current User: IT24102137
 */

// Wait for document to be fully loaded before running scripts
document.addEventListener('DOMContentLoaded', function() {
    // =============================
    // Form Validation Configuration
    // =============================
    
    // Validation patterns
    const patterns = {
        username: /^[a-zA-Z0-9_-]{3,20}$/,
        email: /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/,
        phone: /^[0-9+()-\s]{5,20}$/,
        fullName: /^[a-zA-Z\s'-]{2,50}$/,
        address: /^[a-zA-Z0-9\s,.'#-]{5,100}$/
    };
    
    // Error messages
    const errorMessages = {
        username: "Username must be 3-20 characters and can only contain letters, numbers, underscores, and hyphens",
        email: "Please enter a valid email address",
        phone: "Please enter a valid phone number",
        fullName: "Please enter a valid name (2-50 characters)",
        address: "Please enter a valid address (5-100 characters)",
        password: "Password must be at least 6 characters",
        confirmPassword: "Passwords must match",
        terms: "You must agree to the Terms and Privacy Policy",
        role: "Please select a role"
    };
    
    // Get all form inputs
    const formFields = {
        username: document.getElementById('username'),
        fullName: document.getElementById('fullName'),
        email: document.getElementById('email'),
        phone: document.getElementById('phone'),
        address: document.getElementById('address'),
        password: document.getElementById('password'),
        confirmPassword: document.getElementById('confirmPassword'),
        terms: document.getElementById('terms'),
        roleUser: document.getElementById('user'),
        roleVendor: document.getElementById('vendor')
    };
    
    // =============================
    // Input Validation Functions
    // =============================
    
    // Validate username field
    if (formFields.username) {
        formFields.username.addEventListener('input', function() {
            validateField(this, patterns.username, errorMessages.username);
        });
        
        formFields.username.addEventListener('blur', function() {
            validateField(this, patterns.username, errorMessages.username);
            
            // Check username availability if valid format
            if (this.value.length > 0 && patterns.username.test(this.value)) {
                checkUsernameAvailability(this.value);
            }
        });
    }
    
    // Validate name field
    if (formFields.fullName) {
        formFields.fullName.addEventListener('input', function() {
            validateField(this, patterns.fullName, errorMessages.fullName);
        });
    }
    
    // Validate email field
    if (formFields.email) {
        formFields.email.addEventListener('input', function() {
            validateField(this, patterns.email, errorMessages.email);
        });
        
        formFields.email.addEventListener('blur', function() {
            validateField(this, patterns.email, errorMessages.email);
            
            // Check email availability if valid format
            if (this.value.length > 0 && patterns.email.test(this.value)) {
                checkEmailAvailability(this.value);
            }
        });
    }
    
    // Validate phone field
    if (formFields.phone) {
        formFields.phone.addEventListener('input', function() {
            // Phone is optional, so only validate if it has content
            if (this.value.trim() !== '') {
                validateField(this, patterns.phone, errorMessages.phone);
            } else {
                this.setCustomValidity(''); // Clear any validation messages
            }
        });
    }
    
    // Validate address field
    if (formFields.address) {
        formFields.address.addEventListener('input', function() {
            // Address is optional, so only validate if it has content
            if (this.value.trim() !== '') {
                validateField(this, patterns.address, errorMessages.address);
            } else {
                this.setCustomValidity(''); // Clear any validation messages
            }
        });
    }
    
    // Password validation and strength meter
    if (formFields.password) {
        formFields.password.addEventListener('input', function() {
            // Basic validation
            if (this.value.length >= 6) {
                this.setCustomValidity('');
            } else {
                this.setCustomValidity(errorMessages.password);
            }
            
            // Update validation icon
            updateValidationIcon(this);
            
            // Update password strength
            updatePasswordStrength(this.value);
            
            // Check confirm password match if it has a value
            if (formFields.confirmPassword && formFields.confirmPassword.value) {
                validatePasswordMatch();
            }
        });
    }
    
    // Confirm password validation
    if (formFields.confirmPassword) {
        formFields.confirmPassword.addEventListener('input', function() {
            validatePasswordMatch();
        });
    }
    
    // Terms checkbox validation
    if (formFields.terms) {
        formFields.terms.addEventListener('change', function() {
            if (this.checked) {
                this.setCustomValidity('');
            } else {
                this.setCustomValidity(errorMessages.terms);
            }
        });
    }
    
    // Role radio validation
    function validateRole() {
        const isUserSelected = formFields.roleUser && formFields.roleUser.checked;
        const isVendorSelected = formFields.roleVendor && formFields.roleVendor.checked;
        
        if (isUserSelected || isVendorSelected) {
            if (formFields.roleUser) formFields.roleUser.setCustomValidity('');
            if (formFields.roleVendor) formFields.roleVendor.setCustomValidity('');
        } else {
            if (formFields.roleUser) formFields.roleUser.setCustomValidity(errorMessages.role);
        }
    }
    
    if (formFields.roleUser) {
        formFields.roleUser.addEventListener('change', validateRole);
    }
    
    if (formFields.roleVendor) {
        formFields.roleVendor.addEventListener('change', validateRole);
    }
    
    // Initialize validation for all fields
    Object.entries(formFields).forEach(([key, field]) => {
        if (field && field.tagName) {
            // Skip radio buttons (handled separately)
            if (field.type !== 'radio') {
                updateValidationIcon(field);
            }
        }
    });
    
    // =============================
    // Validation Helper Functions
    // =============================
    
    // Validate a field against a pattern
    function validateField(field, pattern, errorMsg) {
        if (field.value.trim() === '') {
            field.setCustomValidity('');
        } else if (!pattern.test(field.value)) {
            field.setCustomValidity(errorMsg);
        } else {
            field.setCustomValidity('');
        }
        
        updateValidationIcon(field);
    }
    
    // Update validation icon based on input validity
    function updateValidationIcon(input) {
        if (!input || !input.parentElement) return;
        
        const validationIcon = input.parentElement.querySelector('.validation-icon i');
        if (!validationIcon) return;
        
        if (input.value === '') {
            // If empty, hide validation icon
            validationIcon.style.display = 'none';
        } else {
            // Show validation icon
            validationIcon.style.display = 'block';
            
            // Check validity and update icon
            if (input.validity.valid) {
                validationIcon.className = 'fas fa-check-circle';
                validationIcon.style.color = '#2ecc71'; // Success green
            } else {
                validationIcon.className = 'fas fa-times-circle';
                validationIcon.style.color = '#e74c3c'; // Error red
            }
        }
    }
    
    // Validate that passwords match
    function validatePasswordMatch() {
        const password = formFields.password.value;
        const confirmPassword = formFields.confirmPassword.value;
        
        if (confirmPassword === '') {
            formFields.confirmPassword.setCustomValidity('');
        } else if (password !== confirmPassword) {
            formFields.confirmPassword.setCustomValidity(errorMessages.confirmPassword);
        } else {
            formFields.confirmPassword.setCustomValidity('');
        }
        
        updateValidationIcon(formFields.confirmPassword);
    }
    
    // =============================
    // Username and Email Availability Check
    // =============================
    
    // Check if username is available
    function checkUsernameAvailability(username) {
        if (username.length < 3) return;
        
        const validationIcon = formFields.username.parentElement.querySelector('.validation-icon i');
        
        // Show checking indicator
        validationIcon.className = 'fas fa-spinner fa-spin';
        validationIcon.style.color = '#3498db'; // Info blue
        validationIcon.style.display = 'block';
        
        $.ajax({
            type: 'GET',
            url: 'UsernameCheckServlet',
            data: { username: username },
            dataType: 'json',
            success: function(response) {
                if (response.available) {
                    // Username is available
                    formFields.username.setCustomValidity('');
                    validationIcon.className = 'fas fa-check-circle';
                    validationIcon.style.color = '#2ecc71'; // Success green
                } else {
                    // Username is taken
                    formFields.username.setCustomValidity('This username is already taken');
                    validationIcon.className = 'fas fa-times-circle';
                    validationIcon.style.color = '#e74c3c'; // Error red
                }
            },
            error: function() {
                // On error, just proceed without availability check
                console.error('Username availability check failed');
                updateValidationIcon(formFields.username);
            }
        });
    }
    
    // Check if email is available
    function checkEmailAvailability(email) {
        if (!patterns.email.test(email)) return;
        
        const validationIcon = formFields.email.parentElement.querySelector('.validation-icon i');
        
        // Show checking indicator
        validationIcon.className = 'fas fa-spinner fa-spin';
        validationIcon.style.color = '#3498db'; // Info blue
        validationIcon.style.display = 'block';
        
        $.ajax({
            type: 'GET',
            url: 'EmailCheckServlet',
            data: { email: email },
            dataType: 'json',
            success: function(response) {
                if (response.available) {
                    // Email is available
                    formFields.email.setCustomValidity('');
                    validationIcon.className = 'fas fa-check-circle';
                    validationIcon.style.color = '#2ecc71'; // Success green
                } else {
                    // Email is taken
                    formFields.email.setCustomValidity('This email is already registered');
                    validationIcon.className = 'fas fa-times-circle';
                    validationIcon.style.color = '#e74c3c'; // Error red
                }
            },
            error: function() {
                // On error, just proceed without availability check
                console.error('Email availability check failed');
                updateValidationIcon(formFields.email);
            }
        });
    }
    
    // =============================
    // Password Strength Meter
    // =============================
    
    // Update password strength indicator
    function updatePasswordStrength(password) {
        const strengthBar = document.getElementById('passwordStrengthBar');
        const strengthText = document.getElementById('passwordStrengthText');
        
        if (!strengthBar || !strengthText) return;
        
        let strength = 0;
        let tips = [];
        
        // Criteria: length
        if (password.length >= 8) {
            strength += 1;
        } else {
            tips.push("Use at least 8 characters");
        }
        
        // Criteria: lowercase and uppercase
        if (/[a-z]/.test(password) && /[A-Z]/.test(password)) {
            strength += 1;
        } else {
            tips.push("Mix uppercase and lowercase letters");
        }
        
        // Criteria: numbers
        if (/[0-9]/.test(password)) {
            strength += 1;
        } else {
            tips.push("Include at least one number");
        }
        
        // Criteria: special characters
        if (/[^a-zA-Z0-9]/.test(password)) {
            strength += 1;
        } else {
            tips.push("Add a special character (e.g., @, #, $)");
        }
        
        // Update UI based on strength
        switch(strength) {
            case 0:
                strengthBar.className = 'progress-bar bg-danger';
                strengthBar.style.width = '10%';
                strengthText.textContent = 'Password strength: Too weak';
                break;
            case 1:
                strengthBar.className = 'progress-bar bg-danger';
                strengthBar.style.width = '25%';
                strengthText.textContent = 'Password strength: Weak';
                break;
            case 2:
                strengthBar.className = 'progress-bar bg-warning';
                strengthBar.style.width = '50%';
                strengthText.textContent = 'Password strength: Medium';
                break;
            case 3:
                strengthBar.className = 'progress-bar bg-info';
                strengthBar.style.width = '75%';
                strengthText.textContent = 'Password strength: Good';
                break;
            case 4:
                strengthBar.className = 'progress-bar bg-success';
                strengthBar.style.width = '100%';
                strengthText.textContent = 'Password strength: Strong';
                break;
        }
        
        // If there are tips and password is not empty, show them
        if (tips.length > 0 && password.length > 0 && strength < 3) {
            strengthText.innerHTML = strengthText.textContent + ' <span class="password-tips">(' + tips[0] + ')</span>';
        }
    }
    
    // =============================
    // Toggle Password Visibility
    // =============================
    
    // Toggle password visibility function
    window.togglePassword = function(fieldId) {
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
    };
    
    // =============================
    // Form Submission
    // =============================
    
    // Handle form submission
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', function(event) {
            // Prevent default form submission to handle with AJAX
            event.preventDefault();
            
            // Validate all fields
            let isValid = true;
            
            // Check role selection
            validateRole();
            if ((formFields.roleUser && formFields.roleUser.validity.customError) ||
                (formFields.roleVendor && formFields.roleVendor.validity.customError)) {
                isValid = false;
            }
            
            // Check other fields
            Object.entries(formFields).forEach(([key, field]) => {
                if (field && field.tagName && field.type !== 'radio') {
                    if (!field.checkValidity()) {
                        isValid = false;
                        
                        // Highlight the field if not valid
                        if (field.type !== 'checkbox') {
                            field.parentElement.classList.add('shake');
                            setTimeout(() => {
                                field.parentElement.classList.remove('shake');
                            }, 600);
                        }
                    }
                }
            });
            
            // Check terms agreement
            if (!formFields.terms.checked) {
                isValid = false;
                showMessage('error', 'Please agree to the Terms and Privacy Policy');
                return;
            }
            
            if (!isValid) {
                showMessage('error', 'Please fill out all required fields correctly.');
                return;
            }
            
            // Add current timestamp
            const accessTimestampInput = document.createElement('input');
            accessTimestampInput.type = 'hidden';
            accessTimestampInput.name = 'accessTimestamp';
            accessTimestampInput.value = new Date().toISOString();
            this.appendChild(accessTimestampInput);
            
            // Show loading state
            const submitBtn = document.querySelector('.btn-register');
            const btnText = submitBtn.querySelector('.btn-text');
            const btnIcon = submitBtn.querySelector('i');
            
            btnText.textContent = 'Creating Account...';
            btnIcon.className = 'fas fa-spinner fa-spin';
            submitBtn.disabled = true;
            
            // Submit the form via AJAX
            $.ajax({
                type: 'POST',
                url: 'RegisterServlet',
                data: $(this).serialize(),
                dataType: 'json',
                success: function(response) {
                    if (response.success) {
                        showMessage('success', response.message || 'Registration successful! You can now login.');
                        
                        // Redirect after successful registration
                        setTimeout(() => {
                            window.location.href = response.redirect || 'login.jsp';
                        }, 1500);
                    } else {
                        showMessage('error', response.message || 'Registration failed. Please try again.');
                        
                        // Reset button state
                        btnText.textContent = 'Create Account';
                        btnIcon.className = 'fas fa-arrow-right';
                        submitBtn.disabled = false;
                    }
                },
                error: function(xhr, status, error) {
                    // Try to parse error message if available
                    let errorMsg = 'Registration failed. Please try again.';
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
                    btnText.textContent = 'Create Account';
                    btnIcon.className = 'fas fa-arrow-right';
                    submitBtn.disabled = false;
                }
            });
        });
    }
    
    // =============================
    // Message Display
    // =============================
    
    // Show message function
    window.showMessage = function(type, message) {
        const messageContainer = document.getElementById('registerMessage');
        if (!messageContainer) return;
        
        const iconClass = type === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
        const alertClass = type === 'success' ? 'alert-success' : 'alert-danger';
        
        // Use the animation function from animations.js if available
        if (typeof animateMessage === 'function') {
            animateMessage(type, message);
        } else {
            // Fallback if animation function is not available
            messageContainer.innerHTML = `
                <div class="alert ${alertClass}" role="alert">
                    <i class="fas ${iconClass} me-2"></i> ${message}
                </div>
            `;
            
            // Scroll to message
            messageContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
        }
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
});