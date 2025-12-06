@extends('admin.layouts.app')

@section('title', 'Edit User - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-md-6">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-user-edit me-2"></i>Edit User
        </h1>
        <p class="text-muted">Update user information and profile</p>
    </div>
    <div class="col-md-6 text-end">
        <a href="{{ route('admin.users.index') }}" class="btn btn-outline-secondary">
            <i class="fas fa-arrow-left me-2"></i>Back to Users
        </a>
    </div>
</div>

<div class="row">
    <div class="col-xl-8 col-lg-10 mx-auto">
        <div class="card shadow">
            <div class="card-header py-3">
                <h6 class="m-0 font-weight-bold text-primary">
                    <i class="fas fa-user me-2"></i>User Information
                </h6>
            </div>
            <div class="card-body">
                @if ($errors->any())
                    <div class="alert alert-danger">
                        <ul class="mb-0">
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif

                <form action="{{ route('admin.users.update', $user->id) }}" method="POST">
                    @csrf
                    @method('PUT')
                    
                    <!-- Basic Information -->
                    <div class="row mb-4">
                        <div class="col-12">
                            <h6 class="text-primary border-bottom pb-2 mb-3">
                                <i class="fas fa-info-circle me-2"></i>Basic Information
                            </h6>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="name" class="form-label">Full Name *</label>
                            <input type="text" class="form-control" id="name" name="name" 
                                   value="{{ old('name', $user->name) }}" required>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="email" class="form-label">Email Address *</label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   value="{{ old('email', $user->email) }}" required>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="role" class="form-label">User Role *</label>
                            <select class="form-select" id="role" name="role" required>
                                <option value="">Select Role</option>
                                <option value="farmer" {{ old('role', $user->role) === 'farmer' ? 'selected' : '' }}>
                                    Farmer
                                </option>
                                <option value="buyer" {{ old('role', $user->role) === 'buyer' ? 'selected' : '' }}>
                                    Buyer
                                </option>
                                <option value="admin" {{ old('role', $user->role) === 'admin' ? 'selected' : '' }}>
                                    Admin
                                </option>
                            </select>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="status" class="form-label">Account Status *</label>
                            <select class="form-select" id="status" name="status" required>
                                <option value="active" {{ old('status', $user->status ?? 'active') === 'active' ? 'selected' : '' }}>
                                    Active
                                </option>
                                <option value="inactive" {{ old('status', $user->status) === 'inactive' ? 'selected' : '' }}>
                                    Inactive
                                </option>
                                <option value="suspended" {{ old('status', $user->status) === 'suspended' ? 'selected' : '' }}>
                                    Suspended
                                </option>
                            </select>
                        </div>
                    </div>

                    <!-- Profile Information -->
                    <div class="row mb-4">
                        <div class="col-12">
                            <h6 class="text-primary border-bottom pb-2 mb-3">
                                <i class="fas fa-address-card me-2"></i>Profile Information
                            </h6>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="phone" class="form-label">Phone Number</label>
                            <input type="text" class="form-control" id="phone" name="phone" 
                                   value="{{ old('phone', $user->profile->phone ?? '') }}">
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="address" class="form-label">Address</label>
                            <input type="text" class="form-control" id="address" name="address" 
                                   value="{{ old('address', $user->profile->address ?? '') }}">
                        </div>
                    </div>

                    <!-- Farmer Specific Information -->
                    <div class="row mb-4" id="farmerFields" style="display: {{ old('role', $user->role) === 'farmer' ? 'block' : 'none' }}">
                        <div class="col-12">
                            <h6 class="text-success border-bottom pb-2 mb-3">
                                <i class="fas fa-leaf me-2"></i>Farmer Information
                            </h6>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="farm_size" class="form-label">Farm Size (hectares)</label>
                            <input type="number" step="0.1" class="form-control" id="farm_size" name="farm_size" 
                                   value="{{ old('farm_size', $user->profile->farm_size ?? '') }}">
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label for="farm_location" class="form-label">Farm Location</label>
                            <input type="text" class="form-control" id="farm_location" name="farm_location" 
                                   value="{{ old('farm_location', $user->profile->farm_location ?? '') }}">
                        </div>
                        
                        <div class="col-12 mb-3">
                            <label for="crops_grown" class="form-label">Crops Grown</label>
                            <textarea class="form-control" id="crops_grown" name="crops_grown" rows="3" 
                                      placeholder="List the main crops grown (e.g., Rice, Corn, Vegetables)">{{ old('crops_grown', $user->profile->crops_grown ?? '') }}</textarea>
                        </div>
                    </div>

                    <!-- Account Information -->
                    <div class="row mb-4">
                        <div class="col-12">
                            <h6 class="text-info border-bottom pb-2 mb-3">
                                <i class="fas fa-clock me-2"></i>Account Information
                            </h6>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Account Created</label>
                            <input type="text" class="form-control" 
                                   value="{{ $user->created_at->format('F d, Y H:i') }}" readonly>
                        </div>
                        
                        <div class="col-md-6 mb-3">
                            <label class="form-label">Last Updated</label>
                            <input type="text" class="form-control" 
                                   value="{{ $user->updated_at->format('F d, Y H:i') }}" readonly>
                        </div>
                    </div>

                    <!-- Action Buttons -->
                    <div class="row">
                        <div class="col-12">
                            <div class="d-flex justify-content-end gap-2">
                                <a href="{{ route('admin.users.index') }}" class="btn btn-outline-secondary">
                                    <i class="fas fa-times me-2"></i>Cancel
                                </a>
                                <button type="submit" class="btn btn-primary">
                                    <i class="fas fa-save me-2"></i>Update User
                                </button>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
// Show/hide farmer fields based on role selection
document.getElementById('role').addEventListener('change', function() {
    const farmerFields = document.getElementById('farmerFields');
    if (this.value === 'farmer') {
        farmerFields.style.display = 'block';
    } else {
        farmerFields.style.display = 'none';
    }
});
</script>
@endsection