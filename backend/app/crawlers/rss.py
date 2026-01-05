"""RSS Crawler"""

import asyncio
import hashlib
import feedparser
from datetime import datetime
from typing import List, Optional
from loguru import logger

from app.models.event import Event, EventSource, SentimentType


class RSSCrawler:
    """Crawler for RSS feeds."""
    
    # 36Kr RSS Feed (Tech News)
    RSS_URL = "https://36kr.com/feed"
    
    def _generate_event_id(self, title: str) -> str:
        """Generate unique event ID."""
        date_str = datetime.now().strftime("%Y%m%d")
        hash_str = hashlib.md5(title.encode()).hexdigest()[:8]
        return f"rss_{date_str}_{hash_str}"
    
    async def fetch_feed(self) -> List[dict]:
        """Fetch and parse RSS feed."""
        try:
            # feedparser fetch is blocking, run in executor
            loop = asyncio.get_event_loop()
            feed = await loop.run_in_executor(None, feedparser.parse, self.RSS_URL)
            
            if feed.bozo:
                logger.warning(f"RSS parse error: {feed.bozo_exception}")
            
            return feed.entries
            
        except Exception as e:
            logger.error(f"Failed to fetch RSS feed: {e}")
            return []
    
    async def get_events(self, limit: int = 20) -> List[Event]:
        """Get RSS items as Event models."""
        entries = await self.fetch_feed()
        events = []
        
        for entry in entries[:limit]:
            try:
                title = entry.get("title", "")
                summary = entry.get("summary", "") or entry.get("description", "")
                link = entry.get("link", "")
                published = entry.get("published_parsed") or datetime.now().timetuple()
                
                # Simple cleaning
                if "<" in summary:
                    # Remove HTML tags (simple version)
                    import re
                    summary = re.sub(r'<[^>]+>', '', summary)
                
                event = Event(
                    id=self._generate_event_id(title),
                    title=title,
                    summary=summary[:200] + "..." if len(summary) > 200 else summary,
                    heat_score=60,  # Default score for RSS items
                    sentiment=SentimentType.NEUTRAL,
                    emotion_tags=["资讯"],
                    region="china",
                    sources=[
                        EventSource(
                            platform="rss",
                            url=link,
                            author="36Kr"
                        )
                    ],
                    keywords=["科技", "新闻"],
                    created_at=datetime.now(),
                    updated_at=datetime.now()
                )
                events.append(event)
                
            except Exception as e:
                logger.warning(f"Failed to parse RSS entry: {e}")
                continue
        
        logger.info(f"Fetched {len(events)} events from RSS")
        return events


# Singleton instance
rss_crawler = RSSCrawler()
