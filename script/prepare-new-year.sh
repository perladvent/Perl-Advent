#!/bin/bash

# Script to prepare Perl Advent Calendar for a new year
# Usage: ./script/prepare-new-year.sh

set -e

NEW_YEAR=$(date +%Y)
PREVIOUS_YEAR=$((NEW_YEAR - 1))

echo "Preparing Perl Advent Calendar for year $NEW_YEAR..."

# Check if previous year directory exists
if [ ! -d "$PREVIOUS_YEAR" ]; then
    echo "Error: Previous year directory '$PREVIOUS_YEAR' not found"
    exit 1
fi

# Create scaffolding
echo "Creating scaffolding for $NEW_YEAR..."
mkdir -p "$NEW_YEAR"
cp "$PREVIOUS_YEAR/advent.ini" "$NEW_YEAR/"

# Find and replace year in various files
echo "Updating year references from $PREVIOUS_YEAR to $NEW_YEAR..."
perl -pi -e "s/$PREVIOUS_YEAR/$NEW_YEAR/g" \
    .github/pull_request_template.md \
    in-season.html \
    README.md \
    script/build-site.sh \
    script/stats.sh \
    "$NEW_YEAR/advent.ini"

echo "Successfully prepared for year $NEW_YEAR!"
echo "Don't forget to check the updated files and commit the changes."
