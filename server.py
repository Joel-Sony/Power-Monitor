from flask import Flask, request, jsonify
from flask_mysqldb import MySQL
from flask_cors import CORS
import mysql.connector
import requests  # Import requests to send data to Flutter
from decimal import Decimal

app = Flask(__name__)
CORS(app)  # Allow requests from Flutter

# MySQL Configuration
db_config = {
    "host": "localhost",
    "user": "joel",
    "password": "root",
    "database": "powerapp"
}

def get_db_connection():
    return mysql.connector.connect(**db_config)

def get_peak_voltage(interval):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = f"SELECT MAX(voltage) FROM power_usage WHERE timestamp >= NOW() - INTERVAL {interval}"
        cursor.execute(query)
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return float(result[0]) if result and result[0] else 0
    except Exception as e:
        print(f"Error fetching peak voltage: {e}")
        return 0

def get_total_units(interval):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = f"SELECT SUM(units_consumed) FROM power_usage WHERE timestamp >= NOW() - INTERVAL {interval}"
        cursor.execute(query)
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return float(result[0]) if result and result[0] else 0
    except Exception as e:
        print(f"Error fetching total units: {e}")
        return 0

def get_highest_power_time():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        query = "SELECT timestamp FROM power_usage ORDER BY power DESC LIMIT 1"
        cursor.execute(query)
        result = cursor.fetchone()
        cursor.close()
        conn.close()
        return result[0].strftime("%Y-%m-%d %H:%M:%S") if result and result[0] else None  # Convert datetime to string
    except Exception as e:
        print(f"Error fetching highest power time: {e}")
        return None

def get_energy_charge(units):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
        SELECT energy_charge_single FROM kseb_tariff
        WHERE min_units <= %s AND (max_units IS NULL OR max_units >= %s)
        """
        cursor.execute(query, (units, units))
        result = cursor.fetchone()  # Fetch the result before closing the cursor

        cursor.fetchall()  # Fetch remaining (if any) to avoid "Unread result" error
        cursor.close()
        conn.close()
        
        return float(result[0]) if result else 0  # Convert Decimal to float
    except Exception as e:
        print(f"Error fetching energy charge: {e}")
        return 0

@app.route('/esp32/data', methods=['POST'])
def receive_data():
    try:
        data = request.json
        voltage = float(data.get("voltage"))
        current = float(data.get("current"))

        power = round(voltage * current, 2)
        units_consumed = round(power / 1000, 2)

        peak_voltage_day = get_peak_voltage("1 DAY")
        peak_voltage_week = get_peak_voltage("7 DAY")
        peak_voltage_month = get_peak_voltage("30 DAY")
        peak_voltage_year = get_peak_voltage("365 DAY")

        total_units_day = get_total_units("1 DAY")
        total_units_week = get_total_units("7 DAY")
        total_units_month = get_total_units("30 DAY")
        total_units_year = get_total_units("365 DAY")

        highest_power_time = get_highest_power_time()
        
        # Convert rate to float before multiplication
        rate = get_energy_charge(total_units_year)
        total_bill = round(total_units_year * rate, 2) if rate else 0

        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
        INSERT INTO power_usage (voltage, current, power, units_consumed, peak_voltage_day,
                                peak_voltage_week, peak_voltage_month, peak_voltage_year,
                                total_units_day, total_units_week, total_units_month, total_units_year,
                                highest_power_time, total_bill)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (voltage, current, power, units_consumed, peak_voltage_day,
                               peak_voltage_week, peak_voltage_month, peak_voltage_year,
                               total_units_day, total_units_week, total_units_month, total_units_year,
                               highest_power_time, total_bill))
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({"message": "Data processed & stored", "status": "success"}), 200

    except Exception as e:
        print(f"Error processing request: {e}")
        return jsonify({"error": str(e), "status": "failed"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
