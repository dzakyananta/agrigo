# Agrigo Admin Panel

Panel admin web untuk platform manajemen pertanian Agrigo yang dibangun dengan Laravel Framework.

## Fitur Utama

### 🔐 Autentikasi Admin

-   Login admin dengan validasi keamanan
-   Session management yang aman
-   Role-based access control

### 📊 Dashboard Analytics

-   Statistik real-time pengguna dan transaksi
-   Chart analisis bulanan menggunakan Chart.js
-   Cards overview dengan data terkini
-   Quick actions untuk navigasi cepat

### 👥 User Management

-   Daftar lengkap pengguna (petani, pembeli, admin)
-   Edit profil pengguna dan informasi pertanian
-   Toggle status aktif/non-aktif pengguna
-   Filter dan pencarian pengguna
-   Pagination untuk performa optimal

### 💰 Transaction Management

-   Monitor semua transaksi pertanian
-   Update status transaksi (pending, confirmed, completed, cancelled)
-   Filter berdasarkan status, tanggal, dan tipe transaksi
-   Detail transaksi lengkap dengan informasi komoditas

### 🌱 Data Models

-   **User**: Manajemen akun dengan role (farmer/buyer/admin)
-   **UserProfile**: Profil detil termasuk informasi pertanian
-   **Commodity**: Master data komoditas pertanian
-   **Transaction**: Transaksi jual-beli komoditas
-   **WeatherData**: Data cuaca untuk analisis pertanian

## Tech Stack

-   **Framework**: Laravel 12.0
-   **Database**: MySQL/PostgreSQL
-   **Frontend**: Bootstrap 5 + Font Awesome
-   **Charts**: Chart.js
-   **Icons**: Font Awesome 6.4.0
-   **Authentication**: Laravel Auth

## Installation & Setup

### 1. Prerequisites

```bash
- PHP >= 8.2
- Composer
- MySQL/PostgreSQL
- Node.js & NPM (optional)
```

### 2. Clone & Install Dependencies

```bash
cd web/agrigo-admin
composer install
npm install (optional, untuk asset compilation)
```

### 3. Environment Configuration

```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate

# Configure database di .env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=agrigo_admin
DB_USERNAME=root
DB_PASSWORD=
```

### 4. Database Setup

```bash
# Create database
mysql -u root -p
CREATE DATABASE agrigo_admin;

# Run migrations (jika ada)
php artisan migrate

# Seed dengan data sample
php artisan db:seed
```

### 5. Start Development Server

```bash
php artisan serve
```

Aplikasi akan tersedia di `http://localhost:8000`

## Login Credentials

### Admin Account

-   **Email**: admin@agrigo.com
-   **Password**: admin123

### Sample Farmer Accounts

-   **Email**: budi@farmer.com / **Password**: password123
-   **Email**: siti@farmer.com / **Password**: password123

### Sample Buyer Account

-   **Email**: buyer@agromandiri.com / **Password**: password123

## File Structure

```
agrigo-admin/
├── app/
│   ├── Http/Controllers/Admin/
│   │   ├── AdminController.php      # Auth & login admin
│   │   ├── DashboardController.php  # Dashboard analytics
│   │   ├── UserController.php       # User management
│   │   └── TransactionController.php # Transaction management
│   └── Models/
│       ├── User.php                 # User model + relationships
│       ├── UserProfile.php          # Profile dengan data pertanian
│       ├── Commodity.php            # Master komoditas
│       ├── Transaction.php          # Transaksi jual-beli
│       └── WeatherData.php          # Data cuaca
├── resources/views/admin/
│   ├── layouts/
│   │   └── app.blade.php           # Layout utama dengan sidebar
│   ├── auth/
│   │   └── login.blade.php         # Halaman login admin
│   ├── dashboard.blade.php         # Dashboard dengan charts
│   ├── users/
│   │   ├── index.blade.php         # List user dengan filter
│   │   └── edit.blade.php          # Edit user & profile
│   └── transactions/
│       └── index.blade.php         # List & manage transaksi
├── routes/web.php                  # Routes admin
└── database/seeders/DatabaseSeeder.php # Sample data
```

