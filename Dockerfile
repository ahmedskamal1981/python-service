# Use slim Python 3.11 (not Alpine because Alpine often breaks packages like PyMuPDF, Pillow, etc.)
FROM python:3.11-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Set workdir
WORKDIR /app

# Install OS dependencies for Tesseract, PyMuPDF, and image handling
RUN apt-get update && apt-get install -y \
    build-essential \
    tesseract-ocr \
    libglib2.0-0 \
    libgl1-mesa-glx \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# Copy only dependency files first for better caching
COPY pyproject.toml poetry.lock ./

# Install project dependencies
RUN poetry config virtualenvs.create false \
 && poetry install --only main

# Copy full app
COPY . .

# Expose port
EXPOSE 8000

# Start the app using hypercorn (entrypoint is src/index.py)
CMD ["hypercorn", "src.index:app", "--bind", "::"]
