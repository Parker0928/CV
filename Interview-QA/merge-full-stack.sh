#!/usr/bin/env bash
# 在 Interview-QA 目录下执行：./merge-full-stack.sh
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
OUT="Full-Stack-Interview-QA.md"
{
  printf '%s\n' '# 全栈高频面试题与答案' '' '> 基于仓库根目录 `README.md` 技术栈整理：Vue / React 对照、Vue3、React、TypeScript、Next.js、React Native + Expo、Flutter、Web3、AI/LLM、Node/NestJS、工程化与 WebSocket。' '' '## 目录' '' '- [一、Vue 与 React：对照与选型](#一vue-与-react对照与选型)' '- [二、Vue3](#二vue3)' '- [三、React](#三react)' '- [四、TypeScript](#四typescript)' '- [五、Next.js](#五nextjs)' '- [六、React Native + Expo](#六react-native--expo)' '- [七、Flutter / Dart](#七flutter--dart)' '- [八、Web3 / 区块链](#八web3--区块链)' '- [九、AI / LLM 应用](#九ai--llm-应用)' '- [十、Node.js / NestJS](#十nodejs--nestjs)' '- [十一、工程化 / Monorepo / 性能](#十一工程化--monorepo--性能)' '- [十二、WebSocket / 实时通信](#十二websocket--实时通信)' '' '---' '' 
  cat Interview-QA-Part1-Vue-React.md
  printf '\n'
  cat Interview-QA-Part2-TypeScript-React-Next.md
  printf '\n'
  cat Interview-QA-Part3-Mobile-Web3-AI-Infra.md
} > "$OUT"
echo "Wrote $OUT ($(wc -l < "$OUT") lines)"
