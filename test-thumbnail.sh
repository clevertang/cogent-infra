#!/bin/bash

set -e

INPUT_IMAGE="demo.png"
OUTPUT_IMAGE="result.png"

if [ ! -f "$INPUT_IMAGE" ]; then
  echo "❌ Input image '$INPUT_IMAGE' not found."
  exit 1
fi

echo "📤 Uploading image to thumbnail.local..."
job_id=$(curl -s --location --request POST 'http://thumbnail.local/thumbnail' \
  --form "file=@${INPUT_IMAGE}" | jq -r '.data.job_id')

if [ -z "$job_id" ]; then
  echo "❌ Failed to get job_id from response."
  exit 1
fi

echo "✅ Upload successful. Job ID: $job_id"

# Optional: wait a few seconds or implement polling if processing is async
echo "⏳ Waiting for thumbnail to be ready..."
sleep 2

echo "📥 Downloading generated thumbnail..."
curl --location --request GET "http://thumbnail.local/thumbnail/${job_id}/image" --output "$OUTPUT_IMAGE"

echo "✅ Saved to $OUTPUT_IMAGE"
