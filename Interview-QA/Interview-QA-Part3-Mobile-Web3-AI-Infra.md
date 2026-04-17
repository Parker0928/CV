## 六、React Native + Expo

### 1. New Architecture（Fabric + TurboModules + JSI）？

**答案：** 旧 Bridge 异步 JSON 序列化瓶颈；JSI 让 JS 直接持有 C++ Host 对象引用，同步调用原生；Fabric 同步布局与并发渲染；TurboModules 懒加载原生模块。降低延迟、提升启动与动画性能。

### 2. Hermes 与字节码？

**答案：** Hermes 为 RN 优化的引擎：构建期生成字节码（BC），运行时解释执行，减少 parse 时间；配合预编译包提升 TTI。JSC 需运行时解析更多源码。

### 3. Managed vs Bare 与 EAS Build？

**答案：** Managed 由 Expo 管理原生工程；Bare 暴露 `android/ios` 全量原生。EAS Build 云端一致环境出包，免本地 Xcode/Android Studio 差异；EAS Submit 上架流水线。

### 4. EAS Update（OTA）？

**答案：** 将 JS bundle 与 assets 上传到 Expo CDN，运行时按 runtime version/channel 拉取差分；灰度用 branch；回滚发布旧 manifest；注意原生变更仍需商店发版。

### 5. `FlatList` 性能参数？

**答案：** `getItemLayout` 跳过测量；`windowSize` 控制视窗外预渲染行数；`maxToRenderPerBatch`/`initialNumToRender` 平衡首屏与滚动；`keyExtractor` 稳定 key；避免匿名内联 `renderItem`。

### 6. Reanimated 与 Worklet？

**答案：** `'worklet'` 函数编译到 UI 线程执行，避免 JS 线程拥堵；`useSharedValue`+`useAnimatedStyle` 驱动 60fps 手势与布局动画。

### 7. 平台差异策略？

**答案：** `Platform.OS`/`Platform.select`；`*.ios.ts`/`*.android.ts` 后缀解析；原生模块抽象；设计 token 统一 UI。

### 8. WalletConnect v2 与 Deep Link？

**答案：** v2 基于 Pairing + Relay；RN 需配置 scheme/universal link，`Linking.addEventListener` 处理 `wc:`/`https://` 回调；注意冷启动与后台恢复时 session 恢复。

### 9. Metro vs Webpack/Vite？

**答案：** Metro 针对 RN 图打包、transform 管道、resolver 平台后缀；分包用 `require.context` 有限，常用 ram-bundle、Hermes 体积优化。

### 10. 冷启动优化与测量？

**答案：** Hermes、删冗余 polyfill、延迟非关键模块、`InteractionManager.runAfterInteractions`、图片预解码；用 Xcode Instruments / Android Profiler / `react-native-performance` 测 TTI。

### 11. Native Modules / Turbo Native Modules？

**答案：** 传统桥异步；Turbo 用 JSI 同步/类型化接口，Codegen 从 TS 规范生成 C++/Java/ObjC 绑定。

### 12. Expo Router vs React Navigation？

**答案：** Expo Router 基于文件系统路由，类 Next 体验；复杂自定义转场仍可用 React Navigation 底层。

### 13. JS / UI / Shadow 线程？

**答案：** JS 执行业务；Shadow（Yoga）算布局；UI 线程绘制。瓶颈常在 JS 与 Bridge（旧）或重布局；Profiler 查掉帧原因。

### 14. WebSocket 稳定性与后台？

**答案：** AppState 监听前后台，后台 iOS 易挂起 socket，需重连与幂等订阅；心跳+指数退避；消息队列合并渲染。

### 15. 调试工具链？

**答案：** Flipper（网络/布局）、React DevTools、Hermes Sampling Profiler、LogBox；新架构可用 Chrome DevTools for JSI 调试视情况。

---

## 七、Flutter / Dart

### 1. 三棵树职责？

**答案：** Widget 配置不可变；Element 持有 widget 与 renderObject、协调更新；RenderObject 负责布局绘制。Element 复用稳定身份，避免每次重建昂贵 render 树。

### 2. `StatefulWidget` 生命周期？

**答案：** `createState` → `initState` → `didChangeDependencies` → `build` → `didUpdateWidget` → `deactivate`（移出树）→ `dispose`。注意 `mounted` 检查异步回调。

### 3. `BuildContext` 与异步？

