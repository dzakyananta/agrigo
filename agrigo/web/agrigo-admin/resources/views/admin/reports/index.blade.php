@extends('admin.layouts.app')

@section('title', 'Reports & Analytics')

@section('content')
<div class="container-fluid px-4">
    <h1 class="h3 mb-4 text-gray-800">Reports & Analytics</h1>

    <!-- Summary Cards -->
    <div class="row mb-4">
        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-primary shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">
                                Total Transactions</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">{{ $totalTransactions }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-exchange-alt fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-success shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-success text-uppercase mb-1">
                                Total Income</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">Rp {{ number_format($totalIncome, 0, ',', '.') }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-arrow-up fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-danger shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">
                                Total Expense</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">Rp {{ number_format($totalExpense, 0, ',', '.') }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-arrow-down fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-xl-3 col-md-6 mb-4">
            <div class="card border-left-info shadow h-100 py-2">
                <div class="card-body">
                    <div class="row no-gutters align-items-center">
                        <div class="col mr-2">
                            <div class="text-xs font-weight-bold text-info text-uppercase mb-1">
                                Net Profit</div>
                            <div class="h5 mb-0 font-weight-bold text-gray-800">Rp {{ number_format($netProfit, 0, ',', '.') }}</div>
                        </div>
                        <div class="col-auto">
                            <i class="fas fa-chart-line fa-2x text-gray-300"></i>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="row">
        <!-- Top Commodities -->
        <div class="col-lg-6 mb-4">
            <div class="card shadow mb-4">
                <div class="card-header py-3" style="background: linear-gradient(135deg, #2E8B25 0%, #4CAF50 100%);">
                    <h6 class="m-0 font-weight-bold text-white">
                        <i class="fas fa-leaf me-2"></i>Top 5 Commodities
                    </h6>
                </div>
                <div class="card-body">
                    @if($topCommodities->count() > 0)
                        <div class="table-responsive">
                            <table class="table table-sm">
                                <thead>
                                    <tr>
                                        <th>Commodity</th>
                                        <th>Transactions</th>
                                        <th>Total Amount</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($topCommodities as $item)
                                    <tr>
                                        <td>{{ $item->commodity->name ?? 'N/A' }}</td>
                                        <td><span class="badge bg-primary">{{ $item->transaction_count }}</span></td>
                                        <td>Rp {{ number_format($item->total_amount, 0, ',', '.') }}</td>
                                    </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    @else
                        <p class="text-muted text-center">No commodity data available</p>
                    @endif
                </div>
            </div>
        </div>

        <!-- Schedule Statistics -->
        <div class="col-lg-6 mb-4">
            <div class="card shadow mb-4">
                <div class="card-header py-3" style="background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);">
                    <h6 class="m-0 font-weight-bold text-white">
                        <i class="fas fa-calendar-alt me-2"></i>Schedule Statistics
                    </h6>
                </div>
                <div class="card-body">
                    <div class="row text-center">
                        <div class="col-6 mb-3">
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h3 class="text-success">{{ $activeSchedules }}</h3>
                                    <small class="text-muted">Active Schedules</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-6 mb-3">
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h3 class="text-primary">{{ $completedSchedules }}</h3>
                                    <small class="text-muted">Completed</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h3 class="text-info">{{ $totalFarmers }}</h3>
                                    <small class="text-muted">Total Farmers</small>
                                </div>
                            </div>
                        </div>
                        <div class="col-6">
                            <div class="card bg-light">
                                <div class="card-body">
                                    <h3 class="text-warning">{{ $activeUsers }}</h3>
                                    <small class="text-muted">Active Users</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Monthly Transactions Chart -->
    <div class="row">
        <div class="col-12">
            <div class="card shadow mb-4">
                <div class="card-header py-3 bg-gradient-primary text-white">
                    <h6 class="m-0 font-weight-bold">
                        <i class="fas fa-chart-area me-2"></i>Monthly Transaction Trends ({{ date('Y') }})
                    </h6>
                </div>
                <div class="card-body">
                    <canvas id="monthlyChart" height="80"></canvas>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
// Monthly Chart
const monthlyCtx = document.getElementById('monthlyChart').getContext('2d');
const monthlyData = @json($monthlyData);

const labels = monthlyData.map(item => {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[item.month - 1];
});
const incomeData = monthlyData.map(item => item.income);
const expenseData = monthlyData.map(item => item.expense);

new Chart(monthlyCtx, {
    type: 'line',
    data: {
        labels: labels,
        datasets: [{
            label: 'Income',
            data: incomeData,
            borderColor: '#4CAF50',
            backgroundColor: 'rgba(76, 175, 80, 0.1)',
            tension: 0.3
        }, {
            label: 'Expense',
            data: expenseData,
            borderColor: '#f44336',
            backgroundColor: 'rgba(244, 67, 54, 0.1)',
            tension: 0.3
        }]
    },
    options: {
        responsive: true,
        maintainAspectRatio: true,
        plugins: {
            legend: {
                position: 'top',
            }
        },
        scales: {
            y: {
                beginAtZero: true,
                ticks: {
                    callback: function(value) {
                        return 'Rp ' + value.toLocaleString('id-ID');
                    }
                }
            }
        }
    }
});
</script>
@endsection
