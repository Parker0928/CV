# 面试题库 — 于志鹏（前端技术负责人 / 9 年经验）

> 根据简历内容定向出题，覆盖 8 大核心模块，共 60+ 道题。  
> 每道题标注【难度】和【考察点】，部分附参考答案要点。

---

## 一、Vue3 & TypeScript 深度（核心主战场）

### 1.1 Vue3 响应式与 Composition API

**Q1**【中等】Vue3 的响应式系统从 `Object.defineProperty` 换成了 `Proxy`，具体解决了哪些 Vue2 的痛点？`Proxy` 有什么局限性？  
**考察：** 响应式原理对比  
**要点：** 动态属性新增/删除、数组索引修改、性能（惰性劫持）；局限：不支持 IE、`Proxy` 无法被 polyfill。

**Q2**【中等】`ref` 和 `reactive` 的底层实现区别是什么？什么场景下你会选择 `ref` 而不是 `reactive`？  
**考察：** 响应式 API 理解深度  
**要点：** `ref` 通过 `RefImpl` 类的 getter/setter 实现，`reactive` 通过 `Proxy`；基本类型必须用 `ref`；`reactive` 解构会丢失响应性。

**Q3**【进阶】你在交易所项目中提到用 `storeToRefs` + `computed` 避免不必要的重渲染，能详细说说 Pinia 中 `storeToRefs` 与直接解构的区别吗？为什么直接解构会导致问题？  
**考察：** Pinia 响应式丢失 + 性能优化意识  
**要点：** 直接解构 `reactive` 对象会丢失响应性，`storeToRefs` 将每个属性转为 `ref` 保持关联；`computed` 做派生避免冗余 watcher。

**Q4**【进阶】Composition API 的 `setup` 中没有 `this`，你在大型项目中如何组织逻辑复用？`composable` 和 `mixin` 相比有什么本质优势？  
**考察：** 代码组织与架构能力  
**要点：** composable 函数式组合、显式依赖、类型推导友好、避免命名冲突；mixin 隐式依赖、来源不明。

**Q5**【进阶】Vue3 的 `watchEffect` 和 `watch` 在依赖收集机制上有什么区别？在你的 AI Chat 流式渲染场景中，如果用 `watchEffect` 监听消息列表变化去做自动滚动，可能遇到什么问题？  
**考察：** 响应式调度与实战坑  
**要点：** `watchEffect` 自动收集依赖、立即执行；大量 chunk 追加时可能频繁触发，需要 `flush: 'post'` 或 `nextTick` + 节流。

### 1.2 TypeScript 类型系统

**Q6**【中等】`type` 和 `interface` 的核心区别是什么？你在项目中如何选择？  
**考察：** TS 基础  
**要点：** interface 可声明合并、继承 extends；type 支持联合/交叉/映射类型；一般对象结构用 interface，工具类型用 type。

**Q7**【进阶】你的 AI Agent 项目中定义了 Tool Schema，如果要用 TypeScript 实现一个类型安全的 Function Calling 注册机制，让每个 tool 的参数和返回值都有类型推导，你会怎么设计？  
**考察：** 泛型 + 类型推导实战  
**要点：** 泛型函数 `defineTool<TParams, TResult>(schema)` 返回强类型对象；利用 `infer` 从 schema 推导类型；映射类型注册表 `Record<ToolName, ToolHandler>`。

**Q8**【进阶】`keyof`、`typeof`、`infer` 各自的使用场景？请写一个工具类型，提取一个函数的第一个参数的类型。  
**考察：** 高级类型体操  
**要点：** `type FirstParam<T> = T extends (first: infer F, ...args: any[]) => any ? F : never`

---

## 二、AI & 大模型应用（核心亮点）

### 2.1 RAG 架构

**Q9**【中等】RAG 的完整链路是什么？你的项目中从文档到最终回答经历了哪些步骤？  
**考察：** RAG 全流程理解  
**要点：** 文档加载 → 文本分块(Chunking) → Embedding 向量化 → 存入向量数据库 → 用户 Query Embedding → 相似度检索(Top-K) → 上下文注入 Prompt → LLM 生成回答。

