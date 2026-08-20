UV ?= uv
COMPOSE ?= docker compose

.PHONY: help install lock dev up down logs ps test lint fmt typecheck check clean

help:
	@echo "install		- sync dependencies into .venv (uv)"
	@echo "lock			- regenerate uv.lock"
	@echo "dev			- build and start the stack in the foreground"
	@echo "up			- start the stack detached"
	@echo "down			- stop the stack (keeps the volumes)"
	@echo "clean		- stop the stack and delete the volumes"
	@echo "logs			- follow app logs"
	@echo "ps			- show container status"
	@echo "test			- run pytest"
	@echo "lint			- ruff check + format check"
	@echo "fmt			- ruff format + autofix"
	@echo "typecheck	- mypy --strict"
	@echo "check		- lint + typecheck + test"

install:
	$(UV) sync

lock:
	$(UV) lock

dev:
	$(COMPOSE) up --build

up:
	$(COMPOSE) up -d --build

down:
	$(COMPOSE) down

clean:
	$(COMPOSE) down -v

logs:
	$(COMPOSE) logs -f app

ps:
	$(COMPOSE) ps

test:
	$(UV) run pytest

lint:
	$(UV) run ruff check .
	$(uv) run ruff format --check .

fmt:
	$(UV) run ruff format .
	$(UV) run ruff check --fix .

typecheck:
	$(UV) run mypy

check: lint typecheck test