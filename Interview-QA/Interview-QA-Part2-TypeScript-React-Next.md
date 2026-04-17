## 二、TypeScript

### 1. `type` 与 `interface` 的区别？何时更推荐哪个？声明合并差异？

**答案：** `interface` 可同名合并（Declaration Merging），适合描述可扩展的公共 API、类实现（`implements`）与面向对象形状；`type` 不可合并同名，但可表达联合、交叉、映射、条件类型等更丰富的类型运算。对外 SDK 或库类型常用 `interface` 便于用户扩展；复杂工具类型、联合字面量、元组优先 `type`。合并：`interface A { x: number }` + `interface A { y: string }` 等价于 `{ x: number; y: string }`；`type` 重复定义会报错。

### 2. 结构化类型 vs 名义类型？

**答案：** TS 是结构化（duck typing）：只要结构兼容即可赋值；Java/C# 多为名义：需显式继承/实现关系。影响：更灵活但易误把“碰巧同形”的类型混用；可通过 `brand` 技巧模拟名义类型：`type UserId = number & { __brand: 'UserId' }`。

### 3. `unknown` / `any` / `never`？

**答案：** `any` 关闭检查；`unknown` 表示未知类型，使用前必须收窄（`typeof`、`instanceof`、类型守卫）。`never` 为底类型：不可达分支、穷尽检查、抛错函数返回类型。推荐用 `unknown` 承接外部数据。

### 4. 条件类型与手写 `DeepPartial<T>`？

**答案：** `T extends U ? X : Y` 在类型级分支。`DeepPartial`：

```ts
type DeepPartial<T> = T extends (...args: infer A) => infer R
  ? T
  : T extends object
    ? { [K in keyof T]?: DeepPartial<T[K]> }
    : T
```

### 5. `infer` 与提取函数返回值？

**答案：** `infer` 在条件类型中由编译器推断占位类型。

```ts
type ReturnType<T> = T extends (...args: any[]) => infer R ? R : never
```

### 6. 协变/逆变与 `strictFunctionTypes`？

**答案：** 返回值位置协变（子类型可替换父类型）；参数位置逆变（更宽参数不能接受更窄实现）。`strictFunctionTypes` 对函数参数采用更严格检查，减少将 `(Animal)=>void` 误赋给 `(Dog)=>void` 的不安全赋值。

### 7. 映射类型与 `Readonly<T>`、`-readonly`、`-?`？

**答案：** `[K in keyof T]` 遍历键生成新对象类型。`Readonly<T> = { readonly [K in keyof T]: T[K] }`。`-readonly`、`-?` 为映射修饰符移除，用于 `Mutable<T>` 等工具类型。

### 8. 模板字面量类型与路由类型安全？

**答案：** 用模板字面量拼接合法路径字面量联合，使 `fetch(\`/api/${path}\`)` 的 `path` 被约束为 `'users' | 'orders'` 等，避免拼错 URL。

### 9. `enum` 的坑与 `const enum`？

**答案：** 数字 enum 反向映射、运行时生成对象、与 tree-shaking 不友好。`const enum` 编译期内联，无运行时对象但调试与 `isolatedModules` 场景可能有问题。常用 `as const` + 联合类型替代。

### 10. `declare module` 与第三方 `.d.ts`？

**答案：** `declare module 'pkg' { export function foo(): void }` 为无类型的包补声明；或 `declare module '*.svg'` 声明资源模块。配合 `paths` 做路径映射。

### 11. 类型收窄与 `is` 谓词？

**答案：** `typeof`、`in`、`instanceof`、可辨识联合的 `tag`、`switch` 穷尽、`if (x)` 等。`function isFish(p: Pet): p is Fish { return (p as Fish).swim !== undefined }` 让后续分支获得精确类型。

### 12. OpenAPI 生成 TS 与 genapi 思路？

**答案：** 解析 Swagger/OpenJSON → AST → 生成 `types`（interface）与 `client`（按 operationId 生成函数）。价值：前后端契约一致、减少手写。`genapi` 类工具多为模板 + OpenAPI 规范遍历。

### 13. `satisfies` vs `as`？

**答案：** `satisfies` 校验表达式满足某类型又保留字面量窄化；`as` 断言跳过检查易不安全。配置对象、路由表优先 `satisfies`。

