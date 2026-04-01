# 全栈面试题库 — 于志鹏（全栈技术负责人 / 9 年经验）

> 基于全栈简历定向出题，覆盖前端 + 后端 + AI + Web3 + DevOps 五大方向，共 80 道题。  
> 每道题标注【难度】和【考察点】，附参考答案要点。

---

## 一、NestJS & Node.js 后端（全栈核心考点）

**Q1**【中等】NestJS 的核心架构理念是什么？`Module`、`Controller`、`Service`、`Provider` 之间的关系？  
**考察：** NestJS 架构  
**要点：** Module 是组织单元；Controller 处理路由请求；Service 封装业务逻辑并通过 `@Injectable()` 标记为 Provider；Provider 通过 IoC 容器自动注入到 Controller 或其他 Service。

**Q2**【中等】NestJS 的依赖注入是怎么工作的？和 Angular 的 DI 有什么关系？如果两个 Service 互相依赖（循环依赖）怎么处理？  
**考察：** DI 机制  
**要点：** 基于 Reflect Metadata + TypeScript 装饰器实现构造函数注入；借鉴 Angular DI 设计；循环依赖用 `@Inject(forwardRef(() => XxxService))` 解决，但应尽量避免，通过拆分模块或引入事件总线解耦。

**Q3**【进阶】你在 AI Agent Platform 中将 NestJS 拆分为 LLM Module、RAG Module、Agent Module，模块之间如何通信？跨模块调用 Service 需要怎么配置？  
**考察：** 模块化架构设计  
**要点：** 被调用的 Module 在 `exports` 中导出 Service；调用方 Module 在 `imports` 中引入；或用 `@Global()` 标记为全局模块；松耦合方案：EventEmitter2 事件驱动 / CQRS 模式。

**Q4**【中等】NestJS 的 `Guard`、`Interceptor`、`Pipe`、`Filter` 分别在请求生命周期的哪个阶段执行？执行顺序是什么？  
**考察：** 请求生命周期  
**要点：** Guard（鉴权，最先）→ Interceptor（前置逻辑）→ Pipe（参数验证/转换）→ Controller Handler → Interceptor（后置逻辑）→ Filter（异常捕获，最后兜底）。

**Q5**【进阶】你在 AI DATA 中用 Guard + Interceptor 实现统一鉴权与日志链路追踪，具体怎么做的？如何实现请求级别的 traceId 透传？  
**考察：** 中间件实战  
**要点：** Guard 校验 JWT / API Key，返回 `canActivate` 布尔值；Interceptor 用 `tap` 操作符记录请求耗时与响应体；traceId 通过 `cls-hooked`（AsyncLocalStorage）或 NestJS 的 `REQUEST` 作用域 Provider 实现请求级上下文透传。

**Q6**【中等】Node.js 的事件循环分哪几个阶段？`setTimeout`、`setImmediate`、`process.nextTick`、`Promise.then` 的执行优先级？  
**考察：** 运行时原理  
**要点：** 6 阶段：timers → pending → idle → poll → check → close；微任务优先于宏任务；`process.nextTick` > `Promise.then` > `setTimeout` > `setImmediate`（在 poll 阶段结束后 check 阶段执行）。

**Q7**【进阶】Node.js 是单线程的，但你的 AI Service 需要同时处理多个 LLM 请求（每个耗时 5-30 秒），如何避免阻塞？如何提高并发能力？  
**考察：** 并发模型  
**要点：** LLM 请求是 I/O 密集型（HTTP 调用），Node.js 的异步 I/O 天然支持；CPU 密集型任务用 Worker Threads；提高并发：连接池复用、请求队列限流、PM2/Cluster 多进程；NestJS 配合 Bull Queue 做异步任务。

