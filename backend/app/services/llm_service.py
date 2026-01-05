"""LLM Service for text processing and analysis."""

import json
import os
from typing import List, Optional
from openai import AsyncOpenAI
from loguru import logger

from app.config import get_settings
from app.models.event import Event, SentimentType


class LLMService:
    """Service for LLM-based text processing."""
    
    def __init__(self):
        """Initialize LLM service with API clients."""
        settings = get_settings()
        
        # DeepSeek API (OpenAI compatible)
        self.client = AsyncOpenAI(
            # 支持通过 DASHSCOPE_API_KEY 或 DEEPSEEK_API_KEY 配置
            api_key=os.getenv("DASHSCOPE_API_KEY") or settings.deepseek_api_key,
            base_url="https://dashscope.aliyuncs.com/compatible-mode/v1",
        )
        self.model = "deepseek-v3"
    
    async def _call_llm(
        self,
        prompt: str,
        system_prompt: str = "你是一个专业的舆情分析助手。",
    ) -> Optional[str]:
        """Call LLM API."""
        if not self.client:
            return None
            
        try:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=500
            )
            return response.choices[0].message.content
        except Exception as e:
            logger.warning(f"LLM API failed: {e}")
            return None
    
    async def generate_summary(self, title: str, context: str = "") -> str:
        """Generate event summary using LLM."""
        prompt = f"""请为以下热点事件生成一段简洁的摘要（50-100字）：

事件标题：{title}
{f'背景信息：{context}' if context else ''}

要求：
1. 客观描述事件核心
2. 不带个人观点
3. 语言简洁明了"""
        
        result = await self._call_llm(prompt)
        return result or f"热点话题：{title}"
    
    async def analyze_sentiment(self, title: str, summary: str = "") -> tuple[SentimentType, List[str]]:
        """Analyze sentiment and emotion tags."""
        prompt = f"""分析以下事件的情感倾向和情绪标签：

事件标题：{title}
事件摘要：{summary}

请以 JSON 格式返回：
{{
    "sentiment": "positive/negative/neutral/mixed",
    "emotions": ["情绪标签1", "情绪标签2", "情绪标签3"]
}}

情绪标签可选：愤怒、喜悦、恐惧、惊讶、悲伤、期待、好奇、质疑、支持、反对"""
        
        result = await self._call_llm(prompt)
        
        try:
            if result:
                # 提取 JSON
                start = result.find("{")
                end = result.rfind("}") + 1
                if start >= 0 and end > start:
                    data = json.loads(result[start:end])
                    sentiment_map = {
                        "positive": SentimentType.POSITIVE,
                        "negative": SentimentType.NEGATIVE,
                        "neutral": SentimentType.NEUTRAL,
                        "mixed": SentimentType.MIXED
                    }
                    sentiment = sentiment_map.get(data.get("sentiment", "neutral"), SentimentType.NEUTRAL)
                    emotions = data.get("emotions", [])[:5]
                    return sentiment, emotions
        except Exception as e:
            logger.warning(f"Failed to parse sentiment result: {e}")
        
        return SentimentType.NEUTRAL, []
    
    async def enrich_event(self, event: Event) -> Event:
        """Enrich event with LLM-generated content."""
        # 生成摘要
        summary = await self.generate_summary(event.title)
        event.summary = summary
        
        # 分析情感
        sentiment, emotions = await self.analyze_sentiment(event.title, summary)
        event.sentiment = sentiment
        event.emotion_tags = emotions
        
        return event
    
    async def enrich_events(self, events: List[Event], max_concurrent: int = 5) -> List[Event]:
        """Enrich multiple events with rate limiting."""
        enriched = []
        for event in events[:max_concurrent]:  # MVP 限制并发
            try:
                enriched_event = await self.enrich_event(event)
                enriched.append(enriched_event)
            except Exception as e:
                logger.warning(f"Failed to enrich event {event.id}: {e}")
                enriched.append(event)
        
        # 未处理的事件直接返回
        enriched.extend(events[max_concurrent:])
        return enriched
    
    async def analyze_comparison(self, title: str, summary: str) -> dict:
        """Analyze perspective difference between domestic and international views."""
        prompt = f"""分析以下事件在"中国国内舆论"与"国际舆论(以美欧为主)"的潜在视角差异：

事件标题：{title}
事件摘要：{summary}

请以 JSON 格式返回：
{{
    "domestic_view": "国内主流观点（50字以内）",
    "international_view": "国际可能视角（50字以内，基于常识推演）",
    "difference_point": "核心争议点或视角差异点"
}}"""
        
        result = await self._call_llm(prompt)
        
        try:
            if result:
                start = result.find("{")
                end = result.rfind("}") + 1
                if start >= 0 and end > start:
                    return json.loads(result[start:end])
        except Exception as e:
            logger.warning(f"Failed to parse comparison result: {e}")
            
        return {
            "domestic_view": "暂无分析",
            "international_view": "暂无分析",
            "difference_point": "分析失败"
        }


# Singleton instance
llm_service = LLMService()