**Q10**【进阶】你提到用"文本分块 + 重叠窗口策略"优化切片质量，具体怎么做的？Chunk Size 和 Overlap 设多大？如何评估切片质量？  
**考察：** RAG 调优经验  
**要点：** Chunk Size 通常 500-1000 tokens、Overlap 10%-20%；按语义段落切分优于固定长度；评估指标：检索召回率、命中率、最终回答准确率（从 65% → 92% 的过程）。

**Q11**【进阶】检索准确率从 65% 提升至 92%，你具体做了哪些优化？如果遇到"检索到了但答案不对"和"根本没检索到"两种情况，分别怎么排查？  
**考察：** RAG 调优方法论  
**要点：** "检索到但不对"：Chunk 粒度过粗 / Prompt 引导不足 / 噪声上下文干扰；"没检索到"：Embedding 模型选择 / Query 改写 / 增加元数据过滤。优化手段：混合检索(向量+关键词)、Rerank 重排序、Query Expansion。

### 2.2 SSE 流式交互

**Q12**【中等】SSE（Server-Sent Events）和 WebSocket 的核心区别？为什么 AI 场景选 SSE 而不是 WebSocket？  
**考察：** 通信协议选型  
**要点：** SSE 单向（服务端→客户端）、基于 HTTP、自动重连、天然适合流式输出；WebSocket 双向、更复杂；AI 推理是单向流，SSE 足够且更简单。

**Q13**【进阶】你封装了 `useSSE` 组合式函数，处理流解析、错误重连和 Token 计数，能详细说说实现思路吗？如何处理 SSE 连接中断后的重连？网络抖动时如何保证消息不丢？  
**考察：** SSE 工程化实现  
**要点：** EventSource / fetch + ReadableStream；自定义重连（指数退避 + 最大重试次数）；通过消息 ID 或 offset 实现断点续传；Token 计数用 tiktoken 或近似估算。

**Q14**【进阶】流式渲染时，每收到一个 chunk 就更新 DOM，在长回答场景下可能导致什么性能问题？你是怎么优化的？  
**考察：** 渲染性能  
**要点：** 频繁 DOM 更新 → 卡顿；解决方案：批量合并 chunk（requestAnimationFrame / 16ms 节流）、虚拟滚动、`v-once` 对历史消息免渲染。

### 2.3 Function Calling & Prompt Engineering

**Q15**【中等】Function Calling 的工作原理是什么？模型是如何"知道"要调用哪个函数的？  
**考察：** LLM 工具调用机制  
**要点：** 在 System Prompt 或 API 参数中传入 tools 描述（名称、参数 JSON Schema、说明）；模型根据用户意图选择工具并输出结构化调用参数；前端/后端执行后将结果注入下一轮对话。

**Q16**【进阶】你设计了 10+ 种工具能力，当用户一句话触发多个工具时（比如"查一下 ETH 当前价格并分析最近一周 K 线"），你的 Agent 是怎么处理的？串行还是并行？  
**考察：** Agent 编排  
**要点：** 任务拆解 → 依赖分析 → 无依赖任务并行（Promise.all）、有依赖任务串行（链式调用）；结果汇总后统一注入 Prompt 让模型综合回答。

**Q17**【进阶】结构化 Prompt 输出 JSON/Table 时，模型偶尔会输出格式不合规的内容（比如 JSON 截断、多余文本），你怎么处理？  
**考察：** Prompt 工程健壮性  
**要点：** JSON Schema 约束 + `response_format: { type: "json_object" }`；兜底方案：正则提取 + `JSON.parse` try-catch + 重试策略；流式场景下逐步拼接 JSON 用增量解析器。

### 2.4 多模型管理

**Q18**【进阶】你提到封装了 `LLMProvider` 抽象层支持多模型热切换与降级策略，具体怎么实现的？降级触发条件是什么？  
**考察：** 架构设计  
**要点：** 统一接口 `LLMProvider.chat(messages, options)` 适配不同厂商 API；降级条件：超时 / 429 限流 / 500 错误 / 余额不足；策略：主模型 GPT-4o → 备选 Claude → 兜底 DeepSeek；配合熔断器模式（错误率阈值触发自动切换）。

---

