import os
import numpy as np
from PIL import Image
import tensorflow as tf
from pathlib import Path
from typing import List, Dict, Any
import io

class DiseaseDetectionService:
    _instance = None
    _model = None
    _class_names = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(DiseaseDetectionService, cls).__new__(cls)
            cls._instance._load_resources()
        return cls._instance

    def _load_resources(self):
        """Load the model and class names."""
        try:
            # Calculate paths relative to this file
            current_dir = Path(__file__).parent
            # backend/app/infrastructure/image_processing/ -> backend/ml_models/
            base_dir = current_dir.parent.parent.parent
            model_path = base_dir / "ml_models" / "leaf_disease_model.keras"
            class_names_path = base_dir / "ml_models" / "class_names.txt"

            print(f"Loading model from: {model_path}")
            self._model = tf.keras.models.load_model(model_path)
            
            print(f"Loading class names from: {class_names_path}")
            with open(class_names_path, "r") as f:
                self._class_names = [line.strip() for line in f.readlines()]
                
        except Exception as e:
            print(f"Error loading disease detection resources: {e}")
            # We might want to raise this or handle it gracefully depending on requirements
            # For now, we'll let it fail if called later if resources aren't loaded
            pass

    def predict(self, image_bytes: bytes) -> Dict[str, Any]:
        """
        Predict disease from an image.
        
        Args:
            image_bytes: The image data in bytes.
            
        Returns:
            A dictionary containing the top class name and confidence score.
        """
        if self._model is None or self._class_names is None:
            self._load_resources()
            if self._model is None:
                raise RuntimeError("Model not loaded successfully")

        try:
            # Preprocess image
            img = Image.open(io.BytesIO(image_bytes))
            img = img.convert('RGB')
            img = img.resize((224, 224)) # Assuming standard input size, adjust if needed
            
            img_array = tf.keras.preprocessing.image.img_to_array(img)
            img_array = tf.expand_dims(img_array, 0) # Create a batch

            # Predict
            predictions = self._model.predict(img_array)
            score = predictions[0]  # Model already has softmax activation, so this is the probability distribution

            # Get top predictions or all predictions
            # For now, let's return the top prediction and confidence
            
            results = []
            for i, confidence in enumerate(score):
                results.append({
                    "class_name": self._class_names[i],
                    "confidence": float(confidence)
                })
            
            # Sort by confidence descending
            results.sort(key=lambda x: x["confidence"], reverse=True)
            
            return results[0]

        except Exception as e:
            print(f"Error during prediction: {e}")
            raise e

# Global instance
disease_detection_service = DiseaseDetectionService()
