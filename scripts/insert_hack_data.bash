#!/bin/bash

# Configuration
RABBITMQ_HOST="localhost"
RABBITMQ_PORT="15672"
USERNAME="guest"
PASSWORD="guest"
VHOST="%2f"
EXCHANGE_NAME=""
ROUTING_KEY="ai-hackathon-registrations"

# The Team Data
TEAM_DATA='[
  {
    "team_name": "Neural Knights",
    "leader_name": "Aarav Mehta",
    "leader_email": "aarav.mehta.dev@gmail.com",
    "leader_phone_number": "9820012345",
    "leader_college_name": "BITS Pilani",
    "problem_statement": "agentic_ai",
    "team_members": [
      {
        "name": "Ishani Roy",
        "email": "i.roy.bits@gmail.com",
        "phone_number": "9820012346",
        "college_name": "BITS Pilani"
      },
      {
        "name": "Sahil Gupta",
        "email": "s.gupta.dev@gmail.com",
        "phone_number": "9820012347",
        "college_name": "BITS Pilani"
      }
    ]
  },
  {
    "team_name": "Edge Pulse",
    "leader_name": "Chloe Simmons",
    "leader_email": "chloe.simm@gmail.com",
    "leader_phone_number": "+1-415-555-0199",
    "leader_college_name": "MIT",
    "problem_statement": "aiot",
    "team_members": [
      {
        "name": "Marcus Wright",
        "email": "m.wright.eng@gmail.com",
        "phone_number": "+1-415-555-0122",
        "college_name": "MIT"
      }
    ]
  },
  {
    "team_name": "Creative Quanta",
    "leader_name": "Yuki Tanaka",
    "leader_email": "yuki.tanaka.art@gmail.com",
    "leader_phone_number": "+81-90-1234-5678",
    "leader_college_name": "University of Tokyo",
    "problem_statement": "generative_ai",
    "team_members": [
      {
        "name": "Kenji Sato",
        "email": "k.sato.research@gmail.com",
        "phone_number": "+81-90-8765-4321",
        "college_name": "University of Tokyo"
      },
      {
        "name": "Hina Mori",
        "email": "hina.mori.dev@gmail.com",
        "phone_number": "+81-90-5555-6666",
        "college_name": "University of Tokyo"
      }
    ]
  }
]'

echo "Starting publication of team data..."

# Parse the array and loop through each team
echo "$TEAM_DATA" | jq -c '.[]' | while read -r team; do
    TEAM_NAME=$(echo "$team" | jq -r '.team_name')
    echo "Publishing team: $TEAM_NAME"

    # Construct the RabbitMQ HTTP API payload
    # Note: content_type is set to application/json to avoid webhook 400 errors
    PAYLOAD=$(jq -n \
                  --arg body "$team" \
                  --arg rkey "$ROUTING_KEY" \
                  '{
                    "properties": {
                      "delivery_mode": 2,
                      "content_type": "application/json"
                    },
                    "routing_key": $rkey,
                    "payload": $body,
                    "payload_encoding": "string"
                  }')

    # Execute POST request
    RESPONSE=$(curl -s -u "$USERNAME:$PASSWORD" \
         -H "Content-Type: application/json" \
         -X POST "http://$RABBITMQ_HOST:$RABBITMQ_PORT/api/exchanges/$VHOST/$EXCHANGE_NAME/publish" \
         -d "$PAYLOAD")

    # Check if publication was successful
    if [[ "$RESPONSE" == *"\"routed\":true"* ]]; then
        echo " Success: Team $TEAM_NAME published."
    else
        echo " Error: Failed to publish $TEAM_NAME. Response: $RESPONSE"
    fi
done

echo "Done."
