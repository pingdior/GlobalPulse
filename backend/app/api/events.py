"""Events API Router"""

from typing import Optional
from fastapi import APIRouter, HTTPException, Query
from loguru import logger

from app.models.event import Event, EventList
from app.crawlers.weibo import weibo_crawler
from app.crawlers.rss import rss_crawler
from app.services.llm_service import llm_service

router = APIRouter(prefix="/events", tags=["Events"])

# 缓存事件数据
_events_cache: dict[str, Event] = {}


@router.get("", response_model=EventList)
async def get_events(
    region: str = Query(default="china", description="Region code"),
    limit: int = Query(default=20, ge=1, le=50, description="Number of events to return"),
    enrich: bool = Query(default=False, description="Enable LLM enrichment (slower)"),
    source: str = Query(default="weibo", description="Data source: weibo or rss")
):
    """
    获取热点事件列表
    
    - **source**: 数据源，可选 "weibo" (默认) 或 "rss"
    """
    global _events_cache
    
    try:
        # 选择爬虫
        if source == "rss":
            events = await rss_crawler.get_events(limit=limit)
        else:
            events = await weibo_crawler.get_events(limit=limit)
        
        # LLM 增强（可选）
        if enrich and events:
            logger.info("Enriching events with LLM...")
            events = await llm_service.enrich_events(events, max_concurrent=5)
        
        # 更新缓存
        for event in events:
            _events_cache[event.id] = event
        
        return EventList(
            total=len(events),
            region=region,
            events=events
        )
    
    except Exception as e:
        logger.error(f"Failed to get events: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/compare", response_model=dict)
async def compare_perspectives(
    title: str = Query(..., description="Event title"),
    summary: str = Query(default="", description="Event summary")
):
    """
    获取跨区舆情对比分析 (Powered by LLM)
    """
    try:
        if not title:
            raise HTTPException(status_code=400, detail="Title is required")
            
        result = await llm_service.analyze_comparison(title, summary)
        return result
    except Exception as e:
        logger.error(f"Error in comparison: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{event_id}", response_model=Event)
async def get_event_detail(event_id: str):
    """
    获取单个事件详情
    
    - **event_id**: 事件 ID
    """
    # 从缓存获取
    if event_id in _events_cache:
        return _events_cache[event_id]
    
    raise HTTPException(status_code=404, detail="Event not found")


@router.post("/{event_id}/enrich", response_model=Event)
async def enrich_event(event_id: str):
    """
    使用 LLM 增强事件信息
    
    - **event_id**: 事件 ID
    """
    if event_id not in _events_cache:
        raise HTTPException(status_code=404, detail="Event not found")
    
    event = _events_cache[event_id]
    enriched = await llm_service.enrich_event(event)
    _events_cache[event_id] = enriched
    
    return enriched