### 14. 泛型约束设计类型安全 EventBus？

**答案：** `type Events = { open: { id: string }; close: void }; class Bus<E> { on<K extends keyof E>(k: K, fn: (p: E[K])=>void){} emit<K extends keyof E>(k: K, p: E[K]){} }`，键与载荷一一对应。

### 15. Project References 与 `composite`？

**答案：** `references` 将 monorepo 包拆成独立 TS 项目，增量构建只编译变更子图；`composite: true` 要求 `declaration` 等，生成 `.tsbuildinfo` 加速 `tsc --build`。

### 16. 手写 `Pick` / `Partial` / `Record`？

**答案：**

```ts
type Pick<T, K extends keyof T> = { [P in K]: T[P] }
type Partial<T> = { [P in keyof T]?: T[P] }
type Record<K extends keyof any, V> = { [P in K]: V }
```

---

## 三、React

### 1. Fiber 解决的问题、节点结构、时间切片？

**答案：** Fiber 将递归渲染改为可中断链表遍历，支持优先级调度与并发特性。Fiber 节点含 `child/sibling/return`、`memoizedState`、`pendingProps` 等。时间切片：在浏览器空闲（`MessageChannel`/Scheduler）分批提交工作，避免长任务阻塞主线程。

### 2. Diff 三策略与 `key`？

**答案：** 同层比较、类型不同则整子树替换、列表用 key 标识身份。`index` 作 key 在重排/插入时导致错误复用 DOM 与状态错位，应使用稳定业务 id。

### 3. `useState` 同步性、React 18 Batching、`flushSync`？

**答案：** 18 前更新异步批处理；18 默认更多场景自动批处理（含 Promise/setTimeout）。`flushSync` 强制同步刷 DOM，用于测量布局或第三方 imperative API 需立即生效时。

### 4. `useEffect` 生命周期与为何不能 `async`？

**答案：** mount → 执行 effect → unmount 前 cleanup → 依赖变更先 cleanup 再执行。`async effect` 返回 Promise 非“清理函数”，易误用；应在 effect 内写 async IIFE 并配合取消标记/AbortController。

### 5. `useMemo` / `useCallback` 与何时需要？

**答案：** 缓存计算结果与函数引用。官方：默认不必优化；当子组件 `memo` 且 props 为引用相等敏感、或昂贵纯计算时再使用，配合 Profiler 验证。

### 6. `useTransition` / `useDeferredValue` / `startTransition`？

**答案：** 标记非紧急更新，让高优先级输入保持流畅；`useDeferredValue` 延迟渲染某 props 的滞后版本，适合大列表/重搜索场景。

### 7. Context 性能与优化？

**答案：** `value` 引用变化会使所有消费者重渲染。拆 Context、按域拆分、`useMemo` 稳定 value、组合 `zustand`/外部 store，或 selector 模式（如 `use-context-selector`）。

### 8. `useRef` 高级用法？

**答案：** 保存可变值（定时器 id、上一次的 props、渲染计数）不触发重渲染；与 `forwardRef` 暴露 DOM；注意 ref 变化不触发 effect。

### 9. 合成事件与 React 17 变化？

**答案：** 统一封装跨浏览器差异、池化（17+ 已调整）。17 起事件委托挂载到 root 容器而非 `document`，利于多根与微前端。

### 10. RTK `createSlice` / `createAsyncThunk` / RTK Query？

**答案：** Slice 合并 reducer+actions；Thunk 处理异步标准模式；RTK Query 管理缓存、去重、失效、乐观更新，减少手写数据同步代码。

### 11. Error Boundary 与 Hooks？

**答案：** 类组件 `getDerivedStateFromError`/`componentDidCatch` 捕获子树渲染错误；函数组件暂无等价官方 API；可用 `react-error-boundary` 封装或边界组件包一层。

### 12. `useLayoutEffect` vs `useEffect`？

**答案：** `useLayoutEffect` 在浏览器 paint 前同步执行，适合读布局并同步写 DOM（测量、避免闪烁）；SSR 需注意：服务端用 `useEffect` 替代或跳过。

### 13. RSC 与 `"use client"`？

**答案：** RSC 默认在服务端运行、可直连 DB、零客户端 JS；需交互/DOM/hooks 的模块标 `"use client"` 成为 Client 边界。数据获取：Server 用 async Server Component；Client 用 `useEffect`/SWR 等。

