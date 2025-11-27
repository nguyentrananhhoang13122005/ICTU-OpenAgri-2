from fastapi import APIRouter, UploadFile, File, HTTPException
from typing import List, Dict, Any
from app.infrastructure.image_processing.disease_detection import disease_detection_service

router = APIRouter()

@router.post("/predict", response_model=Dict[str, Any])
async def predict_disease(file: UploadFile = File(...)):
    """
    Predict disease from an uploaded image file.
    """
    if not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="File must be an image")

    try:
        contents = await file.read()
        prediction = disease_detection_service.predict(contents)
        return prediction
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Prediction failed: {str(e)}")