**答案：** `context` 绑定 Element 位置；`await` 后 widget 可能已卸载，应 `if (!context.mounted) return` 再 `Navigator.of(context)`。

### 4. `flutter_bloc` 核心？

**答案：** Event → Bloc 纯函数/异步 → emit 新 State；Cubit 无 Event 简版。相比 Provider：更强制单向数据流与可测试性。

### 5. Key 种类？

**答案：** `ValueKey`（值身份）、`ObjectKey`（对象身份）、`UniqueKey` 强制新 Element、`GlobalKey` 跨树访问 State/Size。列表缺 key 导致错误复用与状态错乱。

### 6. `Isolate` vs `compute`？

**答案：** `compute(fn, msg)` 封装一次性 isolate 开销；长驻任务用 `Isolate.spawn` + `ReceivePort`；避免在 isolate 直接用 `BuildContext`。

### 7. Sliver 与性能？

**答案：** Sliver 协议统一滚动视口，组合 `CustomScrollView` 避免嵌套滚动冲突；懒构建 viewport 外不布局，优于多层 `ListView` 嵌套。

### 8. `go_router` 与 Deep Link？

**答案：** 声明式 `GoRoute` 树 + redirect；`uni_links`/`app_links` 解析 OS 传入 URI 映射到路由。

### 9. `flutter_secure_storage`？

**答案：** iOS Keychain、Android Keystore 加密密钥材料；敏感数据不落明文 SharedPreferences；注意 Android 自动备份排除。

### 10. WalletConnect v2（Reown）会话？

**答案：** Pairing URI → approve session → pending requests 队列展示签名 → chainChanged/account 事件同步；Kill session 释放资源。

### 11. `RepaintBoundary`？

**答案：** 隔离重绘层，配合 `debugRepaintRainbowEnabled` 诊断过度重绘；用于复杂动画子树。

### 12. `InheritedWidget` 与 Provider？

**答案：** `InheritedWidget` 沿 Element 树 O(1) 查找最近祖先；Provider 在其上封装依赖注入与重建粒度控制。

### 13. BIP-39/32/44 简述？

**答案：** BIP-39 助记词→种子；BIP-32 HD 分层派生；BIP-44 路径 `m/purpose'/coin'/account'/change/index`。实现须用审计过的密码学库。

### 14. Hot Reload vs Restart？

**答案：** Reload 注入新代码保留状态，不改变 `main`/全局初始化；Restart 全量重启。enum/泛型改动等需 restart。

### 15. 列表与启动优化？

**答案：** `ListView.builder` 懒构建；`AutomaticKeepAliveClientMixin` 谨慎使用；首屏分批 `Future.microtask`；图片缓存；`compute` 做重解析。

### 16. Null Safety？

**答案：** 默认非空；`?` 可空、`!` 断言非空（危险）、`late` 延迟初始化（未赋值前读抛错）、`required` 命名参数必选。迁移后减少 NPE。

---

## 八、Web3 / 区块链

### 1. Ethers v5 vs v6 与三大抽象？

**答案：** v6 模块化 import、BigInt 原生、Provider API 更一致。Provider 读链；Signer 签名交易；Contract 封装 ABI 调用。

### 2. `approve` + `transferFrom` 与风险？

**答案：** 合约代扣需授权额度；无限 `approve` 遇恶意合约或钓鱼可转走资产。应最小授权（EIP-2612 permit）、定期 revoke、读 allowance。

### 3. `window.ethereum` 流程？

**答案：** `eth_requestAccounts` 取权限；`eth_sendTransaction`/`eth_signTypedData_v4` 走钱包弹窗；监听 `chainChanged`/`accountsChanged`。

### 4. WC v1 vs v2？

**答案：** v1 桥接简单已弃用；v2 多链、会话命名空间、Pairing topic、Relay 集群，更安全可扩展。

### 5. Gas 与 EIP-1559？

**答案：** `estimateGas` 预估执行用量；Base Fee 协议销毁、Priority Fee 给矿工/验证者；`maxFeePerGas` ≥ base+priority。

### 6. ABI 编码？

**答案：** 选择器 `keccak256(sig).slice(0,4)` + 参数 ABI 编码；`Interface.encodeFunctionData` 解码 `decodeResult`。

### 7. AMM vs 订单簿 / Bonding Curve？

**答案：** AMM 用池子曲线定价；订单簿为挂单撮合；Bonding Curve 以储备与曲线函数决定价格，常见于发射盘。

