@extends('admin.layouts.app')

@section('title', 'Add Weather Data')

@section('content')
<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Add Weather Data</h1>
        <a href="{{ route('admin.weather.index') }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left me-2"></i>Back
        </a>
    </div>

    <div class="row">
        <div class="col-lg-8">
            <div class="card shadow mb-4">
                <div class="card-header py-3" style="background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);">
                    <h6 class="m-0 font-weight-bold text-white">
                        <i class="fas fa-cloud-sun me-2"></i>Weather Information
                    </h6>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.weather.store') }}" method="POST">
                        @csrf
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Assign to User</label>
                                <select name="user_id" class="form-select">
                                    <option value="">(Global / All Users)</option>
                                    @foreach($users as $u)
                                        <option value="{{ $u->id }}" {{ old('user_id') == $u->id ? 'selected' : '' }}>{{ $u->name }} ({{ $u->email }})</option>
                                    @endforeach
                                </select>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Location <span class="text-danger">*</span></label>
                                <input type="text" name="location" class="form-control @error('location') is-invalid @enderror" 
                                       value="{{ old('location') }}" placeholder="e.g., Jakarta" required>
                                @error('location')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Date <span class="text-danger">*</span></label>
                                <input type="date" name="date" class="form-control @error('date') is-invalid @enderror" 
                                       value="{{ old('date') }}" required>
                                @error('date')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Temperature (°C) <span class="text-danger">*</span></label>
                                <input type="number" name="temperature" class="form-control @error('temperature') is-invalid @enderror" 
                                       value="{{ old('temperature') }}" step="0.1" required>
                                @error('temperature')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Humidity (%) <span class="text-danger">*</span></label>
                                <input type="number" name="humidity" class="form-control @error('humidity') is-invalid @enderror" 
                                       value="{{ old('humidity') }}" min="0" max="100" required>
                                @error('humidity')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-4 mb-3">
                                <label class="form-label">Rainfall (mm)</label>
                                <input type="number" name="rainfall" class="form-control @error('rainfall') is-invalid @enderror" 
                                       value="{{ old('rainfall') }}" step="0.1" min="0">
                                @error('rainfall')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-4 mb-3">
                                <label class="form-label">Wind Speed (km/h)</label>
                                <input type="number" name="wind_speed" class="form-control @error('wind_speed') is-invalid @enderror" 
                                       value="{{ old('wind_speed') }}" step="0.1" min="0">
                                @error('wind_speed')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-4 mb-3">
                                <label class="form-label">Condition <span class="text-danger">*</span></label>
                                <select name="condition" class="form-select @error('condition') is-invalid @enderror" required>
                                    <option value="">Select</option>
                                    <option value="Cerah" {{ old('condition') == 'Cerah' ? 'selected' : '' }}>Cerah</option>
                                    <option value="Berawan" {{ old('condition') == 'Berawan' ? 'selected' : '' }}>Berawan</option>
                                    <option value="Hujan" {{ old('condition') == 'Hujan' ? 'selected' : '' }}>Hujan</option>
                                    <option value="Mendung" {{ old('condition') == 'Mendung' ? 'selected' : '' }}>Mendung</option>
                                </select>
                                @error('condition')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Description</label>
                            <textarea name="description" class="form-control @error('description') is-invalid @enderror" 
                                      rows="2">{{ old('description') }}</textarea>
                            @error('description')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-2"></i>Save
                            </button>
                            <a href="{{ route('admin.weather.index') }}" class="btn btn-secondary">
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
