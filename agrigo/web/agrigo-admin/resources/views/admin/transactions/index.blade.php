@extends('admin.layouts.app')

@section('title', 'Transaction Management - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-md-12">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-exchange-alt me-2"></i>Transaction Monitoring
        </h1>
        <p class="text-muted">Monitor all agricultural transactions from users</p>
    </div>
</div>

<!-- Overall Statistics -->
<div class="row mb-4">
    <div class="col-xl-3 col-md-6 mb-3">
        <div class="card border-left-primary shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-primary text-uppercase mb-1">Total Transactions</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">{{ $transactions->total() }}</div>
                    </div>
                    <div class="col-auto">
                        <i class="fas fa-receipt fa-2x text-gray-300"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-xl-3 col-md-6 mb-3">
        <div class="card border-left-success shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-success text-uppercase mb-1">Total Income</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">
                            Rp {{ number_format($userStats->sum('income'), 0, ',', '.') }}
                        </div>
                    </div>
                    <div class="col-auto">
                        <i class="fas fa-arrow-up fa-2x text-gray-300"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-xl-3 col-md-6 mb-3">
        <div class="card border-left-danger shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-danger text-uppercase mb-1">Total Expense</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">
                            Rp {{ number_format($userStats->sum('expense'), 0, ',', '.') }}
                        </div>
                    </div>
                    <div class="col-auto">
                        <i class="fas fa-arrow-down fa-2x text-gray-300"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-xl-3 col-md-6 mb-3">
        <div class="card border-left-info shadow h-100 py-2">
            <div class="card-body">
                <div class="row no-gutters align-items-center">
                    <div class="col mr-2">
                        <div class="text-xs font-weight-bold text-info text-uppercase mb-1">Net Balance</div>
                        <div class="h5 mb-0 font-weight-bold text-gray-800">
                            Rp {{ number_format($userStats->sum('income') - $userStats->sum('expense'), 0, ',', '.') }}
                        </div>
                    </div>
                    <div class="col-auto">
                        <i class="fas fa-wallet fa-2x text-gray-300"></i>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- All User Transactions Summary -->
<div class="card shadow mb-4">
    <div class="card-header py-3 bg-success text-white">
        <h6 class="m-0 font-weight-bold">
            <i class="fas fa-table me-2"></i>All Transactions
        </h6>
    </div>
    <div class="card-body p-0">
        @if($userStats->count() > 0)
            <div class="table-responsive">
                <table class="table table-hover mb-0">
                    <thead class="bg-light">
                        <tr>
                            <th class="bg-success text-white">ID</th>
                            <th class="bg-success text-white">User</th>
                            <th class="bg-success text-white text-end">Income</th>
                            <th class="bg-success text-white text-end">Expense</th>
                            <th class="bg-success text-white text-end">Balance</th>
                            <th class="bg-success text-white">Commodity</th>
                            <th class="bg-success text-white">Source</th>
                            <th class="bg-success text-white">Description</th>
                            <th class="bg-success text-white">Date</th>
                            <th class="bg-success text-white text-center">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @php $no = 1; @endphp
                        @foreach($userStats as $stat)
                        <tr>
                            <td>
                                <span class="badge bg-secondary">#{{ $no++ }}</span>
                            </td>
                            <td>
                                <div>
                                    <strong>{{ $stat['user']->name }}</strong>
                                    <br><small class="text-muted">{{ $stat['user']->email }}</small>
                                </div>
                            </td>
                            <td class="text-end">
                                <strong class="text-success">Rp {{ number_format($stat['income'], 0, ',', '.') }}</strong>
                            </td>
                            <td class="text-end">
                                <strong class="text-danger">Rp {{ number_format($stat['expense'], 0, ',', '.') }}</strong>
                            </td>
                            <td class="text-end">
                                <strong class="{{ $stat['balance'] >= 0 ? 'text-success' : 'text-danger' }}">
                                    Rp {{ number_format($stat['balance'], 0, ',', '.') }}
                                </strong>
                            </td>
                            <td>
                                @php
                                    $userTransactions = $transactions->where('user_id', $stat['user']->id);
                                    $latestTransaction = $userTransactions->first();
                                @endphp
                                @if($latestTransaction && $latestTransaction->commodity)
                                    <div>
                                        <strong>{{ $latestTransaction->commodity->name }}</strong>
                                        <br><small class="text-muted">{{ $latestTransaction->commodity->type }}</small>
                                    </div>
                                @else
                                    <span class="text-muted">-</span>
                                @endif
                            </td>
                            <td>
                                @if($latestTransaction && $latestTransaction->source)
                                    <span class="badge bg-info">{{ $latestTransaction->source }}</span>
                                @else
                                    <span class="text-muted">-</span>
                                @endif
                            </td>
                            <td>
                                @if($latestTransaction)
                                    <small>{{ Str::limit($latestTransaction->description, 30) }}</small>
                                @else
                                    <span class="text-muted">-</span>
                                @endif
                            </td>
                            <td>
                                @if($latestTransaction)
                                    {{ \Carbon\Carbon::parse($latestTransaction->date)->format('d M Y') }}
                                @else
                                    -
                                @endif
                            </td>
                            <td class="text-center">
                                <a href="{{ route('admin.transactions.index') }}?user={{ $stat['user']->id }}" 
                                   class="btn btn-sm btn-outline-primary" title="View Details">
                                    <i class="fas fa-eye"></i> Details
                                </a>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        @else
            <div class="text-center py-5">
                <i class="fas fa-exchange-alt fa-3x text-muted mb-3"></i>
                <p class="text-muted">No transactions found.</p>
                <p class="text-muted small">Transactions will appear here when users create them in the mobile app.</p>
            </div>
        @endif
    </div>
</div>
@endsection
