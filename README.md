# URL Shortener ECS

A URL shortener service deployed on AWS ECS with blue/green deployments, WAF protection, and automated CI/CD.

## Quick Start

### Base URL
```
https://url.shortener.tomakady.com
```

### Shorten a URL

```bash
curl -X POST https://url.shortener.tomakady.com/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://www.youtube.com/watch?v=5PApp6ksmiw"}'
```

**Response:**
```json
{
  "short": "a1b2c3d4",
  "url": "https://www.youtube.com/watch?v=5PApp6ksmiw"
}
```

### Use the Short URL

Visit in browser or use curl:
```
https://url.shortener.tomakady.com/a1b2c3d4
```

This redirects to the original URL.

### Health Check

```bash
curl https://url.shortener.tomakady.com/healthz
```

## API Endpoints

- `POST /shorten` - Create a short URL
  - Body: `{"url": "https://example.com"}`
  - Returns: `{"short": "code", "url": "original"}`

- `GET /{short_id}` - Redirect to original URL
  - Returns: HTTP 302 redirect

- `GET /healthz` - Health check
  - Returns: `{"status": "ok", "ts": timestamp, "version": "1.0"}`

## Example

```bash
# Shorten a URL
curl -X POST https://url.shortener.tomakady.com/shorten \
  -H "Content-Type: application/json" \
  -d '{"url": "https://github.com"}'

# Use the returned short code
# Visit: https://url.shortener.tomakady.com/{short_code}
```
