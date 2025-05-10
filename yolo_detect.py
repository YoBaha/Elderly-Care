import os
import cv2
import numpy as np
from ultralytics import YOLO
from ultralytics.nn.tasks import DetectionModel
from ultralytics.nn.modules.conv import Conv, Concat, DWConv  # Add DWConv
from ultralytics.nn.modules.block import C2f, SPPF, C3k2, Bottleneck, C3k, C2PSA, PSABlock, Attention, DFL  # Add DFL
from ultralytics.nn.modules.head import Detect
from torch.nn.modules.container import Sequential
from torch.nn.modules.conv import Conv2d
from torch.nn.modules.batchnorm import BatchNorm2d
from torch.nn.modules.activation import SiLU
from torch.nn.modules.upsampling import Upsample
from ultralytics.nn.modules.conv import Conv, Concat  # Fix Concat import
from torch.nn.modules.container import Sequential, ModuleList  # Add ModuleList
from torch.nn.modules.pooling import MaxPool2d  # Add MaxPool2d
from torch.nn.modules.linear import Identity  # Corrected import
from flask import Flask, request, jsonify
from flask_cors import CORS
import torch.serialization
import time

app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

model = None
labels = None
min_thresh = 0.5

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

model_path = "my_model.pt"
if not os.path.exists(model_path):
    print(f'ERROR: Model path {model_path} is invalid or not found.')
    exit(1)

torch.serialization.add_safe_globals([DetectionModel, Sequential, Conv, Conv2d, BatchNorm2d, C2f, SPPF, Detect, SiLU, Upsample, Concat, C3k2, ModuleList, Bottleneck, C3k, MaxPool2d, C2PSA, PSABlock, Attention, Identity, DWConv, DFL])
model = YOLO(model_path, task='detect')
labels = model.names
print(f'Model labels: {labels}')
min_thresh = float(os.environ.get('MIN_THRESH', 0.5))

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 5000))
    app.run(host='0.0.0.0', port=port, debug=False)