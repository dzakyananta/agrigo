@extends('admin.layouts.app')

@section('title', 'Dashboard - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-12">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-tachometer-alt me-2"></i>Dashboard Overview
        </h1>
        <p class="text-muted">Welcome to Agrigo Agricultural Management System</p>
    </div>
</div>

<!-- Statistics Cards -->
<div class="row mb-4">
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="stats-card h-100">
            <div class="row no-gutters align-items-center">
                <div class="col mr-2">
                    <div class="stats-label">Total Users</div>
                    <div class="stats-number">{{ $stats['total_users'] ?? 0 }}</div>
                </div>
                <div class="col-auto">
                    <i class="fas fa-users stats-icon"></i>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="stats-card h-100">
            <div class="row no-gutters align-items-center">
                <div class="col mr-2">
                    <div class="stats-label">Active Farmers</div>
                    <div class="stats-number">{{ $stats['total_farmers'] ?? 0 }}</div>
                </div>
                <div class="col-auto">
                    <i class="fas fa-user-tie stats-icon"></i>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="stats-card h-100">
            <div class="row no-gutters align-items-center">
                <div class="col mr-2">
                    <div class="stats-label">Total Transactions</div>
                    <div class="stats-number">{{ $stats['total_transactions'] ?? 0 }}</div>
                </div>
                <div class="col-auto">
                    <i class="fas fa-exchange-alt stats-icon"></i>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-xl-3 col-md-6 mb-4">
        <div class="stats-card h-100">
            <div class="row no-gutters align-items-center">
                <div class="col mr-2">
                    <div class="stats-label">Monthly Revenue</div>
                    <div class="stats-number">Rp {{ number_format($stats['monthly_revenue'] ?? 0, 0, ',', '.') }}</div>
                </div>
                <div class="col-auto">
                    <i class="fas fa-dollar-sign stats-icon"></i>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Charts and Recent Activity -->
<div class="row">
    <!-- Monthly Transactions Chart -->
    <div class="col-xl-8 col-lg-7 mb-4">
        <div class="card shadow">
            <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                <h6 class="m-0 font-weight-bold text-primary">
                    <i class="fas fa-chart-area me-2"></i>Monthly Transactions Overview
                </h6>
            </div>
            <div class="card-body">
                <div class="chart-area">
                    <canvas id="monthlyChart" width="100%" height="50"></canvas>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Transaction Status Pie Chart -->
    <div class="col-xl-4 col-lg-5 mb-4">
        <div class="card shadow">
            <div class="card-header py-3 d-flex flex-row align-items-center justify-content-between">
                <h6 class="m-0 font-weight-bold text-primary">
                    <i class="fas fa-chart-pie me-2"></i>Transaction Status
                </h6>
            </div>
            <div class="card-body">
                <div class="chart-pie pt-4 pb-2">
                    <canvas id="statusChart" width="100%" height="100"></canvas>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Recent Activity -->
<div class="row">
    <!-- Recent Users -->
    <div class="col-lg-6 mb-4">
        <div class="table-container">
            <div class="card-header py-3">
                <h6 class="m-0 font-weight-bold text-white">
                    <i class="fas fa-user-plus me-2"></i>Recent Users
                </h6>
            </div>
            <div class="card-body">
                @if(isset($stats['recent_users']) && $stats['recent_users']->count() > 0)
                    <div class="table-responsive">
                        <table class="table table-borderless mb-0">
                            <thead>
                                <tr>
                                    <th>Name</th>
                                    <th>Role</th>
                                    <th>Joined</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($stats['recent_users'] as $user)
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="avatar avatar-sm rounded-circle bg-primary text-white me-2">
                                                {{ strtoupper(substr($user->name, 0, 2)) }}
                                            </div>
                                            <div>
                                                <div class="font-weight-bold">{{ $user->name }}</div>
                                                <small class="text-muted">{{ $user->email }}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge bg-{{ $user->role === 'farmer' ? 'success' : 'primary' }}">
                                            {{ ucfirst($user->role) }}
                                        </span>
                                    </td>
                                    <td>
                                        <small class="text-muted">
                                            {{ $user->created_at->diffForHumans() }}
                                        </small>
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @else
                    <div class="text-center py-4">
                        <i class="fas fa-users text-muted" style="font-size: 3rem; opacity: 0.3;"></i>
                        <p class="text-muted mt-2">No recent users</p>
                    </div>
                @endif
            </div>
        </div>
    </div>
    
    <!-- Recent Transactions -->
    <div class="col-lg-6 mb-4">
        <div class="table-container">
            <div class="card-header py-3">
                <h6 class="m-0 font-weight-bold text-white">
                    <i class="fas fa-history me-2"></i>Recent Transactions
                </h6>
            </div>
            <div class="card-body">
                @if(isset($stats['recent_transactions']) && $stats['recent_transactions']->count() > 0)
                    <div class="table-responsive">
                        <table class="table table-borderless mb-0">
                            <thead>
                                <tr>
                                    <th>User</th>
                                    <th>Amount</th>
                                    <th>Status</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($stats['recent_transactions'] as $transaction)
                                <tr>
                                    <td>
                                        <div class="font-weight-bold">{{ $transaction->user->name ?? 'N/A' }}</div>
                                    </td>
                                    <td>
                                        <span class="text-success font-weight-bold">
                                            Rp {{ number_format($transaction->amount, 0, ',', '.') }}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge status-{{ $transaction->status ?? 'pending' }}">
                                            {{ ucfirst($transaction->status ?? 'Pending') }}
                                        </span>
                                    </td>
                                    <td>
                                        <small class="text-muted">
                                            {{ $transaction->created_at->format('M d, Y') }}
                                        </small>
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                @else
                    <div class="text-center py-4">
                        <i class="fas fa-exchange-alt text-muted" style="font-size: 3rem; opacity: 0.3;"></i>
                        <p class="text-muted mt-2">No recent transactions</p>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>

<!-- Quick Actions -->
<div class="row">
    <div class="col-12">
        <div class="card shadow">
            <div class="card-header py-3">
                <h6 class="m-0 font-weight-bold text-primary">
                    <i class="fas fa-bolt me-2"></i>Quick Actions
                </h6>
            </div>
            <div class="card-body">
                <div class="row">
                    <div class="col-md-3 mb-3">
                        <a href="{{ route('admin.users.index') }}" class="btn btn-primary w-100 p-3">
                            <i class="fas fa-users d-block mb-2" style="font-size: 2rem;"></i>
                            Manage Users
                        </a>
                    </div>
                    <div class="col-md-3 mb-3">
                        <a href="{{ route('admin.transactions.index') }}" class="btn btn-success w-100 p-3">
                            <i class="fas fa-exchange-alt d-block mb-2" style="font-size: 2rem;"></i>
                            View Transactions
                        </a>
                    </div>
                    <div class="col-md-3 mb-3">
                        <button class="btn btn-info w-100 p-3">
                            <i class="fas fa-leaf d-block mb-2" style="font-size: 2rem;"></i>
                            Add Commodity
                        </button>
                    </div>
                    <div class="col-md-3 mb-3">
                        <button class="btn btn-warning w-100 p-3">
                            <i class="fas fa-chart-bar d-block mb-2" style="font-size: 2rem;"></i>
                            Generate Report
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
// Monthly Transactions Chart
const ctx = document.getElementById('monthlyChart').getContext('2d');
const monthlyChart = new Chart(ctx, {
    type: 'line',
    data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
        datasets: [{
            label: 'Transactions',
            data: [
                @if(isset($monthlyData))
                    @php
                        $chartData = array_fill(0, 12, 0);
                        foreach($monthlyData as $data) {
                            $chartData[$data->month - 1] = $data->count;
                        }
                        echo implode(',', $chartData);
                    @endphp
                @else
                    0,0,0,0,0,0,0,0,0,0,0,0
                @endif
            ],
            borderColor: '#4ade80',
            backgroundColor: 'rgba(74, 222, 128, 0.1)',
            borderWidth: 3,
            fill: true,
            tension: 0.4
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                display: false
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                grid: {
                    color: '#f1f5f9'
                }
            },
            x: {
                grid: {
                    display: false
                }
            }
        }
    }
});

// Transaction Status Pie Chart
const statusCtx = document.getElementById('statusChart').getContext('2d');
const statusChart = new Chart(statusCtx, {
    type: 'doughnut',
    data: {
        labels: ['Completed', 'Pending', 'Cancelled'],
        datasets: [{
            data: [65, 25, 10],
            backgroundColor: ['#10b981', '#f59e0b', '#dc2626'],
            borderWidth: 0
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
            legend: {
                position: 'bottom'
            }
        }
    }
});
</script>
@endsection