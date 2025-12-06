# Backend Integration Guide - Serendib Frontend

This document describes how the Flutter frontend (serendib-fe) integrates with the Spring Boot backend (serendib-be).

## Overview

The frontend has been fully integrated with the Spring Boot backend API, providing:
- JWT-based authentication
- User registration and login
- Artifact management (CRUD operations)
- Role-based access control
- Secure token storage
- Automatic token handling in API requests

## Backend API Configuration

### API Base URL

The backend API URL is configured in [`lib/core/constants/app_constants.dart`](lib/core/constants/app_constants.dart):

```dart
static const String baseUrl = 'http://localhost:8080';
static const String apiVersion = '/api/v1';
static const String apiBaseUrl = '$baseUrl$apiVersion';
```

**For Production**: Update the `baseUrl` to your production backend URL.

**For Android Emulator**: Use `http://10.0.2.2:8080` instead of `localhost`

**For iOS Simulator**: Use `http://localhost:8080` (works as-is)

**For Physical Device**: Use your computer's IP address (e.g., `http://192.168.1.100:8080`)

## Architecture

### 1. Models (`lib/models/`)

#### User Model
- **File**: [`user.dart`](lib/models/user.dart)
- Maps to backend `UserResponse` DTO
- Fields: `id`, `firstName`, `lastName`, `email`, `role`, `enabled`

#### Auth Response
- **File**: [`auth_response.dart`](lib/models/auth_response.dart)
- Contains: `accessToken`, `refreshToken`, `tokenType`, `user`

#### Artifact Model
- **File**: [`artifact.dart`](lib/models/artifact.dart)
- Maps to backend `ArtifactResponse` DTO
- Includes `ArtifactListResponse` for paginated results

#### API Error
- **File**: [`api_error.dart`](lib/models/api_error.dart)
- Handles backend error responses
- Provides user-friendly error messages

### 2. Services (`lib/services/`)

#### API Service
- **File**: [`api_service.dart`](lib/services/api_service.dart)
- Base HTTP client for all API calls
- Automatically attaches JWT token to requests
- Handles request/response serialization
- Provides error handling

**Methods**:
- `get()` - GET requests
- `post()` - POST requests
- `put()` - PUT requests
- `delete()` - DELETE requests

#### Auth Service
- **File**: [`auth_service.dart`](lib/services/auth_service.dart)
- Handles authentication operations

**Methods**:
- `login(email, password)` - User login
- `register(firstName, lastName, email, password, role)` - User registration

#### Artifact Service
- **File**: [`artifact_service.dart`](lib/services/artifact_service.dart)
- Manages artifact-related API calls

**Methods**:
- `getArtifacts()` - Get paginated list
- `getArtifactById(id)` - Get single artifact
- `createArtifact(artifact)` - Create new artifact
- `updateArtifact(id, artifact)` - Update artifact
- `deleteArtifact(id)` - Delete artifact
- `searchArtifacts(searchTerm)` - Search artifacts

#### Storage Service
- **File**: [`storage_service.dart`](lib/services/storage_service.dart)
- Handles secure local storage
- Stores JWT tokens in secure storage
- Stores user data in shared preferences

**Token Management**:
- `saveAuthToken(token)` - Save access token
- `getAuthToken()` - Retrieve access token
- `saveRefreshToken(token)` - Save refresh token
- `getRefreshToken()` - Retrieve refresh token

### 3. Providers (State Management)

#### Auth Provider
- **File**: [`providers/auth_provider.dart`](lib/providers/auth_provider.dart)
- Manages authentication state
- Provides user information
- Handles login/logout

**State**:
- `user` - Current user object
- `isAuthenticated` - Authentication status
- `isLoading` - Loading state
- `error` - Error message

**Methods**:
- `login(email, password)`
- `register(firstName, lastName, email, password)`
- `logout()`
- `clearError()`

#### Artifact Provider
- **File**: [`providers/artifact_provider.dart`](lib/providers/artifact_provider.dart)
- Manages artifact state
- Handles pagination
- Provides CRUD operations

**State**:
- `artifacts` - List of artifacts
- `isLoading` - Loading state
- `error` - Error message
- `currentPage` - Current page number
- `totalPages` - Total pages
- `hasMore` - More data available

**Methods**:
- `fetchArtifacts()` - Load artifacts
- `loadMore()` - Load next page
- `refreshArtifacts()` - Refresh list
- `createArtifact(artifact)`
- `updateArtifact(id, artifact)`
- `deleteArtifact(id)`
- `searchArtifacts(searchTerm)`

### 4. Screens

#### Authentication Screens

**Login Screen** - [`screens/auth/login_screen.dart`](lib/screens/auth/login_screen.dart)
- Email and password fields
- Form validation
- Displays API error messages
- Navigates to home on success

**Register Screen** - [`screens/auth/register_screen.dart`](lib/screens/auth/register_screen.dart)
- First name, last name, email, password fields
- Password confirmation
- Minimum 8 character password requirement
- Displays API error messages

#### Artifacts Screen

**Artifacts List** - [`screens/artifacts/artifacts_list_screen.dart`](lib/screens/artifacts/artifacts_list_screen.dart)
- Displays all artifacts from backend
- Infinite scroll with pagination
- Pull-to-refresh
- Search functionality
- Shows role-based FAB (only for ADMIN/CURATOR)
- Logout button

## API Endpoints Used

### Authentication Endpoints

| Method | Endpoint | Description | Auth Required |
|--------|----------|-------------|---------------|
| POST | `/api/v1/auth/register` | Register new user | No |
| POST | `/api/v1/auth/login` | Login user | No |

