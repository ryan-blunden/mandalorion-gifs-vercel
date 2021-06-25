#!/usr/bin/env bash

set -e

./bin/doppler-check.sh

random_id() {
  docker run --rm alpine/openssl rand -base64 32
}

echo '[info]: Creating "mandalorion-gifs" project'
doppler projects create mandalorion-gifs --silent
doppler setup --no-prompt --silent

echo '[info]: Setting initial configuration using sample.env'
doppler secrets upload --silent --config dev sample.env
doppler secrets upload --silent --config stg sample.env
doppler secrets upload --silent --config prd sample.env

echo '[info]: Setting random Webhook secrets'
doppler secrets set --silent --config dev WEBHOOK_SECRET "$(random_id)"
doppler secrets set --silent --config stg WEBHOOK_SECRET "$(random_id)"
doppler secrets set --silent --config prd WEBHOOK_SECRET "$(random_id)"

echo '[info]: Adjusting values for production environment'
doppler secrets delete NODE_DEV --config prd -y

echo '[info]: Setting GIPHY API KEY (if supplied)'
echo -n 'GIPHY API KEY: ' && read -s GIPHY_API_KEY
doppler secrets set --silent GIPHY_API_KEY="$GIPHY_API_KEY"
doppler secrets set --silent --config stg GIPHY_API_KEY="$GIPHY_API_KEY"
doppler secrets set --silent --config prd GIPHY_API_KEY="$GIPHY_API_KEY"

echo '[info]: Setting default local Doppler config to "dev"'
doppler setup --no-prompt --silent

echo '[info]: Opening the Doppler dashboard'
doppler open dashboard
