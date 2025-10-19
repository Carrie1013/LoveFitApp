from flask import Flask, request, jsonify
from flask_cors import CORS
from game_engine import GameEngine
import json

app = Flask(__name__)
CORS(app)

game_engine = GameEngine()

@app.route('/api/test', methods=['GET'])
def test_connection(): # test connection API 测试连接用的接口
    return jsonify({
        "status": "success", 
        "message": "Python Server is Running!",
        "timestamp": "2024-10-17 00:30:00",
        "endpoints": {
            "test": "/api/test",
            "submit_workout": "/api/user-progress",
            "get_content": "/api/available-content/<user_id>"
        }
    })

@app.route('/api/user-progress', methods=['POST'])
def update_progress(): # update game with receiving sports data 接收运动数据，更新游戏进度
    data = request.json
    print(f"🎯 Received workouts data: {data}")
    
    user_id = "test_user"
    workout_type = data.get('type')
    distance = data.get('distance', 0)
    duration = data.get('duration', 0)
    
    result = game_engine.process_workout(user_id, workout_type, distance, duration)
    print(f"📦 Return result: {result}")
    
    return jsonify(result)

@app.route('/api/available-content/<user_id>', methods=['GET'])
def get_available_content(user_id): # 获取用户当前可解锁的剧情内容
    content = game_engine.get_available_content(user_id)
    return jsonify(content)

@app.route('/api/debug/reset', methods=['POST'])
def debug_reset(): # 调试用：重置用户进度
    user_id = "test_user"
    if user_id in game_engine.user_progress:
        del game_engine.user_progress[user_id]
    return jsonify({"status": "success", "message": "User progress reset."})

@app.route('/api/debug/status', methods=['GET'])
def debug_status(): # 调试用：查看当前状态
    user_id = "test_user"
    return jsonify({
        "user_progress": game_engine.user_progress.get(user_id, "User not available."),
        "requirements": game_engine.requirements
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001, debug=True)