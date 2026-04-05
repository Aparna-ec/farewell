#!/bin/bash
set -e
cd "$(dirname "$0")"

# Create output directory
mkdir -p build_output

# Loop through all 21 variants
for i in {1..21}; do
  echo "Building variant $i..."
  
  # Build web version for this variant
  flutter build web \
    --dart-define=PERSON_ID=$i \
    --output "build_output/person_$i"
    
done

echo "All 21 variants built successfully!"
