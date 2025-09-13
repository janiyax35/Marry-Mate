<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
<%
    // Current date and time for documentation
    String currentDateTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
    String currentUser = "IT24102137";
    
    // Get requested URL that caused the error
    String requestedUrl = (String) request.getAttribute("javax.servlet.error.request_uri");
    if (requestedUrl == null) {
        requestedUrl = request.getRequestURI();
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>404 - Page Not Found | Marry Mate</title>
    
    <!-- Favicon -->
    <link rel="shortcut icon" href="https://img.icons8.com/color/48/wedding-rings.png" type="image/png">
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary: #1a365d;      /* Deep navy blue */
            --primary-light: #2d5a92; /* Lighter navy blue */
            --accent: #c8b273;       /* Gold accent */
            --accent-light: #e0d4a9;  /* Light gold */
            --text-light: #ffffff;   /* White text */
        }
        
        body {
            margin: 0;
            padding: 0;
            font-family: 'Montserrat', sans-serif;
            background-color: #f8f9fa;
            color: var(--primary);
            overflow-x: hidden;
            min-height: 100vh;
        }
        
        #canvas-container {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: -1;
        }
        
        .content {
            position: relative;
            z-index: 10;
            padding: 2rem;
            text-align: center;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        
        h1 {
            font-family: 'Playfair Display', serif;
            font-size: 8rem;
            font-weight: 700;
            color: var(--primary);
            margin-bottom: 0;
            line-height: 1.2;
            text-shadow: 0 5px 15px rgba(0,0,0,0.1);
        }
        
        h2 {
            font-family: 'Playfair Display', serif;
            font-size: 2.5rem;
            margin-bottom: 1.5rem;
            color: var(--primary);
        }
        
        p {
            font-size: 1.2rem;
            max-width: 600px;
            margin: 0 auto 2rem;
            color: var(--primary-light);
        }
        
        .btn {
            border-radius: 50px;
            padding: 12px 30px;
            font-weight: 600;
            transition: all 0.3s cubic-bezier(0.25, 0.8, 0.25, 1);
            margin: 0 10px;
            box-shadow: 0 4px 15px rgba(26, 54, 93, 0.3);
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            border: none;
        }
        
        .btn-primary:hover {
            transform: translateY(-3px);
            box-shadow: 0 6px 20px rgba(26, 54, 93, 0.4);
            background: linear-gradient(135deg, var(--primary-light), var(--primary));
        }
        
        .btn-outline-primary {
            color: var(--primary);
            border: 2px solid var(--primary);
            background: transparent;
        }
        
        .btn-outline-primary:hover {
            background-color: var(--primary);
            border-color: var(--primary);
            color: var(--text-light);
            transform: translateY(-3px);
        }
        
        .message-card {
            background-color: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            padding: 3rem;
            box-shadow: 0 10px 30px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
            margin: 2rem;
            border-top: 5px solid var(--accent);
            max-width: 700px;
        }
        
        .error-code {
            position: relative;
            display: inline-block;
        }
        
        .error-code:after {
            content: '';
            position: absolute;
            width: 50%;
            height: 3px;
            background: linear-gradient(to right, var(--accent), var(--accent-light));
            bottom: -10px;
            left: 25%;
            border-radius: 50px;
        }
        
        .home-link {
            margin-top: 2rem;
            display: flex;
            gap: 1rem;
        }
        
        .logo-container {
            display: flex;
            align-items: center;
            margin-bottom: 2rem;
        }
        
        .logo-icon {
            position: relative;
            width: 40px;
            height: 40px;
            margin-right: 10px;
        }
        
        .logo-icon i {
            font-size: 26px;
            color: var(--primary);
        }
        
        .logo-icon i:last-child {
            font-size: 14px;
            position: absolute;
            bottom: 0;
            right: 0;
            color: var(--accent);
        }
        
        .logo-text {
            font-family: 'Playfair Display', serif;
            font-weight: 700;
            font-size: 1.8rem;
            color: var(--primary);
        }
        
        #loading-screen {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: #f8f9fa;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            z-index: 1000;
            transition: opacity 0.5s ease-in-out;
        }
        
        .loading-spinner {
            width: 80px;
            height: 80px;
            border: 5px solid rgba(26, 54, 93, 0.1);
            border-top: 5px solid var(--accent);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin-bottom: 20px;
        }
        
        .loading-text {
            font-family: 'Playfair Display', serif;
            color: var(--primary);
            font-size: 1.2rem;
        }
        
        .loading-progress {
            width: 200px;
            height: 4px;
            background: rgba(26, 54, 93, 0.1);
            border-radius: 2px;
            margin-top: 10px;
            overflow: hidden;
        }
        
        .loading-progress-bar {
            height: 100%;
            width: 0%;
            background: linear-gradient(to right, var(--primary), var(--accent));
            transition: width 0.3s ease;
        }
        
        @keyframes spin {
            0% { transform: rotate(0deg); }
            100% { transform: rotate(360deg); }
        }
        
        #stats-container {
            position: fixed;
            top: 0;
            left: 0;
            z-index: 100;
            opacity: 0.7;
            transition: opacity 0.3s ease;
        }
        
        #stats-container:hover {
            opacity: 1;
        }
        
        .controls-panel {
            position: fixed;
            top: 10px;
            right: 10px;
            background: rgba(255,255,255,0.8);
            padding: 10px 15px;
            border-radius: 10px;
            backdrop-filter: blur(5px);
            z-index: 100;
            display: none;
            box-shadow: 0 3px 15px rgba(0,0,0,0.1);
        }
        
        .debug-toggle {
            position: fixed;
            top: 10px;
            right: 10px;
            background: rgba(255,255,255,0.8);
            padding: 8px 15px;
            border-radius: 50px;
            backdrop-filter: blur(5px);
            z-index: 100;
            cursor: pointer;
            font-size: 0.8rem;
            box-shadow: 0 3px 15px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
        }
        
        .debug-toggle:hover {
            background: rgba(255,255,255,0.95);
            transform: translateY(-2px);
        }
        
        .tooltip {
            position: fixed;
            background: rgba(0,0,0,0.7);
            color: white;
            padding: 5px 10px;
            border-radius: 5px;
            font-size: 0.8rem;
            pointer-events: none;
            z-index: 1000;
            transition: opacity 0.2s;
            opacity: 0;
        }
        
        @media (max-width: 768px) {
            h1 {
                font-size: 5rem;
            }
            
            h2 {
                font-size: 1.8rem;
            }
            
            .message-card {
                padding: 2rem;
                margin: 1rem;
            }
            
            .home-link {
                flex-direction: column;
                gap: 0.5rem;
            }
            
            .btn {
                margin: 0.5rem;
            }
        }
    </style>
