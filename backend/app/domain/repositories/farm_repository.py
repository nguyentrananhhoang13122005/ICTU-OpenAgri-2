from abc import ABC, abstractmethod
from typing import List, Optional
from app.domain.entities.farm import FarmArea

class FarmRepository(ABC):
    @abstractmethod
    async def save(self, farm: FarmArea) -> FarmArea:
        pass

    @abstractmethod
    async def get_by_user_id(self, user_id: int) -> List[FarmArea]:
        pass

    @abstractmethod
    async def get_by_id(self, farm_id: int) -> Optional[FarmArea]:
        pass

    @abstractmethod
    async def get_all_with_user(self, skip: int = 0, limit: int = 100) -> List[tuple[FarmArea, dict]]:
        """Get all farms with user details."""
        pass
