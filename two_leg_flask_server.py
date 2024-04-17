from flask import Flask, request
import csv
from datetime import datetime
import re


app = Flask(__name__)

app.config['MAX_CONTENT_LENGTH'] = 200 * 1024 * 1024

@app.route('/data', methods=['POST'])
def receive_data():
    device_id = request.form.get('device_id', 'unknown_device')  
    print(device_id)
    batch_data = request.form['data']  

    csv_file_path = f"{device_id}_sensor_data.csv"

    pattern = r'(\d+):(-?\d+\.\d+,-?\d+\.\d+,-?\d+\.\d+,-?\d+\.\d+,-?\d+\.\d+,-?\d+\.\d+)'
    sensor_readings = re.findall(pattern, batch_data)

    with open(csv_file_path, 'a', newline='') as file:
        writer = csv.writer(file)
        for reading in sensor_readings:
            channel = reading[0]
            values_str = reading[1]
            values = values_str.split(',')
            writer.writerow([datetime.now(), channel] + values)

    return 'Data received'

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)



