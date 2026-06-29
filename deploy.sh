#!/bin/sh
cd /opt/handover-haven || exit 1
git fetch origin main || exit 1
if ! git diff --quiet HEAD origin/main; then
  echo "[$(date)] New commit found, redeploying..."
  git pull origin main
  docker compose down
  docker compose build
  docker compose up -d
else
  echo "[$(date)] No updates"
fi