**Q8**【进阶】你封装的 `LLMProvider` 支持多模型热切换与降级策略，后端代码大致怎么设计？熔断器模式怎么实现？  
**考察：** 容错设计  
**要点：** 抽象接口 `LLMProvider { chat(messages, options): AsyncIterable<Chunk> }`；每个模型一个实现类；熔断器：维护错误计数和状态（Closed/Open/Half-Open），连续 N 次失败 → Open（直接走降级）→ 超时后 Half-Open 试探 → 成功恢复 Closed。

---

## 二、PostgreSQL & 数据库设计

**Q9**【中等】PostgreSQL 和 MySQL 的核心区别？你在项目中为什么选 PostgreSQL？  
**考察：** 数据库选型  
**要点：** PG 支持 JSONB（灵活存储 AI 对话消息）、数组类型、全文搜索、pgvector 向量扩展（RAG 场景）；MVCC 实现更优、事务隔离级别支持更完善；MySQL 在简单读写场景性能更好、生态更广。

**Q10**【中等】你设计了数据集元信息表、交易流水表、积分明细表，能说说这三张表的核心字段和关系吗？  
**考察：** 数据库建模  
**要点：** 数据集表（id, name, owner_id, size, chunk_count, status, price, created_at）；交易表（id, dataset_id, buyer_id, seller_id, amount, tx_hash, status, created_at）；积分表（id, user_id, action, points, balance_after, ref_id, created_at）；交易表和积分表通过事务绑定保证一致性。

**Q11**【进阶】"使用事务保证交易与积分变动的原子性"，具体怎么实现的？如果事务中某一步失败了怎么处理？NestJS 中怎么管理事务？  
**考察：** 事务管理  
**要点：** TypeORM 的 `QueryRunner` 或 `EntityManager.transaction()`；流程：`startTransaction()` → 扣款 → 记录交易流水 → 增加积分 → `commitTransaction()`；任何一步抛异常 → `rollbackTransaction()`；NestJS 中可封装 `@Transactional()` 装饰器。

**Q12**【中等】数据库索引的底层数据结构是什么？什么场景该加索引？什么场景不该加？  
**考察：** 索引原理  
**要点：** B+ 树（范围查询友好）/ Hash（等值查询）/ GiST/GIN（全文搜索/JSONB）；该加：WHERE / JOIN / ORDER BY 高频字段；不该加：写多读少的表、低选择性字段（如性别）、小表。

**Q13**【进阶】数据集表可能有百万级数据，按 `owner_id` + `status` + `created_at` 组合查询，如何设计索引？联合索引的最左前缀原则是什么？  
**考察：** 索引优化  
**要点：** 创建联合索引 `(owner_id, status, created_at DESC)`；最左前缀：查询条件必须包含索引最左列才能命中索引；`WHERE owner_id = ? AND status = ? ORDER BY created_at DESC` 可以完全利用此索引。

---

## 三、Redis & 缓存

**Q14**【中等】Redis 常用的数据结构有哪些？各自适合什么场景？  
**考察：** Redis 基础  
**要点：** String（缓存/计数器）、Hash（对象存储/分片上传状态）、List（消息队列）、Set（去重/标签）、Sorted Set（排行榜/延迟队列）、Stream（事件流）。

**Q15**【中等】你用 Redis 记录分片上传状态，具体数据结构是怎么设计的？key 怎么命名？过期策略是什么？  
**考察：** Redis 实战  
**要点：** Key: `upload:{fileHash}:chunks`，用 Hash 存 `{ chunkIndex: status }`；或用 Bitmap 记录每个分片是否上传完成；过期策略：设置 TTL（如 24h），超时未完成的上传自动清理分片；合并完成后主动删除 Key。

**Q16**【进阶】Redis 和数据库之间的数据一致性怎么保证？如果 Redis 缓存了用户积分，积分变动时用"先更新数据库再删缓存"还是"先删缓存再更新数据库"？  
**考察：** 缓存一致性  
**要点：** 推荐"先更新数据库，再删除缓存"（Cache-Aside 模式）；极端场景下仍可能短暂不一致，可加延迟双删（更新 DB → 删缓存 → 延迟 500ms 再删一次）；或用 Canal/Debezium 监听 Binlog 异步刷新缓存。

