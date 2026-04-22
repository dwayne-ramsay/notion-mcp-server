# syntax=docker/dockerfile:1

FROM node:20-slim AS builder

WORKDIR /app
COPY package*.json ./

# Include devDependencies — TypeScript is needed for the build step
RUN npm ci --ignore-scripts

COPY . .
RUN npm run build
RUN npm link

FROM node:20-slim

COPY scripts/notion-openapi.json /usr/local/scripts/
COPY --from=builder /usr/local/lib/node_modules/@notionhq/notion-mcp-server \
     /usr/local/lib/node_modules/@notionhq/notion-mcp-server
COPY --from=builder /usr/local/bin/notion-mcp-server \
     /usr/local/bin/notion-mcp-server

ENV OPENAPI_MCP_HEADERS="{}"

# CMD (not ENTRYPOINT) so Railway can override; shell form expands $PORT
CMD notion-mcp-server --transport http --port ${PORT:-3000}
