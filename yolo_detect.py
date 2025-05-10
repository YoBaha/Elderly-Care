import os
import cv2
import numpy as np
from ultralytics import YOLO
from flask import Flask, request, jsonify
from flask_cors import CORS

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})  # Allow all origins for testing

# Global variables
model = None
labels = None
min_thresh = 0.5

# Detection endpoint for web clients
@app.route('/detect', methods=['POST'])
def detect():
    try:
        # Get image data from request
        if 'image' not in request.files and not request.get_data():
            return jsonify({"error": "No image data provided"}), 400

        # Handle image file upload or raw data
        if 'image' in request.files:
            file = request.files['image']
            nparr = np.frombuffer(file.read(), np.uint8)
        else:
            nparr = np.frombuffer(request.get_data(), np.uint8)

        # Decode image
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if frame is None:
            print('Failed to decode image')  # Debug
            return jsonify({"error": "Invalid image data"}), 400

        # Log frame details
        print(f'Frame shape: {frame.shape}, size: {frame.size}')  # Debug

        # Resize frame to match local script (e.g., 640x480)
        frame = cv2.resize(frame, (640, 480))

        # Perform inference
        results = model(frame, verbose=False)
        detections = results[0].boxes
        print(f'Number of detections: {len(detections)}')  # Debug

        # Process detections
        for i in range(len(detections)):
            conf = detections[i].conf.item()
            classidx = int(detections[i].cls.item())
            classname = labels[classidx]
            print(f'Detection {i}: Class={classname}, Confidence={conf}')  # Debug
            if conf > min_thresh:
                print(f'Returning sign: {classname}, confidence: {conf}')  # Debug
                return jsonify({
                    "sign": classname,
                    "confidence": conf,
                    "timestamp": time.time()
                })

        print('No detections above threshold')  # Debug
        return jsonify({
            "sign": "",
            "confidence": 0.0,
            "timestamp": time.time()
        })

    except Exception as e:
        print(f'Error in detect: {e}')  # Debug
        return jsonify({"error": str(e)}), 500

# Initialize model at startup
model_path = "my_model.pt"
if not os.path.exists(model_path):
    print(f'ERROR: Model path {model_path} is invalid or not found.')
    sys.exit(1)

model = YOLO(model_path, task='detect')
labels = model.names
print(f'Model labels: {labels}')  # Debug labels
min_thresh = float(os.environ.get('MIN_THRESH', 0.5))  # Optional: configure via env

if __name__ == "__main__":
    # For local testing only; Render uses gunicorn
    port = int(os.environ.get("PORT", 5000))  # Use Render's PORT or default
    app.run(host='0.0.0.0', port=port, debug=False)