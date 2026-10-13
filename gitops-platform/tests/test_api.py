from app.main import create_app


def test_healthz():
    client = create_app().test_client()
    response = client.get("/healthz")
    assert response.status_code == 200
    assert response.json == {"status": "ok"}


def test_release_metadata(monkeypatch):
    monkeypatch.setenv("APP_VERSION", "1.2.3")
    monkeypatch.setenv("GIT_SHA", "abc123")
    monkeypatch.setenv("APP_ENV", "dev")
    client = create_app().test_client()
    response = client.get("/api/v1/release")
    assert response.json["version"] == "1.2.3"
    assert response.json["commit"] == "abc123"
    assert response.json["managed_by"] == "argocd"
