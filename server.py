from flask import Flask, request, jsonify
import mysql.connector
from datetime import datetime, timedelta

app = Flask(__name__)

# Database Configuration
db_config = {
    "host": "localhost",
    "user": "joel",
    "password": "root",
    "database": "powerapp"
}

# Connect to MySQL
def get_db_connection():
    return mysql.connector.connect(**db_config)

# Get latest peak voltage for a given time range
def get_peak_voltage(duration):
    conn = get_db_connection()
    cursor = conn.cursor()
    query = f"SELECT MAX(voltage) FROM power_usage WHERE timestamp >= NOW() - INTERVAL {duration}"
    cursor.execute(query)
    result = cursor.fetchone()[0]
    conn.close()
    return result if result else 0

# Get total units consumed in a given time range
def get_total_units(duration):
    conn = get_db_connection()
    cursor = conn.cursor()
    query = f"SELECT SUM(units_consumed) FROM power_usage WHERE timestamp >= NOW() - INTERVAL {duration}"
    cursor.execute(query)
    result = cursor.fetchone()[0]
    conn.close()
    return result if result else 0

# Get highest power consumption time
def get_highest_power_time():
    conn = get_db_connection()
    cursor = conn.cursor()
    query = "SELECT timestamp FROM power_usage ORDER BY power DESC LIMIT 1"
    cursor.execute(query)
    result = cursor.fetchone()[0]
    conn.close()
    return result

# Get latest KSEB rate
def get_energy_charge(units):
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT * FROM kseb_tariff ORDER BY id DESC")  # Adjust based on correct sorting column
    tariffs = cursor.fetchall()
    conn.close()

    for tariff in tariffs:
        # Use min_units and max_units instead of units_range
        if tariff['min_units'] <= units <= tariff['max_units']:
            return tariff['energy_charge_single']  # Or 'energy_charge_three' based on connection type

    return None  # No matching tariff

# API to receive ESP32 data, process & store it
@app.route('/esp32/data', methods=['POST'])
def receive_data():
    try:
        data = request.json
        voltage = float(data.get("voltage"))
        current = float(data.get("current"))
        
        # Calculate Power (W) and Units Consumed (kWh)
        power = round(voltage * current, 2)
        units_consumed = round(power / 1000, 2)

        # Calculate Peak Voltages
        peak_voltage_day = get_peak_voltage("1 DAY")
        peak_voltage_week = get_peak_voltage("7 DAY")
        peak_voltage_month = get_peak_voltage("30 DAY")
        peak_voltage_year = get_peak_voltage("365 DAY")

        # Calculate Total Units Consumed
        total_units_day = get_total_units("1 DAY")
        total_units_week = get_total_units("7 DAY")
        total_units_month = get_total_units("30 DAY")
        total_units_year = get_total_units("365 DAY")
        total_units_till_now = get_total_units("100 YEAR")  # Entire history

        # Get highest power consumption time
        highest_power_time = get_highest_power_time()

        # Get latest KSEB rate
        rate = get_energy_charge(total_units_till_now)
        total_bill = round(total_units_till_now * rate, 2) if rate else 0
        bill_day = round(total_units_day * rate, 2) if rate else 0
        bill_week = round(total_units_week * rate, 2) if rate else 0
        bill_month = round(total_units_month * rate, 2) if rate else 0
        bill_year = round(total_units_year * rate, 2) if rate else 0
    
        # Insert data into MySQL
        conn = get_db_connection()
        cursor = conn.cursor()

        query = """
        INSERT INTO power_usage (voltage, current, power, units_consumed, peak_voltage_day,
                                peak_voltage_week, peak_voltage_month, peak_voltage_year,
                                total_units_day, total_units_week, total_units_month, total_units_year,
                                highest_power_time, total_bill, bill_day, bill_week, bill_month, bill_year)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """
        cursor.execute(query, (voltage, current, power, units_consumed, peak_voltage_day,
                               peak_voltage_week, peak_voltage_month, peak_voltage_year,
                               total_units_day, total_units_week, total_units_month, total_units_year,
                               highest_power_time, total_bill, bill_day, bill_week, bill_month, bill_year))
        conn.commit()
        conn.close()

        return jsonify({"message": "Data processed & stored", "status": "success"}), 200

    except Exception as e:
        return jsonify({"error": str(e), "status": "failed"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
