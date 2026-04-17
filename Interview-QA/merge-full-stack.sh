#!/usr/bin/env bash
# 在 Interview-QA 目录下执行：./merge-full-stack.sh
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
OUT="Full-Stack-Interview-QA.md"
{
  printf '%s\n' '# 全栈高频面试题与答案' '' '> 基于仓库根目录 `README.md` 技术栈整理：Vue3、TypeScript、React、Next.js、React Native + Expo、Flutter、Web3、AI/LLM、Node/NestJS、工程化与 WebSocket。' '' '## 目录' '' '- [一、Vue3](#一vue3)' '- [二、TypeScript](#二typescript)' '- [三、React](#三react)' '- [四、Next.js](#四nextjs)' '- [五、React Native + Expo](#五react-native--expo)' '- [六、Flutter / Dart](#六flutter--dart)' '- [七、Web3 / 区块链](#七web3--区块链)' '- [八、AI / LLM 应用](#八ai--llm-应用)' '- [九、Node.js / NestJS](#九nodejs--nestjs)' '- [十、工程化 / Monorepo / 性能](#十工程化--monorepo--性能)' '- [十一、WebSocket / 实时通信](#十一websocket--实时通信)' '' '---' '' 
  cat Interview-QA-Part1-Vue3.md
  printf '\n'
  cat Interview-QA-Part2-TypeScript-React-Next.md
  printf '\n'
  cat Interview-QA-Part3-Mobile-Web3-AI-Infra.md
} > "$OUT"
echo "Wrote $OUT ($(wc -l < "$OUT") lines)"