## 三、Web3 & 区块链（差异化竞争力）

### 3.1 钱包连接

**Q19**【中等】MetaMask 的 Injected Provider 模式和 WalletConnect 的 Relay Protocol 模式有什么本质区别？用户体验上有何不同？  
**考察：** 钱包连接原理  
**要点：** Injected Provider 是浏览器插件直接注入 `window.ethereum`，同域通信；WalletConnect 通过中继服务器 + 二维码/深度链接实现跨设备签名，适合移动端。

**Q20**【进阶】你设计的 `WalletAdapter` 统一抽象层，用了策略模式，能画一下类结构吗？如何做到新增钱包只需 1 天？  
**考察：** 设计模式实战  
**要点：** 定义 `WalletAdapter` 接口（connect / disconnect / signTransaction / switchNetwork / getBalance）；每种钱包实现一个 Adapter 类；工厂函数根据钱包类型返回具体实例；新增钱包只需实现接口、注册到工厂。

**Q21**【进阶】Ethereum 和 Cosmos 的交易签名机制有什么不同？在跨链桥中如何统一处理这两种链的交易流程？  
**考察：** 多链开发经验  
**要点：** Ethereum 用 ECDSA secp256k1 签名、RLP 编码；Cosmos 用 Amino / Protobuf 编码、ADR-036 签名；抽象 `ChainTransactionBuilder` 接口，分链实现交易构建 → 签名 → 广播 → 确认的统一流程。

### 3.2 合约交互

**Q22**【中等】用 Ethers.js 调用合约的完整流程是什么？`Contract.connect(signer)` 和 `Contract.connect(provider)` 有什么区别？  
**考察：** Ethers.js 基础  
**要点：** provider 只读（call）、signer 可写（sendTransaction）；流程：创建 Provider → 获取 Signer → 实例化 Contract(address, ABI, signer) → 调用方法。

**Q23**【进阶】在交易所项目中，用户下单时需要链上签名，如何处理 Gas 估算失败的情况？如何避免交易卡在 pending 状态？  
**考察：** 链上交易异常处理  
**要点：** Gas 估算失败通常是合约 revert，需 try-catch 捕获错误并解析 revert reason；pending 处理：设置合理 gasPrice / maxFeePerGas、支持加速（替换交易 nonce 不变 + 更高 gas）或取消。

**Q24**【进阶】`Bignumber.js` 在交易所中处理价格精度，为什么不直接用 `BigInt`？两者有什么区别？  
**考察：** 数值精度方案选型  
**要点：** `BigInt` 只支持整数，无法处理小数；交易所价格有多位小数（如 0.00001234 BTC），需要 `Bignumber.js` 的任意精度十进制运算；另一种方案是统一用最小单位整数（如 wei）配合 BigInt。

---

## 四、WebSocket & 实时通信（交易所核心）

**Q25**【中等】WebSocket 的握手过程是什么？和 HTTP 长轮询相比有什么优势？  
**考察：** 协议基础  
**要点：** HTTP Upgrade 请求 → 101 Switching Protocols → 全双工连接；优势：低延迟、无重复 Header 开销、双向推送。

**Q26**【进阶】你封装的 WebSocket 通信层中"指数退避重连"策略具体是怎样的？最大重连间隔设多少？如何避免"重连风暴"（所有客户端同时重连）？  
**考察：** 连接健壮性  
**要点：** 初始 1s → 2s → 4s → 8s → max 30s；加入随机抖动（jitter）避免雷群效应；记录重连次数，超限提示用户手动刷新。

**Q27**【进阶】每秒 10000+ 条消息推送，前端如何消费？直接渲染会有什么问题？你是怎么处理的？  
**考察：** 高频数据渲染优化  
**要点：** 直接渲染会导致页面卡死；方案：消息队列缓冲 + `requestAnimationFrame` 批量消费（16ms/帧）；对深度数据做增量更新（diff 算法）而非全量替换；用 `Object.freeze` 冻结不变数据避免 Vue 深度响应式开销。

