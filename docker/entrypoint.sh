#!/bin/bash
set -e

# ---------- Config ----------
MODEL_PATH="/models/model.gguf"
SYSTEM_PROMPT=""
USER_PROMPT=""
HIDE_THOUGHTS=false
HIDE_INPUT_STATS=false

show_help() {
  echo "Usage: $0 [options] [USER_PROMPT]"
  echo ""
  echo "Options:"
  echo "  --sys <prompt>     Set the system prompt."
  echo "  --hide-thoughts    Hide thought process in output."
  echo "  --hide-input-stats Prevent printing of input word count"
  echo "  --help             Display this help message."
  echo ""
  echo "USER_PROMPT can be provided as an argument or via STDIN."
  echo "Use \"/no_think\" in the system prompt or user prompt to disable thinking mode."
}

# ---------- Argument Parsing ----------
while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      show_help
      exit 0
      ;; 
    --sys)
      SYSTEM_PROMPT="$2"
      shift 2
      ;; 
    --hide-thoughts)
      HIDE_THOUGHTS=true
      shift
      ;; 
    --hide-input-stats)
      HIDE_INPUT_STATS=true
      shift
      ;; 
    *)
      USER_PROMPT="$1"
      shift
      ;; 
  esac
done

# ---------- STDIN Detection and Read ----------
if [[ -z "$USER_PROMPT" && ! -t 0 ]]; then
  USER_PROMPT=$(cat)
fi

# ---------- Final Validation ----------
if [[ -z "$USER_PROMPT" ]]; then
  echo "Error: USER_PROMPT is required. Provide as argument or via STDIN."
  exit 1
fi

if ! $HIDE_INPUT_STATS; then
  INPUT_WORD_COUNT=$(echo "${USER_PROMPT}" | wc -w)
  echo "Input Words: $INPUT_WORD_COUNT" >&2
fi

# Use default system prompt if not provided
if [[ -z "$SYSTEM_PROMPT" ]]; then
  SYSTEM_PROMPT="You are a helpful assistant."
fi

# ---------- Build llama-cli command ----------
CMD=(./llama-cli -m "$MODEL_PATH")
CMD+=(
  -sys "$SYSTEM_PROMPT"
  --single-turn
  --dry-multiplier 0.8
  --dry-base 1.75
  --dry-allowed-length 2
  --dry-penalty-last-n -1
  --dry-sequence-breaker "—"
  --dry-sequence-breaker "##"
  --flash-attn auto
  --temp 0.6
  --top-k 20
  --top-p 0.95
  --min-p 0
  --predict 32768
  --no-context-shift
  --no-display-prompt
  -p "$USER_PROMPT"
)

# ---------- Streaming Output Filter ----------
if $HIDE_THOUGHTS; then
#  "${CMD[@]}" 2>/dev/null | bash /end-of-text-filter.sh | bash /think-filter.sh
  "${CMD[@]}" 2>/dev/null | python3 /end-of-text-filter.py | python3 /think-filter.py
else
#  "${CMD[@]}" 2>/dev/null | bash /end-of-text-filter.sh
  "${CMD[@]}" 2>/dev/null | python3 /end-of-text-filter.py
fi