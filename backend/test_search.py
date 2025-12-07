import asyncio
import os
from app.infrastructure.external_services.sentinel_client import search_sentinel_products, download_product
from app.infrastructure.image_processing.ndvi_processing import find_band_paths, compute_ndvi
from app.infrastructure.config.settings import get_settings

settings = get_settings()

async def test():
    bbox = [105.79, 10.02, 105.80, 10.03]
    api, products = await search_sentinel_products(bbox, "2025-11-01", "2025-12-07")
    print("Found", len(products), "products")
    
    # Filter low cloud
    low_cloud = [p for p in products.values() if p.get("cloud_cover", 100) < 30]
    print(f"Low cloud (<30%): {len(low_cloud)}")
    
    if low_cloud:
        product = low_cloud[0]
        print(f"Downloading: {product['title']} - cloud: {product['cloud_cover']}%")
        
        out = await download_product(api, product, out_dir=settings.OUTPUT_DIR)
        print(f"Downloaded to: {out}")
        
        # List jp2 files
        print("JP2 files found:")
        for root, dirs, files in os.walk(out):
            for f in files:
                if f.endswith(".jp2"):
                    print(f"  {f}")
        
        # Find bands
        try:
            red_path, nir_path = find_band_paths(out)
            print(f"Red band: {red_path}")
            print(f"NIR band: {nir_path}")
            
            # Compute NDVI with bbox
            out_tif = "/app/output/test_ndvi.tif"
            out_tif, mean_val, min_val, max_val = compute_ndvi(red_path, nir_path, out_tif, bbox=bbox)
            print(f"NDVI computed: mean={mean_val}, min={min_val}, max={max_val}")
        except Exception as e:
            print(f"Error: {e}")

asyncio.run(test())
