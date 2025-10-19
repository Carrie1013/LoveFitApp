from character_agent import AICharacter
import json


def print_banner(): # print welcome banner
    print("\n" + "="*60)
    print("🎭 Welcome to LoveFit v1.0")
    print("="*60 + "\n")


def print_menu():
    print("\n📋 Menu:")
    print("  1. 💬 Chat Mode")
    print("  2. 📖 查看可用故事线")
    print("  3. 🎮 开始/继续剧情")
    print("  4. 👤 查看角色信息")
    print("  5. 📝 修改角色设定")
    print("  6. 💾 保存对话历史")
    print("  7. 📂 加载对话历史")
    print("  8. 🗑️  清空对话历史")
    print("  9. 📊 导出故事记录")
    print("  0. 🚪 退出系统")
    print()


def chat_mode(character: AICharacter):
    print("\n💬 Chat Mode (enter 'quit' back to main menu)")
    print("-" * 60)
    
    while True:
        user_input = input("\nYou: ").strip()
        
        if user_input.lower() in ['quit', 'exit', 'q']:
            print("✅ Back to menu.")
            break
        
        if not user_input:
            continue
        
        response = character.chat(user_input)
        print(f"\n{character.character_data.get('name', '角色')}: {response}")


def view_storylines(character: AICharacter): # view storylines
    storylines = character.get_available_storylines()
    
    if not storylines:
        print("\n❌ no available storyline for now")
        return
    
    print("\n📚 可用故事线:")
    print("-" * 60)
    for i, story in enumerate(storylines, 1):
        status = "🔓 已解锁" if story['unlocked'] else "🔒 未解锁"
        print(f"\n{i}. {story['title']} {status}")
        print(f"   ID: {story['id']}")
        print(f"   描述: {story['description']}")
        print(f"   进度: {story['progress']}")


def story_mode(character: AICharacter):
    """剧情模式"""
    current_storyline = character.character_data.get("current_storyline")
    
    if not current_storyline:
        print("\n❌ 未选择故事线，请先选择一个故事线")
        storylines = character.get_available_storylines()
        
        if not storylines:
            print("❌ 暂无可用故事线")
            return
        
        print("\n请选择要开始的故事线:")
        unlocked = [s for s in storylines if s['unlocked']]
        
        for i, story in enumerate(unlocked, 1):
            print(f"{i}. {story['title']}")
        
        try:
            choice = int(input("\n请输入编号: ").strip())
            if 1 <= choice <= len(unlocked):
                selected = unlocked[choice - 1]
                intro = character.start_storyline(selected['id'])
                print("\n" + intro)
            else:
                print("❌ 无效选择")
                return
        except ValueError:
            print("❌ 请输入有效数字")
            return
    
    # 进入剧情推进循环
    print("\n🎮 剧情模式 (输入 'quit' 返回主菜单)")
    print("-" * 60)
    
    while True:
        user_action = input("\n你的行动: ").strip()
        
        if user_action.lower() in ['quit', 'exit', 'q']:
            print("✅ 返回主菜单")
            break
        
        if not user_action:
            continue
        
        result = character.advance_story(user_action)
        
        if "error" in result:
            print(f"❌ {result['error']}")
            continue
        
        print(f"\n{character.character_data.get('name', '角色')}: {result['response']}")
        
        if "chapter_completed" in result and result["chapter_completed"]:
            print(f"\n{result['message']}")
            print(f"📊 进度: {result['chapter_index'] + 1}/{result['total_chapters']}")
        
        if result.get("storyline_completed", False):
            print("\n🎉 恭喜完成整条故事线！")
            break


def view_character_info(character: AICharacter):
    """查看角色信息"""
    info = character.get_character_info()
    
    if not info:
        print("\n❌ 未加载角色信息")
        return
    
    print("\n👤 角色信息:")
    print("-" * 60)
    print(f"名字: {info.get('name', '未知')}")
    print(f"性格: {info.get('personality', '未设置')}")
    print(f"对话次数: {info.get('chat_count', 0)}")
    print(f"当前故事线: {info.get('current_storyline', '无')}")
    print(f"可用故事线数量: {info.get('available_storylines', 0)}")
    
    # 显示更多详细信息
    if character.character_data:
        print(f"\n背景: {character.character_data.get('background', '未设置')}")
        print(f"说话风格: {character.character_data.get('speaking_style', '未设置')}")
        
        if 'traits' in character.character_data:
            print(f"\n特征:")
            for trait in character.character_data['traits']:
                print(f"  • {trait}")