**Q28**【进阶】WebSocket 连接断开后，行情数据会出现空白区间，你是怎么处理数据补偿的？  
**考察：** 数据一致性  
**要点：** 重连后发送最后收到的消息 ID / 时间戳，请求服务端补推缺失数据；或通过 REST API 拉取缺失区间的快照数据，与实时流合并。

---

## 五、性能优化（面试高频）

**Q29**【中等】首屏加载从 3s 优化到 0.8s，你具体做了哪些事？优先级怎么排的？  
**考察：** 性能优化方法论  
**要点：** 分析阶段（Lighthouse / Performance / Bundle Analyzer）→ 网络层（CDN / Gzip / 分包）→ 资源层（懒加载 / 预加载 / 图片优化）→ 渲染层（虚拟滚动 / 异步组件）→ 运行时（冻结数据 / 节流）。

**Q30**【中等】虚拟滚动（Virtual List）的核心原理是什么？如果列表项高度不固定怎么办？  
**考察：** 虚拟滚动实现  
**要点：** 只渲染可视区域内的 DOM，通过计算 scrollTop 确定起始/结束索引；不定高：预估高度 + 渲染后缓存实际高度 + 动态修正总高度和偏移量。

**Q31**【进阶】你提到用 `requestAnimationFrame` 节流高频行情渲染，为什么不用 `setTimeout` 或 `lodash.throttle`？有什么区别？  
**考察：** 浏览器渲染机制  
**要点：** rAF 与浏览器刷新帧对齐（16.67ms / 60fps），在下一帧绘制前执行，避免无效渲染和丢帧；setTimeout 不与帧同步可能导致卡顿或浪费。

**Q32**【进阶】内存占用降低 60% 是怎么做到的？如何排查前端内存泄漏？  
**考察：** 内存优化  
**要点：** `Object.freeze` 冻结行情快照、及时清理 WebSocket 订阅与定时器、组件卸载时注销事件监听、避免闭包引用导致的 GC 无法回收；排查工具：Chrome DevTools Memory Snapshot、Performance Monitor。

---

## 六、工程化 & Monorepo（架构能力）

**Q33**【中等】`pnpm workspace` 的依赖管理机制是什么？和 `npm workspace` / `yarn workspace` 有什么区别？  
**考察：** 包管理器对比  
**要点：** pnpm 通过硬链接 + 内容寻址存储节省磁盘空间；严格的 node_modules 结构（非扁平化）避免幽灵依赖；workspace 协议（`workspace:*`）实现内部包引用。

**Q34**【中等】Changeset 的工作流程是什么？和直接手动改 `package.json` 版本号有什么区别？  
**考察：** 版本管理  
**要点：** 开发者提交时运行 `changeset add` 选择变更包和版本策略（major/minor/patch）+ 描述；发布时 `changeset version` 自动更新版本号和 CHANGELOG；确保版本号语义化、变更可追溯。

**Q35**【进阶】管理 6+ 个子项目的 Monorepo，构建速度怎么保证？如果某个包改了，如何只构建受影响的子项目？  
**考察：** 增量构建  
**要点：** Turborepo 的 task pipeline + 缓存（本地 + 远程 cache）；依赖图分析只跑受影响的任务；`turbo run build --filter=...[HEAD~1]` 增量构建。

**Q36**【进阶】你搭建了 50+ 通用组件的组件库，组件库的打包策略是什么？ESM / CJS / UMD 都支持吗？样式怎么处理？  
**考察：** 组件库工程化  
**要点：** Rollup 多格式输出（ESM 为主、CJS 兼容）；样式方案：CSS-in-JS / 独立 CSS 文件 / CSS 变量主题；Tree-shaking 友好：保持 ESM + `sideEffects: false`；按需加载：组件独立入口。

---

## 七、分片上传 & 文件处理（项目亮点）

**Q37**【中等】分片上传的完整流程是什么？为什么要用 Web Workers 做 Hash 计算？  
**考察：** 大文件上传方案  
**要点：** 文件切片 → 每片计算 Hash（SparkMD5）→ 查询服务端已上传分片（秒传/续传）→ 并发上传 → 全部完成后通知服务端合并；Web Workers 避免 Hash 计算阻塞主线程导致 UI 卡顿。

