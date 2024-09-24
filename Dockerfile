# Use a base image that includes bash and necessary dependencies
FROM debian:12-slim

# Set environment variables for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies (e.g., curl, kubectl)
RUN apt-get update && \
    apt-get install -y curl sudo && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Set the working directory inside the container
WORKDIR /opt/scripts

# Copy the script files from your repository to the container
COPY wal-g-retention.sh postgres_backup.sh /opt/scripts/

# Make the scripts executable
RUN chmod +x /opt/scripts/wal-g-retention.sh /opt/scripts/postgres_backup.sh

# Set the default command to run your retention script
CMD ["/opt/scripts/wal-g-retention.sh"]
