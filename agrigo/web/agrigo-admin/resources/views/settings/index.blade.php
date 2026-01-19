@extends('admin.layouts.app')

@section('title', 'Pengaturan')

@section('styles')
<style>
/* Centered container matching the design */
.page-header { margin-bottom:18px }
.settings-container { max-width: 980px; margin: 0 auto }
.settings-row { display:flex; gap:20px; align-items:flex-start }
.left-col { flex:1 }
.card-box { background:#fff; border-radius:12px; padding:20px; box-shadow:0 10px 30px rgba(16,24,40,0.06); border:1px solid rgba(2,6,23,0.04) }
.sub-card { background:#fafafa; border-radius:10px; padding:18px; border:1px solid rgba(2,6,23,0.06); box-shadow: none }
.section-title { font-weight:700; margin-bottom:8px; font-size:15px }
.section-desc { color:#6b7280; font-size:13px; margin-bottom:12px }
.small-muted { color:#6b7280; font-size:13px }
.btn-primary-green { background: linear-gradient(180deg,#2fb148,#16a34a); color: #fff; border:none; padding:12px 20px; border-radius:9999px; font-weight:700; display:inline-block; box-shadow:0 6px 18px rgba(16,24,40,0.08) }
.btn-outline { background: #f3f4f6; border:1px solid rgba(2,6,23,0.04); padding:10px 12px; border-radius:8px; display:inline-block }
.backup-btn { border-radius:9999px; padding:8px 12px; display:flex; align-items:center; gap:10px; justify-content:flex-start; background:#f3f4f6; border:1px solid rgba(2,6,23,0.04); color:#111827 }
.backup-sub { padding:12px }
.form-select, .form-control { border-radius:9999px; padding:10px 14px; border:1px solid #e5e7eb; background:#f3f4f6 }
.form-select:focus, .form-control:focus { outline:none; box-shadow:0 0 0 3px rgba(34,197,94,0.08) }
.notif-col { width: 240px }
 .toggle { width:44px; height:24px; border-radius:9999px; background:#e6e9ec; position:relative; display:inline-block }
 .toggle input { display:none }
 .toggle .knob { position:absolute; left:3px; top:3px; width:18px; height:18px; border-radius:50%; background:#fff; box-shadow:0 1px 3px rgba(2,6,23,0.12); transition:left .12s ease, background .12s }
 .toggle input:checked + .knob { left:23px; background:#16a34a }
.sub-card .btn-primary-green { width:100% }
.settings-header-space { padding: 8px 0 18px }
@media (max-width: 992px) {
  .settings-container { padding: 0 12px }
  .notif-col { width: 100% }
}
</style>
@endsection

@section('content')
  <div class="container-fluid px-4">
  <div class="page-header">
    <h2 class="h3">Pengaturan</h2>
  </div>

  <div class="settings-container">
    <div class="settings-row">
      <div class="left-col">
        <div class="card-box">
          <div class="section-title">Manajemen Pengguna</div>
          <div class="section-desc">Kelola akses dan peran pengguna dalam sistem.</div>
          <div style="display:flex; gap:12px; margin-top:12px;">
            <div class="sub-card" style="flex:1; min-width:0">
              <div style="font-weight:700">Tambah Pengguna Baru</div>
              <div class="small-muted">Undang administrator atau anggota tim baru.</div>
              <div style="margin-top:12px" class="sub-actions"><a href="#" class="btn-primary-green">Tambah Pengguna</a></div>
            </div>
            <div class="sub-card" style="flex:1; min-width:0">
              <div style="font-weight:700">Lihat Log Aktivitas</div>
              <div class="small-muted">Lacak perubahan dan aktivitas penting pengguna.</div>
              <div style="margin-top:12px" class="sub-actions"><a href="#" class="btn-primary-green w-100">Lihat Log</a></div>
            </div>
          </div>
        </div>

        <div style="height:20px"></div>
        <div class="card-box">
          <div class="section-title">Preferensi Sistem</div>
          <div class="section-desc">Pilih bahasa default dan zona waktu aplikasi.</div>
          <div style="margin-top:12px; display:flex; flex-direction:column; gap:10px">
            <div style="display:flex; align-items:center; gap:12px">
              <div style="flex:1">
                <div style="font-weight:600">Bahasa Sistem</div>
                <div class="small-muted">Pilih bahasa default untuk aplikasi.</div>
              </div>
              <div style="width:240px">
                <div style="margin-top:6px"><select class="form-select" name="lang"><option>Bahasa Indonesia</option><option>English</option></select></div>
              </div>
            </div>
            <div style="border-top:1px solid #e5e7eb"></div>
            <div style="display:flex; align-items:center; gap:12px">
              <div style="flex:1">
                <div style="font-weight:600">Zona Waktu</div>
                <div class="small-muted">Pastikan semua data waktu ditampilkan dengan benar.</div>
              </div>
              <div style="width:240px">
                <div style="margin-top:6px"><select class="form-select" name="tz"><option>(UTC+07:00) Jakarta</option></select></div>
              </div>
            </div>
          </div>
        </div>

        <div style="height:20px"></div>

        <div class="card-box">
          <div style="display:flex; gap:16px; align-items:flex-start">
            <div style="flex:1">
              <div class="section-title">Data & Pencadangan</div>
              <div class="section-desc">Amankan data Anda dengan melakukan pencadangan secara berkala.</div>
              <div style="margin-top:12px; display:flex; flex-direction:column; gap:12px">
                <div class="sub-card backup-sub">
                  <div style="font-weight:700">Buat Cadangan Sekarang</div>
                  <div class="small-muted">Amankan data Anda dengan cadangan manual.</div>
                  <div style="margin-top:12px">
                    <button class="backup-btn w-100" type="button">
                      <span style="display:inline-flex; align-items:center; gap:10px">
                        <span style="width:24px; height:24px; display:inline-flex; align-items:center; justify-content:center; background:#eef2f4; border-radius:9999px; color:#6b7280">
                          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 3v9" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M21 15v2a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3v-2" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M7 10l5-5 5 5" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        </span>
                        <span>Buat Cadangan Sekarang</span>
                      </span>
                    </button>
                  </div>
                </div>

                <div class="sub-card backup-sub">
                  <div style="font-weight:700">Atur Jadwal Otomatis</div>
                  <div class="small-muted">Jadwalkan pencadangan berkala.</div>
                  <div style="margin-top:12px">
                    <button class="backup-btn w-100" type="button">
                      <span style="display:inline-flex; align-items:center; gap:10px">
                        <span style="width:24px; height:24px; display:inline-flex; align-items:center; justify-content:center; background:#eef2f4; border-radius:9999px; color:#6b7280">
                          <svg width="12" height="12" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M21 12.79A9 9 0 1 1 11.21 3" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M22 22v-6h-6" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                        </span>
                        <span>Atur Jadwal Otomatis</span>
                      </span>
                    </button>
                  </div>
                </div>
              </div>
            </div>
            <div style="width:340px">
              <div class="sub-card" style="padding:12px">
                <div style="font-weight:700">Notifikasi</div>
                <div class="small-muted">Pilih cara Anda menerima pembaruan sistem.</div>
                <div style="margin-top:12px; display:flex; flex-direction:column; gap:12px">
                  <div style="display:flex; justify-content:space-between; align-items:center">
                    <div><div style="font-weight:600">Notifikasi Email</div></div>
                    <label class="toggle"><input type="checkbox" checked /><span class="knob"></span></label>
                  </div>
                  <div style="display:flex; justify-content:space-between; align-items:center">
                    <div><div style="font-weight:600">Notifikasi Dalam Aplikasi</div></div>
                    <label class="toggle"><input type="checkbox" /><span class="knob"></span></label>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
  </div>
  @endsection