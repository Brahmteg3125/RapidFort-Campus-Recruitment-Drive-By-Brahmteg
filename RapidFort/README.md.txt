# DOCX to PDF Converter Web Application

This web application allows users to upload a DOCX file, view its metadata, convert it to a password-protected PDF, and download the converted PDF.

## Features

- Upload DOCX files
- Display file metadata
- Convert DOCX to PDF
- Password-protect the PDF
- Simple UI
- Dockerized application
- CI pipeline with GitHub Actions
- Kubernetes manifests for deployment

## Requirements

- Docker
- Kubernetes (optional for deployment)
- Python 3.9+

## Setup Instructions

### Running with Docker

1. Build and run the Docker container:

   ```bash
   chmod +x run_container.sh
   ./run_container.sh
