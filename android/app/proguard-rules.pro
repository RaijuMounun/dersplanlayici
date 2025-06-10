# Flutter ProGuard Rules

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

# Provider
-keep class com.example.provider.** { *; }

# Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Most of volatile fields are updated with AFU and should not be mangled
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Kotlin
-keep class kotlin.** { *; }

# UUID
-keep class java.util.UUID { *; }

# Local notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; } 