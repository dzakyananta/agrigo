@extends('admin.layouts.app')

@section('title', 'Commodity Management')

@section('content')
<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Commodity Management</h1>
        <a href="{{ route('admin.commodities.create') }}" class="btn btn-primary">
            <i class="fas fa-plus me-2"></i>Add New Commodity
        </a>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    @endif

    <div class="card shadow mb-4">
        <div class="card-header py-3" style="background: linear-gradient(135deg, #2E8B25 0%, #4CAF50 100%);">
            <h6 class="m-0 font-weight-bold text-white">
                <i class="fas fa-leaf me-2"></i>All Commodities
            </h6>
        </div>
        <div class="card-body p-0">
            @if($commodities->count() > 0)
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Category</th>
                                <th>Unit</th>
                                <th>Current Price</th>
                                <th>Price Range</th>
                                <th>Harvest Season</th>
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
                                    <div class="font-weight-bold">{{ $commodity->name }}</div>
                                </td>
                                <td>
                                    <span class="badge bg-info">{{ $commodity->category }}</span>
                                </td>
                                <td>{{ $commodity->unit }}</td>
                                <td>
                                    <strong>Rp {{ number_format($commodity->current_price, 0, ',', '.') }}</strong>
                                </td>
                                <td>
                                    @if($commodity->min_price || $commodity->max_price)
                                        <small class="text-muted">
                                            Rp {{ number_format($commodity->min_price ?? 0, 0, ',', '.') }} - 
                                            Rp {{ number_format($commodity->max_price ?? 0, 0, ',', '.') }}
                                        </small>
                                    @else
                                        <small class="text-muted">-</small>
                                    @endif
                                </td>
                                <td>
                                    {{ $commodity->harvest_season ?? '-' }}
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
                                        <a href="{{ route('admin.commodities.show', $commodity->id) }}" 
                                           class="btn btn-sm btn-info" title="View">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="{{ route('admin.commodities.edit', $commodity->id) }}" 
                                           class="btn btn-sm btn-warning" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <form action="{{ route('admin.commodities.toggle-status', $commodity->id) }}" 
                                              method="POST" class="d-inline">
                                            @csrf
                                            @method('POST')
                                            <button type="submit" class="btn btn-sm btn-secondary" 
                                                    title="Toggle Status">
                                                <i class="fas fa-toggle-{{ $commodity->is_active ? 'on' : 'off' }}"></i>
                                            </button>
                                        </form>
                                        <form action="{{ route('admin.commodities.destroy', $commodity->id) }}" 
                                              method="POST" class="d-inline" 
                                              onsubmit="return confirm('Are you sure you want to delete this commodity?')">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-danger" title="Delete">
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
                <div class="card-footer">
                    {{ $commodities->links() }}
                </div>
            @else
                <div class="text-center py-5">
                    <i class="fas fa-leaf fa-3x text-muted mb-3"></i>
                    <p class="text-muted">No commodities found. Add your first commodity!</p>
                    <a href="{{ route('admin.commodities.create') }}" class="btn btn-primary">
                        <i class="fas fa-plus me-2"></i>Add Commodity
                    </a>
                </div>
            @endif
        </div>
    </div>
</div>
@endsection
