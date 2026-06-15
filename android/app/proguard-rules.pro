# Keep native SQLite and sqlite3 bindings
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }
-keep class androidx.sqlite.** { *; }
-keep class * implements android.database.Cursor { *; }

# Keep Drift database classes
-keep class * extends de.charlex.drift.** { *; }
-keep class * extends de.charlex.drift.DriftDatabase { *; }
-keep class * extends de.charlex.drift.Table { *; }
-keep class * extends de.charlex.drift.TableInfo { *; }

# Keep reflection targets
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
