@extends('admin.layouts.app')

@section('title', 'Edit FAQ')

@section('content')
<div class="container-fluid py-4">
    <div class="row">
        <div class="col-md-8 mx-auto">
            <div class="card">
                <div class="card-header bg-warning text-white">
                    <h4 class="mb-0">Edit Chatbot FAQ #{{ $chatbotFaq->id }}</h4>
                </div>
                <div class="card-body">
                    <form action="{{ route('admin.chatbot-faqs.update', $chatbotFaq->id) }}" method="POST">
                        @csrf
                        @method('PUT')

                        <div class="mb-3">
                            <label for="category" class="form-label">Category <span class="text-danger">*</span></label>
                            <input type="text" 
                                   class="form-control @error('category') is-invalid @enderror" 
                                   id="category" 
                                   name="category" 
                                   value="{{ old('category', $chatbotFaq->category) }}"
                                   list="categoryList"
                                   required>
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
                        </div>

                        <div class="mb-3">
                            <label for="question" class="form-label">Question <span class="text-danger">*</span></label>
                            <textarea class="form-control @error('question') is-invalid @enderror" 
                                      id="question" 
                                      name="question" 
                                      rows="2" 
                                      required>{{ old('question', $chatbotFaq->question) }}</textarea>
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
                                      required>{{ old('answer', $chatbotFaq->answer) }}</textarea>
                            @error('answer')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>

                        <div class="mb-3">
                            <label for="keywords" class="form-label">Keywords <span class="text-danger">*</span></label>
                            <input type="text" 
                                   class="form-control @error('keywords') is-invalid @enderror" 
                                   id="keywords" 
                                   name="keywords" 
                                   value="{{ old('keywords', implode(', ', $chatbotFaq->keywords)) }}"
                                   required>
                            @error('keywords')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                            <small class="text-muted">Pisahkan dengan koma (,)</small>
                        </div>

                        <div class="mb-3">
                            <div class="form-check">
                                <input class="form-check-input" 
                                       type="checkbox" 
                                       id="is_active" 
                                       name="is_active" 
                                       value="1"
                                       {{ old('is_active', $chatbotFaq->is_active) ? 'checked' : '' }}>
                                <label class="form-check-label" for="is_active">
                                    Active (Visible to users)
                                </label>
                            </div>
                        </div>

                        <div class="alert alert-info">
                            <strong>Usage Statistics:</strong><br>
                            This FAQ has been used <strong>{{ $chatbotFaq->usage_count }}</strong> times.<br>
                            <small>Created: {{ $chatbotFaq->created_at->format('d M Y H:i') }}</small><br>
                            <small>Last Updated: {{ $chatbotFaq->updated_at->format('d M Y H:i') }}</small>
                        </div>

                        <div class="d-flex justify-content-between">
                            <a href="{{ route('admin.chatbot-faqs.index') }}" class="btn btn-secondary">
                                <i class="fas fa-arrow-left"></i> Back
                            </a>
                            <button type="submit" class="btn btn-warning">
                                <i class="fas fa-save"></i> Update FAQ
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
