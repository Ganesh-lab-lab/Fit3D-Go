"""
RoomFit Wishlist & Persistence Service
Handles saving, retrieving, and filtering fit-check records.
"""

from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
import uuid


class FitCheckItem(BaseModel):
    id: str = Field(default_factory=lambda: f"fit_{uuid.uuid4().hex[:10]}")
    title: str
    source: str = "offline"  # online | offline
    category: str = "sofa"
    length_in: float
    width_in: float
    height_in: float
    confidence: str = "directHigh"  # directHigh | packagingAmber | unverifiedRed
    room_id: str
    room_name: str
    position_x: float = 0.0
    position_y: float = 0.0
    rotation_deg: float = 0.0
    fit_status: str = "fits"  # fits | tight | wontFit
    clearance_inches: float = 12.0
    obstruction_reason: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)


class WishlistRepository:
    def __init__(self):
        # In-memory store seeded with realistic initial records
        self._items: dict[str, FitCheckItem] = {
            "seed_1": FitCheckItem(
                id="seed_1",
                title="IKEA KIVIK 3-Seat Sofa",
                source="online",
                category="sofa",
                length_in=90.0,
                width_in=38.0,
                height_in=33.0,
                confidence="directHigh",
                room_id="room_1",
                room_name="Living Room",
                position_x=0.1,
                position_y=-0.2,
                rotation_deg=0.0,
                fit_status="fits",
                clearance_inches=14.5,
            ),
            "seed_2": FitCheckItem(
                id="seed_2",
                title="Bjursta Extendable Dining Table",
                source="offline",
                category="table",
                length_in=68.0,
                width_in=34.0,
                height_in=29.5,
                confidence="packagingAmber",
                room_id="room_2",
                room_name="Dining Room",
                position_x=0.0,
                position_y=0.0,
                rotation_deg=90.0,
                fit_status="tight",
                clearance_inches=3.2,
            ),
        }

    def list_all(
        self, fit_status: Optional[str] = None, room_id: Optional[str] = None
    ) -> List[FitCheckItem]:
        results = list(self._items.values())
        if fit_status:
            results = [i for i in results if i.fit_status.lower() == fit_status.lower()]
        if room_id:
            results = [i for i in results if i.room_id == room_id]
        return sorted(results, key=lambda x: x.created_at, reverse=True)

    def add(self, item: FitCheckItem) -> FitCheckItem:
        self._items[item.id] = item
        return item

    def get(self, item_id: str) -> Optional[FitCheckItem]:
        return self._items.get(item_id)

    def delete(self, item_id: str) -> bool:
        if item_id in self._items:
            del self._items[item_id]
            return True
        return False


wishlist_repo = WishlistRepository()
