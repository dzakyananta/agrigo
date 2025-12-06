@extends('admin.layouts.app')

@section('title', 'Add New Schedule')

@section('content')
<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Add New Planting Schedule</h1>
        <a href="{{ route('admin.schedules.index') }}" class="btn btn-secondary">
            <i class="fas fa-arrow-left me-2"></i>Back to List
        </a>
    </div>

    <div class="row">
        <div class="col-lg-8">
            <div class="card shadow mb-4">
                <div class="card-header py-3" style="background: linear-gradient(135deg, #2E8B25 0%, #4CAF50 100%);">
                    <h6 class="m-0 font-weight-bold text-white">
                        <i class="fas fa-calendar-alt me-2"></i>Schedule Information
                    </h6>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.schedules.store') }}" method="POST">
                        @csrf
                        
                        <div class="mb-3">
                            <label class="form-label">Farmer <span class="text-danger">*</span></label>
                            <select name="user_id" class="form-select @error('user_id') is-invalid @enderror" required>
                                <option value="">Select Farmer</option>
                                @foreach($users as $user)
                                    <option value="{{ $user->id }}" {{ old('user_id') == $user->id ? 'selected' : '' }}>
                                        {{ $user->name }} - {{ $user->email }}
                                    </option>
                                @endforeach
                            </select>
                            @error('user_id')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Commodity Name <span class="text-danger">*</span></label>
                                <input type="text" name="komoditas" class="form-control @error('komoditas') is-invalid @enderror" 
                                       value="{{ old('komoditas') }}" placeholder="e.g., Padi, Jagung" required>
                                @error('komoditas')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">Commodity Reference (Optional)</label>
                                <select name="commodity_id" class="form-select @error('commodity_id') is-invalid @enderror">
                                    <option value="">Select Commodity</option>
                                    @foreach($commodities as $commodity)
                                        <option value="{{ $commodity->id }}" {{ old('commodity_id') == $commodity->id ? 'selected' : '' }}>
                                            {{ $commodity->name }} ({{ $commodity->category }})
                                        </option>
                                    @endforeach
                                </select>
                                @error('commodity_id')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label class="form-label">Start Date <span class="text-danger">*</span></label>
                                <input type="date" name="start_date" class="form-control @error('start_date') is-invalid @enderror" 
                                       value="{{ old('start_date') }}" required>
                                @error('start_date')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>

                            <div class="col-md-6 mb-3">
                                <label class="form-label">End Date <span class="text-danger">*</span></label>
                                <input type="date" name="end_date" class="form-control @error('end_date') is-invalid @enderror" 
                                       value="{{ old('end_date') }}" required>
                                @error('end_date')
                                    <div class="invalid-feedback">{{ $message }}</div>
                                @enderror
                            </div>
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Status <span class="text-danger">*</span></label>
                            <select name="status" class="form-select @error('status') is-invalid @enderror" required>
                                <option value="active" {{ old('status') == 'active' ? 'selected' : '' }}>Active</option>
                                <option value="completed" {{ old('status') == 'completed' ? 'selected' : '' }}>Completed</option>
                                <option value="cancelled" {{ old('status') == 'cancelled' ? 'selected' : '' }}>Cancelled</option>
                            </select>
                            @error('status')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label class="form-label">Notes</label>
                            <textarea name="notes" class="form-control @error('notes') is-invalid @enderror" 
                                      rows="3" placeholder="Additional notes...">{{ old('notes') }}</textarea>
                            @error('notes')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="d-flex gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save me-2"></i>Save Schedule
                            </button>
                            <a href="{{ route('admin.schedules.index') }}" class="btn btn-secondary">
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
                        <li>Select the farmer who owns this planting schedule</li>
                        <li>Enter the commodity name as it will appear to the farmer</li>
                        <li>Optionally link to a commodity for price tracking</li>
                        <li>Set realistic start and end dates</li>
                        <li>Use notes for special instructions or reminders</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
