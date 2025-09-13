/**
 * JavaScript for About Us Page - Marry Mate Wedding Planning System
 * 
 * Current Date and Time: 2025-05-18 11:56:28
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
    
    // Animated number counters for stats section
    function animateStats() {
        const stats = document.querySelectorAll('.stat-number');
        const speed = 2000; // Animation duration in milliseconds
        
        stats.forEach(stat => {
            const target = parseInt(stat.getAttribute('data-count'));
            const increment = target / (speed / 30); // Update every 30ms
            
            let current = 0;
            const counter = setInterval(() => {
                current += increment;
                
                // Update the element with the current value (rounded)
                stat.textContent = Math.floor(current);
                
                // Check if target is reached
                if (current >= target) {
                    stat.textContent = target; // Ensure the final value is exactly the target
                    clearInterval(counter);
                }
            }, 30);
        });
    }
    
    // Trigger animation when stats section comes into view
    const statsSection = document.querySelector('.stats-section');
    if (statsSection) {
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    animateStats();
                    observer.unobserve(entry.target); // Only trigger once
                }
            });
        }, { threshold: 0.3 });
        
        observer.observe(statsSection);
    }
    
    // Testimonial slider
    const testimonials = document.querySelectorAll('.testimonial-about-item');
    const indicators = document.querySelectorAll('.indicator');
    const prevBtn = document.querySelector('.prev-testimonial');
    const nextBtn = document.querySelector('.next-testimonial');
    
    let currentTestimonial = 0;
    
    function showTestimonial(index) {
        // Hide all testimonials
        testimonials.forEach(testimonial => {
            testimonial.classList.remove('active');
        });
        
        // Deactivate all indicators
        indicators.forEach(indicator => {
            indicator.classList.remove('active');
        });
        
        // Show the selected testimonial and activate its indicator
        testimonials[index].classList.add('active');
        indicators[index].classList.add('active');
        
        currentTestimonial = index;
    }
    
    // Next testimonial button
    if (nextBtn) {
        nextBtn.addEventListener('click', function() {
            let nextIndex = currentTestimonial + 1;
            if (nextIndex >= testimonials.length) {
                nextIndex = 0;
            }
            showTestimonial(nextIndex);
        });
    }
    
    // Previous testimonial button
    if (prevBtn) {
        prevBtn.addEventListener('click', function() {
            let prevIndex = currentTestimonial - 1;
            if (prevIndex < 0) {
                prevIndex = testimonials.length - 1;
            }
            showTestimonial(prevIndex);
        });
    }
    
    // Click on indicator to show specific testimonial
    indicators.forEach((indicator, index) => {
        indicator.addEventListener('click', function() {
            showTestimonial(index);
        });
    });
    
    // Auto-rotate testimonials every 5 seconds
    let testimonialInterval = setInterval(() => {
        let nextIndex = currentTestimonial + 1;
        if (nextIndex >= testimonials.length) {
            nextIndex = 0;
        }
        showTestimonial(nextIndex);
    }, 5000);
    
    // Pause auto-rotation when hovering over testimonials
    const testimonialSlider = document.querySelector('.testimonial-slider');
    if (testimonialSlider) {
        testimonialSlider.addEventListener('mouseenter', () => {
            clearInterval(testimonialInterval);
        });
        
        testimonialSlider.addEventListener('mouseleave', () => {
            testimonialInterval = setInterval(() => {
                let nextIndex = currentTestimonial + 1;
                if (nextIndex >= testimonials.length) {
                    nextIndex = 0;
                }
                showTestimonial(nextIndex);
            }, 5000);
        });
    }
});