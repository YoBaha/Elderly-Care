import os
import cv2
import numpy as np
from ultralytics import YOLO
from flask import Flask, request, jsonify
from flask_cors import CORS
import torch.serialization  # Add this import

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

# Global variables
model = None
labels = None
min_thresh = 0.5

# Detection endpoint (unchanged)
@app.route('/detect', methods=['POST'])
def detect():
    try:
        if 'image' not in request.files and not request.get_data():
            return jsonify({"error": "No image data provided"}), 400
        if 'image' in request.files:
            file = request.files['image']
            nparr = np.frombuffer(file.read(), np.uint8)
        else:
            nparr = np.frombuffer(request.get_data(), np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        if frame is None:
            print('Failed to decode image')
            return jsonify({"error": "Invalid image data"}), 400
        print(f'Frame shape: {frame.shape}, size: {frame.size}')
        frame = cv2.resize(frame, (640, 480))
        results = model(frame, verbose=False)
        detections = results[0].boxes
        print(f'Number of detections: {len(detections)}')
        for i in range(len(detections)):
            conf = detections[i].conf.item()
            classidx = int(detections[i].cls.item())
            classname = labels[classidx]
            print(f'Detection {i}: Class={classname}, Confidence={conf}')
            if conf > min_thresh:
                print(f'Returning sign: {classname}, confidence: {conf}')
                return jsonify({
                    "sign": classname,
                    "confidence": conf,
                    "timestamp": time.time()
                })
        print('No detections above threshold')
        return jsonify({
            "sign": "",
            "confidence": 0.0,
            "timestamp": time.time()
        })
    except Exception as e:
        print(f'Error in detect: {e}')
        return jsonify({"error": str(e)}), 500

# Initialize model at startup
model_path = "my_model.pt"
if not os.path.exists(model_path):
    print(f'ERROR: Model path {model_path} is invalid or not found.')
    exit(1)

# Allowlist DetectionModel for torch.load
torch.serialization.add_safe_globals(['ultralytics.nn.tasks.DetectionModel'])
model = YOLO(model_path, task='detect')
labels = model.names
print(f'Model labels: {labels}')
min_thresh = float(os.environ.get('MIN_THRESH', 0.5))

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=False)