### 14. Zustand 管跨链状态 vs Redux？

**答案：** Zustand 小 API、无需 Provider 包裹也可用、按 selector 订阅细粒度更新；适合桥接场景多模块（wallet/transfer/bridge）。Redux 更强约束与 DevTools 生态，样板更多。

### 15. Hydration 与 Mismatch？

**答案：** 服务端 HTML 与客户端首帧虚拟 DOM 不一致。常见原因：`Date.now()`、随机数、`window`、本地化格式、浏览器扩展改 DOM。修复：可疑值延后到 `useEffect`、suppress 仅作最后手段。

### 16. `memo` / `PureComponent` / `shouldComponentUpdate`？

**答案：** 均为浅比较避免重渲染；类 `PureComponent` 默认浅比较 props/state；`memo` 为函数组件包装；浅比较对深层对象变化不敏感，需不可变更新或自定义比较函数。

---

## 四、Next.js

### 1. App Router vs Pages Router？

**答案：** App Router 以 RSC 为一等公民、嵌套 layout、`loading.tsx` 流式、更细缓存语义；Pages 以页面为单位的 `getServerSideProps` 等。官方长期重心在 App Router。

### 2. SSR / SSG / ISR？

**答案：** SSR 每请求服务端渲染；SSG 构建时生成静态 HTML；ISR 静态 + 按 `revalidate` 后台再生成。权衡：新鲜度 vs 成本与 TTFB。

### 3. Server Components 默认与 `"use client"`？

**答案：** 默认 Server；需状态、事件、浏览器 API 时标客户端。Server 可直接 `await fetch`（带缓存语义）；Client 用 hooks 请求。

### 4. `generateStaticParams`？

**答案：** 为动态段预生成静态路径，如 `posts/[id]` 返回 `[{id:'1'},{id:'2'}]`，构建期生成页面。

### 5. Middleware 运行环境与限制？

**答案：** Edge Runtime 优先（轻量、低延迟）；可做鉴权重写重定向；不适合重 Node API、长 CPU、全量 DB 连接池场景。

### 6. App Router 中扩展的 `fetch` 与缓存？

**答案：** `fetch(url,{cache:'force-cache'|'no-store', next:{revalidate:60, tags:['x']}})` 与 Data Cache 集成；`revalidateTag` 按需失效。

### 7. `loading` / `error` / `not-found` 与 Streaming？

**答案：** `loading.tsx` 触发 Suspense 边界流式输出骨架；`error.tsx` 捕获子树错误边界；`not-found` 处理 404。

### 8. Server Actions 与安全？

**答案：** 服务端可调用的异步函数，经编译生成端点；需校验 session、校验输入、防 CSRF（框架 token）、限权。优势：少写 HTTP 胶水、类型直达。

### 9. `next/image`？

**答案：** 自动 srcset、懒加载、`priority` 控制 LCP 图、`placeholder="blur"`、`sizes` 响应式选型，减少 CLS。

### 10. Route Groups 与 Parallel Routes？

**答案：** `(marketing)` 分组不参与 URL；`@slot` 并行插槽适合 Dashboard 多面板独立加载/错误隔离。

### 11. `next/dynamic` vs `React.lazy`？

**答案：** `next/dynamic` 支持 `ssr:false`、加载占位；SSR 下注意客户端-only 模块用 dynamic+ssr false 避免服务端引用浏览器 API。

### 12. 缓存层级？

**答案：** 请求级 memo → fetch Data Cache → Full Route Cache（静态 RSC 结果）→ Router Cache（客户端软导航缓存）。理解顺序有助于排障“为何没更新”。

### 13. App Router i18n？

**答案：** 常用 `[locale]` 动态段 + middleware 检测 `Accept-Language` 重定向；或 `next-intl` 等库管理消息与路由。

### 14. Vercel 部署 vs 自托管 ISR？

**答案：** Vercel 对 ISR/on-demand revalidate 集成好；自托管需配置持久缓存与再验证队列（如 OSS+Redis），否则行为与边缘不一致。

### 15. `metadata` / `generateMetadata`？

**答案：** 导出静态 `metadata` 或异步 `generateMetadata({params})` 动态 SEO；避免泄露敏感数据；与 RSC 数据合并生成 title/description/OG。

---
