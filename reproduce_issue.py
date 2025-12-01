import asyncio
import logging
import sys
import os

# Add backend to path
sys.path.append(os.path.join(os.getcwd(), 'backend'))

from app.infrastructure.external_services.gbif_service import GBIFService

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def main():
    service = GBIFService()
    
    latitude = 30.7333
    longitude = 76.7794
    radius_km = 25
    years_back = 10
    
    print(f"Checking default pests for location: {latitude}, {longitude}")
    result = await service.get_pest_risk_forecast(
        latitude=latitude,
        longitude=longitude,
        radius_km=radius_km,
        years_back=years_back
    )
    
    print("Result for default pests:")
    print(result)
    
    # Try a common pest that might be in India
    # Locusta migratoria (Migratory locust)
    print("\nChecking for Locusta migratoria...")
    result_locust = await service.get_pest_risk_forecast(
        latitude=latitude,
        longitude=longitude,
        radius_km=radius_km,
        years_back=years_back,
        pest_scientific_names=["Locusta migratoria"]
    )
    print("Result for Locusta migratoria:")
    print(result_locust)

if __name__ == "__main__":
    asyncio.run(main())
