# ---------- build stage ----------
# Use a Debian-based image so the Flutter SDK works smoothly.
FROM debian:bookworm-slim AS builder

# Install dependencies for Flutter web builds.
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter SDK.
ENV FLUTTER_HOME=/opt/flutter
RUN git clone --depth 1 --branch stable https://github.com/flutter/flutter.git $FLUTTER_HOME
ENV PATH="$FLUTTER_HOME/bin:$PATH"
RUN flutter precache --web && flutter doctor -v

WORKDIR /app
COPY . .
RUN flutter pub get && flutter build web --release

# ---------- runtime stage ----------
FROM nginx:1.27-alpine
# Copy the compiled web assets into nginx's default root.
COPY --from=builder /app/build/web /usr/share/nginx/html
EXPOSE 80