**Q38**【进阶】并发上传队列"最大并发 6 路"是怎么实现的？如果某一片上传失败，重试策略是什么？  
**考察：** 并发控制  
**要点：** 实现一个并发控制器（Promise 池），维护正在运行的请求数，完成一个启动下一个；失败重试：单片最多 3 次重试（指数退避），超过标记失败并暂停后续上传，提示用户断点续传。

**Q39**【进阶】100GB 文件上传，如何保证断点续传的可靠性？刷新浏览器后怎么恢复进度？  
**考察：** 可靠性设计  
**要点：** 服务端记录已完成分片列表（以文件 Hash + 分片索引为 key）；前端上传前先查询已完成列表，跳过已传分片；文件 Hash（整体/抽样）用于校验文件一致性；进度可持久化到 localStorage / IndexedDB。

---

## 八、团队管理 & 软技能（技术负责人考察）

**Q40**【中等】你推动 Vue2 → Vue3 迁移，团队阻力大吗？怎么推动的？迁移策略是渐进式还是重写？  
**考察：** 技术决策与推动  
**要点：** 评估成本收益 → 小范围 POC 验证 → 制定迁移 Checklist → 渐进式（新项目直接 Vue3、老项目按模块迁移）→ 编写迁移指南 → CR 把关。

**Q41**【中等】你建立了 Code Review 流程，CR 时你主要关注哪些方面？有没有遇到过 CR 效率低、形同虚设的问题？怎么解决？  
**考察：** 代码质量治理  
**要点：** 关注点：架构合理性 > 逻辑正确性 > 性能隐患 > 代码风格；效率低：制定 CR Checklist、限定 Review 时间、小 PR 原则（<400 行）、自动化 Lint 先行。

**Q42**【中等】新人上手周期从 4 周缩短至 2 周，你具体做了哪些事？  
**考察：** 团队建设  
**要点：** 编写 Onboarding 文档（技术栈 / 项目架构 / 开发流程）、Starter Template 脚手架、Pair Programming 带教、首周安排简单任务快速出活增强信心。

**Q43**【进阶】作为技术负责人，你是如何做技术选型决策的？举一个你做过的选型案例，分析利弊和最终决策依据。  
**考察：** 技术判断力  
**要点：** 从业务需求出发 → 候选方案对比（社区活跃度 / 学习成本 / 团队储备 / 长期维护）→ POC 验证 → 团队讨论 → 渐进引入；可以用 Monorepo（Turborepo vs Nx vs Lerna）或状态管理（Pinia vs Vuex）做案例。

---

## 九、综合场景题 & 系统设计（高级）

**Q44**【进阶】如果让你从零设计一个 AI Chat 产品的前端架构，你会怎么规划？需要考虑哪些核心模块？  
**考察：** 架构设计全局观  
**要点：** 消息系统（数据模型 / 流式渲染 / 历史管理）、会话管理（多轮上下文 / Token 窗口）、流式通信层（SSE / WebSocket）、工具调用 UI（Function Calling 结果展示）、状态管理、离线缓存、错误处理与降级、多模型切换。

**Q45**【进阶】交易所的订单簿组件每秒接收几千条更新，如果让你重新设计这个组件，你会怎么做？要求：低延迟、不卡顿、价格精准。  
**考察：** 高性能组件设计  
**要点：** 数据层：增量更新（diff 价格档位，只改变化的行）+ 排序树维护；渲染层：虚拟滚动 + Canvas 渲染（脱离 DOM）；精度层：BigNumber 处理 + 统一精度格式化；节流层：rAF 批量更新。

**Q46**【进阶】你负责的 Monorepo 有 6+ 子项目，如果有一天某个共享包发了一个 Bug，导致所有子项目都受影响，你会怎么排查和处理？如何避免类似问题再次发生？  
**考察：** 工程化治理与应急  
**要点：** 排查：快速定位共享包变更（git log / changeset）→ 回滚或 hotfix；预防：共享包单测覆盖、发布前集成测试（CI 矩阵跑所有消费者项目）、锁版本 + Canary 发布、共享包 Breaking Change 必须 major 版本号。

