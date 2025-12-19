# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in /usr/local/Cellar/android-sdk/24.3.3/tools/proguard/proguard-android.txt

# Keep SQLite native code
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# Keep sqflite
-keep class com.tekartik.sqflite.** { *; }

# Keep Gson if used
-keepattributes Signature
-keepattributes *Annotation*

# Keep model classes (adjust package name as needed)
-keep class com.tafaseer.app.** { *; }

# Prevent stripping of Arabic fonts
-keep class android.graphics.Typeface { *; }

# Missing Play Core deferred components - dontwarn since we don't use them
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**
