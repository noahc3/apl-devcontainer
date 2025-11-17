#!/usr/bin/env bash

# Generate .env file with current user's UID and GID

ENV_FILE=".env"

echo "Generating ${ENV_FILE} with your user ID..."

cat > "${ENV_FILE}" << EOF
# User ID mapping for proper file ownership
USER_UID=$(id -u)
USER_GID=$(id -g)
EOF

echo "✓ ${ENV_FILE} created with:"
echo "  USER_UID=$(id -u)"
echo "  USER_GID=$(id -g)"
echo ""
echo "You can now build with: docker-compose up -d --build"
