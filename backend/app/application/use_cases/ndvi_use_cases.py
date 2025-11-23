import random
import datetime
import os
import uuid
from fastapi import HTTPException
from app.application.dto.ndvi_dto import NDVIRequest, NDVIResponse
from app.infrastructure.external_services.sentinel_client import search_sentinel_products, download_product
from app.infrastructure.image_processing.ndvi_processing import find_band_paths, compute_ndvi
from app.infrastructure.image_processing.utils import convert_tiff_to_base64_png
from app.infrastructure.config.settings import get_settings

settings = get_settings()

class CalculateNDVIUseCase:
    def execute(self, req: NDVIRequest) -> NDVIResponse:
        # validate bbox
        if len(req.bbox) != 4:
            raise HTTPException(status_code=400, detail='bbox must be [minx,miny,maxx,maxy]')
        
        try:
            # search products
            api, products = search_sentinel_products(req.bbox, req.start_date, req.end_date)
            if not products:
                raise HTTPException(status_code=404, detail='No Sentinel-2 product found for this bbox/date range')
            
            # pick best product (lowest cloud cover)
            best_product_uuid = None
            best_product_info = None
            min_cloud_cover = 101.0

            for uuid_val, info in products.items():
                if info['cloud_cover'] < min_cloud_cover:
                    min_cloud_cover = info['cloud_cover']
                    best_product_uuid = uuid_val
                    best_product_info = info
            
            if not best_product_info:
                 # Fallback to first if something goes wrong
                 best_product_uuid, best_product_info = next(iter(products.items()))

            print(f"Selected product: {best_product_info['title']} with cloud cover {best_product_info['cloud_cover']}%")

            # Download
            out = download_product(api, best_product_info, out_dir=settings.OUTPUT_DIR)
            
            # find bands
            red_path, nir_path = find_band_paths(out)
            
            # Generate output path
            out_tif = os.path.join(settings.OUTPUT_DIR, f'ndvi_{uuid.uuid4().hex}.tif')
            
            # Compute
            out_tif, mean_val, min_val, max_val = compute_ndvi(red_path, nir_path, out_tif)

            # Convert to Base64 PNG
            img_base64 = convert_tiff_to_base64_png(out_tif, colormap='RdYlGn', vmin=-1, vmax=1)

            # Generate Chart Data (Simulated for Demo)
            # In a real system, we would need to download and process every image in the list.
            # Here we take the dates from the search results and simulate values around the current mean.
            chart_data = []
            
            # Sort products by date
            sorted_products = sorted(products.values(), key=lambda x: x['ingestiondate'])
            
            for p in sorted_products:
                p_date = p['ingestiondate'].split('T')[0]
                # If it's the selected product, use the real value
                if p['uuid'] == best_product_uuid:
                    val = mean_val
                else:
                    # Simulate a value close to the mean (e.g., +/- 0.1)
                    # This is strictly for UI demonstration purposes as requested
                    val = mean_val + random.uniform(-0.1, 0.1)
                    val = max(-1.0, min(1.0, val)) # Clip to valid range
                
                chart_data.append({
                    'date': p_date,
                    'value': round(val, 2)
                })

            return NDVIResponse(
                status="success", 
                ndvi_geotiff=out_tif, 
                image_base64=img_base64,
                mean_ndvi=round(mean_val, 2),
                min_ndvi=round(min_val, 2),
                max_ndvi=round(max_val, 2),
                acquisition_date=best_product_info['ingestiondate'].split('T')[0],
                chart_data=chart_data
            )
            
        except Exception as e:
            # Log error here
            print(f"Error in CalculateNDVIUseCase: {e}")
            raise HTTPException(status_code=500, detail=str(e))
