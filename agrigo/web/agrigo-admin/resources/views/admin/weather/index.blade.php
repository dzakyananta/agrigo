@extends('admin.layouts.app')

@section('title', 'Weather Data')

@section('content')
<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h1 class="h3 mb-0 text-gray-800">Weather Data Management</h1>
        <a href="{{ route('admin.weather.create') }}" class="btn btn-primary">
            <i class="fas fa-plus me-2"></i>Add Weather Data
        </a>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    @endif

    <div class="card shadow mb-4">
        <div class="card-header py-3" style="background: linear-gradient(135deg, #3498db 0%, #2980b9 100%);">
            <h6 class="m-0 font-weight-bold text-white">
                <i class="fas fa-cloud-sun me-2"></i>All Weather Records
            </h6>
        </div>
        <div class="card-body p-0">
            @if($weatherData->count() > 0)
                <div class="table-responsive">
                    <table class="table table-hover mb-0">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Location</th>
                                <th>Condition</th>
                                <th>Temperature</th>
                                <th>Humidity</th>
                                <th>Rainfall</th>
                                <th>Wind Speed</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach($weatherData as $weather)
                            <tr>
                                <td>{{ $weather->date ? \Carbon\Carbon::parse($weather->date)->format('d/m/Y') : '-' }}</td>
                                <td><strong>{{ $weather->location }}</strong></td>
                                <td>
                                    <span class="badge bg-primary">{{ $weather->condition }}</span>
                                </td>
                                <td>{{ $weather->temperature }}°C</td>
                                <td>{{ $weather->humidity }}%</td>
                                <td>{{ $weather->rainfall ?? 0 }} mm</td>
                                <td>{{ $weather->wind_speed ?? '-' }} km/h</td>
                                <td>
                                    <form action="{{ route('admin.weather.destroy', $weather->id) }}" 
                                          method="POST" class="d-inline" 
                                          onsubmit="return confirm('Are you sure?')">
                                        @csrf
                                        @method('DELETE')
                                        <button type="submit" class="btn btn-sm btn-danger" title="Delete">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </form>
                                </td>
                            </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
                <div class="card-footer">
                    {{ $weatherData->links() }}
                </div>
            @else
                <div class="text-center py-5">
                    <i class="fas fa-cloud-sun fa-3x text-muted mb-3"></i>
                    <p class="text-muted">No weather data found.</p>
                    <a href="{{ route('admin.weather.create') }}" class="btn btn-primary">
                        <i class="fas fa-plus me-2"></i>Add Weather Data
                    </a>
                </div>
            @endif
        </div>
    </div>
</div>
@endsection
