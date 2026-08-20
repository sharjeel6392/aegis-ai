# Aegis

Open-source AIOps: alerts in, AI-generated root-cause analysis out.

Aegis ingests alerts from your monitoring stack (Prometheus Alertmanager first), persists and correlates them into incidents,
and hands each incident to an LLM pipeline that produces a written root-cause analysis with the evidence it used.

> **Status:** Week 1 of 16 — working skeleton. The plumbing is being built; there is not AI in the loop yet.

## Architecture (target state, v1)

```
Alertmanager ──▶ POST /webhook/prometheus ──▶ Postgres (alerts, incidents)
                          │                        ▲
                          │ publish                │ write
                          ▼                        │
                   Redis (arq queue) ──▶ worker ───┘
                                            │
                                            └──▶ LLM pipeline ──▶ RCA
```

Everything on the request path is async: FastAPI, SQLAlchemy 2.0 async engine + asyncpg, and arq (Redis-native, async-first) for background work. That choice is load-bearing ─ a sync call anywhere on this path blocks the event loop.

---

## Layout
| Path                 | Contents                                                      |
| -------------------- | ------------------------------------------------------------- |
| `src/aegis/`         | Application package (src layout ─ import it, never path-hack) |
| `tests/`             | pytest suite; files are prefixed `test_`                      |
| `infra/`             | `Dockerfile` and, later, deployment manifests                 |
| `docker-compose.yml` | Local stack: app + postgres + redis                           |
| `Makefile`           | Canonical entrypoints ─ see below                             |
| `.env.example`       | Every congfig key, 1:1 with `aegis.settings.Settings`         |

---

## Requirements

- [uv](http://docs.astral.sh/uv/) ─ the only package manager used here. No `pip`, no `poetry`, never `--system`.
- Docker with Compose v2 (Linux containers).
- GNU make. Python itself is fetched by uv (3.12, pinned in `.python-version`).

## Setup

```bash
cp .env.example .env            # adjust if you want non-default credentials
make install                    # uv sync → creates .venv from uv.lock
make dev                        # build + start app, postgres, redis in the foreground
```

`make dev` is ready when the app container logs `aegis <version> scaffold OK` and both `postgres` and `redis` report healthy in `make ps`.

## Commands

| Command            | Does                                          |
| ------------------ | --------------------------------------------- |
| `make install`     | Sync dependencies into `.venv`                |
| `make lock`        | Regenerate `uv.lock`                          |
| `make dev`         | Build and run the stack in the foreground     |
| `make up` / `down` | Start detached / stop (volumes preserved)     |
| `make clean`       | Stop and **delete** volumes ─ full clean boot |
| `make logs`        | Follow app logs                               |
| `make ps`          | Container status                              |
| `make test`        | `pytest`                                      |
| `make lint`        | `ruff check` + format check                   |
| `make fmt`         | `ruff format` + autofix                       |
| `make typecheck`   | `mypy --strict`                               |
| `make check`       | lint + typecheck + test                       |

Run tools through uv (`uv run pytest`), not by activating `.venv` by hand.

## Development

Test-driven where practical: write the failing tests in `tests/test_*.py` first. `mypy` runs in strict mode over `src` and `tests`, and `ruff` owns both linting and formatting ─ install the hooks once with `uv run pre-commit install` and both run on every commit, pinned to the versions in `uv.lock` rather than to upstream tag that can drift.

Source is bind-mounted into the app container, so edits are live; the virtualenv at `opt/venv` is deliberately outside the mount so it isn't shadowed.

### On Windows

`uv` and `make` install to per-user directories added to `PATH` ─ open a new terminal after installing either, or the commands won't resolve.

--- 

## License
MIT ─ see `LICENSE`.