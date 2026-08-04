# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class io.flutter.plugins.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Just Audio
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

# Keep serialized model classes
-keep class com.askiman.ask_iman.** { *; }

# Keep enum classes
-keepclassmembers enum * { *; }

# Gson — preserve generic signatures for TypeToken at runtime (R8 strips these)
-keepattributes Signature
-keep class com.google.gson.reflect.TypeToken { *; }
-keep class * extends com.google.gson.reflect.TypeToken
-keep class com.google.gson.** { *; }
-dontwarn com.google.gson.**
