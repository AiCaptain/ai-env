#!/bin/bash

# Pfad zur docker-compose.yml Datei
COMPOSE_FILE="all-services-docker-compose.yaml"

# Funktion zum Herunterfahren, Aktualisieren und Starten eines einzelnen Containers
update_container() {
    local service_name=$1

    echo "Stopping container: $service_name"
    sudo docker compose -f $COMPOSE_FILE stop $service_name

    echo "Pulling new image for: $service_name"
    sudo docker compose -f $COMPOSE_FILE pull $service_name

    echo "Starting container: $service_name"
    sudo docker compose -f $COMPOSE_FILE up -d $service_name

    # Überprüfen, ob der Container erfolgreich gestartet wurde
    if sudo docker compose -f $COMPOSE_FILE ps -q $service_name | grep -q .; then
        echo "Container $service_name started successfully."
        cleanup_images
    else
        echo "Failed to start container: $service_name"
    fi
}

# Funktion zum Löschen alter Images
cleanup_images() {
    echo "Cleaning up old images..."
    sudo docker image prune -f
}

# Hauptfunktion
main() {
    # Liste aller Dienste aus der docker-compose.yml Datei
    services=$(sudo docker compose -f $COMPOSE_FILE config --services)

    # Aktualisiere jeden Dienst einzeln
    for service in $services; do
        update_container $service
    done

    echo "Update and cleanup completed."
}

# Skript ausführen
main
