@extends('admin.layouts.app')

@section('title', 'Laporan Regional Pertanian - Agrigo Admin')

@section('content')
<div class="card shadow-sm mb-4" style="border: 2px solid #3b82f6; border-radius: 10px;">
    <div class="card-body p-4">
        <!-- Header -->
        <div class="mb-4">
            <h4 class="mb-0 fw-bold" style="color: #1f2937;">Laporan Regional Pertanian</h4>
        </div>

        <!-- Regional Reports -->
        <div class="row">
            <!-- Jawa Barat -->
            <div class="col-12 mb-4">
                <div class="card shadow-sm" style="border: 1px solid #e5e7eb; border-radius: 10px;">
                    <div class="card-body p-0">
                        <div class="row g-0">
                            <div class="col-md-7 p-3">
                                <h5 class="mb-3 fw-bold" style="color: #1f2937;">Peta Sebaran Petani - Jawa Barat</h5>
                                <div class="position-relative" style="height: 250px; background: #e5e7eb; border-radius: 8px; overflow: hidden;">
                                     <img src="/images/PETA.jpeg" 
                                         alt="Peta Jawa Barat" 
                                         class="w-100 h-100" 
                                         style="object-fit: cover;">
                                    <div class="position-absolute bottom-0 start-0 p-2">
                                        <span class="badge bg-light text-dark me-2">Peta</span>
                                        <span class="badge bg-success">Statistik</span>
                                    </div>
                                    <div class="position-absolute top-0 end-0 p-2">
                                        <button class="btn btn-sm btn-light rounded-circle mb-1" style="width: 35px; height: 35px;">
                                            <i class="fas fa-plus"></i>
                                        </button><br>
                                        <button class="btn btn-sm btn-light rounded-circle mb-1" style="width: 35px; height: 35px;">
                                            <i class="fas fa-minus"></i>
                                        </button><br>
                                        <button class="btn btn-sm btn-light rounded-circle" style="width: 35px; height: 35px;">
                                            <i class="fas fa-info"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-5 p-4 d-flex flex-column justify-content-center" style="background: #f9fafb;">
                                <div class="d-flex align-items-center mb-3">
                                    <div class="rounded-circle bg-success d-flex align-items-center justify-content-center me-3" 
                                         style="width: 40px; height: 40px;">
                                        <i class="fas fa-arrow-up text-white"></i>
                                    </div>
                                    <div>
                                        <div class="text-muted small">Pendapatan Rata-rata Petani</div>
                                        <div class="small text-success">4 minggu sebelumnya</div>
                                    </div>
                                </div>
                                <h3 class="fw-bold mb-2" style="color: #1f2937;">Rp 5.250.000</h3>
                                <div class="text-success mb-2">↑ 8% dari bulan lalu</div>
                                <p class="text-muted small mb-0">Data diperoleh 4 minggu lalu untuk melacak dan menganalisa laporan petani</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Lampung -->
            <div class="col-12 mb-4">
                <div class="card shadow-sm" style="border: 1px solid #e5e7eb; border-radius: 10px;">
                    <div class="card-body p-0">
                        <div class="row g-0">
                            <div class="col-md-7 p-3">
                                <h5 class="mb-3 fw-bold" style="color: #1f2937;">Peta Sebaran Petani - Lampung</h5>
                                <div class="position-relative" style="height: 250px; background: #e5e7eb; border-radius: 8px; overflow: hidden;">
                                     <img src="/images/PETA.jpeg" 
                                         alt="Peta Lampung" 
                                         class="w-100 h-100" 
                                         style="object-fit: cover;">
                                    <div class="position-absolute bottom-0 start-0 p-2">
                                        <span class="badge bg-light text-dark me-2">Peta</span>
                                        <span class="badge bg-success">Statistik</span>
                                    </div>
                                    <div class="position-absolute top-0 end-0 p-2">
                                        <button class="btn btn-sm btn-light rounded-circle mb-1" style="width: 35px; height: 35px;">
                                            <i class="fas fa-plus"></i>
                                        </button><br>
                                        <button class="btn btn-sm btn-light rounded-circle mb-1" style="width: 35px; height: 35px;">
                                            <i class="fas fa-minus"></i>
                                        </button><br>
                                        <button class="btn btn-sm btn-light rounded-circle" style="width: 35px; height: 35px;">
                                            <i class="fas fa-info"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-5 p-4 d-flex flex-column justify-content-center" style="background: #f9fafb;">
                                <div class="d-flex align-items-center mb-3">
                                    <div class="rounded-circle bg-success d-flex align-items-center justify-content-center me-3" 
                                         style="width: 40px; height: 40px;">
                                        <i class="fas fa-arrow-up text-white"></i>
                                    </div>
                                    <div>
                                        <div class="text-muted small">Pendapatan Rata-rata Petani</div>
                                        <div class="small text-success">4 minggu sebelumnya</div>
                                    </div>
                                </div>
                                <h3 class="fw-bold mb-2" style="color: #1f2937;">Rp 6.300.000</h3>
                                <div class="text-success mb-2">↑ 12% dari bulan lalu</div>
                                <p class="text-muted small mb-0">Data diperoleh 4 minggu lalu untuk melacak dan menganalisa laporan petani</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Jawa Tengah -->
            <div class="col-12 mb-4">
                <div class="card shadow-sm" style="border: 1px solid #e5e7eb; border-radius: 10px;">
                    <div class="card-body p-0">
                        <div class="row g-0">
                            <div class="col-md-7 p-3">
                                <h5 class="mb-3 fw-bold" style="color: #1f2937;">Peta Sebaran Petani - Jawa Tengah</h5>
                                <div class="position-relative" style="height: 250px; background: #e5e7eb; border-radius: 8px; overflow: hidden;">
                                     <img src="/images/PETA.jpeg" 
                                         alt="Peta Jawa Tengah" 
                                         class="w-100 h-100" 
                                         style="object-fit: cover;">
                                    <div class="position-absolute bottom-0 start-0 p-2">
                                        <span class="badge bg-light text-dark me-2">Peta</span>
                                        <span class="badge bg-success">Statistik</span>
                                    </div>
                                    <div class="position-absolute top-0 end-0 p-2">
                                        <button class="btn btn-sm btn-light rounded-circle mb-1" style="width: 35px; height: 35px;">
                                            <i class="fas fa-plus"></i>
                                        </button><br>
                                        <button class="btn btn-sm btn-light rounded-circle mb-1" style="width: 35px; height: 35px;">
                                            <i class="fas fa-minus"></i>
                                        </button><br>
                                        <button class="btn btn-sm btn-light rounded-circle" style="width: 35px; height: 35px;">
                                            <i class="fas fa-info"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div class="col-md-5 p-4 d-flex flex-column justify-content-center" style="background: #f9fafb;">
                                <div class="d-flex align-items-center mb-3">
                                    <div class="rounded-circle bg-success d-flex align-items-center justify-content-center me-3" 
                                         style="width: 40px; height: 40px;">
                                        <i class="fas fa-arrow-up text-white"></i>
                                    </div>
                                    <div>
                                        <div class="text-muted small">Pendapatan Rata-rata Petani</div>
                                        <div class="small text-success">4 minggu sebelumnya</div>
                                    </div>
                                </div>
                                <h3 class="fw-bold mb-2" style="color: #1f2937;">Rp 4.400.000</h3>
                                <div class="text-success mb-2">↑ 5% dari bulan lalu</div>
                                <p class="text-muted small mb-0">Data diperoleh 4 minggu lalu untuk melacak dan menganalisa laporan petani</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

@endsection
