import math

class EloEngine:
    """
    Lõi Toán học: Cập nhật ELO bóng đá & Phân bổ Xác suất (Win/Draw/Loss)
    """
    K_FACTOR = 20
    HOME_FIELD_ADVANTAGE = 50 # Lợi thế sân nhà (+50 điểm)
    
    @staticmethod
    def _calculate_binary_expected_prob(elo_home: float, elo_away: float) -> tuple:
        """ Tính xác suất nhị phân phục vụ tính toán cộng/trừ điểm ELO """
        adjusted_home_elo = elo_home + EloEngine.HOME_FIELD_ADVANTAGE
        prob_home = 1 / (1 + math.pow(10, (elo_away - adjusted_home_elo) / 400))
        return prob_home, 1 - prob_home

    @staticmethod
    def calculate_match_probabilities(elo_home: float, elo_away: float) -> tuple:
        """
        Tính toán Xác suất 3 cửa (Win - Draw - Loss) để đẩy lên App cho User xem.
        """
        prob_home_raw, prob_away_raw = EloEngine._calculate_binary_expected_prob(elo_home, elo_away)
        
        # LOGIC TÍNH CỬA HÒA: Dựa vào độ chênh lệch ELO
        adjusted_home_elo = elo_home + EloEngine.HOME_FIELD_ADVANTAGE
        elo_diff = abs(adjusted_home_elo - elo_away)
        
        # Max hòa = 28% (khi 2 đội cân bằng), Min hòa = 16% (khi chênh lệch >= 300 điểm)
        draw_prob = 0.28 - 0.12 * (min(elo_diff, 300) / 300)
        
        # Phân bổ lại xác suất Thắng / Thua sau khi trừ đi cửa Hòa
        home_win_prob = prob_home_raw * (1 - draw_prob)
        away_win_prob = prob_away_raw * (1 - draw_prob)
        
        return round(home_win_prob, 4), round(draw_prob, 4), round(away_win_prob, 4)

    @staticmethod
    def update_elo(elo_home: float, elo_away: float, home_goals: int, away_goals: int) -> tuple:
        """ Cập nhật ELO sau khi có kết quả tỷ số thực tế """
        if home_goals > away_goals:
            actual_home, actual_away = 1.0, 0.0
        elif home_goals < away_goals:
            actual_home, actual_away = 0.0, 1.0
        else:
            actual_home, actual_away = 0.5, 0.5
            
        prob_home_raw, prob_away_raw = EloEngine._calculate_binary_expected_prob(elo_home, elo_away)
        
        new_elo_home = elo_home + EloEngine.K_FACTOR * (actual_home - prob_home_raw)
        new_elo_away = elo_away + EloEngine.K_FACTOR * (actual_away - prob_away_raw)
        
        return round(new_elo_home, 2), round(new_elo_away, 2)
