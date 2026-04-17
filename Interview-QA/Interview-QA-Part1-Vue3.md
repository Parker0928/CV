## 一、Vue3

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
