# Smart Power Monitoring System

## Overview

The **Smart Power Monitoring System** is a real-time energy tracking solution that collects voltage and current data from a household electric meter using an **ESP32**. The data is stored locally on a **Windows-based server with a database** and visualized using a **Flutter app**.

## Features

-  **Real-time power usage tracking**
-  **Peak voltage and power consumption monitoring**
-  **Daily, weekly, and monthly energy usage reports**
-  **Bill estimation based on KSEB tariff rates**
-  **Historical data analysis for better energy management**
-  **ESP32 integration for data collection**
-  **Local server storage to ensure data privacy**

## How It Works

1. **ESP32 Module** reads voltage and current from the electric meter.
2. **Data Transmission**: The ESP32 sends the collected data to a local server over WiFi.
3. **Server Processing**: A **Flask-based API** running on a Windows PC receives and processes the data, storing it in a MySQL database.
4. **Data Visualization**: A **Flutter app** fetches the stored data and displays real-time statistics and insights.
5. **Energy Reports & Billing**: The system calculates energy usage, estimates bills based on KSEB tariff rates, and provides users with detailed insights.

## Tech Stack

- **Hardware**: ESP32
- **Backend**: Flask (Python), MySQL
- **Frontend**: Flutter (Dart)
- **Hosting**: Local Windows Server
- **Communication**: REST API

## Installation & Setup

### Prerequisites

- ESP32 with appropriate sensors
- Python 3 installed on Windows
- MySQL Server
- Flutter installed for mobile app development

### Backend (Flask API & MySQL)

1. Clone the repository.
2. Install dependencies:
   ```bash
   pip install flask flask-mysqldb flask-cors mysql-connector-python
   ```
3. Configure `config.py` with MySQL credentials.
4. Run the Flask server:
   ```bash
   python app.py
   ```

### ESP32 Firmware

1. Flash the ESP32 with the provided Arduino/C++ firmware.
2. Configure WiFi credentials in the firmware.
3. Upload the code to the ESP32.

## Future Improvements

- 📌 Cloud-based storage option
- 📌 AI-based energy consumption predictions
- 📌 Smart alerts for unusual power consumption

## License

This project is licensed under the MIT License.

## Contributors

1.[Joshua Jame Biju](https://github.com/hmm-1947) 
2.[David George Anuj](https://github.com/DavidGeorgeAnuj)
3.[Kevin Jose](https://github.com/Kevinjose102)
4.[Joel Sony](https://github.com/Joel-Sony) 