</head>
<body>
    <!-- Loading Screen -->
    <div id="loading-screen">
        <div class="loading-spinner"></div>
        <div class="loading-text">Loading wedding wonderland...</div>
        <div class="loading-progress">
            <div class="loading-progress-bar"></div>
        </div>
    </div>

    <!-- Debug Toggle Button -->
    <div class="debug-toggle" onclick="toggleDebugPanel()">
        <i class="fas fa-wrench"></i> Debug
    </div>

    <!-- Debug Controls Panel -->
    <div class="controls-panel" id="debug-panel">
        <h5>Debug Controls</h5>
        <div class="mb-2">
            <label for="particles-toggle" class="form-check-label">Particles</label>
            <input type="checkbox" id="particles-toggle" class="form-check-input" checked>
        </div>
        <div class="mb-2">
            <label for="post-processing-toggle" class="form-check-label">Post Processing</label>
            <input type="checkbox" id="post-processing-toggle" class="form-check-input" checked>
        </div>
        <div class="mb-2">
            <label for="rings-toggle" class="form-check-label">Show Rings</label>
            <input type="checkbox" id="rings-toggle" class="form-check-input" checked>
        </div>
        <div class="mb-2">
            <label for="quality-selector" class="form-label">Quality</label>
            <select id="quality-selector" class="form-select form-select-sm">
                <option value="high">High</option>
                <option value="medium" selected>Medium</option>
                <option value="low">Low</option>
            </select>
        </div>
    </div>

    <!-- Stats Container for performance monitoring -->
    <div id="stats-container"></div>
    
    <!-- Tooltip for interactive elements -->
    <div class="tooltip" id="tooltip"></div>
    
    <!-- Three.js Container -->
    <div id="canvas-container"></div>
    
    <!-- Content -->
    <div class="content">
        <div class="message-card">
            <div class="logo-container">
                <div class="logo-icon">
                    <i class="fas fa-heart"></i>
                    <i class="fas fa-ring"></i>
                </div>
                <div class="logo-text">Marry Mate</div>
            </div>
            
            <h1 class="error-code">404</h1>
            <h2>This Page Has Gone on Honeymoon</h2>
            <p>Oops! It seems the page you're looking for has slipped away. Perhaps it's enjoying a romantic getaway or simply got lost in wedding preparations.</p>
            
            <div class="home-link">
                <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                    <i class="fas fa-home me-2"></i> Back to Homepage
                </a>
                <a href="${pageContext.request.contextPath}/views/contact.jsp" class="btn btn-outline-primary">
                    <i class="fas fa-envelope me-2"></i> Contact Support
                </a>
            </div>
        </div>
        
        <div class="mt-3 text-muted small">
            <p style="font-size: 0.8rem; opacity: 0.7;">
                Requested URL: <%= requestedUrl %><br>
                Current Date: <%= currentDateTime %> | Developer: <%= currentUser %>
            </p>
        </div>
    </div>

    <!-- Required Libraries -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/GLTFLoader.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/loaders/DRACOLoader.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/postprocessing/EffectComposer.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/postprocessing/RenderPass.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/postprocessing/UnrealBloomPass.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/postprocessing/ShaderPass.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/shaders/CopyShader.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/shaders/LuminosityHighPassShader.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/stats.js/r17/Stats.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.9.1/gsap.min.js"></script>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Custom Three.js Implementation -->
    <script>
    (function() {
        'use strict';
        
        /**
         * Constants and configuration
         */
        const CONFIG = {
            colors: {
                navyBlue: 0x1a365d,
                lightNavyBlue: 0x2d5a92,
                gold: 0xc8b273,
                lightGold: 0xe0d4a9,
                white: 0xffffff,
                black: 0x000000
            },
            particles: {
                count: 2000,
                size: 0.05,
                speed: 0.01,
                sparkleCount: 200,
                sparkleSize: 0.1
            },
            rings: {
                segments: 64,
                detail: 3,
                rotationSpeed: 0.005,
                hoverScale: 1.2,
                animationDuration: 20
            },
            camera: {
                fov: 50,
                nearPlane: 0.1,
                farPlane: 1000,
                position: { x: 0, y: 0, z: 15 },
                lookAt: { x: 0, y: 0, z: 0 }
            },
            scene: {
                fogDensity: 0.02,
                fogColor: 0xf8f9fa,
                backgroundColor: 0xf8f9fa
            },
            postProcessing: {
                bloomStrength: 0.8,
                bloomRadius: 0.5,
                bloomThreshold: 0.2
            },
            performance: {
                lowQualityThreshold: 30,
                mediumQualityThreshold: 50
            },
            mouse: {
                interactionDistance: 5,
                tooltipOffset: { x: 10, y: 10 }
            },
            debug: {
                showStats: false,
                showGui: false,
                enabled: false
            }
        };
        
        /**
         * Global variables
         */
        let scene, camera, renderer, composer;
        let controls, stats;
        let clock = new THREE.Clock();
        let goldRing, silverRing, blueRing, rings = [];
        let particles, sparkles, customParticles = [];
        let raycaster, mouse, intersectedObject = null;
        let tooltip = document.getElementById('tooltip');
        let loadingProgressBar = document.querySelector('.loading-progress-bar');
        let loadingScreen = document.getElementById('loading-screen');
        let debugPanel = document.getElementById('debug-panel');
        let isDebugMode = false;
        let frameCount = 0;
        let lastTime = 0;
        let deltaTime = 0;
        let qualityLevel = 'medium';
        let isPostProcessingEnabled = true;
        let isParticlesEnabled = true;
        let isRingsVisible = true;
        
        /**
         * Utility functions
         */
        const Utils = {
            // Convert degrees to radians
            degToRad: function(degrees) {
                return degrees * (Math.PI / 180);
            },
            
            // Generate random number within range
            random: function(min, max) {
                return Math.random() * (max - min) + min;
            },
            
            // Map value from one range to another
            map: function(value, inMin, inMax, outMin, outMax) {
                return ((value - inMin) * (outMax - outMin)) / (inMax - inMin) + outMin;
            },
            
            // Clamp value between min and max
            clamp: function(value, min, max) {
                return Math.min(Math.max(value, min), max);
            },
            
            // Lerp (linear interpolation) between two values
            lerp: function(start, end, amount) {
                return (1 - amount) * start + amount * end;
            },
            
            // Get device pixel ratio with limits for performance
            getOptimalPixelRatio: function() {
                const maxPixelRatio = 2; // Limit for performance reasons
                return Math.min(window.devicePixelRatio, maxPixelRatio);
            },
            
            // Check if device is mobile
            isMobile: function() {
                return /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(navigator.userAgent);
            },
            
            // Format number with commas
            formatNumber: function(num) {
                return num.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
            }
        };
        
        /**
         * Custom shaders
         */
        const CustomShaders = {
            // Vertex shader for particles
            particleVertex: `
                varying vec3 vColor;
                attribute float size;
                attribute vec3 customColor;
                uniform float time;
                
                void main() {
                    vColor = customColor;
                    
                    // Animate particles
                    vec3 pos = position;
                    pos.y += sin(time * 2.0 + position.x * 5.0) * 0.1;
                    pos.x += cos(time * 2.0 + position.y * 5.0) * 0.1;
                    
                    // Varying size based on position
                    vec4 mvPosition = modelViewMatrix * vec4(pos, 1.0);
                    gl_PointSize = size * (300.0 / -mvPosition.z);
                    gl_Position = projectionMatrix * mvPosition;
                }
            `,
            
            // Fragment shader for particles
            particleFragment: `
                varying vec3 vColor;
                uniform sampler2D texture;
                
                void main() {
                    // Circular particles
                    vec2 uv = gl_PointCoord.xy - 0.5;
                    float circle = smoothstep(0.5, 0.4, length(uv));
                    
                    if (circle < 0.1) discard;
                    
                    gl_FragColor = vec4(vColor, circle);
                }
            `,
            
            // Vertex shader for rings
            ringVertex: `
                uniform float time;
                varying vec3 vNormal;
                varying vec3 vPosition;
                varying vec2 vUv;
                uniform float hoverEffect;
                
                void main() {
                    vUv = uv;
                    vNormal = normalize(normalMatrix * normal);
                    
                    // Add subtle wave effect
                    vec3 newPosition = position;
                    float wave = sin(time * 2.0 + position.x * 10.0) * 0.05;
                    newPosition += normal * wave * hoverEffect;
                    
                    vPosition = newPosition;
                    gl_Position = projectionMatrix * modelViewMatrix * vec4(newPosition, 1.0);
                }
            `,
            
            // Fragment shader for gold ring
            goldRingFragment: `
                uniform float time;
                varying vec3 vNormal;
                varying vec3 vPosition;
                varying vec2 vUv;
                uniform float hoverEffect;
                
                void main() {
                    // Gold base color
                    vec3 baseColor = vec3(0.8, 0.7, 0.45);
                    
                    // Calculate rim lighting
                    vec3 viewDirection = normalize(-vPosition);
                    float rimLight = 1.0 - max(0.0, dot(viewDirection, vNormal));
                    rimLight = pow(rimLight, 3.0);
                    
                    // Add sparkle effect
                    float sparkle = pow(sin(vUv.x * 100.0 + time) * sin(vUv.y * 100.0 + time), 16.0);
                    
                    // Mix base color with rim light and sparkle
                    vec3 finalColor = mix(baseColor, vec3(1.0), rimLight * 0.6);
                    finalColor += sparkle * 0.5 * hoverEffect;
                    
                    // Increase brightness when hovered
                    finalColor = mix(finalColor, finalColor * 1.3, hoverEffect);
                    
                    gl_FragColor = vec4(finalColor, 1.0);
                }
            `,
            
            // Fragment shader for silver/white ring
            silverRingFragment: `
                uniform float time;
                varying vec3 vNormal;
                varying vec3 vPosition;
                varying vec2 vUv;
                uniform float hoverEffect;
                
                void main() {
                    // Silver base color
                    vec3 baseColor = vec3(0.9, 0.9, 0.92);
                    
                    // Calculate rim lighting
                    vec3 viewDirection = normalize(-vPosition);
                    float rimLight = 1.0 - max(0.0, dot(viewDirection, vNormal));
                    rimLight = pow(rimLight, 4.0);
                    
                    // Add subtle patterns
                    float pattern = sin(vUv.x * 50.0) * sin(vUv.y * 50.0);
                    float sparkle = pow(sin(vUv.x * 120.0 + time) * sin(vUv.y * 120.0 + time * 0.7), 32.0);
                    
                    // Mix base color with effects
                    vec3 finalColor = mix(baseColor, vec3(1.0), rimLight * 0.7);
                    finalColor = mix(finalColor, finalColor * 0.98, pattern * 0.5);
                    finalColor += sparkle * 0.7 * hoverEffect;
                    
                    // Increase brightness when hovered
                    finalColor = mix(finalColor, finalColor * 1.3, hoverEffect);
                    
                    gl_FragColor = vec4(finalColor, 1.0);
                }
            `,
            
            // Fragment shader for navy blue ring
            blueRingFragment: `
                uniform float time;
                varying vec3 vNormal;
                varying vec3 vPosition;
                varying vec2 vUv;
                uniform float hoverEffect;
                
                void main() {
                    // Navy blue base color
                    vec3 baseColor = vec3(0.1, 0.21, 0.36);
                    
                    // Calculate rim lighting
                    vec3 viewDirection = normalize(-vPosition);
                    float rimLight = 1.0 - max(0.0, dot(viewDirection, vNormal));
                    rimLight = pow(rimLight, 5.0);
                    
                    // Add geometric pattern
                    float pattern = step(0.5, fract(vUv.x * 20.0)) * step(0.5, fract(vUv.y * 20.0));
                    pattern = mix(0.95, 1.05, pattern);
                    
                    // Add subtle glow effect
                    float glow = pow(sin(time * 0.5), 2.0) * 0.1;
                    
                    // Mix base color with effects
                    vec3 finalColor = baseColor * pattern;
                    finalColor = mix(finalColor, vec3(0.2, 0.3, 0.5), rimLight * 0.7);
                    finalColor += vec3(0.1, 0.2, 0.4) * glow * hoverEffect;
                    
                    // Increase brightness when hovered
                    finalColor = mix(finalColor, finalColor * 1.5, hoverEffect);
                    
                    gl_FragColor = vec4(finalColor, 1.0);
                }
            `
        };
        
        /**
         * Main initialization function
         */
        function init() {
            initScene();
            initCamera();
            initRenderer();
            initLights();
            initControls();
            initRaycaster();
            
            if (CONFIG.debug.showStats) {
                initStats();
            }
            
            // Create all scene objects
            createRings();
            createParticles();
            createSparkleSystems();
            createBackgroundElements();
            
            // Setup post-processing
            setupPostProcessing();
            
            // Add event listeners
            setupEventListeners();
            
            // Start animation loop
            animate();
            
            // Hide loading screen after everything is set up
            setTimeout(function() {
                loadingScreen.style.opacity = 0;
                setTimeout(function() {
                    loadingScreen.style.display = 'none';
                }, 500);
            }, 1000);
        }
        
        /**
         * Initialize the scene
         */
        function initScene() {
            scene = new THREE.Scene();
            scene.background = new THREE.Color(CONFIG.scene.backgroundColor);
            
            // Add fog for depth
            scene.fog = new THREE.FogExp2(CONFIG.scene.fogColor, CONFIG.scene.fogDensity);
        }
        
        /**
         * Initialize the camera
         */
        function initCamera() {
            const aspect = window.innerWidth / window.innerHeight;
            camera = new THREE.PerspectiveCamera(
                CONFIG.camera.fov, 
                aspect, 
                CONFIG.camera.nearPlane, 
                CONFIG.camera.farPlane
            );
            camera.position.set(
                CONFIG.camera.position.x,
                CONFIG.camera.position.y,
                CONFIG.camera.position.z
            );
            camera.lookAt(
                CONFIG.camera.lookAt.x,
                CONFIG.camera.lookAt.y,
                CONFIG.camera.lookAt.z
            );
        }
        
        /**
         * Initialize the WebGL renderer
         */
        function initRenderer() {
            renderer = new THREE.WebGLRenderer({
                antialias: true,
                alpha: true,
                powerPreference: 'high-performance'
            });
            renderer.setSize(window.innerWidth, window.innerHeight);
            renderer.setPixelRatio(Utils.getOptimalPixelRatio());
            renderer.shadowMap.enabled = true;
            renderer.shadowMap.type = THREE.PCFSoftShadowMap;
            renderer.outputEncoding = THREE.sRGBEncoding;
            renderer.toneMapping = THREE.ACESFilmicToneMapping;
            renderer.toneMappingExposure = 1.2;
            
            const container = document.getElementById('canvas-container');
            container.appendChild(renderer.domElement);
        }
        
        /**
         * Initialize scene lighting
         */
        function initLights() {
            // Ambient light
            const ambientLight = new THREE.AmbientLight(CONFIG.colors.white, 0.4);
            scene.add(ambientLight);
            
            // Main directional light
            const directionalLight1 = new THREE.DirectionalLight(CONFIG.colors.white, 0.8);
            directionalLight1.position.set(5, 5, 5);
            directionalLight1.castShadow = true;
            
            // Configure shadow properties
            directionalLight1.shadow.mapSize.width = 1024;
            directionalLight1.shadow.mapSize.height = 1024;
            directionalLight1.shadow.camera.near = 0.1;
            directionalLight1.shadow.camera.far = 50;
            directionalLight1.shadow.camera.left = -10;
            directionalLight1.shadow.camera.right = 10;
            directionalLight1.shadow.camera.top = 10;
            directionalLight1.shadow.camera.bottom = -10;
            directionalLight1.shadow.bias = -0.001;
            
            scene.add(directionalLight1);
            
            // Secondary directional light (gold tint)
            const directionalLight2 = new THREE.DirectionalLight(CONFIG.colors.gold, 0.5);
            directionalLight2.position.set(-5, -5, 3);
            scene.add(directionalLight2);
            
            // Additional accent light
            const pointLight = new THREE.PointLight(CONFIG.colors.lightGold, 0.7, 20);
            pointLight.position.set(0, 3, 4);
            scene.add(pointLight);
            
            // Create animated spotlight
            const spotlight = new THREE.SpotLight(CONFIG.colors.white, 0.8, 30, Math.PI / 6, 0.5, 1);
            spotlight.position.set(5, 10, 5);
            spotlight.castShadow = true;
            spotlight.shadow.mapSize.width = 1024;
            spotlight.shadow.mapSize.height = 1024;
            spotlight.shadow.bias = -0.0001;
            scene.add(spotlight);
            
            // Animate spotlight
            gsap.to(spotlight.position, {
                x: -5,
                duration: 15,
                repeat: -1,
                yoyo: true,
                ease: "sine.inOut"
            });
        }
        
        /**
         * Initialize OrbitControls
         */
        function initControls() {
            controls = new THREE.OrbitControls(camera, renderer.domElement);
            controls.enableDamping = true;
            controls.dampingFactor = 0.05;
            controls.rotateSpeed = 0.7;
            controls.minDistance = 5;
            controls.maxDistance = 30;
            controls.enablePan = false;
            controls.autoRotate = true;
            controls.autoRotateSpeed = 0.5;
        }
        
        /**
         * Initialize raycaster for mouse interaction
         */
        function initRaycaster() {
            raycaster = new THREE.Raycaster();
            mouse = new THREE.Vector2();
        }
        
        /**
         * Initialize stats for performance monitoring
         */
        function initStats() {
            stats = new Stats();
            stats.showPanel(0); // 0: fps, 1: ms, 2: mb, 3+: custom
            document.getElementById('stats-container').appendChild(stats.dom);
        }
        
        /**
         * Create wedding rings with custom shaders
         */
        function createRings() {
            const torusGeometry = new THREE.TorusGeometry(2, 0.4, CONFIG.rings.segments, CONFIG.rings.segments);
            
            // Create custom materials with shaders
            const goldMaterial = new THREE.ShaderMaterial({
                uniforms: {
                    time: { value: 0 },
                    hoverEffect: { value: 0 }
                },
                vertexShader: CustomShaders.ringVertex,
                fragmentShader: CustomShaders.goldRingFragment
            });
            
            const silverMaterial = new THREE.ShaderMaterial({
                uniforms: {
                    time: { value: 0 },
                    hoverEffect: { value: 0 }
                },
                vertexShader: CustomShaders.ringVertex,
                fragmentShader: CustomShaders.silverRingFragment
            });
            
            const blueMaterial = new THREE.ShaderMaterial({
                uniforms: {
                    time: { value: 0 },
                    hoverEffect: { value: 0 }
                },
                vertexShader: CustomShaders.ringVertex,
                fragmentShader: CustomShaders.blueRingFragment
            });
            
            // Create rings with materials
            goldRing = new THREE.Mesh(torusGeometry, goldMaterial);
            goldRing.position.set(-2, 0, 0);
            goldRing.rotation.set(Math.PI / 3, Math.PI / 6, 0);
            goldRing.castShadow = true;
            goldRing.receiveShadow = true;
            goldRing.userData = {
                name: "Gold Ring",
                description: "A precious gold wedding band, symbol of eternal love.",
                hoverEffect: 0,
                targetHoverEffect: 0
            };
            scene.add(goldRing);
            rings.push(goldRing);
            
            silverRing = new THREE.Mesh(torusGeometry, silverMaterial);
            silverRing.scale.set(1.25, 1.25, 1.25);
            silverRing.position.set(2, 0, 1);
            silverRing.rotation.set(Math.PI / 4, Math.PI / 3, 0);
            silverRing.castShadow = true;
            silverRing.receiveShadow = true;
            silverRing.userData = {
                name: "Silver Ring",
                description: "An elegant silver wedding ring, representing purity and clarity.",
                hoverEffect: 0,
                targetHoverEffect: 0
            };
            scene.add(silverRing);
            rings.push(silverRing);
            
            blueRing = new THREE.Mesh(torusGeometry, blueMaterial);
            blueRing.scale.set(1.5, 1.5, 1.5);
            blueRing.position.set(0, 0, -1);
            blueRing.rotation.set(Math.PI / 5, 0, Math.PI / 2);
            blueRing.castShadow = true;
            blueRing.receiveShadow = true;
            blueRing.userData = {
                name: "Navy Blue Ring",
                description: "A modern navy blue ring, symbolizing loyalty and trust.",
                hoverEffect: 0,
                targetHoverEffect: 0
            };
            scene.add(blueRing);
            rings.push(blueRing);
            
            // Set up GSAP animations for rings
            setupRingAnimations();
        }
        
        /**
         * Set up GSAP animations for rings
         */
        function setupRingAnimations() {
            // Gold ring animation
            gsap.to(goldRing.rotation, {
                x: Math.PI * 2 + Math.PI / 3,
                y: Math.PI * 2 + Math.PI / 6,
                duration: CONFIG.rings.animationDuration,
                ease: "none",
                repeat: -1
            });
            
            gsap.to(goldRing.position, {
                y: goldRing.position.y + 0.5,
                duration: 4,
                ease: "sine.inOut",
                yoyo: true,
                repeat: -1
            });
            
            // Silver ring animation
            gsap.to(silverRing.rotation, {
                x: Math.PI * 2 + Math.PI / 4,
                y: Math.PI * 2 + Math.PI / 3,
                duration: CONFIG.rings.animationDuration + 5,
                ease: "none",
                repeat: -1
            });
            
            gsap.to(silverRing.position, {
                y: silverRing.position.y + 0.7,
                duration: 3,
                ease: "sine.inOut",
                yoyo: true,
                repeat: -1,
                delay: 0.5
            });
            
            // Blue ring animation
            gsap.to(blueRing.rotation, {
                x: Math.PI * 2 + Math.PI / 5,
                z: Math.PI * 2 + Math.PI / 2,
                duration: CONFIG.rings.animationDuration + 10,
                ease: "none",
                repeat: -1
            });
            
            gsap.to(blueRing.position, {
                y: blueRing.position.y + 0.6,
                duration: 5,
                ease: "sine.inOut",
                yoyo: true,
                repeat: -1,
                delay: 1
            });
        }
        
        /**
         * Create background particle system
         */
        function createParticles() {
            const particlesGeometry = new THREE.BufferGeometry();
            const particleCount = CONFIG.particles.count;
            const positions = new Float32Array(particleCount * 3);
            const colors = new Float32Array(particleCount * 3);
            const sizes = new Float32Array(particleCount);
            
            // Generate random positions, sizes, and colors for particles
            for (let i = 0; i < particleCount; i++) {
                const i3 = i * 3;
                
                // Position particles in a spherical distribution
                const radius = Utils.random(10, 50);
                const theta = Utils.random(0, Math.PI * 2);
                const phi = Utils.random(0, Math.PI);
                
                positions[i3] = radius * Math.sin(phi) * Math.cos(theta);
                positions[i3 + 1] = radius * Math.sin(phi) * Math.sin(theta);
                positions[i3 + 2] = radius * Math.cos(phi);
                
                // Determine color based on position
                const colorChoice = Math.random();
                if (colorChoice < 0.33) {
                    // Navy blue color
                    colors[i3] = 0.1;
                    colors[i3 + 1] = 0.21;
                    colors[i3 + 2] = 0.36;
                } else if (colorChoice < 0.66) {
                    // Gold color
                    colors[i3] = 0.8;
                    colors[i3 + 1] = 0.7;
                    colors[i3 + 2] = 0.45;
                } else {
                    // White color
                    colors[i3] = 1.0;
                    colors[i3 + 1] = 1.0;
                    colors[i3 + 2] = 1.0;
                }
                
                // Random size variation
                sizes[i] = Utils.random(0.01, CONFIG.particles.size * 3);
            }
            
            particlesGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            particlesGeometry.setAttribute('customColor', new THREE.BufferAttribute(colors, 3));
            particlesGeometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
            
            // Create custom shader material
            const particlesMaterial = new THREE.ShaderMaterial({
                uniforms: {
                    time: { value: 0 },
                    texture: { value: null }
                },
                vertexShader: CustomShaders.particleVertex,
                fragmentShader: CustomShaders.particleFragment,
                transparent: true,
                blending: THREE.AdditiveBlending,
                depthWrite: false
            });
            
            particles = new THREE.Points(particlesGeometry, particlesMaterial);
            scene.add(particles);
        }
        
        /**
         * Create sparkle effect systems
         */
        function createSparkleSystems() {
            const sparkleGeometry = new THREE.BufferGeometry();
            const sparkleCount = CONFIG.particles.sparkleCount;
            const positions = new Float32Array(sparkleCount * 3);
            const colors = new Float32Array(sparkleCount * 3);
            const sizes = new Float32Array(sparkleCount);
            
            // Generate sparkle particles around rings
            for (let i = 0; i < sparkleCount; i++) {
                const i3 = i * 3;
                
                // Position particles around rings
                const ringChoice = Math.floor(Math.random() * 3);
                const ringPosition = [goldRing, silverRing, blueRing][ringChoice].position;
                
                const radius = Utils.random(2, 4);
                const theta = Utils.random(0, Math.PI * 2);
                const phi = Utils.random(0, Math.PI);
                
                positions[i3] = ringPosition.x + radius * Math.sin(phi) * Math.cos(theta);
                positions[i3 + 1] = ringPosition.y + radius * Math.sin(phi) * Math.sin(theta);
                positions[i3 + 2] = ringPosition.z + radius * Math.cos(phi);
                
                // Set colors based on ring choice
                if (ringChoice === 0) {
                    // Gold sparkle
                    colors[i3] = 1.0;
                    colors[i3 + 1] = 0.9;
                    colors[i3 + 2] = 0.6;
                } else if (ringChoice === 1) {
                    // White sparkle
                    colors[i3] = 1.0;
                    colors[i3 + 1] = 1.0;
                    colors[i3 + 2] = 1.0;
                } else {
                    // Blue sparkle
                    colors[i3] = 0.5;
                    colors[i3 + 1] = 0.7;
                    colors[i3 + 2] = 0.9;
                }
                
                // Vary size
                sizes[i] = Utils.random(0.05, CONFIG.particles.sparkleSize);
            }
            
            sparkleGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            sparkleGeometry.setAttribute('customColor', new THREE.BufferAttribute(colors, 3));
            sparkleGeometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
            
            // Create material with point texture
            const sparkleMaterial = new THREE.PointsMaterial({
                size: CONFIG.particles.sparkleSize,
                map: createSparkleTexture(),
                blending: THREE.AdditiveBlending,
                transparent: true,
                vertexColors: true,
                depthWrite: false
            });
            
            sparkles = new THREE.Points(sparkleGeometry, sparkleMaterial);
            scene.add(sparkles);
            
            // Additional custom particles for interactive effects
            createCustomParticles();
        }
        
        /**
         * Create custom interactive particles
         */
        function createCustomParticles() {
            // Create 10 custom particle systems for interactive effects
            for (let i = 0; i < 10; i++) {
                const particleSystem = createParticleSystem(
                    20, // particles per system
                    Utils.random(0.03, 0.08), // size
                    new THREE.Color(
                        Utils.random(0.7, 1), 
                        Utils.random(0.7, 1), 
                        Utils.random(0.7, 1)
                    )
                );
                
                // Position them randomly in the scene
                particleSystem.position.set(
                    Utils.random(-5, 5),
                    Utils.random(-5, 5),
                    Utils.random(-5, 5)
                );
                
                scene.add(particleSystem);
                customParticles.push(particleSystem);
            }
        }
        
        /**
         * Create custom particle system
         */
        function createParticleSystem(count, size, color) {
            const geometry = new THREE.BufferGeometry();
            const positions = new Float32Array(count * 3);
            
            for (let i = 0; i < count * 3; i += 3) {
                const radius = 0.5;
                const theta = Utils.random(0, Math.PI * 2);
                const phi = Utils.random(0, Math.PI);
                
                positions[i] = radius * Math.sin(phi) * Math.cos(theta);
                positions[i + 1] = radius * Math.sin(phi) * Math.sin(theta);
                positions[i + 2] = radius * Math.cos(phi);
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            
            const material = new THREE.PointsMaterial({
                color: color,
                size: size,
                transparent: true,
                blending: THREE.AdditiveBlending,
                map: createSparkleTexture()
            });
            
            return new THREE.Points(geometry, material);
        }
        
        /**
         * Create texture for sparkle particles
         */
        function createSparkleTexture() {
            const canvas = document.createElement('canvas');
            canvas.width = 64;
            canvas.height = 64;
            
            const context = canvas.getContext('2d');
            context.fillStyle = 'white';
            context.beginPath();
            context.arc(32, 32, 16, 0, Math.PI * 2);
            context.fill();
            
            // Add glow effect
            const gradient = context.createRadialGradient(32, 32, 0, 32, 32, 32);
            gradient.addColorStop(0, 'rgba(255, 255, 255, 1)');
            gradient.addColorStop(0.3, 'rgba(255, 255, 255, 0.8)');
            gradient.addColorStop(0.7, 'rgba(255, 255, 255, 0.1)');
            gradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
            
            context.fillStyle = gradient;
            context.beginPath();
            context.arc(32, 32, 32, 0, Math.PI * 2);
            context.fill();
            
            const texture = new THREE.CanvasTexture(canvas);
            texture.needsUpdate = true;
            return texture;
        }
        
        /**
         * Create decorative background elements
         */
        function createBackgroundElements() {
            // Create distant stars
            const starsGeometry = new THREE.BufferGeometry();
            const starCount = 2000;
            const starPositions = new Float32Array(starCount * 3);
            
            for (let i = 0; i < starCount * 3; i += 3) {
                const radius = Utils.random(50, 100);
                const theta = Utils.random(0, Math.PI * 2);
                const phi = Utils.random(0, Math.PI);
                
                starPositions[i] = radius * Math.sin(phi) * Math.cos(theta);
                starPositions[i + 1] = radius * Math.sin(phi) * Math.sin(theta);
                starPositions[i + 2] = radius * Math.cos(phi);
            }
            
            starsGeometry.setAttribute('position', new THREE.BufferAttribute(starPositions, 3));
            
            const starsMaterial = new THREE.PointsMaterial({
                color: 0xffffff,
                size: 0.2,
                transparent: true,
                opacity: 0.8
            });
            
            const stars = new THREE.Points(starsGeometry, starsMaterial);
            scene.add(stars);
            
            // Create decorative floating hearts
            for (let i = 0; i < 8; i++) {
                const heartGeometry = createHeartShape();
                
                const material = new THREE.MeshStandardMaterial({
                    color: i % 3 === 0 ? CONFIG.colors.navyBlue : 
                           i % 3 === 1 ? CONFIG.colors.gold : CONFIG.colors.white,
                    roughness: 0.3,
                    metalness: 0.7,
                    side: THREE.DoubleSide,
                    transparent: true,
                    opacity: 0.7
                });
                
                const heart = new THREE.Mesh(heartGeometry, material);
                
                // Position randomly around the scene
                heart.position.set(
                    Utils.random(-15, 15),
                    Utils.random(-15, 15),
                    Utils.random(-15, 15)
                );
                
                // Random scale and rotation
                const scale = Utils.random(0.2, 0.5);
                heart.scale.set(scale, scale, scale);
                heart.rotation.set(
                    Utils.random(0, Math.PI * 2),
                    Utils.random(0, Math.PI * 2),
                    Utils.random(0, Math.PI * 2)
                );
                
                scene.add(heart);
                
                // Animate heart with GSAP
                gsap.to(heart.rotation, {
                    x: heart.rotation.x + Math.PI * 2,
                    y: heart.rotation.y + Math.PI * 2,
                    z: heart.rotation.z + Math.PI * 2,
                    duration: Utils.random(20, 40),
                    ease: "none",
                    repeat: -1
                });
                
                gsap.to(heart.position, {
                    y: heart.position.y + Utils.random(1, 2),
                    duration: Utils.random(3, 8),
                    ease: "sine.inOut",
                    yoyo: true,
                    repeat: -1
                });
            }
        }
        
        /**
         * Create heart shape geometry
         */
        function createHeartShape() {
            const shape = new THREE.Shape();
            const x = 0, y = 0;
            
            shape.moveTo(x, y);
            shape.bezierCurveTo(x - 0.5, y - 0.5, x - 1, y + 0.5, x, y + 1);
            shape.bezierCurveTo(x + 1, y + 0.5, x + 0.5, y - 0.5, x, y);
            
            const extrudeSettings = {
                steps: 2,
                depth: 0.2,
                bevelEnabled: true,
                bevelThickness: 0.1,
                bevelSize: 0.1,
                bevelOffset: 0,
                bevelSegments: 5
            };
            
            return new THREE.ExtrudeGeometry(shape, extrudeSettings);
        }
        
        /**
         * Setup post-processing effects
         */
        function setupPostProcessing() {
            // Create composer
            composer = new THREE.EffectComposer(renderer);
            
            // Add render pass
            const renderPass = new THREE.RenderPass(scene, camera);
            composer.addPass(renderPass);
            
            // Add bloom pass
            const bloomPass = new THREE.UnrealBloomPass(
                new THREE.Vector2(window.innerWidth, window.innerHeight),
                CONFIG.postProcessing.bloomStrength,
                CONFIG.postProcessing.bloomRadius,
                CONFIG.postProcessing.bloomThreshold
            );
            composer.addPass(bloomPass);
        }
        
        /**
         * Set up event listeners
         */
        function setupEventListeners() {
            // Mouse move for hover effects
            window.addEventListener('mousemove', onMouseMove);
            
            // Window resize
            window.addEventListener('resize', onWindowResize);
            
            // Mouse click for interaction
            window.addEventListener('click', onMouseClick);
            
            // Setup debug controls
            setupDebugControls();
            
            // Update loading progress bar
            updateLoadingProgress(20);
            
            // Simulated asset loading progress
            simulateLoading();
        }
        
        /**
         * Setup debug control elements
         */
        function setupDebugControls() {
            // Debug panel toggle
            document.getElementById('particles-toggle').addEventListener('change', function(e) {
                isParticlesEnabled = e.target.checked;
                particles.visible = isParticlesEnabled;
                sparkles.visible = isParticlesEnabled;
                customParticles.forEach(p => p.visible = isParticlesEnabled);
            });
            
            document.getElementById('post-processing-toggle').addEventListener('change', function(e) {
                isPostProcessingEnabled = e.target.checked;
            });
            
            document.getElementById('rings-toggle').addEventListener('change', function(e) {
                isRingsVisible = e.target.checked;
                rings.forEach(ring => ring.visible = isRingsVisible);
            });
            
            document.getElementById('quality-selector').addEventListener('change', function(e) {
                qualityLevel = e.target.value;
                updateQualitySettings();
            });
            
            // Update loading progress
            updateLoadingProgress(40);
        }
        
        /**
         * Handle mouse move events for hover effects
         */
        function onMouseMove(event) {
            // Calculate mouse position in normalized device coordinates (-1 to +1)
            mouse.x = (event.clientX / window.innerWidth) * 2 - 1;
            mouse.y = -(event.clientY / window.innerHeight) * 2 + 1;
            
            // Update tooltip position
            tooltip.style.left = (event.clientX + CONFIG.mouse.tooltipOffset.x) + 'px';
            tooltip.style.top = (event.clientY + CONFIG.mouse.tooltipOffset.y) + 'px';
        }
        
        /**
         * Handle window resize
         */
        function onWindowResize() {
            camera.aspect = window.innerWidth / window.innerHeight;
            camera.updateProjectionMatrix();
            
            renderer.setSize(window.innerWidth, window.innerHeight);
            composer.setSize(window.innerWidth, window.innerHeight);
        }
        
        /**
         * Handle mouse click events
         */
        function onMouseClick() {
            if (intersectedObject) {
                // Create explosion particles at clicked ring
                createClickExplosion(intersectedObject.position);
                
                // Animate the clicked ring
                animateClickedRing(intersectedObject);
            }
        }
        
        /**
         * Create particle explosion effect at click position
         */
        function createClickExplosion(position) {
            const explosionGeometry = new THREE.BufferGeometry();
            const particleCount = 100;
            const positions = new Float32Array(particleCount * 3);
            
            for (let i = 0; i < particleCount * 3; i += 3) {
                positions[i] = 0;
                positions[i + 1] = 0;
                positions[i + 2] = 0;
            }
            
            explosionGeometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            
            // Determine color based on position (use ring's position to decide color)
            let color;
            if (position.distanceTo(goldRing.position) < 3) {
                color = CONFIG.colors.gold;
            } else if (position.distanceTo(silverRing.position) < 3) {
                color = CONFIG.colors.white;
            } else {
                color = CONFIG.colors.navyBlue;
            }
            
            const explosionMaterial = new THREE.PointsMaterial({
                color: color,
                size: 0.1,
                transparent: true,
                blending: THREE.AdditiveBlending,
                depthWrite: false,
                map: createSparkleTexture()
            });
            
            const explosionParticles = new THREE.Points(explosionGeometry, explosionMaterial);
            explosionParticles.position.copy(position);
            scene.add(explosionParticles);
            
            // Animate explosion
            const velocity = [];
            for (let i = 0; i < particleCount; i++) {
                velocity.push({
                    x: Utils.random(-0.1, 0.1),
                    y: Utils.random(-0.1, 0.1),
                    z: Utils.random(-0.1, 0.1)
                });
            }
            
            gsap.to(explosionMaterial, {
                opacity: 0,
                duration: 2,
                onComplete: () => {
                    scene.remove(explosionParticles);
                    explosionParticles.geometry.dispose();
                    explosionMaterial.dispose();
                }
            });
            
            // Animation loop for explosion particles
            const animateExplosion = () => {
                const positions = explosionParticles.geometry.attributes.position.array;
                
                for (let i = 0; i < particleCount; i++) {
                    const i3 = i * 3;
                    positions[i3] += velocity[i].x;
                    positions[i3 + 1] += velocity[i].y;
                    positions[i3 + 2] += velocity[i].z;
                    
                    // Add gravity effect
                    velocity[i].y -= 0.001;
                }
                
                explosionParticles.geometry.attributes.position.needsUpdate = true;
                
                if (explosionMaterial.opacity > 0) {
                    requestAnimationFrame(animateExplosion);
                }
            };
            
            animateExplosion();
        }
        
        /**
         * Animate ring on click
         */
        function animateClickedRing(ring) {
            // Pulse animation
            const originalScale = ring.scale.clone();
            
            gsap.timeline()
                .to(ring.scale, {
                    x: originalScale.x * 1.2,
                    y: originalScale.y * 1.2,
                    z: originalScale.z * 1.2,
                    duration: 0.2,
                    ease: "power1.out"
                })
                .to(ring.scale, {
                    x: originalScale.x,
                    y: originalScale.y,
                    z: originalScale.z,
                    duration: 0.5,
                    ease: "elastic.out(1, 0.3)"
                });
            
            // Also animate hover effect
            gsap.to(ring.userData, {
                hoverEffect: 1,
                duration: 0.3,
                onUpdate: () => {
                    ring.material.uniforms.hoverEffect.value = ring.userData.hoverEffect;
                },
                onComplete: () => {
                    gsap.to(ring.userData, {
                        hoverEffect: 0,
                        duration: 1,
                        onUpdate: () => {
                            ring.material.uniforms.hoverEffect.value = ring.userData.hoverEffect;
                        }
                    });
                }
            });
        }
        
        /**
         * Update quality settings based on selection
         */
        function updateQualitySettings() {
            switch (qualityLevel) {
                case 'low':
                    CONFIG.particles.count = 500;
                    CONFIG.particles.sparkleCount = 50;
                    renderer.setPixelRatio(1);
                    break;
                case 'medium':
                    CONFIG.particles.count = 1000;
                    CONFIG.particles.sparkleCount = 100;
                    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 1.5));
                    break;
                case 'high':
                    CONFIG.particles.count = 2000;
                    CONFIG.particles.sparkleCount = 200;
                    renderer.setPixelRatio(Utils.getOptimalPixelRatio());
                    break;
            }
            
            // Update particle systems with new counts if needed
            if (particles) {
                scene.remove(particles);
                createParticles();
            }
            
            if (sparkles) {
                scene.remove(sparkles);
                createSparkleSystems();
            }
        }
        
        /**
         * Toggle debug panel visibility
         */
        function toggleDebugPanel() {
            isDebugMode = !isDebugMode;
            debugPanel.style.display = isDebugMode ? 'block' : 'none';
        }
        
        /**
         * Simulate loading progress for better UX
         */
        function simulateLoading() {
            let progress = 40;
            const interval = setInterval(() => {
                progress += Math.floor(Math.random() * 10) + 1;
                if (progress >= 100) {
                    progress = 100;
                    clearInterval(interval);
                }
                updateLoadingProgress(progress);
            }, 200);
        }
        
        /**
         * Update loading progress bar
         */
        function updateLoadingProgress(progress) {
            loadingProgressBar.style.width = progress + '%';
            
            if (progress >= 100) {
                setTimeout(() => {
                    loadingScreen.style.opacity = 0;
                    setTimeout(() => {
                        loadingScreen.style.display = 'none';
                    }, 500);
                }, 500);
            }
        }
        
        /**
         * Main animation loop
         */
        function animate() {
            requestAnimationFrame(animate);
            
            const time = clock.getElapsedTime();
            deltaTime = clock.getDelta();
            frameCount++;
            
            // Update stats if enabled
            if (CONFIG.debug.showStats && stats) {
                stats.begin();
            }
            
            // Dynamic quality adjustment
            if (frameCount % 60 === 0) {
                const fps = Math.round(1 / deltaTime);
                if (qualityLevel !== 'low' && fps < CONFIG.performance.lowQualityThreshold) {
                    qualityLevel = 'low';
                    updateQualitySettings();
                } else if (qualityLevel === 'low' && fps > CONFIG.performance.mediumQualityThreshold) {
                    qualityLevel = 'medium';
                    updateQualitySettings();
                }
            }
            
            // Update all animations and effects
            updateRaycast();
            updateMaterials(time);
            updateParticles(time);
            updateCustomParticles(time);
            
            // Update controls if enabled
            if (controls) {
                controls.update();
            }
            
            // Render the scene
            if (isPostProcessingEnabled) {
                composer.render();
            } else {
                renderer.render(scene, camera);
            }
            
            // Update stats if enabled
            if (CONFIG.debug.showStats && stats) {
                stats.end();
            }
        }
        
        /**
         * Update raycaster for interaction
         */
        function updateRaycast() {
            // Use raycaster to detect hover on rings
            raycaster.setFromCamera(mouse, camera);
            
            const intersects = raycaster.intersectObjects(rings);
            
            if (intersects.length > 0) {
                if (intersectedObject !== intersects[0].object) {
                    // Reset previous hover state
                    if (intersectedObject) {
                        gsap.to(intersectedObject.userData, {
                            targetHoverEffect: 0,
                            duration: 0.5,
                            onUpdate: () => {
                                intersectedObject.material.uniforms.hoverEffect.value = 
                                    Utils.lerp(intersectedObject.material.uniforms.hoverEffect.value, 
                                             intersectedObject.userData.targetHoverEffect, 0.1);
                            }
                        });
                    }
                    
                    // Set new intersected object
                    intersectedObject = intersects[0].object;
                    
                    // Show tooltip with object name
                    tooltip.textContent = intersectedObject.userData.name;
                    tooltip.style.opacity = 1;
                    
                    // Set hover effect on current object
                    gsap.to(intersectedObject.userData, {
                        targetHoverEffect: 1,
                        duration: 0.5
                    });
                    
                    // Change cursor to pointer
                    document.body.style.cursor = 'pointer';
                }
            } else {
                // No intersection, reset hover state
                if (intersectedObject) {
                    gsap.to(intersectedObject.userData, {
                        targetHoverEffect: 0,
                        duration: 0.5,
                        onUpdate: () => {
                            intersectedObject.material.uniforms.hoverEffect.value = 
                                Utils.lerp(intersectedObject.material.uniforms.hoverEffect.value, 
                                         intersectedObject.userData.targetHoverEffect, 0.1);
                        }
                    });
                    
                    // Hide tooltip
                    tooltip.style.opacity = 0;
                    
                    // Reset cursor
                    document.body.style.cursor = 'auto';
                    
                    intersectedObject = null;
                }
            }
            
            // Smoothly update hover effect on all rings
            rings.forEach(ring => {
                // Interpolate current hover effect to target
                ring.material.uniforms.hoverEffect.value = 
                    Utils.lerp(ring.material.uniforms.hoverEffect.value, ring.userData.targetHoverEffect, 0.1);
            });
        }
        
        /**
         * Update all material uniforms
         */
        function updateMaterials(time) {
            // Update time uniform for all shader materials
            if (goldRing) goldRing.material.uniforms.time.value = time;
            if (silverRing) silverRing.material.uniforms.time.value = time;
            if (blueRing) blueRing.material.uniforms.time.value = time;
            
            // Update particles time uniform
            if (particles && particles.material.uniforms) {
                particles.material.uniforms.time.value = time;
            }
        }
        
        /**
         * Update particles animation
         */
        function updateParticles(time) {
            if (!particles || !isParticlesEnabled) return;
            
            // Rotate particles slowly
            particles.rotation.y = time * 0.05;
            
            // Update sparkles
            if (sparkles) {
                sparkles.rotation.y = time * 0.1;
                
                // Pulse sparkles size
                const scale = 1 + Math.sin(time * 2) * 0.1;
                sparkles.material.size = CONFIG.particles.sparkleSize * scale;
            }
        }
        
        /**
         * Update custom particle systems
         */
        function updateCustomParticles(time) {
            if (!isParticlesEnabled) return;
            
            customParticles.forEach((system, index) => {
                // Rotate each system differently
                system.rotation.x = time * 0.2 * (index % 3 + 1);
                system.rotation.y = time * 0.3 * ((index + 1) % 3 + 1);
                
                // Move particles in a circular pattern
                const radius = 2 + index * 0.5;
                const speed = 0.2 + index * 0.05;
                system.position.x = Math.cos(time * speed) * radius;
                system.position.z = Math.sin(time * speed) * radius;
                
                // Pulse size
                const pulseScale = 0.7 + Math.sin(time * 3 + index) * 0.3;
                system.material.size = system.material.size * 0.95 + pulseScale * 0.05;
            });
        }
        
        /**
         * Helper function to create dust particles that follow mouse
         */
        function createMouseDustParticles() {
            const geometry = new THREE.BufferGeometry();
            const particleCount = 50;
            const positions = new Float32Array(particleCount * 3);
            const opacities = new Float32Array(particleCount);
            const sizes = new Float32Array(particleCount);
            
            for (let i = 0; i < particleCount; i++) {
                positions[i * 3] = 0;
                positions[i * 3 + 1] = 0;
                positions[i * 3 + 2] = 0;
                opacities[i] = 0;
                sizes[i] = Utils.random(0.01, 0.05);
            }
            
            geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));
            geometry.setAttribute('opacity', new THREE.BufferAttribute(opacities, 1));
            geometry.setAttribute('size', new THREE.BufferAttribute(sizes, 1));
            
            const material = new THREE.ShaderMaterial({
                uniforms: {
                    color: { value: new THREE.Color(0xc8b273) },
                    pointTexture: { value: createSparkleTexture() }
                },
                vertexShader: `
                    attribute float opacity;
                    attribute float size;
                    varying float vOpacity;
                    void main() {
                        vOpacity = opacity;
                        vec4 mvPosition = modelViewMatrix * vec4(position, 1.0);
                        gl_PointSize = size * (300.0 / -mvPosition.z);
                        gl_Position = projectionMatrix * mvPosition;
                    }
                `,
                fragmentShader: `
                    uniform vec3 color;
                    uniform sampler2D pointTexture;
                    varying float vOpacity;
                    void main() {
                        gl_FragColor = vec4(color, vOpacity) * texture2D(pointTexture, gl_PointCoord);
                    }
                `,
                transparent: true,
                blending: THREE.AdditiveBlending,
                depthWrite: false
            });
            
            const particleSystem = new THREE.Points(geometry, material);
            scene.add(particleSystem);
            
            return {
                system: particleSystem,
                update: function(mousePosition) {
                    const positions = particleSystem.geometry.attributes.position.array;
                    const opacities = particleSystem.geometry.attributes.opacity.array;
                    
                    for (let i = 0; i < particleCount; i++) {
                        const i3 = i * 3;
                        
                        // Slowly move particles toward mouse position
                        positions[i3] += (mousePosition.x - positions[i3]) * 0.02;
                        positions[i3 + 1] += (mousePosition.y - positions[i3 + 1]) * 0.02;
                        positions[i3 + 2] += (mousePosition.z - positions[i3 + 2]) * 0.02;
                        
                        // Fade particles in and out
                        opacities[i] = Math.max(0, opacities[i] - 0.01);
                    }
                    
                    particleSystem.geometry.attributes.position.needsUpdate = true;
                    particleSystem.geometry.attributes.opacity.needsUpdate = true;
                },
                activateParticles: function(mousePosition, count) {
                    const positions = particleSystem.geometry.attributes.position.array;
                    const opacities = particleSystem.geometry.attributes.opacity.array;
                    
                    for (let i = 0; i < count; i++) {
                        const index = Math.floor(Math.random() * particleCount);
                        const i3 = index * 3;
                        
                        positions[i3] = mousePosition.x;
                        positions[i3 + 1] = mousePosition.y;
                        positions[i3 + 2] = mousePosition.z;
                        opacities[index] = 1.0;
                    }
                    
                    particleSystem.geometry.attributes.position.needsUpdate = true;
                    particleSystem.geometry.attributes.opacity.needsUpdate = true;
                }
            };
        }
        
        /**
         * Calculate world position from mouse coordinates
         */
        function getMouseWorldPosition() {
            // Create vector at mouse position in normalized device coordinates
            const mouseVector = new THREE.Vector3(mouse.x, mouse.y, 0.5);
            
            // Unproject to get world coordinates
            mouseVector.unproject(camera);
            
            // Calculate direction
            const direction = mouseVector.sub(camera.position).normalize();
            
            // Calculate distance to a plane in front of the camera
            const distance = 10;
            const scaledDirection = direction.multiplyScalar(distance);
            
            // Return world position
            return camera.position.clone().add(scaledDirection);
        }
        
        // Initialize the application
        init();
    })();
    </script>
</body>
</html>