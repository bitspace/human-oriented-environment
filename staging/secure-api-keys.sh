#!/bin/bash
# Secure API Key Management via 1Password
# Replace hardcoded keys with secure 1Password references

export OPENAI_API_KEY=$(op read "op://Employee/OpenAI API Key/credential" 2>/dev/null)
export ANTHROPIC_API_KEY=$(op read "op://Employee/Anthropic API Key/credential" 2>/dev/null)
export GEMINI_API_KEY=$(op read "op://Employee/Google API Key/credential" 2>/dev/null)
export GOOGLE_API_KEY=$(op read "op://Employee/Google API Key/credential" 2>/dev/null)
export SERPER_API_KEY=$(op read "op://Employee/Serper API Key/credential" 2>/dev/null)
export TOGETHER_API_KEY=$(op read "op://Employee/TogetherAI API Key/credential" 2>/dev/null)
export FIREWORKS_API_KEY=$(op read "op://Employee/Fireworks AI API Key/credential" 2>/dev/null)
export PROMPTLAYER_API_KEY=$(op read "op://Employee/PromptLayer API Key/credential" 2>/dev/null)
export COHERE_API_KEY=$(op read "op://Employee/Cohere AI API Key/credential" 2>/dev/null)
export PERPLEXITY_API_KEY=$(op read "op://Employee/Perplexity API Key/credential" 2>/dev/null)
export MISTRAL_API_KEY=$(op read "op://Employee/Mistral API Key/credential" 2>/dev/null)
export GROQ_API_KEY=$(op read "op://Employee/Groq API Key/credential" 2>/dev/null)
export WEATHER_API_KEY=$(op read "op://Employee/OpenWeatherMap/credential" 2>/dev/null)
export SERPAPI_API_KEY=$(op read "op://Employee/SerpAPI API Key/credential" 2>/dev/null)

# Silent fallback - if 1Password is unavailable, commands will get empty values
# This prevents errors while maintaining security