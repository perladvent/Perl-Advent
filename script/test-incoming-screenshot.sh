#!/bin/bash
#
# Test incoming article screenshot workflow
#
# This simulates the CI workflow for incoming articles
#

set -eu -o pipefail

YEAR=$(date +%Y)
echo "📅 Testing incoming article workflow for year: $YEAR"

# Clean up any previous test artifacts
echo ""
echo "🧹 Cleaning up previous test artifacts..."
docker compose down 2>/dev/null || true
rm -rf screenshots out out-host 2>/dev/null || true

# Step 1: Build Docker image
echo ""
echo "🐳 Step 1: Building Docker image..."
docker compose build

# Step 2: Detect changed articles (simulate)
echo ""
echo "🔍 Step 2: Simulating changed incoming files..."
CHANGED_FILES=$(find ${YEAR}/incoming -name "*.pod" 2>/dev/null)

if [ -z "$CHANGED_FILES" ]; then
    echo "❌ No incoming articles found"
    exit 1
fi

echo "Found incoming articles:"
echo "$CHANGED_FILES"

# Step 3: Build site (incoming path)
echo ""
echo "📚 Step 3: Building site with incoming articles..."
docker compose run --rm perl-advent bash -c "perl script/render-incoming.pl && bash script/build-site.sh --single-year $YEAR --today ${YEAR}-12-25"

# Step 4: Copy build output to host
echo ""
echo "📤 Step 4: Copying build output to host..."
docker compose run --rm perl-advent cp -r /app/out /app/out-host
mv out-host out

echo "Contents of out/$YEAR:"
ls -la out/$YEAR/*.html 2>/dev/null | head -10

# Step 5: Start Docker server
echo ""
echo "🌐 Step 5: Starting Docker server..."
docker compose up -d --no-deps perl-advent-server

# Wait for server
sleep 3
SERVER_READY=false
for i in $(seq 1 10); do
    if curl -s "http://localhost:7007/$YEAR/" > /dev/null 2>&1; then
        echo "✅ Server is ready and serving $YEAR directory"
        SERVER_READY=true
        break
    fi
    echo "Waiting for server... attempt $i"
    sleep 2
done

if [ "$SERVER_READY" = "false" ]; then
    echo "❌ Server failed to start"
    docker compose down
    exit 1
fi

# Step 6: Install Playwright (if needed)
echo ""
echo "🎭 Step 6: Checking Playwright..."
if [ ! -d "node_modules/playwright" ]; then
    npm install playwright
fi

if ! npx playwright --version > /dev/null 2>&1; then
    npx playwright install chromium
fi

# Step 7: Take screenshots
echo ""
echo "📸 Step 7: Taking screenshots..."
mkdir -p screenshots

export CHANGED_FILES="$CHANGED_FILES"
export YEAR="$YEAR"
export SERVER_PORT=7007

node script/ci/take-screenshots.js

# Step 8: Cleanup
echo ""
echo "🛑 Step 8: Stopping server..."
docker compose down

# Step 9: Verify results
echo ""
echo "✅ Test complete!"
echo ""
echo "📁 Generated screenshots:"
ls -lh screenshots/

if [ -f "screenshots/info.json" ]; then
    echo ""
    echo "📋 Screenshot info:"
    cat screenshots/info.json | jq '.' 2>/dev/null || cat screenshots/info.json
fi

echo ""
echo "🔍 Verifying screenshot matching..."
if [ -f "screenshots/info.json" ]; then
    ARTICLE_COUNT=$(cat screenshots/info.json | jq 'length' 2>/dev/null || echo "0")
    echo "Screenshots generated for $ARTICLE_COUNT article(s)"

    # Show which HTML file was matched
    cat screenshots/info.json | jq -r '.[] | "  \(.article) -> \(.htmlFile)"' 2>/dev/null || echo "Could not parse JSON"
fi

echo ""
echo "🎉 Incoming article screenshot test complete!"
echo ""
echo "💡 To view a screenshot:"
echo "   Open screenshots/*.png with an image viewer"
