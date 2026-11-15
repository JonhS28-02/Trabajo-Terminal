"""Esquema inicial y catálogos, tomados de la base local del prototipo (2026-11-15).

Revision ID: 0001
Revises:
"""
from pathlib import Path

from alembic import op

revision = "0001"
down_revision = None
branch_labels = None
depends_on = None

SQL_DIR = Path(__file__).resolve().parent.parent / "sql"


def upgrade() -> None:
    op.execute((SQL_DIR / "0001_esquema.sql").read_text(encoding="utf-8"))
    op.execute((SQL_DIR / "0001_catalogos.sql").read_text(encoding="utf-8"))


def downgrade() -> None:
    raise NotImplementedError("La migración inicial no se revierte; elimine la base de datos.")
