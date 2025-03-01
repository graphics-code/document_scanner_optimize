# Keep classes that Flutter uses
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Flutter-related methods
-keep class * extends io.flutter.plugins.PluginRegistry$Registrant { *; }

# Keep classes and methods that are used in the app
-keep class com.yourpackage.** { *; }
-keepclassmembers class * {
    public static void main(java.lang.String[]);
}

# Allow rules for Firebase and other libraries
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Add any specific rules for other libraries
-keep class androidx.** { *; }