#!/bin/sh

CLUSTER_ID="fMCL8kv1SWm87L_Md-I2hg"

# Generate kafka.properties dynamically
cat <<EOF > /tmp/kafka.properties
node.id=$KAFKA_NODE_ID
process.roles=broker,controller
controller.listener.names=CONTROLLER
listener.security.protocol.map=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT
listeners=PLAINTEXT://$HOSTNAME:29092,CONTROLLER://$HOSTNAME:29093
log.dirs=/tmp/kraft-combined-logs
controller.quorum.voters=1@kafka0:29093,2@kafka1:29093
EOF

# Only format if not already formatted
if [ ! -f "/tmp/kraft-combined-logs/meta.properties" ]; then
  echo "Formatting storage with cluster ID: $CLUSTER_ID"
  kafka-storage format --ignore-formatted --cluster-id "$CLUSTER_ID" --config /tmp/kafka.properties
else
  echo "Storage already formatted"
fi

# Remove ZooKeeper references from Docker scripts
sed -i '/KAFKA_ZOOKEEPER_CONNECT/d' /etc/confluent/docker/configure
sed -i 's/cub zk-ready/echo zk-ready skipped/' /etc/confluent/docker/ensure

# Launch Kafka
exec /etc/confluent/docker/run
