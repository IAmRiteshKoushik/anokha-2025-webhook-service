#!/bin/bash

# Configuration
RABBITMQ_HOST="localhost"
RABBITMQ_PORT="15672"
USERNAME="guest"
PASSWORD="guest"
VHOST="%2f" # Default vhost '/' is URL-encoded as %2f
EXCHANGE_NAME=""
ROUTING_KEY="woc-registrations"

# Input JSON Data
USER_DATA='[
  {
    "firstName": "Marcus",
    "lastName": "Vane",
    "email": "m.vane@gmail.com",
    "password": "$2a$12$8yD4GCUfOqr7W5OO8DHFROmuLe55uGr6wAh6e58DeJVBaBp1OipSK"
  },
  {
    "firstName": "Elena",
    "lastName": "Rodriguez",
    "email": "elena.rod@gmail.com",
    "password": "$2a$12$8yD4GCUfOqr7W5OO8DHFROmuLe55uGr6wAh6e58DeJVBaBp1OipSK"
  },
  {
    "firstName": "Sanjay",
    "lastName": "Patel",
    "email": "spatel@gmail.com",
    "password": "$2a$12$8yD4GCUfOqr7W5OO8DHFROmuLe55uGr6wAh6e58DeJVBaBp1OipSK"
  },
  {
    "firstName": "Ingrid",
    "lastName": "Jensen",
    "email": "ingrid.j@gmail.com",
    "password": "$2a$12$8yD4GCUfOqr7W5OO8DHFROmuLe55uGr6wAh6e58DeJVBaBp1OipSK"
  },
  {
    "firstName": "Julian",
    "lastName": "Okoro",
    "email": "j.okoro@gmail.com",
    "password": "$2a$12$8yD4GCUfOqr7W5OO8DHFROmuLe55uGr6wAh6e58DeJVBaBp1OipSK"
  }
]'

# Iterate over each user in the JSON array using jq
echo "Starting publication to RabbitMQ..."

echo "$USER_DATA" | jq -c '.[]' | while read -r user; do
    echo "Publishing user: $(echo $user | jq -r '.email')"

    # Construct the RabbitMQ API payload
    # properties: delivery_mode 2 makes the message persistent
    PAYLOAD=$(jq -n \
                  --arg body "$user" \
                  --arg rkey "$ROUTING_KEY" \
                  '{properties: {delivery_mode: 2}, routing_key: $rkey, payload: $body, payload_encoding: "string"}')

    # Send POST request to RabbitMQ HTTP API
    curl -s -u "$USERNAME:$PASSWORD" \
         -H "Content-Type: application/json" \
         -X POST "http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/exchanges/$VHOST/$EXCHANGE_NAME/publish" \
         -d "$PAYLOAD"
    
    echo " Done."
done

echo "All users published successfully."
