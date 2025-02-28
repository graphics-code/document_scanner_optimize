# Keep class names for reflection
-keepattributes *Annotation*

# Keep essential Flutter classes
-keep class io.flutter.** { *; }
-keep class androidx.lifecycle.** { *; }

# Keep serialized classes
-keepclassmembers class * implements java.io.Serializable { *; }

# Avoid stripping native method names
-keepclasseswithmembernames class * {
    native <methods>;
}