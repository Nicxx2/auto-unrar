## 💖 Support This Project

If you found this helpful and want to support what I do, you can leave a tip here — thank you so much!

[![Support on Ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/nicxx2)

---



<img src="https://github.com/Nicxx2/auto-unrar/blob/main/auto_unrar.png?raw=true" alt="Auto UnRAR" title="Auto UnRAR Script" width="500"/>



**Auto-UnRAR: Enhanced Archive Extraction Tool**  

Auto-UnRAR is a Dockerized utility crafted to streamline the extraction of RAR files across multiple environments seamlessly. Designed for both simplicity and efficiency, it automates the detection and extraction of RAR archives, operating quietly in the background. From media enthusiasts organizing vast libraries to professionals managing extensive data archives, Auto-UnRAR is the go-to solution for automating the archive extraction workflow.

**Key Features:**  
- Cross-Platform Compatibility: Runs effortlessly on a variety of systems, including Windows, Linux, and ARM-based devices such as Raspberry Pi 4 / Raspberry Pi 5.
- Flexible Archive Handling: Offers options to either preserve or delete original RAR files post-extraction, catering to diverse data management preferences.
- Configurable Automatic Scans: Performs scans at user-defined intervals, guaranteeing that new archives are extracted promptly with zero manual effort.
- Smart Non-Destructive Extraction: Employs an extraction strategy that prevents overwriting of existing files by default, preserving the integrity of your data. With configurable settings, users can opt to overwrite existing files if needed.
- Efficient Processing: Uses marker files to avoid reprocessing previously extracted archives, enhancing subsequent scans for speed and reduced resource consumption. This feature can be disabled for continuous extraction regardless of previous runs.
- Customizable Setup: Easily tailor the scan directory, extraction behaviour, and scan frequency via simple environment variables, making it adaptable to specific requirements.


**Getting Started:**  
To use Auto-UnRAR, simply pull the Docker image from Docker Hub and run it with Docker or Docker Compose.<br>
**Link:** https://hub.docker.com/r/nicxx2/auto-unrar

```yaml
version: '3.8'
services:
  auto-unrar:
    image: nicxx2/auto-unrar:latest
    volumes:
      - /path/to/your/data:/data
     # - /path/to/your/directory/to/add/extracted/data:/extract_to  # Optional: Specify a directory for extracted files
    environment:
      - SOURCE_DIRECTORY=/data
      - SLEEP_TIME=3600 # Default: Scan every hour
      # - OVERWRITE_FILES=false # Set to true to overwrite existing files during extraction
      # - DO_NOT_USE_MARKERS=false # Set to true to ignore markers and extract all archives
      # - EXTRACT_TO_DIRECTORY=/extract_to #Optional
      # - DELETE_RAR_AFTER_EXTRACTION=false # Set to true to delete RAR files post-extraction

```

**Note:** Replace **/path/to/your/data** with the path to the directory you want Auto-UnRAR to scan.
Also, remove "#" for any options that you want to use. If you don't use those options, then the default options set in the extraction script will be used.


**Customization Options:**
- **SOURCE_DIRECTORY:** Directory to scan for RAR files.
- **SLEEP_TIME:** Interval (in seconds) between scans. Default is 3600 seconds (1 hour).
- **OVERWRITE_FILES:** When true, extracted files will overwrite any existing files with the same name. Default is false
- **DO_NOT_USE_MARKERS:** If true, disables the use of marker files, leading to the extraction of all archives on each scan. Default is false
- **EXTRACT_TO_DIRECTORY:** Define a specific directory for extracted files by changing "/path/to/your/directory/to/add/extracted/data" under volume. If this option is not used, files are extracted to their respective archive locations.
- **DELETE_RAR_AFTER_EXTRACTION:** Set to true to remove RAR files after successful extraction. Default is false <be>

