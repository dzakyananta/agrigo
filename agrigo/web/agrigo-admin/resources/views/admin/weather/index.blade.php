@extends('admin.layouts.app')

@section('title', 'Weather Data')
 
@section('styles')
<style>
    /* Scoped Weather styles to match design without affecting other pages */
    .weather-hero {
        border-radius: 18px;
        padding: 0;
        color: #ffffff;
        position: relative;
        overflow: hidden;
        width: 100%;
        /* keep the hero height fixed and allow it to grow wider horizontally */
        height: 390px; /* preserve the current vertical size */
        max-width: 760px; /* widened so the hero extends more to the right */
        display: block;
    }

    .weather-hero .hero-bg {
        position: relative;
        padding: 0; /* let content inside control spacing so image reaches edges */
        height: 100%;
        display: flex;
        gap: 18px;
        align-items: stretch;
        border-radius: 18px; /* match outer radius so image and container align */
        box-shadow: 0 12px 30px rgba(16,24,40,0.08);
        overflow: hidden;
    }

    /* background image layer and overlay to keep text legible */
    .weather-hero .hero-bg-img {
        position: absolute;
        inset: 0;
        width: 100%;
        height: 100%;
        object-fit: cover;
        object-position: center 48%; /* slightly below center so field shows */
        z-index: 1;
        filter: brightness(0.98) saturate(1.02);
        transform-origin: center center;
        transform: scale(1.0);
        border-radius: 18px; /* clip image to same rounded shape */
        -webkit-mask-image: linear-gradient(#000, #000); /* ensure clipping in some browsers */
    }
    .weather-hero .hero-overlay {
        position: absolute;
        inset: 0;
        z-index: 2;
        background: linear-gradient(180deg, rgba(3,7,18,0.32), rgba(3,7,18,0.06));
    }

    .hero-left { flex: 1; display:flex; flex-direction:column; justify-content:space-between; position:relative; z-index:3; padding:16px 22px }
    .hero-right-meta { width:160px; text-align:right; position:relative; z-index:3; padding-right:18px }

    .hero-location { font-size:30px; font-weight:800; color: #fff; text-shadow:0 2px 0 rgba(0,0,0,0.34); margin-bottom:6px }
    .hero-updated { font-size:13px; color: rgba(255,255,255,0.9) }
    .hero-temp { font-size:48px; font-weight:900; color:#fff; margin-top:6px; letter-spacing:0.4px; text-shadow:0 6px 18px rgba(3,7,18,0.4) }
    .hero-cond { font-size:16px; color: rgba(255,255,255,0.95); margin-top:6px; text-shadow:0 3px 8px rgba(3,7,18,0.4) }

    .hero-sub { font-size:13px; color: rgba(255,255,255,0.9); margin-top:6px }
    .hero-mini-icons { display:flex; gap:18px; margin-top:14px; align-items:center }
    .hero-mini-icons .mini { color: rgba(255,255,255,0.92); font-size:13px }
    .hero-mini-icons .mini .v { font-weight:700; display:block; font-size:14px }

    .hero-stats { display:flex; gap:18px; margin-top:18px; align-items:center }
    .hero-stat { background: rgba(255,255,255,0.08); padding:10px 12px; border-radius:10px; text-align:center; min-width:82px; box-shadow:none }
    .hero-stat .v { font-weight:700; color:#fff }
    .hero-stat .k { font-size:12px; color: rgba(255,255,255,0.9) }

    .hero-icon { position:absolute; right:20px; top:18px; background: rgba(255,255,255,0.10); width:54px; height:54px; border-radius:12px; display:flex; align-items:center; justify-content:center; color:#fff; font-size:20px; z-index:3 }
    .updated-badge { position:absolute; right:20px; bottom:18px; background: rgba(255,255,255,0.92); color:#0f172a; padding:7px 12px; border-radius:12px; font-size:12px; z-index:3; font-weight:700; box-shadow:0 6px 18px rgba(2,6,23,0.09) }

    /* Updated small badge */
    .updated-badge { background: rgba(255,255,255,0.16); color:#fff; padding:6px 10px; border-radius:10px; font-size:12px }

    /* mini summary list inside hero (matches region cards below) */
    .hero-mini-list { display:flex; gap:10px; margin-top:12px }
    .hero-mini-item { background: rgba(255,255,255,0.06); padding:8px 10px; border-radius:8px; min-width:90px; text-align:left }
    .hero-mini-item .loc { font-size:12px; color: rgba(255,255,255,0.95); font-weight:700 }
    .hero-mini-item .t { font-size:16px; font-weight:800; color:#fff; margin-top:6px }

    .alerts-panel { background: #fff; border-radius: 12px; padding: 14px; box-shadow: 0 6px 18px rgba(16,24,40,0.06);} 
    .alerts-panel h6 { margin:0 0 8px 0; font-weight:700 }
    .alerts-panel .panel-title { display:flex; align-items:center; gap:10px; margin-bottom:10px }
    .alerts-panel .panel-title i { color:#f59e0b }

    .alert-badge { display:flex; gap:12px; padding:12px; border-radius:10px; margin-bottom:10px; align-items:flex-start }
    .alert-badge .marker { width:8px; height:40px; border-radius:6px; flex-shrink:0 }
    .alert-danger { background:#fff5f5; border:1px solid #fecaca }
    .alert-danger .marker { background: linear-gradient(180deg,#fca5a5,#fecaca) }
    .alert-warn { background:#fff7ed; border:1px solid #fed7aa }
    .alert-warn .marker { background: linear-gradient(180deg,#fed7aa,#ffd29a) }
    .alert-info { background:#eff6ff; border:1px solid #bfdbfe }
    .alert-info .marker { background: linear-gradient(180deg,#bfdbfe,#93c5fd) }
    .alert-badge .content { flex:1 }
    .alert-badge .title { font-weight:700; margin-bottom:4px }
    .alert-badge .desc { font-size:13px; color:#6b7280 }

    .region-card { background:#fff; border-radius:16px; padding:20px; box-shadow:0 14px 30px rgba(16,24,40,0.06); position:relative; min-height:220px; border:1px solid rgba(15,23,42,0.04); }
    .region-card .title { font-weight:800; font-size:16px; }
    .region-card .region-top { display:flex; justify-content:space-between; align-items:flex-start }
    .region-card .region-left { flex:1 }
    .region-card .region-temp { font-size:40px; font-weight:800; color:#111827; margin-top:8px }
    .region-card .region-sub { font-size:13px; color:#6b7280; margin-top:6px }
    .region-card .icon-circle { position:absolute; right:18px; top:8px; width:64px; height:64px; border-radius:14px; display:flex; align-items:center; justify-content:center; background:transparent; box-shadow:none; color:#fff; z-index:3 }
    .card-decor { position:absolute; right:12px; top:-18px; width:88px; height:88px; border-radius:20px; display:flex; align-items:center; justify-content:center; box-shadow:0 18px 40px rgba(16,24,40,0.08); z-index:2; overflow:hidden }
    .card-decor-img { width:100%; height:100%; object-fit:cover; display:block }
    .card-decor i { display:none }
    .icon-circle i { display:none }
    /* ensure the visible icon is the one inside .card-decor via pseudo layering */
    /* use clean white background and subtle border so SVG icons remain visible */
    .card-decor { background: #fff; border:1px solid rgba(15,23,42,0.04); }
    .card-decor-sun { background: #fff }
    .card-decor-cloud { background: #fff }
    .card-decor-rain { background: #fff }
    .card-decor-img { width:70%; height:70%; object-fit:contain; display:block; margin:auto }
    .region-meta { font-size:13px; color:#6b7280 }
    .region-stats { display:flex; gap:12px; justify-content:flex-start; margin-top:12px; font-size:13px; color:#6b7280 }
    .region-stat { background:#f8fafc; padding:8px 10px; border-radius:8px; min-width:72px; text-align:left }
    .region-next { display:flex; justify-content:space-between; align-items:center; margin-top:12px }
    .status-chip { padding:6px 10px; border-radius:999px; font-weight:700; font-size:12px }

    @media (max-width: 992px) {
        .hero-right-meta { width:120px }
        .weather-hero .hero-bg { flex-direction:column; gap:12px }
    }
    .tinjauan-row { margin-top: 8px }
    .tinjauan-row .col-md-4 { display:flex }
    .tinjauan-row .region-card { flex:1 }
</style>
@endsection
@section('content')
<div class="container-fluid px-4">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <div>
            <h2 class="h3 mb-1">Regional Weather</h2>
            <div class="text-muted">Monitoring conditions for agricultural zones</div>
        </div>
        <div style="width:320px">
            <input type="text" class="form-control" placeholder="Search region..." style="border-radius:12px; padding:10px 14px;" />
        </div>
    </div>

    {{-- User filter and compact weather preview like design --}}
    <div class="row mb-4">
        <div class="col-md-8">
            <form method="GET" action="{{ route('admin.weather.index') }}" class="d-flex gap-2">
                <select name="user_id" class="form-select w-auto">
                    <option value="">Semua Pengguna</option>
                    @foreach($users as $u)
                        <option value="{{ $u->id }}" {{ isset($queryUserId) && $queryUserId == $u->id ? 'selected' : '' }}>{{ $u->name }}</option>
                    @endforeach
                </select>
                <button class="btn btn-secondary" type="submit">Filter</button>
            </form>
        </div>
    </div>

    {{-- Top design-like weather card area (updated to match design) --}}
    <div class="row mb-4">
        <div class="col-lg-9">
            @php
                $item = $weatherData->first() ?? (object) [
                    'location' => 'Jawa Barat HQ',
                    'date' => null,
                    'temperature' => 24,
                    'weather_condition' => 'Partly Cloudy',
                    'humidity' => 78,
                    'wind_speed' => '12',
                    'rainfall' => 0,
                    'zone' => 'Bandung, Indonesia'
                ];
            @endphp
            <div class="weather-hero">
                <div class="hero-bg">
                    <img class="hero-bg-img" src="/images/weather-landscape-2.svg" alt="weather background">
                    <div class="hero-overlay" aria-hidden="true"></div>
                    <div class="hero-left">
                        <div>
                            <div class="hero-location">{{ $item->location }}</div>
                            <div class="hero-sub">{{ $item->zone ?? 'Vegetable Zone A' }}</div>
                        </div>
                        <div>
                            <div style="display:flex; align-items:flex-start; gap:20px">
                                <div>
                                    <div class="hero-temp">{{ $item->temperature }}°</div>
                                    <div class="hero-cond">{{ $item->weather_condition }}</div>
                                </div>
                                <div style="margin-left:auto; text-align:right">
                                    <div class="hero-icon"><i class="fas fa-cloud-sun"></i></div>
                                </div>
                            </div>

                            <div class="hero-mini-icons">
                                <div class="mini"><span class="v">{{ $item->temperature }}°</span><small>Temp</small></div>
                                <div class="mini"><span class="v">{{ $item->humidity }}%</span><small>Hum</small></div>
                                <div class="mini"><span class="v">{{ $item->wind_speed }} km/h</span><small>Wind</small></div>
                            </div>
                        </div>
                    </div>
                    <div class="hero-right-meta">
                        <div class="hero-icon"><i class="fas fa-cloud-sun"></i></div>
                        <div class="updated-badge">{{ $item->date ? \Carbon\Carbon::parse($item->date)->diffForHumans() : 'Updated 5m ago' }}</div>
                    </div>
                </div>
            </div>
        </div>

        <div class="col-lg-3">
            <div class="d-flex flex-column gap-3">
                <div class="alerts-panel">
                    {{-- search moved to page header for design parity --}}
                    <div>
                        <div class="panel-title">
                            <i class="fas fa-exclamation-triangle"></i>
                            <h6 class="mb-0">Weather Alerts</h6>
                        </div>
                        @if(isset($alerts) && count($alerts))
                            @foreach($alerts as $a)
                                <div class="alert-badge {{ $a['type'] == 'danger' ? 'alert-danger' : ($a['type'] == 'warn' ? 'alert-warn' : 'alert-info') }}">
                                    <div class="marker"></div>
                                    <div class="content">
                                        <div class="title">{{ $a['title'] }}</div>
                                        <div class="desc">Region: {{ $a['region'] ?? '-' }}</div>
                                    </div>
                                </div>
                            @endforeach
                        @else
                            <div class="alert-badge alert-danger">
                                <div class="marker"></div>
                                <div class="content">
                                    <div class="title">Heavy Rainfall Warning</div>
                                    <div class="desc">Region: Garut Selatan. Expected &gt;50mm in next 3h.</div>
                                </div>
                            </div>
                            <div class="alert-badge alert-warn">
                                <div class="marker"></div>
                                <div class="content">
                                    <div class="title">High Wind Advisory</div>
                                    <div class="desc">Region: Lembang Highlands. Gusts up to 45km/h.</div>
                                </div>
                            </div>
                            <div class="alert-badge alert-info">
                                <div class="marker"></div>
                                <div class="content">
                                    <div class="title">Frost Potential</div>
                                    <div class="desc">Region: Dieng Plateau. Prepare coverings.</div>
                                </div>
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>

    {{-- Tinjauan Wilayah — full width centered cards (moved out from sidebar) --}}
    <div class="row mb-4">
        <div class="col-12">
            <h6 class="mb-3">Tinjauan Wilayah</h6>
            <div class="row g-4 tinjauan-row justify-content-center">
                @if($weatherData->count() > 0)
                    @foreach($weatherData->take(3) as $w)
                        <div class="col-md-4">
                            <div class="region-card text-start">
                                <div class="region-top">
                                    <div class="region-left">
                                        <div class="title">{{ $w->location }}</div>
                                        <div class="region-sub">{{ $w->weather_condition ?? $w->condition ?? '' }}</div>
                                    </div>
                                    @php
                                        $cond = strtolower((string)($w->weather_condition ?? $w->condition ?? ''));
                                        $icon = 'fa-sun';
                                        $decor = 'sun';
                                        if (strpos($cond, 'cloud') !== false || strpos($cond, 'overcast') !== false) {
                                            $icon = 'fa-cloud';
                                            $decor = 'cloud';
                                        } elseif (strpos($cond, 'rain') !== false || strpos($cond, 'storm') !== false || strpos($cond, 'shower') !== false) {
                                            $icon = 'fa-cloud-showers-heavy';
                                            $decor = 'rain';
                                        }
                                    @endphp
                                                <div class="icon-circle">
                                                    <div class="card-decor card-decor-{{ $decor }}">
                                                        <img src="/images/weather-{{ $decor }}.svg" class="card-decor-img" alt="">
                                                    </div>
                                                </div>
                                </div>

                                <div style="display:flex; align-items:flex-start; gap:12px; margin-top:10px">
                                    <div style="flex:0 0 90px;">
                                        <div class="region-temp">{{ $w->temperature ?? $w->temp ?? '28' }}°</div>
                                    </div>
                                    <div style="flex:1">
                                        <div class="region-stats">
                                            <div class="region-stat">Wind<br><strong>{{ $w->wind_speed ?? $w->wind_kmh ?? '-' }} km/h</strong></div>
                                            <div class="region-stat">Hum<br><strong>{{ $w->humidity ?? '-' }}%</strong></div>
                                            <div class="region-stat">Rain<br><strong>{{ $w->rainfall ?? $w->rain_prob ?? 0 }}%</strong></div>
                                        </div>
                                    </div>
                                </div>

                                <div class="region-next">
                                    <div class="text-muted">Next 3h: {{ $w->next_desc ?? 'Clear' }}</div>
                                    @php
                                        $risk = ($w->rainfall ?? $w->rain_prob ?? 0) > 30 ? 'danger' : ((($w->rainfall ?? $w->rain_prob ?? 0) > 10) ? 'warn' : 'ok');
                                    @endphp
                                    <div>
                                        @if($risk == 'danger')
                                            <span class="status-chip" style="background:#FEE2E2;color:#9b1c1c">Risk</span>
                                        @elseif($risk == 'warn')
                                            <span class="status-chip" style="background:#FEF3C7;color:#92400e">Caution</span>
                                        @else
                                            <span class="status-chip" style="background:#D1FAE5;color:#065f46">Optimal</span>
                                        @endif
                                    </div>
                                </div>
                            </div>
                        </div>
                    @endforeach
                @else
                    {{-- show sample placeholders when no data present to preserve layout --}}
                    <div class="col-md-4">
                        <div class="region-card">
                            <div class="region-top">
                                <div class="region-left">
                                    <div class="title">Lembang</div>
                                    <div class="region-sub">Vegetable Zone A</div>
                                </div>
                                        <div class="icon-circle">
                                            <div class="card-decor card-decor-sun"><img src="/images/weather-sun.svg" class="card-decor-img" alt="sun"></div>
                                        </div>
                            </div>
                            <div style="display:flex; align-items:flex-start; gap:12px; margin-top:10px">
                                <div style="flex:0 0 90px;">
                                    <div class="region-temp">28°</div>
                                </div>
                                <div style="flex:1">
                                    <div class="region-stats">
                                        <div class="region-stat">Wind<br><strong>8 km/h</strong></div>
                                        <div class="region-stat">Hum<br><strong>65%</strong></div>
                                        <div class="region-stat">Rain<br><strong>0%</strong></div>
                                    </div>
                                </div>
                            </div>
                            <div class="region-next">
                                <div class="text-muted">Next 3h: Clear</div>
                                <div><span class="status-chip" style="background:#D1FAE5;color:#065f46">Optimal</span></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="region-card">
                            <div class="region-top">
                                <div class="region-left">
                                    <div class="title">Ciwidey</div>
                                    <div class="region-sub">Strawberry Fields</div>
                                </div>
                                        <div class="icon-circle">
                                            <div class="card-decor card-decor-cloud"><img src="/images/weather-cloud.svg" class="card-decor-img" alt="cloud"></div>
                                        </div>
                            </div>
                            <div style="display:flex; align-items:flex-start; gap:12px; margin-top:10px">
                                <div style="flex:0 0 90px;">
                                    <div class="region-temp">22°</div>
                                </div>
                                <div style="flex:1">
                                    <div class="region-stats">
                                        <div class="region-stat">Wind<br><strong>14 km/h</strong></div>
                                        <div class="region-stat">Hum<br><strong>82%</strong></div>
                                        <div class="region-stat">Rain<br><strong>10%</strong></div>
                                    </div>
                                </div>
                            </div>
                            <div class="region-next">
                                <div class="text-muted">Next 3h: Light Drizzle</div>
                                <div><span class="status-chip" style="background:#FEF3C7;color:#92400e">Caution</span></div>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-4">
                        <div class="region-card">
                            <div class="region-top">
                                <div class="region-left">
                                    <div class="title">Pangalengan</div>
                                    <div class="region-sub">Tea Plantation</div>
                                </div>
                                <div class="icon-circle">
                                    <div class="card-decor card-decor-rain"><img src="/images/weather-rain.svg" class="card-decor-img" alt="rain"></div>
                                </div>
                            </div>
                            <div style="display:flex; align-items:flex-start; gap:12px; margin-top:10px">
                                <div style="flex:0 0 90px;">
                                    <div class="region-temp">19°</div>
                                </div>
                                <div style="flex:1">
                                    <div class="region-stats">
                                        <div class="region-stat">Wind<br><strong>25 km/h</strong></div>
                                        <div class="region-stat">Hum<br><strong>95%</strong></div>
                                        <div class="region-stat">Rain<br><strong>90%</strong></div>
                                    </div>
                                </div>
                            </div>
                            <div class="region-next">
                                <div class="text-muted">Next 3h: Heavy Rain</div>
                                <div><span class="status-chip" style="background:#FEE2E2;color:#9b1c1c">Risk</span></div>
                            </div>
                        </div>
                    </div>
                @endif
            </div>
        </div>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    @endif
</div>
@endsection
