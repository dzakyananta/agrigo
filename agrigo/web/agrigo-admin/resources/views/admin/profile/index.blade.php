@extends('admin.layouts.app')

@section('title', 'Profil Admin - Agrigo Admin')

@section('content')
<div class="row">
    <div class="col-lg-8 mx-auto">
        <div class="card shadow-sm mb-4" style="border: 2px solid #3b82f6; border-radius: 10px;">
            <div class="card-body p-4">
                <!-- Header -->
                <h4 class="mb-4 fw-bold" style="color: #1f2937;">Profil Admin</h4>
                
                <!-- Profile Picture Section -->
                <div class="text-center mb-4">
                    <div class="position-relative d-inline-block">
                        <div class="rounded-circle overflow-hidden mx-auto" style="width: 120px; height: 120px; border: 4px solid #22c55e;">
                            <img src="{{ auth()->user()->avatar ?? 'https://ui-avatars.com/api/?name='.urlencode(auth()->user()->name ?? 'Admin').'&background=22c55e&color=fff&size=120' }}" 
                                 alt="Profile" 
                                 class="w-100 h-100" 
                                 style="object-fit: cover;">
                        </div>
                        <span class="badge bg-success position-absolute" style="bottom: 10px; left: 50%; transform: translateX(-50%); padding: 6px 16px; border-radius: 20px;">
                            Admin Profil
                        </span>
                    </div>
                    <div class="mt-3 text-muted small">JPG, GIF atau PNG. Maks 2mb</div>
                </div>

                <!-- Profile Information Form -->
                <form action="{{ route('admin.profile.update') }}" method="POST">
                    @csrf
                    @method('PUT')
                    
                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="name" class="form-label fw-semibold" style="color: #1f2937;">Nama Lengkap</label>
                            <input type="text" class="form-control" id="name" name="name" 
                                   value="{{ old('name', auth()->user()->name ?? 'Admin Agrigo') }}" 
                                   style="border: 1px solid #d1d5db; border-radius: 8px; padding: 10px;">
                        </div>
                        <div class="col-md-6">
                            <label for="email" class="form-label fw-semibold" style="color: #1f2937;">Alamat Email</label>
                            <input type="email" class="form-control" id="email" name="email" 
                                   value="{{ old('email', auth()->user()->email ?? 'admin@agrigo@email.com') }}" 
                                   style="border: 1px solid #d1d5db; border-radius: 8px; padding: 10px;">
                        </div>
                    </div>

                    <div class="row mb-3">
                        <div class="col-md-6">
                            <label for="phone" class="form-label fw-semibold" style="color: #1f2937;">Nomor Telepon</label>
                            <input type="text" class="form-control" id="phone" name="phone" 
                                   value="{{ old('phone', '081234567890') }}" 
                                   style="border: 1px solid #d1d5db; border-radius: 8px; padding: 10px;">
                        </div>
                        <div class="col-md-6">
                            <label for="position" class="form-label fw-semibold" style="color: #1f2937;">Jabatan</label>
                            <input type="text" class="form-control" id="position" name="position" 
                                   value="{{ old('position', 'Administrator Utama') }}" 
                                   style="border: 1px solid #d1d5db; border-radius: 8px; padding: 10px;">
                        </div>
                    </div>

                    <div class="mb-4">
                        <label for="address" class="form-label fw-semibold" style="color: #1f2937;">Alamat</label>
                        <textarea class="form-control" id="address" name="address" rows="2" 
                                  style="border: 1px solid #d1d5db; border-radius: 8px; padding: 10px;">{{ old('address', 'Jl. Pertanian Makmur No. 1, Jakarta, Indonesia') }}</textarea>
                    </div>

                    <!-- Action Buttons -->
                    <div class="d-flex justify-content-end gap-2">
                        <button type="button" class="btn btn-outline-secondary" style="border-radius: 8px; padding: 10px 24px;">
                            Batal
                        </button>
                        <button type="submit" class="btn btn-success" style="background: #22c55e; border: none; border-radius: 8px; padding: 10px 24px;">
                            Simpan Perubahan
                        </button>
                    </div>
                </form>
            </div>
        </div>

        <!-- Change Password Section -->
        <div class="card shadow-sm mb-4" style="border: 2px solid #3b82f6; border-radius: 10px;">
            <div class="card-body p-4">
                <h5 class="mb-4 fw-bold" style="color: #1f2937;">Ubah Kata Sandi</h5>
                <p class="text-muted mb-4">Pastikan akun menggunakan kata sandi yang kuat dan panjang untuk tetap aman</p>

                <form action="{{ route('admin.profile.password') }}" method="POST">
                    @csrf
                    @method('PUT')
                    
                    <div class="row mb-3">
                        <div class="col-md-4">
                            <label for="current_password" class="form-label fw-semibold" style="color: #1f2937;">Kata Sandi Saat Ini</label>
                            <input type="password" class="form-control" id="current_password" name="current_password" 
                                   placeholder="Admin" 
                                   style="border: 1px solid #d1d5db; border-radius: 8px; padding: 10px;">
                        </div>
                        <div class="col-md-4">
                            <label for="new_password" class="form-label fw-semibold" style="color: #1f2937;">Kata Sandi Baru</label>
                            <input type="password" class="form-control" id="new_password" name="new_password" 
                                   placeholder="AdminAgrigo" 
                                   style="border: 1px solid #d1d5db; border-radius: 8px; padding: 10px;">
                        </div>
                        <div class="col-md-4">
                            <label for="new_password_confirmation" class="form-label fw-semibold" style="color: #1f2937;">Konfirmasi Kata Sandi Baru</label>
                            <input type="password" class="form-control" id="new_password_confirmation" name="new_password_confirmation" 
                                   placeholder="AdminAgrigo" 
                                   style="border: 1px solid #d1d5db; border-radius: 8px; padding: 10px;">
                        </div>
                    </div>

                    <div class="text-end">
                        <button type="submit" class="btn btn-success" style="background: #22c55e; border: none; border-radius: 8px; padding: 10px 24px;">
                            Ubah Kata Sandi
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection
