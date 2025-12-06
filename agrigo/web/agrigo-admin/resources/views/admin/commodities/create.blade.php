@extends('admin.layouts.app')

@section('title', 'Add New Commodity')

@section('content')
<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Add New Commodity</h1>
        <a href="{{ route('admin.commodities.index') }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left me-2"></i>Back to List
        </a>
    </div>

    <div class="row">
        <div class="col-lg-8">
            <div class="card shadow mb-4">
                <div class="card-header py-3" style="background: linear-gradient(135deg, #2E8B25 0%, #4CAF50 100%);">
                    <h6 class="m-0 font-weight-bold text-white">
                        <i class="fas fa-leaf me-2"></i>Commodity Information
                    </h6>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.commodities.store') }}" method="POST">
                        @csrf
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Commodity Name <span class="text-danger">*</span></label>
                                <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" 
                                       value="{{ old('name') }}" placeholder="e.g., Padi, Jagung, Cabai" required>
                                @error('name')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Category <span class="text-danger">*</span></label>
                                <select name="category" class="form-select @error('category') is-invalid @enderror" required>
                                    <option value="">Select Category</option>
                                    <option value="Padi-padian" {{ old('category') == 'Padi-padian' ? 'selected' : '' }}>Padi-padian</option>
                                    <option value="Palawija" {{ old('category') == 'Palawija' ? 'selected' : '' }}>Palawija</option>
                                    <option value="Sayuran" {{ old('category') == 'Sayuran' ? 'selected' : '' }}>Sayuran</option>
                                    <option value="Buah-buahan" {{ old('category') == 'Buah-buahan' ? 'selected' : '' }}>Buah-buahan</option>
                                    <option value="Rempah" {{ old('category') == 'Rempah' ? 'selected' : '' }}>Rempah</option>
                                    <option value="Umbi-umbian" {{ old('category') == 'Umbi-umbian' ? 'selected' : '' }}>Umbi-umbian</option>
                                </select>
                                @error('category')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <textarea name="description" class="form-control @error('description') is-invalid @enderror" 
                                      rows="3" placeholder="Describe the commodity...">{{ old('description') }}</textarea>
                            @error('description')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Unit <span class="text-danger">*</span></label>
                                <select name="unit" class="form-select @error('unit') is-invalid @enderror" required>
                                    <option value="">Select Unit</option>
                                    <option value="Kg" {{ old('unit') == 'Kg' ? 'selected' : '' }}>Kg</option>
                                    <option value="Ton" {{ old('unit') == 'Ton' ? 'selected' : '' }}>Ton</option>
                                    <option value="Kuintal" {{ old('unit') == 'Kuintal' ? 'selected' : '' }}>Kuintal</option>
                                    <option value="Karung" {{ old('unit') == 'Karung' ? 'selected' : '' }}>Karung</option>
                                    <option value="Ikat" {{ old('unit') == 'Ikat' ? 'selected' : '' }}>Ikat</option>
                                    <option value="Buah" {{ old('unit') == 'Buah' ? 'selected' : '' }}>Buah</option>
                                </select>
                                @error('unit')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-4 mb-3">
                                <label class="form-label">Current Price (Rp) <span class="text-danger">*</span></label>
                                <input type="number" name="current_price" class="form-control @error('current_price') is-invalid @enderror" 
                                       value="{{ old('current_price') }}" placeholder="e.g., 15000" step="0.01" required>
                                @error('current_price')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-4 mb-3">
                                <label class="form-label">Harvest Season</label>
                                <input type="text" name="harvest_season" class="form-control @error('harvest_season') is-invalid @enderror" 
                                       value="{{ old('harvest_season') }}" placeholder="e.g., Maret - Juni">
                                @error('harvest_season')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Minimum Price (Rp)</label>
                                <input type="number" name="min_price" class="form-control @error('min_price') is-invalid @enderror" 
                                       value="{{ old('min_price') }}" placeholder="e.g., 10000" step="0.01">
                                @error('min_price')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Maximum Price (Rp)</label>
                                <input type="number" name="max_price" class="form-control @error('max_price') is-invalid @enderror" 
                                       value="{{ old('max_price') }}" placeholder="e.g., 20000" step="0.01">
                                @error('max_price')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Storage Requirements</label>
                            <textarea name="storage_requirements" class="form-control @error('storage_requirements') is-invalid @enderror" 
                                      rows="2" placeholder="e.g., Store in cool, dry place">{{ old('storage_requirements') }}</textarea>
                            @error('storage_requirements')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Quality Standards</label>
                            <textarea name="quality_standards" class="form-control @error('quality_standards') is-invalid @enderror" 
                                      rows="2" placeholder="e.g., Moisture content < 14%">{{ old('quality_standards') }}</textarea>
                            @error('quality_standards')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" name="is_active" id="is_active" 
                                       {{ old('is_active', true) ? 'checked' : '' }}>
                                <label class="form-check-label" for="is_active">
                                    Active (Available for use)
                                </label>
                            </div>
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-2"></i>Save Commodity
                            </button>
                            <a href="{{ route('admin.commodities.index') }}" class="btn btn-secondary">
                                Cancel
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <div class="col-lg-4">
            <div class="card shadow mb-4">
                <div class="card-header py-3 bg-info text-white">
                    <h6 class="m-0 font-weight-bold">
                        <i class="fas fa-info-circle me-2"></i>Help
                    </h6>
                </div>
                <div class="card-body">
                    <h6 class="font-weight-bold">Tips:</h6>
                    <ul class="small">
                        <li>Enter accurate current market price</li>
                        <li>Set realistic min/max price ranges</li>
                        <li>Specify harvest season for planning</li>
                        <li>Add quality standards for reference</li>
                        <li>Mark as active to make it available in the mobile app</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
