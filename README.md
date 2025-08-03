# LLM-Guided Laptop Build Experiment

## Project Evolution: New Approach

### Why didn't this work with Gentoo?

As it turns out, Claude Code is not great with long-running tasks. I had chosen Gentoo because of its flexibility and fine-grained control. The finest-grained control in Gentoo is to build as much as possible from source and have highly-customized USE flags and other parameters all over the place.
Compiling from source takes time; some packages, a _lot_ of time. A good example is `llvm-core/llvm` which takes well over 30 minutes to compile.
Another option is to integrate some binary packages in the mix, but then some amount of control is lost, unless the exact combination of USE flags I want is replicated in the binary package and its dependencies.
Claude code timed out after some period of time having no input control. It doesn't time out gracefully, really; it crashes.
I have not tried this with either Gemini CLI or OpenAI Codex. My (admittedly lighter than with Claude Code) experience with those tools is underwhelming.
My weird brain did what it often does, though, and went overboard on "boil the ocean" size project ideas. I'm going to build a customized user experience on my laptop that is optimized for the sets of tasks that I have for it. I will make most of my choices - including the choice of operating system (no Windows, no hackintosh) and window/desktop environment - through a process of consensus developed across several outputs from various large language models.
Something of a visualization: (Project description -> LLM -> output) * several LLM's -> analyze/evaluate these using an agent orchestrator like Claude Code, Gemini CLI, or OpenAI Codex. I might even run it through all three.

### Evolution Generation 2 Approach

Define the overall system requirements and have each LLM create a plan to accomplish the goal of building the system. Use one of the agentic LLM orchestration tools to synthesize the "best of" from these. The way this is worded in Gen 1 CLAUDE.md is great. Execute on the plan, probably using a combination of manual and automated. Try to drive fully automated, intervening and overriding when that produces a better outcome.
For the web-based LLM's that accept a system prompt to set up the persona/expertise/context, provide that separately. Use the existing one.

- [ ] Write the system requirements
  - Adapt existing document
  - Provide target system specifications
- [ ] Compile a list of LLM's to use
  - Probably the same 20+ used for Gen 1 of this project
- [ ] Feed the bots, saving and labeling output
- [ ] Generate larger project instructions (CLAUDE.md etc)
  - Use a web-based LLM client to assist. Use Claude web to generate Claude Code instructions, use Gemini to generate Gemini CLI instructions, use ChatGPT to generate OpenAI Codex instructions
  - It is this document that is to be deployed to the target system with the system specifications document and possibly the Linux expert system prompt text; the LLM response text does not get deployed to the target system.
- [ ] Iterate through the plan; drive automated, stepping out to manually intervene when necessary, redirect and guide the LLM as appropriate.

## 2025-08-01

I'm discovering that Claude Code struggles with long-running tasks. Anybody who's worked with Gentoo realizes that there are a lot of these. I'm rethinking the approach here, and whether I want to use Gentoo and build lots of things from source, use binaries, or just a different distribution.

## 2025-07-26

I'm back at it! I'm doing some quick crash-course/cram-study type learning about RAG, agents, tool use, prompting techniques, and some specifics for each of the tools I'm using here.  

My approach has not changed, except that instead of my executing the synthesized task list, I'm going to hand it off to the agent orchestrator directly. That means Claude Code in this initial version.  

Random thought: I might turn this into a little bit of a test of capabilities of the various tools. Can it build and install a Gentoo system on the testing (`ACCEPT_KEYWORDS="~x86"`) branch?  

## Update 2025-07-23

This devolved into a morass of crazy flags and dependencies and silly tweaks and... well, it's a mess. It's likely that the way I approached this - with me being the "human in the loop" and evaluating everything the AI generated and running each command myself.  

I'm going to table this for now. My next adventure - soon, within the next few days - will be to hand the reins over to the tool and set it free without human intervention.

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

## Process Journal

I thought to keep notes about this experience only a while after having been through several iterations.  

My biggest takeaway so far is that the ReAct sort of reason/do/analyze/re-reason/retry-do/re-analyze is a very slow process naturally. This is probably amplified by the nature of the project I've given the tools - the "do" involves compiling a shitload of software, after all - but iteration is repetitive and tedious.  

The second takeaway, just as important, is that I am the bottleneck in this process. Because I was reluctant to Leeroy Jenkins this thing and wanted to verify input/output at each step, it's been a lot slower. I have changed nothing from the model's recommendations at any point.  

At around the seventh or eighth iteration - at the point in the development tools install script (`phase2`) that installs `pipx` - the model rectified an issue by adding a `~amd64` testing flag to the `pipx` package, which is in the `USE` flag setup in the first script. That change required going all the way back to `phase1` again. This time, however, I am running the script itself in toto, since I've iterated through the whole thing manually already. At least it didn't take long.