def modify_character(character: AICharacter):
    """修改角色设定"""
    print("\n✏️  修改角色设定")
    print("-" * 60)
    print("可修改的字段:")
    print("  1. personality (性格)")
    print("  2. speaking_style (说话风格)")
    print("  3. background (背景)")
    print("  4. relationship (关系)")
    
    field = input("\n请输入要修改的字段名: ").strip()
    
    if field not in ['personality', 'speaking_style', 'background', 'relationship']:
        print("❌ 无效的字段名")
        return
    
    print(f"\n当前值: {character.character_data.get(field, '未设置')}")
    new_value = input("\n请输入新值: ").strip()
    
    if new_value:
        character.update_character({field: new_value})
        print("✅ 修改成功")
    else:
        print("❌ 输入为空，取消修改")


def save_history(character: AICharacter):
    """保存对话历史"""
    filename = input("\n请输入保存文件名 (默认: chat_history.json): ").strip()
    if not filename:
        filename = "chat_history.json"
    
    character.save_chat_history(filename)


def load_history(character: AICharacter):
    """加载对话历史"""
    filename = input("\n请输入文件名 (默认: chat_history.json): ").strip()
    if not filename:
        filename = "chat_history.json"
    
    character.load_chat_history(filename)


def export_story(character: AICharacter):
    """导出故事记录"""
    storylines = character.get_available_storylines()
    
    if not storylines:
        print("\n❌ 暂无可用故事线")
        return
    
    print("\n选择要导出的故事线:")
    for i, story in enumerate(storylines, 1):
        print(f"{i}. {story['title']} (进度: {story['progress']})")
    
    try:
        choice = int(input("\n请输入编号: ").strip())
        if 1 <= choice <= len(storylines):
            selected = storylines[choice - 1]
            character.export_story_transcript(selected['id'])
        else:
            print("❌ 无效选择")
    except ValueError:
        print("❌ 请输入有效数字")


