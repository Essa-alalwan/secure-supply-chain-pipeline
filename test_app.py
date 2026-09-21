from fastapi.testclient import TestClient
from app import app

client = TestClient(app)

def test_health():
    r = client.get("/health")
    assert r.status_code == 200
    assert r.json() == {"status": "ok"}

def test_hello():
    r = client.get("/hello")
    assert r.status_code == 200
    assert "message" in r.json()