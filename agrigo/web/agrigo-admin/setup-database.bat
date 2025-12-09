@echo off
echo ========================================
echo   AGRIGO ADMIN - DATABASE SETUP
echo ========================================
echo.

cd /d "%~dp0"

echo [1/4] Dropping existing tables...
php artisan migrate:fresh --force
echo.

echo [2/4] Running migrations...
php artisan migrate --force
echo.

echo [3/4] Seeding database...
php artisan db:seed --force
echo.

echo [4/4] Seeding new features...
php artisan db:seed --class=NewFeaturesSeeder --force
echo.

echo ========================================
echo   SETUP COMPLETED!
echo ========================================
echo.
echo Admin Login:
echo URL: http://127.0.0.1:8000/admin/login
echo Email: admin@agrigo.com
echo Password: admin123
echo.
pause
