@extends('admin.layouts.app')
        <div class="card-box">
          <div style="display:flex; gap:16px; align-items:flex-start">
            <div style="flex:1">
              <div class="section-title">Data & Pencadangan</div>
              <div class="section-desc">Amankan data Anda dengan melakukan pencadangan secara berkala.</div>
              <div style="margin-top:12px; display:flex; flex-direction:column; gap:12px">
                <div class="sub-card">
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
                  <div>
                    <div style="font-weight:600">Notifikasi Email</div>
                  </div>
                  <label class="toggle">
                    <input type="checkbox" checked />
                    <span class="knob"></span>
                  </label>
                </div>

                <div style="display:flex; justify-content:space-between; align-items:center">
                  <div>
                    <div style="font-weight:600">Notifikasi Dalam Aplikasi</div>
                  </div>
                  <label class="toggle">
                    <input type="checkbox" />
                    <span class="knob"></span>
                  </label>
                </div>
              </div>
            </div>
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
          <div class="section-title">Data & Pencadangan</div>
          <div class="section-desc">Amankan data Anda dengan melakukan pencadangan secara berkala.</div>
          <div style="margin-top:12px; display:flex; flex-direction:column; gap:12px">
            <div class="sub-card">
              <div style="font-weight:700">Buat Cadangan Sekarang</div>
              <div class="small-muted">Amankan data Anda dengan cadangan manual.</div>
              <div style="margin-top:12px">
                <button class="backup-btn w-100" type="button">
                  <span style="display:inline-flex; align-items:center; gap:12px">
                    <span style="width:28px; height:28px; display:inline-flex; align-items:center; justify-content:center; background:#eef2f4; border-radius:9999px; color:#6b7280">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M12 3v9" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M21 15v2a3 3 0 0 1-3 3H6a3 3 0 0 1-3-3v-2" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M7 10l5-5 5 5" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </span>
                    <span>Buat Cadangan Sekarang</span>
                  </span>
                </button>
              </div>
            </div>

            <div class="sub-card">
              <div style="font-weight:700">Atur Jadwal Otomatis</div>
              <div class="small-muted">Jadwalkan pencadangan berkala.</div>
              <div style="margin-top:12px">
                <button class="backup-btn w-100" type="button">
                  <span style="display:inline-flex; align-items:center; gap:12px">
                    <span style="width:28px; height:28px; display:inline-flex; align-items:center; justify-content:center; background:#eef2f4; border-radius:9999px; color:#6b7280">
                      <svg width="14" height="14" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M21 12.79A9 9 0 1 1 11.21 3" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/><path d="M22 22v-6h-6" stroke="#6b7280" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
                    </span>
                    <span>Atur Jadwal Otomatis</span>
                  </span>
                </button>
              </div>
            </div>
          </div>
        </div>
                        </div>
