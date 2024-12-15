# **Wality Project**

Welcome to **Wality** — a project designed to seamlessly integrate water flow tracking with mobile and backend solutions using Flutter and Go.

---

## **Project Setup**

### **Prerequisites**

Before running the application, ensure you have the following installed on your computer:

- **[Flutter Installation Guide](https://flutter.dev/docs/get-started/install)**
- **[Golang Installation Guide](https://golang.org/doc/install)**

### **Clone the Repository**

Clone the repository from GitHub to access the code:

```bash
git clone https://github.com/yourusername/Wality.git
```

Alternatively, download the ZIP file and extract it to your desired location.

---

## **Backend Setup**

To start the backend server:

1. Open a terminal and navigate to the `GO_backend` folder:

    ```bash
    cd Wality-main/GO_backend
    ```

2. Run the Go backend server:

    ```bash
    go run main.go
    ```

---

## **Frontend Setup**

1. Open a new terminal and navigate to the frontend folder:

    ```bash
    cd Wality-main/wality_application
    ```

2. Open `main.dart` located in the `lib` folder within your preferred IDE (e.g., **VS Code**).

---

## **Running the Application**

### **Install Dependencies**

In the frontend folder, fetch all necessary packages:

```bash
flutter pub get
```

### **Prepare Your Device**

1. Connect your Android phone to your computer via a USB cable (ensure it supports data transfer).  
2. Enable **Developer Options** and **USB Debugging** on your phone.

### **Set Up ADB Port Forwarding**

Run the following command to forward the port for the backend server:

```bash
adb reverse tcp:8080 tcp:8080
```

### **Launch the App**

In your IDE or terminal, run the Flutter application:

```bash
flutter run lib/main.dart
```
Alternatively, You can click the main.dart file of the application and click on run

---

## **Enjoy Using Wality!**

Now, you should have the backend running and the Flutter app launched on your device. Happy tracking! 🌊📱

---
