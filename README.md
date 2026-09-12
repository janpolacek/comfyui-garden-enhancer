# ComfyUI Garden Enhancer

A source-preserving, two-image garden design workflow for local ComfyUI:

1. Load a photo of the existing garden.
2. Load a second garden or flower-bed photo as weak inspiration.
3. Describe the planting changes.
4. Generate an approximately 1-megapixel concept image that retains the source viewpoint and layout.

The workflow uses the original garden as an encoded edit reference rather than merely borrowing its visual style. The inspiration image has a deliberately weaker influence.

## Tested setup

- Windows 11 with Ubuntu 24.04 under WSL2
- NVIDIA RTX 5060
- 32 GB system RAM
- ComfyUI accessed from another computer on the local network
- Output follows the source aspect ratio; the tested portrait output was 832 × 1248
- Typical tested runtime: about 3 minutes

## Install

Start with a working ComfyUI checkout and NVIDIA CUDA support. Clone this repository inside WSL, then run:

```bash
COMFY_ROOT=/path/to/ComfyUI bash scripts/install.sh
```

The installer downloads approximately 14 GB of model data, verifies every model checksum, installs the pinned Krea2Edit node pack, and copies the UI workflow into `user/default/workflows/`.

Restart ComfyUI after installation. No model weights are stored in this repository.

## Use

Open `garden-enhancement-1mp` in ComfyUI, then:

1. In **SOURCE GARDEN**, upload the garden that must be preserved.
2. In **INSPIRATION**, upload the garden or flower bed whose planting language you like.
3. Edit the plain-English instruction in **Krea2EditGroundedEncode**.
4. Queue the workflow.

The output automatically follows the source image's orientation and is scaled to approximately 1 MP.

### Fidelity controls

The `Krea2EditModelPatch` node exposes two important values:

- `ref_boost = 0.75`: inspiration influence
- `ref_boost_a = 4.0`: source-garden fidelity

If the original layout drifts, lower inspiration to `0.3–0.5` or raise source fidelity to `5–6`. Excessively high source fidelity can prevent visible improvements.

The default prompt preserves the camera viewpoint, house, windows, fences, mature trees, lawn boundaries, paths, levels, perspective, lighting direction, and hardscape. It also rejects grain, stippling, painterly texture, haze, and pointillism.

## Files

- `workflows/garden-enhancement-1mp.json` — workflow for the ComfyUI interface
- `workflows/garden-enhancement-1mp-api.json` — equivalent API-format workflow with placeholder image names
- `scripts/install.sh` — pinned, checksum-verified WSL/Linux installer

For API use, place `source-garden.png` and `inspiration-garden.png` in ComfyUI's `input/` directory or update nodes `5` and `6` in the API JSON.

## LAN note

Running ComfyUI with `--listen 0.0.0.0` makes it reachable by other devices on the LAN. ComfyUI does not provide authentication by default, so expose it only on a trusted network and restrict port 8188 with the host firewall.

## Credits and licenses

This workflow is adapted from the Apache-2.0 licensed [ComfyUI-Krea2Edit](https://github.com/lbouaraba/comfyui-krea2edit) example workflow. The node pack provides the source-image latent path, image-grounded Qwen3-VL encoding, FIT geometry, and reference-fidelity controls.

The Krea 2 model and Krea2 Identity Edit LoRA are separate downloads governed by the Krea 2 Community License. Review their model cards and license terms before use or redistribution:

- [Comfy-Org/Krea-2](https://huggingface.co/Comfy-Org/Krea-2)
- [conradlocke/krea2-identity-edit](https://huggingface.co/conradlocke/krea2-identity-edit)

Repository code and workflow modifications are provided under Apache License 2.0. See `LICENSE` and `ATTRIBUTION.md`.
