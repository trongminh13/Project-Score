from abc import ABC, abstractmethod
from typing import Any

class DataPipelineFlow(ABC):
    """
    Lớp cha định nghĩa Luồng chuẩn (Pipeline Flow) của Football Analytics.
    Các Pipeline con (như KagglePipeline, TransfermarktPipeline) sẽ kế thừa và implement.
    """
    
    @abstractmethod
    def extract_raw_data(self) -> Any:
        """Bước 1: Tải/Đọc Raw Data từ nguồn (CSV, JSON, SQL)"""
        pass

    @abstractmethod
    def resolve_entities(self, raw_data: Any) -> Any:
        """
        Bước 2: Entity Resolution (Gộp ID)
        Match cầu thủ/đội bóng giữa các nguồn về chung 1 Canonical ID.
        """
        pass

    @abstractmethod
    def build_canonical_schema(self, resolved_data: Any) -> dict:
        """
        Bước 3: Đổ data vào các lớp con Granularity
        Tạo ra: PlayerMatch, PlayerSeason, TeamMatch, TeamSeason
        """
        pass

    @abstractmethod
    def engineer_features(self, canonical_data: dict) -> Any:
        """
        Bước 4: Feature Engineering
        Tạo Form, Tính Elo, Xử lý missing values...
        """
        pass

    @abstractmethod
    def temporal_split_validation(self, features: Any) -> tuple:
        """
        Bước 5: Tránh Leakage bằng Time-based Split.
        VD: Train 2015-2020 | Val: 2021 | Test: 2022
        """
        pass

    def run_pipeline(self) -> tuple:
        """Thực thi toàn bộ luồng"""
        print("1. Extracting Raw Data...")
        raw = self.extract_raw_data()
        
        print("2. Resolving Entities...")
        resolved = self.resolve_entities(raw)
        
        print("3. Building Canonical Schema...")
        canonical = self.build_canonical_schema(resolved)
        
        print("4. Engineering Features...")
        features = self.engineer_features(canonical)
        
        print("5. Splitting Temporally...")
        train, val, test = self.temporal_split_validation(features)
        
        return train, val, test
