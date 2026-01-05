"""Tests for Events API"""

import pytest
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest.fixture
def anyio_backend():
    return "asyncio"


@pytest.fixture
async def client():
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as ac:
        yield ac


@pytest.mark.anyio
async def test_root(client: AsyncClient):
    """Test root endpoint."""
    response = await client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "GlobalPulse API"
    assert "version" in data


@pytest.mark.anyio
async def test_health_check(client: AsyncClient):
    """Test health check endpoint."""
    response = await client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"


@pytest.mark.anyio
async def test_get_events(client: AsyncClient):
    """Test get events endpoint."""
    response = await client.get("/api/events?limit=5")
    assert response.status_code == 200
    data = response.json()
    assert "total" in data
    assert "region" in data
    assert "events" in data
    assert isinstance(data["events"], list)


@pytest.mark.anyio
async def test_get_event_not_found(client: AsyncClient):
    """Test get non-existent event."""
    response = await client.get("/api/events/non_existent_id")
    assert response.status_code == 404
