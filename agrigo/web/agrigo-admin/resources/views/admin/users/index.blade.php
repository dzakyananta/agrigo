@extends('admin.layouts.app')

@section('title', 'Pengguna - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-12">
        <h1 class="h3 mb-0" style="color: #1f2937; font-weight: 600;">
            Pengguna
        </h1>
    </div>
</div>

<!-- Main Content Card -->
<div class="card shadow-sm" style="border: 2px solid #3b82f6; border-radius: 12px;">
    <div class="card-body p-4">
        <!-- Search and Add Button -->
        <div class="row mb-4">
            <div class="col-md-8">
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0">
                        <i class="fas fa-search text-muted"></i>
                    </span>
                    <input type="text" class="form-control border-start-0" 
                           placeholder="Cari pengguna" 
                           id="searchInput"
                           style="border-left: none;">
                </div>
            </div>
            <div class="col-md-4 text-end">
                <button class="btn btn-success">
                    <i class="fas fa-plus me-2"></i>Tambah pengguna baru
                </button>
            </div>
        </div>

        <!-- Header with Filter -->
        <div class="d-flex justify-content-between align-items-center mb-3">
            <h5 class="mb-0" style="color: #1f2937; font-weight: 600;">
                Semua Pengguna ({{ $users->total() ?? 0 }})
            </h5>
            <button class="btn btn-outline-secondary btn-sm">
                <i class="fas fa-filter me-1"></i> Filter
            </button>
        </div>

        <!-- Users List -->
        <div class="users-list">
            @if(isset($users) && $users->count() > 0)
                @foreach($users as $user)
                <div class="card mb-3 shadow-sm" style="border: 1px solid #e5e7eb; border-radius: 10px;">
                    <div class="card-body p-3">
                        <div class="d-flex align-items-center justify-content-between">
                            <div class="d-flex align-items-center flex-grow-1">
                                <div class="avatar rounded-circle d-flex align-items-center justify-content-center me-3" 
                                     style="width: 50px; height: 50px; background: linear-gradient(135deg, #3b82f6 0%, #2563eb 100%); flex-shrink: 0;">
                                    <span class="text-white fw-bold">{{ strtoupper(substr($user->name, 0, 2)) }}</span>
                                </div>
                                <div class="flex-grow-1">
                                    <div class="fw-bold" style="color: #1f2937;">{{ $user->name }}</div>
                                    <div class="small text-muted">
                                        <i class="fas fa-calendar-alt me-1"></i>Bergabung {{ $user->created_at->format('d M Y') }}
                                    </div>
                                </div>
                            </div>
                            <div class="d-flex gap-2">
                                <a href="{{ route('admin.users.edit', $user->id) }}" 
                                   class="btn btn-sm btn-outline-primary" 
                                   title="Edit">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <button class="btn btn-sm btn-outline-danger" 
                                        onclick="deleteUser({{ $user->id }})" 
                                        title="Delete">
                                    <i class="fas fa-trash"></i>
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                @endforeach
                    
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