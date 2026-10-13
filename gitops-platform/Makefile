install:
	python -m venv .venv && . .venv/bin/activate && pip install -r requirements-dev.txt

test:
	python -m pytest -q

run:
	python -m app.main

docker-build:
	docker build -t gitops-release-api:local .

docker-run:
	docker run --rm -p 8080:8080 gitops-release-api:local
