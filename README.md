**Auto-UnRAR: Archive Extraction Tool**

Auto-UnRAR is a Dockerized tool designed to automate the extraction of RAR files across multiple platforms without the hassle. Built with simplicity and efficiency in mind, it periodically scans a designated directory for RAR archives and extracts them silently in the background. This tool is ideal for anyone looking to automate their archive extraction process, from hobbyists managing media libraries to professionals handling bulk data archives.



**Key Features:**

- Cross-Platform Compatibility: Works on various devices, including PCs (Windows, Linux) and ARM-based devices like Raspberry Pi 4 / Raspberry Pi 5.
- Preserves original RAR files: Ensures that RAR archives remain untouched and undeleted after the extraction process, retaining your original data for archival purposes or further use.
- Automatic Scans: Configurable to run at specified intervals, ensuring new archives are promptly extracted without manual intervention.
- Non-Destructive Extraction: Utilizes a smart extraction process that avoids overwriting existing files, ensuring your data remains intact. It leverages marker files to efficiently skip previously processed archives, making subsequent scans quicker and more resource-friendly.
- Easy Configuration: Customize the scan directory and frequency through simple environment variables, making it adaptable to your specific needs.


**Getting Started:**<br>
To use Auto-UnRAR, simply pull the Docker image from Docker Hub and run it with Docker or Docker Compose.
Link: https://hub.docker.com/r/nicxx2/auto-unrar


```yaml
version: '3.8'
services:
  auto-unrar:
    image: nicxx2/auto-unrar:latest
    volumes:
      - /path/to/your/data:/data
    environment:
      - SOURCE_DIRECTORY=/data
      - SLEEP_TIME=3600 # Scan every hour

```

**Note:** Replace **/path/to/your/data** with the path to the directory you want Auto-UnRAR to scan.


**Customization:**
- **path/to/your/data:** Set this to the directory you want to monitor for RAR files.
- **SLEEP_TIME:** Determine how frequently (in seconds) you want Auto-UnRAR to scan your directory. Default is 3600 seconds (1 hour).
