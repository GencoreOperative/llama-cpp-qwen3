# Overview

This project provides a Dockerized environment for running the Qwen3 language model. This model was
released with a range of model sizes. This particular project is interested in running this model
on the command line as part of natrual language processing tasks. The smallest models are packaged
to provide options for the user.

0.6B is the smallest and shows a surprising amount of capability for its small <1GB size. The 
1.7B model is the next size up and appears to be able to handle moderate text processing abilities.

## Key Features

*   **Multiple Model Sizes:** Supports the two smallest model sizes for the Qwen3 series; 0.6B and 1.7B.
*   **Custom System Prompts:** Easily set a custom system prompt to guide the model's behavior.
*   **Toggle Thought Process:** Choose to show or hide the model's thought process in the output.
*   **Input Statistics:** View the word count of your input prompt.
*   **Flexible Input:** Provide user prompts as command-line arguments or via STDIN.

## Building the Image

To build the Docker images for the available models, use the following Make commands:

*   **Build the 0.6B parameter model:**
    ```bash
    make build_0_6
    ```

*   **Build the 1.7B parameter model:**
    ```bash
    make build_1_7
    ```

*   **Build all models:**
    ```bash
    make build
    ```

## Running the Image

To run the Docker image, use the `make run` command. You can specify the model version by setting the `tag` variable. For example, to run the 1.7B model:

```bash
make run tag=1.7B
```

By default, the `run` command will use the `0.6B` tag.

## Usage

You can interact with the model using various command-line options passed to the `docker run` command after the image name:

```
Usage: docker run --rm -i gencore/llama-cpp-qwen3:<tag> [options] [USER_PROMPT]

Options:
  --sys <prompt>        Set the system prompt.
  --hide-thoughts       Hide thought process in output.
  --hide-input-stats    Prevent printing of input word count.
  --help                Display this help message.
```

You can provide the `USER_PROMPT` as a command-line argument or pipe it to the container via STDIN.

**Example:**

```bash
# Using a command-line argument
docker run --rm -i gencore/llama-cpp-qwen3:0.6B "Hello, world!"

# Using STDIN
echo "Hello, world!" | docker run --rm -i gencore/llama-cpp-qwen3:0.6B
```