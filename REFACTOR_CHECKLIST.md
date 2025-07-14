# Kapsamlı Refaktör Görev Listesi

Bu belge, projenin kalitesini, sürdürülebilirliğini ve yönetilebilirliğini artırmak için yapılması gereken refaktör görevlerini detaylı bir şekilde açıklamaktadır. Her görev, "Ne?", "Neden?" ve "Nasıl?" adımlarını içerir, böylece farklı geliştiriciler veya yapay zeka modelleri tarafından kolayca anlaşılıp uygulanabilir.

---

### **1. Proje Genelinde Klasör Yapısını Standartlaştırma**

- **Ne?**
    Proje içindeki tüm `features` (özellik) modüllerinde `.../presentation/pages` olarak adlandırılmış klasörlerin `.../presentation/screens` olarak yeniden adlandırılması. Şu anda sadece `students` modülü bu standarda uyuyor.

- **Neden?**
    Proje kurallarında belirtilen dosya ve klasör yapısı standardını proje geneline yayarak kod tabanında tutarlılık sağlamak. Bu, geliştiricilerin aradıkları dosyaları daha hızlı bulmasını sağlar ve projeyi daha öngörülebilir hale getirir.

- **Nasıl?**
    1. Aşağıdaki klasörler `git mv` komutu kullanılarak yeniden adlandırılmalıdır. Bu, hem dosya sistemindeki değişikliği yapar hem de `git` geçmişini korur.
        - `lib/features/calendar/presentation/pages` -> `lib/features/calendar/presentation/screens`
        - `lib/features/fees/presentation/pages` -> `lib/features/fees/presentation/screens`
        - `lib/features/home/presentation/pages` -> `lib/features/home/presentation/screens`
        - `lib/features/lessons/presentation/pages` -> `lib/features/lessons/presentation/screens`
        - `lib/features/settings/presentation/pages` -> `lib/features/settings/presentation/screens`
    2. Yeniden adlandırma işleminden sonra, proje genelinde eski yollara (`.../pages/...`) referans veren tüm `import` ifadeleri güncellenmelidir. Bu işlem en çok `lib/core/navigation/app_router.dart` dosyasını etkileyecektir. Proje genelinde `import '.../pages/` şeklinde bir arama yapılarak tüm referanslar bulunmalı ve `.../screens/...` olarak düzeltilmelidir.

---

### **2. State Logic'i (Durum Mantığı) UI Katmanından Ayırma**

- **Ne?**
    `StatefulWidget`'lar içinde yönetilen karmaşık durumların (state) ve iş mantığının ilgili `Provider` sınıflarına taşınması. Özellikle `FeeManagementPage` ve `AddEditLessonPage` bu duruma örnektir.

- **Neden?**
    Bu, **Single Responsibility Principle (Tek Sorumluluk Prensibi)**'ne uymamızı sağlar. Widget'ların görevi UI'ı oluşturmak ve kullanıcı etkileşimlerini dinlemektir; iş mantığı ve durum yönetimi ise state management katmanının (Provider) sorumluluğundadır. Bu ayrım, kodu daha test edilebilir, daha az karmaşık ve daha kolay yönetilebilir hale getirir.

- **Nasıl?**
    1. **`FeeManagementPage` için:**
        - `_FeeManagementPageState` içindeki `_isLoading`, `_feeSummaries`, `_students`, `_payments`, `_totalAmount`, `_paidAmount` gibi durum değişkenleri `FeeProvider`'a (veya bu sayfa için oluşturulacak yeni bir `FeeManagementProvider`'a) taşınmalıdır.
        - `_loadData` ve `_calculateStatistics` gibi metotlar, `Provider` sınıfı içine alınmalıdır.
        - UI katmanı (`FeeManagementPage`), bu verileri `context.watch<FeeProvider>().feeSummaries` gibi ifadelerle dinlemeli ve `Provider`'daki metotları `context.read<FeeProvider>().loadData()` şeklinde çağırmalıdır.
    2. **`AddEditLessonPage` için:**
        - `_initializeForm`, `_saveForm`, `_deleteRecurringSeries` gibi veri yükleme ve kaydetme mantığı içeren metotlar `LessonProvider`'a taşınmalıdır.
        - `_isLoading` durumu, formun kendi durumu (`_formKey`) ve `TextEditingController`'lar dışındaki tüm durum değişkenleri (`_lessonDate`, `_recurringInfo` vb.) `Provider` katmanında yönetilebilir. Alternatif olarak, bu sayfa için geçici bir "form state" provider'ı oluşturulabilir.