**Q47**【进阶】跨链桥项目中，如果用户发起了一笔跨链交易，源链确认了但目标链迟迟没到账，你作为前端应该如何处理？给用户什么反馈？  
**考察：** 异常场景处理  
**要点：** 前端展示交易分阶段状态（源链确认 → 中继传输 → 目标链确认）；超时告警（如目标链 30 分钟未确认）；提供交易哈希让用户自查；对接后端定时任务监控卡单；UI 提供"联系客服"入口。

---

## 十、代码手写题（现场编码）

**Q48**【中等】实现一个并发控制函数 `concurrencyLimit(tasks, limit)`，限制最大并发数。

```typescript
// 输入：tasks 是一组返回 Promise 的函数，limit 是最大并发数
// 输出：按顺序返回所有结果
async function concurrencyLimit<T>(
  tasks: (() => Promise<T>)[],
  limit: number
): Promise<T[]> {
  // 请实现
}
```

**Q49**【中等】实现一个带有自动重连和心跳机制的 WebSocket 封装类。

```typescript
class ReconnectWebSocket {
  constructor(url: string, options?: {
    heartbeatInterval?: number  // 心跳间隔 ms
    maxRetries?: number         // 最大重连次数
    retryDelay?: number         // 初始重连延迟 ms
  })

  connect(): void
  send(data: any): void
  on(event: string, handler: Function): void
  close(): void
}
```

**Q50**【进阶】实现一个简化版的 `useSSE` 组合式函数。

```typescript
// 需求：
// 1. 建立 SSE 连接，逐 chunk 返回响应式数据
// 2. 支持错误重连
// 3. 组件卸载自动断开

function useSSE(url: string) {
  // 返回 { data, error, isStreaming, close }
}
```

---

## 十一、CSS3 & HTML5 基础（常被忽视的考点）

**Q51**【中等】BFC（Block Formatting Context）是什么？触发条件有哪些？在实际开发中什么场景会用到？  
**考察：** CSS 布局原理  
**要点：** BFC 是独立渲染区域，内部元素不影响外部；触发：`overflow: hidden`、`display: flex/grid`、`float`、`position: absolute/fixed`；场景：清除浮动、防止 margin 塌陷、自适应两栏布局。

**Q52**【中等】Flex 布局中 `flex: 1` 等价于什么？`flex-grow`、`flex-shrink`、`flex-basis` 三者分别控制什么？  
**考察：** Flex 布局  
**要点：** `flex: 1` = `flex-grow: 1; flex-shrink: 1; flex-basis: 0%`；grow 控制剩余空间分配比例、shrink 控制空间不足时的收缩比例、basis 控制初始主轴尺寸。

**Q53**【中等】CSS 选择器优先级如何计算？`!important` > 内联 > ID > Class > 标签，如果两个选择器权重相同怎么办？  
**考察：** 选择器权重  
**要点：** 相同权重按源码顺序后者覆盖前者；权重计算：(内联, ID 数, 类/属性/伪类数, 标签/伪元素数)；`!important` 破坏层叠规则，应尽量避免。

**Q54**【进阶】`position: sticky` 的工作原理和使用限制？在你的交易所项目中，表头固定是怎么实现的？  
**考察：** 定位机制  
**要点：** sticky 在滚动到阈值前是 relative，到达后变为 fixed；限制：祖先元素不能有 `overflow: hidden/auto`，必须指定 `top/left` 等阈值；交易所场景也可以用双层 div（固定表头 + 可滚动 body）实现。

**Q55**【中等】HTML5 的 `Web Workers`、`Service Worker`、`SharedWorker` 三者有什么区别？你在分片上传中为什么选 Web Workers？  
**考察：** HTML5 多线程  
**要点：** Web Worker 专属单页面后台线程；SharedWorker 多页面共享；Service Worker 拦截网络请求（PWA/离线缓存）；分片上传选 Web Worker 因为只需要单页面内做 CPU 密集的 Hash 计算，不需要跨页面通信。

---

## 十二、Vite & Webpack 构建工具

**Q56**【中等】Vite 为什么比 Webpack 快？它的开发模式和生产模式分别用了什么技术？  
**考察：** 构建工具原理  
**要点：** 开发模式：基于浏览器原生 ESM + esbuild 预构建依赖（Go 编写，速度极快）；生产模式：用 Rollup 打包；Webpack 开发时需要全量打包后启动 DevServer，所以慢。

