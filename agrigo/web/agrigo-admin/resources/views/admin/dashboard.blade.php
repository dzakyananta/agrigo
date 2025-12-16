@extends('admin.layouts.app')

@section('title', 'Dashboard - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-12">
        <h1 class="h3 mb-0" style="color: #1f2937; font-weight: 600;">
            Dashboard
        </h1>
    </div>
</div>

<!-- Main Dashboard Card -->
<div class="card shadow-sm" style="border: 2px solid #3b82f6; border-radius: 12px;">
    <div class="card-body p-4">
        <!-- Statistics Cards -->
        <div class="row mb-4">
            <div class="col-md-3 mb-3">
                <div class="card shadow-sm h-100" style="border: 1px solid #e5e7eb; border-radius: 10px;">
                    <div class="card-body text-center p-3">
                        <div class="text-muted small mb-2">Pengguna Aktif</div>
                        <div class="h3 mb-1 font-weight-bold" style="color: #1f2937;">{{ $stats['total_users'] ?? 1200 }}</div>
                        <div class="text-success small">+0%</div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <div class="card shadow-sm h-100" style="border: 1px solid #e5e7eb; border-radius: 10px;">
                    <div class="card-body text-center p-3">
                        <div class="text-muted small mb-2">Total Komoditas</div>
                        <div class="h3 mb-1 font-weight-bold" style="color: #1f2937;">{{ $stats['total_commodities'] ?? 1200 }}</div>
                        <div class="text-success small">+0%</div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <div class="card shadow-sm h-100" style="border: 1px solid #e5e7eb; border-radius: 10px;">
                    <div class="card-body text-center p-3">
                        <div class="text-muted small mb-2">Total Panen (Kg)</div>
                        <div class="h3 mb-1 font-weight-bold" style="color: #1f2937;">{{ $stats['total_harvest'] ?? 1200 }}</div>
                        <div class="text-success small">+0%</div>
                    </div>
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <div class="card shadow-sm h-100" style="border: 1px solid #e5e7eb; border-radius: 10px;">
                    <div class="card-body text-center p-3">
                        <div class="text-muted small mb-2">Pemasukan</div>
                        <div class="h3 mb-1 font-weight-bold" style="color: #1f2937;">{{ $stats['total_income'] ?? 1200 }}</div>
                        <div class="text-success small">+0%</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Divider -->
        <hr style="border-top: 2px dashed #e5e7eb;">

        <!-- Chart Section -->
        <div class="mb-4">
            <h5 class="mb-3" style="color: #1f2937; font-weight: 600;">
                Pertumbuhan Pengguna Bulanan
            </h5>
            <div class="mb-2">
                <strong style="font-size: 1.5rem;">{{ $stats['total_users'] ?? 1200 }}</strong>
                <span class="text-muted ms-2">| 1 Bulan Terakhir <span class="text-success">+20%</span></span>
            </div>
            <div class="chart-area" style="height: 250px;">
                <canvas id="userGrowthChart"></canvas>
            </div>
        </div>

        <!-- Divider -->
        <hr style="border-top: 2px dashed #e5e7eb;">

        <!-- Recent Activity -->
        <div>
            <h5 class="mb-3" style="color: #1f2937; font-weight: 600;">
                Aktivitas Terbaru
            </h5>
            <div class="activity-list">
                <div class="d-flex align-items-start mb-3">
                    <div class="rounded-circle bg-success d-flex align-items-center justify-content-center me-3" 
                         style="width: 40px; height: 40px; flex-shrink: 0;">
                        <i class="fas fa-user-plus text-white"></i>
                    </div>
                    <div class="flex-grow-1">
                        <div class="font-weight-bold">Trio baru saja mendaftar</div>
                        <small class="text-muted">2 minggu yang lalu</small>
                    </div>
                </div>
                
                <div class="d-flex align-items-start mb-3">
                    <div class="rounded-circle bg-info d-flex align-items-center justify-content-center me-3" 
                         style="width: 40px; height: 40px; flex-shrink: 0;">
                        <i class="fas fa-file-alt text-white"></i>
                    </div>
                    <div class="flex-grow-1">
                        <div class="font-weight-bold">Laporan baru diterima dari petani</div>
                        <small class="text-muted">3 minggu yang lalu</small>
                    </div>
                </div>
                
                <div class="d-flex align-items-start mb-3">
                    <div class="rounded-circle bg-warning d-flex align-items-center justify-content-center me-3" 
                         style="width: 40px; height: 40px; flex-shrink: 0;">
                        <i class="fas fa-leaf text-white"></i>
                    </div>
                    <div class="flex-grow-1">
                        <div class="font-weight-bold">Komoditas "padi" ditambahkan</div>
                        <small class="text-muted">3 jam yang lalu</small>
                    </div>
                </div>
            </div>
            
            <div class="text-center mt-3">
                <a href="#" class="text-primary text-decoration-none">
                    Lihat Semua Aktivitas <i class="fas fa-arrow-down ms-1"></i>
                </a>
            </div>
        </div>
    </div>
</div>


@endsection

@section('scripts')
<script>
// User Growth Chart
const ctx = document.getElementById('userGrowthChart').getContext('2d');
const userGrowthChart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agus', 'Sep', 'Okt', 'Nov', 'Des'],
        datasets: [{
            label: 'Pengguna',
            data: [850, 920, 880, 950, 1050, 1100, 1080, 1150, 1200, 1180, 1250, 1200],
            borderColor: '#22c55e',
            backgroundColor: 'rgba(34, 197, 94, 0.1)',
            borderWidth: 2,
            fill: true,
            tension: 0.4,
            pointRadius: 3,
            pointBackgroundColor: '#22c55e',
            pointBorderColor: '#fff',
            pointBorderWidth: 2
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                display: false
            },
            tooltip: {
                backgroundColor: 'rgba(0, 0, 0, 0.8)',
                padding: 12,
                titleColor: '#fff',
                bodyColor: '#fff',
                cornerRadius: 8
            }
        },
        scales: {
            y: {
                beginAtZero: false,
                min: 800,
                max: 1300,
                ticks: {
                    stepSize: 100,
                    color: '#6b7280'
                },
                grid: {
                    color: '#f3f4f6',
                    drawBorder: false
                }
            },
            x: {
                ticks: {
                    color: '#6b7280'
                },
                grid: {
                    display: false,
                    drawBorder: false
                }
            }
        }
    }
});
</script>
@endsection