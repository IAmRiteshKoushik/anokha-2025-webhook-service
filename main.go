package main

import (
	"fmt"

	amqp "github.com/rabbitmq/amqp091-go"
)

func main() {
	fmt.Println("Hello world")
}

const (
	QueueHackathonRegistrations = "ai-hackathon-registrations"
	QueueWocRegistrations       = "woc-registrations"
	QueueDebateRegistrations    = "debate-registrations"
)

var allQueues = []string{
	QueueDebateRegistrations,
	QueueWocRegistrations,
	QueueHackathonRegistrations,
}

var Rabbit *MsgBroker

type MsgBroker struct {
	conn *amqp.Connection
}