**Q57**【中等】Vite 的 HMR（热更新）为什么快？和 Webpack 的 HMR 有什么区别？  
**考察：** HMR 机制  
**要点：** Vite HMR 基于 ESM，只需要重新请求变更的模块（精确到文件级），不需要重新构建整个 Bundle；Webpack HMR 需要重新编译变更模块及其依赖链，项目越大越慢。

**Q58**【进阶】你在项目中用 `vite-plugin-cdn-import` 做 CDN 拆包，具体是怎么配置的？有没有遇到 CDN 资源加载失败的情况？怎么做降级？  
**考察：** 构建优化实战  
**要点：** 配置：指定包名 + CDN URL，插件自动在 HTML 注入 `<script>` 标签并在 Rollup 中 external 对应依赖；降级方案：`<script>` 的 `onerror` 回退到本地资源 / 备用 CDN；或用 `window.Vue` 检测是否加载成功。

**Q59**【进阶】Webpack 的 Tree Shaking 原理是什么？为什么 CommonJS 模块无法被 Tree Shake？  
**考察：** Tree Shaking  
**要点：** 基于 ESM 的静态分析（import/export 在编译期确定），标记未使用的导出并在压缩阶段删除；CJS 是动态加载（`require` 可以在条件语句中），无法静态分析依赖关系。

---

## 十三、Node.js & NestJS 后端

**Q60**【中等】Node.js 的事件循环（Event Loop）分哪几个阶段？`setTimeout`、`setImmediate`、`process.nextTick` 的执行顺序是什么？  
**考察：** Node.js 运行时  
**要点：** 6 个阶段：timers → pending callbacks → idle/prepare → poll → check → close；`process.nextTick` 在当前阶段结束后立即执行（微任务）；`setImmediate` 在 check 阶段；`setTimeout(fn, 0)` 在 timers 阶段。

**Q61**【中等】NestJS 的依赖注入（DI）是怎么工作的？`@Injectable()`、`@Module()`、`providers` 之间的关系是什么？  
**考察：** NestJS 核心机制  
**要点：** `@Injectable()` 标记类可被注入；在 `@Module()` 的 `providers` 中注册；NestJS IoC 容器根据构造函数参数类型自动解析并注入实例；`exports` 用于跨模块共享 Provider。

**Q62**【进阶】你在 AI Agent Platform 中将 NestJS 拆分为 LLM Module、RAG Module、Agent Module，模块之间如何通信？如果 RAG Module 需要调用 LLM Module 的能力，怎么设计？  
**考察：** 模块化架构  
**要点：** LLM Module 在 `exports` 中导出 `LLMService`；RAG Module 在 `imports` 中引入 LLM Module，通过构造函数注入 `LLMService`；或通过自定义事件（EventEmitter2）实现松耦合通信。

---

## 十四、MySQL & GraphQL

**Q63**【中等】MySQL 的 `INNER JOIN`、`LEFT JOIN`、`RIGHT JOIN` 有什么区别？什么场景下用 `LEFT JOIN`？  
**考察：** SQL 基础  
**要点：** INNER JOIN 只返回两表匹配的行；LEFT JOIN 返回左表全部 + 右表匹配的（不匹配填 NULL）；场景：查询所有用户及其订单（包括没下单的用户）。

**Q64**【中等】MySQL 索引的底层数据结构是什么？为什么用 B+ 树而不是 B 树或 Hash？  
**考察：** 索引原理  
**要点：** InnoDB 用 B+ 树；B+ 树叶子节点有序链表，支持范围查询；B 树非叶子节点也存数据，查询不稳定；Hash 只支持等值查询，不支持范围和排序。

**Q65**【中等】GraphQL 相比 REST API 的核心优势是什么？有什么劣势？  
**考察：** API 设计  
**要点：** 优势：客户端按需查询字段（避免 over-fetching / under-fetching）、一次请求获取多资源、强类型 Schema；劣势：缓存复杂（无法用 HTTP 缓存）、N+1 查询问题、学习成本。

---

## 十五、Git & CI/CD 工程实践