---

## 四、Docker & CI/CD & DevOps

**Q17**【中等】Docker 的镜像（Image）和容器（Container）的关系？`Dockerfile` 中 `RUN`、`CMD`、`ENTRYPOINT` 的区别？  
**考察：** Docker 基础  
**要点：** Image 是只读模板（多层 UnionFS）；Container 是运行实例（可写层）；`RUN` 构建期执行命令生成新层；`CMD` 容器启动时默认命令（可被覆盖）；`ENTRYPOINT` 容器启动入口（不易被覆盖，CMD 作为参数传入）。

**Q18**【中等】你配置了 Docker Compose 编排 Nginx + NestJS + PostgreSQL + Redis，`docker-compose.yml` 的核心配置有哪些？服务间如何通信？  
**考察：** Docker Compose  
**要点：** `services` 定义各容器；`depends_on` 控制启动顺序；`networks` 共享网络（同一 bridge 内用服务名作为 hostname 直接访问）；`volumes` 持久化 PG 数据；`environment` 注入环境变量；`ports` 映射宿主端口。

**Q19**【进阶】NestJS 应用的 Dockerfile 怎么写才能优化构建速度和镜像体积？多阶段构建（multi-stage）怎么用？  
**考察：** Docker 优化  
**要点：** 阶段 1（builder）：`FROM node:20-alpine` → `COPY package.json` → `pnpm install` → `COPY src` → `pnpm build`；阶段 2（runner）：`FROM node:20-alpine` → 只 COPY `dist` + `node_modules`（production）→ `CMD ["node", "dist/main.js"]`；利用缓存层：先 COPY `package.json` 再 COPY 源码，依赖不变时跳过 install。

