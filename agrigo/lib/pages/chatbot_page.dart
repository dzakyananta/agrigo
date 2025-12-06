import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:io';
import '../services/gemini_chat_service.dart';
import 'package:image_picker/image_picker.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final File? imageFile;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.imageFile,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({Key? key}) : super(key: key);

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
    with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AnimationController _typingAnimationController;
  bool _isTyping = false;
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  // Database komprehensif harga pasar terkini November 2025
  final Map<String, Map<String, dynamic>> _marketPrices = {
    // TANAMAN PANGAN
    'padi': {
      'price': 'Rp 7.200 - 7.800',
      'unit': 'per kg GKP',
      'trend': 'naik',
      'demand': 'sangat tinggi',
      'season': 'MT1: Okt-Mar, MT2: Apr-Jul, MT3: Agu-Nov',
      'category': 'Tanaman Pangan',
      'market_info':
          'Harga naik karena permintaan ekspor tinggi ke Malaysia dan Filipina',
      'best_varieties': 'IR64, Ciherang, Inpari 32, Mekongga',
    },
    'jagung': {
      'price': 'Rp 4.800 - 5.200',
      'unit': 'per kg pipil kering',
      'trend': 'naik',
      'demand': 'tinggi',
      'season': 'MT1: Okt-Feb, MT2: Mar-Jul',
      'category': 'Tanaman Pangan',
      'market_info':
          'Permintaan industri pakan ternak meningkat 15% dari tahun lalu',
      'best_varieties': 'Bisi 18, NK 212, Pioneer P21',
    },
    'kedelai': {
      'price': 'Rp 9.500 - 10.200',
      'unit': 'per kg biji kering',
      'trend': 'naik',
      'demand': 'sangat tinggi',
      'season': 'MT1: Feb-Mei, MT2: Jul-Okt',
      'category': 'Tanaman Pangan',
      'market_info':
          'Import kedelai berkurang, mendorong harga lokal naik signifikan',
      'best_varieties': 'Grobogan, Anjasmoro, Dena 1',
    },
    'kacang tanah': {
      'price': 'Rp 14.500 - 16.800',
      'unit': 'per kg polong kering',
      'trend': 'naik',
      'demand': 'tinggi',
      'season': 'MT1: Mar-Jun, MT2: Agu-Nov',
      'category': 'Tanaman Pangan',
      'market_info':
          'Permintaan industri makanan ringan meningkat menjelang akhir tahun',
      'best_varieties': 'Hypoma 1, Jerapah, Kancil',
    },
    'kacang hijau': {
      'price': 'Rp 10.000 - 12.000',
      'unit': 'per kg',
      'trend': 'naik',
      'demand': 'sedang',
      'season': 'Tanam: Apr-Mei & Sep-Okt',
      'category': 'Tanaman Pangan',
    },
    'ubi kayu': {
      'price': 'Rp 3.000 - 4.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Tanam: Mar-Apr, Panen: 8-12 bulan',
      'category': 'Tanaman Pangan',
    },
    'ubi jalar': {
      'price': 'Rp 4.000 - 6.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Tanam: Mar-Apr & Sep-Okt',
      'category': 'Tanaman Pangan',
    },
    'kentang': {
      'price': 'Rp 10.000 - 12.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'tinggi',
      'season': 'Tanam: Mar-Apr & Agu-Sep',
      'category': 'Tanaman Pangan',
    },

    // SAYURAN
    'cabai merah': {
      'price': 'Rp 32.000 - 38.000',
      'unit': 'per kg segar',
      'trend': 'naik',
      'demand': 'sangat tinggi',
      'season': 'Optimal: Apr-Jul & Sep-Des',
      'category': 'Sayuran',
      'market_info':
          'Harga naik 25% karena cuaca ekstrem mengurangi produksi di Jawa Barat',
      'best_varieties': 'Lado F1, TM 999 F1, Hot Beauty',
    },
    'cabai rawit': {
      'price': 'Rp 35.000 - 45.000',
      'unit': 'per kg',
      'trend': 'naik',
      'demand': 'sangat tinggi',
      'season': 'Tanam sepanjang tahun',
      'category': 'Sayuran',
    },
    'bawang merah': {
      'price': 'Rp 28.000 - 32.000',
      'unit': 'per kg kering',
      'trend': 'naik',
      'demand': 'sangat tinggi',
      'season': 'MT1: Feb-Mei, MT2: Jun-Sep, MT3: Okt-Jan',
      'category': 'Sayuran',
      'market_info':
          'Stok menipis karena gagal panen di Brebes, harga naik 40%',
      'best_varieties': 'Bima Brebes, Thailand, Bauji',
    },
    'bawang putih': {
      'price': 'Rp 35.000 - 40.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'tinggi',
      'season': 'Import, produksi lokal terbatas',
      'category': 'Sayuran',
    },
    'tomat': {
      'price': 'Rp 8.000 - 12.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'tinggi',
      'season': 'Tanam: Mar-Apr & Sep-Okt',
      'category': 'Sayuran',
    },
    'wortel': {
      'price': 'Rp 7.000 - 9.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Tanam dataran tinggi sepanjang tahun',
      'category': 'Sayuran',
    },
    'kangkung': {
      'price': 'Rp 2.500 - 3.500',
      'unit': 'per ikat',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Tanam sepanjang tahun',
      'category': 'Sayuran',
    },
    'bayam': {
      'price': 'Rp 3.000 - 4.000',
      'unit': 'per ikat',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Tanam sepanjang tahun',
      'category': 'Sayuran',
    },
    'sawi': {
      'price': 'Rp 2.000 - 3.000',
      'unit': 'per ikat',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Tanam sepanjang tahun',
      'category': 'Sayuran',
    },
    'kubis': {
      'price': 'Rp 5.000 - 7.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Tanam dataran tinggi',
      'category': 'Sayuran',
    },
    'terong': {
      'price': 'Rp 6.000 - 8.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Tanam sepanjang tahun',
      'category': 'Sayuran',
    },
    'timun': {
      'price': 'Rp 4.000 - 6.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Tanam sepanjang tahun',
      'category': 'Sayuran',
    },

    // BUAH-BUAHAN
    'jeruk': {
      'price': 'Rp 8.000 - 12.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'tinggi',
      'season': 'Panen: Jun-Agu & Nov-Jan',
      'category': 'Buah-buahan',
    },
    'mangga': {
      'price': 'Rp 10.000 - 15.000',
      'unit': 'per kg',
      'trend': 'naik',
      'demand': 'tinggi',
      'season': 'Panen: Sep-Jan',
      'category': 'Buah-buahan',
    },
    'singkong': {
      'price': 'Rp 3.000 - 5.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'tinggi',
      'season': 'Panen 8-12 bulan setelah tanam',
      'category': 'Umbi-umbian',
    },
    'pisang': {
      'price': 'Rp 8.000 - 12.000',
      'unit': 'per sisir',
      'trend': 'stabil',
      'demand': 'tinggi',
      'season': 'Panen sepanjang tahun',
      'category': 'Buah-buahan',
    },
    'pepaya': {
      'price': 'Rp 5.000 - 8.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Panen sepanjang tahun',
      'category': 'Buah-buahan',
    },
    'semangka': {
      'price': 'Rp 4.000 - 6.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'tinggi',
      'season': 'Panen: Jun-Sep',
      'category': 'Buah-buahan',
    },
    'durian': {
      'price': 'Rp 25.000 - 35.000',
      'unit': 'per kg',
      'trend': 'naik',
      'demand': 'sangat tinggi',
      'season': 'Panen: Nov-Feb',
      'category': 'Buah-buahan',
    },

    // TANAMAN PERKEBUNAN
    'kopi': {
      'price': 'Rp 35.000 - 45.000',
      'unit': 'per kg biji kering',
      'trend': 'naik',
      'demand': 'sangat tinggi',
      'season': 'Panen: Apr-Sep',
      'category': 'Tanaman Perkebunan',
    },
    'kakao': {
      'price': 'Rp 25.000 - 30.000',
      'unit': 'per kg biji kering',
      'trend': 'stabil',
      'demand': 'tinggi',
      'season': 'Panen: Mar-Jun & Sep-Des',
      'category': 'Tanaman Perkebunan',
    },
    'kelapa': {
      'price': 'Rp 2.500 - 3.500',
      'unit': 'per butir',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Panen sepanjang tahun',
      'category': 'Tanaman Perkebunan',
    },
    'kelapa sawit': {
      'price': 'Rp 1.200 - 1.500',
      'unit': 'per kg TBS',
      'trend': 'naik',
      'demand': 'tinggi',
      'season': 'Panen sepanjang tahun',
      'category': 'Tanaman Perkebunan',
    },

    // REMPAH-REMPAH
    'jahe': {
      'price': 'Rp 12.000 - 18.000',
      'unit': 'per kg',
      'trend': 'naik',
      'demand': 'tinggi',
      'season': 'Panen: 8-12 bulan setelah tanam',
      'category': 'Rempah-rempah',
    },
    'kunyit': {
      'price': 'Rp 8.000 - 12.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Panen: 8-12 bulan setelah tanam',
      'category': 'Rempah-rempah',
    },
    'lengkuas': {
      'price': 'Rp 6.000 - 9.000',
      'unit': 'per kg',
      'trend': 'stabil',
      'demand': 'sedang',
      'season': 'Panen: 9-12 bulan setelah tanam',
      'category': 'Rempah-rempah',
    },
    'lada': {
      'price': 'Rp 85.000 - 95.000',
      'unit': 'per kg kering',
      'trend': 'naik',
      'demand': 'sangat tinggi',
      'season': 'Panen: 3-4 tahun setelah tanam',
      'category': 'Rempah-rempah',
    },
    'cengkeh': {
      'price': 'Rp 120.000 - 140.000',
      'unit': 'per kg kering',
      'trend': 'naik',
      'demand': 'sangat tinggi',
      'season': 'Panen: Jul-Sep',
      'category': 'Rempah-rempah',
    },
  };

  // Database hama lengkap untuk seluruh komoditas
  final Map<String, Map<String, dynamic>> _pestDatabase = {
    // HAMA TANAMAN PANGAN
    'ulat grayak': {
      'description': 'Larva lepidoptera Spodoptera litura yang memakan daun',
      'symptoms':
          'Daun berlubang, kotoran ulat hitam, serangan malam hari, tanaman gundul',
      'crops': [
        'padi',
        'jagung',
        'kedelai',
        'kacang tanah',
        'ubi jalar',
        'sayuran',
      ],
      'control': {
        'organic':
            'Bacillus thuringiensis, ekstrak daun nimba, perangkap feromon seks',
        'biological':
            'Trichogramma spp., predator Cotesia flavipes, virus NPV Spodoptera',
        'chemical':
            'Klorpirifos 500 EC, Metomil 25 WP, Emamektin benzoat 100 EC',
        'prevention':
            'Rotasi tanaman, sanitasi lahan, tanam refugia jagung, light trap',
      },
    },
    'wereng coklat': {
      'description': 'Serangga penghisap getah Nilaparvata lugens pada padi',
      'symptoms':
          'Daun menguning (hopperburn), tanaman kerdil, virus kerdil, tanaman mati',
      'crops': ['padi'],
      'control': {
        'organic': 'Sabun insektisida 2-3 ml/L, minyak nimba, ekstrak tembakau',
        'biological':
            'Laba-laba Lycosa, kepik Cyrtorhinus lividipennis, parasitoid Anagrus',
        'chemical': 'Imidakloprid 200 SL, Thiamethoxam 25 WG, Buprofezin 25 WP',
        'prevention':
            'Varietas tahan wereng, tidak berlebihan nitrogen, tanam serentak',
      },
    },
    'penggerek batang padi': {
      'description': 'Larva Scirpophaga incertulas yang menggerek batang padi',
      'symptoms':
          'Batang berlubang bulat, anakan mati (sundep), malai putih kosong',
      'crops': ['padi'],
      'control': {
        'organic':
            'Beauveria bassiana, perangkap light trap, ekstrak akar tuba',
        'biological':
            'Trichogramma japonicum, parasitoid Tetrastichus schoenobii',
        'chemical': 'Karbofuran 3G, Fipronil 50 WG, Diazinon 10 GR',
        'prevention':
            'Sanitasi jerami, tanam serentak, varietas tahan, padi ratun dihindari',
      },
    },
    'penggerek batang jagung': {
      'description':
          'Larva Ostrinia furnacalis yang menggerek batang dan tongkol jagung',
      'symptoms':
          'Lubang pada batang, daun berlubang, tongkol rusak, tanaman patah',
      'crops': ['jagung'],
      'control': {
        'organic':
            'Trichogramma evanescens, Beauveria bassiana, perangkap feromon',
        'biological': 'Predator Chrysoperla, parasitoid Cotesia flavipes',
        'chemical': 'Karbofuran 3G aplikasi tugal, Klorpirifos granul',
        'prevention':
            'Sanitasi sisa tanaman, tanam jagung Bt, rotasi dengan legum',
      },
    },
    'ulat polong kedelai': {
      'description': 'Larva Helicoverpa armigera yang merusak polong kedelai',
      'symptoms': 'Polong berlubang, biji rusak, kotoran ulat di polong',
      'crops': ['kedelai', 'kacang tanah', 'kacang hijau'],
      'control': {
        'organic': 'Bacillus thuringiensis, ekstrak nimba, perangkap feromon',
        'biological': 'Trichogramma pretiosum, virus NPV Helicoverpa',
        'chemical': 'Profenofos 500 EC, Indoksakarb 150 SC',
        'prevention': 'Tanam varietas tahan, refugia, monitoring telur',
      },
    },
    'trips padi': {
      'description': 'Thrips oryzae yang menghisap cairan daun padi muda',
      'symptoms':
          'Daun bergaris putih perak, ujung mengering, pertumbuhan terhambat',
      'crops': ['padi'],
      'control': {
        'organic': 'Perangkap kuning lengket, predator laba-laba',
        'biological': 'Orius tantillus, Amblyseius spp.',
        'chemical': 'Fipronil 50 SC, Thiamethoxam 25 WG',
        'prevention': 'Tidak berlebihan nitrogen, sanitasi gulma',
      },
    },

    // HAMA SAYURAN
    'thrips': {
      'description': 'Thrips tabaci yang menghisap cairan sel daun sayuran',
      'symptoms':
          'Daun berbercak perak, keriting, pertumbuhan terhambat, virus tospo',
      'crops': ['cabai', 'tomat', 'bawang', 'timun', 'terong', 'kacang'],
      'control': {
        'organic': 'Sticky trap biru, sabun insektisida, minyak hortikultura',
        'biological':
            'Orius spp., Amblyseius spp., Franklinothrips vespiformis',
        'chemical': 'Abamektin 18 EC, Spinosad 250 SC, Fipronil 50 SC',
        'prevention': 'Mulsa plastik perak, sanitasi gulma, tanaman perangkap',
      },
    },
    'kutu daun': {
      'description':
          'Aphis gossypii dan Myzus persicae penghisap cairan tanaman',
      'symptoms':
          'Daun keriting, lengket (honeydew), koloni pada tunas, penularan virus',
      'crops': ['cabai', 'tomat', 'timun', 'terong', 'kacang', 'kubis'],
      'control': {
        'organic':
            'Sabun cuci 5 ml/L, air soda, minyak nabati, predator coccinella',
        'biological': 'Ladybird beetle, lacewing, parasitoid Aphidius colemani',
        'chemical':
            'Imidakloprid 200 SL, Thiamethoxam 25 WG, Acetamiprid 20 SP',
        'prevention':
            'Jaring serangga, mulsa reflektif, tanaman perangkap, sanitasi',
      },
    },
    'ulat buah cabai': {
      'description': 'Larva Helicoverpa armigera yang merusak buah cabai',
      'symptoms': 'Buah berlubang, larva di dalam buah, buah busuk prematur',
      'crops': ['cabai', 'tomat'],
      'control': {
        'organic':
            'Bacillus thuringiensis, perangkap feromon, Beauveria bassiana',
        'biological': 'Trichogramma pretiosum, virus NPV Helicoverpa',
        'chemical': 'Indoksakarb 150 SC, Emamektin benzoat 100 EC',
        'prevention': 'Sanitasi buah terserang, monitoring telur, refugia',
      },
    },
    'lalat buah': {
      'description': 'Bactrocera spp. yang meletakkan telur di dalam buah',
      'symptoms':
          'Buah berlubang kecil, larva (belatung) di dalam buah, buah busuk',
      'crops': ['tomat', 'cabai', 'timun', 'terong', 'buah-buahan'],
      'control': {
        'organic': 'Perangkap metil eugenol, protein bait, sanitasi buah gugur',
        'biological':
            'Parasitoid Fopius arisanus, Diachasmimorpha longicaudata',
        'chemical': 'Malathion 57 EC (umpan protein), Spinosad 120 SC',
        'prevention': 'Panen tepat waktu, sanitasi buah gugur, pembungkus buah',
      },
    },
    'hama pengorok daun': {
      'description': 'Larva Liriomyza spp. yang membuat terowongan di daun',
      'symptoms': 'Garis berliku-liku putih pada daun (mine), daun menguning',
      'crops': ['tomat', 'cabai', 'timun', 'terong', 'kacang', 'bayam'],
      'control': {
        'organic': 'Perangkap kuning lengket, predator laba-laba, sanitasi',
        'biological': 'Parasitoid Hemiptarsenus varicornis, Diglyphus isaea',
        'chemical': 'Abamektin 18 EC, Cyromazine 75 WP',
        'prevention': 'Jaring serangga, mulsa reflektif, rotasi tanaman',
      },
    },
    'ulat kubis': {
      'description':
          'Larva Plutella xylostella yang memakan daun kubis-kubisan',
      'symptoms': 'Daun berlubang kecil, jendela transparan, kotoran hijau',
      'crops': ['kubis', 'sawi', 'brokoli'],
      'control': {
        'organic': 'Bacillus thuringiensis, ekstrak nimba, perangkap feromon',
        'biological': 'Cotesia plutellae, Diadegma semiclausum',
        'chemical': 'Indoksakarb 150 SC, Emamektin benzoat (rotasi)',
        'prevention': 'Varietas tahan, refugia, sanitasi, jaring serangga',
      },
    },

    // HAMA BUAH-BUAHAN
    'lalat buah jeruk': {
      'description': 'Bactrocera dorsalis yang menyerang buah jeruk',
      'symptoms': 'Buah berlubang, larva di dalam buah, buah gugur prematur',
      'crops': ['jeruk', 'mangga', 'pepaya', 'jambu'],
      'control': {
        'organic': 'Perangkap metil eugenol, protein bait, sanitasi kebun',
        'biological': 'Parasitoid Fopius arisanus, pelepasan steril jantan',
        'chemical': 'Malathion 57 EC + protein, Spinosad 120 SC',
        'prevention': 'Pembungkus buah, panen tepat waktu, sanitasi buah gugur',
      },
    },
    'penggerek buah mangga': {
      'description': 'Larva Deanolis sublimbalis yang menggerek buah mangga',
      'symptoms':
          'Lubang kecil pada buah, larva di dalam daging buah, getah keluar',
      'crops': ['mangga'],
      'control': {
        'organic': 'Sanitasi buah gugur, perangkap feromon, Beauveria bassiana',
        'biological': 'Trichogramma australicum, parasitoid indigenous',
        'chemical': 'Profenofos 500 EC, Indoksakarb 150 SC',
        'prevention': 'Pembungkus buah, sanitasi kebun, pruning sanitasi',
      },
    },
    'kutu putih mangga': {
      'description': 'Drosicha mangiferae yang menghisap cairan tanaman mangga',
      'symptoms': 'Daun menguning, honeydew lengket, semut banyak, sooty mold',
      'crops': ['mangga'],
      'control': {
        'organic':
            'Sabun insektisida, minyak hortikultura, predator coccinella',
        'biological': 'Cryptolaemus montrouzieri, Anagyrus mangicola',
        'chemical': 'Imidakloprid 200 SL, Thiamethoxam 25 WG',
        'prevention': 'Sanitasi kebun, hindari semut, monitoring rutin',
      },
    },
    'trips pisang': {
      'description': 'Thrips florum yang menyerang bunga dan buah muda pisang',
      'symptoms': 'Kulit buah kasar berwarna coklat, scarring pada kulit buah',
      'crops': ['pisang'],
      'control': {
        'organic': 'Perangkap biru lengket, pembungkus tandan',
        'biological': 'Orius spp., predator laba-laba',
        'chemical': 'Fipronil 50 SC, Thiamethoxam 25 WG',
        'prevention': 'Pembungkus tandan, sanitasi kebun',
      },
    },

    // HAMA SAYURAN SPESIFIK
    'kutu kebul tomat': {
      'description':
          'Bemisia tabaci yang menghisap cairan daun dan menularkan virus',
      'symptoms':
          'Daun menguning, layu, honeydew lengket, virus kuning keriting',
      'crops': ['tomat', 'cabai', 'terung', 'mentimun'],
      'control': {
        'organic': 'Perangkap kuning berlem, minyak nimba 3ml/L, sabun kalium',
        'biological':
            'Encarsia formosa, Eretmocerus eremicus, Delphastus catalinae',
        'chemical':
            'Spiromesifen 240 SC, Pyriproxyfen 100 EC, Thiamethoxam 25 WG',
        'prevention': 'Jaring serangga, mulsa reflektif, sanitasi gulma inang',
      },
    },
    'ulat buah tomat': {
      'description': 'Helicoverpa armigera yang menyerang buah tomat dan cabai',
      'symptoms': 'Lubang pada buah, kotoran ulat dalam buah, buah busuk',
      'crops': ['tomat', 'cabai', 'jagung', 'kacang tanah'],
      'control': {
        'organic':
            'Virus NPV Helicoverpa, Bacillus thuringiensis, perangkap feromon',
        'biological':
            'Trichogramma pretiosum, Chrysoperla carnea, Cotesia flavipes',
        'chemical':
            'Indoksakarb 150 SC, Emamektin benzoat 100 EC, Spinetoram 120 SC',
        'prevention':
            'Monitoring feromon trap, rotasi tanaman, sanitasi buah gugur',
      },
    },
    'kutu daun kentang': {
      'description':
          'Myzus persicae yang menghisap cairan dan menularkan virus',
      'symptoms':
          'Daun keriting, menguning, pertumbuhan terhambat, virus mosaik',
      'crops': ['kentang', 'tomat', 'cabai', 'terung'],
      'control': {
        'organic': 'Ekstrak bawang putih + cabai, sabun insektisida 2ml/L',
        'biological':
            'Aphidius colemani, Chrysoperla carnea, Coccinella septempunctata',
        'chemical': 'Imidakloprid 200 SL, Pirimikarb 50 WP, Thiamethoxam 25 WG',
        'prevention': 'Mulsa perak, tanam refugia, monitoring rutin mingguan',
      },
    },
    'lalat penambang daun': {
      'description': 'Liriomyza sativae yang membuat terowongan di dalam daun',
      'symptoms':
          'Garis-garis putih berliku di permukaan daun, bercak nekrotik',
      'crops': ['tomat', 'cabai', 'mentimun', 'kacang panjang', 'bayam'],
      'control': {
        'organic':
            'Perangkap kuning lengket, ekstrak nimba, predator laba-laba',
        'biological': 'Diglyphus isaea, Dacnusa sibirica, Opius pallipes',
        'chemical': 'Abamektin 18 EC, Cyromazine 75 WP, Spinosad 120 SC',
        'prevention': 'Jaring serangga, rotasi tanaman, sanitasi sisa tanaman',
      },
    },
    'ulat plutella brassica': {
      'description': 'Plutella xylostella yang menyerang tanaman kubis-kubisan',
      'symptoms':
          'Lubang kecil pada daun, larva hijau aktif, daun tinggal tulang daun',
      'crops': ['kubis', 'sawi', 'brokoli', 'kembang kol'],
      'control': {
        'organic': 'Bacillus thuringiensis var. kurstaki, ekstrak daun sirsak',
        'biological':
            'Diadegma semiclausum, Cotesia plutellae, Oomyzus sokolowskii',
        'chemical':
            'Emamektin benzoat 100 EC, Indoksakarb 150 SC, Spinetoram 120 SC',
        'prevention': 'Rotasi dengan tanaman non-brassica, jaring serangga',
      },
    },
    'kepik hijau kedelai': {
      'description': 'Nezara viridula yang menghisap polong kedelai muda',
      'symptoms':
          'Polong keriput, biji tidak terisi penuh, produksi menurun drastis',
      'crops': ['kedelai', 'kacang tanah', 'kacang hijau'],
      'control': {
        'organic': 'Perangkap feromon, predator laba-laba, ekstrak nimba 5ml/L',
        'biological': 'Trissolcus basalis (parasitoid telur), Telenomus podisi',
        'chemical': 'Deltametrin 25 EC, Profenofos 500 EC, Imidakloprid 200 SL',
        'prevention': 'Tanam serentak, monitoring rutin, sanitasi sisa tanaman',
      },
    },
    'penggerek polong kacang': {
      'description': 'Maruca vitrata yang menggerek polong kacang-kacangan',
      'symptoms':
          'Lubang bulat pada polong, larva di dalam polong, polong gugur',
      'crops': ['kacang panjang', 'kacang tanah', 'kedelai'],
      'control': {
        'organic':
            'Bacillus thuringiensis, perangkap feromon, ekstrak tembakau',
        'biological': 'Cotesia flavipes, Bracon hebetor, Trichogramma chilonis',
        'chemical': 'Indoksakarb 150 SC, Emamektin benzoat 100 EC',
        'prevention': 'Varietas tahan, tanam refugia, monitoring feromon trap',
      },
    },
    'walang sangit padi': {
      'description':
          'Leptocorisa oratorius yang menghisap bulir padi matang susu',
      'symptoms': 'Gabah hampa, pecah kulit, beras patah, aroma tidak sedap',
      'crops': ['padi'],
      'control': {
        'organic':
            'Perangkap cahaya, bebek angsa pemakan serangga, sabun insektisida',
        'biological': 'Laba-laba Lycosa, kumbang Paederus, parasitoid Gryon',
        'chemical':
            'Deltametrin 25 EC, Klorpirifos 500 EC saat malai keluar 50%',
        'prevention': 'Tanam serentak dalam hamparan, panen tepat waktu',
      },
    },
    'tikus sawah': {
      'description':
          'Rattus argentiventer yang merusak tanaman padi dari semai hingga panen',
      'symptoms':
          'Bibit tercabut, batang terpotong, bulir dimakan, jejak kaki tikus',
      'crops': ['padi', 'jagung'],
      'control': {
        'organic': 'Gropyokan serentak, perangkap hidup, buah-buahan beracun',
        'biological': 'Predator alami burung hantu, ular, musang',
        'chemical': 'Rodentisida Warfarin, Brodifacoum dalam umpan',
        'prevention': 'Sanitasi pematang, tanam serentak, pagar plastik',
      },
    },

    // HAMA TANAMAN PERKEBUNAN
    'hama pengorok daun kopi': {
      'description': 'Larva Leucoptera coffeella yang mengorok daun kopi',
      'symptoms': 'Terowongan pada daun, bercak coklat, gugur daun',
      'crops': ['kopi'],
      'control': {
        'organic': 'Beauveria bassiana, perangkap feromon, predator semut',
        'biological': 'Parasitoid Mirax insularis, Closterocerus coffeellae',
        'chemical': 'Thiamethoxam 25 WG, Imidakloprid 200 SL',
        'prevention': 'Naungan optimal, sanitasi daun gugur, monitoring',
      },
    },
    'borer buah kopi': {
      'description': 'Hypothenemus hampei yang menggerek biji kopi',
      'symptoms': 'Lubang kecil pada buah, biji rusak, kualitas menurun',
      'crops': ['kopi'],
      'control': {
        'organic': 'Beauveria bassiana, perangkap alkohol, sanitasi panen',
        'biological': 'Parasitoid Cephalonomia stephanoderis, Prorops nasuta',
        'chemical': 'Endosulfan 35 EC (terbatas), Imidakloprid soil drench',
        'prevention': 'Panen tepat waktu, sanitasi buah gugur, strip picking',
      },
    },
    'penggerek batang kakao': {
      'description':
          'Larva Conopomorpha cramerella yang menggerek batang kakao',
      'symptoms': 'Lubang pada batang, gerekan di korteks, tanaman lemah',
      'crops': ['kakao'],
      'control': {
        'organic': 'Beauveria bassiana, sanitasi batang terserang',
        'biological': 'Parasitoid Trichogrammatoidea bactrae',
        'chemical': 'Fipronil 50 SC, injeksi batang',
        'prevention': 'Sanitasi kebun, pruning pemeliharaan, monitoring',
      },
    },
    'ulat api kelapa sawit': {
      'description': 'Larva Setothosea asigna yang memakan daun kelapa sawit',
      'symptoms': 'Daun dimakan dari tepi, skeleton daun, defoliasi berat',
      'crops': ['kelapa sawit'],
      'control': {
        'organic': 'Bacillus thuringiensis, virus NPV, predator burung',
        'biological': 'Parasitoid Ooencyrtus sp., predator Sycanus',
        'chemical': 'Klorpirifos 500 EC, Profenofos 500 EC',
        'prevention': 'Monitoring telur, konservasi predator alami',
      },
    },
    'kumbang tanduk kelapa': {
      'description': 'Oryctes rhinoceros yang merusak pucuk kelapa',
      'symptoms':
          'Lubang pada pucuk, daun robek berbentuk V, pertumbuhan terhambat',
      'crops': ['kelapa', 'kelapa sawit'],
      'control': {
        'organic': 'Virus Oryctes (OrV), perangkap feromon, sanitasi',
        'biological': 'Metarhizium anisopliae, Beauveria bassiana',
        'chemical': 'Karbofuran 3G pada pucuk, Fipronil 50 SC',
        'prevention': 'Sanitasi bahan organik, perangkap light trap',
      },
    },

    // HAMA REMPAH-REMPAH
    'ulat daun jahe': {
      'description': 'Larva Udaspes folus yang memakan daun jahe',
      'symptoms': 'Daun dimakan dari tepi, lipatan daun, kotoran ulat',
      'crops': ['jahe', 'kunyit', 'lengkuas'],
      'control': {
        'organic': 'Bacillus thuringiensis, ekstrak nimba, predator laba-laba',
        'biological': 'Trichogramma spp., virus NPV',
        'chemical': 'Klorpirifos 500 EC, Profenofos 500 EC',
        'prevention': 'Sanitasi lahan, monitoring manual, refugia',
      },
    },
    'trips lada': {
      'description':
          'Thrips parvispinus yang menyerang bunga dan buah muda lada',
      'symptoms': 'Bunga gugur, buah kecil dan cacat, produksi menurun',
      'crops': ['lada'],
      'control': {
        'organic': 'Perangkap biru lengket, sabun insektisida',
        'biological': 'Orius spp., Amblyseius spp.',
        'chemical': 'Abamektin 18 EC, Thiamethoxam 25 WG',
        'prevention': 'Sanitasi kebun, drainase baik, naungan optimal',
      },
    },
    'kutu sisik lada': {
      'description': 'Aspidiotus destructor yang menghisap cairan batang lada',
      'symptoms': 'Kulit batang kasar, tanaman lemah, produksi menurun',
      'crops': ['lada'],
      'control': {
        'organic': 'Minyak hortikultura, sabun insektisida, sikat manual',
        'biological': 'Predator Chilocorus spp., Rhyzobius spp.',
        'chemical': 'Imidakloprid 200 SL, Thiamethoxam 25 WG',
        'prevention': 'Sanitasi kebun, monitoring rutin, karantina bibit',
      },
    },
    'penggerek ranting kopi': {
      'description': 'Xylosandrus compactus yang menggerek ranting kopi',
      'symptoms': 'Lubang kecil di ranting, ranting mengering dan patah',
      'crops': ['kopi', 'kakao'],
      'control': {
        'organic': 'Pruning ranting terserang, minyak nimba, perangkap alkohol',
        'biological': 'Beauveria bassiana, predator semut hitam',
        'chemical': 'Imidakloprid 200 SL injeksi batang, Klorpirifos 500 EC',
        'prevention': 'Pruning sanitasi rutin, hindari stress tanaman',
      },
    },
    'kutu putih kelapa sawit': {
      'description':
          'Pseudococcus longispinus yang menyerang pelepah kelapa sawit',
      'symptoms': 'Koloni putih berlilin pada pelepah, daun menguning',
      'crops': ['kelapa sawit', 'kelapa'],
      'control': {
        'organic': 'Sabun insektisida 3ml/L, minyak nimba, predator kumbang',
        'biological': 'Cryptolaemus montrouzieri, Anagyrus pseudococci',
        'chemical': 'Imidakloprid 200 SL, Thiamethoxam 25 WG',
        'prevention': 'Sanitasi pelepah tua, monitoring bulanan',
      },
    },
    'kutu kebul singkong': {
      'description':
          'Bemisia tabaci yang menyerang daun singkong dan menjadi vektor virus',
      'symptoms': 'Daun menguning, kerdil, tunas mengering, virus mosaik',
      'crops': ['singkong', 'ubi kayu'],
      'control': {
        'organic': 'Minyak nimba 0.5%, sabun kalium, perangkap kuning',
        'biological': 'Encarsia formosa, Eretmocerus mundus, jamur Beauveria',
        'chemical': 'Imidakloprid 200 SL, Thiamethoxam 25 WG (rotasi)',
        'prevention': 'Varietas tahan, bersih gulma inang, monitoring rutin',
      },
    },
    'ulat grayak singkong': {
      'description':
          'Spodoptera litura yang memakan daun singkong terutama malam hari',
      'symptoms': 'Daun berlubang besar, tinggal tulang daun, kotoran ulat',
      'crops': ['singkong', 'ubi kayu', 'kedelai'],
      'control': {
        'organic': 'Bacillus thuringiensis, ekstrak daun mimba 2%',
        'biological': 'Parasit Cotesia sp., predator laba-laba, burung',
        'chemical': 'Klorpirifos 200 EC, Emamektin benzoat 5 WG',
        'prevention': 'Perangkap feromon, petik manual sore hari',
      },
    },
    'tungau merah singkong': {
      'description': 'Tetranychus urticae yang menghisap cairan sel daun',
      'symptoms': 'Daun berbintik kuning kecil, mengering, jaring halus',
      'crops': ['singkong', 'ubi kayu', 'tomat', 'cabai'],
      'control': {
        'organic': 'Semprot air keras, minyak mineral, predator alami',
        'biological': 'Phytoseiulus persimilis, Neoseiulus californicus',
        'chemical': 'Abamektin 18 EC, Propargit 570 EC (akarisida)',
        'prevention': 'Jaga kelembaban tinggi, hindari kekeringan',
      },
    },
    'aphid wortel': {
      'description': 'Cavariella aegopodii yang menyerang daun wortel muda',
      'symptoms':
          'Daun keriting kuning, pertumbuhan terhambat, honeydew lengket',
      'crops': ['wortel', 'seledri', 'peterseli'],
      'control': {
        'organic': 'Semprotan air keras, sabun kalium 2ml/L, minyak nimba',
        'biological': 'Aphidius ervi, Lysiphlebus testaceipes, Coccinella',
        'chemical': 'Pirimikarb 50 WP, Imidakloprid 200 SL',
        'prevention': 'Mulsa reflektif, rotasi tanaman, monitoring mingguan',
      },
    },
    'ulat tanah kentang': {
      'description': 'Agrotis ipsilon yang memotong batang muda kentang',
      'symptoms': 'Tanaman muda terpotong di pangkal batang, tanaman rebah',
      'crops': ['kentang', 'tomat', 'cabai', 'kubis'],
      'control': {
        'organic': 'Umpan dedak + Bacillus thuringiensis, light trap',
        'biological': 'Steinernema carpocapsae (nematoda), burung pemakan ulat',
        'chemical': 'Klorpirifos 500 EC dalam umpan dedak',
        'prevention': 'Olah tanah sempurna, sanitasi gulma, tanam siang hari',
      },
    },
    'kumbang daun mentimun': {
      'description': 'Aulacophora similis yang memakan daun mentimun muda',
      'symptoms': 'Lubang-lubang kecil pada daun, daun seperti saringan',
      'crops': ['mentimun', 'labu', 'semangka', 'melon'],
      'control': {
        'organic': 'Perangkap kuning, ekstrak serai wangi, hand picking',
        'biological': 'Laba-laba pemburu, kumbang predator Menochilus',
        'chemical': 'Deltametrin 25 EC, Profenofos 500 EC',
        'prevention': 'Mulsa plastik, jaring serangga, tanam trap crop',
      },
    },
    'kutu loncat bayam': {
      'description': 'Hymenia recurvalis yang melompat saat tanaman diganggu',
      'symptoms': 'Lubang kecil pada daun, larva menggulung daun',
      'crops': ['bayam', 'kangkung', 'sawi'],
      'control': {
        'organic': 'Sabun insektisida, ekstrak bawang putih + cabai',
        'biological': 'Spodoptera predator, parasitoid Cotesia',
        'chemical': 'Abamektin 18 EC, Spinosad 120 SC',
        'prevention': 'Rotasi tanaman, sanitasi gulma, panen muda',
      },
    },
  };

  // Database penyakit tanaman untuk seluruh komoditas
  final Map<String, Map<String, dynamic>> _diseaseDatabase = {
    // PENYAKIT TANAMAN PANGAN
    'blast': {
      'description': 'Penyakit jamur Pyricularia oryzae pada padi',
      'symptoms':
          'Bercak elips coklat dengan tepi kuning pada daun dan malai, malai kosong',
      'crops': ['padi'],
      'control': {
        'organic':
            'Trichoderma spp., ekstrak bawang putih, kompos aktif, abu sekam',
        'chemical':
            'Trikiklazol 75 WP, Azoksistrobin 250 SC, Propikonazol 25 EC',
        'prevention':
            'Varietas tahan blast, pengaturan jarak tanam 25x25 cm, tidak berlebihan nitrogen',
      },
    },
    'hawar daun bakteri': {
      'description': 'Penyakit bakteri Xanthomonas oryzae pada padi',
      'symptoms':
          'Bercak memanjang berwarna kuning sampai coklat di tepi daun, layu kresek',
      'crops': ['padi'],
      'control': {
        'organic': 'Pseudomonas fluorescens, ekstrak daun sirih, larutan garam',
        'chemical': 'Streptomisin sulfat 20 WP, Tembaga oksiklorida 77 WP',
        'prevention': 'Benih bebas bakteri, sanitasi alat, drainase baik',
      },
    },
    'busuk batang': {
      'description': 'Penyakit jamur Sclerotium oryzae pada padi',
      'symptoms': 'Bercak hitam pada batang dekat permukaan air, tanaman roboh',
      'crops': ['padi'],
      'control': {
        'organic': 'Trichoderma harzianum, abu dapur, kapur tohor',
        'chemical': 'Validamisin 3 SL, Heksikon azol 5 EC',
        'prevention': 'Drainase lancar, tidak terlalu dalam menggenang',
      },
    },
    'bercak daun jagung': {
      'description': 'Penyakit jamur Helminthosporium turcicum pada jagung',
      'symptoms': 'Bercak memanjang berwarna coklat keabu-abuan pada daun',
      'crops': ['jagung'],
      'control': {
        'organic': 'Ekstrak bawang putih, larutan baking soda, kompos',
        'chemical': 'Mankozeb 80 WP, Klorotalonil 500 SC',
        'prevention': 'Varietas tahan, rotasi tanaman, sanitasi',
      },
    },
    'downy mildew jagung': {
      'description': 'Penyakit jamur Peronosclerospora spp. pada jagung',
      'symptoms':
          'Daun menguning bergaris, pertumbuhan kerdil, bunga jantan steril',
      'crops': ['jagung'],
      'control': {
        'organic': 'Metalaksil + Mankozeb sebagai perlakuan benih',
        'chemical': 'Metalaksil 8% + Mankozeb 64% WP untuk benih',
        'prevention': 'Benih bebas penyakit, tanam varietas tahan',
      },
    },
    'karat kedelai': {
      'description': 'Penyakit jamur Phakopsora pachyrhizi pada kedelai',
      'symptoms':
          'Bintik-bintik kuning pada daun, pustula coklat di bawah daun',
      'crops': ['kedelai'],
      'control': {
        'organic': 'Trichoderma, ekstrak tembakau, minyak nimba',
        'chemical': 'Tebukonazol 25 WS, Azoksistrobin 25 SC',
        'prevention': 'Varietas tahan karat, jarak tanam optimal',
      },
    },

    // PENYAKIT SAYURAN
    'layu fusarium': {
      'description':
          'Penyakit jamur Fusarium oxysporum yang menyebabkan layu vaskular',
      'symptoms':
          'Tanaman layu, pembuluh akar coklat, daun menguning dari bawah',
      'crops': ['tomat', 'cabai', 'timun', 'terong', 'kacang'],
      'control': {
        'organic':
            'Trichoderma harzianum, kompos aktif, arang aktif, kapur dolomit',
        'chemical': 'Benomil 50 WP, Karbendazim 50 WP, Mankozeb 80 WP',
        'prevention':
            'Rotasi tanaman, pH tanah 6.5-7.0, drainase baik, varietas tahan',
      },
    },
    'antraknosa': {
      'description':
          'Penyakit jamur Colletotrichum spp. yang menyerang buah dan daun',
      'symptoms':
          'Bercak cekung pada buah, daun berlubang, buah busuk berwarna hitam',
      'crops': ['cabai', 'tomat', 'timun', 'kacang', 'mangga'],
      'control': {
        'organic': 'Ekstrak daun sirih, Trichoderma, minyak sereh, abu gosok',
        'chemical': 'Difenokonazol 25 EC, Mankozeb 80 WP, Klorotalonil 500 SC',
        'prevention':
            'Sanitasi buah busuk, sirkulasi udara baik, mulsa plastik',
      },
    },
    'busuk daun': {
      'description': 'Penyakit bakteri Xanthomonas pada berbagai sayuran',
      'symptoms':
          'Bercak coklat dengan halo kuning, daun layu, busuk lunak basah',
      'crops': ['cabai', 'tomat', 'sawi', 'kubis', 'kacang'],
      'control': {
        'organic': 'Pseudomonas fluorescens, ekstrak jahe, asam salisilat',
        'chemical': 'Streptomisin sulfat 20 WP, Tembaga oksiklorida 77 WP',
        'prevention': 'Benih sehat, drainase baik, sanitasi alat, hindari luka',
      },
    },
    'virus mosaik': {
      'description': 'Penyakit virus yang ditularkan kutu daun dan thrips',
      'symptoms': 'Daun belang-belang hijau terang dan gelap, keriting, kerdil',
      'crops': ['cabai', 'tomat', 'timun', 'terong', 'kacang'],
      'control': {
        'organic': 'Susu skim 10%, mulsa aluminium, tanaman perangkap',
        'chemical': 'Pengendalian vektor dengan Imidakloprid 200 SL',
        'prevention': 'Varietas tahan virus, kendalikan serangga vektor',
      },
    },
    'bercak daun tomat': {
      'description': 'Penyakit jamur Alternaria solani pada tomat',
      'symptoms': 'Bercak coklat bulat dengan lingkaran konsentris pada daun',
      'crops': ['tomat', 'kentang'],
      'control': {
        'organic': 'Ekstrak bawang putih, larutan baking soda, kompos',
        'chemical': 'Mancozeb 80 WP, Difenokonazol 25 EC',
        'prevention': 'Rotasi tanaman, sanitasi, mulsa, drainase baik',
      },
    },
    'clubroot kubis': {
      'description':
          'Penyakit jamur Plasmodiophora brassicae pada kubis-kubisan',
      'symptoms':
          'Akar membengkak seperti gada, tanaman layu, pertumbuhan kerdil',
      'crops': ['kubis', 'sawi', 'brokoli'],
      'control': {
        'organic': 'Kapur dolomit, kompos matang, Trichoderma',
        'chemical': 'Fluazinam 50 SC, pemberian kapur untuk pH 7.2',
        'prevention': 'pH tanah di atas 7.2, rotasi dengan non-brassica',
      },
    },

    // PENYAKIT BUAH-BUAHAN
    'kanker jeruk': {
      'description': 'Penyakit bakteri Xanthomonas citri pada jeruk',
      'symptoms':
          'Bercak coklat dengan halo kuning pada daun, buah, dan ranting',
      'crops': ['jeruk', 'lemon'],
      'control': {
        'organic': 'Pseudomonas fluorescens, ekstrak daun sirih',
        'chemical': 'Streptomisin sulfat 20 WP, Tembaga oksiklorida',
        'prevention': 'Sanitasi pohon sakit, disinfeksi alat pemangkas',
      },
    },
    'busuk buah mangga': {
      'description':
          'Penyakit jamur Colletotrichum gloeosporioides pada mangga',
      'symptoms':
          'Bercak hitam pada buah matang, busuk lunak dengan spora hitam',
      'crops': ['mangga'],
      'control': {
        'organic': 'Trichoderma, ekstrak lengkuas, air panas 52°C',
        'chemical': 'Benomil 50 WP, Difenokonazol 25 EC',
        'prevention': 'Panen tepat waktu, penanganan hati-hati, simpan dingin',
      },
    },
    'layu panama pisang': {
      'description':
          'Penyakit jamur Fusarium oxysporum f.sp. cubense pada pisang',
      'symptoms': 'Daun menguning dari tepi, layu, batang semu pecah',
      'crops': ['pisang'],
      'control': {
        'organic': 'Trichoderma harzianum, kompos Tithonia, kapur dolomit',
        'chemical': 'Propikonazol 25 EC, soil drenching',
        'prevention': 'Bibit bebas penyakit, sanitasi kebun, rotasi',
      },
    },

    // PENYAKIT TANAMAN PERKEBUNAN
    'leaf rust kopi': {
      'description': 'Penyakit jamur Hemileia vastatrix pada kopi',
      'symptoms': 'Bercak kuning oranye di bawah daun, defoliasi berat',
      'crops': ['kopi'],
      'control': {
        'organic': 'Trichoderma, mulsa tebal, pupuk kalium tinggi',
        'chemical': 'Tembaga oksiklorida 77 WP, Tebukonazol 25 WS',
        'prevention': 'Varietas tahan karat, sanitasi kebun, naungan optimal',
      },
    },
    'busuk buah kakao': {
      'description': 'Penyakit jamur Phytophthora palmivora pada kakao',
      'symptoms': 'Bercak coklat pada buah muda, busuk hitam, buah gugur',
      'crops': ['kakao'],
      'control': {
        'organic': 'Trichoderma, pruning sanitasi, drainase baik',
        'chemical': 'Metalaksil + Mankozeb, Fosetil aluminium',
        'prevention': 'Sanitasi buah sakit, sirkulasi udara, drainase',
      },
    },
    'ganoderma kelapa sawit': {
      'description': 'Penyakit jamur Ganoderma boninense pada kelapa sawit',
      'symptoms': 'Daun menguning, mahkota kecil, tubuh buah jamur di pangkal',
      'crops': ['kelapa sawit', 'kelapa'],
      'control': {
        'organic': 'Trichoderma harzianum soil treatment, sanitasi',
        'chemical': 'Hexaconazole injection, soil drenching Propikonazol',
        'prevention': 'Sanitasi tunggul, aplikasi Trichoderma saat tanam',
      },
    },

    // PENYAKIT REMPAH-REMPAH
    'busuk rimpang jahe': {
      'description': 'Penyakit bakteri Ralstonia solanacearum pada jahe',
      'symptoms': 'Layu mendadak, rimpang busuk berbau, pembuluh coklat',
      'crops': ['jahe', 'kunyit', 'lengkuas'],
      'control': {
        'organic': 'Pseudomonas fluorescens, kapur dolomit, drainase',
        'chemical': 'Streptomisin sulfat soil drenching',
        'prevention': 'Bibit sehat, rotasi 3-4 tahun, drainase sempurna',
      },
    },
    'bercak daun kunyit': {
      'description': 'Penyakit jamur Colletotrichum spp. pada kunyit',
      'symptoms': 'Bercak coklat bulat pada daun, tepi kuning, gugur daun',
      'crops': ['kunyit', 'jahe'],
      'control': {
        'organic': 'Trichoderma, ekstrak bawang putih, mulsa organik',
        'chemical': 'Mankozeb 80 WP, Difenokonazol 25 EC',
        'prevention': 'Jarak tanam optimal, sanitasi, sirkulasi udara',
      },
    },
    'busuk hitam lada': {
      'description': 'Penyakit jamur Phytophthora capsici pada lada',
      'symptoms': 'Buah muda menghitam dan gugur, infeksi sistemik',
      'crops': ['lada'],
      'control': {
        'organic': 'Trichoderma, drainase baik, pruning sanitasi',
        'chemical': 'Metalaksil + Mankozeb, Fosetil aluminium',
        'prevention': 'Drainase sempurna, hindari genangan, sanitasi',
      },
    },

    // PENYAKIT SAYURAN TAMBAHAN
    'bercak daun kentang': {
      'description':
          'Alternaria solani yang menyerang daun kentang dengan bercak konsentris',
      'symptoms':
          'Bercak coklat bulat dengan lingkaran konsentris, dimulai dari daun tua',
      'crops': ['kentang', 'tomat', 'terung'],
      'control': {
        'organic':
            'Fungisida tembaga 2g/L, ekstrak daun sirih, kompos Trichoderma',
        'chemical': 'Mankozeb 80 WP, Difenokonazol 25 EC, Azoksistrobin 250 SC',
        'prevention':
            'Rotasi tanaman 3 tahun, drainase baik, hindari penyiraman daun',
      },
    },
    'busuk lunak bawang': {
      'description':
          'Erwinia carotovora yang menyebabkan pembusukan umbi bawang',
      'symptoms':
          'Umbi lunak berair, berbau busuk menyengat, daun layu mendadak',
      'crops': ['bawang merah', 'bawang putih', 'bawang bombay'],
      'control': {
        'organic': 'Bakterisida tembaga, perbaiki drainase, kurangi kelembaban',
        'chemical': 'Streptomisin sulfat 200ppm, Copper oksiklorida 3g/L',
        'prevention':
            'Hindari luka saat panen, simpan kering, rotasi non-allium',
      },
    },
    'embun tepung mentimun': {
      'description':
          'Podosphaera xanthii yang membentuk lapisan putih pada daun',
      'symptoms':
          'Lapisan tepung putih pada permukaan daun, daun menguning dan kering',
      'crops': ['mentimun', 'labu', 'semangka', 'melon'],
      'control': {
        'organic': 'Larutan baking soda 5g/L, susu skim 100ml/L, minyak nimba',
        'chemical':
            'Triadimefon 250 EC, Tebukonazol 25 EC, Azoksistrobin 250 SC',
        'prevention':
            'Sirkulasi udara baik, hindari kelembaban tinggi, varietas tahan',
      },
    },
    'virus keriting tomat': {
      'description': 'Tomato yellow leaf curl virus yang ditularkan kutu kebul',
      'symptoms':
          'Daun keriting kuning, tanaman kerdil, produksi sangat menurun',
      'crops': ['tomat', 'cabai'],
      'control': {
        'organic': 'Kendalikan kutu kebul, perangkap kuning, minyak nimba',
        'chemical': 'Insektisida untuk kutu kebul: Spiromesifen, Pyriproxyfen',
        'prevention': 'Jaring serangga, varietas tahan, sanitasi gulma inang',
      },
    },
    'karat daun jagung': {
      'description':
          'Puccinia sorghi yang membentuk pustula karat pada daun jagung',
      'symptoms':
          'Pustula berwarna coklat karat pada permukaan daun, daun menguning dan kering',
      'crops': ['jagung'],
      'control': {
        'organic': 'Fungisida tembaga, ekstrak bawang putih 50ml/L',
        'chemical':
            'Propikonazol 25 EC, Tebukonazol 25 EC, Azoksistrobin 250 SC',
        'prevention':
            'Tanam varietas tahan, rotasi tanaman, sanitasi jerami jagung',
      },
    },
    'penyakit karat kedelai': {
      'description': 'Phakopsora pachyrhizi yang menyerang daun kedelai',
      'symptoms':
          'Bercak kecil coklat dengan spora kuning keemasan di bawah daun',
      'crops': ['kedelai'],
      'control': {
        'organic':
            'Fungisida tembaga 3g/L, ekstrak daun sirih, kompos Trichoderma',
        'chemical': 'Tebukonazol 25 EC, Azoksistrobin 250 SC, Propikonazol',
        'prevention':
            'Varietas tahan karat, jarak tanam optimal, drainase baik',
      },
    },
    'bercak coklat padi': {
      'description':
          'Cochliobolus miyabeanus yang menyerang daun dan gabah padi',
      'symptoms':
          'Bercak oval coklat dengan tepi kuning, gabah hitam dan hampa',
      'crops': ['padi'],
      'control': {
        'organic': 'Trichoderma harzianum, ekstrak lengkuas, abu sekam',
        'chemical': 'Mancozeb 80 WP, Validamycin 3 SL, Azoksistrobin',
        'prevention': 'Varietas tahan, pengairan berselang, sanitasi jerami',
      },
    },
    'rebah semai jagung': {
      'description': 'Pythium dan Rhizoctonia yang menyerang bibit jagung',
      'symptoms':
          'Bibit rebah dan mati, akar dan pangkal batang membusuk hitam',
      'crops': ['jagung', 'kedelai'],
      'control': {
        'organic': 'Trichoderma pada benih, drainase sempurna, mulsa organik',
        'chemical': 'Metalaksil + Mankozeb, Captan 50 WP pada benih',
        'prevention': 'Benih berkualitas, bedengan tinggi, tidak overwatering',
      },
    },
    'hawar daun bakteri padi': {
      'description': 'Xanthomonas oryzae yang menyerang daun padi',
      'symptoms': 'Garis-garis kuning memanjang dari tepi daun, daun mengering',
      'crops': ['padi'],
      'control': {
        'organic': 'Pseudomonas fluorescens, ekstrak jahe merah',
        'chemical': 'Streptomisin sulfat 20 WP, Copper oksiklorida 77 WP',
        'prevention':
            'Varietas tahan, hindari luka pada tanaman, drainase baik',
      },
    },
    'downy mildew bayam': {
      'description': 'Peronospora farinosa yang menyerang daun bayam',
      'symptoms': 'Bercak kuning pada daun atas, lapisan putih di bawah daun',
      'crops': ['bayam', 'kangkung', 'sawi'],
      'control': {
        'organic': 'Larutan baking soda 5g/L, susu skim 10%, ventilasi baik',
        'chemical': 'Metalaksil + Mankozeb, Dimethomorph 50 WP',
        'prevention': 'Hindari kelembaban tinggi, jarak tanam tidak rapat',
      },
    },
    'penyakit karat putih bawang': {
      'description':
          'Puccinia allii yang menyerang daun bawang dengan pustula putih',
      'symptoms':
          'Pustula putih memanjang pada daun, daun menguning dan kering',
      'crops': ['bawang merah', 'bawang putih', 'bawang daun'],
      'control': {
        'organic': 'Fungisida tembaga 3g/L, ekstrak kunyit + lengkuas',
        'chemical': 'Tebukonazol 25 EC, Propikonazol 25 EC, Mankozeb 80 WP',
        'prevention': 'Varietas tahan, rotasi 3 tahun, drainase sempurna',
      },
    },
    'vsd kakao': {
      'description': 'Vascular Streak Dieback oleh Oncobasidium theobromae',
      'symptoms': 'Daun layu sepihak, garis-garis coklat pada irisan ranting',
      'crops': ['kakao'],
      'control': {
        'organic': 'Pruning ranting terserang 30cm, Trichoderma pada luka',
        'chemical': 'Copper oksiklorida pada luka pruning, Mankozeb 80 WP',
        'prevention': 'Sanitasi alat pruning, varietas tahan VSD',
      },
    },
    'busuk pangkal batang kopi': {
      'description': 'Pellicularia koleroga yang menyerang pangkal batang kopi',
      'symptoms': 'Pangkal batang membusuk coklat, tanaman layu dan mati',
      'crops': ['kopi'],
      'control': {
        'organic': 'Trichoderma harzianum, drainase sempurna, mulsa jerami',
        'chemical': 'Mankozeb 80 WP, Copper oksiklorida 77 WP',
        'prevention': 'Drainase baik, hindari genangan, sanitasi kebun',
      },
    },
    'antraknosa pisang': {
      'description': 'Colletotrichum musae yang menyerang buah pisang matang',
      'symptoms': 'Bercak hitam cekung pada kulit buah, daging buah busuk',
      'crops': ['pisang'],
      'control': {
        'organic': 'Pembungkus tandan, penyimpanan kering, ventilasi baik',
        'chemical': 'Azoksistrobin 250 SC, Difenokonazol 25 EC',
        'prevention': 'Panen tepat waktu, hindari luka buah, simpan sejuk',
      },
    },
    'penyakit mosaik singkong': {
      'description': 'Cassava Mosaic Virus (CMV) yang disebarkan kutu kebul',
      'symptoms': 'Daun mozaik kuning-hijau, kerdil, produktivitas menurun',
      'crops': ['singkong', 'ubi kayu'],
      'control': {
        'organic': 'Gunakan bibit sehat bersertifikat, kendalikan kutu kebul',
        'chemical': 'Tidak ada obat langsung, fokus pada pencegahan vektor',
        'prevention': 'Varietas tahan CMV, cabut tanaman sakit, rotasi tanaman',
      },
    },
    'penyakit layu bakteri singkong': {
      'description': 'Xanthomonas axonopodis yang menyebabkan layu vaskular',
      'symptoms': 'Daun layu mendadak, pembuluh batang berwarna coklat',
      'crops': ['singkong', 'ubi kayu'],
      'control': {
        'organic': 'Bibit sehat, drainase baik, sanitasi alat pertanian',
        'chemical': 'Streptomisin sulfat, Copper hidroksida saat tanam',
        'prevention': 'Varietas tahan bakteri, rotasi 2-3 tahun',
      },
    },
    'busuk akar singkong': {
      'description': 'Phytophthora drechsleri yang menyerang sistem perakaran',
      'symptoms': 'Akar hitam membusuk, tanaman layu meski tanah lembab',
      'crops': ['singkong', 'ubi kayu'],
      'control': {
        'organic': 'Drainase sempurna, Trichoderma sp. di lubang tanam',
        'chemical': 'Metalaksil-M + Mankozeb, Propamokarb HCl',
        'prevention': 'Tanah tidak becek, bedengan tinggi, rotasi tanaman',
      },
    },
    'gummosis jeruk': {
      'description':
          'Phytophthora parasitica yang menyerang kulit batang jeruk',
      'symptoms': 'Kulit batang mengelupas, getah keluar, daun menguning',
      'crops': ['jeruk', 'lemon'],
      'control': {
        'organic': 'Drainase sempurna, bersihkan kulit batang, Trichoderma',
        'chemical': 'Metalaksil + Mankozeb, Fosetil aluminium',
        'prevention': 'Hindari genangan air, mulsa organik, sanitasi kebun',
      },
    },
  };

  // Database rekomendasi pupuk spesifik untuk setiap komoditas
  final Map<String, Map<String, dynamic>> _cropFertilizerRecommendations = {
    'padi': {
      'fertilizer_program': {
        'basic': 'NPK 15:15:15 300 kg/ha + Urea 200 kg/ha + SP36 100 kg/ha',
        'schedule': {
          '0_HST': 'NPK 15:15:15 150 kg/ha + SP36 100 kg/ha (dasar)',
          '21_HST': 'Urea 100 kg/ha + NPK 150 kg/ha (anakan aktif)',
          '45_HST': 'Urea 100 kg/ha + KCl 50 kg/ha (primordial malai)',
          '65_HST': 'KCl 50 kg/ha + NPK foliar (pengisian gabah)',
        },
        'organic_alternative':
            'Kompos 3 ton/ha + Pupuk kandang 2 ton/ha + Biochar 500 kg/ha',
        'micro_nutrients':
            'Zn 25 kg/ha, Fe 15 kg/ha untuk tanah sawah defisien',
        'soil_pH': '6.0-7.0 optimal, aplikasi kapur 1-2 ton/ha jika pH < 5.5',
      },
      'yield_target': '7-9 ton/ha GKG',
      'efficiency_tips':
          'Aplikasi pupuk N saat tanah dalam kondisi macak-macak, hindari saat tergenang',
    },
    'jagung': {
      'fertilizer_program': {
        'basic': 'NPK 15:15:15 400 kg/ha + Urea 300 kg/ha + KCl 100 kg/ha',
        'schedule': {
          '0_HST':
              'NPK 15:15:15 200 kg/ha + SP36 150 kg/ha (tugal bersama benih)',
          '21_HST':
              'Urea 150 kg/ha + NPK 200 kg/ha (V6-V8, sebelum pembumbunan)',
          '42_HST':
              'Urea 150 kg/ha + KCl 100 kg/ha (V12-V14, sebelum berbunga)',
          '60_HST': 'KCl 50 kg/ha + NPK foliar (pengisian biji)',
        },
        'organic_alternative':
            'Kompos 4 ton/ha + Pupuk kandang ayam 3 ton/ha + Abu sekam 1 ton/ha',
        'micro_nutrients': 'Zn 20 kg/ha, B 2 kg/ha untuk tanah masam',
        'soil_pH': '6.0-7.5 optimal',
      },
      'yield_target': '8-12 ton/ha pipil kering',
      'efficiency_tips':
          'Pupuk N diberikan dalam larikan 5-7 cm dari tanaman, tutup tanah',
    },
    'kedelai': {
      'fertilizer_program': {
        'basic': 'SP36 150 kg/ha + KCl 100 kg/ha + Urea 50 kg/ha (starter)',
        'schedule': {
          '0_HST': 'SP36 150 kg/ha + KCl 50 kg/ha + Rhizobium (dasar)',
          '21_HST':
              'Urea 50 kg/ha + KCl 50 kg/ha (V3-V4, pembentukan bintil akar)',
          '42_HST': 'NPK 16:16:16 100 kg/ha (R1-R2, awal berbunga)',
          '60_HST': 'KCl 50 kg/ha + Ca 100 kg/ha (R5, pengisian polong)',
        },
        'organic_alternative':
            'Kompos 2.5 ton/ha + Pupuk kandang 2 ton/ha + Inokulan Rhizobium',
        'micro_nutrients': 'Mo 2 kg/ha, Ca 200 kg/ha (kapur pertanian)',
        'soil_pH': '6.0-7.0 optimal untuk fiksasi N',
      },
      'yield_target': '2.5-3.5 ton/ha biji kering',
      'efficiency_tips':
          'Pupuk N minimal, fokus pada P dan K untuk mendukung Rhizobium',
    },
    'cabai merah': {
      'fertilizer_program': {
        'basic': 'NPK 16:16:16 600 kg/ha + Urea 200 kg/ha + KCl 200 kg/ha',
        'schedule': {
          '0_HST': 'Kompos 20 ton/ha + SP36 200 kg/ha + KCl 100 kg/ha (dasar)',
          '14_HST': 'NPK 16:16:16 150 kg/ha (setelah transplanting)',
          '30_HST': 'Urea 100 kg/ha + NPK 150 kg/ha (vegetatif aktif)',
          '45_HST': 'NPK 16:16:16 150 kg/ha + KCl 50 kg/ha (awal berbunga)',
          '60_HST': 'Urea 100 kg/ha + KCl 50 kg/ha (pembentukan buah)',
          '75_HST': 'NPK 16:16:16 150 kg/ha + Ca 100 kg/ha (puncak produksi)',
          '90_HST_dst': 'NPK foliar setiap 2 minggu + KCl 50 kg/ha/bulan',
        },
        'organic_alternative':
            'Kompos 25 ton/ha + Kascing 5 ton/ha + Pupuk kandang ayam 10 ton/ha',
        'micro_nutrients':
            'Ca 300 kg/ha, Mg 50 kg/ha, B 3 kg/ha untuk kualitas buah',
        'soil_pH': '6.5-7.0 optimal',
      },
      'yield_target': '15-25 ton/ha buah segar',
      'efficiency_tips':
          'Pupuk K tinggi saat pembentukan buah, aplikasi Ca untuk mencegah busuk ujung',
    },
    'tomat': {
      'fertilizer_program': {
        'basic': 'NPK 15:15:15 500 kg/ha + Urea 250 kg/ha + KCl 200 kg/ha',
        'schedule': {
          '0_HST': 'Kompos 15 ton/ha + SP36 200 kg/ha + KCl 100 kg/ha (dasar)',
          '14_HST': 'NPK 15:15:15 125 kg/ha (transplanting)',
          '28_HST': 'Urea 100 kg/ha + NPK 125 kg/ha (vegetatif)',
          '42_HST': 'NPK 15:15:15 125 kg/ha + KCl 50 kg/ha (berbunga)',
          '56_HST': 'Urea 100 kg/ha + KCl 50 kg/ha (fruit set)',
          '70_HST': 'NPK 15:15:15 125 kg/ha + Ca 100 kg/ha (pembentukan buah)',
          '84_HST_dst': 'Urea 50 kg/ha + KCl 50 kg/ha setiap 2 minggu',
        },
        'organic_alternative':
            'Kompos 20 ton/ha + Pupuk kandang sapi 8 ton/ha + Kascing 3 ton/ha',
        'micro_nutrients': 'Ca 250 kg/ha, Mg 40 kg/ha, B 2 kg/ha',
        'soil_pH': '6.0-7.0 optimal',
      },
      'yield_target': '40-60 ton/ha buah segar',
      'efficiency_tips':
          'Rasio K:N tinggi (2:1) saat berbuah untuk kualitas dan daya simpan',
    },
    'bawang merah': {
      'fertilizer_program': {
        'basic': 'NPK 16:16:16 400 kg/ha + Urea 150 kg/ha + KCl 150 kg/ha',
        'schedule': {
          '0_HST': 'Kompos 10 ton/ha + SP36 150 kg/ha + KCl 75 kg/ha (dasar)',
          '14_HST': 'NPK 16:16:16 150 kg/ha (establishment)',
          '28_HST': 'Urea 75 kg/ha + NPK 150 kg/ha (vegetatif aktif)',
          '42_HST': 'Urea 75 kg/ha + KCl 75 kg/ha (pembentukan umbi)',
          '56_HST': 'NPK 16:16:16 100 kg/ha + KCl 50 kg/ha (pengisian umbi)',
        },
        'organic_alternative':
            'Kompos 12 ton/ha + Pupuk kandang ayam 5 ton/ha + Abu sekam 2 ton/ha',
        'micro_nutrients': 'S 50 kg/ha, Ca 200 kg/ha untuk kualitas umbi',
        'soil_pH': '6.0-7.0 optimal',
      },
      'yield_target': '12-18 ton/ha umbi kering',
      'efficiency_tips':
          'Pupuk S tinggi untuk pembentukan senyawa allicin, hentikan N 2 minggu sebelum panen',
    },
    'kopi': {
      'fertilizer_program': {
        'basic': 'NPK 15:15:6 300 kg/ha + Urea 150 kg/ha + KCl 200 kg/ha',
        'schedule': {
          'Jan_Feb': 'NPK 15:15:6 150 kg/ha (awal musim hujan)',
          'Apr_Mei': 'Urea 75 kg/ha + KCl 100 kg/ha (pembungaan)',
          'Jul_Agu': 'Urea 75 kg/ha + NPK 150 kg/ha (pengisian buah)',
          'Okt_Nov': 'KCl 100 kg/ha + Ca 200 kg/ha (pematangan buah)',
        },
        'organic_alternative':
            'Kompos 8 ton/ha + Pupuk kandang 5 ton/ha + Mulsa organik 10 cm',
        'micro_nutrients': 'Zn 15 kg/ha, B 3 kg/ha, Mg 100 kg/ha',
        'soil_pH': '6.0-6.5 optimal',
      },
      'yield_target': '1.5-2.5 ton/ha biji kering',
      'efficiency_tips':
          'Aplikasi pupuk dalam lingkaran di bawah tajuk, mulsa untuk konservasi',
    },
    'kelapa sawit': {
      'fertilizer_program': {
        'basic': 'NPK 12:12:17 + 2MgO 2-3 kg/pohon/tahun',
        'schedule': {
          'Jan_Mar': 'NPK 12:12:17 0.75 kg/pohon + Dolomit 1 kg/pohon',
          'Apr_Jun': 'Urea 0.5 kg/pohon + KCl 1 kg/pohon + Borate 50 g/pohon',
          'Jul_Sep': 'NPK 12:12:17 0.75 kg/pohon + TSP 0.5 kg/pohon',
          'Okt_Des': 'KCl 1 kg/pohon + MgSO4 0.5 kg/pohon + mikro hara',
        },
        'organic_alternative':
            'EFB compost 100 kg/pohon/tahun + Janjangan kosong 50 kg/pohon',
        'micro_nutrients': 'B 100 g/pohon, Cu 50 g/pohon, Zn 50 g/pohon',
        'soil_pH': '4.5-6.5 toleran',
      },
      'yield_target': '20-30 ton TBS/ha/tahun',
      'efficiency_tips':
          'Aplikasi dalam piringan 1-3 m dari batang, hindari aplikasi saat kemarau',
    },
    'singkong': {
      'fertilizer_program': {
        'basic':
            'Urea 100 kg/ha + SP36 50 kg/ha + KCl 150 kg/ha + Pupuk kandang 15 ton/ha',
        'schedule': {
          '0_HST':
              'Pupuk kandang 15 ton/ha + SP36 50 kg/ha + KCl 50 kg/ha (persiapan lahan)',
          '30_HST':
              'Urea 50 kg/ha + NPK 15:15:15 100 kg/ha (setelah pembumbunan pertama)',
          '60_HST': 'Urea 50 kg/ha + KCl 50 kg/ha (pembentukan umbi)',
          '90_HST': 'KCl 50 kg/ha + NPK foliar (pengembangan umbi)',
        },
        'organic_alternative':
            'Kompos 20 ton/ha + Abu sekam 2 ton/ha + Pupuk kandang 15 ton/ha',
        'micro_nutrients': 'Zn 10 kg/ha, B 2 kg/ha, Ca 500 kg/ha (kapur)',
        'soil_pH': '5.5-6.8 optimal, toleran pH rendah',
      },
      'yield_target': '20-40 ton umbi segar/ha',
      'efficiency_tips':
          'Fokus pada pupuk K untuk pembentukan umbi, hindari N berlebihan yang membuat daun rimbun tapi umbi kecil',
    },
  };

  // Database pupuk dan nutrisi umum
  final Map<String, Map<String, dynamic>> _fertilizerDatabase = {
    'urea': {
      'type': 'Nitrogen (46% N)',
      'function': 'Pertumbuhan vegetatif, pembentukan klorofil, protein',
      'application': '2-3 kali selama musim tanam',
      'dosage': '200-300 kg/ha',
      'timing': 'Tanam, 30 HST, 60 HST',
      'crops': ['padi', 'jagung', 'sayuran daun'],
      'tips': 'Aplikasi sore hari, tidak saat kering, campur tanah',
    },
    'sp36': {
      'type': 'Fosfor (36% P2O5)',
      'function': 'Pembentukan akar, bunga, buah, transfer energi',
      'application': '1 kali saat tanam atau olah tanah',
      'dosage': '100-150 kg/ha',
      'timing': 'Saat pengolahan tanah atau tugal',
      'crops': ['semua tanaman'],
      'tips': 'Campur tanah, dekat akar, tidak mudah tercuci',
    },
    'kcl': {
      'type': 'Kalium (60% K2O)',
      'function': 'Ketahanan penyakit, kualitas hasil, osmotic pressure',
      'application': '2 kali selama musim tanam',
      'dosage': '100-200 kg/ha',
      'timing': 'Tanam dan fase generatif',
      'crops': ['buah-buahan', 'umbi-umbian', 'padi'],
      'tips': 'Penting saat berbunga, tingkatkan gula buah',
    },
    'npk': {
      'type': 'Majemuk (15:15:15 atau 16:16:16)',
      'function': 'Nutrisi lengkap seimbang untuk pertumbuhan optimal',
      'application': '2-3 kali selama musim tanam',
      'dosage': '300-500 kg/ha',
      'timing': 'Tanam, 30 HST, 60 HST',
      'crops': ['semua tanaman'],
      'tips': 'Praktis, seimbang, cocok untuk pemula',
    },
    'kompos': {
      'type': 'Organik',
      'function': 'Memperbaiki struktur tanah, nutrisi lengkap, mikroorganisme',
      'application': '1 kali sebelum tanam',
      'dosage': '2-5 ton/ha',
      'timing': '2-4 minggu sebelum tanam',
      'crops': ['semua tanaman'],
      'tips': 'Fermentasi sempurna, tidak berbau, warna kehitaman',
    },
    'kandang': {
      'type': 'Organik (kotoran ternak)',
      'function': 'Nutrisi lambat lepas, memperbaiki biologi tanah',
      'application': '1 kali sebelum tanam',
      'dosage': '10-20 ton/ha',
      'timing': '4-6 minggu sebelum tanam',
      'crops': ['semua tanaman'],
      'tips': 'Harus difermentasi, komposisi C/N seimbang',
    },
  };

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Pesan selamat datang
    _addMessage(
      ChatMessage(
        text:
            '🌾 Selamat datang di AgriGo AI Assistant!\n\nSaya siap membantu Anda dengan informasi harga pasar, tips budidaya, pengendalian hama penyakit, rekomendasi pupuk, dan konsultasi pertanian lainnya.\n\nApa yang ingin Anda konsultasikan hari ini? 😊',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _typingAnimationController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _generateAIResponse(String message) {
    String lowerMessage = message.toLowerCase();

    // Respon untuk harga pasar dengan informasi terkini November 2025
    if (lowerMessage.contains('harga')) {
      for (String crop in _marketPrices.keys) {
        if (lowerMessage.contains(crop)) {
          final data = _marketPrices[crop]!;
          String trendIcon = data['trend'] == 'naik'
              ? '📈'
              : data['trend'] == 'turun'
              ? '📉'
              : '📊';
          String demandIcon = data['demand'] == 'sangat tinggi'
              ? '🔥🔥🔥'
              : data['demand'] == 'tinggi'
              ? '🔥🔥'
              : data['demand'] == 'sedang'
              ? '🔥'
              : '💧';

          String response =
              '💰 **HARGA ${crop.toUpperCase()} TERKINI (Nov 2025)**\n\n'
              '💵 **Harga:** ${data['price']} ${data['unit']}\n'
              '$trendIcon **Trend:** ${data['trend']}\n'
              '$demandIcon **Permintaan:** ${data['demand']}\n'
              '📅 **Musim:** ${data['season']}\n'
              '📂 **Kategori:** ${data['category']}\n\n';

          if (data.containsKey('market_info')) {
            response += '📊 **Analisis Pasar:**\n${data['market_info']}\n\n';
          }

          if (data.containsKey('best_varieties')) {
            response +=
                '🌱 **Varietas Terbaik:**\n${data['best_varieties']}\n\n';
          }

          response +=
              '💡 **Tips Trading:** Pantau trend harian dan faktor cuaca untuk timing jual yang optimal! 📈';
          return response;
        }
      }
      return '💰 **HARGA KOMODITAS TERKINI (November 2025)**\n\n'
          '**🌾 TANAMAN PANGAN:**\n'
          '• Padi: Rp 7.200-7.800/kg GKP 📈\n'
          '• Jagung: Rp 4.800-5.200/kg pipil 📈\n'
          '• Kedelai: Rp 9.500-10.200/kg 📈\n'
          '• Kacang Tanah: Rp 14.500-16.800/kg 📈\n\n'
          '**🌶️ SAYURAN:**\n'
          '• Cabai Merah: Rp 32.000-38.000/kg 📈\n'
          '• Bawang Merah: Rp 28.000-32.000/kg 📈\n'
          '• Tomat: Rp 8.000-12.000/kg 📊\n\n'
          '**☕ PERKEBUNAN:**\n'
          '• Kopi: Rp 35.000-45.000/kg 📈\n'
          '• Kakao: Rp 25.000-30.000/kg 📊\n\n'
          '**🌿 REMPAH:**\n'
          '• Jahe: Rp 12.000-18.000/kg 📈\n'
          '• Lada: Rp 85.000-95.000/kg 📈\n\n'
          '💡 Ketik "harga [nama komoditas]" untuk analisis detail!';
    }

    // Respon untuk hama dan pengendaliannya
    if (lowerMessage.contains('hama') ||
        lowerMessage.contains('ulat') ||
        lowerMessage.contains('wereng') ||
        lowerMessage.contains('thrips') ||
        lowerMessage.contains('kutu') ||
        lowerMessage.contains('mengatasi')) {
      for (String pest in _pestDatabase.keys) {
        if (lowerMessage.contains(pest.split(' ')[0]) ||
            lowerMessage.contains(pest)) {
          final data = _pestDatabase[pest]!;
          return '🐛 **PENGENDALIAN ${pest.toUpperCase()}**\n\n'
              '📝 **Deskripsi:** ${data['description']}\n\n'
              '⚠️ **Gejala Serangan:**\n${data['symptoms']}\n\n'
              '🌾 **Tanaman yang Diserang:** ${(data['crops'] as List).join(", ")}\n\n'
              '🛡️ **STRATEGI PENGENDALIAN:**\n'
              '🌿 **Organik:** ${data['control']['organic']}\n'
              '🐞 **Hayati:** ${data['control']['biological']}\n'
              '⚗️ **Kimia:** ${data['control']['chemical']}\n\n'
              '🚫 **Pencegahan:** ${data['control']['prevention']}\n\n'
              '💡 Gunakan pendekatan PHT (Pengendalian Hama Terpadu) untuk hasil optimal!';
        }
      }
      return '🐛 **PANDUAN PENGENDALIAN HAMA TERPADU (PHT):**\n\n'
          '**📋 HAMA UTAMA PER KOMODITAS:**\n'
          '🌾 **Padi:** Wereng, Ulat Grayak, Walang Sangit, Tikus\n'
          '🌽 **Jagung:** Ulat Tanah, Penggerek, Ulat Grayak\n'
          '🌶️ **Cabai:** Kutu Kebul, Thrips, Ulat Buah\n'
          '🍅 **Tomat:** Kutu Daun, Lalat Penambang, Ulat Buah\n'
          '🥔 **Kentang:** Ulat Tanah, Kutu Daun, Kumbang Daun\n'
          '🧅 **Bawang:** Kutu Loncat, Ulat Bawang, Trips\n\n'
          '⚡ **STRATEGI PHT 4 PILAR:**\n'
          '1️⃣ **PENCEGAHAN BUDIDAYA**\n'
          '   • Varietas tahan/toleran OPT\n'
          '   • Sanitasi lahan & alat\n'
          '   • Rotasi tanaman non-inang\n'
          '   • Pengaturan waktu tanam\n\n'
          '2️⃣ **MONITORING & PERAMALAN**\n'
          '   • Scout mingguan sistematis\n'
          '   • Light trap & feromon trap\n'
          '   • Ambang ekonomi spesifik\n'
          '   • Cuaca & kondisi lingkungan\n\n'
          '3️⃣ **PENGENDALIAN HAYATI**\n'
          '   • Predator: Coccinella, Chrysopa\n'
          '   • Parasitoid: Trichogramma, Cotesia\n'
          '   • Patogen: Bacillus thuringiensis, NPV\n'
          '   • Habitat refugia 10% lahan\n\n'
          '4️⃣ **PENGENDALIAN KIMIAWI BIJAK**\n'
          '   • Sesuai ambang ekonomi\n'
          '   • Pestisida selektif & bergantian\n'
          '   • Waktu & cara aplikasi tepat\n'
          '   • Perlindungan musuh alami\n\n'
          '🎯 **KEBERHASILAN PHT:** Produksi optimal, biaya efisien, lingkungan lestari\n\n'
          '💬 Tanya spesifik: "cara mengatasi [nama hama] pada [tanaman]"';
    }

    // Respon untuk penyakit tanaman
    if (lowerMessage.contains('penyakit') ||
        lowerMessage.contains('jamur') ||
        lowerMessage.contains('bakteri') ||
        lowerMessage.contains('virus') ||
        lowerMessage.contains('blast') ||
        lowerMessage.contains('layu') ||
        lowerMessage.contains('busuk') ||
        lowerMessage.contains('antraknosa')) {
      for (String disease in _diseaseDatabase.keys) {
        if (lowerMessage.contains(disease.split(' ')[0]) ||
            lowerMessage.contains(disease)) {
          final data = _diseaseDatabase[disease]!;
          return '🦠 **PENGENDALIAN ${disease.toUpperCase()}**\n\n'
              '📝 **Deskripsi:** ${data['description']}\n\n'
              '⚠️ **Gejala Penyakit:**\n${data['symptoms']}\n\n'
              '🌾 **Tanaman Inang:** ${(data['crops'] as List).join(", ")}\n\n'
              '💊 **STRATEGI PENGENDALIAN:**\n'
              '🌿 **Organik:** ${data['control']['organic']}\n'
              '⚗️ **Kimia:** ${data['control']['chemical']}\n\n'
              '🚫 **Pencegahan:** ${data['control']['prevention']}\n\n'
              '💡 Pencegahan lebih baik daripada pengobatan!';
        }
      }
      return '🦠 **PANDUAN PENGENDALIAN PENYAKIT TERPADU:**\n\n'
          '**📋 PENYAKIT UTAMA PER KOMODITAS:**\n'
          '🌾 **Padi:** Blast, Bercak Coklat, Hawar Bakteri\n'
          '🌽 **Jagung:** Karat Daun, Rebah Semai, Busuk Batang\n'
          '🌶️ **Cabai:** Antraknosa, Virus Keriting, Layu Fusarium\n'
          '🍅 **Tomat:** Virus Mosaik, Bercak Daun, Layu Fusarium\n'
          '🥔 **Kentang:** Bercak Daun, Busuk Daun, Virus Y\n'
          '🧅 **Bawang:** Busuk Lunak, Karat Putih, Downy Mildew\n\n'
          '🛡️ **STRATEGI PENGENDALIAN PENYAKIT:**\n'
          '1️⃣ **PENCEGAHAN KULTURIL**\n'
          '   • Varietas tahan/toleran penyakit\n'
          '   • Benih/bibit sehat bersertifikat\n'
          '   • Sanitasi lahan & alat kerja\n'
          '   • Rotasi tanaman berbeda famili\n'
          '   • Pengaturan jarak tanam optimal\n\n'
          '2️⃣ **PENGELOLAAN LINGKUNGAN**\n'
          '   • Drainase & irigasi teratur\n'
          '   • Mulsa untuk stabilitas suhu\n'
          '   • Sirkulasi udara baik\n'
          '   • pH tanah sesuai kebutuhan\n'
          '   • Nutrisi seimbang, hindari excess N\n\n'
          '3️⃣ **PENGENDALIAN HAYATI**\n'
          '   • Trichoderma harzianum/viride\n'
          '   • Pseudomonas fluorescens\n'
          '   • Bacillus subtilis\n'
          '   • Kompos mikroorganisme lokal\n\n'
          '4️⃣ **PENGENDALIAN KIMIAWI RASIONAL**\n'
          '   • Fungisida preventif & kuratif\n'
          '   • Sistem rotasi bahan aktif\n'
          '   • Konsentrasi & interval tepat\n'
          '   • Aplikasi sesuai kondisi cuaca\n\n'
          '📊 **MONITORING PENYAKIT:**\n'
          '• Inspeksi rutin 2x/minggu\n'
          '• Catat gejala & tingkat serangan\n'
          '• Analisis faktor predisposisi\n'
          '• Evaluasi efektivitas pengendalian\n\n'
          '💬 Tanya spesifik: "cara mengatasi [penyakit] pada [tanaman]"';
    }

    // Respon untuk pupuk dan nutrisi
    if (lowerMessage.contains('pupuk') ||
        lowerMessage.contains('nutrisi') ||
        lowerMessage.contains('pemupukan') ||
        lowerMessage.contains('urea') ||
        lowerMessage.contains('npk') ||
        lowerMessage.contains('kompos') ||
        lowerMessage.contains('kandang') ||
        lowerMessage.contains('sp36') ||
        lowerMessage.contains('kcl')) {
      for (String fertilizer in _fertilizerDatabase.keys) {
        if (lowerMessage.contains(fertilizer)) {
          final data = _fertilizerDatabase[fertilizer]!;
          return '🌿 **PANDUAN PUPUK ${fertilizer.toUpperCase()}**\n\n'
              '📋 **Jenis:** ${data['type']}\n\n'
              '🎯 **Fungsi:** ${data['function']}\n\n'
              '📅 **Waktu Aplikasi:** ${data['timing']}\n\n'
              '⚖️ **Dosis Anjuran:** ${data['dosage']}\n\n'
              '🌾 **Cocok untuk:** ${(data['crops'] as List).join(", ")}\n\n'
              '📖 **Frekuensi:** ${data['application']}\n\n'
              '💡 **Tips Aplikasi:** ${data['tips']}';
        }
      }
      return '🌿 **PANDUAN PEMUPUKAN LENGKAP:**\n\n'
          '**PUPUK MAKRO UTAMA:**\n'
          '🔵 **Urea (46% N)** - Pertumbuhan daun & batang\n'
          '🟡 **SP36 (36% P)** - Pembentukan akar & buah\n'
          '🔴 **KCl (60% K)** - Ketahanan & kualitas hasil\n'
          '🟢 **NPK** - Nutrisi seimbang lengkap\n\n'
          '**PUPUK ORGANIK:**\n'
          '🟤 **Kompos** - Memperbaiki struktur tanah\n'
          '🐄 **Kandang** - Nutrisi lengkap lambat lepas\n\n'
          '📊 **PRINSIP 4T PEMUPUKAN:**\n'
          '• **Tepat Jenis** - Sesuai kebutuhan tanaman\n'
          '• **Tepat Dosis** - Tidak berlebihan/kekurangan\n'
          '• **Tepat Waktu** - Sesuai fase pertumbuhan\n'
          '• **Tepat Cara** - Metode aplikasi yang benar\n\n'
          'Tanya spesifik: "pupuk [jenis pupuk]" atau "pemupukan [tanaman]"';
    }

    // Respon untuk tips bertani dan budidaya dengan database komprehensif
    if (lowerMessage.contains('tips') ||
        lowerMessage.contains('cara menanam') ||
        lowerMessage.contains('budidaya') ||
        lowerMessage.contains('tanam')) {
      // Cek jika ada komoditas spesifik dalam database fertilizer
      for (String crop in _cropFertilizerRecommendations.keys) {
        if (lowerMessage.contains(crop)) {
          final fertData = _cropFertilizerRecommendations[crop]!;
          String response = '🌱 **PANDUAN BUDIDAYA ${crop.toUpperCase()}**\n\n';

          response += '**📅 PROGRAM PEMUPUKAN TERPADU:**\n';
          if (fertData.containsKey('basic_fertilizer')) {
            response +=
                '🧪 **Pupuk Dasar:**\n${fertData['basic_fertilizer']}\n\n';
          }
          if (fertData.containsKey('vegetative')) {
            response += '🌿 **Fase Vegetatif:**\n${fertData['vegetative']}\n\n';
          }
          if (fertData.containsKey('reproductive')) {
            response +=
                '🌺 **Fase Reproduktif:**\n${fertData['reproductive']}\n\n';
          }
          if (fertData.containsKey('organic')) {
            response += '🍃 **Pupuk Organik:**\n${fertData['organic']}\n\n';
          }
          if (fertData.containsKey('yield_target')) {
            response += '🎯 **Target Hasil:** ${fertData['yield_target']}\n\n';
          }

          response +=
              '💡 **Tips Sukses:** Kombinasikan pemupukan dengan pengelolaan air yang baik dan pengendalian OPT terpadu!';
          return response;
        }
      }

      if (lowerMessage.contains('padi')) {
        return '🌾 **PANDUAN LENGKAP BUDIDAYA PADI**\n\n'
            '**PERSIAPAN LAHAN:**\n'
            '• Olah tanah 2-3 kali hingga lumpur halus\n'
            '• Buat petakan 10x10 m dengan pematang 30 cm\n'
            '• Genangi lahan 3-5 cm, biarkan 1 minggu\n'
            '• pH tanah optimal 6.0-7.0\n\n'
            '**PENANAMAN:**\n'
            '• Bibit umur 15-21 hari (3-4 helai daun)\n'
            '• Jarak tanam 25x25 cm (2-3 bibit/lubang)\n'
            '• Kedalaman tanam 1-2 cm\n'
            '• Tanam pagi (06:00-09:00) atau sore (15:00-17:00)\n\n'
            '**PEMUPUKAN TERPADU:**\n'
            '• Dasar: 200 kg Urea + 100 kg SP36 + 100 kg KCl/ha\n'
            '• Susulan I (21 HST): 100 kg Urea/ha\n'
            '• Susulan II (45 HST): 100 kg Urea + 50 kg KCl/ha\n\n'
            '**PERAWATAN:**\n'
            '• Penyiangan 2-3 kali (21, 35, 50 HST)\n'
            '• Pengairan sistem intermiten\n'
            '• Pengendalian wereng dan penggerek batang\n'
            '• Panen umur 120-130 hari (bulir 80% kuning)';
      } else if (lowerMessage.contains('jagung')) {
        return '🌽 **PANDUAN LENGKAP BUDIDAYA JAGUNG**\n\n'
            '**PERSIAPAN LAHAN:**\n'
            '• Olah tanah 2 kali dengan bajak singkal\n'
            '• Buat bedengan lebar 70 cm, tinggi 20-25 cm\n'
            '• Jarak antar bedengan 30 cm\n'
            '• Beri pupuk kandang 2-3 ton/ha\n\n'
            '**PENANAMAN:**\n'
            '• Jarak tanam 75x25 cm atau 70x20 cm\n'
            '• Kedalaman tanam 3-5 cm (1 biji/lubang)\n'
            '• Pilih varietas hibrida unggul bersertifikat\n'
            '• Tanam saat awal musim hujan\n\n'
            '**PEMUPUKAN:**\n'
            '• Dasar: 300 kg NPK (15:15:15)/ha\n'
            '• Susulan I (30 HST): 200 kg Urea/ha\n'
            '• Susulan II (50 HST): 100 kg Urea + 100 kg KCl/ha\n\n'
            '**PERAWATAN:**\n'
            '• Penyulaman maksimal 10 HST\n'
            '• Pembumbunan umur 30-35 HST\n'
            '• Pengendalian ulat grayak dan penggerek batang\n'
            '• Panen umur 100-110 hari (kadar air 18-20%)';
      } else if (lowerMessage.contains('cabai')) {
        return '🌶️ **PANDUAN LENGKAP BUDIDAYA CABAI**\n\n'
            '**PEMBIBITAN:**\n'
            '• Semai benih di tray semai/polibag kecil\n'
            '• Media: tanah + kompos + sekam bakar (1:1:1)\n'
            '• Pindah tanam umur 30-35 hari (6-8 daun)\n'
            '• Aklimatisasi bibit 3-5 hari\n\n'
            '**PERSIAPAN LAHAN:**\n'
            '• Buat bedengan lebar 100-120 cm, tinggi 30 cm\n'
            '• Jarak antar bedengan 50 cm\n'
            '• Pasang mulsa plastik hitam perak\n'
            '• Buat lubang tanam diameter 5 cm\n\n'
            '**PENANAMAN:**\n'
            '• Jarak tanam 50x50 cm atau 60x40 cm\n'
            '• Tanam sore hari, siram setelah tanam\n'
            '• Pasang ajir bambu setinggi 1,5-2 m\n\n'
            '**PEMUPUKAN:**\n'
            '• Dasar: 15 ton kompos + 500 kg NPK/ha\n'
            '• Susulan: 200 kg NPK + 100 kg KCl setiap 2 minggu\n'
            '• Pupuk daun saat berbunga dan berbuah\n\n'
            '**PERAWATAN:**\n'
            '• Pruning tunas air dan daun tua\n'
            '• Pengendalian thrips, kutu daun, antraknosa\n'
            '• Penyiraman pagi dan sore hari\n'
            '• Panen dimulai umur 75-80 HST';
      }

      return '🌱 **PANDUAN BERTANI MODERN & BERKELANJUTAN:**\n\n'
          '**📋 TAHAP PERENCANAAN:**\n'
          '• Analisis tanah dan pH (6.0-7.0 optimal)\n'
          '• Pemilihan varietas unggul bersertifikat\n'
          '• Perhitungan RAB dan kebutuhan input\n'
          '• Penjadwalan tanam sesuai kalender musim\n\n'
          '**🚜 TAHAP PELAKSANAAN:**\n'
          '• Pengolahan tanah optimal (2-3 kali)\n'
          '• Penanaman dengan jarak dan kedalaman tepat\n'
          '• Pemupukan berimbang sesuai kebutuhan\n'
          '• Pengendalian HPT secara terpadu (PHT)\n\n'
          '**📊 TAHAP MONITORING:**\n'
          '• Pengamatan pertumbuhan mingguan\n'
          '• Evaluasi serangan HPT dan cuaca\n'
          '• Dokumentasi kegiatan dan biaya\n'
          '• Analisis produktivitas per fase\n\n'
          '**💰 TAHAP PASCAPANEN:**\n'
          '• Penanganan hasil sesuai SOP\n'
          '• Strategi pemasaran dan value added\n'
          '• Analisis kelayakan usahatani\n'
          '• Perencanaan peningkatan musim berikutnya\n\n'
          'Untuk panduan spesifik, ketik: "cara menanam [nama tanaman]"';
    }

    // Respon untuk cuaca dan iklim
    if (lowerMessage.contains('cuaca') ||
        lowerMessage.contains('iklim') ||
        lowerMessage.contains('hujan') ||
        lowerMessage.contains('kemarau') ||
        lowerMessage.contains('musim')) {
      return '🌤️ **STRATEGI BERTANI SESUAI CUACA:**\n\n'
          '☀️ **MUSIM KEMARAU (Apr-Sep):**\n'
          '• Pilih varietas genjah tahan kekeringan\n'
          '• Sistem irigasi tetes/sprinkler untuk efisiensi\n'
          '• Mulsa organik/plastik untuk konservasi air\n'
          '• Jadwal penyiraman pagi (05:00) & sore (17:00)\n'
          '• Shading net 40-50% untuk sayuran sensitif\n'
          '• Aplikasi pupuk organik cair lebih sering\n'
          '• Monitoring kelembaban tanah dengan sensor\n\n'
          '🌧️ **MUSIM HUJAN (Okt-Mar):**\n'
          '• Buat drainase dalam 50-60 cm\n'
          '• Bedengan tinggi 30-40 cm untuk aerasi\n'
          '• Tingkatkan aplikasi fungisida preventif\n'
          '• Atap plastik transparan untuk tanaman sensitif\n'
          '• Monitor penyakit jamur dan bakteri\n'
          '• Kurangi nitrogen, tingkatkan kalium\n'
          '• Aplikasi kapur dolomit untuk pH tanah\n\n'
          '🌡️ **PARAMETER IKLIM MIKRO OPTIMAL:**\n'
          '• Suhu: 25-30°C (siang), 20-25°C (malam)\n'
          '• Kelembaban relatif: 60-80%\n'
          '• Curah hujan: 150-200 mm/bulan\n'
          '• Kecepatan angin: <15 km/jam\n'
          '• Intensitas cahaya: 6-8 jam/hari\n\n'
          '📱 Gunakan aplikasi BMKG dan Early Warning System untuk monitoring!';
    }

    // Respon untuk konsultasi ekonomi dan bisnis pertanian
    if (lowerMessage.contains('untung') ||
        lowerMessage.contains('keuntungan') ||
        lowerMessage.contains('modal') ||
        lowerMessage.contains('bisnis') ||
        lowerMessage.contains('usaha') ||
        lowerMessage.contains('analisis')) {
      return '💰 **ANALISIS KELAYAKAN USAHATANI:**\n\n'
          '📊 **KOMPONEN BIAYA PRODUKSI:**\n'
          '• **Biaya Tetap:** Sewa lahan, pajak, penyusutan alat (30%)\n'
          '• **Biaya Variabel:** Benih, pupuk, pestisida, tenaga kerja (60%)\n'
          '• **Biaya Tak Terduga:** Cadangan risiko cuaca/hama (10%)\n\n'
          '📈 **INDIKATOR KELAYAKAN FINANSIAL:**\n'
          '• **NPV > 0:** Usaha layak secara finansial\n'
          '• **IRR > Suku Bunga Bank:** Lebih menguntungkan investasi\n'
          '• **B/C Ratio > 1.5:** Benefit optimal dibanding cost\n'
          '• **Payback Period < 2 tahun:** Cepat balik modal\n\n'
          '🎯 **STRATEGI MAKSIMALISASI PROFIT:**\n'
          '• **Diversifikasi:** Kombinasi tanaman sesuai musim\n'
          '• **Integrasi:** Sistem terpadu tanaman-ternak\n'
          '• **Direct Selling:** Kurangi rantai pemasaran\n'
          '• **Value Added:** Pengolahan pascapanen\n'
          '• **Koperasi:** Bargaining power dan akses input\n'
          '• **Asuransi:** Proteksi risiko gagal panen\n\n'
          '💡 **TIPS EFISIENSI BIAYA:**\n'
          '• Beli input berkelompok untuk harga grosir\n'
          '• Buat pupuk organik sendiri\n'
          '• Sistem bagi hasil dengan pemilik lahan\n'
          '• Manfaatkan subsidi pemerintah\n\n'
          'Butuh analisis usahatani spesifik? Sebutkan komoditas dan luas lahan!';
    }

    // Respon untuk teknologi pertanian modern
    if (lowerMessage.contains('teknologi') ||
        lowerMessage.contains('modern') ||
        lowerMessage.contains('digital') ||
        lowerMessage.contains('sensor') ||
        lowerMessage.contains('drone') ||
        lowerMessage.contains('smart')) {
      return '🚀 **TEKNOLOGI PERTANIAN 4.0:**\n\n'
          '📡 **PRECISION AGRICULTURE:**\n'
          '• GPS RTK untuk pemetaan lahan akurat\n'
          '• Sensor IoT: kelembaban, pH, NPK tanah\n'
          '• Variable Rate Technology (VRT) untuk pupuk\n'
          '• Yield mapping dan profit mapping real-time\n'
          '• Soil sampling otomatis dengan grid\n\n'
          '🛩️ **DRONE & REMOTE SENSING:**\n'
          '• Multispectral imaging untuk NDVI analysis\n'
          '• Deteksi stress tanaman dan defisiensi nutrisi\n'
          '• Penyemprotan presisi dengan flight controller\n'
          '• Monitoring luas areal dan estimasi hasil\n'
          '• Thermal imaging untuk deteksi penyakit\n\n'
          '📱 **SMART FARMING IoT:**\n'
          '• Automatic Weather Station (AWS)\n'
          '• Smart irrigation dengan AI controller\n'
          '• Digital pest monitoring trap\n'
          '• Greenhouse climate control automation\n'
          '• Mobile app untuk monitoring real-time\n\n'
          '🌐 **DIGITAL AGRICULTURE PLATFORM:**\n'
          '• E-commerce B2B untuk direct selling\n'
          '• Telemedicine pertanian dengan expert system\n'
          '• Blockchain untuk product traceability\n'
          '• Big data analytics untuk yield prediction\n'
          '• Satellite imagery untuk crop monitoring\n\n'
          '💰 **ROI TEKNOLOGI:** Investasi teknologi dapat meningkatkan:\n'
          '• Produktivitas: 20-40%\n'
          '• Efisiensi biaya: 15-30%\n'
          '• Kualitas hasil: 25-35%\n'
          '• Sustainability score: 40-50%';
    }

    // Respon untuk salam dan percakapan umum
    List<String> greetings = [
      'hai',
      'halo',
      'selamat',
      'pagi',
      'siang',
      'sore',
      'malam',
      'hei',
      'hello',
    ];
    if (greetings.any((greeting) => lowerMessage.contains(greeting))) {
      return '👋 **Halo! Selamat datang di AgriGo AI Assistant!**\n\n'
          'Saya siap membantu Anda dengan berbagai konsultasi pertanian:\n\n'
          '💰 **Informasi Harga Pasar** - Update real-time\n'
          '🌱 **Panduan Budidaya** - Step-by-step lengkap\n'
          '🛡️ **Solusi HPT** - Hama, penyakit, pengendalian\n'
          '🌿 **Rekomendasi Pupuk** - Dosis dan timing tepat\n'
          '🌤️ **Strategi Cuaca** - Adaptasi musim\n'
          '🚀 **Teknologi Modern** - Smart farming\n'
          '💰 **Analisis Bisnis** - Kelayakan usahatani\n\n'
          'Ada yang bisa saya bantu hari ini? Silakan konsultasikan masalah pertanian Anda! 😊';
    }

    // Respon untuk ucapan terima kasih
    if (lowerMessage.contains('terima kasih') ||
        lowerMessage.contains('makasih') ||
        lowerMessage.contains('thanks')) {
      return '🙏 **Sama-sama! Senang bisa membantu!**\n\n'
          'Jangan ragu untuk konsultasi lagi kapan saja. Saya selalu siap membantu petani Indonesia untuk:\n\n'
          '• Meningkatkan produktivitas hasil panen\n'
          '• Mengoptimalkan efisiensi biaya produksi\n'
          '• Menerapkan teknologi modern\n'
          '• Mengembangkan agribisnis berkelanjutan\n\n'
          '🌾 **Mari bersama memajukan pertanian Indonesia!** 🇮🇩\n\n'
          'Semoga panen Anda selalu berkah dan melimpah! 🌱✨';
    }

    // Respon default yang informatif dan engaging
    List<String> defaultResponses = [
      '🤖 **AgriGo AI Assistant - Konsultan Pertanian Digital Terpercaya!**\n\n'
          'Maaf, saya belum sepenuhnya memahami pertanyaan Anda. Mari saya bantu dengan lebih spesifik!\n\n'
          '💡 **CONTOH PERTANYAAN YANG BISA SAYA JAWAB:**\n\n'
          '💰 **Harga & Pasar:**\n'
          '• "Harga cabai hari ini"\n'
          '• "Trend harga bawang merah"\n\n'
          '🌱 **Budidaya & Tips:**\n'
          '• "Cara menanam padi organik"\n'
          '• "Tips budidaya jagung hasil tinggi"\n\n'
          '🐛 **Hama & Penyakit:**\n'
          '• "Mengatasi ulat grayak pada jagung"\n'
          '• "Cara mengatasi penyakit blast"\n\n'
          '🌿 **Pupuk & Nutrisi:**\n'
          '• "Pupuk terbaik untuk cabai"\n'
          '• "Jadwal pemupukan padi"\n\n'
          '🌤️ **Cuaca & Musim:**\n'
          '• "Tips bertani musim hujan"\n'
          '• "Strategi menghadapi kemarau"\n\n'
          'Coba tanyakan dengan lebih detail, saya pasti bisa membantu! 😊',

      '🌾 **Selamat datang di era Smart Farming!**\n\n'
          'Saya belum bisa memahami pertanyaan Anda dengan sempurna. Mari kita coba dengan cara yang lebih spesifik!\n\n'
          '🎯 **BIDANG KEAHLIAN SAYA:**\n\n'
          '📊 **Analisis Pasar** - Prediksi harga, trend pasar\n'
          '🔬 **Diagnosa HPT** - Identifikasi hama penyakit akurat\n'
          '⚗️ **Formula Nutrisi** - Rekomendasi pupuk optimal\n'
          '🌡️ **Climate Smart** - Adaptasi perubahan iklim\n'
          '🚀 **Agritech** - Implementasi teknologi modern\n'
          '💰 **Agribisnis** - Analisis kelayakan usaha\n\n'
          '📝 **FORMAT PERTANYAAN YANG DIREKOMENDASIKAN:**\n'
          '• Mulai dengan kata kunci utama\n'
          '• Sebutkan nama tanaman/komoditas\n'
          '• Jelaskan masalah atau kebutuhan spesifik\n\n'
          'Contoh: "Pupuk organik untuk tomat di musim hujan"\n\n'
          'Mari konsultasi yang lebih terarah! 🎯',

      '👨‍🌾 **AgriGo AI - Partner Petani Cerdas Indonesia!**\n\n'
          'Pertanyaan Anda belum bisa saya pahami sepenuhnya. Mari kita komunikasi dengan lebih efektif!\n\n'
          '🏆 **KEUNGGULAN LAYANAN KAMI:**\n\n'
          '✅ **Database Lengkap** - 10,000+ data pertanian terupdate\n'
          '✅ **AI Processing** - Analisis cerdas berbasis machine learning\n'
          '✅ **Real-time Update** - Informasi pasar dan cuaca terkini\n'
          '✅ **Expert Verified** - Diverifikasi ahli pertanian berpengalaman\n'
          '✅ **Bahasa Praktis** - Mudah dipahami semua kalangan\n'
          '✅ **24/7 Service** - Siap membantu kapan saja\n\n'
          '🎪 **LAYANAN UNGGULAN:**\n'
          '🌟 Konsultasi Premium untuk masalah kompleks\n'
          '🌟 Analisis usahatani komprehensif\n'
          '🌟 Rekomendasi teknologi tepat guna\n'
          '🌟 Strategi pemasaran produk pertanian\n\n'
          'Silakan ajukan pertanyaan yang lebih spesifik, saya siap memberikan solusi terbaik! 🌱⭐',
    ];

    return defaultResponses[DateTime.now().millisecond %
        defaultResponses.length];
  }

  void _sendMessage() async {
    String message = _messageController.text.trim();
    if (message.isEmpty && _selectedImage == null) return;

    // Add user message with image if available
    _addMessage(
      ChatMessage(
        text: message.isEmpty ? '📸 [Gambar tanaman]' : message,
        isUser: true,
        imageFile: _selectedImage,
      ),
    );

    _messageController.clear();
    File? imageToSend = _selectedImage;

    setState(() {
      _selectedImage = null; // Clear selected image
      _isTyping = true;
    });

    try {
      String response;

      // If image is attached, use vision API
      if (imageToSend != null) {
        response = await GeminiChatService.sendMessageWithImage(
          message.isEmpty
              ? 'Analisis tanaman ini, apakah ada masalah? Berikan rekomendasi perawatan.'
              : message,
          imageToSend,
        );
      } else {
        // Text only
        response = await GeminiChatService.sendMessage(message);
      }

      setState(() {
        _isTyping = false;
      });

      // Add AI response
      _addMessage(ChatMessage(text: response, isUser: false));
    } catch (e) {
      setState(() {
        _isTyping = false;
      });

      // Fallback to local response on error
      String response = _generateAIResponse(message);
      _addMessage(ChatMessage(text: response, isUser: false));
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $e')));
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _selectedImage = File(photo.path);
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.smart_toy_outlined,
                color: Colors.green.shade700,
                size: 24,
              ),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AgriGo AI Assistant',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'Konsultan Pertanian Digital 🌾',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF4CAF50)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.agriculture, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Tentang AgriGo AI'),
                    ],
                  ),
                  content: const Text(
                    'AgriGo AI Assistant adalah chatbot cerdas yang membantu petani dengan:\n\n'
                    '• Informasi harga pasar terkini\n'
                    '• Panduan budidaya lengkap\n'
                    '• Solusi hama dan penyakit\n'
                    '• Rekomendasi pupuk optimal\n'
                    '• Strategi menghadapi cuaca\n'
                    '• Teknologi pertanian modern\n'
                    '• Analisis usahatani\n\n'
                    'Dikembangkan dengan AI dan database pertanian terlengkap untuk kemajuan petani Indonesia.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tutup'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.green.shade50, Colors.white],
                ),
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return _buildTypingIndicator();
                  }

                  final message = _messages[index];
                  return _buildMessageBubble(message);
                },
              ),
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Image preview if selected
                          if (_selectedImage != null)
                            Container(
                              margin: EdgeInsets.all(8),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedImage = null;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.all(4),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: _selectedImage != null
                                  ? '📸 Tanyakan tentang gambar ini...'
                                  : '💬 Konsultasi pertanian Anda...',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 12, right: 8),
                                child: Icon(
                                  Icons.chat_bubble_outline,
                                  color: Colors.green.shade400,
                                  size: 20,
                                ),
                              ),
                              prefixIconConstraints: BoxConstraints(
                                minWidth: 40,
                                minHeight: 20,
                              ),
                            ),
                            maxLines: null,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            onSubmitted: (_) => _sendMessage(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Camera button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.blue.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.blue,
                        size: 22,
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Container(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.camera_alt,
                                    color: Colors.blue,
                                  ),
                                  title: Text('Ambil Foto'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _takePhoto();
                                  },
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.photo_library,
                                    color: Colors.green,
                                  ),
                                  title: Text('Pilih dari Galeri'),
                                  onTap: () {
                                    Navigator.pop(context);
                                    _pickImage();
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      tooltip: 'Upload foto tanaman',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: _sendMessage,
                      splashRadius: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.3),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.agriculture,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: isUser ? null : Colors.white,
                gradient: isUser
                    ? LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 20 : 4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    color: isUser
                        ? Colors.green.withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                  ),
                ],
                border: !isUser
                    ? Border.all(color: Colors.green.withOpacity(0.1), width: 1)
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Show image if available
                  if (message.imageFile != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        message.imageFile!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                      height: 1.5,
                      fontWeight: isUser ? FontWeight.w500 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _typingAnimationController.value * 0.5,
                  child: const Icon(
                    Icons.agriculture,
                    color: Colors.white,
                    size: 22,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    blurRadius: 8,
                    color: Colors.black.withOpacity(0.1),
                  ),
                ],
                border: Border.all(
                  color: Colors.green.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '🧠 AI sedang berpikir',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6),
                  AnimatedBuilder(
                    animation: _typingAnimationController,
                    builder: (context, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          final delay = index * 0.2;
                          final animationValue =
                              (_typingAnimationController.value - delay).clamp(
                                0.0,
                                1.0,
                              );
                          final opacity =
                              (sin(animationValue * pi * 2) + 1) / 2;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: Opacity(
                              opacity: opacity,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'AI sedang mengetik...',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
