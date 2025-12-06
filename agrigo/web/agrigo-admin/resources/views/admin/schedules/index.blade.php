@extends('admin.layouts.app')

@section('title', 'Planting Schedules')

@section('content')
<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Planting Schedule Management</h1>
        <a href="{{ route('admin.schedules.create') }}" class="btn btn-primary">
            <i class="fas fa-plus me-2"></i>Add New Schedule
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
                <i class="fas fa-calendar-alt me-2"></i>All Planting Schedules
            </h6>
        </div>
        <div class="card-body p-0">
            @if($schedules->count() > 0)
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Farmer</th>
                                <th>Commodity</th>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th>Duration</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($schedules as $schedule)
                            <tr>
                                <td>
                                    <span class="badge bg-secondary">#{{ $schedule->id }}</span>
                                </td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        <div class="avatar avatar-sm rounded-circle bg-primary text-white me-2 d-flex align-items-center justify-content-center" style="width: 30px; height: 30px; font-size: 0.8rem;">
                                            {{ strtoupper(substr($schedule->user->name ?? 'N/A', 0, 2)) }}
                                        </div>
                                        <div>
                                            <div class="font-weight-bold">{{ $schedule->user->name ?? 'N/A' }}</div>
                                            <small class="text-muted">{{ $schedule->user->email ?? '' }}</small>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div class="font-weight-bold">{{ $schedule->komoditas }}</div>
                                    @if($schedule->commodity)
                                        <small class="text-muted">{{ $schedule->commodity->category }}</small>
                                    @endif
                                </td>
                                <td>{{ $schedule->start_date ? $schedule->start_date->format('d/m/Y') : '-' }}</td>
                                <td>{{ $schedule->end_date ? $schedule->end_date->format('d/m/Y') : '-' }}</td>
                                <td>
                                    <span class="badge bg-info">{{ $schedule->duration }} days</span>
                                </td>
                                <td>
                                    @if($schedule->status == 'active')
                                        <span class="badge bg-success">Active</span>
                                    @elseif($schedule->status == 'completed')
                                        <span class="badge bg-primary">Completed</span>
                                    @else
                                        <span class="badge bg-secondary">Cancelled</span>
                                    @endif
                                </td>
                                <td>
                                    <div class="btn-group" role="group">
                                        <a href="{{ route('admin.schedules.show', $schedule->id) }}" 
                                           class="btn btn-sm btn-info" title="View">
                                            <i class="fas fa-eye"></i>
                                        </a>
                                        <a href="{{ route('admin.schedules.edit', $schedule->id) }}" 
                                           class="btn btn-sm btn-warning" title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <form action="{{ route('admin.schedules.destroy', $schedule->id) }}" 
                                              method="POST" class="d-inline" 
                                              onsubmit="return confirm('Are you sure you want to delete this schedule?')">
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
                    {{ $schedules->links() }}
                </div>
            @else
                <div class="text-center py-5">
                    <i class="fas fa-calendar-alt fa-3x text-muted mb-3"></i>
                    <p class="text-muted">No schedules found. Add your first planting schedule!</p>
                    <a href="{{ route('admin.schedules.create') }}" class="btn btn-primary">
                        <i class="fas fa-plus me-2"></i>Add Schedule
                    </a>
                </div>
            @endif
        </div>
    </div>
</div>
@endsection
