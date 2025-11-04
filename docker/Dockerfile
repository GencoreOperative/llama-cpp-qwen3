# ---------------------------
# Stage 1: Build llama.cpp
# ---------------------------
FROM ubuntu:22.04 AS build-cli

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    git \
    cmake \
    build-essential \
    libcurl4-openssl-dev \
    && apt-get clean

WORKDIR /opt
RUN git clone https://github.com/ggml-org/llama.cpp.git
WORKDIR /opt/llama.cpp
RUN cmake -DLLAMA_LOG_DISABLE=ON -B build
RUN cmake --build build --config Release -j $(nproc)

# ---------------------------
# Stage 2: Download Model
# ---------------------------
FROM ubuntu:22.04 AS fetch-model

ENV DEBIAN_FRONTEND=noninteractive

# Build args
ARG MODEL_NAME=Qwen/Qwen3-0.6B-GGUF
ARG MODEL_FILE=Qwen3-0.6B-Q8_0.gguf

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    && apt-get clean

RUN pip install --no-cache-dir huggingface_hub

WORKDIR /models

RUN hf download ${MODEL_NAME} ${MODEL_FILE} --local-dir . \
 && cp ${MODEL_FILE} model.gguf

# ---------------------------
# Stage 3: Run the model
# ---------------------------
FROM ubuntu:22.04 AS runtime

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libcurl4-openssl-dev \
    libgomp1 \
    && apt-get clean

# Copy runtime binary + model
COPY --from=build-cli /opt/llama.cpp/build/bin /opt/llama.cpp/build/bin
COPY --from=fetch-model /models/model.gguf /models/model.gguf

RUN apt-get update && apt-get install -y \
    python3 \
    && apt-get clean

# Copy entrypoint script and prompt file
COPY docker/entrypoint.sh /
COPY docker/think-filter.py /
COPY docker/end-of-text-filter.py /
RUN chmod +x /entrypoint.sh

WORKDIR /opt/llama.cpp/build/bin

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]