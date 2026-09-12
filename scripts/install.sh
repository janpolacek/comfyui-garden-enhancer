#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd -- "$SCRIPT_DIR/.." && pwd)
COMFY_ROOT=${COMFY_ROOT:-$REPO_ROOT/../ComfyUI}
PLUGIN_COMMIT=86f886dac23013d88996e3a2e99093ba44d322fb
PLUGIN_SHA256=de43b5529a916a3bdca0bcebe9420a314f2ee0f8c55603a5c419fdd62be57a17
PLUGIN_DIR="$COMFY_ROOT/custom_nodes/comfyui-krea2edit"
INSTALL_TMP=$(mktemp -d)

cleanup() {
  rm -rf -- "$INSTALL_TMP"
}
trap cleanup EXIT

for command_name in curl sha256sum tar; do
  command -v "$command_name" >/dev/null || {
    printf 'Missing required command: %s\n' "$command_name" >&2
    exit 1
  }
done

if [[ ! -d "$COMFY_ROOT" ]]; then
  printf 'ComfyUI directory not found: %s\n' "$COMFY_ROOT" >&2
  exit 1
fi

download_verified() {
  local url=$1
  local destination=$2
  local expected_sha256=$3
  local partial="${destination}.part"

  mkdir -p -- "$(dirname -- "$destination")"

  if [[ -f "$destination" ]] && printf '%s  %s\n' "$expected_sha256" "$destination" | sha256sum --check --status; then
    printf 'Already verified: %s\n' "$destination"
    return
  fi

  curl --fail --location --retry 5 --retry-delay 5 --continue-at - --output "$partial" "$url"
  printf '%s  %s\n' "$expected_sha256" "$partial" | sha256sum --check
  mv -- "$partial" "$destination"
}

install_plugin() {
  local archive="$INSTALL_TMP/comfyui-krea2edit.tar.gz"
  local extracted="$INSTALL_TMP/comfyui-krea2edit"

  if [[ -d "$PLUGIN_DIR" ]]; then
    printf 'Plugin directory already exists; leaving it unchanged: %s\n' "$PLUGIN_DIR"
    return
  fi

  download_verified \
    "https://github.com/lbouaraba/comfyui-krea2edit/archive/${PLUGIN_COMMIT}.tar.gz" \
    "$archive" \
    "$PLUGIN_SHA256"

  mkdir -p -- "$extracted"
  tar -xzf "$archive" --strip-components=1 -C "$extracted"
  mkdir -p -- "$(dirname -- "$PLUGIN_DIR")"
  mv -- "$extracted" "$PLUGIN_DIR"
  printf 'Installed Krea2Edit plugin commit %s\n' "$PLUGIN_COMMIT"
}

install_plugin

download_verified \
  'https://huggingface.co/Comfy-Org/Krea-2/resolve/main/diffusion_models/krea2_turbo_nvfp4.safetensors' \
  "$COMFY_ROOT/models/diffusion_models/krea2_turbo_nvfp4.safetensors" \
  '61527003b2d537055494d01bc8efe51d6e86e64192ba23e3721a5647231fe394'

download_verified \
  'https://huggingface.co/Comfy-Org/Krea-2/resolve/main/text_encoders/qwen3vl_4b_fp8_scaled.safetensors' \
  "$COMFY_ROOT/models/text_encoders/qwen3vl_4b_fp8_scaled.safetensors" \
  '54bd5144df0bbc25dd6ccadfcb826b521445a1b06ae5a42570bdd2974ca87094'

download_verified \
  'https://huggingface.co/Comfy-Org/Krea-2/resolve/main/vae/qwen_image_vae.safetensors' \
  "$COMFY_ROOT/models/vae/qwen_image_vae.safetensors" \
  'a70580f0213e67967ee9c95f05bb400e8fb08307e017a924bf3441223e023d1f'

download_verified \
  'https://huggingface.co/conradlocke/krea2-identity-edit/resolve/main/krea2_identity_edit_v1_2_r64.safetensors' \
  "$COMFY_ROOT/models/loras/krea2_identity_edit_v1_2_r64.safetensors" \
  'f794b47142555c929cf536a2f1e4f335174b9aedbb08572b07d45814d4242423'

mkdir -p -- "$COMFY_ROOT/user/default/workflows"
install -m 0644 \
  "$REPO_ROOT/workflows/garden-enhancement-1mp.json" \
  "$COMFY_ROOT/user/default/workflows/garden-enhancement-1mp.json"

printf '\nGarden enhancer installed. Restart ComfyUI, then open garden-enhancement-1mp.\n'
