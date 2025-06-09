import 'package:flutter/material.dart';

class StudentDetailsPage extends StatelessWidget {
  final String studentId;

  const StudentDetailsPage({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    // Gerçek uygulamada bu veriler bir servisten alınacak
    final Map<String, dynamic> student = {
      'id': studentId,
      'name': 'Ahmet Yılmaz',
      'grade': '5. Sınıf',
      'parentName': 'Mehmet Yılmaz',
      'phone': '+90 555 123 4567',
      'email': 'mehmet.yilmaz@example.com',
      'subjects': ['Matematik', 'Fen Bilgisi'],
      'notes': 'Matematik konusunda ekstra desteğe ihtiyacı var.',
    };

    // Öğrencinin geçmiş dersleri
    final List<Map<String, dynamic>> pastLessons = [
      {
        'date': '15 Mayıs 2023',
        'subject': 'Matematik',
        'topic': 'Kesirler',
        'duration': '90 dakika',
        'status': 'Tamamlandı',
      },
      {
        'date': '12 Mayıs 2023',
        'subject': 'Fen Bilgisi',
        'topic': 'Basit Makineler',
        'duration': '90 dakika',
        'status': 'Tamamlandı',
      },
    ];

    // Öğrencinin gelecek dersleri
    final List<Map<String, dynamic>> upcomingLessons = [
      {
        'date': '22 Mayıs 2023',
        'subject': 'Matematik',
        'topic': 'Ondalık Sayılar',
        'time': '14:00 - 15:30',
        'status': 'Planlandı',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Öğrenci Detayları'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Öğrenci düzenleme sayfasına git
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStudentHeader(context, student),
            const SizedBox(height: 24),
            _buildInfoSection(context, student),
            const SizedBox(height: 24),
            _buildNotesSection(context, student),
            const SizedBox(height: 24),
            _buildUpcomingLessonsSection(context, upcomingLessons),
            const SizedBox(height: 24),
            _buildPastLessonsSection(context, pastLessons),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // Yeni ders ekleme sayfasına git
        },
        icon: const Icon(Icons.add),
        label: const Text('Yeni Ders'),
      ),
    );
  }

  Widget _buildStudentHeader(
    BuildContext context,
    Map<String, dynamic> student,
  ) {
    return Row(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            student['name'].isNotEmpty ? student['name'][0].toUpperCase() : '',
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                student['grade'],
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: (student['subjects'] as List<String>).map((subject) {
                  return Chip(
                    label: Text(
                      subject,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(204),
                    padding: const EdgeInsets.all(4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Map<String, dynamic> student) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'İletişim Bilgileri',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(Icons.person, 'Veli', student['parentName']),
            const Divider(height: 24),
            _buildInfoRow(Icons.phone, 'Telefon', student['phone']),
            const Divider(height: 24),
            _buildInfoRow(Icons.email, 'E-posta', student['email']),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection(
    BuildContext context,
    Map<String, dynamic> student,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Notlar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Not düzenleme
                  },
                  iconSize: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(student['notes']),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingLessonsSection(
    BuildContext context,
    List<Map<String, dynamic>> lessons,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Yaklaşan Dersler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            lessons.isEmpty
                ? const Text('Planlanmış ders bulunmuyor.')
                : Column(
                    children: lessons.map((lesson) {
                      return _buildLessonItem(
                        context,
                        lesson,
                        isUpcoming: true,
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildPastLessonsSection(
    BuildContext context,
    List<Map<String, dynamic>> lessons,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Geçmiş Dersler',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            lessons.isEmpty
                ? const Text('Geçmiş ders bulunmuyor.')
                : Column(
                    children: lessons.map((lesson) {
                      return _buildLessonItem(
                        context,
                        lesson,
                        isUpcoming: false,
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(
    BuildContext context,
    Map<String, dynamic> lesson, {
    required bool isUpcoming,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isUpcoming ? Icons.event : Icons.event_available,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson['date'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('${lesson['subject']} - ${lesson['topic']}'),
                const SizedBox(height: 4),
                Text(
                  isUpcoming ? lesson['time'] : lesson['duration'],
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUpcoming
                  ? Colors.blue.withAlpha(50)
                  : Colors.green.withAlpha(50),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              lesson['status'],
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUpcoming ? Colors.blue : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
