/**
 * Registration Animations - Marry Mate Wedding Planning System
 * 
 * This file contains all animation-related code for the registration page
 * 
 * Current Date and Time: 2025-04-26 13:09:09 UTC
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

    // Apply animation to account type selection
    const accountTypeOptions = document.querySelectorAll('.account-type-input');
    accountTypeOptions.forEach(option => {
        option.addEventListener('change', function() {
            accountTypeOptions.forEach(opt => {
                const label = opt.nextElementSibling;
                if (opt.checked) {
                    label.classList.add('selected');
                } else {
                    label.classList.remove('selected');
                }
            });
        });
    });

    // Set initial selected state for account type
    accountTypeOptions.forEach(opt => {
        const label = opt.nextElementSibling;
        if (opt.checked) {
            label.classList.add('selected');
        }
    });

    // Add animation for form submission
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', function() {
            const submitBtn = document.querySelector('.btn-register');
            const btnText = submitBtn.querySelector('.btn-text');
            const btnIcon = submitBtn.querySelector('i');
            
            // Only animate if form is valid
            if (this.checkValidity()) {
                btnText.textContent = 'Creating Account...';
                btnIcon.className = 'fas fa-spinner fa-spin';
                submitBtn.disabled = true;
            }
        });
    }

    // Add shake animation for invalid fields on submit attempt
    document.addEventListener('invalid', (function(){
        return function(e) {
            // Add shake effect to parent element of invalid field
            const inputGroup = e.target.closest('.input-group');
            if (inputGroup) {
                inputGroup.classList.add('shake');
                setTimeout(() => {
                    inputGroup.classList.remove('shake');
                }, 600);
            }
        };
    })(), true);
});

// Function to smoothly show messages
function animateMessage(messageType, message) {
    const messageContainer = document.getElementById('registerMessage');
    if (!messageContainer) return;
    
    const iconClass = messageType === 'success' ? 'fa-check-circle' : 'fa-exclamation-circle';
    const alertClass = messageType === 'success' ? 'alert-success' : 'alert-danger';
    
    // Create and insert the message element
    messageContainer.innerHTML = `
        <div class="alert ${alertClass}" role="alert" style="opacity: 0; transform: translateY(20px);">
            <i class="fas ${iconClass} me-2"></i> ${message}
        </div>
    `;
    
    // Animate the message in
    const alertElement = messageContainer.querySelector('.alert');
    setTimeout(() => {
        alertElement.style.transition = 'all 0.5s ease';
        alertElement.style.opacity = '1';
        alertElement.style.transform = 'translateY(0)';
    }, 10);
    
    // Scroll to message
    messageContainer.scrollIntoView({ behavior: 'smooth', block: 'start' });
}