### 8. 永续与 PnL 展示？

**答案：** 保证金率、标记价格、资金费率周期结算；强平价格由风险引擎算；前端用 BigNumber 显示未实现盈亏并 WS 更新。

### 9. 跨链桥类型？

**答案：** Lock-Mint、Burn-Mint、原子交换（HTLC）；安全依赖验证层与多签/轻客户端。

### 10. Cosmos IBC `MsgTransfer`？

**答案：** 源链锁定/铸造 voucher，经 IBC packet 中继到目标链；需 channel/port 与 timeout；查询 packet ack/timeout 状态。

### 11. `WalletAdapter` 策略模式？

**答案：** 统一 `connect/sign/switchChain` 接口；每钱包一策略；新增钱包实现接口注册表，无需改业务代码。

### 12. Viem + Wagmi？

**答案：** Viem 类型安全、模块化以太坊原语；Wagmi React hooks 管理连接、缓存、多链，减轻样板代码。

### 13. 助记词安全存储？

**答案：** 移动端系统安全区；Web 避免长期存 localStorage；展示时截屏风控；生物识别 gating。

### 14. 交易追踪？

**答案：** `waitForTransactionReceipt` 轮询；`provider.on('block')` 或合约 `event` 过滤日志解析 Transfer。

### 15. 高精度数值？

**答案：** JS 双精度 IEEE754；金额用整数 wei + BigNumber/decimal 库，禁止直接 `Number` 运算。

### 16. Privy 统一登录？

**答案：** 嵌入式钱包 + OAuth 账号绑定同一 user id；服务端校验 JWT；降低 Web2 用户进入门槛。

---

## 九、AI / LLM 应用

### 1. RAG 与 Embedding？

**答案：** 检索相关文档片段注入上下文再生成；Embedding 将文本映射向量以语义相似检索（ANN）；缓解幻觉与知识时效。

### 2. Chunking 与 overlap？

**答案：** 固定长度、语义切分、Markdown 结构切；overlap 保留边界上下文减少切断语义；chunk 过大噪声多，过小丢上下文。

### 3. SSE vs WebSocket 与 `useSSE`？

**答案：** SSE 单向、HTTP/2 友好、自动重连简单，适合 token 流；WS 双向。前端 `EventSource` 或 `fetch`+ReadableStream 解析 `data:` 行，处理重连与 abort。

### 4. Function Calling？

**答案：** 模型输出 tool_calls JSON；宿主执行工具返回 tool_result；循环直到无工具调用。Schema 描述 name/params JSON Schema。

### 5. Prompt 技巧与 JSON？

**答案：** System 定角色与约束；Few-shot 给范例；CoT `let's think step by step` 提升推理。JSON：要求仅输出 fenced json + 失败重试/约束解码（视模型）。

### 6. Token 与上下文管理？

**答案：** Token 为子词单元；策略：截断尾部、摘要历史、滑动窗口、只保留 system+最近 k 轮+检索块。

### 7. LangChain 概念？

**答案：** Chain 组合步骤；Agent 动态选 tool；Memory 会话；Tool 外部能力。价值：编排可替换组件，注意版本与抽象泄漏。

### 8. 多模型降级？

**答案：** 超时/429 触发 fallback 链；统一 `LLMProvider` 接口记录 latency/cost；熔断与健康检查。

### 9. 向量库与相似度？

**答案：** 选型看延迟、过滤、混合检索、托管成本；余弦适合归一化向量；欧氏距离与 L2 归一化相关。

### 10. Agent 与 ReAct？

**答案：** Agent 循环：Thought→Action→Observation；并行 tool 执行需合并结果；与普通 chat 差在主动调用工具改变环境。

### 11. 流式渲染前端？

**答案：** 累积 assistant delta 渲染 Markdown；防抖排版；错误重连带 `Last-Event-ID`（若服务端支持）；背压时合并 token。

### 12. NestJS AI 模块划分？

**答案：** `LlmModule`（provider 切换）、`RagModule`（ingest/query）、`AgentModule`（tool registry+executor）；通过 DI 注入接口便于单测。

### 13. RAG 评估与优化？

**答案：** 指标：召回@k、答案相关性、引用准确率；优化：混合检索、rerank、query 改写、元数据过滤、清洗 PDF。

### 14. 安全与 Prompt Injection？

