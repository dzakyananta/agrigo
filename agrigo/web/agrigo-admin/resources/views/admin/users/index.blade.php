@extends('admin.layouts.app')

@section('title', 'User Management - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-md-6">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-users me-2"></i>User Management
        </h1>
        <p class="text-muted">Manage farmers and users in the system</p>
    </div>
    <div class="col-md-6 text-end">
        <button class="btn btn-primary">
            <i class="fas fa-plus me-2"></i>Add New User
        </button>
    </div>
</div>

<!-- Filter and Search -->
<div class="row mb-4">
    <div class="col-12">
        <div class="card shadow">
            <div class="card-body">
                <form method="GET" class="row g-3">
                    <div class="col-md-4">
                        <label class="form-label">Search Users</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="fas fa-search"></i></span>
                            <input type="text" class="form-control" name="search" 
                                   placeholder="Search by name or email..." 
                                   value="{{ request('search') }}">
                        </div>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Role</label>
                        <select name="role" class="form-select">
                            <option value="">All Roles</option>
                            <option value="farmer" {{ request('role') === 'farmer' ? 'selected' : '' }}>Farmer</option>
                            <option value="buyer" {{ request('role') === 'buyer' ? 'selected' : '' }}>Buyer</option>
                            <option value="admin" {{ request('role') === 'admin' ? 'selected' : '' }}>Admin</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-select">
                            <option value="">All Status</option>
                            <option value="active" {{ request('status') === 'active' ? 'selected' : '' }}>Active</option>
                            <option value="inactive" {{ request('status') === 'inactive' ? 'selected' : '' }}>Inactive</option>
                            <option value="suspended" {{ request('status') === 'suspended' ? 'selected' : '' }}>Suspended</option>
                        </select>
                    </div>
                    <div class="col-md-4">
                        <label class="form-label">&nbsp;</label>
                        <div class="d-grid gap-2 d-md-flex">
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-filter me-2"></i>Filter
                            </button>
                            <a href="{{ route('admin.users.index') }}" class="btn btn-outline-secondary">
                                <i class="fas fa-undo me-2"></i>Reset
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- Users Table -->
<div class="row">
    <div class="col-12">
        <div class="table-container">
            <div class="card-header py-3">
                <h6 class="m-0 font-weight-bold text-white">
                    <i class="fas fa-list me-2"></i>All Users ({{ $users->total() ?? 0 }})
                </h6>
            </div>
            <div class="card-body p-0">
                @if(isset($users) && $users->count() > 0)
                    <div class="table-responsive">
                        <table class="table table-hover mb-0">
                            <thead>
                                <tr>
                                    <th>User</th>
                                    <th>Role</th>
                                    <th>Status</th>
                                    <th>Profile Info</th>
                                    <th>Joined Date</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($users as $user)
                                <tr>
                                    <td>
                                        <div class="d-flex align-items-center">
                                            <div class="avatar avatar-md rounded-circle bg-primary text-white me-3 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                                                {{ strtoupper(substr($user->name, 0, 2)) }}
                                            </div>
                                            <div>
                                                <div class="font-weight-bold">{{ $user->name }}</div>
                                                <small class="text-muted">{{ $user->email }}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <span class="badge bg-{{ $user->role === 'farmer' ? 'success' : ($user->role === 'admin' ? 'danger' : 'info') }}">
                                            <i class="fas fa-{{ $user->role === 'farmer' ? 'leaf' : ($user->role === 'admin' ? 'crown' : 'shopping-cart') }} me-1"></i>
                                            {{ ucfirst($user->role ?? 'User') }}
                                        </span>
                                    </td>
                                    <td>
                                        <span class="badge status-{{ $user->status ?? 'active' }}">
                                            {{ ucfirst($user->status ?? 'Active') }}
                                        </span>
                                    </td>
                                    <td>
                                        @if($user->profile)
                                            <div class="small">
                                                @if($user->profile->phone)
                                                    <div><i class="fas fa-phone me-1"></i>{{ $user->profile->phone }}</div>
                                                @endif
                                                @if($user->profile->farm_location && $user->role === 'farmer')
                                                    <div><i class="fas fa-map-marker-alt me-1"></i>{{ $user->profile->farm_location }}</div>
                                                @endif
                                            </div>
                                        @else
                                            <small class="text-muted">No profile data</small>
                                        @endif
                                    </td>
                                    <td>
                                        <div>{{ $user->created_at->format('M d, Y') }}</div>
                                        <small class="text-muted">{{ $user->created_at->diffForHumans() }}</small>
                                    </td>
                                    <td>
                                        <div class="btn-group" role="group">
                                            <a href="{{ route('admin.users.show', $user->id) }}" 
                                               class="btn btn-sm btn-outline-info" title="View Details">
                                                <i class="fas fa-eye"></i>
                                            </a>
                                            <a href="{{ route('admin.users.edit', $user->id) }}" 
                                               class="btn btn-sm btn-outline-warning" title="Edit">
                                                <i class="fas fa-edit"></i>
                                            </a>
                                            <button class="btn btn-sm btn-outline-{{ $user->status === 'active' ? 'secondary' : 'success' }}" 
                                                    onclick="toggleUserStatus({{ $user->id }})" 
                                                    title="{{ $user->status === 'active' ? 'Deactivate' : 'Activate' }}">
                                                <i class="fas fa-{{ $user->status === 'active' ? 'ban' : 'check' }}"></i>
                                            </button>
                                            <button class="btn btn-sm btn-outline-danger" 
                                                    onclick="deleteUser({{ $user->id }})" title="Delete">
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
                    @if($users->hasPages())
                        <div class="d-flex justify-content-center pt-3 pb-3">
                            {{ $users->links() }}
                        </div>
                    @endif
                @else
                    <div class="text-center py-5">
                        <i class="fas fa-users text-muted" style="font-size: 4rem; opacity: 0.3;"></i>
                        <h5 class="text-muted mt-3">No Users Found</h5>
                        <p class="text-muted">No users match your current filter criteria.</p>
                        <button class="btn btn-primary">
                            <i class="fas fa-plus me-2"></i>Add First User
                        </button>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title">Confirm Deletion</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this user? This action cannot be undone.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <form id="deleteForm" method="POST" class="d-inline">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="btn btn-danger">Delete User</button>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
function toggleUserStatus(userId) {
    fetch(`/admin/users/${userId}/toggle-status`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
        }
    })
    .then(response => response.json())
    .then(data => {
        if (data.status === 'success') {
            location.reload();
        } else {
            alert('Error updating user status');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Error updating user status');
    });
}

function deleteUser(userId) {
    document.getElementById('deleteForm').action = `/admin/users/${userId}`;
    new bootstrap.Modal(document.getElementById('deleteModal')).show();
}
</script>
@endsection