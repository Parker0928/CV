## 二、React

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

