# 面试题资料（Markdown）

本目录集中存放与简历技术栈相关的面试题与答案，便于版本管理与检索。

## 推荐阅读顺序

拆为 **Part1～Part4** 四个分片：**Vue** 与 **React 各自独立文件**，按知识点成章、不穿插对照，方便分开背诵。合并总览见 **`Full-Stack-Interview-QA.md`**（由脚本生成，勿手改）。

| 文件 | 说明 |
|------|------|
| **Interview-QA-Part1-Vue3.md** | **一、Vue3**（仅 Vue，整章自洽） |
| **Interview-QA-Part2-React.md** | **二、React**（仅 React，整章自洽） |
| **Interview-QA-Part3-TypeScript-Next.md** | **三、TypeScript**；**四、Next.js** |
| **Interview-QA-Part4-Mobile-Web3-AI-Infra.md** | **五～十一**：移动端、Web3、AI、NestJS、工程化、WebSocket |
| **Full-Stack-Interview-QA.md** | 合并版（通读、导出 PDF 等用） |
| **merge-full-stack.sh** | 在本目录执行 `./merge-full-stack.sh` 从 Part1～4 重新生成合并文件 |

### 以往资料（另一处归档）

较早整理的面试笔记在子目录 **`legacy/`**（见其中 `README.md`）。

## 覆盖度核对（vs 根目录 `README.md` 技能表）

| 章节 | 题量 | 简历对应 |
|------|------|----------|
| 一、Vue3 | 17 | Vue2·3 / Vue3 核心 |
| 二、React | 16 | React；内含 RTK / Zustand 等 |
| 三、TypeScript | 16 | TypeScript |
| 四、Next.js | 15 | Next.js（App Router / RSC） |
| 五、React Native + Expo | 15 | RN、Expo、EAS、Hermes 等 |
| 六、Flutter / Dart | 16 | Flutter、Dart、钱包相关 |
| 七、Web3 / 区块链 | 16 | Ethers、Viem、Wagmi、Privy 等 |
| 八、AI / LLM | 15 | RAG、SSE、Prompt、LangChain 等 |
| 九、Node.js / NestJS | 15 | Node、Nest；GraphQL 有涉及 |
| 十、工程化 / Monorepo / 性能 | 16 | pnpm、Turborepo、Vite、Docker、GitHub Actions 等 |
| 十一、WebSocket | 15 | WebSocket、实时行情 |

**简历中有、成套文档里未单独成章或偏少的点：** ES6/HTML/CSS、Bootstrap、Vue2 专章、Webpack/Rollup/Vitest 深度、Nx、MySQL/PostgreSQL、Express/Koa 专章、Vercel AI SDK、Web3.js 专章、Keplr/Trust 钱包细项等（详见此前说明，需要时可补 Part）。

## 维护说明

- 日常只改 **Part1～Part4**；改完后执行 **`./merge-full-stack.sh`** 再生成 **Full-Stack-Interview-QA.md**。
- 根目录 **`README.md`** 仍为个人简历主文件，未移动。
