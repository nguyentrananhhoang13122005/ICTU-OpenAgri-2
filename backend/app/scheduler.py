# Copyright (c) 2025 CuongKenn and ICTU-OpenAgri Contributors
# Licensed under the MIT License. See LICENSE file in the project root for full license information.

import asyncio
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from sqlalchemy import select
from app.infrastructure.database.database import AsyncSessionLocal
from app.infrastructure.database.models.farm_model import FarmModel
from app.application.use_cases.ndvi_use_cases import CalculateNDVIUseCase
from app.domain.entities.farm import Coordinate

scheduler = AsyncIOScheduler()

async def update_all_farms_ndvi():
    """
    Scheduled job to update NDVI data for all farms.
    """
    print("Starting scheduled NDVI update job...")
    async with AsyncSessionLocal() as db:
        try:
            # Fetch all farms
            result = await db.execute(select(FarmModel))
            farms = result.scalars().all()
            
            use_case = CalculateNDVIUseCase()
            
            for farm in farms:
                # Convert farm coordinates to bbox [minx, miny, maxx, maxy]
                # Assuming coordinates is a list of dicts or objects
                coords = farm.coordinates
                if not coords:
                    continue
                
                # Simple bbox calculation
                lats = [c['lat'] for c in coords]
                lngs = [c['lng'] for c in coords]
                bbox = [min(lngs), min(lats), max(lngs), max(lats)]
                
                await use_case.sync_latest_data_for_farm(farm.id, bbox, db)
                
        except Exception as e:
            print(f"Error in scheduled job: {e}")
    print("Scheduled NDVI update job finished.")

def start_scheduler():
    """
    Start the background scheduler.
    """
    # Run every day at 00:00
    scheduler.add_job(update_all_farms_ndvi, 'cron', hour=0, minute=0)
    # Also run once on startup for testing (optional, maybe comment out in production)
    # scheduler.add_job(update_all_farms_ndvi, 'date', run_date=datetime.datetime.now() + datetime.timedelta(seconds=10))
    
    scheduler.start()
    print("Scheduler started.")
