@extends('admin.layouts.app')

@section('title', 'Edit Commodity - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-md-12">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-edit me-2"></i>Edit Commodity: {{ $commodity->name }}
        </h1>
        <p class="text-muted">Update commodity information</p>
    </div>
</div>

<div class="row">
    <div class="col-md-8">
        <div class="card shadow">
            <div class="card-header">
                <h6 class="m-0 font-weight-bold text-primary">Commodity Information</h6>
            </div>
            <div class="card-body">
                <form action="{{ route('admin.commodities.update', $commodity->id) }}" method="POST">
                    @csrf
                    @method('PUT')
                    
                    <div class="mb-3">
                        <label for="name" class="form-label">Commodity Name <span class="text-danger">*</span></label>
                        <input type="text" name="name" id="name" 
                               class="form-control @error('name') is-invalid @enderror" 
                               value="{{ old('name', $commodity->name) }}" 
                               placeholder="e.g., Padi, Jagung, Cabai, Tomat" 
                               required>
                        @error('name')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <label for="type" class="form-label">Type/Category <span class="text-danger">*</span></label>
                        <select name="type" id="type" class="form-control @error('type') is-invalid @enderror" required>
                            <option value="">Select Type</option>
                            <option value="Padi-padian" {{ old('type', $commodity->type) == 'Padi-padian' ? 'selected' : '' }}>Padi-padian</option>
                            <option value="Palawija" {{ old('type', $commodity->type) == 'Palawija' ? 'selected' : '' }}>Palawija</option>
                            <option value="Sayuran" {{ old('type', $commodity->type) == 'Sayuran' ? 'selected' : '' }}>Sayuran</option>
                            <option value="Buah-buahan" {{ old('type', $commodity->type) == 'Buah-buahan' ? 'selected' : '' }}>Buah-buahan</option>
                            <option value="Umbi-umbian" {{ old('type', $commodity->type) == 'Umbi-umbian' ? 'selected' : '' }}>Umbi-umbian</option>
                            <option value="Rempah-rempah" {{ old('type', $commodity->type) == 'Rempah-rempah' ? 'selected' : '' }}>Rempah-rempah</option>
                        </select>
                        @error('type')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>

                    <div class="mb-3">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" name="is_active" id="is_active" 
                                   {{ old('is_active', $commodity->is_active) ? 'checked' : '' }}>
                            <label class="form-check-label" for="is_active">
                                <strong>Active</strong> (Available for use in schedules and transactions)
                            </label>
                        </div>
                    </div>

                    <div class="d-flex justify-content-between">
                        <a href="{{ route('admin.commodities.index') }}" class="btn btn-secondary">
                            <i class="fas fa-arrow-left me-2"></i>Cancel
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save me-2"></i>Update Commodity
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="col-md-4">
        <div class="card shadow mb-3">
            <div class="card-header">
                <h6 class="m-0 font-weight-bold text-primary">Statistics</h6>
            </div>
            <div class="card-body">
                <p class="mb-2">
                    <strong>Schedules:</strong> 
                    <span class="badge bg-primary">{{ $commodity->schedules->count() ?? 0 }}</span>
                </p>
                <p class="mb-2">
                    <strong>Transactions:</strong> 
                    <span class="badge bg-success">{{ $commodity->transactions->count() ?? 0 }}</span>
                </p>
                <hr>
                <p class="mb-2"><strong>Created:</strong> {{ $commodity->created_at->format('d M Y') }}</p>
                <p class="mb-0"><strong>Last Updated:</strong> {{ $commodity->updated_at->format('d M Y') }}</p>
            </div>
        </div>

        <div class="card shadow">
            <div class="card-header">
                <h6 class="m-0 font-weight-bold text-primary">Help</h6>
            </div>
            <div class="card-body">
                <div class="alert alert-info">
                    <i class="fas fa-info-circle me-2"></i>
                    <strong>Note:</strong> Perubahan data akan otomatis tersinkronisasi ke aplikasi mobile Agrigo.
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
