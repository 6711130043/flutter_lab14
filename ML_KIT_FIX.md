# แก้ไขข้อผิดพลาด ML Kit Image Labeling

## ปัญหาที่พบ
```
MissingPluginException(No implementation found for method vision#startImageLabelDetector on channel google_mlkit_image_labeler)
```

## สาเหตุ
1. Plugin Google ML Kit Image Labeling ไม่ได้ถูก configure อย่างถูกต้องใน Android
2. ไม่มีการระบุ minSdk และ compileSdk ที่เหมาะสม
3. ไม่มี ML Kit metadata ใน AndroidManifest.xml

## การแก้ไข

### 1. อัพเดท `android/app/build.gradle.kts`
- เปลี่ยน `minSdk` จาก `flutter.minSdkVersion` เป็น `21` (ต้องการสำหรับ ML Kit)
- เปลี่ยน `compileSdk` จาก `flutter.compileSdkVersion` เป็น `34` (เพื่อความเข้ากันได้ที่ดี)

### 2. อัพเดท `android/app/src/main/AndroidManifest.xml`
- เพิ่ม ML Kit metadata สำหรับ Image Labeling:
```xml
<meta-data
    android:name="com.google.mlkit.vision.DEPENDENCIES"
    android:value="label" />
```

## วิธีการทดสอบ

1. **ทำความสะอาดและ rebuild project:**
```bash
flutter clean
flutter pub get
```

2. **หยุด app ที่กำลังรันอยู่ (ถ้ามี) และ run ใหม่:**
```bash
flutter run
```

3. **สำคัญ:** ต้อง **cold restart** หรือ **stop แล้ว run ใหม่** ไม่ใช่แค่ hot reload เพราะการเปลี่ยนแปลง native configuration จำเป็นต้อง rebuild app

## หมายเหตุ
- การเปลี่ยนแปลง Android configuration ต้องทำการ rebuild app ทั้งหมด
- Hot reload จะไม่มีผลกับการเปลี่ยนแปลงในส่วน native (Android/iOS)
- ML Kit จะดาวน์โหลด model อัตโนมัติครั้งแรกที่ใช้งาน (ต้องมี internet)

น