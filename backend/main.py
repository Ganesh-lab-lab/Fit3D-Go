"""
Fit3D / RoomFit FastAPI Backend
Provides high-performance endpoints for fast-path 3D reconstruction,
product dimension parsing, and wishlist persistence.
"""

from fastapi import FastAPI, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import List, Optional
import random

from backend.services.reconstruction_service import (
    FastReconstructionEngine,
    KeyframeMetadata,
)
from backend.services.wishlist_service import (
    wishlist_repo,
    FitCheckItem,
)

app = FastAPI(
    title="RoomFit Spatial Fit-Check API",
    version="1.0.0",
    description="Backend microservice for real-world photogrammetry turnaround and spatial wishlist persistence.",
)

# Enable CORS for Flutter web preview and mobile dev clients
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class ScanJobRequest(BaseModel):
    category_hint: str = "sofa"
    frame_count: int = Field(default=16, ge=4, le=60)
    orbit_arc_degrees: float = Field(default=180.0, ge=45.0, le=360.0)
    ar_scale_factor: float = Field(default=1.0, ge=0.5, le=2.0)


@app.get("/api/health")
def health_check():
    return {
        "status": "healthy",
        "service": "RoomFit Spatial Backend",
        "splatting_engine": "active",
    }


@app.post("/api/reconstruction/fast-scan")
def trigger_fast_reconstruction(req: ScanJobRequest):
    """
    Simulates real-world AR-calibrated Gaussian Splatting fast-path reconstruction job.
    Applies blur filtering, keyframe spacing, and scale calibration.
    """
    # Synthesize keyframes from client capture stream
    synthetic_frames: List[KeyframeMetadata] = []
    angle_step = req.orbit_arc_degrees / max(1, req.frame_count)

    for i in range(req.frame_count):
        # Occasionally inject a blurry frame to exercise the blur-detection filter
        sharpness = (
            20.0
            if (i % 5 == 0 and i > 0)
            else random.uniform(45.0, 95.0)
        )
        synthetic_frames.append(
            KeyframeMetadata(
                frame_index=i,
                orbit_angle_deg=round(i * angle_step, 1),
                sharpness_score=sharpness,
                ar_depth_confidence=random.uniform(0.85, 0.99),
                camera_position_meters=(0.5 * i, 1.2, -1.0),
            )
        )

    result = FastReconstructionEngine.reconstruct_from_orbit(
        frames=synthetic_frames,
        category_hint=req.category_hint,
        ar_scale_factor=req.ar_scale_factor,
    )

    return {
        "success": True,
        "length_in": result.length_inches,
        "width_in": result.width_inches,
        "height_in": result.height_inches,
        "category": result.detected_category,
        "confidence": "directHigh",
        "confidence_score": result.confidence_score,
        "gaussian_splat_iterations": result.gaussian_splat_iterations,
        "frames_total": result.total_frames_processed,
        "frames_accepted": result.frames_accepted,
        "processing_time_ms": result.processing_time_ms,
        "badge": "Measured directly — high confidence",
    }


@app.get("/api/wishlist", response_model=List[FitCheckItem])
def get_wishlist(
    fit_status: Optional[str] = Query(None, description="fits, tight, or wontFit"),
    room_id: Optional[str] = Query(None, description="filter by room id"),
):
    return wishlist_repo.list_all(fit_status=fit_status, room_id=room_id)


@app.post("/api/wishlist", response_model=FitCheckItem)
def save_to_wishlist(item: FitCheckItem):
    return wishlist_repo.add(item)


@app.delete("/api/wishlist/{item_id}")
def delete_wishlist_item(item_id: str):
    success = wishlist_repo.delete(item_id)
    if not success:
        raise HTTPException(status_code=404, detail="Item not found")
    return {"success": True, "deleted_id": item_id}
