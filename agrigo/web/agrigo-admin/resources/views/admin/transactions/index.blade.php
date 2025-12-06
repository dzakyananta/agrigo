@extends('admin.layouts.app')

@section('title', 'Transaction Management - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-md-6">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-exchange-alt me-2"></i>Transaction Management
        </h1>
        <p class="text-muted">Monitor and manage all agricultural transactions</p>
    </div>
    <div class="col-md-6 text-end">
        <div class="btn-group">
            <button class="btn btn-success">
                <i class="fas fa-file-excel me-2"></i>Export Excel
            </button>
            <button class="btn btn-primary">
                <i class="fas fa-plus me-2"></i>Add Transaction
            </button>
        </div>
    </div>
</div>

<!-- Statistics Cards -->
<div class="row mb-4">
    <div class="col-xl-3 col-md-6 mb-3">
        <div class="stats-card h-100">
            <div class="row no-gutters align-items-center">
                <div class="col mr-2">
                    <div class="stats-label">Total Transactions</div>
                    <div class="stats-number">{{ $transactions->total() ?? 0 }}</div>
                </div>
                <div class="col-auto">
                    <i class="fas fa-receipt stats-icon"></i>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-xl-3 col-md-6 mb-3">
        <div class="stats-card h-100">
            <div class="row no-gutters align-items-center">
                <div class="col mr-2">
                    <div class="stats-label">Pending</div>
                    <div class="stats-number">{{ $transactions->where('status', 'pending')->count() }}</div>
                </div>
                <div class="col-auto">
                    <i class="fas fa-clock stats-icon"></i>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-xl-3 col-md-6 mb-3">
        <div class="stats-card h-100">
            <div class="row no-gutters align-items-center">
                <div class="col mr-2">
                    <div class="stats-label">Completed</div>
                    <div class="stats-number">{{ $transactions->where('status', 'completed')->count() }}</div>
                </div>
                <div class="col-auto">
                    <i class="fas fa-check-circle stats-icon"></i>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-xl-3 col-md-6 mb-3">
        <div class="stats-card h-100">
            <div class="row no-gutters align-items-center">
                <div class="col mr-2">
                    <div class="stats-label">Total Value</div>
                    <div class="stats-number">Rp {{ number_format($transactions->sum('amount'), 0, ',', '.') }}</div>
                </div>
                <div class="col-auto">
                    <i class="fas fa-money-bill-wave stats-icon"></i>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Filter and Search -->
<div class="row mb-4">
    <div class="col-12">
        <div class="card shadow">
            <div class="card-body">
                <form method="GET" class="row g-3">
                    <div class="col-md-3">
                        <label class="form-label">Search Transactions</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" name="search" 
                                   placeholder="Search by user or description..." 
                                   value="{{ request('search') }}">
                        </div>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-select">
                            <option value="">All Status</option>
                            <option value="pending" {{ request('status') === 'pending' ? 'selected' : '' }}>Pending</option>
                            <option value="confirmed" {{ request('status') === 'confirmed' ? 'selected' : '' }}>Confirmed</option>
                            <option value="completed" {{ request('status') === 'completed' ? 'selected' : '' }}>Completed</option>
                            <option value="cancelled" {{ request('status') === 'cancelled' ? 'selected' : '' }}>Cancelled</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Type</label>
                        <select name="type" class="form-select">
                            <option value="">All Types</option>
                            <option value="sale" {{ request('type') === 'sale' ? 'selected' : '' }}>Sale</option>
                            <option value="purchase" {{ request('type') === 'purchase' ? 'selected' : '' }}>Purchase</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Date From</label>
                        <input type="date" class="form-control" name="date_from" 
                               value="{{ request('date_from') }}">
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Date To</label>
                        <input type="date" class="form-control" name="date_to" 
                               value="{{ request('date_to') }}">
                    </div>
                    <div class="col-md-1">
                        <label class="form-label">&nbsp;</label>
                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-filter"></i>
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Transactions Table -->
<div class="row">
    <div class="col-12">
        <div class="table-container">
            <div class="card-header py-3">
                <h6 class="m-0 font-weight-bold text-white">
                    <i class="fas fa-list me-2"></i>All Transactions
                </h6>
            </div>
            <div class="card-body p-0">
                @if(isset($transactions) && $transactions->count() > 0)
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>User</th>
                                    <th>Commodity</th>
                                    <th>Type</th>
                                    <th>Amount</th>
                                    <th>Quantity</th>
                                    <th>Status</th>
                                    <th>Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($transactions as $transaction)
                                <tr>
                                    <td>
                                        <span class="badge bg-secondary">#{{ $transaction->id }}</span>
                                    </td>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="avatar avatar-sm rounded-circle bg-primary text-white me-2 d-flex align-items-center justify-content-center" style="width: 30px; height: 30px; font-size: 0.8rem;">
                                                {{ strtoupper(substr($transaction->user->name ?? 'N/A', 0, 2)) }}
                                            </div>
                                            <div>
                                                <div class="font-weight-bold">{{ $transaction->user->name ?? 'N/A' }}</div>
                                                <small class="text-muted">{{ $transaction->user->email ?? '' }}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        @if($transaction->commodity)
                                            <div class="font-weight-bold">{{ $transaction->commodity->name }}</div>
                                            <small class="text-muted">{{ $transaction->commodity->category }}</small>
                                        @else
                                            <span class="text-muted">No commodity</span>
                                        @endif
                                    </td>
                                    <td>
                                        <span class="badge bg-{{ $transaction->type === 'sale' ? 'success' : 'info' }}">
                                            <i class="fas fa-{{ $transaction->type === 'sale' ? 'arrow-up' : 'arrow-down' }} me-1"></i>
                                            {{ ucfirst($transaction->type ?? 'N/A') }}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="text-success font-weight-bold">
                                            Rp {{ number_format($transaction->amount, 0, ',', '.') }}
                                        </span>
                                        @if($transaction->price_per_unit)
                                            <br><small class="text-muted">@ Rp {{ number_format($transaction->price_per_unit, 0, ',', '.') }}</small>
                                        @endif
                                    </td>
                                    <td>
                                        <span class="font-weight-bold">{{ $transaction->quantity ?? 'N/A' }}</span>
                                        @if($transaction->commodity && $transaction->commodity->unit)
                                            <br><small class="text-muted">{{ $transaction->commodity->unit }}</small>
                                        @endif
                                    </td>
                                    <td>
                                        <span class="badge status-{{ $transaction->status ?? 'pending' }}">
                                            {{ ucfirst($transaction->status ?? 'Pending') }}
                                        </span>
                                    </td>
                                    <td>
                                        <div>{{ $transaction->created_at->format('M d, Y') }}</div>
                                        <small class="text-muted">{{ $transaction->created_at->format('H:i') }}</small>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <a href="{{ route('admin.transactions.show', $transaction->id) }}" 
                                               class="btn btn-sm btn-outline-info" title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            @if($transaction->status === 'pending')
                                                <button class="btn btn-sm btn-outline-success" 
                                                        onclick="updateStatus({{ $transaction->id }}, 'confirmed')" 
                                                        title="Confirm">
                                                    <i class="fas fa-check"></i>
                                                </button>
                                                <button class="btn btn-sm btn-outline-danger" 
                                                        onclick="updateStatus({{ $transaction->id }}, 'cancelled')" 
                                                        title="Cancel">
                                                    <i class="fas fa-times"></i>
                                                </button>
                                            @endif
                                            <button class="btn btn-sm btn-outline-danger" 
                                                    onclick="deleteTransaction({{ $transaction->id }})" 
                                                    title="Delete">
                                                <i class="fas fa-trash"></i>
                                            </button>
                                        </div>
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                    
                    <!-- Pagination -->
                    @if($transactions->hasPages())
                        <div class="d-flex justify-content-center pt-3 pb-3">
                            {{ $transactions->links() }}
                        </div>
                    @endif
                @else
                    <div class="text-center py-5">
                        <i class="fas fa-exchange-alt text-muted" style="font-size: 4rem; opacity: 0.3;"></i>
                        <h5 class="text-muted mt-3">No Transactions Found</h5>
                        <p class="text-muted">No transactions match your current filter criteria.</p>
                        <button class="btn btn-primary">
                            <i class="fas fa-plus me-2"></i>Add First Transaction
                        </button>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>

<!-- Status Update Modal -->
<div class="modal fade" id="statusModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Update Transaction Status</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <form id="statusForm" method="POST">
                @csrf
                @method('PUT')
                <div class="modal-body">
                    <p>Are you sure you want to update this transaction status?</p>
                    <input type="hidden" name="status" id="statusValue">
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">Update Status</button>
                </div>
            </form>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
function updateStatus(transactionId, status) {
    document.getElementById('statusForm').action = `/admin/transactions/${transactionId}/status`;
    document.getElementById('statusValue').value = status;
    new bootstrap.Modal(document.getElementById('statusModal')).show();
}

function deleteTransaction(transactionId) {
    if (confirm('Are you sure you want to delete this transaction? This action cannot be undone.')) {
        fetch(`/admin/transactions/${transactionId}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            }
        })
        .then(response => {
            if (response.ok) {
                location.reload();
            } else {
                alert('Error deleting transaction');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Error deleting transaction');
        });
    }
}
</script>
@endsection