@extends('admin.layouts.app')

@section('title', 'Commodity Management - Agrigo Admin')

@section('content')
<div class="row mb-4">
    <div class="col-md-6">
        <h1 class="h3 mb-0 text-gray-800">
            <i class="fas fa-seedling me-2"></i>Commodity Management
        </h1>
        <p class="text-muted">Manage agricultural commodities</p>
    </div>
    <div class="col-md-6 text-end">
        <a href="{{ route('admin.commodities.create') }}" class="btn btn-primary">
            <i class="fas fa-plus me-2"></i>Add Commodity
        </a>
    </div>
</div>

<!-- Statistics -->
<div class="alert alert-info mb-4">
    <i class="fas fa-info-circle me-2"></i>
    Total: <strong>{{ $commodities->total() }}</strong> commodities | 
    Page {{ $commodities->currentPage() }} of {{ $commodities->lastPage() }}
</div>

<!-- Commodities Table -->
<div class="card shadow mb-4">
    <div class="card-header py-3">
        <h6 class="m-0 font-weight-bold text-primary">All Commodities</h6>
    </div>
    <div class="card-body">
        @if($commodities->count() > 0)
            <div class="table-responsive">
                <table class="table table-hover">
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Name</th>
                            <th>Type/Category</th>
                            <th>Description</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($commodities as $commodity)
                        <tr>
                            <td>
                                <span class="badge bg-secondary">#{{ $commodity->id }}</span>
                            </td>
                            <td>
                                <strong>{{ $commodity->name }}</strong>
                            </td>
                            <td>
                                <span class="badge bg-info">{{ $commodity->type }}</span>
                            </td>
                            <td>
                                <small>{{ Str::limit($commodity->description ?? '-', 50) }}</small>
                            </td>
                            <td>
                                @if($commodity->is_active)
                                    <span class="badge bg-success">Active</span>
                                @else
                                    <span class="badge bg-secondary">Inactive</span>
                                @endif
                            </td>
                            <td>
                                <div class="btn-group" role="group">
                                    <a href="{{ route('admin.commodities.edit', $commodity->id) }}" 
                                       class="btn btn-sm btn-outline-primary" title="Edit">
                                        <i class="fas fa-edit"></i>
                                    </a>
                                    <form action="{{ route('admin.commodities.toggle-status', $commodity->id) }}" 
                                          method="POST" class="d-inline">
                                        @csrf
                                        <button type="submit" 
                                                class="btn btn-sm btn-outline-{{ $commodity->is_active ? 'warning' : 'success' }}" 
                                                title="{{ $commodity->is_active ? 'Deactivate' : 'Activate' }}">
                                            <i class="fas fa-{{ $commodity->is_active ? 'pause' : 'play' }}"></i>
                                        </button>
                                    </form>
                                    <form action="{{ route('admin.commodities.destroy', $commodity->id) }}" 
                                          method="POST" class="d-inline"
                                          onsubmit="return confirm('Are you sure you want to delete this commodity?');">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-outline-danger" title="Delete">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </form>
                                </div>
                            </td>
                        </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
            
            <!-- Pagination -->
            <div class="mt-3">
                {{ $commodities->links() }}
            </div>
        @else
            <div class="text-center py-5">
                <i class="fas fa-seedling fa-3x text-muted mb-3"></i>
                <p class="text-muted">No commodities found.</p>
                <a href="{{ route('admin.commodities.create') }}" class="btn btn-primary">
                    <i class="fas fa-plus me-2"></i>Add First Commodity
                </a>
            </div>
        @endif
    </div>
</div>
@endsection
