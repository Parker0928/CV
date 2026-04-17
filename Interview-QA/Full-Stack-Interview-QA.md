# 全栈高频面试题与答案

> 基于仓库根目录 `README.md` 技术栈整理：Vue / React 对照、Vue3、React、TypeScript、Next.js、React Native + Expo、Flutter、Web3、AI/LLM、Node/NestJS、工程化与 WebSocket。

## 目录

- [一、Vue 与 React：对照与选型](#一vue-与-react对照与选型)
- [二、Vue3](#二vue3)
- [三、React](#三react)
- [四、TypeScript](#四typescript)
- [五、Next.js](#五nextjs)
- [六、React Native + Expo](#六react-native--expo)
- [七、Flutter / Dart](#七flutter--dart)
- [八、Web3 / 区块链](#八web3--区块链)
- [九、AI / LLM 应用](#九ai--llm-应用)
- [十、Node.js / NestJS](#十nodejs--nestjs)
- [十一、工程化 / Monorepo / 性能](#十一工程化--monorepo--性能)
- [十二、WebSocket / 实时通信](#十二websocket--实时通信)

---

## 一、Vue 与 React：对照与选型

> 与下文的「Vue3 深度」「React 深度」并列：本章侧重**并排对比**与**技术选型话术**，面试中常被问「两个都用过，你怎么选」。

### 1. 总体编程模型有什么本质不同？

**答案：** Vue 以**单文件组件 + 模板**为主流，HTML 结构更接近设计稿，指令（`v-if` / `v-for`）在模板层表达 UI 分支与列表；React 以 **JSX 即 JavaScript 表达式**描述 UI，分支与列表都是 `{}` 里的逻辑。选型：偏设计还原与模板可读性 → Vue；偏逻辑与类型全在 TS/JS 一体 → React。

### 2. 响应式哲学：Vue 的「依赖追踪」vs React 的「显式 setState」？

**答案：** Vue3 用 Proxy **自动追踪**渲染函数里读到的数据，mutable 源数据 + 细粒度更新；React 默认 **不可变数据 + 全量协调（Fiber）**，通过 `setState`/`useReducer` 触发调度。对比：Vue 少写「依赖数组」心智负担；React 数据流更「显式」，与 time-travel、并发特性结合紧。注意：React 也有 MobX 等类 Vue 模型，但生态主路径仍是 hooks。

### 3. `ref`/`reactive` 和 `useState`/`useRef` 分别解决什么？能否类比？

**答案：** `ref` 是单值响应式容器（`.value`），`reactive` 包装对象；`useState` 是**触发重渲染的状态槽**，`useRef` 是**跨渲染可变槽且不触发渲染**。类比：`ref` 更接近 `useState` 的一个值；`reactive` 无直接等价，常拆成多个 `useState` 或 `useReducer`。面试点：「为什么 React 里修改对象属性不触发更新」→ 引用未变。

### 4. `computed` 和 `useMemo` 的相同点与不同点？

**答案：** 都做**派生值缓存**。Vue `computed` 默认 lazy + 自动依赖收集；React `useMemo(fn, deps)` **依赖需手写**，漏写则 stale。对比：Vue 省 deps；React 更可控但易错。性能：两者都应只在昂贵计算或稳定引用时使用。

### 5. `watch`/`watchEffect` 和 `useEffect` 如何对照理解？

**答案：** `watch` 显式源 + 可选 lazy；`watchEffect` 自动收集依赖，接近「每次渲染后跑副作用」但更偏响应式管道。`useEffect` 是**提交阶段后**的副作用，依赖数组等价于「告诉 React 哪些外部同步」。对比：`useEffect` 必须考虑「组件视图已提交」；Vue 的 `watch` 更贴近「数据变了做什么」，与 `flush` 时机（pre/post/sync）组合使用。

### 6. 组件通信：Vue 的 props/emit/provide 与 React 的 props/context？

**答案：** 父子：二者都是 props 向下、回调向上（emit vs callback props）。跨层级：Vue `provide/inject` 常配合 `readonly`；React `Context` + `useContext`，需注意 **Context value 变化导致大范围重渲染**，常拆 context 或用外部 store（Zustand/Jotai）。面试：对比「Vue 更省样板」vs「React context 性能坑与治理」。

### 7. 列表渲染与 `key`：两边理念一致吗？

**答案：** 一致：**稳定 key 标识身份**，避免错误复用 DOM/组件实例。Vue `v-for :key`；React `key` prop。反面教材都是「用 index 作 key」在重排插入时出问题。可补充：Vue2 曾用 key 区分组件类型，Vue3/React18 的 diff 都对静态提升/并发有优化，但 key 语义不变。

### 8. 逻辑复用：Composables 与 Custom Hooks 有什么异同？

**答案：** 二者都是**无渲染逻辑复用**：Vue `useXxx()` 返回 refs/methods；React `useXxx()` 返回 state/setter。差异：Hooks **调用顺序与规则**（不能条件调用）是硬性约束；Vue composable 更自由但仍建议一致返回结构。对比 mixin：两边都可用组合替代 mixin（Vue3 官方推 composable）。

### 9. 状态管理生态：Pinia vs Redux Toolkit / Zustand？

**答案：** Pinia：模块 store、DevTools、无 mutation 样板也可；RTK：单向数据流 + `createSlice` 标准化；Zustand：最小 API、细粒度订阅。面试话术：**业务复杂度与团队规范**决定；跨框架 Monorepo 可能偏向更中立的 Zustand/Jotai。

### 10. 路由：vue-router 与 React Router / Next 路由？

**答案：** vue-router：动态路由、`navigation guard`、keep-alive 一体化；React Router：声明式嵌套路由；Next App Router：**文件系统路由 + RSC 默认**。选型：后台 SPA 常 vue-router；内容站/全栈 Next；纯 CSR React 用 RR。

### 11. 样式方案对比：scoped CSS / CSS Modules vs CSS-in-JS？

**答案：** Vue 常见 `scoped` + 深度选择器；React 常见 CSS Modules、Tailwind、Styled-components。面试点：**样式隔离、SSR、FOUC、包体积**；Vue SFC 单文件集成度高；CSS-in-JS 运行时成本需权衡。

### 12. 表单：Vue `v-model` 与 React 受控组件？

**答案：** `v-model` 是语法糖（`modelValue` + `update:modelValue`）；React 手写 `value` + `onChange`。对比：Vue 少样板；React 显式适合复杂合成事件与跨平台（RN）。

### 13. SSR / SSG：Nuxt 与 Next 如何一句话对比？

**答案：** 都是元框架：**约定路由、数据获取、混合渲染**。Nuxt 偏 Vue 生态；Next 当前以 RSC、缓存语义为卖点。简历场景：「移动端 RN/Expo + Web Next」vs「中后台 Vue + Nuxt」可各举一条项目经验。

### 14. TypeScript 体验：`<script setup lang="ts">` vs TSX？

**答案：** Vue SFC 模板与脚本分离，类型在 `defineProps` 泛型、`Props` 接口清晰；TSX 全在类型系统里，组件即函数，**库作者更友好**。对比：大型表单页 Vue 模板可读性；设计系统/Headless UI TSX 组合灵活。

### 15. 性能优化「口诀级」对照？

**答案：** Vue：`v-once`、`v-memo`、异步组件、`shallowRef`、虚拟列表；React：`memo`、`useMemo/useCallback`（慎用）、并发特性、`React.lazy`。共同点：**测了再优化**、列表虚拟化、减少无关重渲染、拆包与资源优先级。

### 16. 若团队只能选一个，你的选型依据？

**答案：** 从**团队栈、招聘、现有资产、交付形态**回答即可：例如中后台组件库已是 Element Plus → Vue；新站要 SEO+RSC → Next；跨端与 RN 共享思维 → React；维护成本与「官方推荐路径」一致性。避免宗教战争，强调**业务与协作**。

---

## 二、Vue3

### 1. Vue3 的响应式系统从 Object.defineProperty 切换到 Proxy 有哪些本质区别？Proxy 能解决哪些 Vue2 无法解决的问题？

**答案：**

**本质区别在于拦截的粒度和方式不同：**

| 维度 | Object.defineProperty (Vue2) | Proxy (Vue3) |
|------|------------------------------|--------------|
| 拦截层级 | 属性级别，需逐个遍历 | 对象级别，一次代理整个对象 |
| 新增/删除属性 | 无法检测，需 `$set` / `$delete` | 天然支持，通过 `has`、`deleteProperty` trap |
| 数组索引赋值 | 无法检测 `arr[index] = val` | 天然支持 |
| 数组长度修改 | 无法检测 `arr.length = 0` | 天然支持 |
| 性能 | 初始化递归遍历全部属性，开销大 | 惰性代理（lazy），访问时才递归 |
| Map/Set/WeakMap | 不支持 | 通过自定义 trap 支持 |

**Vue2 的核心痛点：**

```javascript
// Vue2 无法检测以下操作
this.obj.newKey = 'value'       // 新增属性 → 不触发更新
delete this.obj.existingKey     // 删除属性 → 不触发更新
this.arr[0] = 'newValue'        // 数组索引赋值 → 不触发更新
this.arr.length = 0             // 修改数组长度 → 不触发更新

// 必须使用特殊 API
this.$set(this.obj, 'newKey', 'value')
this.$delete(this.obj, 'existingKey')
```

**Proxy 的实现核心：**

```javascript
function reactive(target) {
  return new Proxy(target, {
    get(target, key, receiver) {
      const res = Reflect.get(target, key, receiver)
      track(target, key) // 依赖收集
      // 惰性递归：只有访问到嵌套对象时才递归代理
      if (isObject(res)) {
        return reactive(res)
      }
      return res
    },
    set(target, key, value, receiver) {
      const oldValue = target[key]
      const result = Reflect.set(target, key, value, receiver)
      if (hasChanged(value, oldValue)) {
        trigger(target, key) // 触发更新
      }
      return result
    },
    deleteProperty(target, key) {
      const hadKey = hasOwn(target, key)
      const result = Reflect.deleteProperty(target, key)
      if (hadKey && result) {
        trigger(target, key) // 删除也能触发
      }
      return result
    },
    has(target, key) {
      track(target, key)
      return Reflect.has(target, key)
    },
    ownKeys(target) {
      track(target, ITERATE_KEY) // for...in 遍历也能追踪
      return Reflect.ownKeys(target)
    }
  })
}
```

**关键优势总结：**

1. **惰性代理**：Vue2 在初始化时递归遍历整个对象树做 `defineProperty`，Vue3 只在 `get` 时才递归，大幅减少初始化开销
2. **完整拦截**：13 种 trap 覆盖几乎所有对象操作（get/set/delete/has/ownKeys 等）
3. **集合类型支持**：Map/Set/WeakMap/WeakSet 通过自定义 handler 实现响应式
4. **`Reflect` 配合**：使用 `Reflect` 保证正确的 `this` 指向和原型链行为，`receiver` 参数确保继承场景下的正确性

---

### 2. ref 和 reactive 的底层实现有何不同？为什么 reactive 不能直接用于基本类型？ref 的 .value 设计出于什么考虑？

**答案：**

**底层实现差异：**

`reactive` 基于 `Proxy` 实现，返回原始对象的代理对象：

```javascript
// reactive 简化实现
function reactive(target) {
  if (!isObject(target)) {
    // 基本类型直接返回，不做代理
    console.warn(`value cannot be made reactive: ${String(target)}`)
    return target
  }
  return createReactiveObject(target, mutableHandlers, mutableCollectionHandlers)
}
```

`ref` 基于 class 的 getter/setter 实现，内部包装一个 `RefImpl` 对象：

```javascript
// ref 简化实现
class RefImpl<T> {
  private _value: T
  private _rawValue: T
  public dep: Dep = new Dep()
  public readonly __v_isRef = true

  constructor(value: T, isShallow: boolean) {
    this._rawValue = isShallow ? value : toRaw(value)
    // 如果是对象，内部会调用 reactive 处理
    this._value = isShallow ? value : toReactive(value)
  }

  get value() {
    this.dep.track() // 依赖收集
    return this._value
  }

  set value(newVal) {
    newVal = this.__v_isShallow ? newVal : toRaw(newVal)
    if (hasChanged(newVal, this._rawValue)) {
      this._rawValue = newVal
      this._value = this.__v_isShallow ? newVal : toReactive(newVal)
      this.dep.trigger() // 触发更新
    }
  }
}
```

**为什么 reactive 不能用于基本类型：**

`Proxy` 只能代理对象（Object），JavaScript 的基本类型（`string`/`number`/`boolean`/`null`/`undefined`/`symbol`/`bigint`）不是对象，无法被 `Proxy` 拦截。这是语言层面的限制，不是框架设计选择。

**`.value` 设计的深层考量：**

1. **保持引用稳定性**：基本类型是值传递，赋值意味着创建新值。`.value` 提供了一个稳定的"容器"，使得函数参数传递和解构时不丢失响应性：

```javascript
// 如果没有 .value，传递后就断开了响应链
function useCounter() {
  let count = reactive(0) // 假设能这样做
  function increment() {
    count++ // 这是重新赋值，外部引用不会更新
  }
  return { count, increment }
}

// 有了 .value，容器引用不变
function useCounter() {
  const count = ref(0)
  function increment() {
    count.value++ // 修改容器内的值，所有引用者都能感知
  }
  return { count, increment }
}
```

2. **统一的响应式入口**：ref 可以包装任何类型（基本类型 + 对象），当包装对象时内部自动调用 `reactive`，提供统一的使用范式

3. **显式的副作用标记**：`.value` 是一种"有意识的响应式访问"，让开发者清楚知道正在操作响应式数据（template 中自动解包是编译器语法糖）

4. **可序列化和可调试**：`ref` 对象有 `__v_isRef` 标记，方便 Vue Devtools 识别和序列化

---

### 3. Vue3 的 Composition API 相比 Options API 在逻辑复用上有何优势？请从 mixins 的痛点出发对比说明。

**答案：**

**Mixins 的三大致命痛点：**

**痛点一：命名冲突（Namespace Collision）**

```javascript
// mixinA.js
export default {
  data() {
    return { loading: false, error: null }
  },
  methods: {
    fetch() { /* ... */ }
  }
}

// mixinB.js
export default {
  data() {
    return { loading: false } // 与 mixinA 冲突！
  },
  methods: {
    fetch() { /* ... */ } // 与 mixinA 冲突！
  }
}

// 组件中使用
export default {
  mixins: [mixinA, mixinB], // loading 和 fetch 到底用谁的？
}
```

Mixin 的合并策略（data 合并、methods 后覆盖前）是隐式的，随着项目规模增长，冲突变得不可预测。

**痛点二：来源不透明（Implicit Dependencies）**

```javascript
export default {
  mixins: [authMixin, analyticsMixin, validationMixin],
  methods: {
    submit() {
      // this.isAuthenticated → 来自哪个 mixin？
      // this.validate() → 来自哪个 mixin？
      // this.trackEvent() → 来自哪个 mixin？
      // 完全无法从当前文件判断
    }
  }
}
```

**痛点三：无法灵活传参和组合**

```javascript
// mixin 无法接收参数来定制行为
const paginationMixin = {
  data() {
    return { page: 1, pageSize: 10 } // 无法配置 pageSize
  }
}
```

**Composition API 如何解决：**

**解决命名冲突 → 显式命名空间**

```typescript
// useAuth.ts
export function useAuth() {
  const loading = ref(false)
  const error = ref<string | null>(null)
  async function login(credentials: Credentials) { /* ... */ }
  return { loading, error, login }
}

// useAnalytics.ts
export function useAnalytics() {
  const loading = ref(false)
  function trackEvent(event: string) { /* ... */ }
  return { loading, trackEvent }
}

// 组件中 → 解构时自由重命名，零冲突
const { loading: authLoading, error, login } = useAuth()
const { loading: analyticsLoading, trackEvent } = useAnalytics()
```

**解决来源不透明 → 显式导入**

```typescript
import { useAuth } from '@/composables/useAuth'       // 清晰来源
import { useAnalytics } from '@/composables/useAnalytics'
import { usePagination } from '@/composables/usePagination'
```

**解决传参问题 → 函数天然支持参数化**

```typescript
function usePagination(options: { pageSize?: number; immediate?: boolean } = {}) {
  const { pageSize = 10, immediate = true } = options
  const page = ref(1)
  const size = ref(pageSize)
  const total = ref(0)

  async function fetchPage(fetcher: (params: PageParams) => Promise<PageResult>) {
    const result = await fetcher({ page: page.value, size: size.value })
    total.value = result.total
    return result.data
  }

  return { page, size, total, fetchPage }
}

// 使用时灵活配置
const { page, size, total, fetchPage } = usePagination({ pageSize: 20 })
```

**额外优势 → 完善的 TypeScript 支持：**

```typescript
// Composition API 天然支持类型推导
function useCounter(initial: number = 0) {
  const count = ref(initial) // 自动推导为 Ref<number>
  const double = computed(() => count.value * 2) // ComputedRef<number>
  function increment() { count.value++ }
  return { count, double, increment } as const
}

// 使用处获得完整类型提示
const { count, double, increment } = useCounter(10)
// count → Ref<number> ✓
// double → ComputedRef<number> ✓
// increment → () => void ✓
```

---

### 4. watchEffect 和 watch 的区别是什么？它们的依赖收集机制有何不同？什么场景下选择哪个？

**答案：**

**核心区别对比：**

| 维度 | watchEffect | watch |
|------|-------------|-------|
| 依赖声明 | 自动收集（隐式） | 显式指定数据源 |
| 执行时机 | 立即执行一次 | 默认懒执行（可配 `immediate: true`） |
| 旧值访问 | 无法获取 | 回调提供 `(newVal, oldVal)` |
| 停止方式 | 返回 stop 函数 | 返回 stop 函数 |
| 依赖追踪 | 运行时动态追踪 | 声明时固定数据源 |

**依赖收集机制的差异：**

`watchEffect` 采用**运行时依赖收集**，和 computed 类似——在执行回调函数时，所有被访问的响应式数据自动成为依赖：

```typescript
const count = ref(0)
const name = ref('Vue')
const flag = ref(true)

watchEffect(() => {
  // 每次执行，依赖会重新收集
  if (flag.value) {
    console.log(count.value) // flag=true 时收集 flag + count
  } else {
    console.log(name.value)  // flag=false 时收集 flag + name
  }
  // 依赖集合是动态变化的！
})
```

`watch` 采用**声明式依赖指定**，数据源在定义时确定：

```typescript
// 侦听单个 ref
watch(count, (newVal, oldVal) => {
  console.log(`${oldVal} → ${newVal}`)
})

// 侦听 getter 函数
watch(
  () => state.nested.deep.value,
  (newVal) => { /* ... */ }
)

// 侦听多个数据源
watch(
  [count, name, () => state.foo],
  ([newCount, newName, newFoo], [oldCount, oldName, oldFoo]) => {
    // 任意一个变化都会触发
  }
)
```

**底层原理：**

```typescript
// watchEffect 简化实现
function watchEffect(effect) {
  const runner = new ReactiveEffect(() => {
    // 每次执行 effect 前清除旧依赖，执行时重新收集
    cleanupDeps(runner)
    effect()
  })
  runner.run() // 立即执行一次
  return () => runner.stop()
}

// watch 简化实现
function watch(source, cb, options) {
  let getter
  if (isRef(source)) {
    getter = () => source.value
  } else if (isReactive(source)) {
    getter = () => traverse(source) // 深度遍历触发所有 getter
  } else if (isFunction(source)) {
    getter = source
  }

  let oldValue
  const runner = new ReactiveEffect(getter, () => {
    const newValue = runner.run()
    cb(newValue, oldValue)
    oldValue = newValue
  })

  if (options?.immediate) {
    const value = runner.run()
    cb(value, undefined)
    oldValue = value
  } else {
    oldValue = runner.run() // 先执行一次 getter 收集依赖，但不触发 cb
  }
}
```

**场景选择指南：**

```typescript
// ✅ watchEffect 适合：副作用与依赖强关联，不关心旧值
watchEffect(() => {
  // 自动追踪所有依赖，代码简洁
  document.title = `${count.value} - ${name.value}`
})

// ✅ watchEffect 适合：初始化时就需要执行一次
watchEffect(async () => {
  const data = await fetch(`/api/user/${userId.value}`)
  userData.value = await data.json()
})

// ✅ watch 适合：需要对比新旧值
watch(searchQuery, (newQuery, oldQuery) => {
  if (newQuery !== oldQuery) {
    analytics.track('search_changed', { from: oldQuery, to: newQuery })
  }
}, { debounce: 300 })

// ✅ watch 适合：精确控制依赖，避免不必要的触发
watch(
  () => route.params.id,  // 只关心 id 变化，忽略 route 其他属性
  (id) => { fetchDetail(id) }
)

// ✅ watch 适合：需要懒执行
watch(formData, (data) => {
  autoSave(data) // 只在用户修改后才保存，不在初始化时保存
}, { deep: true })
```

---

### 5. Vue3 的虚拟 DOM diff 算法相比 Vue2 做了哪些优化？请解释静态提升（Static Hoisting）、Patch Flag、Block Tree 的作用。

**答案：**

Vue3 的编译器和运行时协同优化，核心思想是**编译时分析 + 运行时跳过**，将"全量 diff"降级为"靶向更新"。

**一、静态提升（Static Hoisting）**

将不会变化的静态节点或静态属性提升到 `render` 函数外部，只创建一次，后续渲染直接复用引用：

```html
<template>
  <div>
    <h1>Static Title</h1>            <!-- 纯静态 -->
    <p class="desc">Static Text</p>  <!-- 纯静态 -->
    <span>{{ dynamic }}</span>        <!-- 动态 -->
  </div>
</template>
```

编译后：

```javascript
// 静态节点提升到模块作用域，只创建一次
const _hoisted_1 = /*#__PURE__*/ createElementVNode("h1", null, "Static Title", -1 /* HOISTED */)
const _hoisted_2 = /*#__PURE__*/ createElementVNode("p", { class: "desc" }, "Static Text", -1)

function render(_ctx) {
  return (openBlock(), createElementBlock("div", null, [
    _hoisted_1,  // 直接引用，不重复创建
    _hoisted_2,
    createElementVNode("span", null, toDisplayString(_ctx.dynamic), 1 /* TEXT */)
  ]))
}
```

当连续静态节点 ≥ 20 个时，Vue3 会将其序列化为 **静态字符串（Static Stringify）**，用 `innerHTML` 一次性设置，进一步减少 VNode 创建开销。

**二、Patch Flag（补丁标记）**

编译器为动态节点添加位标记，告诉运行时"这个节点哪些部分是动态的"：

```javascript
// Patch Flag 枚举
export const enum PatchFlags {
  TEXT = 1,           // 动态文本内容
  CLASS = 1 << 1,     // 动态 class
  STYLE = 1 << 2,     // 动态 style
  PROPS = 1 << 3,     // 动态非 class/style 属性
  FULL_PROPS = 1 << 4, // 有动态 key 的属性
  NEED_HYDRATION = 1 << 5,
  STABLE_FRAGMENT = 1 << 6,
  KEYED_FRAGMENT = 1 << 7,
  UNKEYED_FRAGMENT = 1 << 8,
  NEED_PATCH = 1 << 9,
  DYNAMIC_SLOTS = 1 << 10,
  HOISTED = -1,
  BAIL = -2
}
```

```html
<div :class="cls" :id="id" :style="stl">{{ msg }}</div>
```

编译后：

```javascript
createElementVNode("div", {
  class: normalizeClass(_ctx.cls),
  id: _ctx.id,
  style: normalizeStyle(_ctx.stl)
}, toDisplayString(_ctx.msg),
  15 /* TEXT | CLASS | STYLE | PROPS */, ["id"]
  // ↑ patchFlag=15 → 运行时只比较 text、class、style、id
  // ↑ dynamicProps=["id"] → props 中只有 id 是动态的
)
```

运行时 `patchElement` 利用 Patch Flag 做靶向更新：

```javascript
function patchElement(n1, n2) {
  const { patchFlag, dynamicChildren } = n2

  if (patchFlag > 0) {
    if (patchFlag & PatchFlags.TEXT) {
      // 只更新文本
      if (n1.children !== n2.children) {
        hostSetElementText(el, n2.children)
      }
    }
    if (patchFlag & PatchFlags.CLASS) {
      // 只更新 class
      if (n1.props.class !== n2.props.class) {
        hostPatchProp(el, 'class', null, n2.props.class)
      }
    }
    // ... 其他 flag 同理
  } else {
    // 没有 flag → 全量 diff（兜底）
    patchProps(el, n1.props, n2.props)
  }
}
```

**三、Block Tree（区块树）**

Block 是一种特殊的 VNode，它会收集所有**动态后代节点**（不限层级）到 `dynamicChildren` 数组中。diff 时只遍历这个扁平数组，跳过所有静态节点：

```html
<div>                          <!-- Block Root -->
  <header>Static Header</header>    <!-- 跳过 -->
  <main>
    <section>
      <p>{{ text }}</p>             <!-- 动态 → 收集到 dynamicChildren -->
      <span :class="cls">Hi</span> <!-- 动态 → 收集到 dynamicChildren -->
    </section>
    <aside>Static Sidebar</aside>   <!-- 跳过 -->
  </main>
  <footer>Static Footer</footer>   <!-- 跳过 -->
</div>
```

```javascript
// Block 的 dynamicChildren 只包含动态节点，无论嵌套多深
block.dynamicChildren = [
  { type: 'p', children: ctx.text, patchFlag: 1 /* TEXT */ },
  { type: 'span', props: { class: ctx.cls }, patchFlag: 2 /* CLASS */ }
]

// diff 时只遍历 2 个节点，而不是整棵树的 6 个节点
function patchBlock(n1, n2) {
  const oldDynamic = n1.dynamicChildren
  const newDynamic = n2.dynamicChildren
  for (let i = 0; i < newDynamic.length; i++) {
    patch(oldDynamic[i], newDynamic[i]) // 逐个靶向 patch
  }
}
```

结构性指令（`v-if`/`v-for`）会创建新的 Block 节点，因为它们可能改变子节点的数量和顺序，无法在父 Block 中用平铺数组追踪。

**优化效果总结：** 假设模板有 100 个节点，其中只有 3 个动态绑定——Vue2 需要 diff 整棵 100 节点的树，Vue3 只需 patch 3 个带 PatchFlag 的节点，性能提升数量级。

---

### 6. shallowRef / shallowReactive / triggerRef 各自的使用场景是什么？在大数据量渲染场景下如何利用它们做性能优化？

**答案：**

**三者的核心区别：**

```typescript
// shallowRef：只对 .value 的赋值做响应式，不对值的内部属性递归代理
const state = shallowRef({ list: [], count: 0 })
state.value.count = 1        // ❌ 不触发更新（内部属性修改）
state.value = { list: [], count: 1 } // ✅ 触发更新（.value 重新赋值）

// shallowReactive：只对对象第一层属性做响应式，嵌套对象不代理
const state = shallowReactive({
  name: 'Vue',              // ✅ 响应式
  nested: { deep: 'value' } // ❌ nested.deep 修改不触发更新
})
state.name = 'React'         // ✅ 触发更新
state.nested.deep = 'new'    // ❌ 不触发更新

// triggerRef：手动触发 shallowRef 的依赖更新
const state = shallowRef({ count: 0 })
state.value.count = 1  // 内部修改不会自动触发
triggerRef(state)       // 手动通知 Vue："我改了，请更新"
```

**大数据量渲染场景优化实践：**

**场景一：万级列表数据（如 DEX 订单簿）**

```typescript
interface Order {
  price: string
  amount: string
  total: string
  side: 'buy' | 'sell'
}

// ❌ 用 reactive 包装万级数据 → 每个 order 的每个属性都被 Proxy 代理
const orderBook = reactive<{ bids: Order[], asks: Order[] }>({
  bids: [], asks: []
})

// ✅ 用 shallowRef → 只在整体替换时触发更新
const orderBook = shallowRef<{ bids: Order[], asks: Order[] }>({
  bids: [], asks: []
})

function handleWebSocketMessage(data: OrderBookSnapshot) {
  // 每次 WS 推送 → 整体替换（不可变数据模式）
  orderBook.value = {
    bids: data.bids.slice(0, 20),
    asks: data.asks.slice(0, 20)
  }
}
```

**场景二：高频更新 + 局部修改（行情 Tick 数据）**

```typescript
const tickerMap = shallowRef<Map<string, Ticker>>(new Map())

function onTickerUpdate(symbol: string, ticker: Ticker) {
  // 直接修改 Map 内部（避免每次创建新 Map）
  tickerMap.value.set(symbol, ticker)
  // 手动触发更新
  triggerRef(tickerMap)
}
```

**场景三：大型表单 / 配置对象**

```typescript
// 表单数据可能有几十个字段和嵌套结构
const formData = shallowReactive({
  basicInfo: { name: '', email: '' },   // 内部不追踪
  settings: { theme: 'dark', lang: 'zh' }, // 内部不追踪
  permissions: []
})

// 需要更新嵌套数据时，整体替换该层
function updateBasicInfo(info: BasicInfo) {
  formData.basicInfo = { ...formData.basicInfo, ...info } // 触发更新
}
```

**场景四：配合虚拟列表优化**

```typescript
// 10万条数据，虚拟滚动只渲染可见区域
const allData = shallowRef<DataItem[]>([])     // 全量数据，shallow 避免深度代理
const visibleData = computed(() => {
  const start = scrollTop.value / ITEM_HEIGHT
  const end = start + VISIBLE_COUNT
  return allData.value.slice(start, end)       // 只对可见切片做 diff
})
```

**性能收益量化：** 以 10,000 条订单记录为例，每条含 6 个字段：
- `reactive` 深度代理 → 创建 ~60,000 个 getter/setter → 初始化耗时 ~50ms
- `shallowRef` → 仅 1 个 `.value` 拦截 → 初始化耗时 ~0.1ms
- 内存方面，`shallowRef` 避免 Proxy 包装，内存占用减少约 40-60%

---

### 7. Pinia 相比 Vuex 4 在架构设计上有哪些改进？storeToRefs 的作用是什么？为什么直接解构 store 会丢失响应性？

**答案：**

**架构设计改进：**

| 维度 | Vuex 4 | Pinia |
|------|--------|-------|
| mutations | 必须通过 mutation 修改 state | 移除 mutations，直接修改 state 或通过 actions |
| 模块嵌套 | 嵌套模块 + namespaced | 扁平化 store，每个 store 独立 |
| TypeScript | 类型推导弱，需大量手动标注 | 天然完整的 TS 类型推导 |
| 代码分割 | 全量打包 | 按需引入，tree-shaking 友好 |
| 组合式 API | 不支持 | 支持 setup 风格定义 store |
| Devtools | 支持 | 支持，且体验更好 |
| 体积 | ~6KB | ~1.5KB |

```typescript
// Vuex 4 风格 → 冗长、类型弱
const store = createStore({
  state: () => ({ count: 0 }),
  mutations: {
    INCREMENT(state) { state.count++ }
  },
  actions: {
    increment({ commit }) { commit('INCREMENT') }  // 字符串引用，无类型安全
  },
  getters: {
    double: (state) => state.count * 2
  }
})

// Pinia → 简洁、类型安全
// Option 风格
export const useCounterStore = defineStore('counter', {
  state: () => ({ count: 0 }),
  getters: {
    double: (state) => state.count * 2
  },
  actions: {
    increment() {
      this.count++  // 直接修改，this 有完整类型
    }
  }
})

// Setup 风格（推荐）
export const useCounterStore = defineStore('counter', () => {
  const count = ref(0)
  const double = computed(() => count.value * 2)
  function increment() { count.value++ }
  return { count, double, increment }
})
```

**storeToRefs 的作用：**

`storeToRefs` 用于将 store 的 state 和 getters **以 ref 的形式解构出来**，同时保持响应性，但**不包含 actions（方法）**：

```typescript
import { storeToRefs } from 'pinia'

const counterStore = useCounterStore()

// ✅ storeToRefs 只提取响应式属性（state + getters）
const { count, double } = storeToRefs(counterStore)
// count → Ref<number>，修改 count.value 会同步到 store
// double → ComputedRef<number>

// actions 直接从 store 解构即可（函数不涉及响应性问题）
const { increment } = counterStore
```

**为什么直接解构 store 会丢失响应性：**

Pinia store 实例本质上是一个 `reactive` 对象。当解构 `reactive` 对象时，基本类型的值会脱离 Proxy 代理：

```typescript
const store = useCounterStore()
// store 内部类似：reactive({ count: 0, double: computed(...), increment: fn })

// ❌ 直接解构
const { count, double } = store
// count 此时是 0（普通数字），不是 Ref，断开了与 store 的关联
// 后续 store.count 变化时，这里的 count 不会更新

// 等价于：
let count = store.count  // count = 0，值复制，不是引用
```

`storeToRefs` 的内部实现原理：

```typescript
function storeToRefs(store) {
  const refs = {}
  for (const key in store) {
    const value = store[key]
    // 只处理 ref 和 computed（reactive 的属性通过 toRef 转换）
    if (isRef(value) || isReactive(value)) {
      refs[key] = toRef(store, key) // 创建一个与 store 属性关联的 ref
    }
    // 跳过 function（actions），不需要包装
  }
  return refs
}
```

`toRef(store, 'count')` 创建了一个"指向" `store.count` 的 ObjectRefImpl，其 getter/setter 始终通过 `store['count']` 访问，所以不会断开响应链。

---

### 8. Vue3 的 Teleport、Suspense、defineAsyncComponent 各自解决什么问题？Suspense 在 SSR 场景下如何工作？

**答案：**

**Teleport — 解决 DOM 层级与逻辑层级不一致的问题：**

典型场景：模态框、通知、Tooltip 等组件在逻辑上属于父组件，但在 DOM 上需要挂载到 `body` 避免 `overflow: hidden`、`z-index` 等 CSS 层叠上下文问题。

```html
<template>
  <div class="parent" style="overflow: hidden;">
    <button @click="showModal = true">打开</button>

    <!-- 逻辑上在父组件内，DOM 上渲染到 body -->
    <Teleport to="body">
      <div v-if="showModal" class="modal-overlay">
        <div class="modal-content">
          <!-- 仍可访问父组件的响应式数据和事件 -->
          <p>{{ message }}</p>
          <button @click="showModal = false">关闭</button>
        </div>
      </div>
    </Teleport>
  </div>
</template>
```

`Teleport` 支持 `disabled` 属性动态切换是否传送，以及 `to` 属性支持 CSS 选择器或 DOM 元素引用。

**Suspense — 解决异步组件/数据的加载状态协调问题：**

```html
<template>
  <Suspense>
    <!-- 主内容：可包含多个 async setup 组件 -->
    <template #default>
      <div>
        <AsyncUserProfile />
        <AsyncUserPosts />
      </div>
    </template>

    <!-- 加载态：所有异步依赖解析前显示 -->
    <template #fallback>
      <LoadingSkeleton />
    </template>
  </Suspense>
</template>

<script setup>
// 组件内部使用 async setup
// AsyncUserProfile.vue
const userData = await fetchUser(userId)  // 顶层 await
const posts = await fetchPosts(userId)
</script>
```

Suspense 的关键行为：
- 等待所有异步后代（async setup 组件 + defineAsyncComponent）resolve 后，才从 `#fallback` 切换到 `#default`
- 提供 `@resolve`、`@pending`、`@fallback` 事件钩子
- 嵌套 Suspense 支持：内层优先捕获

**defineAsyncComponent — 解决组件级别的按需加载和加载状态管理：**

```typescript
import { defineAsyncComponent } from 'vue'

const AsyncChart = defineAsyncComponent({
  loader: () => import('./HeavyChart.vue'),
  loadingComponent: ChartSkeleton,
  errorComponent: ChartError,
  delay: 200,       // 200ms 后才显示 loading（避免闪烁）
  timeout: 10000,   // 10s 超时显示 error
  onError(error, retry, fail, attempts) {
    if (attempts <= 3) {
      retry() // 自动重试
    } else {
      fail()
    }
  }
})
```

**Suspense 在 SSR 场景下的工作方式：**

```
浏览器请求 → 服务端渲染流程：

1. 服务端遇到 <Suspense>
2. 等待所有 async setup 的 Promise resolve
3. 将解析后的完整 HTML 发送给客户端（无 fallback 状态）
4. 客户端 hydration 时对照服务端输出进行激活
```

Vue3 SSR + Suspense 支持**流式渲染（Streaming SSR）**：

```typescript
// server.js（Node.js 流式 SSR）
import { renderToStream } from 'vue/server-renderer'

app.get('*', async (req, res) => {
  const app = createSSRApp(App)
  const stream = renderToStream(app)

  // Suspense 边界内的异步内容可分段发送
  // 1. 先发送 shell HTML（包含 fallback 占位）
  // 2. 异步内容 resolve 后，以 <script> 注入方式替换占位
  stream.pipe(res)
})
```

流式 SSR 中 Suspense 的行为：
1. 遇到 Suspense 边界时，先发送 `#fallback` 的 HTML 占位
2. 当异步组件 resolve 后，通过 `<script>` 标签将真实 HTML "注入"到页面并替换占位内容
3. 用户能更快看到页面骨架（TTFB 降低），异步内容流式到达后无缝替换

---

### 9. Vue3 的编译优化中，v-once、v-memo 分别做了什么？v-memo 的缓存策略是如何实现的？

**答案：**

**v-once — 一次性渲染，永不更新：**

```html
<template>
  <!-- 只在首次渲染时创建 VNode，后续跳过 diff -->
  <h1 v-once>{{ title }}</h1>

  <!-- 常用于大量静态内容 -->
  <div v-once>
    <TermsOfService />  <!-- 整个子树都不会更新 -->
  </div>
</template>
```

编译后：

```javascript
// v-once 编译为缓存 VNode
function render(_ctx, _cache) {
  return (openBlock(), createElementBlock("div", null, [
    // _cache[0] 存储首次创建的 VNode，后续直接返回
    _cache[0] || (
      setBlockTracking(-1), // 暂停 Block 收集（不收集到 dynamicChildren）
      _cache[0] = createVNode("h1", null, toDisplayString(_ctx.title), 1),
      setBlockTracking(1),
      _cache[0]
    )
  ]))
}
```

**v-memo — 带条件的渲染缓存（Vue 3.2+）：**

```html
<!-- 只有当 dependencies 数组中的值变化时才重新渲染 -->
<div v-memo="[item.id, item.selected]">
  <!-- 复杂的子树：多级嵌套、计算密集 -->
  <ExpensiveComponent :data="item" />
  <span>{{ formatDate(item.createdAt) }}</span>
  <Badge :type="item.status" />
</div>
```

`v-memo` 在 `v-for` 长列表中的经典优化：

```html
<template>
  <div v-for="item in list" :key="item.id"
       v-memo="[item.id === selectedId]">
    <!-- 只有选中状态变化的行才重新渲染 -->
    <div :class="{ active: item.id === selectedId }">
      {{ item.name }}
    </div>
  </div>
</template>
```

**v-memo 的缓存策略实现原理：**

```javascript
// 编译后生成的代码
function render(_ctx, _cache) {
  return (openBlock(true), createElementBlock(Fragment, null,
    renderList(_ctx.list, (item, index) => {
      return withMemo(
        [item.id === _ctx.selectedId],  // memo 依赖数组
        () => {
          // VNode 创建函数（昂贵操作）
          return (openBlock(), createElementBlock("div", {
            key: item.id,
            class: normalizeClass({ active: item.id === _ctx.selectedId })
          }, [
            createTextVNode(toDisplayString(item.name), 1)
          ]))
        },
        _cache,        // 组件实例的缓存数组
        index           // 缓存索引
      )
    }),
    128 /* KEYED_FRAGMENT */
  ))
}
```

`withMemo` 的核心逻辑：

```typescript
function withMemo(
  memo: any[],              // 当前依赖值
  render: () => VNode,      // VNode 创建函数
  cache: any[],             // 缓存数组
  index: number             // 缓存位置
): VNode {
  const cached = cache[index] as VNode | undefined

  // 有缓存 → 浅比较 memo 数组
  if (cached && isMemoSame(cached, memo)) {
    return cached  // 依赖未变 → 返回缓存的 VNode（跳过子树创建和 diff）
  }

  // 无缓存或依赖变化 → 重新创建
  const ret = render()
  ret.memo = memo.slice()   // 保存当前 memo 快照
  cache[index] = ret        // 写入缓存
  return ret
}

function isMemoSame(cached: VNode, memo: any[]): boolean {
  const prev = cached.memo!
  if (prev.length !== memo.length) return false
  for (let i = 0; i < prev.length; i++) {
    if (hasChanged(prev[i], memo[i])) return false
  }
  return true
}
```

**关键点：**
- `v-memo="[]"` 等价于 `v-once`（空依赖永远不变）
- 缓存粒度是 VNode 子树级别，命中缓存后整个子树的 diff 都被跳过
- 在 1000 行列表中切换选中项，只有 2 行（旧选中 + 新选中）会重新渲染，其余 998 行命中缓存

---

### 10. computed 的懒计算（lazy evaluation）机制是如何实现的？它的缓存失效条件是什么？与方法调用有何本质区别？

**答案：**

**懒计算的实现原理：**

computed 内部使用了 **dirty flag（脏标记）** 机制：

```typescript
class ComputedRefImpl<T> {
  public dep: Dep = new Dep()
  private _value!: T
  public readonly effect: ReactiveEffect<T>
  public _dirty = true  // 核心：脏标记

  constructor(getter: ComputedGetter<T>, private readonly _setter?: ComputedSetter<T>) {
    this.effect = new ReactiveEffect(
      () => getter(this._value),
      () => {
        // scheduler：当依赖变化时不立即重算，只标记为脏
        if (!this._dirty) {
          this._dirty = true
          this.dep.trigger() // 通知依赖此 computed 的 watcher
        }
      }
    )
    this.effect.computed = this
  }

  get value() {
    this.dep.track() // 收集谁依赖了此 computed
    if (this._dirty) {
      // 脏了才重新计算
      this._dirty = false
      this._value = this.effect.run()! // 执行 getter
    }
    return this._value // 不脏直接返回缓存值
  }

  set value(newValue: T) {
    this._setter?.(newValue)
  }
}
```

**完整的懒计算流程：**

```
1. 初始化时：dirty = true，不执行 getter
2. 首次读取 .value → dirty=true → 执行 getter → 缓存结果 → dirty=false
3. 再次读取 .value → dirty=false → 直接返回缓存
4. 依赖的响应式数据变化 → scheduler 被调用 → dirty=true（不执行 getter！）
5. 下次读取 .value → dirty=true → 重新执行 getter → 更新缓存
6. 如果没人读取 .value → getter 永远不会执行（真正的懒计算）
```

**缓存失效的条件：**

```typescript
const firstName = ref('John')
const lastName = ref('Doe')

const fullName = computed(() => {
  console.log('computed 执行了')  // 追踪执行次数
  return `${firstName.value} ${lastName.value}`
})

// 情况 1：依赖变化 → 缓存失效
firstName.value = 'Jane'  // dirty = true
console.log(fullName.value)  // 输出 "computed 执行了" + "Jane Doe"

// 情况 2：非依赖数据变化 → 缓存不失效
const unrelated = ref(0)
unrelated.value = 100
console.log(fullName.value)  // 不输出 "computed 执行了"，直接返回 "Jane Doe"

// 情况 3：依赖变化但没人访问 → getter 不执行
firstName.value = 'Bob'  // dirty = true
// ...但如果一直没有 fullName.value 读取，getter 不会执行
```

**与方法调用的本质区别：**

```typescript
// computed → 有缓存，响应式依赖追踪
const expensiveComputed = computed(() => {
  return heavyCalculation(list.value) // 只在 list 变化后下次访问时重算
})

// method → 无缓存，每次调用都执行
function expensiveMethod() {
  return heavyCalculation(list.value) // 每次调用都执行
}
```

```html
<template>
  <!-- computed：渲染中被多处引用只计算一次 -->
  <div>{{ expensiveComputed }}</div>
  <div>{{ expensiveComputed }}</div>  <!-- 第二次直接用缓存 -->
  <div>{{ expensiveComputed }}</div>  <!-- 第三次直接用缓存 -->

  <!-- method：每处引用都调用一次 -->
  <div>{{ expensiveMethod() }}</div>
  <div>{{ expensiveMethod() }}</div>  <!-- 又执行一次 -->
  <div>{{ expensiveMethod() }}</div>  <!-- 又执行一次 -->
</template>
```

| 维度 | computed | 方法 |
|------|----------|------|
| 缓存 | 有，依赖不变则不重算 | 无，每次调用都执行 |
| 触发时机 | 依赖变化 + 被访问时 | 每次调用时 |
| 响应式追踪 | 自身也是响应式数据，可被其他 computed/watch 追踪 | 无响应式身份 |
| 可写性 | 支持 getter + setter | 本身就是函数 |
| 适用场景 | 派生状态（一个值由其他值确定性推导） | 事件处理、有副作用的操作 |

---

### 11. Vue3 中 provide / inject 的响应性如何保证？在大型应用中使用它做依赖注入有哪些注意事项？

**答案：**

**响应性保证的原理：**

provide/inject 本身不创建响应性，它只是一个值的传递通道。响应性取决于你 provide 的值是否是响应式的：

```typescript
// ✅ 提供响应式数据 → inject 处自动获得响应性
// 父组件
const theme = ref('dark')
const config = reactive({ fontSize: 14, lang: 'zh' })
provide('theme', theme)     // 提供 Ref
provide('config', config)   // 提供 Reactive 对象

// 子/孙组件
const theme = inject('theme')!  // 得到的是同一个 Ref，响应式保持
const config = inject('config')! // 得到的是同一个 Proxy，响应式保持

watch(theme, (val) => {
  console.log('theme 变了', val) // ✅ 能监听到
})
```

```typescript
// ❌ 提供非响应式数据 → 无法追踪变化
provide('count', 0)         // 基本类型值，断开响应链
provide('list', [...arr])   // 新数组，与原数据无关
```

**推荐模式：提供 readonly + 修改方法**

```typescript
// 父组件（数据的拥有者）
const state = reactive({
  user: null as User | null,
  permissions: [] as string[]
})

function updateUser(user: User) {
  state.user = user
}

provide('auth', {
  state: readonly(state),  // 消费者只读，防止意外修改
  updateUser               // 通过暴露的方法修改
})
```

```typescript
// 子组件
const auth = inject<AuthContext>('auth')!
// auth.state.user = null  // ❌ 运行时警告（readonly）
auth.updateUser(newUser)    // ✅ 通过父组件暴露的方法修改
```

**大型应用中的注意事项和最佳实践：**

**1. 使用 InjectionKey 保证类型安全**

```typescript
// keys.ts — 集中管理所有 injection key
import type { InjectionKey, Ref } from 'vue'

export interface AuthContext {
  user: Readonly<Ref<User | null>>
  login: (credentials: Credentials) => Promise<void>
  logout: () => void
}

export const AUTH_KEY: InjectionKey<AuthContext> = Symbol('auth')
export const THEME_KEY: InjectionKey<Ref<'light' | 'dark'>> = Symbol('theme')

// 提供方
provide(AUTH_KEY, { user, login, logout })

// 消费方 → 完整类型推导
const auth = inject(AUTH_KEY)! // 类型为 AuthContext
```

**2. 提供默认值避免 undefined**

```typescript
// 可能未被 provide 时给合理默认值
const theme = inject(THEME_KEY, ref('light'))

// 或工厂函数（避免在组件外创建响应式对象）
const config = inject(CONFIG_KEY, () => reactive({ debug: false }), true)
```

**3. 避免 provide/inject 替代 Pinia**

```typescript
// ❌ 不要用 provide/inject 做全局状态管理
// 问题：无法跨组件树共享，无 devtools 支持，无持久化

// ✅ provide/inject 适合的场景：
// - 组件库内部的父子通信（Form → FormItem）
// - 主题/国际化配置向下传递
// - 插件向组件注入能力（路由、store 本身就是通过 inject 获取的）
```

**4. 控制 provide 的作用域**

```typescript
// provide 默认只在当前组件的子树中生效
// 兄弟组件或不相关的组件树获取不到

// 全局 provide → 在 app 级别
const app = createApp(App)
app.provide(AUTH_KEY, authService)  // 所有组件都能 inject

// 局部 provide → 在特定组件
// FormProvider.vue
provide(FORM_KEY, formContext)  // 只有 Form 内部的后代能 inject
```

**5. 注意 inject 的时序**

```typescript
// inject 只能在 setup() 或 <script setup> 中同步调用
// ❌ 不能在异步回调或生命周期外调用
onMounted(async () => {
  const data = await fetch(...)
  // const auth = inject(AUTH_KEY) // ❌ 此时已不在 setup 上下文
})

// ✅ 在 setup 顶层 inject
const auth = inject(AUTH_KEY)!
onMounted(async () => {
  const data = await fetch(...)
  auth.updateUser(data) // ✅ 使用之前 inject 的引用
})
```

---

### 12. Vue3 的 script setup 语法糖编译后生成了什么代码？defineProps、defineEmits、defineExpose 的编译时行为是怎样的？

**答案：**

**script setup 的编译转换：**

源码：

```html
<script setup lang="ts">
import { ref, computed } from 'vue'
import ChildComponent from './Child.vue'

interface Props {
  title: string
  count?: number
}

const props = defineProps<Props>()
const emit = defineEmits<{
  (e: 'update', value: number): void
  (e: 'close'): void
}>()

defineExpose({ reset })

const localCount = ref(0)
const double = computed(() => (props.count ?? 0) * 2)

function reset() {
  localCount.value = 0
}

function handleClick() {
  localCount.value++
  emit('update', localCount.value)
}
</script>

<template>
  <div @click="handleClick">
    <h1>{{ title }}</h1>
    <ChildComponent :value="double" />
  </div>
</template>
```

编译后等价代码：

```javascript
import { ref, computed, defineComponent } from 'vue'
import ChildComponent from './Child.vue'

export default /*#__PURE__*/ defineComponent({
  __name: 'MyComponent',

  props: {
    title: { type: String, required: true },
    count: { type: Number, required: false }
  },

  emits: ['update', 'close'],

  setup(__props, { expose, emit }) {
    const props = __props

    const localCount = ref(0)
    const double = computed(() => (props.count ?? 0) * 2)

    function reset() {
      localCount.value = 0
    }

    function handleClick() {
      localCount.value++
      emit('update', localCount.value)
    }

    expose({ reset })

    // setup 的返回值 = render 函数
    return (_ctx, _cache) => {
      return (openBlock(), createElementBlock("div", { onClick: handleClick }, [
        createElementVNode("h1", null, toDisplayString(__props.title), 1),
        createVNode(ChildComponent, { value: double.value }, null, 8, ["value"])
      ]))
    }
  }
})
```

**各 define 宏的编译时行为：**

**defineProps — 编译期类型擦除 + Props 声明提取**

```typescript
// 源码（纯 TypeScript 类型，运行时不存在）
const props = defineProps<{
  title: string
  count?: number
  items: string[]
}>()

// 编译器行为：
// 1. 解析 TypeScript 类型 AST
// 2. 将 TS 类型映射为运行时 props 选项
// 3. 擦除类型泛型，替换为运行时声明
// 编译输出：
props: {
  title: { type: String, required: true },
  count: { type: Number, required: false },
  items: { type: Array, required: true }
}

// 支持 withDefaults 设置默认值
const props = withDefaults(defineProps<Props>(), {
  count: 0,
  items: () => []
})
// 编译为：
props: {
  title: { type: String, required: true },
  count: { type: Number, required: false, default: 0 },
  items: { type: Array, required: false, default: () => [] }
}
```

**defineEmits — 编译期提取事件声明**

```typescript
// 源码
const emit = defineEmits<{
  (e: 'change', id: number): void
  (e: 'update', value: string): void
}>()

// 编译输出：
emits: ['change', 'update']
// emit 变量被替换为 setup 上下文的 emit 参数引用
```

**defineExpose — 编译期转换为 expose 调用**

```typescript
// 源码
defineExpose({ reset, validate })

// 编译为 setup 内部的 expose 调用：
setup(__props, { expose }) {
  // ...
  expose({ reset, validate })
}

// 效果：父组件通过 ref 只能访问 expose 的内容
// 不 expose → 默认不暴露任何内容（script setup 的安全默认）
```

**编译时宏的关键特性：**

1. **不需要 import**：`defineProps`/`defineEmits`/`defineExpose`/`defineSlots` 是编译器宏，不是运行时函数，无需导入
2. **编译期完全擦除**：这些宏在编译后不存在于输出代码中
3. **只能在 `<script setup>` 顶层使用**：不能在函数内部或条件块中调用
4. **类型只支持字面量或本文件 interface**：不能从外部文件 import 类型用于 defineProps 的泛型参数（Vue 3.3+ 已支持 imported types）

---

### 13. 在 DEX 项目中，10 大核心 Store 是如何设计的？Store 之间如何处理依赖关系？如何避免循环依赖？

**答案：**

**10 大核心 Store 的架构设计：**

在去中心化交易所项目中，基于 Pinia 将状态按领域模型拆分为 10 个独立 Store，遵循**单一职责 + 高内聚低耦合**原则：

```
┌─────────────────────────────────────────────────────────┐
│                      应用层 Store                        │
│                                                         │
│  ┌──────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │  common   │  │ tradingPair  │  │   wallet     │      │
│  │ (全局配置) │  │ (交易对管理)  │  │ (钱包连接)   │      │
│  └──────────┘  └──────────────┘  └──────────────┘      │
│                                                         │
│                      交易层 Store                        │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐         │
│  │  depth   │  │  kLine   │  │  orderBook   │         │
│  │ (深度图)  │  │ (K线数据) │  │ (订单簿渲染)  │         │
│  └──────────┘  └──────────┘  └──────────────┘         │
│                                                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────┐     │
│  │  openOrder   │  │ orderHistory │  │ position │     │
│  │ (当前挂单)    │  │ (历史订单)   │  │ (持仓管理) │     │
│  └──────────────┘  └──────────────┘  └──────────┘     │
│                                                         │
│                      资产层 Store                        │
│                                                         │
│  ┌──────────┐                                           │
│  │ balance  │                                           │
│  │ (余额资产) │                                          │
│  └──────────┘                                           │
└─────────────────────────────────────────────────────────┘
```

各 Store 的职责设计：

```typescript
// 1. common — 全局配置、网络状态、汇率
export const useCommonStore = defineStore('common', () => {
  const chainId = ref<number>(1)
  const networkStatus = ref<'connected' | 'disconnected'>('disconnected')
  const fiatRate = ref<Record<string, number>>({})
  return { chainId, networkStatus, fiatRate }
})

// 2. tradingPair — 交易对列表、当前选中交易对
export const useTradingPairStore = defineStore('tradingPair', () => {
  const pairs = ref<TradingPair[]>([])
  const currentPair = ref<TradingPair | null>(null)
  const currentSymbol = computed(() => currentPair.value?.symbol ?? '')
  function switchPair(pair: TradingPair) { /* 切换交易对，通知其他 store 重新订阅 */ }
  return { pairs, currentPair, currentSymbol, switchPair }
})

// 3. wallet — 钱包连接、账户、签名
export const useWalletStore = defineStore('wallet', () => {
  const address = ref<string>('')
  const isConnected = computed(() => !!address.value)
  const provider = shallowRef<ethers.BrowserProvider | null>(null)
  async function connect() { /* ... */ }
  async function signTransaction(tx: TransactionRequest) { /* ... */ }
  return { address, isConnected, provider, connect, signTransaction }
})

// 4. balance — 账户余额、保证金
export const useBalanceStore = defineStore('balance', () => {
  const balances = shallowRef<Record<string, string>>({})
  const marginBalance = ref('0')

  async function fetchBalances() {
    const walletStore = useWalletStore() // 在 action 中按需获取
    if (!walletStore.isConnected) return
    // ...
  }
  return { balances, marginBalance, fetchBalances }
})

// 5-10. 其他 Store 类似...
```

**Store 之间的依赖关系处理：**

**原则：在 action/getter 内部按需获取，不在 setup 顶层获取**

```typescript
// ✅ 正确做法：在需要时才获取其他 store
export const useOrderBookStore = defineStore('orderBook', () => {
  const bids = shallowRef<Order[]>([])
  const asks = shallowRef<Order[]>([])

  function subscribeOrderBook() {
    // 在 action 内部获取依赖的 store
    const tradingPairStore = useTradingPairStore()
    const symbol = tradingPairStore.currentSymbol

    ws.subscribe(`orderbook:${symbol}`, (data) => {
      bids.value = data.bids
      asks.value = data.asks
    })
  }

  // 通过 computed 派生跨 store 数据
  const bestBid = computed(() => bids.value[0]?.price ?? '0')
  const bestAsk = computed(() => asks.value[0]?.price ?? '0')
  const spread = computed(() => {
    return BigNumber(bestAsk.value).minus(bestBid.value).toString()
  })

  return { bids, asks, bestBid, bestAsk, spread, subscribeOrderBook }
})
```

```typescript
// ❌ 错误做法：在 setup 顶层交叉引用 → 容易形成循环依赖
export const useStoreA = defineStore('a', () => {
  const storeB = useStoreB() // ❌ 顶层调用，B 可能还未初始化
  // ...
})
```

**避免循环依赖的策略：**

**策略一：分层依赖 — 单向数据流**

```
common / wallet（底层，不依赖业务 store）
   ↓
tradingPair / balance（中间层，依赖底层）
   ↓
depth / kLine / orderBook / openOrder / orderHistory / position（业务层，依赖中间层）
```

同层 Store 之间不直接互相依赖。

**策略二：事件总线解耦（EventBus / mitt）**

```typescript
// eventBus.ts
import mitt from 'mitt'

type Events = {
  'pair:switched': TradingPair
  'wallet:connected': string
  'order:filled': Order
}

export const emitter = mitt<Events>()

// tradingPairStore 发布事件
function switchPair(pair: TradingPair) {
  currentPair.value = pair
  emitter.emit('pair:switched', pair) // 发布，不关心谁消费
}

// orderBookStore 订阅事件
emitter.on('pair:switched', (pair) => {
  resubscribeOrderBook(pair.symbol) // 响应，不关心谁发布
})
```

**策略三：Composable 抽离公共逻辑**

```typescript
// 当两个 Store 需要共享逻辑时，提取到 composable
// useWebSocket.ts
export function useWebSocket(channel: string) {
  const data = shallowRef<any>(null)
  function subscribe() { /* ... */ }
  function unsubscribe() { /* ... */ }
  return { data, subscribe, unsubscribe }
}

// 多个 Store 各自使用 composable，而非互相引用
// depthStore
const { data: depthData, subscribe } = useWebSocket('depth')

// kLineStore
const { data: kLineData, subscribe } = useWebSocket('kline')
```

---

### 14. Vue3 项目中如何实现动态路由 + RBAC 权限控制？addRoute 的时机选择和路由守卫的配合策略是什么？

**答案：**

**整体架构设计：**

```
用户登录 → 获取 Token → 请求权限菜单 → 过滤路由表 → addRoute 动态注册 → 路由守卫校验
```

**一、路由结构设计**

```typescript
// router/static-routes.ts — 静态路由（不需要权限）
export const staticRoutes: RouteRecordRaw[] = [
  { path: '/login', name: 'Login', component: () => import('@/views/Login.vue') },
  { path: '/403', name: 'Forbidden', component: () => import('@/views/403.vue') },
  { path: '/404', name: 'NotFound', component: () => import('@/views/404.vue') },
]

// router/async-routes.ts — 全量异步路由（后端返回的权限标识作为 key）
export const asyncRoutes: RouteRecordRaw[] = [
  {
    path: '/dashboard',
    name: 'Dashboard',
    component: Layout,
    meta: { title: '仪表盘', icon: 'dashboard', permission: 'dashboard:view' },
    children: [
      {
        path: 'analysis',
        name: 'Analysis',
        component: () => import('@/views/dashboard/Analysis.vue'),
        meta: { permission: 'dashboard:analysis' }
      }
    ]
  },
  {
    path: '/system',
    name: 'System',
    component: Layout,
    meta: { title: '系统管理', icon: 'setting', permission: 'system:manage' },
    children: [
      {
        path: 'user',
        name: 'UserManage',
        component: () => import('@/views/system/User.vue'),
        meta: { permission: 'system:user' }
      },
      {
        path: 'role',
        name: 'RoleManage',
        component: () => import('@/views/system/Role.vue'),
        meta: { permission: 'system:role' }
      }
    ]
  }
]
```

**二、权限过滤逻辑**

```typescript
// utils/permission.ts
export function filterAsyncRoutes(
  routes: RouteRecordRaw[],
  permissions: Set<string>
): RouteRecordRaw[] {
  const result: RouteRecordRaw[] = []

  for (const route of routes) {
    const cloned = { ...route }

    if (hasPermission(cloned, permissions)) {
      if (cloned.children?.length) {
        cloned.children = filterAsyncRoutes(cloned.children, permissions)
      }
      result.push(cloned)
    }
  }

  return result
}

function hasPermission(route: RouteRecordRaw, permissions: Set<string>): boolean {
  if (route.meta?.permission) {
    return permissions.has(route.meta.permission as string)
  }
  return true // 没有 permission 标记的路由默认放行
}
```

**三、Permission Store**

```typescript
// stores/permission.ts
export const usePermissionStore = defineStore('permission', () => {
  const routes = ref<RouteRecordRaw[]>([])
  const addedRoutes = ref<RouteRecordRaw[]>([])
  const permissions = ref<Set<string>>(new Set())
  const buttonPermissions = ref<Set<string>>(new Set())

  async function generateRoutes() {
    // 1. 从后端获取用户权限列表
    const { menuPermissions, btnPermissions } = await getUserPermissions()

    permissions.value = new Set(menuPermissions)
    buttonPermissions.value = new Set(btnPermissions)

    // 2. 过滤异步路由
    const filteredRoutes = filterAsyncRoutes(asyncRoutes, permissions.value)

    // 3. 动态添加路由
    filteredRoutes.forEach(route => {
      router.addRoute(route) // 关键：addRoute 注册
    })

    // 4. 添加兜底 404（必须在所有动态路由之后）
    router.addRoute({
      path: '/:pathMatch(.*)*',
      redirect: '/404'
    })

    addedRoutes.value = filteredRoutes
    routes.value = [...staticRoutes, ...filteredRoutes]
  }

  function resetRoutes() {
    // 移除所有动态添加的路由
    addedRoutes.value.forEach(route => {
      if (route.name) {
        router.removeRoute(route.name)
      }
    })
    addedRoutes.value = []
    permissions.value.clear()
  }

  function hasButtonPermission(code: string): boolean {
    return buttonPermissions.value.has(code)
  }

  return { routes, permissions, generateRoutes, resetRoutes, hasButtonPermission }
})
```

**四、路由守卫配合策略（addRoute 时机的关键）**

```typescript
// router/guard.ts
const whiteList = ['/login', '/403', '/404']

router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()
  const permissionStore = usePermissionStore()

  // 1. 有 token
  if (userStore.token) {
    if (to.path === '/login') {
      next({ path: '/' })
      return
    }

    // 2. 已经加载过权限路由 → 放行
    if (permissionStore.addedRoutes.length > 0) {
      next()
      return
    }

    // 3. 首次访问 / 刷新页面 → 重新生成路由
    try {
      await userStore.fetchUserInfo()
      await permissionStore.generateRoutes()

      // 关键：addRoute 后必须用 next({ ...to, replace: true }) 重新导航
      // 因为 addRoute 是异步注册，当前导航目标可能还未匹配到新路由
      next({ ...to, replace: true })
    } catch (error) {
      userStore.logout()
      next(`/login?redirect=${to.path}`)
    }
    return
  }

  // 4. 无 token
  if (whiteList.includes(to.path)) {
    next()
  } else {
    next(`/login?redirect=${to.path}`)
  }
})
```

**五、按钮级权限指令**

```typescript
// directives/permission.ts
export const vPermission: Directive<HTMLElement, string | string[]> = {
  mounted(el, binding) {
    const permissionStore = usePermissionStore()
    const required = Array.isArray(binding.value) ? binding.value : [binding.value]
    const hasPermission = required.some(p => permissionStore.hasButtonPermission(p))

    if (!hasPermission) {
      el.parentNode?.removeChild(el)
    }
  }
}
```

```html
<!-- 使用 -->
<button v-permission="'order:delete'">删除订单</button>
<button v-permission="['order:edit', 'order:admin']">编辑订单</button>
```

**addRoute 时机的关键点：**
1. 在 `router.beforeEach` 守卫中执行，确保在路由解析前完成注册
2. `addRoute` 后必须使用 `next({ ...to, replace: true })` 中断当前导航并重新触发，否则新增的路由不会匹配
3. 404 兜底路由必须在所有动态路由之后添加，否则动态路由会被 404 拦截
4. 页面刷新时需要重新获取权限并 addRoute（Token 持久化在 localStorage，但路由信息在内存中丢失）

---

### 15. Vue3 的 KeepAlive 组件缓存策略是什么？include/exclude/max 如何工作？LRU 缓存淘汰的实现原理？

**答案：**

**KeepAlive 的核心缓存机制：**

KeepAlive 是一个内置抽象组件，它在内部维护一个缓存 Map，将组件的 VNode 实例保存在内存中，切换时不销毁而是"停用"（deactivated），再次激活时从缓存中恢复：

```html
<KeepAlive :include="['UserList', 'OrderList']" :exclude="['Login']" :max="10">
  <router-view />
</KeepAlive>
```

**include / exclude 的工作方式：**

```typescript
// KeepAlive 内部判断逻辑
function matches(
  pattern: string | RegExp | (string | RegExp)[], // include 或 exclude 的值
  name: string                                      // 组件的 name
): boolean {
  if (isArray(pattern)) {
    return pattern.some(p => matches(p, name))
  } else if (isString(pattern)) {
    return pattern.split(',').includes(name)
  } else if (isRegExp(pattern)) {
    return pattern.test(name)
  }
  return false
}

// 在渲染时判断
const { include, exclude } = props
if (
  (include && (!name || !matches(include, name))) ||
  (exclude && name && matches(exclude, name))
) {
  // 不缓存，直接渲染
  return rawVNode
}
```

三种匹配方式：
```html
<!-- 字符串（逗号分隔） -->
<KeepAlive include="UserList,OrderList">

<!-- 正则表达式 -->
<KeepAlive :include="/^(User|Order)/">

<!-- 数组 -->
<KeepAlive :include="['UserList', 'OrderList']">
```

匹配目标是组件的 `name` 选项。`<script setup>` 中文件名自动成为 name，也可通过 `defineOptions({ name: 'CustomName' })` 显式指定。

**max 与 LRU 缓存淘汰实现原理：**

```typescript
// KeepAlive 组件的简化实现
const KeepAliveImpl = {
  setup(props, { slots }) {
    const cache = new Map<CacheKey, VNode>()   // key → VNode 缓存
    const keys = new Set<CacheKey>()           // 记录访问顺序（Set 保持插入顺序）

    function cacheSubtree(vnode: VNode) {
      const key = vnode.key ?? vnode.type
      const { max } = props

      if (cache.has(key)) {
        // 已缓存 → 更新访问顺序（LRU 核心：移到最新）
        keys.delete(key)
        keys.add(key)
      } else {
        // 新缓存
        keys.add(key)
        cache.set(key, vnode)

        // 超出 max → 淘汰最久未使用的（LRU 淘汰）
        if (max && keys.size > parseInt(max as string, 10)) {
          pruneCacheEntry(keys.values().next().value) // Set 迭代顺序 = 插入顺序
        }
      }
    }

    function pruneCacheEntry(key: CacheKey) {
      const cached = cache.get(key)!
      // 卸载被淘汰的组件实例
      unmount(cached)
      cache.delete(key)
      keys.delete(key)
    }

    return () => {
      const rawVNode = slots.default?.()
      // ...include/exclude 判断...

      const key = rawVNode.key ?? rawVNode.type
      const cachedVNode = cache.get(key)

      if (cachedVNode) {
        // 命中缓存 → 复用组件实例
        rawVNode.component = cachedVNode.component
        rawVNode.shapeFlag |= ShapeFlags.COMPONENT_KEPT_ALIVE

        // LRU：更新访问顺序
        keys.delete(key)
        keys.add(key)
      } else {
        // 首次 → 标记需要缓存
        rawVNode.shapeFlag |= ShapeFlags.COMPONENT_SHOULD_KEEP_ALIVE
      }

      return rawVNode
    }
  }
}
```

**LRU（Least Recently Used）算法图解：**

```
假设 max = 3

操作序列：访问 A → B → C → D → B

Step 1: 访问 A → keys: [A]           cache: {A}
Step 2: 访问 B → keys: [A, B]        cache: {A, B}
Step 3: 访问 C → keys: [A, B, C]     cache: {A, B, C}  ← 满了
Step 4: 访问 D → 淘汰最久未使用的 A
                  keys: [B, C, D]     cache: {B, C, D}
Step 5: 访问 B → B 已存在，移到最新位置
                  keys: [C, D, B]     cache: {B, C, D}

下次超出时，C 会被淘汰（最久未访问）
```

**KeepAlive 的生命周期：**

```typescript
// 被缓存的组件会触发特殊生命周期
import { onActivated, onDeactivated } from 'vue'

onActivated(() => {
  // 组件从缓存中激活时（从 KeepAlive 缓存恢复显示）
  // 适合刷新数据、恢复定时器/WebSocket 订阅
  refreshData()
  ws.subscribe()
})

onDeactivated(() => {
  // 组件被缓存时（切走但未销毁）
  // 适合暂停定时器、取消订阅，节省资源
  clearInterval(timer)
  ws.unsubscribe()
})
```

---

### 16. 从 Vue2 迁移到 Vue3 的过程中，最大的技术挑战是什么？你是如何制定渐进式迁移策略的？

**答案：**

**最大的技术挑战（按影响范围排序）：**

**挑战一：响应式系统的 Breaking Changes**

```javascript
// Vue2 依赖的响应式 hack 在 Vue3 中全部失效
this.$set(this.obj, 'key', value)  // Vue3 不需要，但代码中大量使用
this.$delete(this.obj, 'key')      // 同上
Vue.set / Vue.delete               // 全局 API 移除

// 数组操作的行为差异
// Vue2 重写了数组方法（push/pop/splice 等），直接索引赋值不响应
// Vue3 Proxy 完全覆盖，但某些 workaround 代码需要清理
```

**挑战二：全局 API 从实例迁移到应用实例**

```javascript
// Vue2 — 全局污染
Vue.component('GlobalComp', Comp)
Vue.directive('focus', directive)
Vue.mixin(globalMixin)
Vue.prototype.$http = axios

// Vue3 — 应用实例隔离
const app = createApp(App)
app.component('GlobalComp', Comp)
app.directive('focus', directive)
app.config.globalProperties.$http = axios
// 多个 app 实例互不干扰
```

**挑战三：Vuex → Pinia 的状态管理重构**

所有 Store 需要从 mutations + actions 模式重写为 Pinia 的 setup 风格，涉及大量状态逻辑重构。

**挑战四：组件库 / 第三方依赖的兼容性**

Element UI → Element Plus，部分 API 变更需要逐个适配。

**渐进式迁移策略：**

**阶段一：基础设施升级（1-2 周）**

```bash
# 1. 引入 @vue/compat（兼容构建）
npm install vue@3 @vue/compat

# 2. 配置 Vue3 兼容模式
# vite.config.ts
export default defineConfig({
  resolve: {
    alias: {
      vue: '@vue/compat' // 用兼容包替换 vue
    }
  }
})

# 3. 开启所有兼容特性
# main.ts
import { configureCompat } from 'vue'
configureCompat({
  MODE: 2, // 默认 Vue2 行为，逐步切换
  GLOBAL_MOUNT: false,      // 已迁移：关闭兼容
  INSTANCE_EVENT_EMITTER: false, // 已迁移：关闭兼容
  // ... 逐个关闭已迁移的特性
})
```

**阶段二：非 Breaking 迁移（2-3 周）**

优先迁移不影响运行的部分：

```typescript
// 1. 全局 API 迁移
// Before: Vue.prototype.$bus = new Vue()
// After: 使用 mitt 替代
import mitt from 'mitt'
app.config.globalProperties.$bus = mitt()

// 2. 生命周期重命名
// beforeDestroy → beforeUnmount
// destroyed → unmounted

// 3. v-model 迁移
// Vue2: value + @input
// Vue3: modelValue + @update:modelValue
// 支持多个 v-model
```

**阶段三：核心模块逐步重写（4-6 周）**

```typescript
// 以功能模块为单位，逐步从 Options API 迁移到 Composition API
// 优先迁移：独立模块 > 公共模块 > 核心模块

// 迁移前：Options API
export default {
  data() {
    return { list: [], loading: false }
  },
  computed: {
    filteredList() { return this.list.filter(/*...*/) }
  },
  methods: {
    async fetchList() { /* ... */ }
  },
  mounted() { this.fetchList() }
}

// 迁移后：Composition API + script setup
const list = ref<Item[]>([])
const loading = ref(false)
const filteredList = computed(() => list.value.filter(/*...*/))

async function fetchList() { /* ... */ }
onMounted(() => fetchList())
```

**阶段四：状态管理迁移（2-3 周）**

```typescript
// Vuex 模块逐个迁移到 Pinia
// 保持旧 Vuex store 和新 Pinia store 共存
// 使用适配层确保过渡期两边数据同步

// adaptor.ts（过渡期使用）
export function syncVuexToPinia() {
  const vuexStore = useStore() // Vuex
  const piniaStore = useTradingPairStore() // Pinia

  watch(
    () => vuexStore.state.tradingPair.current,
    (pair) => { piniaStore.currentPair = pair }
  )
}
```

**阶段五：移除 @vue/compat，完全切换到 Vue3（1 周）**

```typescript
// 逐步将 configureCompat 中的所有特性都关闭
// 确认没有控制台警告后，移除 @vue/compat
configureCompat({
  MODE: 3 // 完全 Vue3 模式，此时应无任何兼容性警告
})

// 最后：移除 @vue/compat，切换到纯 vue@3
```

**迁移过程中的工程保障：**

1. **分支策略**：从 main 拉出 `feat/vue3-migration` 长期分支，定期 rebase main
2. **测试覆盖**：迁移前补充核心模块的单元测试（Vitest），作为迁移正确性的回归保障
3. **渐进发布**：通过功能开关（Feature Flag）控制 Vue2/Vue3 代码路径，灰度上线
4. **团队协作**：制定迁移清单，按模块认领，每周 Review 进度

---

### 17. Vue3 的 effectScope 是什么？在什么场景下需要手动管理 effect 作用域？

**答案：**

**effectScope 的本质：**

`effectScope` 是 Vue 3.2 引入的 API，用于**批量管理响应式副作用（effect）的生命周期**。它创建一个作用域，在该作用域内创建的所有 `watch`、`watchEffect`、`computed` 会被自动收集，调用 `scope.stop()` 时统一销毁：

```typescript
import { effectScope, ref, computed, watchEffect, watch } from 'vue'

const scope = effectScope()

scope.run(() => {
  const count = ref(0)
  const double = computed(() => count.value * 2)

  watchEffect(() => {
    console.log('count:', count.value)
  })

  watch(count, (val) => {
    console.log('watch:', val)
  })
})

// 一键销毁所有 effect：computed、watchEffect、watch 全部停止
scope.stop()
```

**为什么需要手动管理？**

在组件内部，Vue 自动创建了一个与组件实例绑定的 effectScope，组件卸载时自动 `stop()`。但在**组件外部**使用响应式 API 时，没有自动清理机制：

```typescript
// composable 在组件内使用 → 自动清理 ✅
// composable 在非组件上下文使用 → 需要手动管理 ⚠️
```

**场景一：跨组件的共享状态管理（Pinia 内部实现）**

```typescript
// Pinia 的 defineStore 内部就是用 effectScope 管理的
export function defineStore(id, setup) {
  function useStore() {
    if (!store) {
      const scope = effectScope(true) // detached scope

      const setupResult = scope.run(() => {
        return setup() // store 内的 computed/watch 都被收集
      })

      store = reactive(setupResult)
      store.$dispose = () => scope.stop() // 销毁时清理所有 effect
    }
    return store
  }
  return useStore
}
```

**场景二：可组合函数（Composables）中管理内部副作用**

```typescript
// 封装一个可以在非组件上下文中使用的 composable
function useEventSource(url: string) {
  const scope = effectScope()
  const data = ref<string | null>(null)
  const status = ref<'connecting' | 'open' | 'closed'>('connecting')

  scope.run(() => {
    const es = new EventSource(url)

    watchEffect((onCleanup) => {
      es.onmessage = (event) => {
        data.value = event.data
      }

      es.onopen = () => { status.value = 'open' }
      es.onerror = () => { status.value = 'closed' }

      onCleanup(() => es.close())
    })

    // 当 url 变化时自动重连
    watch(() => url, (newUrl) => {
      // ...
    })
  })

  function dispose() {
    scope.stop() // 一键清理所有 watcher + EventSource
  }

  return { data, status, dispose }
}
```

**场景三：条件性 / 动态创建的 effect 组**

```typescript
// 根据用户操作动态创建/销毁一组 effect
function useDynamicFeature() {
  let featureScope: EffectScope | null = null

  function enableFeature() {
    featureScope = effectScope()
    featureScope.run(() => {
      // 启用功能时创建一批 effect
      const timer = ref(0)
      watchEffect(() => { /* 定时轮询 */ })
      watch(someData, () => { /* 数据同步 */ })
      // ... 可能有很多 effect
    })
  }

  function disableFeature() {
    featureScope?.stop() // 一键清理，无需逐个 stop
    featureScope = null
  }

  return { enableFeature, disableFeature }
}
```

**场景四：测试环境中隔离副作用**

```typescript
describe('useCounter', () => {
  it('should increment', () => {
    const scope = effectScope()

    scope.run(() => {
      const { count, increment } = useCounter()
      expect(count.value).toBe(0)
      increment()
      expect(count.value).toBe(1)
    })

    // 测试结束 → 清理所有副作用，避免影响其他测试
    scope.stop()
  })
})
```

**场景五：嵌套作用域与 detached 模式**

```typescript
const parentScope = effectScope()

parentScope.run(() => {
  // 子作用域（默认）→ 跟随父作用域一起销毁
  const childScope = effectScope()
  childScope.run(() => { /* ... */ })

  // 分离作用域（detached: true）→ 父作用域销毁时不受影响
  const detachedScope = effectScope(true)
  detachedScope.run(() => { /* 独立生命周期 */ })
})

parentScope.stop()
// childScope 的 effect 也被清理 ✅
// detachedScope 的 effect 仍在运行 → 需要手动 detachedScope.stop()
```

**`getCurrentScope` 和 `onScopeDispose`：**

```typescript
import { getCurrentScope, onScopeDispose } from 'vue'

function useResource() {
  const resource = acquireResource()

  // 在当前作用域销毁时自动释放资源
  if (getCurrentScope()) {
    onScopeDispose(() => {
      releaseResource(resource) // 无论是组件卸载还是 scope.stop()
    })
  }

  return resource
}
```

`onScopeDispose` 是 `onUnmounted` 的泛化版本——在组件内等价于 `onUnmounted`，在 effectScope 内等价于 `scope.stop()` 时的清理回调。这使得 composable 既能在组件内使用，也能在非组件上下文中正确清理。

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


## 四、TypeScript

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

## 五、Next.js

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
