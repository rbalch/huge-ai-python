# === Builder Stage ===
FROM python:3.13-slim AS base
# FROM nvidia/cuda:12.4.1-devel-ubuntu22.04 as base

# Install build tools and required system packages
RUN apt update -y && apt install --no-install-recommends -y \
    build-essential \
    git \
    vim \
    python3-dev \
    python3-pip \
    curl

WORKDIR /code

# Set environment variables for Python behavior and module discovery
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH="$PYTHONPATH:/code"

# Setup history for interactive sessions (ensuring it’s mappable with a volume)
RUN mkdir -p /root/history
ENV HISTFILE=/root/history/.bash_history
ENV PROMPT_COMMAND="history -a"

# Build the Huggingface cache directory
RUN mkdir -p /huggingface_cache
ENV HF_HOME="/huggingface_cache"

# --- Node.js (via NodeSource) ---
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get update && apt-get install -y nodejs \
    && npm install -g npm \
    && node -v && npm -v && npx --version

# Install Poetry inside the container
RUN curl -sSL https://install.python-poetry.org | python -
ENV PATH="/root/.local/bin:$PATH"

# Configure Poetry to install directly into system Python (no venv)
RUN poetry config virtualenvs.create false

# Copy project dependency descriptors
COPY pyproject.toml poetry.lock* ./

# Install dependencies using Poetry into the system environment
RUN poetry install --no-root --no-interaction --no-ansi --only main

# Install GeminiCLI
# TODO: this has a prompt for setup; need to sort that out
# RUN npx --yes https://github.com/google-gemini/gemini-cli

# === Runtime Stage ===
FROM python:3.13-slim AS runtime

WORKDIR /code

# Copy installed dependencies from the builder
COPY --from=base /usr/local/lib/python3.13/site-packages /usr/local/lib/python3.13/site-packages
COPY --from=base /usr/local/bin /usr/local/bin

# Reapply the environment variables for runtime and module resolution
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH="$PYTHONPATH:/code"

# Recreate history and Huggingface cache directories (so they can be mapped via Docker Compose)
RUN mkdir -p /root/history
ENV HISTFILE=/root/history/.bash_history
ENV PROMPT_COMMAND="history -a"

RUN mkdir -p /huggingface_cache
ENV HF_HOME="/huggingface_cache"

# Copy the rest of your application code
COPY . .

# Expose your service port
EXPOSE 8000

# Final command to run your app
CMD ["uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000"]
