/**
 * JavaScript for Contact Page - Marry Mate Wedding Planning System
 * 
 * Current Date and Time: 2025-05-18 12:16:08
 * Current User: IT24100905
 */

// Wait for document to be fully loaded before running scripts
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Animation On Scroll (AOS)
    AOS.init({
        duration: 800,
        easing: 'ease-out',
        once: true,
        offset: 100
    });
    
    // Navbar scroll effect (imported from index.js but included here for completeness)
    const navbar = document.querySelector('.navbar');
    
    function handleScroll() {
        if (window.scrollY > 100) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
        
        // Back to top button visibility
        const backToTopBtn = document.getElementById('back-to-top');
        if (backToTopBtn) {
            if (window.scrollY > 300) {
                backToTopBtn.classList.add('active');
            } else {
                backToTopBtn.classList.remove('active');
            }
        }
    }
    
    // Throttle scroll events for better performance
    let scrollTimeout;
    window.addEventListener('scroll', function() {
        if (!scrollTimeout) {
            scrollTimeout = setTimeout(function() {
                handleScroll();
                scrollTimeout = null;
            }, 50);
        }
    });
    
    // Initial call in case page is refreshed when already scrolled down
    handleScroll();
    
    // Back to top button functionality
    const backToTopBtn = document.getElementById('back-to-top');
    if (backToTopBtn) {
        backToTopBtn.addEventListener('click', function() {
            window.scrollTo({
                top: 0,
                behavior: 'smooth'
            });
        });
    }
    
    // Contact Form Validation and Submission
    const contactForm = document.getElementById('contactForm');
    const formStatus = document.getElementById('formStatus');
    
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Get form data
            const name = document.getElementById('name').value.trim();
            const email = document.getElementById('email').value.trim();
            const subject = document.getElementById('subject').value.trim();
            const message = document.getElementById('message').value.trim();
            const agreeTerms = document.getElementById('agreeTerms').checked;
            
            // Validate form
            if (name === '' || email === '' || subject === '' || message === '' || !agreeTerms) {
                showFormStatus('Please fill in all required fields and agree to the terms.', 'error');
                return;
            }
            
            // Email validation
            if (!isValidEmail(email)) {
                showFormStatus('Please enter a valid email address.', 'error');
                return;
            }
            
            // Simulate form submission
            const submitBtn = document.getElementById('submitBtn');
            submitBtn.disabled = true;
            submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Sending...';
            
            // Simulate AJAX request with timeout
            setTimeout(function() {
                // Form submission successful
                showFormStatus('Thank you! Your message has been sent successfully. We\'ll get back to you soon.', 'success');
                
                // Reset form
                contactForm.reset();
                
                // Reset button
                submitBtn.disabled = false;
                submitBtn.innerHTML = 'Send Message';
                
                // Hide the success message after 5 seconds
                setTimeout(function() {
                    formStatus.style.display = 'none';
                }, 5000);
            }, 1500);
        });
    }
    
    // Show form status (success/error)
    function showFormStatus(message, status) {
        formStatus.textContent = message;
        formStatus.className = '';
        formStatus.classList.add(status);
    }
    
    // Email validation function
    function isValidEmail(email) {
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        return emailRegex.test(email);
    }
    
    // Form field validation on blur
    const formFields = ['name', 'email', 'subject', 'message'];
    
    formFields.forEach(field => {
        const input = document.getElementById(field);
        if (input) {
            input.addEventListener('blur', function() {
                if (this.value.trim() === '') {
                    this.classList.add('is-invalid');
                } else {
                    this.classList.remove('is-invalid');
                    
                    // Additional email validation
                    if (field === 'email' && !isValidEmail(this.value.trim())) {
                        this.classList.add('is-invalid');
                    }
                }
            });
            
            // Remove invalid class on input
            input.addEventListener('input', function() {
                if (this.value.trim() !== '') {
                    this.classList.remove('is-invalid');
                    
                    // Additional email validation on input
                    if (field === 'email' && !isValidEmail(this.value.trim())) {
                        this.classList.add('is-invalid');
                    } else {
                        this.classList.remove('is-invalid');
                    }
                }
            });
        }
    });
    
    // Open accordion items when linked from elsewhere
    function openAccordionFromHash() {
        const hash = window.location.hash;
        if (hash) {
            const targetAccordion = document.querySelector(hash);
            if (targetAccordion && targetAccordion.classList.contains('accordion-collapse')) {
                const allAccordions = document.querySelectorAll('.accordion-collapse');
                allAccordions.forEach(accordion => {
                    accordion.classList.remove('show');
                });
                
                targetAccordion.classList.add('show');
                
                // Scroll to the accordion with an offset for the navbar
                setTimeout(() => {
                    const topOffset = targetAccordion.getBoundingClientRect().top + window.pageYOffset - 120;
                    window.scrollTo({
                        top: topOffset,
                        behavior: 'smooth'
                    });
                }, 300);
            }
        }
    }
    
    // Run on page load
    openAccordionFromHash();
    
    // Run when hash changes
    window.addEventListener('hashchange', openAccordionFromHash);
});