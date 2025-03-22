FROM --platform=linux/arm/v7 python:3.13-alpine AS python
RUN echo "Building for linux/arm/v7"

FROM --platform=linux/arm/v5 python:3.13-alpine AS python
RUN echo "Building for linux/arm/v5"

FROM --platform=linux/arm64/v8 python:3.13-alpine AS python
RUN echo "Building for linux/arm64/v8"

FROM --platform=linux/amd64 python:3.13-alpine AS python
RUN echo "Building for linux/amd64"

FROM --platform=linux/386 python:3.13-alpine AS python
RUN echo "Building for linux/386"

FROM --platform=linux/arm/v6 arm32v6/python:3.13-alpine AS python
RUN echo "Building for linux/arm/v6"

FROM python AS builder
RUN apk --no-cache add curl

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh

# Run the installer then remove it
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Ensure the installed binary is on the `PATH`
ENV PATH="/root/.local/bin/:$PATH"

ENV UV_COMPILE_BYTECODE=1 UV_LINK_MODE=copy

# Disable Python downloads, because we want to use the system interpreter across both images.
ENV UV_PYTHON_DOWNLOADS=0

WORKDIR /app
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev
ADD . /app
RUN --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev


# Then, use a final image without uv
FROM python
# It is important to use the image that matches the builder, as the path to the
# Python executable must be the same, e.g., using `python:3.11-slim-bookworm`
# will fail.

# Copy the application from the builder
COPY --from=builder --chown=app:app /app /app

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Run app. (defined in pyproject.toml)
CMD ["app"]