**答案：** 特权指令与用户输入隔离、输出过滤、工具侧鉴权、最小权限、不可信文本不进入 system、检测越狱模式。

### 15. AI + ECharts？

**答案：** 约束模型输出固定 JSON schema（series/xAxis/data）；前端 zod 校验后 `setOption`；失败回退模板或重新请求修复 JSON。

---

## 十、Node.js / NestJS

### 1. 事件循环阶段与 `nextTick`？

**答案：** timers → pending → idle/prepare → poll → check → close；`nextTick` 微任务队列优先于其他微任务；`Promise.then` 在微任务阶段。

### 2. Nest 模块与 DI？

**答案：** `@Module` 声明 providers/imports/controllers；构造器注入 token（class/interface+`@Inject`）；IoC 容器解析依赖图单例默认。

### 3. 中间件 / Guard / Interceptor / Pipe / Filter 顺序？

**答案：** 入站：Middleware → Guard → Interceptor(before) → Pipe → Controller → Interceptor(after) → Exception Filter；理解顺序排权限与日志。

### 4. Stream 与背压？

**答案：** Readable/Writable/Duplex/Transform；`pipe` 自动处理 `highWaterMark`；手动 `write` 需检查 `drain` 事件避免内存暴涨。

### 5. Express / Koa / Nest？

**答案：** Express 中间件线性；Koa 洋葱模型 `ctx`；Nest 提供模块化与装饰器、可插拔底层（Express/Fastify）。

### 6. Nest SSE？

**答案：** `@Sse()` 返回 `Observable<MessageEvent>`；或 `@Header('Content-Type','text/event-stream')` + stream；注意连接断开取消订阅。

### 7. Cluster vs Worker Threads？

**答案：** Cluster 多进程共享端口 fork CPU 核；Worker Threads 共享内存适合 CPU 密集；I/O 密集用 async 即可。

### 8. `LLMProvider` 抽象？

**答案：** `interface LLM { completeStream(prompt,opts): AsyncIterable<string> }`；各厂商 adapter 实现；配置驱动切换。

### 9. 内存泄漏诊断？

**答案：** 全局缓存无限增长、未移除监听器、闭包持有大对象；`node --inspect` + Chrome Memory 快照对比堆。

### 10. 自定义装饰器？

**答案：** `createParamDecorator((data, ctx) => ctx.switchToHttp().getRequest().user)` 取当前用户。

### 11. GraphQL vs REST 与 Nest？

**答案：** GraphQL 强类型聚合查询、N+1 需注意 DataLoader；Nest `@Resolver` Code First 用 TS 类生成 schema。

### 12. 大文件分片上传？

**答案：** `multipart` 接收 chunk + index + fileId；落盘临时目录；merge 校验 hash；断点续传记录已传分片。

### 13. JWT vs Session？

**答案：** JWT 无状态可跨域；Session 服务端撤销即时；Nest `Passport` + `JwtStrategy` 校验 `Authorization`。

### 14. Buffer 与 TypedArray？

**答案：** Buffer 是 Uint8Array 子类 Node 扩展；二进制协议、图片处理注意编码与拷贝成本。

### 15. AI 服务分层与 DI？

**答案：** 每域 Module 导出 Service；Shared `CoreModule` 提供全局配置；接口 token 绑定实现便于 mock 与替换。

---

## 十一、工程化 / Monorepo / 性能

### 1. Monorepo vs Multirepo？

**答案：** Mono：统一工具链、原子重构、共享组件；缺点 CI 复杂、权限边界需设计。适合多应用强耦合团队。

### 2. `pnpm` 原理？

**答案：** 全局 content-addressable store + 硬链接，依赖去重；非扁平 node_modules 防幽灵依赖；workspace 协议 `workspace:*`。

### 3. Turborepo？

**答案：** `pipeline` 定义任务 DAG；本地+远程缓存 hash 输入输出；远程缓存加速 CI。`dependsOn: ["^build"]` 拓扑执行。

### 4. Vite 快的原因？

**答案：** 开发态原生 ESM + esbuild 转译依赖预构建；生产仍 rollup 做 tree-shaking 与兼容目标。

### 5. Tree Shaking？

**答案：** ESM 静态结构可分析；`sideEffects:false` 标记包可安全剔除未引用文件；注意 re-export 模式。

### 6. Code Splitting？

