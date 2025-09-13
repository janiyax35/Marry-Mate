<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ page import="java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>

<%
// Current timestamp
String currentDateTime = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
// Get current user if available
String currentUserLogin = (session != null && session.getAttribute("username") != null) ? 
    session.getAttribute("username").toString() : "Guest";

// Get the requested URL that caused the error
String requestedUrl = request.getRequestURI();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="robots" content="noindex, nofollow">
    <title>Access Denied | Marry Mate</title>
    
    <!-- Bootstrap CSS -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css">
    
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- Google Fonts - Playfair Display & Montserrat -->
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Montserrat:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    
    <style>
        :root {
            --primary: #1a365d;
            --primary-light: #2d5a92;
            --secondary: #c8b273;
            --secondary-light: #e0d4a9;
            --text-dark: #333333;
            --text-medium: #666666;
        }
        
        body {
            font-family: 'Montserrat', sans-serif;
            background: linear-gradient(135deg, rgba(26, 54, 93, 0.95), rgba(45, 90, 146, 0.95)), url('${pageContext.request.contextPath}/assets/images/bg/error-bg.jpg');
            background-size: cover;
            background-position: center;
            background-attachment: fixed;
            color: #fff;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0;
            padding: 20px;
        }
        
        .error-container {
            background-color: rgba(255, 255, 255, 0.95);
            border-radius: 15px;
            box-shadow: 0 15px 30px rgba(0, 0, 0, 0.2);
            max-width: 800px;
            width: 100%;
            padding: 2.5rem;
            color: var(--text-dark);
            position: relative;
            overflow: hidden;
        }
        
        .error-container::before {
            content: "";
            position: absolute;
            top: 0;
            left: 0;
            width: 8px;
            height: 100%;
            background: linear-gradient(to bottom, var(--secondary), var(--secondary-light));
        }
        
        .error-header {
            text-align: center;
            margin-bottom: 2.5rem;
            position: relative;
        }
        
        .error-header::after {
            content: "";
            position: absolute;
            bottom: -10px;
            left: 50%;
            transform: translateX(-50%);
            width: 80px;
            height: 3px;
            background: linear-gradient(to right, var(--secondary), var(--secondary-light));
            border-radius: 50rem;
        }
        
        .error-header h1 {
            font-family: 'Playfair Display', serif;
            color: var(--primary);
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 0.5rem;
        }
        
        .error-header .error-code {
            font-size: 1.25rem;
            color: var(--primary-light);
            font-weight: 600;
        }
        
        .error-icon {
            font-size: 5rem;
            margin-bottom: 1.5rem;
            color: var(--primary);
            opacity: 0.8;
        }
        
        .error-message {
            text-align: center;
            margin-bottom: 2rem;
        }
        
        .error-message p {
            font-size: 1.1rem;
            line-height: 1.6;
            color: var(--text-medium);
            margin-bottom: 1.25rem;
        }
        
        .error-details {
            background-color: rgba(26, 54, 93, 0.05);
            border: 1px solid rgba(26, 54, 93, 0.1);
            border-radius: 10px;
            padding: 1.25rem;
            margin-bottom: 1.5rem;
        }
        
        .error-details h3 {
            font-size: 1rem;
            font-weight: 600;
            color: var(--primary);
            margin-bottom: 0.75rem;
        }
        
        .error-details p {
            font-size: 0.9rem;
            margin-bottom: 0.5rem;
            color: var(--text-medium);
        }
        
        .error-details code {
            background-color: rgba(26, 54, 93, 0.1);
            padding: 0.2rem 0.4rem;
            border-radius: 4px;
            font-size: 0.85rem;
        }
        
        .actions {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            justify-content: center;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            border: none;
            padding: 12px 25px;
            border-radius: 50px;
            box-shadow: 0 4px 15px rgba(26, 54, 93, 0.2);
            transition: all 0.3s ease;
        }
        
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(26, 54, 93, 0.3);
            background: linear-gradient(135deg, var(--primary), #1a365d);
        }
        
        .btn-outline-primary {
            background: transparent;
            border: 2px solid var(--primary);
            color: var(--primary);
            padding: 10px 25px;
            border-radius: 50px;
            transition: all 0.3s ease;
            font-weight: 500;
        }
        
        .btn-outline-primary:hover {
            background-color: rgba(26, 54, 93, 0.05);
            box-shadow: 0 4px 10px rgba(26, 54, 93, 0.1);
            color: var(--primary);
            border-color: var(--primary);
        }
        
        .footer {
            text-align: center;
            margin-top: 2rem;
            font-size: 0.85rem;
            color: var(--text-medium);
        }
        
        .footer a {
            color: var(--primary);
            text-decoration: none;
            transition: all 0.2s ease;
        }
        
        .footer a:hover {
            color: var(--secondary);
            text-decoration: underline;
        }
        
        .error-code-display {
            font-family: 'Montserrat', sans-serif;
            font-size: 8rem;
            font-weight: 700;
            line-height: 1;
            background: linear-gradient(135deg, var(--primary), var(--secondary));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            text-shadow: 2px 2px 10px rgba(0, 0, 0, 0.05);
            margin-bottom: 2rem;
            text-align: center;
        }
        
        .lock-icon {
            position: absolute;
            top: -30px;
            right: -30px;
            width: 100px;
            height: 100px;
            background-color: rgba(200, 178, 115, 0.1);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--secondary);
            font-size: 2.5rem;
            opacity: 0.5;
            transform: rotate(-15deg);
        }
        
        @media (max-width: 768px) {
            .error-container {
                padding: 1.5rem;
            }
            
            .error-code-display {
                font-size: 6rem;
            }
            
            .error-icon {
                font-size: 3.5rem;
            }
            
            .error-header h1 {
                font-size: 2rem;
            }
            
            .actions {
                flex-direction: column;
            }
            
            .btn {
                width: 100%;
            }
        }
    </style>
</head>
<body>
    <div class="error-container">
        <div class="lock-icon">
            <i class="fas fa-lock"></i>
        </div>
        
        <div class="error-header">
            <div class="error-code-display">403</div>
            <h1>Access Denied</h1>
            <div class="error-code">Forbidden • Error Code: 403</div>
        </div>
        
        <div class="error-message">
            <div class="error-icon">
                <i class="fas fa-user-shield"></i>
            </div>
            <p>You don't have permission to access this page.</p>
            <p>This area is restricted and requires proper authorization or higher privileges.</p>
        </div>
        
        <div class="error-details">
            <h3>Error Details</h3>
            <p><strong>Timestamp:</strong> <%= currentDateTime %></p>
            <p><strong>User:</strong> <%= currentUserLogin %></p>
            <p><strong>Requested URL:</strong> <code><%= requestedUrl %></code></p>
        </div>
        
        <div class="actions">
            <a href="${pageContext.request.contextPath}/" class="btn btn-primary">
                <i class="fas fa-home me-2"></i> Return to Homepage
            </a>
            <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline-primary">
                <i class="fas fa-sign-in-alt me-2"></i> Sign In
            </a>
            <button onclick="window.history.back()" class="btn btn-outline-primary">
                <i class="fas fa-arrow-left me-2"></i> Go Back
            </button>
        </div>
        
        <div class="footer">
            <p>If you believe this is an error, please contact <a href="mailto:support@marrymate.com">support@marrymate.com</a></p>
            <p>&copy; 2025 Marry Mate Wedding Planning System | <a href="${pageContext.request.contextPath}/help.jsp">Help Center</a></p>
        </div>
    </div>

    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>