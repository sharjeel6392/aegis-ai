"""Day 1 scaffold guardrail: the package imports"""

from pathlib import Path

import aegis

PROJECT_ROOT = Path(__file__).resolve().parents[1]


def test_package_imports_and_is_versioned() -> None:
    assert aegis.__version__ == "0.1.0"


def test_src_layout_is_intact() -> None:
    assert (PROJECT_ROOT / "src" / "aegis" / "__init__.py").is_file()
    assert (PROJECT_ROOT / "src" / "aegis" / "py.typed").is_file()


def test_scaffold_files_present() -> None:
    for name in (
        "pyproject.toml",
        "docker-compose.yml",
        "Makefile",
        "LICENSE",
        ".env.example",
        ".gitignore",
        ".pre-commit-config.yaml",
        "infra/Dockerfile",
    ):
        assert (PROJECT_ROOT / name).is_file(), f"missing scaffold file: {name}"
