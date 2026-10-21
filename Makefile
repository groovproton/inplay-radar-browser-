PYTHON ?= python3
PORT ?= 8000
HOST ?= 127.0.0.1
PID_FILE := .bws-server-$(PORT).pid
LOG_FILE := .bws-server-$(PORT).log

.PHONY: help serve start stop restart status

help:
	@printf '%s\n' \
	  'make serve               Run HTTP server in foreground (Ctrl+C to stop)' \
	  'make start               Start HTTP server in background' \
	  'make status              Check managed background server' \
	  'make stop                Stop managed background server' \
	  'make restart             Restart managed background server' \
	  'PORT=8080 make serve     Use a different port'

serve:
	$(PYTHON) -m http.server $(PORT) --bind $(HOST)

start:
	@if [ -f "$(PID_FILE)" ] && kill -0 "$$(cat "$(PID_FILE)")" 2>/dev/null; then \
	  echo "BWS is already running (PID $$(cat "$(PID_FILE)"))"; \
	else \
	  rm -f "$(PID_FILE)"; \
	  $(PYTHON) -m http.server $(PORT) --bind $(HOST) > "$(LOG_FILE)" 2>&1 & \
	  pid=$$!; echo "$$pid" > "$(PID_FILE)"; \
	  sleep 1; \
	  if kill -0 "$$pid" 2>/dev/null; then \
	    echo "BWS running at http://$(HOST):$(PORT)/ (PID $$pid)"; \
	  else \
	    rm -f "$(PID_FILE)"; \
	    echo "Could not start BWS; see $(LOG_FILE)"; \
	    exit 1; \
	  fi; \
	fi

stop:
	@if [ -f "$(PID_FILE)" ]; then \
	  pid=$$(cat "$(PID_FILE)"); \
	  if kill -0 "$$pid" 2>/dev/null; then \
	    kill "$$pid" && echo "Stopped BWS (PID $$pid)"; \
	  else \
	    echo "BWS is not running (stale PID file)"; \
	  fi; \
	  rm -f "$(PID_FILE)"; \
	else \
	  echo "No managed BWS server found"; \
	fi

restart: stop start

status:
	@if [ -f "$(PID_FILE)" ] && kill -0 "$$(cat "$(PID_FILE)")" 2>/dev/null; then \
	  echo "BWS running at http://$(HOST):$(PORT)/ (PID $$(cat "$(PID_FILE)"))"; \
	else \
	  echo "BWS is not running under Makefile management"; \
	fi
