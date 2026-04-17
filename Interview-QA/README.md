# 面试题资料（Markdown）

本目录集中存放与简历技术栈相关的面试题与答案，便于版本管理与检索。

## 推荐阅读顺序

拆分为 **Part1～Part3** 三段维护，结构一致；合并总览见 **`Full-Stack-Interview-QA.md`**（由脚本生成，勿手改）。

| 文件 | 说明 |
|------|------|
| **Interview-QA-Part1-Vue3.md** | 第一章：Vue3 |
| **Interview-QA-Part2-TypeScript-React-Next.md** | 第二～四章：TypeScript、React、Next.js |
| **Interview-QA-Part3-Mobile-Web3-AI-Infra.md** | 第五～十一章：移动端、Web3、AI、NestJS、工程化、WebSocket |
| **Full-Stack-Interview-QA.md** | 合并版（通读、导出 PDF 等用） |
| **merge-full-stack.sh** | 在 `Interview-QA/` 下执行 `./merge-full-stack.sh` 从 Part1～3 重新生成合并文件 |

### 以往资料（另一处归档）

较早整理的面试笔记已单独放在子目录 **`legacy/`**（见其中 `README.md`），与上表「按简历技术栈」成套文档区分，避免混在一处。

## 覆盖度核对（vs 根目录 `README.md` 技能表）

当前成套文档按「章」统计题量（每章均 ≥15 题，满足此前「每技术栈至少 15 题」的约定）：

| 章节 | 题量 | 简历对应 |
|------|------|----------|
| 一、Vue3 | 17 | Vue2·3 / Vue3 核心 |
| 二、TypeScript | 16 | TypeScript |
| 三、React | 16 | React；内含 RTK / Zustand 等生态题 |
| 四、Next.js | 15 | Next.js（App Router / RSC） |
| 五、React Native + Expo | 15 | RN、Expo、EAS、Hermes 等 |
| 六、Flutter / Dart | 16 | Flutter、Dart、钱包相关 |
| 七、Web3 / 区块链 | 16 | Ethers、Viem、Wagmi、Privy、DEX/跨链等 |
| 八、AI / LLM | 15 | RAG、SSE、Prompt、LangChain、Agent 等 |
| 九、Node.js / NestJS | 15 | Node、Nest；GraphQL 有涉及 |
| 十、工程化 / Monorepo / 性能 | 16 | pnpm、Turborepo、Vite、Docker、GitHub Actions 等 |
| 十一、WebSocket | 15 | WebSocket、实时行情场景 |

**简历中有、当前成套文档里未单独成章或明显偏少的点（可后续补题）：**

- **ES6+ / HTML5 / CSS3**：无独立章节（部分散落在 Vue/React）。
- **Bootstrap**：未覆盖。
- **Vue2 专项**：无单独章节（仅 Vue3 中有「Vue2→Vue3 迁移」类题目）。
- **Webpack / Rollup / Vitest / ESLint**：第十章仅有 Vite、Tree Shaking、ESLint+Husky 等概括题，**Vitest、Rollup 专项、Webpack 深度**可再加。
- **Nx**：Monorepo 以 Turborepo + pnpm 为主，**Nx** 未单列。
- **Express / Koa**：第九章以 Nest 与 Node 通用能力为主，**Express/Koa 中间件与洋葱模型**可单独加 2～3 题加深。
- **MySQL / PostgreSQL**：**关系型数据库与 SQL、事务、索引**未覆盖；GraphQL 仅在 Nest 一题带过。
- **Vercel AI SDK**：简历技能有提，**AI 章未单列**（可与 LangChain/OpenAI 并列补题）。
- **Web3.js**：简历有写，当前以 **Ethers / Viem** 为主，**web3.js API 差异**可补 1～2 题。
- **钱包线（Keplr / Cosmos、Trust）**：跨链与 WC 有涉及，**Keplr + Cosmos 签名、Trust 移动端**可再拆专项小题。
- **CI/CD**：GitHub Actions、Docker、EAS 分散在第十、五章；**多环境发布策略**可再集中加题。
- **开发工具（VS Code / Cursor / Git）**：未单独面试化（通常非技术深度考点）。

结论：**按「已整理的 11 个章」没有缺题到不足 15 道的情况**；若按**简历整张技能表的颗粒度**，上表「未单独成章」项为缺口，需要时可从 `legacy/` 旧笔记迁移或新写小节补全。

## 维护说明

- 日常只改 **Part1 / Part2 / Part3**；改完后在本目录执行 **`./merge-full-stack.sh`** 再生成 **Full-Stack-Interview-QA.md**（避免合并版与分片不一致）。
- 根目录 **`README.md`** 仍为个人简历主文件，未移动。
