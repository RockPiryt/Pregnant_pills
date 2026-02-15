#!/bin/sh
set -eu pipefail

echo "APP_ENV=$APP_ENV"
echo "FLASK_APP=$FLASK_APP"
echo "DATABASE_URL=$DATABASE_URL"

echo "==> Waiting for DB to be reachable..."
python - <<'PY'
import os, time
import sqlalchemy as sa
url = os.environ["DATABASE_URL"]
engine = sa.create_engine(url, pool_pre_ping=True)
for i in range(60):
    try:
        with engine.connect() as c:
            c.execute(sa.text("SELECT 1"))
        print("DB is ready")
        break
    except Exception as e:
        print(f"DB not ready yet ({i+1}/60): {e}")
        time.sleep(2)
else:
    raise SystemExit("DB did not become ready in time")
PY

echo "==> Running migrations: flask db upgrade"
flask db upgrade

echo "==> Cleaning data (TRUNCATE) via clean.sql"
python - <<'PY'
import os
import sqlalchemy as sa
url = os.environ["DATABASE_URL"]
engine = sa.create_engine(url)
sql = open("/reset/clean.sql","r",encoding="utf-8").read()
with engine.begin() as conn:
    conn.execute(sa.text(sql))
print("Clean done")
PY

echo "==> Seeding data via seed.sql"
python - <<'PY'
import os
import sqlalchemy as sa
url = os.environ["DATABASE_URL"]
engine = sa.create_engine(url)
sql = open("/reset/seed.sql","r",encoding="utf-8").read()
with engine.begin() as conn:
    conn.execute(sa.text(sql))
print("Seed done")
PY

echo "==> DB reset finished ✅"