def create_sample_character():
    """创建示例角色"""
    sample = {
        "name": "露娜",
        "age": "18",
        "gender": "女",
        "personality": "温柔体贴，有点天然呆。喜欢安静的环境，热爱阅读和星空。虽然看起来柔弱，但内心非常坚强。",
        "speaking_style": "说话轻声细语，常用「嗯」「啊」等语气词。喜欢用比喻的方式表达。偶尔会陷入自己的小世界里发呆。",
        "background": "从小在图书馆长大的孤儿，被管理员收养。对书籍和知识有着特殊的情感。最近成为了一名见习图书管理员。",
        "traits": [
            "遇到陌生人会害羞，但对熟悉的人很亲近",
            "记忆力超群，过目不忘",
            "喜欢在下雨天看书",
            "最喜欢的饮料是热可可",
            "会在紧张时咬指甲"
        ],
        "voice_tone": "轻柔温和，带着书卷气",
        "appearance": "黑色长发，深蓝色眼睛。身材娇小，喜欢穿淡色的长裙和毛衣。",
        "relationship": "刚认识不久的朋友，正在慢慢熟悉",
        "knowledge_areas": ["文学", "历史", "天文学"],
        "likes": ["书籍", "星空", "安静", "热可可", "雨天"],
        "dislikes": ["嘈杂", "粗鲁的人", "被打扰", "虫子"],
        "goals": [
            "成为一名优秀的图书管理员",
            "写一本属于自己的书",
            "找到自己的身世之谜"
        ],
        "secrets": [
            "其实能够看见书中文字背后的故事画面",
            "藏有一本神秘的古老书籍"
        ],
        "storylines": [
            {
                "id": "mystery_book",
                "title": "禁忌之书的秘密",
                "description": "图书馆深处发现了一本被封印的古老书籍，露娜意外触碰后开启了一段奇妙的冒险。",
                "unlocked": True,
                "difficulty": "中等",
                "chapters": [
                    {
                        "title": "神秘的书页",
                        "description": "在整理禁区书架时，露娜发现了一本散发着微光的书。当她触碰书页时，周围的空间开始扭曲...",
                        "objective": "调查古书的来历并解读第一页的内容",
                        "hints": ["寻找图书馆的历史档案", "询问老馆长关于禁区的事"],
                        "key_events": ["触碰书籍", "看见幻象", "发现线索"],
                        "success_conditions": ["成功解读第一页", "了解书籍的基本信息"]
                    },
                    {
                        "title": "文字的试炼",
                        "description": "书籍开始显现文字，但这些文字会化为实体出现在现实中。露娜必须通过智慧来应对这些考验。",
                        "objective": "解决三个文字谜题并获得书籍的认可",
                        "hints": ["运用文学知识", "思考文字的深层含义"],
                        "key_events": ["文字谜题1", "文字谜题2", "文字谜题3"],
                        "success_conditions": ["解开所有谜题"]
                    },
                    {
                        "title": "真相与抉择",
                        "description": "书籍揭示了露娜身世的真相，同时也带来了一个重大的抉择：是继承书籍的力量，还是将它重新封印？",
                        "objective": "做出最终的选择",
                        "hints": ["倾听内心的声音", "考虑每个选择的后果"],
                        "key_events": ["身世揭秘", "力量觉醒", "最终抉择"],
                        "success_conditions": ["做出选择"],
                        "branching_paths": {
                            "inherit": "继承力量，成为书籍守护者",
                            "seal": "封印书籍，回归平凡生活"
                        }
                    }
                ]
            },
            {
                "id": "daily_life",
                "title": "图书馆日常",
                "description": "作为见习管理员的日常生活，帮助读者，整理书籍，偶尔还会遇到有趣的事情。",
                "unlocked": True,
                "difficulty": "简单",
                "chapters": [
                    {
                        "title": "特殊的访客",
                        "description": "今天来了一位特别的访客，似乎在寻找一本很久以前的书...",
                        "objective": "帮助访客找到他要找的书",
                        "hints": ["仔细聆听访客的描述", "利用图书馆的检索系统"],
                        "key_events": ["接待访客", "搜索书籍", "意外发现"],
                        "success_conditions": ["找到书籍并了解其背后的故事"]
                    }
                ]
            }
        ]
    }
    
    character = AICharacter(character_file="luna_character.json", model="gemma3")
    character.setup_character(sample)
    print("✅ 示例角色 '露娜' 创建成功！")
    return character


def main():
    """主程序"""
    print_banner()
    
    # 询问是创建新角色还是加载现有角色
    print("欢迎使用 AI 角色系统！")
    print("\n请选择:")
    print("  1. 创建示例角色 (露娜)")
    print("  2. 加载现有角色")
    print("  3. 创建自定义角色")
    
    choice = input("\n请输入选项 (1/2/3): ").strip()
    
    if choice == "1":
        character = create_sample_character()
    elif choice == "2":
        filename = input("请输入角色文件名 (默认: character.json): ").strip()
        if not filename:
            filename = "character.json"
        character = AICharacter(character_file=filename, model="gemma3")
    elif choice == "3":
        print("\n请查看 character_template.json 来了解如何创建角色配置")
        print("创建完成后请将文件保存，然后选择选项 2 加载")
        return
    else:
        print("❌ 无效选择")
        return
    
    # 主循环
    while True:
        print_menu()
        
        choice = input("请选择操作 (0-9): ").strip()
        
        if choice == "1":
            chat_mode(character)
        elif choice == "2":
            view_storylines(character)
        elif choice == "3":
            story_mode(character)
        elif choice == "4":
            view_character_info(character)
        elif choice == "5":
            modify_character(character)
        elif choice == "6":
            save_history(character)
        elif choice == "7":
            load_history(character)
        elif choice == "8":
            confirm = input("\n⚠️  确定要清空对话历史吗? (y/n): ").strip().lower()
            if confirm == 'y':
                character.clear_chat_history()
        elif choice == "9":
            export_story(character)
        elif choice == "0":
            print("\n👋 感谢使用，再见！")
            break
        else:
            print("\n❌ 无效选择，请重新输入")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n👋 程序被中断，再见！")
    except Exception as e:
        print(f"\n❌ 发生错误: {e}")