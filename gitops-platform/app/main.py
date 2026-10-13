from flask import Flask, jsonify
import os
import time


def create_app():
    app = Flask(__name__)
    started_at = time.time()

    @app.get("/")
    def index():
        return jsonify({
            "service": "gitops-release-api",
            "version": os.getenv("APP_VERSION", "dev"),
            "environment": os.getenv("APP_ENV", "local"),
            "message": "Release metadata is reconciled from Git.",
        })

    @app.get("/healthz")
    def healthz():
        return jsonify({"status": "ok"})

    @app.get("/readyz")
    def readyz():
        return jsonify({"status": "ready", "uptime_seconds": round(time.time() - started_at, 2)})

    @app.get("/api/v1/release")
    def release():
        return jsonify({
            "service": "gitops-release-api",
            "version": os.getenv("APP_VERSION", "dev"),
            "commit": os.getenv("GIT_SHA", "local"),
            "environment": os.getenv("APP_ENV", "local"),
            "managed_by": "argocd",
        })

    return app


app = create_app()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8080")))
