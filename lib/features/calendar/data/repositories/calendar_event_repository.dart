import 'package:ders_planlayici/core/data/database_helper.dart';
import 'package:ders_planlayici/core/error/app_exception.dart' as app_exception;
import 'package:ders_planlayici/features/calendar/domain/models/calendar_event_model.dart';
import 'package:uuid/uuid.dart';

class CalendarEventRepository {
  final DatabaseHelper _databaseHelper;
  final _uuid = const Uuid();

  CalendarEventRepository({DatabaseHelper? databaseHelper})
    : _databaseHelper = databaseHelper ?? DatabaseHelper();

  /// Tüm takvim etkinliklerini getirir
  Future<List<CalendarEvent>> getAllEvents() async {
    try {
      final eventMaps = await _databaseHelper.getCalendarEvents();
      return eventMaps.map((map) => CalendarEvent.fromMap(map)).toList();
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Takvim etkinlikleri alınamadı',
        code: 'get_events_failed',
        details: e.toString(),
      );
    }
  }

  /// Belirli bir tarihe ait takvim etkinliklerini getirir
  Future<List<CalendarEvent>> getEventsByDate(String dateString) async {
    try {
      final eventMaps = await _databaseHelper.getCalendarEventsByDate(
        dateString,
      );
      return eventMaps.map((map) => CalendarEvent.fromMap(map)).toList();
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Tarihe göre takvim etkinlikleri alınamadı',
        code: 'get_events_by_date_failed',
        details: e.toString(),
      );
    }
  }

  /// Belirli bir takvim etkinliğini getirir
  Future<CalendarEvent?> getEventById(String id) async {
    try {
      final eventMap = await _databaseHelper.getCalendarEvent(id);
      if (eventMap != null) {
        return CalendarEvent.fromMap(eventMap);
      }
      return null;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Takvim etkinliği alınamadı',
        code: 'get_event_failed',
        details: e.toString(),
      );
    }
  }

  /// Yeni bir takvim etkinliği ekler
  Future<CalendarEvent> addEvent(CalendarEvent event) async {
    try {
      // Eğer ID yoksa, yeni bir ID oluştur
      final eventWithId = event.id.isEmpty
          ? event.copyWith(id: _uuid.v4())
          : event;

      await _databaseHelper.insertCalendarEvent(eventWithId.toMap());
      return eventWithId;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Takvim etkinliği eklenemedi',
        code: 'add_event_failed',
        details: e.toString(),
      );
    }
  }

  /// Bir takvim etkinliğini günceller
  Future<bool> updateEvent(CalendarEvent event) async {
    try {
      final result = await _databaseHelper.updateCalendarEvent(event.toMap());
      return result > 0;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Takvim etkinliği güncellenemedi',
        code: 'update_event_failed',
        details: e.toString(),
      );
    }
  }

  /// Bir takvim etkinliğini siler
  Future<bool> deleteEvent(String id) async {
    try {
      final result = await _databaseHelper.deleteCalendarEvent(id);
      return result > 0;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Takvim etkinliği silinemedi',
        code: 'delete_event_failed',
        details: e.toString(),
      );
    }
  }

  /// Derslerden takvim etkinlikleri oluşturur
  Future<List<CalendarEvent>> syncEventsFromLessons(
    List<Map<String, dynamic>> lessons,
  ) async {
    try {
      // İlk olarak mevcut takvim etkinliklerini alalım
      final existingEvents = await getAllEvents();

      // Yeni eklenecek etkinlikler listesi
      final List<CalendarEvent> newEvents = [];

      // Her ders için bir takvim etkinliği oluştur
      for (final lessonMap in lessons) {
        final lessonId = lessonMap['id'] as String;

        // Bu derse ait mevcut bir etkinlik var mı kontrol et
        final existingEvent =
            existingEvents
                .where(
                  (event) =>
                      event.metadata != null &&
                      event.metadata!['lessonId'] == lessonId,
                )
                .isEmpty
            ? null
            : existingEvents.firstWhere(
                (event) =>
                    event.metadata != null &&
                    event.metadata!['lessonId'] == lessonId,
              );

        // Dersten yeni bir CalendarEvent oluştur
        final lesson = {
          'id': lessonId,
          'subject': lessonMap['subject'],
          'studentName': lessonMap['studentName'],
          'studentId': lessonMap['studentId'],
          'topic': lessonMap['topic'],
          'date': lessonMap['date'],
          'startTime': lessonMap['startTime'],
          'endTime': lessonMap['endTime'],
          'status': lessonMap['status'],
        };

        // CalendarEvent'i oluştur
        final calendarEvent = _createEventFromLesson(lesson, existingEvent?.id);

        // Eğer mevcut bir etkinlik varsa, güncelle
        if (existingEvent != null) {
          await updateEvent(calendarEvent);
        } else {
          // Yoksa yeni ekle
          final addedEvent = await addEvent(calendarEvent);
          newEvents.add(addedEvent);
        }
      }

      return newEvents;
    } catch (e) {
      throw app_exception.DatabaseException(
        message: 'Dersler takvime eklenemedi',
        code: 'sync_events_failed',
        details: e.toString(),
      );
    }
  }

  /// Ders bilgilerinden CalendarEvent oluşturur
  CalendarEvent _createEventFromLesson(
    Map<String, dynamic> lesson, [
    String? eventId,
  ]) {
    final title = '${lesson['subject']} - ${lesson['studentName']}';
    final id = eventId ?? _uuid.v4();

    return CalendarEvent(
      id: id,
      title: lesson['topic'] != null && lesson['topic'].toString().isNotEmpty
          ? '$title (${lesson['topic']})'
          : title,
      date: lesson['date'],
      startTime: lesson['startTime'],
      endTime: lesson['endTime'],
      type: CalendarEventType.lesson,
      metadata: {
        'lessonId': lesson['id'],
        'studentId': lesson['studentId'],
        'subject': lesson['subject'],
        'status': lesson['status'],
      },
      color: _getColorForLessonStatus(lesson['status']),
      isAllDay: false,
    );
  }

  /// Ders durumuna göre renk döndürür
  String? _getColorForLessonStatus(String status) {
    switch (status) {
      case 'scheduled':
        return '#4CAF50'; // Yeşil
      case 'completed':
        return '#2196F3'; // Mavi
      case 'cancelled':
        return '#F44336'; // Kırmızı
      case 'postponed':
        return '#FF9800'; // Turuncu
      default:
        return '#9E9E9E'; // Gri
    }
  }
}