**答案：** 路由级、组件级动态 `import()`；分析 bundle 体积与缓存命中率；避免过度碎片导致请求风暴。

### 7. 虚拟列表？

**答案：** 只测量渲染视口内项；不定高需缓存已测高度或二分探测；滚动时复用 DOM。

### 8. `rAF` 节流？

**答案：** 与显示器刷新对齐合并多次数据更新；`setTimeout(16)` 不同步易抖动；行情 tick 合并一帧一次 DOM。

### 9. Worker 与大文件上传？

**答案：** Worker 中切片、SparkMD5，主线程只做进度条； transferable ArrayBuffer 减少拷贝。

### 10. 首屏优化？

**答案：** 网络：HTTP2/3、压缩、CDN；资源：关键 CSS、字体子集、图片现代格式；渲染：SSR/静态、hydration 减负、减少主线程长任务。

### 11. CDN externals 风险？

**答案：** 可用性与 SRI 完整性；版本锁定；开发离线失败；考虑自托管或 vendor chunk。

### 12. ESLint + Husky？

**答案：** `lint-staged` 仅检查暂存文件加速；CI 再全量；避免规则和 Prettier 冲突用 `eslint-config-prettier`。

### 13. Changeset？

**答案：** 开发者写 changeset 描述变更；`changeset version`  bump 包版本与 CHANGELOG；`publish` 按依赖图发包。

### 14. Docker 多阶段？

**答案：** 阶段1安装构建；阶段2仅复制 `dist`+prod deps，减小攻击面与镜像体积。

### 15. GitHub Actions 多环境？

**答案：** `workflow_dispatch`/`environment` secrets；分支策略 main→staging→prod；缓存 pnpm store 加速。

### 16. WS 重连与心跳？

**答案：** 指数退避 `min(cap, base*2^n)+jitter`；心跳检测死连接与 NAT；缓冲队列合并 UI 更新防掉帧。

---

## 十二、WebSocket / 实时通信

### 1. 握手与对比长轮询/SSE？

**答案：** HTTP Upgrade: websocket + Sec-WebSocket-Accept；全双工低延迟。长轮询实现简单延迟高；SSE 单向服务器推送。

### 2. 帧类型？

**答案：** 文本/二进制/关闭/ping/pong/延续帧；ping/pong 保活由协议层或应用层实现。

### 3. 指数退避实现？

**答案：** `delay = min(maxDelay, base * 2**attempt) + random()`；成功复位 attempt；超限进入离线模式。

### 4. 心跳必要性？

**答案：** 检测半开连接、穿透 NAT/代理超时；间隔略小于网关 idle（如 30s）。

### 5. 万级消息/秒前端？

**答案：** 业务队列+`rAF` 批渲染；只维护订单簿增量 diff；WebWorker 预处理；避免每条消息 setState。

### 6. 订阅模型？

**答案：** `subscribe(channel)` 映射回调；退订发送 `unsubscribe` 释放服务端资源；切频道先 unsub 再 sub。

### 7. 断线一致性？

**答案：** 重连后 `snapshot + seq` 对齐；缺口用 REST 补历史；幂等处理重复包。

### 8. 背压与降级？

**答案：** 检测队列长度超阈丢弃非关键 tick、提高聚合粒度、提示用户网络不佳。

### 9. Socket.IO？

**答案：** 自动降级 polling；房间广播抽象；协议自带心跳；注意与原生 WS 不兼容需客户端匹配。

### 10. React/Vue 生命周期？

**答案：** 单例 service 或在 `onMounted` 建立、`onUnmounted` close+移除监听；`useEffect` cleanup 必须返回关闭函数。

### 11. WSS 与鉴权？

**答案：** TLS 加密；首包 query token 或连接后 auth 消息；token 短期+刷新；避免把密钥放 URL 日志。

### 12. 序列化优化？

**答案：** 二进制 MessagePack/Protobuf 减小带宽与解析成本；兼容性与调试权衡。

### 13. TradingView Datafeed？

**答案：** `onReady`→`resolveSymbol`→`getBars` 历史；`subscribeBars` 推送实时；`unsubscribeBars` 释放；统一时间与时区。

### 14. 移动端 WS？

**答案：** 后台挂起断开；AppState 重连；省电模式降频；注意 iOS BG 限制。

### 15. 可复用通信层？

**答案：** 类 `EventEmitter` 分发 `message`；中间件链（日志、重连、鉴权）；与 UI store 解耦。

---
