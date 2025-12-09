@extends('admin.layouts.app')

@section('title', 'Add New Transaction - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-md-12">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-plus me-2"></i>Add New Transaction
        </h1>
        <p class="text-muted">Create a new income or expense transaction</p>
    </div>
</div>

<div class="row">
    <div class="col-md-8">
        <div class="card shadow">
            <div class="card-header">
                <h6 class="m-0 font-weight-bold text-primary">Transaction Information</h6>
            </div>
            <div class="card-body">
                <form action="{{ route('admin.transactions.store') }}" method="POST">
                    @csrf
                    
                    <div class="mb-3">
                        <label for="user_id" class="form-label">User/Farmer <span class="text-danger">*</span></label>
                        <select name="user_id" id="user_id" class="form-control @error('user_id') is-invalid @enderror" required>
                            <option value="">Select User</option>
                            @foreach($users as $user)
                                <option value="{{ $user->id }}" {{ old('user_id') == $user->id ? 'selected' : '' }}>
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
                            <option value="income" {{ old('type') == 'income' ? 'selected' : '' }}>Income (Pemasukan)</option>
                            <option value="expense" {{ old('type') == 'expense' ? 'selected' : '' }}>Expense (Pengeluaran)</option>
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
                                <option value="{{ $commodity->id }}" {{ old('commodity_id') == $commodity->id ? 'selected' : '' }}>
                                    {{ $commodity->name }} - {{ $commodity->type }}
                                </option>
                            @endforeach
                        </select>
                        @error('commodity_id')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <label for="source" class="form-label">Source (Optional)</label>
                        <select name="source" id="source" class="form-control @error('source') is-invalid @enderror">
                            <option value="">Select Source (Optional)</option>
                            <optgroup label="Sumber Pemasukan">
                                <option value="Penjualan Hasil Panen" {{ old('source') == 'Penjualan Hasil Panen' ? 'selected' : '' }}>Penjualan Hasil Panen</option>
                                <option value="Bantuan Pemerintah" {{ old('source') == 'Bantuan Pemerintah' ? 'selected' : '' }}>Bantuan Pemerintah</option>
                                <option value="Pinjaman Bank" {{ old('source') == 'Pinjaman Bank' ? 'selected' : '' }}>Pinjaman Bank</option>
                                <option value="Pinjaman Koperasi" {{ old('source') == 'Pinjaman Koperasi' ? 'selected' : '' }}>Pinjaman Koperasi</option>
                                <option value="Investor/Partner" {{ old('source') == 'Investor/Partner' ? 'selected' : '' }}>Investor/Partner</option>
                                <option value="Modal Pribadi" {{ old('source') == 'Modal Pribadi' ? 'selected' : '' }}>Modal Pribadi</option>
                            </optgroup>
                            <optgroup label="Sumber Pengeluaran">
                                <option value="Pembelian Bibit" {{ old('source') == 'Pembelian Bibit' ? 'selected' : '' }}>Pembelian Bibit</option>
                                <option value="Pembelian Pupuk" {{ old('source') == 'Pembelian Pupuk' ? 'selected' : '' }}>Pembelian Pupuk</option>
                                <option value="Pembelian Pestisida" {{ old('source') == 'Pembelian Pestisida' ? 'selected' : '' }}>Pembelian Pestisida</option>
                                <option value="Sewa Alat" {{ old('source') == 'Sewa Alat' ? 'selected' : '' }}>Sewa Alat</option>
                                <option value="Upah Pekerja" {{ old('source') == 'Upah Pekerja' ? 'selected' : '' }}>Upah Pekerja</option>
                                <option value="Biaya Transportasi" {{ old('source') == 'Biaya Transportasi' ? 'selected' : '' }}>Biaya Transportasi</option>
                            </optgroup>
                        </select>
                        @error('source')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                        <small class="form-text text-muted">
                            Pilih sumber pemasukan (misal: Penjualan Hasil Panen, Pinjaman Bank, dll) atau sumber pengeluaran
                        </small>
                    </div>

                    <div class="mb-3">
                        <label for="amount" class="form-label">Amount (Rp) <span class="text-danger">*</span></label>
                        <input type="number" name="amount" id="amount" 
                               class="form-control @error('amount') is-invalid @enderror" 
                               value="{{ old('amount') }}" 
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
                                  required>{{ old('description') }}</textarea>
                        @error('description')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <label for="date" class="form-label">Transaction Date <span class="text-danger">*</span></label>
                        <input type="date" name="date" id="date" 
                               class="form-control @error('date') is-invalid @enderror" 
                               value="{{ old('date', date('Y-m-d')) }}" 
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
                            <i class="fas fa-save me-2"></i>Save Transaction
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="col-md-4">
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

                <h6 class="text-primary mt-3">Examples:</h6>
                <div class="small">
                    <strong>Income:</strong>
                    <ul>
                        <li>Penjualan padi 500 kg</li>
                        <li>Penjualan jagung ke pasar</li>
                    </ul>
                    
                    <strong>Expense:</strong>
                    <ul>
                        <li>Pembelian pupuk urea 50 kg</li>
                        <li>Biaya tenaga kerja panen</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
