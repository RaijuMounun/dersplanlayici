import 'package:flutter/material.dart';
import 'package:ders_planlayici/features/calendar/presentation/pages/calendar_page.dart';
import 'package:ders_planlayici/features/students/presentation/pages/student_list_page.dart';
import 'package:ders_planlayici/features/settings/presentation/pages/settings_page.dart';
import 'package:ders_planlayici/features/lessons/presentation/pages/lessons_page.dart';
import 'package:ders_planlayici/features/fees/presentation/pages/payment_list_page.dart';
import 'package:ders_planlayici/core/widgets/app_bottom_navigation.dart';
import 'package:ders_planlayici/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

/// Ana sayfa widget'ı. Bottom navigation bar ile farklı sayfalara geçiş sağlar.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const CalendarPage(),
    const LessonsPage(),
    const StudentListPage(),
    const PaymentListPage(),
    const SettingsPage(),
  ];

  final List<String> _titles = [
    'Takvim',
    'Dersler',
    'Öğrenciler',
    'Ödemeler',
    'Ayarlar',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: _buildActions(),
      ),
      body: _pages[_selectedIndex],
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          AppBottomNavigationItem(label: 'Takvim', icon: Icons.calendar_today),
          AppBottomNavigationItem(label: 'Dersler', icon: Icons.book),
          AppBottomNavigationItem(label: 'Öğrenciler', icon: Icons.people),
          AppBottomNavigationItem(label: 'Ödemeler', icon: Icons.payments),
          AppBottomNavigationItem(label: 'Ayarlar', icon: Icons.settings),
        ],
      ),
    );
  }

  List<Widget>? _buildActions() {
    // Seçili sayfaya göre app bar için action'ları döndür
    switch (_selectedIndex) {
      case 0: // Takvim
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Takvim sayfasında arama diyaloğunu göster
              _showSearchDialog(context, 'Takvimde Ara');
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Takvim filtreleme diyaloğunu göster
              _showFilterDialog(context, 'Takvim Filtreleri');
            },
          ),
        ];
      case 1: // Dersler
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Dersler sayfasında arama diyaloğunu göster
              _showSearchDialog(context, 'Derslerde Ara');
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Dersler filtreleme diyaloğunu göster
              _showFilterDialog(context, 'Ders Filtreleri');
            },
          ),
        ];
      case 2: // Öğrenciler
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Öğrenci arama diyaloğunu göster
              _showSearchDialog(context, 'Öğrencilerde Ara');
            },
          ),
        ];
      case 3: // Ödemeler
        return [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Ödeme arama diyaloğunu göster
              _showSearchDialog(context, 'Ödemelerde Ara');
            },
          ),
          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Ücret Yönetimi',
            onPressed: () {
              context.push('/fee-management');
            },
          ),
        ];
      case 4: // Ayarlar
        return null;
      default:
        return null;
    }
  }

  // Arama diyaloğunu gösterir
  void _showSearchDialog(BuildContext context, String title) {
    final TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: searchController,
          decoration: const InputDecoration(
            hintText: 'Ara...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          autofocus: true,
          onSubmitted: (value) {
            Navigator.pop(context, value);
            _performSearch(value);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, searchController.text);
              _performSearch(searchController.text);
            },
            child: const Text('Ara'),
          ),
        ],
      ),
    );
  }

  // Filtreleme diyaloğunu gösterir
  void _showFilterDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: double.maxFinite,
          child: _buildFilterOptions(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _applyFilters();
            },
            child: const Text('Uygula'),
          ),
        ],
      ),
    );
  }

  // Filtreleme seçeneklerini oluşturur
  Widget _buildFilterOptions() {
    // Seçili sayfaya göre filtreleme seçeneklerini göster
    switch (_selectedIndex) {
      case 0: // Takvim
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Takvim için filtreleme seçenekleri
            _buildFilterCheckbox('Tamamlanan Dersler', true),
            _buildFilterCheckbox('Planlanan Dersler', true),
            _buildFilterCheckbox('İptal Edilen Dersler', false),
            const Divider(),
            _buildDateRangeSelector(),
          ],
        );
      case 1: // Dersler
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dersler için filtreleme seçenekleri
            _buildFilterCheckbox('Tamamlanan', true),
            _buildFilterCheckbox('Planlanan', true),
            _buildFilterCheckbox('İptal Edilen', false),
            const Divider(),
            _buildFilterCheckbox('Bugün', false),
            _buildFilterCheckbox('Bu Hafta', true),
            _buildFilterCheckbox('Bu Ay', true),
          ],
        );
      default:
        return const Text('Bu sayfa için filtreleme seçeneği bulunmuyor.');
    }
  }

  // Filtreleme için checkbox oluşturur
  Widget _buildFilterCheckbox(String label, bool initialValue) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isChecked = initialValue;
        return CheckboxListTile(
          title: Text(label),
          value: isChecked,
          onChanged: (value) {
            if (value != null) {
              setState(() {
                isChecked = value;
              });
            }
          },
        );
      },
    );
  }

  // Tarih aralığı seçici
  Widget _buildDateRangeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Tarih Aralığı',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Başlangıç'),
                onPressed: () {
                  // Tarih seçimi
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                },
              ),
            ),
            Expanded(
              child: TextButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: const Text('Bitiş'),
                onPressed: () {
                  // Tarih seçimi
                  showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Arama işlemini gerçekleştirir
  void _performSearch(String query) {
    if (query.isEmpty) return;

    // Şu an için sadece snackbar gösteriyoruz,
    // gerçek implementasyon ilgili provider'lara bağlanmalıdır
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$query" araması yapılıyor...'),
        duration: const Duration(seconds: 2),
      ),
    );

    // Gerçek implementasyon örnek:
    // switch (_selectedIndex) {
    //   case 0: // Takvim
    //     Provider.of<CalendarProvider>(context, listen: false).search(query);
    //     break;
    //   case 1: // Dersler
    //     Provider.of<LessonProvider>(context, listen: false).search(query);
    //     break;
    //   ...
    // }
  }

  // Filtreleri uygular
  void _applyFilters() {
    // Şu an için sadece snackbar gösteriyoruz
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filtreler uygulanıyor...'),
        duration: Duration(seconds: 2),
      ),
    );

    // Gerçek implementasyon buraya gelecek
  }

  Widget? _buildFloatingActionButton() {
    // Seçili sayfaya göre FAB döndür
    switch (_selectedIndex) {
      case 0: // Takvim
        return FloatingActionButton(
          onPressed: () {
            context.push('/new-lesson');
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        );
      case 1: // Dersler
        return FloatingActionButton(
          onPressed: () {
            context.push('/new-lesson');
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        );
      case 2: // Öğrenciler
        return FloatingActionButton(
          onPressed: () {
            context.push('/add-student');
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.person_add),
        );
      case 3: // Ödemeler
        return FloatingActionButton(
          onPressed: () {
            context.push('/add-payment');
          },
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        );
      case 4: // Ayarlar
        return null;
      default:
        return null;
    }
  }
}
