# WorkManager (pulled in by the Google Mobile Ads SDK) creates its Room
# database reflectively at process start. R8 full mode removes the generated
# class's no-arg constructor, which crashes the app on launch with
# "Failed to create an instance of androidx.work.impl.WorkDatabase".
-keep class * extends androidx.room.RoomDatabase { <init>(); }
-keep class androidx.work.impl.WorkDatabase_Impl { <init>(); }
