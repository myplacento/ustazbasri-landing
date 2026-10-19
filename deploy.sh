#!/bin/bash
set -e
cd /home/ubuntu/landing-ustazbasri
TOKEN=$(cat /home/ubuntu/threads-dashboard/.gh_token)

echo "=== 1. CIPTA REPO ==="
CODE=$(curl -s -X POST -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d '{"name":"ustazbasri-landing","description":"Landing page Ustaz Basri - preview","private":false}' \
  -o /tmp/repo.json -w "%{http_code}")
echo "HTTP $CODE"
python3 -c "
import json
d = json.load(open('/tmp/repo.json'))
print('repo:', d.get('full_name'), '| msg:', d.get('message'))
"

echo "=== 2. INIT DAN PUSH ==="
git init -q
git add -A
git -c user.email=basri@local -c user.name=basri commit -qm "Landing page v1 - preview" || true
git branch -M main
git remote remove origin 2>/dev/null || true
git remote add origin "https://x-access-token:${TOKEN}@github.com/myplacento/ustazbasri-landing.git"
git push -q -u origin main
echo "PUSH OK"

echo "=== 3. AKTIFKAN PAGES ==="
curl -s -X POST -H "Authorization: token $TOKEN" -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/myplacento/ustazbasri-landing/pages \
  -d '{"source":{"branch":"main","path":"/"}}' -o /tmp/pages.json -w "HTTP %{http_code}\n"
python3 -c "
import json
d = json.load(open('/tmp/pages.json'))
print('pages url:', d.get('html_url'), '| status:', d.get('status'), '| msg:', d.get('message'))
"
