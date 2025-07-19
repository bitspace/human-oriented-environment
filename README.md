# Gentoo Laptops

## Abstract

This documents the process and approach to installing Gentoo Linux on my laptops. This project doubles as an experiment with agentic AI and LLM's.  

## Approach

- Install base Gentoo system following [the Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64). Base system uses desktop/systemd stage3.
- Write a [prompt](initial-llm-prompt.md) to compel LLM's to design a plan for building a system that suits my needs.
- Input this prompt to several models and collect their responses.
- Leverage agent wrangler (Claude Code) to synthesize the responses from the other models to create a detailed plan
- Iterate and execute

## Ideas for the future

- This proof of concept was implemented with Claude Code. Give other similar tools, such as Gemini CLI and OpenAI Codex, the same challenge.
- Apply the refined process to another laptop (I've got a few). Install an agent wrangler on a base system and have it implement the plan directly
- Give Claude Code its own computer! Inspired by a video clip on X in which somebody gave a Mac Mini to Claude Code.
- Because I have more than one spare computer, do it on two computers and devise some sort of game in which they attempt to compromise the other. Bonus: if the other agent wranglers work nearly as well as Claude Code, pit them against each other.
  - alternatively, instead of compromise, maybe play a game.
