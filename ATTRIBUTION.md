# Attribution

The garden workflow was adapted from `workflows/krea2_identity_edit.json` in [lbouaraba/comfyui-krea2edit](https://github.com/lbouaraba/comfyui-krea2edit), pinned during development at commit `86f886dac23013d88996e3a2e99093ba44d322fb`.

ComfyUI-Krea2Edit is licensed under Apache License 2.0. Its Krea2 Identity Edit weights are distributed separately under the Krea 2 Community License and are not included in this repository.

The adapted workflow adds:

- garden-specific source-preservation instructions;
- a weak secondary planting-inspiration input;
- automatic approximately 1 MP scaling while retaining source aspect ratio;
- low-VRAM RTX 5060 defaults;
- explicit anti-grain guidance; and
- a reproducible checksum-verified installer.
