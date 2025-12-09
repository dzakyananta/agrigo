@extends('admin.layouts.app')

@section('title', 'Add New FAQ')

@section('content')
<div class="container-fluid py-4">
    <div class="row">
        <div class="col-md-8 mx-auto">
            <div class="card">
                <div class="card-header bg-primary text-white">
                    <h4 class="mb-0">Add New Chatbot FAQ</h4>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.chatbot-faqs.store') }}" method="POST">
                        @csrf

                        <div class="mb-3">
                            <label for="category" class="form-label">Category <span class="text-danger">*</span></label>
                            <input type="text" 
                                   class="form-control @error('category') is-invalid @enderror" 
                                   id="category" 
                                   name="category" 
                                   value="{{ old('category') }}"
                                   list="categoryList"
                                   placeholder="e.g., Pertanian, Cuaca, Komoditas, Keuangan, Jadwal">
                            <datalist id="categoryList">
                                @foreach($categories as $cat)
                                    <option value="{{ $cat }}">
                                @endforeach
                                <option value="Pertanian">
                                <option value="Cuaca">
                                <option value="Komoditas">
                                <option value="Keuangan">
                                <option value="Jadwal">
                                <option value="Umum">
                            </datalist>
                            @error('category')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                            <small class="text-muted">Category untuk mengelompokkan FAQ</small>
                        </div>

                        <div class="mb-3">
                            <label for="question" class="form-label">Question <span class="text-danger">*</span></label>
                            <textarea class="form-control @error('question') is-invalid @enderror" 
                                      id="question" 
                                      name="question" 
                                      rows="2" 
                                      placeholder="Apa itu tanaman padi?"
                                      required>{{ old('question') }}</textarea>
                            @error('question')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label for="answer" class="form-label">Answer <span class="text-danger">*</span></label>
                            <textarea class="form-control @error('answer') is-invalid @enderror" 
                                      id="answer" 
                                      name="answer" 
                                      rows="5" 
                                      placeholder="Padi adalah tanaman makanan pokok yang menghasilkan beras..."
                                      required>{{ old('answer') }}</textarea>
                            @error('answer')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                            <small class="text-muted">Jawaban yang akan ditampilkan ke user</small>
                        </div>

                        <div class="mb-3">
                            <label for="keywords" class="form-label">Keywords <span class="text-danger">*</span></label>
                            <input type="text" 
                                   class="form-control @error('keywords') is-invalid @enderror" 
                                   id="keywords" 
                                   name="keywords" 
                                   value="{{ old('keywords') }}"
                                   placeholder="padi, tanaman padi, beras, rice"
                                   required>
                            @error('keywords')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                            <small class="text-muted">Pisahkan dengan koma (,) - untuk pencarian chatbot</small>
                        </div>

                        <div class="mb-3">
                            <div class="form-check">
                                <input class="form-check-input" 
                                       type="checkbox" 
                                       id="is_active" 
                                       name="is_active" 
                                       value="1"
                                       {{ old('is_active', true) ? 'checked' : '' }}>
                                <label class="form-check-label" for="is_active">
                                    Active (Visible to users)
                                </label>
                            </div>
                        </div>

                        <div class="d-flex justify-content-between">
                            <a href="{{ route('admin.chatbot-faqs.index') }}" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Back
                            </a>
                            <button type="submit" class="btn btn-primary">
                                <i class="fas fa-save"></i> Save FAQ
                            </button>
                        </div>
                    </form>
                </div>
            </div>

            <!-- Help Card -->
            <div class="card mt-3">
                <div class="card-header bg-info text-white">
                    <h6 class="mb-0">💡 Tips</h6>
                </div>
                <div class="card-body">
                    <ul class="mb-0">
                        <li><strong>Category:</strong> Gunakan kategori yang konsisten untuk grouping (Pertanian, Cuaca, dll)</li>
                        <li><strong>Keywords:</strong> Tambahkan variasi kata kunci agar chatbot mudah menemukan FAQ ini</li>
                        <li><strong>Question:</strong> Tulis pertanyaan seperti yang akan ditanyakan user</li>
                        <li><strong>Answer:</strong> Berikan jawaban yang jelas, informatif, dan mudah dipahami</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