---

### **3. Tekrar Eden UI Komponentlerini Merkezileştirme (DRY Prensibi)**

- **Ne?**
    Projenin farklı yerlerinde tekrar eden veya çok benzer olan UI bileşenlerinin (widget'lar) `lib/core/widgets/` altına taşınarak yeniden kullanılabilir hale getirilmesi.

- **Neden?**
    **Don't Repeat Yourself (Kendini Tekrar Etme)** prensibine uymak, kod tekrarını azaltır. Merkezi bir bileşende yapılan bir değişiklik, kullanıldığı her yere yansır. Bu, hem tutarlı bir UI sağlar hem de bakım maliyetini düşürür.

- **Nasıl?**
    1. **Onay Diyaloğu:** `student_list_page.dart` içindeki `_showDeleteConfirmation` ve `_showBulkDeleteConfirmation` metotları, neredeyse aynı onay diyaloğunu oluşturur.
        - `lib/core/widgets/` altında `app_confirmation_dialog.dart` adında yeni bir dosya oluşturulmalıdır.
        - Bu dosya, `title`, `content` ve `onConfirm` (bir `Future<void> Function()` olabilir) gibi parametreler alan genel bir `showAppConfirmationDialog` fonksiyonu içermelidir.
        - `student_list_page.dart` bu genel fonksiyonu çağıracak şekilde refaktör edilmelidir.
    2. **Özet Kartları:** `fee_management_page.dart` içindeki `_buildSummaryCard` metodu, genel bir "bilgi kartı" bileşenidir.
        - Bu widget, `lib/core/widgets/summary_card.dart` gibi bir dosyaya taşınabilir.
        - `title`, `value`, `icon` ve `color` gibi parametreler alarak projenin başka yerlerinde de (örneğin ana sayfada veya öğrenci detaylarında) kullanılabilir hale getirilmelidir.

---

### **4. Navigasyon için Sabit (Constant) Kullanımını Zorunlu Hale Getirme**

- **Ne?**
    Uygulama içinde navigasyon için kullanılan `context.push('/some-route')` gibi hard-coded (doğrudan yazılmış) string'lerin, `lib/core/navigation/route_names.dart` dosyasında tanımlanan sabitlerle (`RouteNames.someRoute`) değiştirilmesi.

- **Neden?**
  - **Yazım Hatalarını Önler:** Sabit kullanmak, rota adlarında yapılabilecek yazım hatalarını derleme zamanında fark etmeyi sağlar.
  - **Merkezi Yönetim:** Bir rotanın adını değiştirmek gerektiğinde, sadece `route_names.dart` dosyasında değişiklik yapmak yeterli olur.
  - **Kod Okunabilirliği:** `context.push(RouteNames.addStudent)` ifadesi, `context.push('/students/add')` ifadesinden daha anlamlıdır.

- **Nasıl?**
    1. Proje genelinde `context.push('/` ve `context.go('/` ifadeleri için bir arama yapılmalıdır.
    2. Bulunan her hard-coded rota, `RouteNames` sınıfındaki ilgili sabitle değiştirilmelidir.
        - Örnek: `student_list_page.dart` içindeki `context.push('/add-student')` çağrısı, `context.push(RouteNames.addStudent)` olarak değiştirilmelidir.
        - `app_router.dart` dosyasındaki `initialLocation: '/students'` ifadesi, `initialLocation: RouteNames.students` olarak değiştirilmelidir.