## API Routes

### Admin Authentication

-   `GET /admin/login` - Show login form
-   `POST /admin/login` - Process login
-   `POST /admin/logout` - Logout admin

### Dashboard

-   `GET /admin/dashboard` - Dashboard analytics

### User Management

-   `GET /admin/users` - List users dengan pagination
-   `GET /admin/users/{id}` - Show user detail
-   `GET /admin/users/{id}/edit` - Edit user form
-   `PUT /admin/users/{id}` - Update user
-   `DELETE /admin/users/{id}` - Delete user
-   `POST /admin/users/{id}/toggle-status` - Toggle active status

### Transaction Management

-   `GET /admin/transactions` - List transactions
-   `GET /admin/transactions/{id}` - Show transaction detail
-   `PUT /admin/transactions/{id}/status` - Update transaction status
-   `DELETE /admin/transactions/{id}` - Delete transaction

## Features Detail

### 🎨 UI/UX Design

-   **Responsive Design**: Optimal di desktop & mobile
-   **Modern Interface**: Glassmorphism effects & gradients
-   **Color Scheme**: Green theme sesuai agriculture
-   **Interactive Elements**: Hover effects & smooth transitions
-   **Professional Layout**: Sidebar navigation dengan header

### 📱 Mobile Responsive

-   Sidebar auto-collapse di mobile
-   Touch-friendly buttons & interactions
-   Optimized table display untuk mobile
-   Hamburger menu untuk navigation

### 🔍 Advanced Filtering

-   **User Management**: Filter by role, status, search by name/email
-   **Transactions**: Filter by status, type, date range, search
-   **Real-time Search**: Instant filtering tanpa reload page
-   **Pagination**: Laravel pagination untuk performa optimal

### 📈 Analytics & Charts

-   **Monthly Transactions**: Line chart dengan Chart.js
-   **Status Distribution**: Pie chart untuk transaction status
-   **Statistics Cards**: Real-time counters dengan icons
-   **Interactive Charts**: Hover tooltips & responsive design

### 🛡️ Security Features

-   **CSRF Protection**: Laravel CSRF tokens
-   **Role-based Access**: Admin-only routes
-   **Secure Authentication**: Hashed passwords
-   **Session Security**: Secure session management

## Development Guidelines

### Code Structure

-   **Controllers**: Thin controllers, business logic di services
-   **Models**: Eloquent relationships & accessors
-   **Views**: Blade components untuk reusability
-   **Routes**: Grouped dengan middleware protection

### Database Design

-   **Normalized Structure**: Proper foreign key relationships
-   **Soft Deletes**: Available untuk data integrity
-   **Timestamps**: Auto-tracking created/updated dates
-   **Indexes**: Optimized untuk query performance

### Best Practices

-   **Validation**: Form requests untuk input validation
-   **Error Handling**: Proper exception handling
-   **Logging**: Laravel logging untuk debugging
-   **Testing**: PHPUnit tests untuk reliability

## Deployment Notes

### Production Setup

1. Set `APP_ENV=production` di .env
2. Set `APP_DEBUG=false` untuk security
3. Configure proper database credentials
4. Set up proper web server (Apache/Nginx)
5. Enable HTTPS untuk security
6. Set up backup untuk database

### Performance Optimization

-   Enable Laravel caching
-   Optimize database queries
-   Compress assets
-   Enable GZIP compression
-   Set up CDN untuk static files

## Support & Documentation

### Laravel Resources

-   [Laravel Documentation](https://laravel.com/docs)
-   [Eloquent ORM Guide](https://laravel.com/docs/eloquent)
-   [Blade Templates](https://laravel.com/docs/blade)

### Frontend Libraries

-   [Bootstrap 5 Documentation](https://getbootstrap.com/docs/5.3/)
-   [Chart.js Documentation](https://www.chartjs.org/docs/)
-   [Font Awesome Icons](https://fontawesome.com/icons)

---

**Agrigo Admin Panel** - Comprehensive agricultural management system built with modern web technologies for efficient farm-to-market operations.
