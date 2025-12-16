@extends('admin.layouts.app')

@section('title', 'Komoditas - Agrigo Admin')

@section('content')
<div class="card shadow-sm mb-4" style="border: 2px solid #3b82f6; border-radius: 10px;">
    <div class="card-body p-4">
        <!-- Header -->
        <div class="d-flex justify-content-between align-items-center mb-4">
            <h4 class="mb-0 fw-bold" style="color: #1f2937;">Komoditas</h4>
        </div>
        
        <!-- Search and Add Button -->
        <div class="row mb-4">
            <div class="col-md-8">
                <div class="input-group">
                    <span class="input-group-text bg-white" style="border-right: none;">
                        <i class="fas fa-search text-muted"></i>
                    </span>
                    <input type="text" class="form-control" placeholder="Cari komoditas" 
                           style="border-left: none;" id="searchInput">
                </div>
            </div>
            <div class="col-md-4 text-end">
                <a href="{{ route('admin.commodities.create') }}" 
                   class="btn btn-success w-100" 
                   style="background: #22c55e; border: none;">
                    <i class="fas fa-plus me-2"></i>Tambah komoditas baru
                </a>
            </div>
        </div>
        
        <!-- Commodities List -->
        @if($commodities->count() > 0)
            @foreach($commodities as $commodity)
            <div class="card mb-3" style="border: 1px solid #e5e7eb; border-radius: 8px; background: #f9fafb;">
                <div class="card-body p-3">
                    <div class="d-flex align-items-center justify-content-between">
                        <div class="d-flex align-items-center gap-3">
                            <strong style="color: #1f2937;">{{ $commodity->name }}</strong>
                            <span class="badge" style="background: #e0f2fe; color: #0369a1; border-radius: 6px; padding: 4px 12px;">
                                {{ $commodity->type }}
                            </span>
                        </div>
                        <div class="d-flex gap-2">
                            <a href="{{ route('admin.commodities.edit', $commodity->id) }}" 
                               class="btn btn-sm btn-primary" 
                               style="background: #3b82f6; border: none; border-radius: 6px;">
                                <i class="fas fa-edit me-1"></i>Edit
                            </a>
                            <form action="{{ route('admin.commodities.destroy', $commodity->id) }}" 
                                  method="POST" class="d-inline"
                                  onsubmit="return confirm('Apakah Anda yakin ingin menghapus komoditas ini?');">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-danger" 
                                        style="background: #ef4444; border: none; border-radius: 6px;">
                                    <i class="fas fa-trash me-1"></i>Hapus
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
            @endforeach
            
            <!-- Pagination -->
            <div class="mt-3">
                {{ $commodities->links() }}
            </div>
        @else
            <div class="text-center py-5">
                <i class="fas fa-seedling fa-3x text-muted mb-3"></i>
                <p class="text-muted">Tidak ada komoditas ditemukan.</p>
            </div>
        @endif
    </div>
</div>

@push('scripts')
<script>
// Search functionality
document.getElementById('searchInput').addEventListener('keyup', function() {
    const searchValue = this.value.toLowerCase();
    const commodityCards = document.querySelectorAll('.card.mb-3');
    
    commodityCards.forEach(card => {
        const commodityName = card.textContent.toLowerCase();
        if (commodityName.includes(searchValue)) {
            card.style.display = 'block';
        } else {
            card.style.display = 'none';
        }
    });
});
</script>
@endpush
@endsection
