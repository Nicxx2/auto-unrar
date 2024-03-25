FROM debian:bookworm

# Add non-free and contrib repositories, including updates and security patches
RUN echo "deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware" > /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
    && echo "deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware" >> /etc/apt/sources.list \
    && apt-get update && apt-get install -y unrar && rm -rf /var/lib/apt/lists/*

# Copy the script to the container
COPY extract.sh /extract.sh

# Ensure the script is executable
RUN chmod +x /extract.sh

# Use CMD to run your script
CMD ["/bin/bash", "-c", "/extract.sh && tail -f /dev/null"]
