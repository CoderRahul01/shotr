# ML Kit text recognition: keep optional script recognizers referenced by reflection.
-keep class com.google.mlkit.vision.text.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**
-dontwarn com.google.mlkit.vision.text.japanese.**
-dontwarn com.google.mlkit.vision.text.korean.**
# RevenueCat
-keep class com.revenuecat.purchases.** { *; }
