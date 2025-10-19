import json
import ollama
from datetime import datetime
from typing import List, Dict, Optional
from pathlib import Path


class AICharacter: # Now: chat+plot
    
    def __init__(self, character_file: str = "character.json", model: str = "gemma3"):
        """
        Character initialization
        
        Args:
            character_file: character configuration path
            model: llm model choice
        """
        self.character_file = character_file
        self.model = model
        self.character_data = {}
        self.chat_history = []
        self.story_progress = {}
        
        # load or create user data
        if Path(character_file).exists():
            self.load_character()
        else:
            print(f"Character does not existed, please setup_character() first.")
    
    def setup_character(self, character_data: Dict):
        """
        Set up/ modify character personality
        
        Args:
            character_data: characters info
        """
        required_fields = ["name", "personality", "speaking_style", "background"]
        for field in required_fields:
            if field not in character_data:
                raise ValueError(f"lacking field: {field}")
        
        self.character_data = character_data
        self.character_data["created_at"] = datetime.now().isoformat()
        self.character_data["updated_at"] = datetime.now().isoformat()
        
        # plot initialization
        if "storylines" in character_data:
            self.story_progress = {
                storyline["id"]: {
                    "current_chapter": 0,
                    "completed_chapters": [],
                    "unlocked": storyline.get("unlocked", False)
                }
                for storyline in character_data["storylines"]
            }
            self.character_data["story_progress"] = self.story_progress
        
        self.save_character()
        print(f"✅ character '{self.character_data['name']}'successfully set up")
    
    def update_character(self, updates: Dict):
        """
        Update character
        
        Args:
            updates: dicts to be updated
        """
        self.character_data.update(updates)
        self.character_data["updated_at"] = datetime.now().isoformat()
        self.save_character()
        print(f"✅ character updated")
    
    def _build_system_prompt(self, mode: str = "chat") -> str: # build system prompt for character
        base_prompt = f"""You name is {self.character_data['name']}。

[[[personality]]]
{self.character_data['personality']}

[[[background story]]]
{self.character_data['background']}

[[[speaking style]]]
{self.character_data['speaking_style']}

[[[behavior requirement]]]

"""
        
        if "traits" in self.character_data:
            base_prompt += "\n".join(f"- {trait}" for trait in self.character_data['traits'])
        
        if mode == "chat":
            base_prompt += """
Now you are having a casual chat with the user. Please maintain the character Settings and respond naturally to the user's topics.
Don't reveal that you are an AI. Immerse yourself completely in the character."""
        
        elif mode == "story":
            current_storyline = self.character_data.get("current_storyline")
            if current_storyline:
                storyline = next(
                    (s for s in self.character_data["storylines"] if s["id"] == current_storyline),
                    None
                )
                if storyline:
                    progress = self.story_progress.get(current_storyline, {})
                    chapter_idx = progress.get("current_chapter", 0)
                    
                    if chapter_idx < len(storyline["chapters"]):
                        chapter = storyline["chapters"][chapter_idx]
                        base_prompt += f"""

[[[current plot]]]
story line: {storyline['title']}
chapter: {chapter['title']}
chapter goal: {chapter['objective']}

Please advance the story based on the current plot progress. Maintain character consistency and create engaging interactions."""
        
        return base_prompt
    
    def chat(self, user_message: str, remember_history: bool = True) -> str:
        """
        Chat with character
        
        Args:
            user_message: user info
            remember_history: memorize the history or not
            
        Returns:
            character reply
        """
        if not self.character_data:
            return "❌ please set up the character first"
        
        # 构建对话消息
        messages = [
            {"role": "system", "content": self._build_system_prompt("chat")}
        ]
        
        # 添加历史对话（最近10轮）
        if remember_history:
            messages.extend(self.chat_history[-20:])
        
        messages.append({"role": "user", "content": user_message})
        # TODO: 添加历史重要事件概述

        # 调用模型
        try:
            response = ollama.chat(model=self.model, messages=messages)
            assistant_message = response['message']['content']
            
            # 保存对话历史
            if remember_history:
                self.chat_history.append({"role": "user", "content": user_message})
                self.chat_history.append({"role": "assistant", "content": assistant_message})
            
            return assistant_message
            
        except Exception as e:
            return f"❌ 对话出错: {str(e)}"
    
    def advance_story(self, user_action: str) -> Dict:
        """
        推进主线剧情
        
        Args:
            user_action: 用户的行动/选择
            
        Returns:
            包含剧情回复和状态的字典
        """
        if not self.character_data or "storylines" not in self.character_data:
            return {"error": "未设置剧情"}
        
        current_storyline_id = self.character_data.get("current_storyline")
        if not current_storyline_id:
            return {"error": "未选择剧情线"}
        
        # 获取当前剧情
        storyline = next(
            (s for s in self.character_data["storylines"] if s["id"] == current_storyline_id),
            None
        )
        
        if not storyline:
            return {"error": "剧情线不存在"}
        
        progress = self.story_progress.get(current_storyline_id, {})
        chapter_idx = progress.get("current_chapter", 0)
        
        if chapter_idx >= len(storyline["chapters"]):
            return {
                "message": f"🎉 恭喜！你已完成 '{storyline['title']}' 故事线！",
                "completed": True
            }
        
        chapter = storyline["chapters"][chapter_idx]
        
        # 构建剧情推进消息
        messages = [
            {"role": "system", "content": self._build_system_prompt("story")},
            {"role": "user", "content": user_action}
        ]
        
        try:
            response = ollama.chat(model=self.model, messages=messages)
            story_response = response['message']['content']
            
            # 检查是否完成当前章节（简单示例：可以改进为更智能的判断）
            chapter_complete = self._check_chapter_completion(user_action, chapter)
            
            result = {
                "response": story_response,
                "storyline": storyline["title"],
                "chapter": chapter["title"],
                "chapter_index": chapter_idx,
                "total_chapters": len(storyline["chapters"]),
                "completed": False
            }
            
            if chapter_complete:
                # 完成当前章节
                progress["completed_chapters"].append(chapter_idx)
                progress["current_chapter"] = chapter_idx + 1
                self.story_progress[current_storyline_id] = progress
                self.character_data["story_progress"] = self.story_progress
                self.save_character()
                
                result["chapter_completed"] = True
                result["message"] = f"✅ 章节 '{chapter['title']}' 完成！"
                
                if chapter_idx + 1 >= len(storyline["chapters"]):
                    result["storyline_completed"] = True
                    result["message"] += f"\n🎉 故事线 '{storyline['title']}' 全部完成！"
            
            return result
            
        except Exception as e:
            return {"error": f"剧情推进出错: {str(e)}"}
    
    def _check_chapter_completion(self, user_action: str, chapter: Dict) -> bool:
        """
        检查章节是否完成（简化版本）
        实际使用中可以用更复杂的逻辑判断
        """
        # 这里可以根据关键词、AI判断或特定条件来决定
        # 简单示例：检查是否包含完成关键词
        completion_keywords = ["完成", "done", "finish", "解决", "成功"]
        return any(keyword in user_action.lower() for keyword in completion_keywords)
    
    def start_storyline(self, storyline_id: str) -> str:
        """
        开始某条故事线
        
        Args:
            storyline_id: 故事线ID
            
        Returns:
            开场描述
        """
        if "storylines" not in self.character_data:
            return "❌ 没有可用的故事线"
        
        storyline = next(
            (s for s in self.character_data["storylines"] if s["id"] == storyline_id),
            None
        )
        
        if not storyline:
            return "❌ 故事线不存在"
        
        if not self.story_progress.get(storyline_id, {}).get("unlocked", False):
            return "❌ 该故事线尚未解锁"
        
        self.character_data["current_storyline"] = storyline_id
        self.save_character()
        
        first_chapter = storyline["chapters"][0]
        return f"""📖 开始故事线: {storyline['title']}

{storyline['description']}

--- 第一章: {first_chapter['title']} ---
{first_chapter['description']}

目标: {first_chapter['objective']}
"""
    
    def get_available_storylines(self) -> List[Dict]:
        """获取可用的故事线列表"""
        if "storylines" not in self.character_data:
            return []
        
        return [
            {
                "id": s["id"],
                "title": s["title"],
                "description": s["description"],
                "unlocked": self.story_progress.get(s["id"], {}).get("unlocked", False),
                "progress": f"{len(self.story_progress.get(s['id'], {}).get('completed_chapters', []))}/{len(s['chapters'])}"
            }
            for s in self.character_data["storylines"]
        ]
    
    def save_character(self):
        """保存角色数据到JSON文件"""
        with open(self.character_file, 'w', encoding='utf-8') as f:
            json.dump(self.character_data, f, ensure_ascii=False, indent=2)
    
    def load_character(self):
        """从JSON文件加载角色数据"""
        with open(self.character_file, 'r', encoding='utf-8') as f:
            self.character_data = json.load(f)
            self.story_progress = self.character_data.get("story_progress", {})
        print(f"✅ 已加载角色: {self.character_data.get('name', '未命名')}")
    
    def save_chat_history(self, filename: str = "chat_history.json"):
        """保存对话历史"""
        history_data = {
            "character": self.character_data.get("name"),
            "timestamp": datetime.now().isoformat(),
            "messages": self.chat_history
        }
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(history_data, f, ensure_ascii=False, indent=2)
        print(f"✅ 对话历史已保存到 {filename}")
    
    def load_chat_history(self, filename: str = "chat_history.json"):
        """加载对话历史"""
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                history_data = json.load(f)
                self.chat_history = history_data.get("messages", [])
            print(f"✅ 已加载 {len(self.chat_history)} 条对话记录")
        except FileNotFoundError:
            print(f"❌ 文件 {filename} 不存在")
    
    def clear_chat_history(self):
        """清空对话历史"""
        self.chat_history = []
        print("✅ 对话历史已清空")
    
    def get_character_info(self) -> Dict:
        """获取角色信息摘要"""
        if not self.character_data:
            return {}
        
        return {
            "name": self.character_data.get("name"),
            "personality": self.character_data.get("personality"),
            "chat_count": len(self.chat_history) // 2,
            "current_storyline": self.character_data.get("current_storyline"),
            "available_storylines": len(self.character_data.get("storylines", []))
        }
    
    def export_story_transcript(self, storyline_id: str, filename: str = None):
        """
        导出某条故事线的完整记录
        
        Args:
            storyline_id: 故事线ID
            filename: 导出文件名（可选）
        """
        storyline = next(
            (s for s in self.character_data.get("storylines", []) if s["id"] == storyline_id),
            None
        )
        
        if not storyline:
            print("❌ 故事线不存在")
            return
        
        progress = self.story_progress.get(storyline_id, {})
        
        transcript = {
            "storyline": storyline["title"],
            "description": storyline["description"],
            "progress": f"{len(progress.get('completed_chapters', []))}/{len(storyline['chapters'])}",
            "chapters": storyline["chapters"],
            "exported_at": datetime.now().isoformat()
        }
        
        if filename is None:
            filename = f"story_{storyline_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(transcript, f, ensure_ascii=False, indent=2)
        
        print(f"✅ 故事记录已导出到 {filename}")


