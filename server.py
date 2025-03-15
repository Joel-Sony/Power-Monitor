from flask import Flask, request, jsonify
from flask_mysqldb import MySQL
from flask_cors import CORS
import mysql.connector
from datetime import datetime, timedelta

app = Flask(__name__)
CORS(app)  # Allow requests from Flutter

# MySQL Configuration
app.config['MYSQL_HOST'] = 'localhost'  # Change if accessing from another PC
app.config['MYSQL_USER'] = 'your_mysql_user'
app.config['MYSQL_PASSWORD'] = 'your_mysql_password'
app.config['MYSQL_DB'] = 'your_database'

mysql = MySQL(app)

db_config = {
    "host": "localhost",
    "user": "joel",
    "password": "root",
    "database": "powerapp"
}

def get_db_connection():
    return mysql.connector.connect(**db_config)

@app.route('/data', methods=['GET'])
def get_data():
    try:
        cursor = mysql.connection.cursor()
        cursor.execute("SELECT * FROM your_table")  # Change to your table name
        rows = cursor.fetchall()
        
        data = [{"id": row[0], "voltage": row[1], "current": row[2]} for row in rows]
        cursor.close()
        return jsonify(data)
    except Exception as e:
        return jsonify({"error": str(e)})

@app.route('/power-usage', methods=['GET'])
def get_power_usage():
    try:
        days = int(request.args.get('days', 7))
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        
        query = """
        SELECT * FROM power_usage
        WHERE timestamp >= NOW() - INTERVAL %s DAY
        ORDER BY timestamp DESC;
        """
        cursor.execute(query, (days,))
        results = cursor.fetchall()
        
        conn.close()
        return jsonify({"data": results, "status": "success"}), 200
    except Exception as e:
        return jsonify({"error": str(e), "status": "failed"}), 500

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

        # Get highest power consumption time
        highest_power_time = get_highest_power_time()

        # Get latest KSEB rate
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
        conn.close()

        return jsonify({"message": "Data processed & stored", "status": "success"}), 200

    except Exception as e:
        return jsonify({"error": str(e), "status": "failed"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
