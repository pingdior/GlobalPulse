from openai import OpenAI
import os
from dotenv import load_dotenv

# 加载环境变量
load_dotenv()

# 初始化OpenAI客户端
# 优先尝试 DASHSCOPE_API_KEY，如果没有则尝试 DEEPSEEK_API_KEY
api_key = os.getenv("DASHSCOPE_API_KEY") or os.getenv("DEEPSEEK_API_KEY")

print(f"Using API Key: {api_key[:4]}****{api_key[-4:] if api_key else 'None'}")

client = OpenAI(
    api_key=api_key,
    base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
)

print(f"Testing model: deepseek-v3")

try:
    messages = [{"role": "user", "content": "你是谁"}]
    completion = client.chat.completions.create(
        model="deepseek-v3", # 尝试 v3，如果失败再试 v3.2
        messages=messages,
        # extra_body={"enable_thinking": True}, # 暂时去掉 enable_thinking 以排除干扰
        stream=True,
        # stream_options={
        #     "include_usage": True
        # },
    )

    reasoning_content = ""
    answer_content = ""
    is_answering = False
    print("\n" + "=" * 20 + "思考过程" + "=" * 20 + "\n")

    for chunk in completion:
        if not chunk.choices:
            print("\n" + "=" * 20 + "Token 消耗" + "=" * 20 + "\n")
            print(chunk.usage)
            continue

        delta = chunk.choices[0].delta

        # 只收集思考内容
        if hasattr(delta, "reasoning_content") and delta.reasoning_content is not None:
            if not is_answering:
                print(delta.reasoning_content, end="", flush=True)
            reasoning_content += delta.reasoning_content

        # 收到content，开始进行回复
        if hasattr(delta, "content") and delta.content:
            if not is_answering:
                print("\n" + "=" * 20 + "完整回复" + "=" * 20 + "\n")
                is_answering = True
            print(delta.content, end="", flush=True)
            answer_content += delta.content

except Exception as e:
    print(f"\nError: {e}")
