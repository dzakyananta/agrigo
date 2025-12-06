@extends('admin.layouts.app')

@section('title', 'Commodity Details')

@section('content')
<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Commodity Details</h1>
        <div class="d-flex gap-2">
            <a href="{{ route('admin.commodities.edit', $commodity->id) }}" class="btn btn-warning">
                <i class="fas fa-edit me-2"></i>Edit
            </a>
            <a href="{{ route('admin.commodities.index') }}" class="btn btn-secondary">
                <i class="fas fa-arrow-left me-2"></i>Back to List
            </a>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-4">
            <div class="card shadow mb-4">
                <div class="card-header py-3" style="background: linear-gradient(135deg, #2E8B25 0%, #4CAF50 100%);">
                    <h6 class="m-0 font-weight-bold text-white">
                        <i class="fas fa-leaf me-2"></i>Basic Information
                    </h6>
                </div>
                <div class="card-body">
                    <table class="table table-sm">
                        <tr>
                            <th width="40%">Name:</th>
                            <td><strong>{{ $commodity->name }}</strong></td>
                        </tr>
                        <tr>
                            <th>Category:</th>
                            <td><span class="badge bg-info">{{ $commodity->category }}</span></td>
                        </tr>
                        <tr>
                            <th>Unit:</th>
                            <td>{{ $commodity->unit }}</td>
                        </tr>
                        <tr>
                            <th>Status:</th>
                            <td>
                                @if($commodity->is_active)
                                    <span class="badge bg-success">Active</span>
                                @else
                                    <span class="badge bg-secondary">Inactive</span>
                                @endif
                            </td>
                        </tr>
                        <tr>
                            <th>Harvest Season:</th>
                            <td>{{ $commodity->harvest_season ?? '-' }}</td>
                        </tr>
                    </table>

                    @if($commodity->description)
                        <hr>
                        <h6 class="font-weight-bold">Description:</h6>
                        <p class="small">{{ $commodity->description }}</p>
                    @endif
                </div>
            </div>

            <div class="card shadow mb-4">
                <div class="card-header py-3 bg-warning text-dark">
                    <h6 class="m-0 font-weight-bold">
                        <i class="fas fa-dollar-sign me-2"></i>Price Information
                    </h6>
                </div>
                <div class="card-body">
                    <div class="mb-3">
                        <small class="text-muted">Current Price</small>
                        <h4 class="text-success">Rp {{ number_format($commodity->current_price, 0, ',', '.') }}</h4>
                    </div>
                    <div class="row">
                        <div class="col-6">
                            <small class="text-muted">Min Price</small>
                            <p class="mb-0">Rp {{ number_format($commodity->min_price ?? 0, 0, ',', '.') }}</p>
                        </div>
                        <div class="col-6">
                            <small class="text-muted">Max Price</small>
                            <p class="mb-0">Rp {{ number_format($commodity->max_price ?? 0, 0, ',', '.') }}</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-8">
            @if($commodity->storage_requirements || $commodity->quality_standards)
                <div class="card shadow mb-4">
                    <div class="card-header py-3 bg-info text-white">
                        <h6 class="m-0 font-weight-bold">
                            <i class="fas fa-clipboard-check me-2"></i>Standards & Requirements
                        </h6>
                    </div>
                    <div class="card-body">
                        @if($commodity->storage_requirements)
                            <h6 class="font-weight-bold">Storage Requirements:</h6>
                            <p>{{ $commodity->storage_requirements }}</p>
                        @endif

                        @if($commodity->quality_standards)
                            <h6 class="font-weight-bold">Quality Standards:</h6>
                            <p>{{ $commodity->quality_standards }}</p>
                        @endif
                    </div>
                </div>
            @endif

            <div class="card shadow mb-4">
                <div class="card-header py-3 bg-primary text-white">
                    <h6 class="m-0 font-weight-bold">
                        <i class="fas fa-chart-line me-2"></i>Transaction Statistics
                    </h6>
                </div>
                <div class="card-body">
                    @if($commodity->transactions->count() > 0)
                        <div class="row text-center">
                            <div class="col-md-4 mb-3">
                                <div class="card bg-light">
                                    <div class="card-body">
                                        <h5 class="text-primary">{{ $commodity->transactions->count() }}</h5>
                                        <small class="text-muted">Total Transactions</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4 mb-3">
                                <div class="card bg-light">
                                    <div class="card-body">
                                        <h5 class="text-success">{{ $commodity->transactions->where('type', 'income')->count() }}</h5>
                                        <small class="text-muted">Income</small>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-4 mb-3">
                                <div class="card bg-light">
                                    <div class="card-body">
                                        <h5 class="text-danger">{{ $commodity->transactions->where('type', 'expense')->count() }}</h5>
                                        <small class="text-muted">Expense</small>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <h6 class="font-weight-bold mt-4 mb-3">Recent Transactions</h6>
                        <div class="table-responsive">
                            <table class="table table-sm table-hover">
                                <thead>
                                    <tr>
                                        <th>Date</th>
                                        <th>Type</th>
                                        <th>User</th>
                                        <th>Amount</th>
                                        <th>Quantity</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($commodity->transactions->take(10) as $transaction)
                                    <tr>
                                        <td>{{ $transaction->transaction_date ? $transaction->transaction_date->format('d/m/Y') : '-' }}</td>
                                        <td>
                                            @if($transaction->type == 'income')
                                                <span class="badge bg-success">Income</span>
                                            @else
                                                <span class="badge bg-danger">Expense</span>
                                            @endif
                                        </td>
                                        <td>{{ $transaction->user->name ?? 'N/A' }}</td>
                                        <td>Rp {{ number_format($transaction->amount, 0, ',', '.') }}</td>
                                        <td>{{ $transaction->quantity }} {{ $commodity->unit }}</td>
                                    </tr>
                                    @endforeach
                                </tbody>
                            </table>
                        </div>
                    @else
                        <div class="text-center py-4">
                            <i class="fas fa-chart-line fa-3x text-muted mb-3"></i>
                            <p class="text-muted">No transactions yet for this commodity</p>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
