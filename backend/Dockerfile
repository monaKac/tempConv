# ---------- build stage ----------
FROM golang:1.24-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
# Static binary, no CGO — keeps the final image tiny.
# RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o /tempconv-server .  # uncomment for GKE deployment
ARG TARGETARCH
RUN CGO_ENABLED=0 go build -o /tempconv-server .

# ---------- runtime stage ----------
FROM alpine:3.21
RUN apk add --no-cache ca-certificates
COPY --from=builder /tempconv-server /tempconv-server
EXPOSE 50051
ENTRYPOINT ["/tempconv-server"]
