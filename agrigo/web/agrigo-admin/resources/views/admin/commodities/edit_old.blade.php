@extends('admin.layouts.app')

@section('title', 'Edit Commodity')

@section('content')
<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Edit Commodity</h1>
        <a href="{{ route('admin.commodities.index') }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left me-2"></i>Back to List
        </a>
    </div>

    <div class="row">
        <div class="col-lg-8">
            <div class="card shadow mb-4">
                <div class="card-header py-3" style="background: linear-gradient(135deg, #2E8B25 0%, #4CAF50 100%);">
                    <h6 class="m-0 font-weight-bold text-white">
                        <i class="fas fa-edit me-2"></i>Edit Commodity Information
                    </h6>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.commodities.update', $commodity->id) }}" method="POST">
                        @csrf
                        @method('PUT')
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Commodity Name <span class="text-danger">*</span></label>
                                <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" 
                                       value="{{ old('name', $commodity->name) }}" required>
                                @error('name')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Category <span class="text-danger">*</span></label>
                                <select name="category" class="form-select @error('category') is-invalid @enderror" required>
                                    <option value="">Select Category</option>
                                    <option value="Padi-padian" {{ old('category', $commodity->category) == 'Padi-padian' ? 'selected' : '' }}>Padi-padian</option>
                                    <option value="Palawija" {{ old('category', $commodity->category) == 'Palawija' ? 'selected' : '' }}>Palawija</option>
                                    <option value="Sayuran" {{ old('category', $commodity->category) == 'Sayuran' ? 'selected' : '' }}>Sayuran</option>
                                    <option value="Buah-buahan" {{ old('category', $commodity->category) == 'Buah-buahan' ? 'selected' : '' }}>Buah-buahan</option>
                                    <option value="Rempah" {{ old('category', $commodity->category) == 'Rempah' ? 'selected' : '' }}>Rempah</option>
                                    <option value="Umbi-umbian" {{ old('category', $commodity->category) == 'Umbi-umbian' ? 'selected' : '' }}>Umbi-umbian</option>
                                </select>
                                @error('category')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <textarea name="description" class="form-control @error('description') is-invalid @enderror" 
                                      rows="3">{{ old('description', $commodity->description) }}</textarea>
                            @error('description')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Unit <span class="text-danger">*</span></label>
                                <select name="unit" class="form-select @error('unit') is-invalid @enderror" required>
                                    <option value="">Select Unit</option>
                                    <option value="Kg" {{ old('unit', $commodity->unit) == 'Kg' ? 'selected' : '' }}>Kg</option>
                                    <option value="Ton" {{ old('unit', $commodity->unit) == 'Ton' ? 'selected' : '' }}>Ton</option>
                                    <option value="Kuintal" {{ old('unit', $commodity->unit) == 'Kuintal' ? 'selected' : '' }}>Kuintal</option>
                                    <option value="Karung" {{ old('unit', $commodity->unit) == 'Karung' ? 'selected' : '' }}>Karung</option>
                                    <option value="Ikat" {{ old('unit', $commodity->unit) == 'Ikat' ? 'selected' : '' }}>Ikat</option>
                                    <option value="Buah" {{ old('unit', $commodity->unit) == 'Buah' ? 'selected' : '' }}>Buah</option>
                                </select>
                                @error('unit')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-4 mb-3">
                                <label class="form-label">Current Price (Rp) <span class="text-danger">*</span></label>
                                <input type="number" name="current_price" class="form-control @error('current_price') is-invalid @enderror" 
                                       value="{{ old('current_price', $commodity->current_price) }}" step="0.01" required>
                                @error('current_price')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-4 mb-3">
                                <label class="form-label">Harvest Season</label>
                                <input type="text" name="harvest_season" class="form-control @error('harvest_season') is-invalid @enderror" 
                                       value="{{ old('harvest_season', $commodity->harvest_season) }}">
                                @error('harvest_season')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Minimum Price (Rp)</label>
                                <input type="number" name="min_price" class="form-control @error('min_price') is-invalid @enderror" 
                                       value="{{ old('min_price', $commodity->min_price) }}" step="0.01">
                                @error('min_price')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Maximum Price (Rp)</label>
                                <input type="number" name="max_price" class="form-control @error('max_price') is-invalid @enderror" 
                                       value="{{ old('max_price', $commodity->max_price) }}" step="0.01">
                                @error('max_price')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Storage Requirements</label>
                            <textarea name="storage_requirements" class="form-control @error('storage_requirements') is-invalid @enderror" 
                                      rows="2">{{ old('storage_requirements', $commodity->storage_requirements) }}</textarea>
                            @error('storage_requirements')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Quality Standards</label>
                            <textarea name="quality_standards" class="form-control @error('quality_standards') is-invalid @enderror" 
                                      rows="2">{{ old('quality_standards', $commodity->quality_standards) }}</textarea>
                            @error('quality_standards')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="is_active" id="is_active" 
                                       {{ old('is_active', $commodity->is_active) ? 'checked' : '' }}>
                                <label class="form-check-label" for="is_active">
                                    Active (Available for use)
                                </label>
                            </div>
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-2"></i>Update Commodity
                            </button>
                            <a href="{{ route('admin.commodities.index') }}" class="btn btn-secondary">
                                Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
