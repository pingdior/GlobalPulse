"""Weibo Hot Search Crawler"""

import asyncio
import hashlib
from datetime import datetime
from typing import List, Optional
import httpx
from loguru import logger

from app.models.event import Event, EventSource, SentimentType


class WeiboCrawler:
    """Crawler for Weibo hot search topics."""
    
    # 微博热搜 API (非官方，仅用于 MVP 演示)
    HOT_SEARCH_API = "https://weibo.com/ajax/side/hotSearch"
    
    # 备用数据源
    BACKUP_API = "https://tenapi.cn/v2/weibohot"
    
    def __init__(self, delay: int = 2):
        """Initialize crawler with request delay."""
        self.delay = delay
        self.headers = {
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36",
            "Accept": "application/json, text/plain, */*",
            "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
        }
    
    def _generate_event_id(self, title: str) -> str:
        """Generate unique event ID based on title and date."""
        date_str = datetime.now().strftime("%Y%m%d")
        hash_str = hashlib.md5(title.encode()).hexdigest()[:8]
        return f"evt_{date_str}_{hash_str}"
    
    async def fetch_hot_search(self) -> List[dict]:
        """Fetch hot search data from Weibo API."""
        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                # 尝试主 API
                response = await client.get(
                    self.HOT_SEARCH_API,
                    headers=self.headers
                )
                
                if response.status_code == 200:
                    data = response.json()
                    if "data" in data and "realtime" in data["data"]:
                        return data["data"]["realtime"]
                
                # 主 API 失败，尝试备用
                logger.warning("Primary API failed, trying backup...")
                return await self._fetch_from_backup(client)
                
            except Exception as e:
                logger.error(f"Failed to fetch hot search: {e}")
                return await self._fetch_from_backup(client)
    
    async def _fetch_from_backup(self, client: httpx.AsyncClient) -> List[dict]:
        """Fetch from backup API."""
        try:
            response = await client.get(self.BACKUP_API)
            if response.status_code == 200:
                data = response.json()
                if "data" in data:
                    return data["data"]
        except Exception as e:
            logger.error(f"Backup API also failed: {e}")
        return []
    
    def _parse_heat_score(self, raw_heat: Optional[int]) -> int:
        """Convert raw heat number to 0-100 score."""
        if not raw_heat:
            return 50
        # 假设最高热度为 500 万
        max_heat = 5000000
        score = min(int((raw_heat / max_heat) * 100), 100)
        return max(score, 10)  # 最低 10 分
    
    async def get_events(self, limit: int = 20) -> List[Event]:
        """Get hot events as Event models."""
        raw_data = await self.fetch_hot_search()
        events = []
        
        # 如果 API 返回空，使用 Mock 数据
        if not raw_data:
            logger.warning("Using mock data due to API unavailability")
            return self._get_mock_events(limit)
        
        for item in raw_data[:limit]:
            try:
                # 解析不同 API 格式
                title = item.get("word") or item.get("name") or item.get("title", "")
                if not title:
                    continue
                
                raw_heat = item.get("raw_hot") or item.get("hot") or item.get("num", 0)
                
                event = Event(
                    id=self._generate_event_id(title),
                    title=title,
                    summary=f"微博热搜话题：{title}",  # 后续由 LLM 生成更详细摘要
                    heat_score=self._parse_heat_score(raw_heat),
                    sentiment=SentimentType.NEUTRAL,  # 后续由 LLM 分析
                    emotion_tags=[],
                    region="china",
                    sources=[
                        EventSource(
                            platform="weibo",
                            url=f"https://s.weibo.com/weibo?q=%23{title}%23",
                            author=None
                        )
                    ],
                    keywords=title.split()[:5],
                    created_at=datetime.now(),
                    updated_at=datetime.now()
                )
                events.append(event)
                
                # 请求间隔
                await asyncio.sleep(0.1)
                
            except Exception as e:
                logger.warning(f"Failed to parse event: {e}")
                continue
        
        logger.info(f"Fetched {len(events)} events from Weibo")
        return events
    
    def _get_mock_events(self, limit: int = 20) -> List[Event]:
        """Generate mock events for demo/testing."""
        mock_data = [
            {"title": "2026年春运正式开启 预计发送旅客90亿人次", "heat": 4500000, "sentiment": "neutral", "emotions": ["期待", "关注"]},
            {"title": "AI技术突破：国产大模型性能超越GPT-5", "heat": 3800000, "sentiment": "positive", "emotions": ["惊喜", "自豪", "好奇"]},
            {"title": "央行宣布降准0.5个百分点 释放流动性", "heat": 3200000, "sentiment": "mixed", "emotions": ["期待", "观望"]},
            {"title": "新能源汽车出口量再创新高", "heat": 2900000, "sentiment": "positive", "emotions": ["喜悦", "自豪"]},
            {"title": "教育部发布2026年高考改革方案", "heat": 2500000, "sentiment": "mixed", "emotions": ["关注", "焦虑", "期待"]},
            {"title": "某知名企业裁员30%引发热议", "heat": 2200000, "sentiment": "negative", "emotions": ["担忧", "愤怒", "不安"]},
            {"title": "国足亚洲杯小组赛首战告捷", "heat": 2000000, "sentiment": "positive", "emotions": ["喜悦", "激动"]},
            {"title": "短视频平台整顿低俗内容", "heat": 1800000, "sentiment": "positive", "emotions": ["支持", "期待"]},
            {"title": "房地产新政策出台 限购松绑", "heat": 1600000, "sentiment": "mixed", "emotions": ["观望", "期待", "质疑"]},
            {"title": "冬季流感高发 专家提醒注意防护", "heat": 1400000, "sentiment": "neutral", "emotions": ["关注", "担忧"]},
        ]
        
        events = []
        for i, item in enumerate(mock_data[:limit]):
            sentiment_map = {
                "positive": SentimentType.POSITIVE,
                "negative": SentimentType.NEGATIVE,
                "neutral": SentimentType.NEUTRAL,
                "mixed": SentimentType.MIXED
            }
            
            event = Event(
                id=self._generate_event_id(item["title"]),
                title=item["title"],
                summary=f"[Mock] 这是关于「{item['title']}」的舆情分析摘要。该话题在社交平台引发广泛讨论...",
                heat_score=self._parse_heat_score(item["heat"]),
                sentiment=sentiment_map.get(item["sentiment"], SentimentType.NEUTRAL),
                emotion_tags=item["emotions"],
                region="china",
                sources=[
                    EventSource(
                        platform="weibo",
                        url=f"https://s.weibo.com/weibo?q=%23{item['title']}%23",
                        author="Mock Data"
                    )
                ],
                keywords=item["title"].split()[:3],
                created_at=datetime.now(),
                updated_at=datetime.now()
            )
            events.append(event)
        
        return events


# Singleton instance
weibo_crawler = WeiboCrawler()
