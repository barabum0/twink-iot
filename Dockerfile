FROM --platform=linux/arm/v7 python:3.13-alpine AS python
FROM --platform=linux/arm/v5 python:3.13-alpine AS python
FROM --platform=linux/arm64/v8 python:3.13-alpine AS python
FROM --platform=linux/amd64 python:3.13-alpine AS python
FROM --platform=linux/386 python:3.13-alpine AS python
FROM --platform=linux/arm/v6 arm32v6/python:3.13-alpine AS python

FROM python AS builder
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

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
FROM python:3.13-alpine
# It is important to use the image that matches the builder, as the path to the
# Python executable must be the same, e.g., using `python:3.11-slim-bookworm`
# will fail.

# Copy the application from the builder
COPY --from=builder --chown=app:app /app /app

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

# Run app. (defined in pyproject.toml)
CMD ["app"]
