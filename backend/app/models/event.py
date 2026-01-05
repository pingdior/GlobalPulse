"""Event Data Models"""

from datetime import datetime
from enum import Enum
from typing import Optional, List
from pydantic import BaseModel, Field


class SentimentType(str, Enum):
    """Sentiment type enumeration."""
    POSITIVE = "positive"
    NEGATIVE = "negative"
    NEUTRAL = "neutral"
    MIXED = "mixed"


class EventSource(BaseModel):
    """Event source information."""
    platform: str = Field(..., description="Source platform (weibo, xiaohongshu, etc.)")
    url: Optional[str] = Field(None, description="Original URL")
    author: Optional[str] = Field(None, description="Original author/account")


class Event(BaseModel):
    """Hot event data model."""
    id: str = Field(..., description="Unique event ID")
    title: str = Field(..., description="Event title")
    summary: str = Field(..., description="AI-generated summary")
    heat_score: int = Field(..., ge=0, le=100, description="Heat score (0-100)")
    sentiment: SentimentType = Field(default=SentimentType.NEUTRAL, description="Sentiment analysis result")
    emotion_tags: List[str] = Field(default_factory=list, description="Emotion tags (anger, joy, fear, etc.)")
    region: str = Field(default="china", description="Region code")
    sources: List[EventSource] = Field(default_factory=list, description="Source list")
    keywords: List[str] = Field(default_factory=list, description="Keywords")
    created_at: datetime = Field(default_factory=datetime.now, description="Created time")
    updated_at: datetime = Field(default_factory=datetime.now, description="Updated time")

    class Config:
        json_schema_extra = {
            "example": {
                "id": "evt_20240104_001",
                "title": "某科技公司发布新品引发热议",
                "summary": "该公司发布的新产品在社交媒体上引发广泛讨论，用户反馈褒贬不一...",
                "heat_score": 85,
                "sentiment": "mixed",
                "emotion_tags": ["excitement", "curiosity", "skepticism"],
                "region": "china",
                "sources": [
                    {"platform": "weibo", "url": "https://weibo.com/...", "author": "科技博主"}
                ],
                "keywords": ["科技", "新品", "发布会"],
                "created_at": "2024-01-04T10:00:00",
                "updated_at": "2024-01-04T10:00:00"
            }
        }


class EventList(BaseModel):
    """Event list response model."""
    total: int = Field(..., description="Total event count")
    region: str = Field(..., description="Region code")
    events: List[Event] = Field(default_factory=list, description="Event list")