# ============= 使用示例 =============
if __name__ == "__main__":
    # 创建角色实例
    character = AICharacter(character_file="my_character.json", model="gemma3:27b")
    
    # 示例：设置角色（首次使用）
    example_character = {
        "name": "艾莉丝",
        "personality": "活泼开朗、好奇心强、有点小迷糊但很聪明。喜欢冒险和探索未知。",
        "speaking_style": "说话时经常用「呢」「哦」等语气词，喜欢用emoji表情，偶尔会说一些可爱的口头禅。",
        "background": "来自魔法学院的见习魔法师，正在人类世界进行毕业实习。对人类的科技和文化充满好奇。",
        "traits": [
            "遇到困难时会先思考再行动",
            "对朋友非常忠诚",
            "害怕黑暗和虫子",
            "最喜欢吃甜食"
        ],
        "voice_tone": "温柔但充满活力",
        "relationship": "初识的朋友，正在建立信任",
        "storylines": [
            {
                "id": "main_quest_1",
                "title": "失落的魔法书",
                "description": "艾莉丝的魔法书在实习途中遗失了，需要找回它才能完成毕业考核。",
                "unlocked": True,
                "chapters": [
                    {
                        "title": "神秘的线索",
                        "description": "在图书馆发现了魔法书可能的下落线索。",
                        "objective": "调查图书馆并找到第一条线索"
                    },
                    {
                        "title": "黑市交易",
                        "description": "线索指向城市的黑市，那里可能有人见过魔法书。",
                        "objective": "潜入黑市并获取情报"
                    },
                    {
                        "title": "最终对决",
                        "description": "找到了偷书贼的藏身处，是时候夺回魔法书了！",
                        "objective": "击败偷书贼并找回魔法书"
                    }
                ]
            }
        ]
    }
    
    # 设置角色（如果是首次运行）
    # character.setup_character(example_character)
    
    # 闲聊示例
    print("\n=== 闲聊模式 ===")
    response = character.chat("嗨！今天天气真好呢～")
    print(f"艾莉丝: {response}")
    
    # 开始故事线
    print("\n=== 剧情模式 ===")
    storylines = character.get_available_storylines()
    print("可用故事线:", storylines)
    
    # intro = character.start_storyline("main_quest_1")
    # print(intro)
    
    # 推进剧情
    # result = character.advance_story("我决定先去图书馆的历史区域查找相关记录")
    # print(result)
    
    # 保存对话历史
    # character.save_chat_history()
    
    print("\n✅ 角色系统示例运行完成！")