**Q66**【中等】`git rebase` 和 `git merge` 的区别？什么场景用 rebase，什么场景用 merge？  
**考察：** Git 工作流  
**要点：** merge 保留完整历史（产生 merge commit）；rebase 线性化历史（更干净但改写了提交记录）；个人分支同步主分支用 rebase，合入主分支用 merge（保留合并记录）。

**Q67**【中等】`git reset --soft`、`--mixed`、`--hard` 的区别？误操作 `--hard` 后怎么恢复？  
**考察：** Git 撤销  
**要点：** soft 保留暂存区和工作区；mixed（默认）重置暂存区、保留工作区；hard 全部丢弃；恢复：`git reflog` 找到之前的 commit hash → `git reset --hard <hash>`。

**Q68**【进阶】你的 GitHub Actions 流水线（Lint → Test → Build → Deploy）具体是怎么配置的？多环境发布（Dev / Staging / Prod）的分支策略是什么？  
**考察：** CI/CD 实战  
**要点：** 分支策略：`develop` → Dev 环境、`release/*` → Staging、`main` → Prod；Actions 配置：`on: push` 触发对应分支的 workflow，每个 job 依赖前一个（`needs`）；Prod 发布加 manual approval。

**Q69**【中等】Docker 的镜像（Image）和容器（Container）有什么区别？`Dockerfile` 中 `COPY` 和 `ADD` 有什么区别？  
**考察：** Docker 基础  
**要点：** Image 是只读模板（多层文件系统）；Container 是 Image 的运行实例（可读写层）；`COPY` 纯复制文件；`ADD` 额外支持 URL 下载和 tar 自动解压，推荐默认用 `COPY`。

---

## 十六、React 基础（简历技能项）

**Q70**【中等】React 的 `useState` 是同步还是异步？在事件处理函数中连续调用两次 `setState` 会触发几次渲染？  
**考察：** React 状态更新  
**要点：** React 18 默认所有场景批处理（Automatic Batching），连续 setState 只触发一次渲染；如果需要立即基于前值更新，使用函数式更新 `setState(prev => prev + 1)`。

**Q71**【中等】React 的 `useEffect` 和 Vue 的 `watchEffect` 有什么异同？`useEffect` 的依赖数组传 `[]` 和不传分别是什么行为？  
**考察：** 框架对比  
**要点：** 相同：都是副作用自动追踪；不同：`useEffect` 需要手动声明依赖数组，`watchEffect` 自动收集；`[]` = 仅 mount 执行一次；不传 = 每次渲染都执行；缺少依赖会导致闭包陷阱。

**Q72**【进阶】Vue3 和 React 在响应式机制上的本质区别是什么？各有什么优劣？  
**考察：** 框架原理对比  
**要点：** Vue 基于 Proxy 数据劫持（自动依赖收集，细粒度更新）；React 基于 `setState` 触发 Reconciliation（Virtual DOM diff，自顶向下重渲染）；Vue 更新更精准但响应式有心智负担（ref/reactive），React 模型更简单但可能有不必要的渲染（需 memo 优化）。

---

## 快速自检清单

| 模块 | 必须能答上来的问题 |
|------|--------------------|
| Vue3 | Q1 Q2 Q3 Q4 |
| TypeScript | Q6 Q7 |
| AI/RAG | Q9 Q10 Q11 Q15 |
| SSE | Q12 Q13 Q14 |
| Web3 | Q19 Q20 Q22 |
| WebSocket | Q25 Q26 Q27 |
| 性能优化 | Q29 Q30 Q31 |
| Monorepo | Q33 Q35 Q36 |
| 分片上传 | Q37 Q38 Q39 |
| 团队管理 | Q40 Q41 Q43 |
| 系统设计 | Q44 Q45 |
| CSS3 / HTML5 | Q51 Q52 Q55 |
| Vite / Webpack | Q56 Q58 Q59 |
| Node.js / NestJS | Q60 Q61 Q62 |
| MySQL / GraphQL | Q63 Q64 Q65 |
| Git / CI/CD | Q66 Q67 Q68 |
| React | Q70 Q71 Q72 |

---

*祝面试顺利！*
