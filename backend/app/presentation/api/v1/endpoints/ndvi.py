from fastapi import APIRouter, Depends
from app.application.dto.ndvi_dto import NDVIRequest, NDVIResponse
from app.application.use_cases.ndvi_use_cases import CalculateNDVIUseCase
from app.domain.entities.user import User
from app.presentation.deps import get_current_user

router = APIRouter()

@router.post("/calculate", response_model=NDVIResponse)
def calculate_ndvi(
    request: NDVIRequest,
    use_case: CalculateNDVIUseCase = Depends(CalculateNDVIUseCase),
    current_user: User = Depends(get_current_user)
):
    """
    Calculate NDVI for a given bounding box and date.
    Downloads Sentinel-2 data and processes it.
    Requires authentication.
    """
    return use_case.execute(request)
