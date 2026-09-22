import json

HTML_CONTENT = """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>HR Employee Lookup</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            max-width: 500px;
            width: 100%;
            padding: 40px;
        }
        .header {
            text-align: center;
            margin-bottom: 30px;
        }
        .header h1 {
            color: #333;
            font-size: 28px;
            margin-bottom: 8px;
        }
        .header p {
            color: #666;
            font-size: 14px;
        }
        .auth-section {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-btn {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px 30px;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s, box-shadow 0.2s;
        }
        .login-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
        }
        .logout-btn {
            background: #dc3545;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            font-size: 14px;
            cursor: pointer;
            margin-top: 10px;
        }
        .logout-btn:hover {
            background: #c82333;
        }
        .search-section {
            display: none;
        }
        .search-section.active {
            display: block;
        }
        .form-group {
            margin-bottom: 20px;
        }
        .form-group label {
            display: block;
            margin-bottom: 8px;
            color: #333;
            font-weight: 600;
            font-size: 14px;
        }
        .form-group input {
            width: 100%;
            padding: 10px;
            border: 2px solid #e0e0e0;
            border-radius: 6px;
            font-size: 14px;
            transition: border-color 0.3s;
        }
        .form-group input:focus {
            outline: none;
            border-color: #667eea;
        }
        .search-btn {
            width: 100%;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            padding: 12px;
            border-radius: 6px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: transform 0.2s;
        }
        .search-btn:hover {
            transform: translateY(-2px);
        }
        .search-btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        .results {
            display: none;
            margin-top: 30px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 6px;
            border-left: 4px solid #667eea;
        }
        .results.show {
            display: block;
        }
        .result-item {
            margin-bottom: 15px;
        }
        .result-label {
            font-weight: 600;
            color: #333;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .result-value {
            color: #666;
            font-size: 16px;
            margin-top: 4px;
        }
        .error {
            background: #f8d7da;
            color: #721c24;
            padding: 12px;
            border-radius: 6px;
            margin-top: 15px;
            border-left: 4px solid #f5c6cb;
        }
        .success-message {
            background: #d4edda;
            color: #155724;
            padding: 12px;
            border-radius: 6px;
            margin-bottom: 20px;
        }
        .loading {
            display: none;
            text-align: center;
            color: #667eea;
            font-weight: 600;
        }
        .loading.show {
            display: block;
        }
        .user-info {
            text-align: center;
            color: #666;
            font-size: 13px;
            margin-bottom: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔍 HR Lookup</h1>
            <p>Search employee information by ID</p>
        </div>

        <!-- Auth Section -->
        <div class="auth-section" id="authSection">
            <button class="login-btn" onclick="login()">Login with Cognito</button>
        </div>

        <!-- Logged In Section -->
        <div id="loggedInSection" style="display: none;">
            <div class="success-message">
                ✅ Successfully logged in!
            </div>
            <div class="user-info" id="userInfo"></div>
            
            <!-- Search Section -->
            <div class="search-section active">
                <div class="form-group">
                    <label for="empId">Employee ID</label>
                    <input 
                        type="text" 
                        id="empId" 
                        placeholder="Enter employee ID (e.g., 1001)" 
                        onkeypress="handleEnter(event)"
                    >
                </div>
                <button class="search-btn" onclick="searchEmployee()">Search</button>
            </div>

            <!-- Loading -->
            <div class="loading" id="loading">Searching...</div>

            <!-- Results -->
            <div class="results" id="results">
                <div class="result-item">
                    <div class="result-label">Employee ID</div>
                    <div class="result-value" id="resultEmpId"></div>
                </div>
                <div class="result-item">
                    <div class="result-label">Name</div>
                    <div class="result-value" id="resultName"></div>
                </div>
                <div class="result-item">
                    <div class="result-label">Salary</div>
                    <div class="result-value" id="resultSalary"></div>
                </div>
                <div class="result-item">
                    <div class="result-label">Date of Join</div>
                    <div class="result-value" id="resultDateOfJoin"></div>
                </div>
                <div class="result-item">
                    <div class="result-label">Description</div>
                    <div class="result-value" id="resultDescription"></div>
                </div>
            </div>

            <!-- Error -->
            <div class="error" id="error" style="display: none;"></div>

            <!-- Logout -->
            <button class="logout-btn" onclick="logout()">Logout</button>
        </div>
    </div>

    <script>
        const API_BASE = window.location.origin;
        const COGNITO_DOMAIN = "serverless-hr-app-dev-611622961093";
        const CLIENT_ID = "5cm74f5tt91gc7812i8aq42p63";
        const REDIRECT_URI = "https://r97uk1mdk3.execute-api.us-east-1.amazonaws.com/prod/";

        // Handle Cognito callback - extract tokens from URL fragment
        function handleCognitoCallback() {
            const hash = window.location.hash.substring(1);

            if (!hash) {
                return;
            }

            const params = new URLSearchParams(hash);

            const idToken = params.get('id_token');
            const accessToken = params.get('access_token');

            if (idToken) {
                localStorage.setItem('idToken', idToken);
                console.log('Stored ID Token');
            }

            if (accessToken) {
                localStorage.setItem('accessToken', accessToken);
                console.log('Stored Access Token');
            }

            // Remove tokens from URL for security
            window.history.replaceState(
                {},
                document.title,
                window.location.pathname + window.location.search
            );
        }

        // Login function
        function login() {
            const authUrl =
                `https://${COGNITO_DOMAIN}.auth.us-east-1.amazoncognito.com/oauth2/authorize` +
                `?client_id=${encodeURIComponent(CLIENT_ID)}` +
                `&response_type=token` +
                `&scope=${encodeURIComponent('openid email profile')}` +
                `&redirect_uri=${encodeURIComponent(REDIRECT_URI)}`;

            window.location.href = authUrl;
        }

        // Logout function
        function logout() {
            localStorage.removeItem('idToken');
            localStorage.removeItem('accessToken');
            
            const logoutUrl =
                `https://${COGNITO_DOMAIN}.auth.us-east-1.amazoncognito.com/logout` +
                `?client_id=${encodeURIComponent(CLIENT_ID)}` +
                `&logout_uri=${encodeURIComponent(REDIRECT_URI)}`;

            window.location.href = logoutUrl;
        }

        // Update UI based on auth state
        function updateAuthUI(isLoggedIn) {
            const authSection = document.getElementById('authSection');
            const loggedInSection = document.getElementById('loggedInSection');

            if (isLoggedIn) {
                authSection.style.display = 'none';
                loggedInSection.style.display = 'block';
                console.log('User is logged in');
            } else {
                authSection.style.display = 'block';
                loggedInSection.style.display = 'none';
                console.log('User is not logged in');
            }
        }

        // Search employee
        async function searchEmployee() {
            const empId = document.getElementById('empId').value.trim();

            if (!empId) {
                showError('Please enter an Employee ID');
                return;
            }

            const token = localStorage.getItem('accessToken');

            if (!token) {
                showError('Not authenticated. Please login again.');
                updateAuthUI(false);
                return;
            }

            showLoading(true);
            hideError();
            hideResults();

            try {
                const response = await fetch(`${API_BASE}/employee/${empId}`, {
                    method: 'GET',
                    headers: {
                        'Authorization': `Bearer ${token}`,
                        'Content-Type': 'application/json'
                    }
                });

                showLoading(false);

                if (!response.ok) {
                    if (response.status === 404) {
                        showError(`Employee with ID ${empId} not found.`);
                    } else if (response.status === 401) {
                        showError('Authentication failed. Please login again.');
                        updateAuthUI(false);
                    } else {
                        const errorData = await response.json();
                        showError1(`HTTP ${response.status} $				{response.statusText}\n\n` +
        `Response:\n${errorText}`
    );
                    }
                    return;
                }

                const data = await response.json();

                document.getElementById('resultEmpId').textContent = data.employeeId || 'N/A';
                document.getElementById('resultName').textContent = data.name || 'N/A';
                document.getElementById('resultSalary').textContent = '$' + (data.salary || 'N/A');
                document.getElementById('resultDateOfJoin').textContent = data.dateOfJoin || 'N/A';
                document.getElementById('resultDescription').textContent = data.description || 'N/A';

                showResults();
            } catch (error) {
                showLoading(false);
                console.error('Error:', error);
                showError('Network error. Please try again.');
            }
        }

        function handleEnter(event) {
            if (event.key === 'Enter') {
                searchEmployee();
            }
        }

        function showError(message) {
            const errorDiv = document.getElementById('error');
            errorDiv.textContent = message;
            errorDiv.style.display = 'block';
        }
        
        function showError1(message) {
             const resultDiv = document.getElementById('result');

             resultDiv.className = 'result show error';

             resultDiv.innerHTML = `
                   <div class="error-message">
                            ✗ Error
                   </div>
                   <pre style="
                      white-space: pre-wrap;
                      word-break: break-word;
                      color: #e74c3c;
                      margin-top: 10px;
                  ">${escapeHtml(message)}</pre>
             `;
        }


        function hideError() {
            document.getElementById('error').style.display = 'none';
        }

        function showResults() {
            document.getElementById('results').classList.add('show');
        }

        function hideResults() {
            document.getElementById('results').classList.remove('show');
        }

        function showLoading(show) {
            document.getElementById('loading').classList.toggle('show', show);
        }

        // On page load
        window.addEventListener('load', function() {
            handleCognitoCallback();

            const token = localStorage.getItem('accessToken');

            if (token) {
                updateAuthUI(true);
            } else {
                updateAuthUI(false);
            }
        });
    </script>
</body>
</html>
"""

def lambda_handler(event, context):
    """
    Handler for GET / - returns the HTML page with OAuth integration
    Called by: GET /
    """
    try:
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'text/html',
                'Access-Control-Allow-Origin': '*'
            },
            'body': HTML_CONTENT
        }
    
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                'Content-Type': 'application/json'
            },
            'body': json.dumps({
                'error': 'Internal server error',
                'message': str(e)
            })
        }
