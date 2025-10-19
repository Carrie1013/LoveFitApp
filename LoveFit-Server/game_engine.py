from typing import Dict, List
import json

class GameEngine:
    def __init__(self):
        self.user_progress = {}  # user sports data from 'Health' app
        self.setup_requirements()
    
    def setup_requirements(self): # define unlock requrement
        self.requirements = {
            "story_1": {"type": "running", "distance": 1*1e3}, 
            "story_2": {"type": "running", "duration": 1*1e3},  
            "story_3": {"type": "running", "distance": 1.2*1e3},   
            "story_4": {"type": "running", "duration": 1.2*1e3},  
        }
    
    ##### TODO: get recent data for story generation
    ##### TODO: get live data for story generation - motivation
    
    def process_workout(self, user_id: str, workout_type: str, distance: float, duration: int): # get historical data for story generation
        if user_id not in self.user_progress:
            self.user_progress[user_id] = {
                "total_distance": 0,
                "total_duration": 0,
                "unlocked_stories": [],
                "current_progress": {}
            }
        
        user = self.user_progress[user_id]
        user["total_distance"] += distance
        user["total_duration"] += duration
        
        # check lockable stories
        newly_unlocked = []
        for story_id, req in self.requirements.items():
            if story_id in user["unlocked_stories"]:
                continue
                
            if self.check_requirement(req, workout_type, distance, duration):
                user["unlocked_stories"].append(story_id)
                newly_unlocked.append(story_id)
        
        return {
            "newly_unlocked": newly_unlocked,
            "total_progress": user
        }
    
    def check_requirement(self, req, workout_type, distance, duration): # check if required
        if req["type"] != workout_type:
            return False
        
        if "distance" in req and distance >= req["distance"]:
            return True
        if "duration" in req and duration >= req["duration"]:
            return True
        
        return False
    
    def get_available_content(self, user_id): # get user's unlocked stories
        if user_id not in self.user_progress:
            return {"unlocked_stories": [], "locked_stories": list(self.requirements.keys())}
        
        user = self.user_progress[user_id]
        locked = [s for s in self.requirements.keys() if s not in user["unlocked_stories"]]
        
        return {
            "unlocked_stories": user["unlocked_stories"],
            "locked_stories": locked,
            "requirements": self.requirements
        }