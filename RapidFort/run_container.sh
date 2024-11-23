#!/bin/bash

docker build -t docx-to-pdf-converter .
docker run -d -p 5000:5000 --name docx-to-pdf-app docx-to-pdf-converter
echo "Application is running at http://localhost:5000"
