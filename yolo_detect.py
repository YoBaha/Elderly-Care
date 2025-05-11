import os
import cv2
import numpy as np
from flask import Flask, request
from flask_cors import CORS
from ultralytics import YOLO
import logging

app = Flask(__name__)
CORS(app)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load YOLO model
try:
    model = YOLO(os.environ.get('MODEL_PATH', 'path/to/your/model.pt'), task='detect')
    model.to('cpu')  # Force CPU
    logger.info(f"Model loaded successfully: {model.names}")
except Exception as e:
    logger.error(f"Failed to load model: {e}")
    raise

@app.route('/detect', methods=['POST'])
def detect():
    try:
        # Read image
        file = request.get_data()
        nparr = np.frombuffer(file, np.uint8)
        frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        logger.info(f"Original frame shape: {frame.shape}, size: {frame.size}")

        # Resize to 320x320
        frame = cv2.resize(frame, (320, 320))
        logger.info(f"Resized frame shape: {frame.shape}")

        # Perform detection
        min_thresh = float(os.environ.get('MIN_THRESH', 0.3))
        results = model(frame, verbose=False, device='cpu', conf=min_thresh)
        sign = ""
        confidence = 0.0

        # Process results
        for result in results:
            if result.boxes:
                max_conf = result.boxes.conf.max().item()
                if max_conf >= min_thresh:
                    class_id = result.boxes.cls[result.boxes.conf.argmax()].item()
                    sign = model.names[class_id]
                    confidence = max_conf

        response = {
            "sign": sign,
            "confidence": confidence,
            "timestamp": os.times()[4]
        }
        logger.info(f"Detection response: {response}")
        return response
    except Exception as e:
        logger.error(f"Detection error: {e}")
        return {"error": str(e)}, 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)