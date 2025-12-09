@echo off
echo ========================================
echo   AGRIGO ADMIN - STARTING SERVER
echo ========================================
echo.

cd /d "%~dp0"

echo Server will run on: http://127.0.0.1:8000
echo.
echo Admin Login:
echo - URL: http://127.0.0.1:8000/admin/login
echo - Email: admin@agrigo.com
echo - Password: admin123
echo.
echo Press Ctrl+C to stop the server
echo.
echo ========================================
echo.

php artisan serve