**Register Request**:
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "email": "john.doe@example.com",
  "password": "SecurePass123!",
  "role": "USER"
}
```

**Login Request**:
```json
{
  "email": "john.doe@example.com",
  "password": "SecurePass123!"
}
```

**Auth Response**:
```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "tokenType": "Bearer",
  "user": {
    "id": 1,
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@example.com",
    "role": "USER",
    "enabled": true
  }
}
```

### Artifact Endpoints

| Method | Endpoint | Description | Auth Required | Role |
|--------|----------|-------------|---------------|------|
| GET | `/api/v1/artifacts` | Get all artifacts | Yes | All |
| GET | `/api/v1/artifacts/{id}` | Get artifact by ID | Yes | All |
| POST | `/api/v1/artifacts` | Create artifact | Yes | ADMIN, CURATOR |
| PUT | `/api/v1/artifacts/{id}` | Update artifact | Yes | ADMIN, CURATOR |
| DELETE | `/api/v1/artifacts/{id}` | Delete artifact | Yes | ADMIN |
| GET | `/api/v1/artifacts/search` | Search artifacts | Yes | All |

**Query Parameters** (for GET all):
- `page` - Page number (default: 0)
- `size` - Page size (default: 10)
- `sortBy` - Sort field (default: id)
- `sortDir` - Sort direction (default: asc)

## Testing the Integration

### 1. Start Backend

```bash
cd serendib-be
mvn spring-boot:run
```

Backend should be running on `http://localhost:8080`

### 2. Verify Backend is Running

Open browser and go to: `http://localhost:8080/swagger-ui.html`

### 3. Update Frontend API URL (if needed)

If using Android emulator or physical device, update [`app_constants.dart`](lib/core/constants/app_constants.dart):

```dart
// For Android Emulator
static const String baseUrl = 'http://10.0.2.2:8080';

// For Physical Device (use your computer's IP)
static const String baseUrl = 'http://192.168.1.100:8080';
```

### 4. Run Flutter App

```bash
cd serendib-fe
flutter pub get
flutter run
```

### 5. Test Flow

1. **Register**: Create a new account
   - Fill in first name, last name, email, password
   - Click "Sign Up"
   - Should automatically login and navigate to home

2. **Logout**: Click logout button

3. **Login**: Login with created account
   - Enter email and password
   - Click "Login"
   - Should navigate to home

4. **View Artifacts**: Navigate to artifacts screen
   - Should display list of artifacts from backend
   - Pull down to refresh
   - Scroll to bottom to load more (pagination)

5. **Search**: Use search bar to find artifacts
   - Type search term
   - Press enter or submit
   - Should show filtered results

## Error Handling

The app handles various error scenarios:

1. **Network Errors**: Shows "Unable to connect to server"
2. **Authentication Errors**: Shows "Invalid email or password"
3. **Validation Errors**: Shows specific field errors from backend
4. **Server Errors**: Shows user-friendly error messages

All errors are displayed as SnackBars at the bottom of the screen.

## Security

### Token Storage

- **Access Token**: Stored in secure storage (iOS Keychain, Android KeyStore)
- **Refresh Token**: Stored in secure storage
- **User Data**: Stored in shared preferences (non-sensitive data)

### Token Usage

- Automatically attached to all authenticated requests
- Format: `Authorization: Bearer <token>`
- Expires after 1 hour (configurable in backend)

### Logout

- Clears all tokens from storage
- Clears user data
- Navigates to login screen

## Troubleshooting

### Issue: Cannot connect to backend

**Solution**:
1. Verify backend is running: `http://localhost:8080/swagger-ui.html`
2. Check firewall settings
3. For Android emulator, use `http://10.0.2.2:8080`
4. For physical device, use computer's IP address

### Issue: Login fails with "Invalid credentials"

**Solution**:
1. Verify you're registered in the backend
2. Check email/password are correct
3. Check backend logs for detailed error

### Issue: Artifacts not loading

**Solution**:
1. Verify you're logged in
2. Check token is valid (not expired)
3. Check backend has artifacts data
4. Check network connectivity

### Issue: "CORS error" in browser

**Note**: CORS errors only occur when testing with web browsers. Flutter mobile apps don't have CORS restrictions.

**Solution**: Backend already has CORS configured for localhost origins.

## Next Steps

1. **Add Image Upload**: Extend artifact model to support images
2. **Implement Refresh Token**: Add automatic token refresh when access token expires
3. **Add Offline Support**: Cache data locally for offline access
4. **Add Push Notifications**: Notify users of new artifacts
5. **Add Social Features**: Comments, ratings, favorites
6. **Implement Deep Linking**: Share artifacts via URL

## File Structure Summary

```
lib/
   core/
      constants/
          app_constants.dart         # API URLs and configuration
   models/
      user.dart                      # User model
      auth_response.dart             # Auth response model
      artifact.dart                  # Artifact model
      api_error.dart                 # Error model
   services/
      api_service.dart               # Base API client
      auth_service.dart              # Auth API calls
      artifact_service.dart          # Artifact API calls
      storage_service.dart           # Local storage
   providers/
      auth_provider.dart             # Auth state management
      artifact_provider.dart         # Artifact state management
   screens/
      auth/
         login_screen.dart          # Login UI
         register_screen.dart       # Register UI
      artifacts/
          artifacts_list_screen.dart # Artifacts list UI
   main.dart                          # App entry point
```

## Support

For issues or questions:
- Backend API: See [`serendib-be/README.md`](../serendib-be/README.md)
- Frontend: Check Flutter documentation
- API Testing: Use Swagger UI at `http://localhost:8080/swagger-ui.html`
