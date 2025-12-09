@extends('admin.layouts.app')

@section('title', 'Edit Transaction - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-md-12">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-edit me-2"></i>Edit Transaction #{{ $transaction->id }}
        </h1>
        <p class="text-muted">Update transaction information</p>
    </div>
</div>

<div class="row">
    <div class="col-md-8">
        <div class="card shadow">
            <div class="card-header">
                <h6 class="m-0 font-weight-bold text-primary">Transaction Information</h6>
            </div>
            <div class="card-body">
                <form action="{{ route('admin.transactions.update', $transaction->id) }}" method="POST">
                    @csrf
                    @method('PUT')
                    
                    <div class="mb-3">
                        <label for="user_id" class="form-label">User/Farmer <span class="text-danger">*</span></label>
                        <select name="user_id" id="user_id" class="form-control @error('user_id') is-invalid @enderror" required>
                            <option value="">Select User</option>
                            @foreach($users as $user)
                                <option value="{{ $user->id }}" {{ old('user_id', $transaction->user_id) == $user->id ? 'selected' : '' }}>
                                    {{ $user->name }} ({{ $user->email }})
                                </option>
                            @endforeach
                        </select>
                        @error('user_id')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <label for="type" class="form-label">Transaction Type <span class="text-danger">*</span></label>
                        <select name="type" id="type" class="form-control @error('type') is-invalid @enderror" required>
                            <option value="">Select Type</option>
                            <option value="income" {{ old('type', $transaction->type) == 'income' ? 'selected' : '' }}>Income (Pemasukan)</option>
                            <option value="expense" {{ old('type', $transaction->type) == 'expense' ? 'selected' : '' }}>Expense (Pengeluaran)</option>
                        </select>
                        @error('type')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <label for="commodity_id" class="form-label">Commodity (Optional)</label>
                        <select name="commodity_id" id="commodity_id" class="form-control @error('commodity_id') is-invalid @enderror">
                            <option value="">Select Commodity (Optional)</option>
                            @foreach($commodities as $commodity)
                                <option value="{{ $commodity->id }}" {{ old('commodity_id', $transaction->commodity_id) == $commodity->id ? 'selected' : '' }}>
                                    {{ $commodity->name }} - {{ $commodity->type }}
                                </option>
                            @endforeach
                        </select>
                        @error('commodity_id')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <label for="amount" class="form-label">Amount (Rp) <span class="text-danger">*</span></label>
                        <input type="number" name="amount" id="amount" 
                               class="form-control @error('amount') is-invalid @enderror" 
                               value="{{ old('amount', $transaction->amount) }}" 
                               placeholder="e.g., 5000000" 
                               min="0" 
                               step="1000" 
                               required>
                        @error('amount')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <label for="description" class="form-label">Description <span class="text-danger">*</span></label>
                        <textarea name="description" id="description" 
                                  class="form-control @error('description') is-invalid @enderror" 
                                  rows="4" 
                                  placeholder="e.g., Penjualan padi 500 kg" 
                                  required>{{ old('description', $transaction->description) }}</textarea>
                        @error('description')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <label for="date" class="form-label">Transaction Date <span class="text-danger">*</span></label>
                        <input type="date" name="date" id="date" 
                               class="form-control @error('date') is-invalid @enderror" 
                               value="{{ old('date', $transaction->date) }}" 
                               required>
                        @error('date')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="d-flex justify-content-between">
                        <a href="{{ route('admin.transactions.index') }}" class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-2"></i>Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save me-2"></i>Update Transaction
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card shadow mb-3">
            <div class="card-header">
                <h6 class="m-0 font-weight-bold text-primary">Transaction Details</h6>
            </div>
            <div class="card-body">
                <p class="mb-2"><strong>Created:</strong> {{ $transaction->created_at->format('d M Y H:i') }}</p>
                <p class="mb-0"><strong>Last Updated:</strong> {{ $transaction->updated_at->format('d M Y H:i') }}</p>
            </div>
        </div>

        <div class="card shadow">
            <div class="card-header">
                <h6 class="m-0 font-weight-bold text-primary">Help</h6>
            </div>
            <div class="card-body">
                <h6 class="text-primary">Transaction Types:</h6>
                <ul class="small">
                    <li><strong>Income:</strong> Money received (e.g., crop sales)</li>
                    <li><strong>Expense:</strong> Money spent (e.g., fertilizer purchase)</li>
                </ul>
            </div>
        </div>
    </div>
</div>
@endsection
