"""
RoomFit Wishlist & Persistence Service
Handles saving, retrieving, and filtering fit-check records with Supabase cloud persistence
and graceful in-memory fallback.
"""

from pydantic import BaseModel, Field
from typing import List, Optional
from datetime import datetime
import os
import uuid
from pathlib import Path

# Attempt to load environment variables from project or local .env
try:
    from dotenv import load_dotenv
    env_paths = [
        Path(__file__).resolve().parent.parent / ".env",
        Path(__file__).resolve().parent.parent.parent / ".env",
    ]
    for p in env_paths:
        if p.exists():
            load_dotenv(p)
            break
except ImportError:
    pass

# Supabase Python Client
try:
    from supabase import create_client, Client
    HAS_SUPABASE_PACKAGE = True
except ImportError:
    HAS_SUPABASE_PACKAGE = False
    Client = None


class FitCheckItem(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
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
        self._supabase: Optional[Client] = None
        self._items: dict[str, FitCheckItem] = {}

        # Initialize Supabase client if available and configured
        url = os.getenv("SUPABASE_URL")
        key = os.getenv("SUPABASE_SERVICE_ROLE_KEY") or os.getenv("SUPABASE_ANON_KEY")

        if HAS_SUPABASE_PACKAGE and url and key:
            try:
                self._supabase = create_client(url, key)
                print("✅ Supabase WishlistRepository connected to cloud")
            except Exception as e:
                print(f"⚠️ Supabase client initialization warning: {e}")
                self._supabase = None

        if not self._supabase:
            # Seed in-memory store for fallback/dev
            self._items = {
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

    def _row_to_item(self, row: dict) -> FitCheckItem:
        prod = row.get("product_data") or {}
        created_str = row.get("timestamp") or row.get("created_at")
        try:
            created_at = datetime.fromisoformat(created_str.replace("Z", "+00:00")) if created_str else datetime.utcnow()
        except Exception:
            created_at = datetime.utcnow()

        return FitCheckItem(
            id=row.get("id", ""),
            title=prod.get("title") or row.get("room_name", "Product"),
            source=prod.get("source", "offline"),
            category=prod.get("category", "sofa"),
            length_in=float(prod.get("length_in", 36.0)),
            width_in=float(prod.get("width_in", 24.0)),
            height_in=float(prod.get("height_in", 30.0)),
            confidence=prod.get("confidence", "directHigh"),
            room_id=row.get("room_id", ""),
            room_name=row.get("room_name", ""),
            position_x=float(row.get("position_x", 0.0)),
            position_y=float(row.get("position_y", 0.0)),
            rotation_deg=float(row.get("rotation_deg", 0.0)),
            fit_status=row.get("fit_status", "fits"),
            clearance_inches=float(row.get("clearance_inches", 0.0)),
            obstruction_reason=row.get("obstruction_reason"),
            created_at=created_at,
        )

    def list_all(
        self, fit_status: Optional[str] = None, room_id: Optional[str] = None
    ) -> List[FitCheckItem]:
        if self._supabase:
            try:
                query = self._supabase.table("fit_checks").select("*")
                if room_id:
                    query = query.eq("room_id", room_id)
                if fit_status:
                    query = query.eq("fit_status", fit_status)
                res = query.order("timestamp", desc=True).execute()
                return [self._row_to_item(r) for r in res.data]
            except Exception as e:
                print(f"⚠️ Error querying Supabase fit_checks: {e}")

        # Fallback to in-memory
        results = list(self._items.values())
        if fit_status:
            results = [i for i in results if i.fit_status.lower() == fit_status.lower()]
        if room_id:
            results = [i for i in results if i.room_id == room_id]
        return sorted(results, key=lambda x: x.created_at, reverse=True)

    def add(self, item: FitCheckItem) -> FitCheckItem:
        if self._supabase:
            try:
                row = {
                    "id": item.id,
                    "product_id": f"prod_{item.id}",
                    "product_data": {
                        "id": f"prod_{item.id}",
                        "title": item.title,
                        "source": item.source,
                        "category": item.category,
                        "length_in": item.length_in,
                        "width_in": item.width_in,
                        "height_in": item.height_in,
                        "confidence": item.confidence,
                        "created_at": item.created_at.isoformat(),
                    },
                    "room_id": item.room_id,
                    "room_name": item.room_name,
                    "position_x": item.position_x,
                    "position_y": item.position_y,
                    "rotation_deg": item.rotation_deg,
                    "fit_status": item.fit_status,
                    "clearance_inches": item.clearance_inches,
                    "obstruction_reason": item.obstruction_reason,
                    "timestamp": item.created_at.isoformat(),
                }
                self._supabase.table("fit_checks").upsert(row).execute()
                return item
            except Exception as e:
                print(f"⚠️ Error saving to Supabase fit_checks: {e}")

        self._items[item.id] = item
        return item

    def get(self, item_id: str) -> Optional[FitCheckItem]:
        if self._supabase:
            try:
                res = self._supabase.table("fit_checks").select("*").eq("id", item_id).execute()
                if res.data:
                    return self._row_to_item(res.data[0])
            except Exception as e:
                print(f"⚠️ Error getting from Supabase: {e}")

        return self._items.get(item_id)

    def delete(self, item_id: str) -> bool:
        if self._supabase:
            try:
                res = self._supabase.table("fit_checks").delete().eq("id", item_id).execute()
                return True
            except Exception as e:
                print(f"⚠️ Error deleting from Supabase: {e}")

        if item_id in self._items:
            del self._items[item_id]
            return True
        return False


wishlist_repo = WishlistRepository()
