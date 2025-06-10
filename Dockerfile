FROM python:3.9-slim

# Install system dependencies including libssl and libcurl
RUN apt-get update && apt-get install -y \
    gcc \
    libssl-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

# Add debug tools
RUN pip install --no-cache-dir watchdog

# Run as non-root user
RUN useradd -m streamlituser && chown -R streamlituser:streamlituser /app
USER streamlituser

EXPOSE 8080

# Health check with curl
HEALTHCHECK --interval=30s --timeout=30s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/_stcore/health || exit 1

# Add debugging entrypoint
CMD ["sh", "-c", "echo 'Starting Streamlit...' && streamlit run dashboard.py --server.port=8080 --server.address=0.0.0.0 --server.headless=true 2>&1"]