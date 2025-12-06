<!-- AgriGo Project Instructions -->

## Project Overview
AgriGo is an agricultural management application with:
- Flutter mobile app for farmers
- Laravel web admin panel for management
- Financial tracking and transaction management
- User management and reporting features

## Development Guidelines

### Flutter Mobile App
- Located in root directory (lib/, android/, ios/, etc.)
- Uses Material Design with green theme (#2E8B25)
- Indonesian number formatting (dots as thousands separator)
- Real-time financial tracking with profit/loss calculations

### Laravel Web Admin Panel
- Located in web/ directory
- Admin dashboard for user management
- Transaction monitoring and financial reports
- RESTful API endpoints for mobile app integration
- Authentication and role-based access control

## File Structure
```
agrigo/
├── lib/ (Flutter mobile app)
├── web/ (Laravel admin panel)
├── android/, ios/, etc. (Flutter platform files)
└── .github/ (project instructions)
```

## Development Rules
- Keep mobile and web components separate
- Use consistent green theme across platforms
- Implement proper API authentication
- Follow Laravel and Flutter best practices
- Maintain Indonesian localization for numbers and dates