**Q20**【进阶】你的 GitHub Actions 全栈 CI/CD 流水线（前端 Lint → Build → CDN 部署，后端 Lint → Test → Docker Build → 多环境发布），能具体说说 workflow 配置吗？多环境怎么区分？  
**考察：** CI/CD 实战  
**要点：** `on.push.branches` 区分分支触发（develop → Dev / release/* → Staging / main → Prod）；前后端分 job 并行跑（`jobs.frontend` / `jobs.backend`）；后端 job：`docker build -t registry/app:$SHA` → `docker push` → SSH / K8s deploy；环境变量通过 GitHub Secrets + Actions env 注入。

---

## 五、全栈架构设计

**Q21**【进阶】你的 AI Agent Platform 用 Monorepo 管理前后端（`apps/web` + `apps/server` + `packages/*`），前后端在同一个仓库有什么好处和坏处？和前后端分仓有什么区别？  
**考察：** 工程架构选型  
**要点：** 好处：共享类型定义（消除接口不一致）、统一 CI/CD、原子提交（前后端联动改动一次 PR 搞定）；坏处：仓库体积大、CI 构建时间长（需增量构建）、权限管理粗粒度；分仓适合团队规模大、前后端部署节奏差异大的场景。

**Q22**【进阶】前后端共享 TypeScript 类型定义，你是怎么实现的？如果后端改了接口字段，前端怎么感知？  
**考察：** 全栈类型安全  
**要点：** `packages/sdk` 中定义接口类型（Request / Response DTO），前后端共同依赖；后端用 `class-validator` + `class-transformer` 做运行时校验，类型与 DTO 类复用；genapi 从 Swagger 自动生成保证单源对齐；后端改接口 → TypeScript 编译报错 → 前端必须同步修改。

**Q23**【进阶】BFF（Backend For Frontend）层的作用是什么？你在上海怡新做的 Node.js 中间层具体解决了什么问题？  
**考察：** BFF 架构  
**要点：** BFF 职责：接口聚合（多个微服务 → 一个前端请求）、数据裁剪（只返回前端需要的字段）、鉴权网关、协议转换（GraphQL → REST）；解决的问题：前端不直接调多个后端服务、减少请求次数、后端接口变动对前端的影响降低。

**Q24**【进阶】如果让你从零设计 AI DATA 的全栈架构，你会怎么规划？需要考虑哪些核心模块？  
**考察：** 系统设计  
**要点：** 前端层（SPA + Monorepo 多子站）→ BFF/API Gateway → 业务服务层（数据集服务 / 交易服务 / 积分服务 / 标注服务）→ AI 服务层（模型推理 / SSE 推送）→ 数据层（PostgreSQL + Redis + 对象存储 + 向量数据库）→ 基础设施（Docker + CI/CD + 监控告警）。

---

## 六、WebSocket 全栈（前端 + 后端）

**Q25**【中等】NestJS 的 `@WebSocketGateway` 和普通 REST Controller 有什么区别？底层用的什么库？  
**考察：** NestJS WebSocket  
**要点：** Gateway 处理持久连接而非请求-响应；底层默认 `socket.io`（可切换为 `ws`）；用 `@SubscribeMessage()` 监听事件；通过 `@ConnectedSocket()` 获取客户端连接；生命周期钩子：`handleConnection` / `handleDisconnect`。

**Q26**【进阶】你的行情推送 WebSocket Gateway 如何实现"房间订阅管理"？用户订阅了 BTC/USDT 交易对，服务端怎么只推这个交易对的数据？  
**考察：** 发布/订阅  
**要点：** 用 socket.io 的 Room 机制：用户订阅 → `client.join('pair:BTC_USDT')`；服务端行情更新 → `server.to('pair:BTC_USDT').emit('depth', data)`；用户切换交易对 → `client.leave` 旧房间 + `client.join` 新房间；或用 Redis Pub/Sub 实现跨进程广播。

**Q27**【进阶】WebSocket 连接数达到万级时，单个 NestJS 实例扛得住吗？如何水平扩展？多实例之间的消息广播怎么处理？  
**考察：** 扩展性  
**要点：** 单实例有连接数上限（受文件描述符和内存限制）；水平扩展：多实例 + Sticky Session（同一用户连同一实例）或无状态设计；跨实例广播：Redis Adapter（`@socket.io/redis-adapter`），所有实例通过 Redis Pub/Sub 同步消息。

---

## 七、分片上传全栈（前端 + 后端）

**Q28**【中等】分片上传的完整全栈流程是什么？前端和后端各自的职责？  
**考察：** 全链路理解  
**要点：** 前端：文件切片 → 计算文件 Hash → 查询已传分片（秒传/续传）→ 并发上传 → 通知合并。后端：提供查询接口（已传分片列表）→ 接收分片并暂存（对象存储/临时目录）→ 记录状态（Redis）→ 合并校验（MD5）→ 入库（PG 元信息）。

**Q29**【进阶】100GB 文件的分片合并在服务端是怎么实现的？合并时会阻塞服务吗？如何保证合并过程的可靠性？  
**考察：** 大文件处理  
**要点：** 流式合并：按分片顺序读取 + 写入目标文件（Stream pipe），不一次性读入内存；异步执行（Bull Queue 后台任务），不阻塞请求处理；可靠性：合并前校验分片完整性（数量 + 每片 MD5）→ 合并 → 校验整体 Hash → 成功后删除临时分片；失败则标记重试。

**Q30**【进阶】如果上传到一半服务端重启了，已上传的分片状态怎么恢复？你的 Redis 过期清理策略会不会误删正在上传中的数据？  
**考察：** 容错设计  
**要点：** Redis TTL 应设置足够长（如 24-48h）；每次上传分片成功都续期 TTL；服务重启后 Redis 数据不丢（开启 RDB/AOF 持久化）；客户端重连后调用查询接口获取已传列表继续上传；真正过期的是用户放弃上传的残留数据。

---

## 八、AI & RAG 全栈

**Q31**【中等】RAG 的完整全栈链路是什么？前端、后端、向量数据库各自的角色？  
**考察：** RAG 全流程  
**要点：** 离线：后端加载文档 → Chunking → 调 Embedding API 向量化 → 存入向量数据库。在线：前端发送 Query → 后端将 Query Embedding → 向量数据库检索 Top-K → 注入 Prompt 上下文 → 调 LLM 生成 → SSE 流式返回前端。

**Q32**【进阶】检索准确率从 65% 提升至 92% 的过程中，前端和后端分别做了哪些优化？  
**考察：** RAG 调优  
**要点：** 后端：优化 Chunk 策略（按语义段落切分 + 重叠窗口）、换更好的 Embedding 模型、增加 Rerank 重排序、混合检索（向量 + 关键词 BM25）、元数据过滤。前端：Query 输入优化（自动补全/推荐问题引导用户提出更精确的问题）、展示检索来源供用户判断。

**Q33**【进阶】向量数据库（如 pgvector / Pinecone / Milvus）的选型考量是什么？你用的是什么？数据量大了之后检索性能怎么保证？  
**考察：** 向量数据库  
**要点：** pgvector 优势：复用 PostgreSQL、运维简单、支持 SQL 联合查询；劣势：大规模向量检索性能不如专用库；性能优化：IVFFlat / HNSW 索引、降维、分区、缓存热门查询结果。

**Q34**【进阶】Function Calling 从前端到后端的完整调用链路是什么？如果工具执行失败了怎么处理？  
**考察：** Agent 全栈链路  
**要点：** 前端发送用户消息 → 后端调 LLM（带 tools 描述）→ LLM 返回 tool_call（函数名 + 参数）→ 后端路由到对应 Tool Handler 执行 → 将执行结果注入消息列表 → 再次调 LLM 生成最终回答 → SSE 返回前端。失败处理：try-catch 捕获工具异常 → 将错误信息作为 tool result 传回 LLM → 模型自行决定重试或告知用户。

---

## 九、Vue3 & TypeScript（前端核心）

**Q35**【中等】Vue3 的响应式系统 `Proxy` 相比 Vue2 的 `Object.defineProperty` 解决了什么问题？  
**考察：** 响应式原理  
**要点：** 动态属性新增/删除自动响应、数组索引直接修改、惰性劫持（用到才代理）、Map/Set 支持。

**Q36**【中等】`ref` 和 `reactive` 的区别？`storeToRefs` 解决了什么问题？  
**考察：** 响应式 API  
**要点：** `ref` 通过 `.value` 包装基本类型；`reactive` 通过 Proxy 代理对象；直接解构 `reactive` 丢失响应性，`storeToRefs` 将每个属性转为独立 `ref` 保持关联。

**Q37**【进阶】你设计了 `useSSE` 组合式函数，如果要同时支持 SSE 和 WebSocket 两种协议，你会怎么抽象？  
**考察：** 设计模式  
**要点：** 定义统一接口 `StreamTransport { connect(), onMessage(cb), close() }`；SSE 和 WebSocket 各自实现；上层 `useStream(transport)` 组合式函数不关心底层协议；通过工厂函数根据配置选择实现。

**Q38**【进阶】TypeScript 中如何实现一个类型安全的 API 请求层，让请求参数和响应类型自动推导？  
**考察：** 泛型设计  
**要点：** 定义路由映射 `type API = { '/users': { req: GetUsersReq; res: GetUsersRes } }`；封装 `request<T extends keyof API>(url: T, data: API[T]['req']): Promise<API[T]['res']>`；或用 genapi 自动生成。

---

## 十、Web3 & 区块链

**Q39**【中等】Ethers.js 中 `Provider` 和 `Signer` 的区别？调用合约的读方法和写方法分别需要什么？  
**考察：** Ethers.js 基础  
**要点：** Provider 只读（连接节点、查询链上数据）；Signer 可签名和发送交易；读方法（`view/pure`）只需 Provider；写方法需要 Signer（触发钱包签名）。

**Q40**【进阶】你设计的 `WalletAdapter` 统一钱包抽象层，策略模式具体怎么实现？如何做到新增钱包 1 天适配？  
**考察：** 设计模式  
**要点：** 接口定义：`connect()`, `disconnect()`, `signTransaction()`, `switchNetwork()`, `getBalance()`；每种钱包实现一个 Adapter 类；工厂根据钱包类型返回实例；新增钱包只需实现接口 + 注册到工厂，不改动上层逻辑。

**Q41**【进阶】ERC-20 Token 的 `approve` + `transferFrom` 两步操作为什么是必要的？跨链桥中这两步是怎么串起来的？  
**考察：** 合约交互  
**要点：** ERC-20 不允许合约直接扣用户 Token，需用户先 `approve` 授权额度给 Bridge 合约 → Bridge 合约再 `transferFrom` 扣款并锁定/销毁 → 目标链 mint/释放对应资产。

---

## 十一、性能优化（全栈视角）

**Q42**【中等】首屏从 3s 优化到 0.8s，前端做了什么？如果后端 API 响应慢，前端还能做什么优化？  
**考察：** 全链路优化  
**要点：** 前端：懒加载 / CDN / 压缩 / 预加载关键资源。后端 API 慢时：前端骨架屏 / 数据缓存（localStorage/SWR 策略）/ 非关键数据延迟加载 / SSR 首屏直出；同时推动后端优化（加缓存/加索引/异步化）。

**Q43**【进阶】WebSocket 每秒推送 10000+ 条消息，前端和后端分别怎么优化？  
**考察：** 高频数据优化  
**要点：** 后端：消息聚合（50ms 批量推送而非逐条）、按需推送（只推用户订阅的交易对）、二进制协议（Protocol Buffers 替代 JSON 减少体积）。前端：消息队列 + rAF 批量消费、增量更新（diff 而非全量替换）、`Object.freeze` 避免 Vue 深度代理。

**Q44**【进阶】PostgreSQL 查询慢，你会怎么排查和优化？  
**考察：** 数据库性能  
**要点：** `EXPLAIN ANALYZE` 分析执行计划 → 检查是否走索引 → 补建/调整索引 → 检查是否 N+1 查询 → 数据量大考虑分区表 → 热数据用 Redis 缓存 → 读写分离 → 慢查询日志定期巡检。

---

## 十二、Monorepo & 工程化

**Q45**【中等】`pnpm workspace` 的依赖隔离机制是什么？什么是"幽灵依赖"？pnpm 怎么避免的？  
**考察：** 包管理  
**要点：** pnpm 的 `node_modules` 不是扁平结构，通过符号链接只暴露 `package.json` 中声明的依赖；幽灵依赖 = 没在 `package.json` 中声明但因为 npm/yarn 扁平安装可以用的包，pnpm 严格隔离后会直接报错。

**Q46**【进阶】全栈 Monorepo 中前后端共享 `packages/sdk`，但后端用 CommonJS、前端用 ESM，SDK 打包怎么处理？  
**考察：** 模块系统  
**要点：** SDK 用 `tsup` 或 `rollup` 打双格式（ESM + CJS）；`package.json` 配置 `"main"` 指向 CJS、`"module"` 指向 ESM、`"exports"` 做条件导出；或统一用 ESM（NestJS 9+ 支持 ESM）。

---

## 十三、综合场景题

**Q47**【进阶】用户反馈"AI 回答越来越慢"，从前端到后端到 LLM 全链路，你会怎么排查？  
**考察：** 全栈问题排查  
**要点：** 前端：检查 SSE 连接是否正常、Token 计数是否超限导致裁剪逻辑耗时。后端：检查 NestJS 日志中 LLM API 响应时间、RAG 检索耗时、Queue 积压情况。LLM：上下文过长导致推理慢（Token 越多越慢）→ 优化上下文窗口裁剪策略、压缩历史消息、用摘要替代全量历史。

**Q48**【进阶】如果 AI DATA 的数据集交易功能出现了"用户付款成功但积分没到账"的问题，你会怎么排查？  
**考察：** 全栈问题定位  
**要点：** 查交易流水表（交易记录是否落库）→ 查积分表（是否有对应记录）→ 检查事务是否部分提交（事务配置是否正确）→ 查后端日志（是否抛异常）→ 检查 Redis 缓存积分是否与 DB 不一致 → 检查是否有并发竞争（乐观锁/悲观锁是否加了）。

**Q49**【进阶】如果让你给 AI Agent Platform 加一个"对话记录导出为 PDF"的功能，全栈怎么实现？  
**考察：** 全栈方案设计  
**要点：** 方案一（后端生成）：前端发请求 → 后端从 PG 查对话记录 → 用 `puppeteer` 或 `pdfkit` 渲染 HTML → 生成 PDF → 返回文件流 / 上传对象存储返回下载链接。方案二（前端生成）：前端用 `html2canvas` + `jsPDF` 直接在浏览器生成。推荐方案一（样式一致性好、不受浏览器限制）。

**Q50**【进阶】作为全栈技术负责人，前端和后端的代码你都 review 吗？前后端 review 的关注点有什么不同？  
**考察：** 技术管理  
**要点：** 都 review，但侧重不同。前端关注：组件设计合理性、状态管理是否冗余、性能（不必要的渲染/大列表）、类型完整性。后端关注：接口设计（RESTful 规范/幂等性）、SQL 性能（N+1/缺索引）、事务正确性、异常处理与兜底、安全（SQL 注入/XSS）。

---

## 十四、手写代码题

**Q51**【中等】实现一个 NestJS 的自定义 Guard，验证请求头中的 API Key。

```typescript
@Injectable()
export class ApiKeyGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    // 请实现
  }
}
```

**Q52**【中等】实现一个通用的并发控制函数（分片上传场景）。

```typescript
async function concurrencyLimit<T>(
  tasks: (() => Promise<T>)[],
  limit: number
): Promise<T[]> {
  // 请实现：最大并发 limit，按顺序返回所有结果
}
```

**Q53**【进阶】实现一个简化版的熔断器类（LLM 降级场景）。

```typescript
class CircuitBreaker {
  constructor(options: {
    failureThreshold: number  // 连续失败次数阈值
    resetTimeout: number      // Open 状态超时后转 Half-Open（ms）
  })

  async call<T>(fn: () => Promise<T>): Promise<T>
  // Closed: 正常执行 fn，失败计数；达阈值 → Open
  // Open: 直接抛异常，超时后 → Half-Open
  // Half-Open: 试执行一次，成功 → Closed，失败 → Open
}
```

**Q54**【进阶】实现一个 TypeScript 工具类型，从 NestJS DTO 类中提取所有属性及其类型（模拟 genapi 的类型生成）。

```typescript
// 输入
class CreateDatasetDto {
  name: string
  price: number
  tags: string[]
}

// 目标：提取为
type CreateDatasetParams = {
  name: string
  price: number
  tags: string[]
}

// 实现工具类型
type DtoToParams<T> = ???
```

---

## 快速自检清单

| 模块 | 必须能答上来的问题 |
|------|--------------------|
| NestJS 后端 | Q1 Q2 Q4 Q8 |
| PostgreSQL | Q9 Q10 Q11 Q13 |
| Redis | Q14 Q15 Q16 |
| Docker / CI/CD | Q17 Q18 Q20 |
| 全栈架构 | Q21 Q22 Q23 Q24 |
| WebSocket 全栈 | Q25 Q26 Q27 |
| 分片上传全栈 | Q28 Q29 Q30 |
| AI / RAG 全栈 | Q31 Q32 Q34 |
| Vue3 / TS | Q35 Q36 Q38 |
| Web3 | Q39 Q40 Q41 |
| 性能优化 | Q42 Q43 Q44 |
| Monorepo | Q45 Q46 |
| 综合场景 | Q47 Q48 Q50 |
| 手写代码 | Q51 Q52 Q53 |

---

*祝面试顺利！*
