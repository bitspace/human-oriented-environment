# TODO

Remaining tasks, most QoL, for fully usable system

## Base CLI

- [ ] Incorporate items from traditional `.bashrc`
  - This will serve as a guide for other things to install like `starship`

## UI (Hyprland and friends)

- [ ] Fix fonts/glyphs

## Tools/Apps

- [ ] vscode-insiders
  - I need to learn more about the immutable/declarative system configuration approach and idiomatic nixisms first. Yay rabbit holes!
  - I had an incredibly interesting interaction with Claude Code while iterating through trying to install this in NixOS that ultimately ended up with the tool telling me that it had tried a bunch of things, here's why they didn't work, and you know, what you've already got installed is good enough for your needs. It was absolulely correct in describing the limitations of what I was asking for in the way I was asking for it, but the obvious judgement assessment was fascinating. I pointed it out and it apologized and offered to soldier on. i acquiesced a bit, since I was not challenging it at all, but fascinated by the judgement call. My acquiescence led to the previous point about needing to learn more about the NixOS ecosystem. I suggested a few things that I wanted to learn about (home manager, flakes) to the agent and it came up with an iterative plan for learning about the different approaches to custom software installation in NixOS. This shit is FUN.
