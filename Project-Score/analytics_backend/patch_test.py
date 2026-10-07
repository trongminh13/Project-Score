import os

filepath = "test_gamification.py"
with open(filepath, "r") as f:
    content = f.read()

old_req = 'req = PlacePredictionReq(user_id=r7.id, match_id=match.id, predicted_result=PredictionResult.HOME, points_staked=200.0)'
new_req = 'req = PlacePredictionReq(match_id=match.id, predicted_result=PredictionResult.HOME, points_staked=200.0)'
content = content.replace(old_req, new_req, 1)

old_call = 'res = place_prediction(req, db)'
new_call = 'res = place_prediction(req, current_user=r7, db=db)'
content = content.replace(old_call, new_call, 1)

with open(filepath, "w") as f:
    f.write(content)
