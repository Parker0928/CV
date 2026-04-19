#!/usr/bin/env bash
# 在 Interview-QA 目录下执行：./merge-full-stack.sh
# Vue 与 React 分文件编排，便于分开背诵；合并时按章节顺序拼接。
set -euo pipefail
DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"
OUT="Full-Stack-Interview-QA.md"
{
  printf '%s\n' '# 全栈高频面试题与答案' '' '> 基于仓库根目录 `README.md` 技术栈整理：Vue3、React、TypeScript、Next.js、React Native + Expo、Flutter、Web3、AI/LLM、Node/NestJS、工程化与 WebSocket。（Vue / React 分章、不对照混排，便于分块记忆。）' '' '## 目录' '' '- [一、Vue3](#一vue3)' '- [二、React](#二react)' '- [三、TypeScript](#三typescript)' '- [四、Next.js](#四nextjs)' '- [五、React Native + Expo](#五react-native--expo)' '- [六、Flutter / Dart](#六flutter--dart)' '- [七、Web3 / 区块链](#七web3--区块链)' '- [八、AI / LLM 应用](#八ai--llm-应用)' '- [九、Node.js / NestJS](#九nodejs--nestjs)' '- [十、工程化 / Monorepo / 性能](#十工程化--monorepo--性能)' '- [十一、WebSocket / 实时通信](#十一websocket--实时通信)' '' '---' '' 
  cat Interview-QA-Part1-Vue3.md
  printf '\n'
  cat Interview-QA-Part2-React.md
  printf '\n'
  cat Interview-QA-Part3-TypeScript-Next.md
  printf '\n'
  cat Interview-QA-Part4-Mobile-Web3-AI-Infra.md
} > "$OUT"
echo "Wrote $OUT ($(wc -l < "$OUT") lines)"
