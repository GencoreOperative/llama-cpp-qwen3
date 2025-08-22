#!/bin/bash

# A simple streaming filter that looks for the <think></think> signal
# that will appear on its own line in the output.

in_think=0

while IFS= read -r line; do
  if [[ "$line" == *"<think>"* ]]; then
    in_think=1
    continue
  fi

  if [[ "$line" == *"</think>"* ]]; then
    in_think=0
    continue
  fi

  if [[ $in_think -eq 0 ]]; then
    echo "$line"
  fi
done
