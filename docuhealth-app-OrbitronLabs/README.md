# Docuhealth

A comprehensive mobile application developed using Flutter.

## 🚀 Project Revamp by Orbitron Labs

This project was extensively overhauled and stabilized by **Orbitron Labs**. We took over a non-functional application and brought it to a production-ready state through major architectural and feature improvements.

### Key Contributions & Features Implemented:

*   **🔧 Complete System Stabilization:** Fixed the completely broken application state, resolving critical crashes and structural issues.
*   **📦 Dependency Revamp:** Thoroughly updated and revamped broken and outdated dependencies, ensuring compatibility with modern Flutter and Dart SDKs.
*   **📶 BLE Integration:** Added robust Bluetooth Low Energy (BLE) capabilities to communicate seamlessly with external health devices and sensors.
*   **🌐 MQTT Implementation:** Integrated MQTT protocols for reliable, real-time messaging and IoT data synchronization.
*   **🧠 Core Business Logic:** Designed and implemented the core business flows, data parsing, and logic required for the app's primary features.
*   **📱 Feature Enhancements:** Stabilized UI components, added background processing capabilities, and ensured reliable cross-platform performance.

---

## Getting Started

### Prerequisites

*   **Flutter SDK**: `>=3.0.0 <4.0.0`
*   **Dart SDK**

### Installation

1. Clone the repository.
2. Navigate to the project directory:
   ```bash
   cd Application
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the application:
   ```bash
   flutter run
   ```

## Architecture & Technologies
This project utilizes the following key technologies and packages:
*   **State Management / Navigation:** GetX (`get`)
*   **IoT & Communication:** `mqtt_client`, `flutter_blue_plus`, `http`
*   **UI Components:** `flutter_screenutil`, `syncfusion_flutter_charts`, `flutter_carousel_widget`, `syncfusion_flutter_pdfviewer`
*   **Hardware/Sensors:** `camera`, `image_picker`, `file_picker`, `opencv_4`
*   **Backend / Services:** Firebase (`firebase_core`, `firebase_messaging`), `awesome_notifications`
