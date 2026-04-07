# 前端高级工程师面试题（含核心考察点+完整版标准答案）

## 一、JavaScript 进阶与原理（高频核心）

### 题目1：详细阐述闭包的本质、形成条件、内存机制，结合实际业务场景说明闭包的应用场景，以及闭包可能导致的内存泄漏问题和解决方案。

**标准答案**：

**1. 闭包本质**：闭包是指函数能够访问并保留其词法作用域，即使该函数在其词法作用域之外执行，本质是**函数嵌套+内部函数引用外部函数变量/参数**，形成的跨越作用域的变量访问机制，属于JavaScript词法作用域的产物。

**2. 形成条件**：① 存在函数嵌套，内部函数定义在外部函数内部；② 内部函数引用了外部函数的变量、参数或自由变量；③ 外部函数执行完毕，内部函数被保留（赋值、返回、作为回调传递）。

**3. 内存机制**：正常情况下，函数执行完毕后，其执行上下文会被销毁，变量占用的内存会被垃圾回收；但闭包中，内部函数持有外部函数作用域的引用，导致外部函数的变量对象无法被销毁，会一直驻留在内存中，直到内部函数被销毁。

**4. 实际应用场景**：

- **模块化封装**：创建私有变量和私有方法，避免全局变量污染，实现模块化（如IIFE+闭包）。

- **函数柯里化/参数复用**：保留预设参数，实现函数延迟执行、参数复用。

- **缓存数据**：利用闭包保留计算结果，实现缓存功能，减少重复计算。

- **事件回调/定时器**：在循环中绑定事件、定时器，保留当前循环的变量值。

- **防抖节流函数**：保留定时器标识，实现函数执行频率控制。

**5. 内存泄漏问题及解决方案**：

泄漏原因：闭包长期持有DOM引用、全局变量、大型对象，且内部函数一直未被销毁，导致内存无法回收；意外的全局闭包、未清理的定时器/事件监听也会加剧泄漏。

解决方案：① 及时销毁闭包引用，将内部函数赋值为null，切断作用域引用；② 避免在闭包中持有不必要的DOM、大型数据引用；③ 用完定时器、事件监听及时清除；④ 模块化开发中合理控制闭包生命周期，避免长期驻留。

### 题目2：对比原型链继承、构造函数继承、组合继承、寄生组合继承、ES6 Class继承的优缺点，分析Class继承的底层实现原理，以及原型链污染的成因和防范措施。

**标准答案**：

**1. 各类继承方式对比**：

- **原型链继承**：优点是实现简单，能继承原型属性和方法；缺点是引用类型属性会被所有实例共享，修改一个实例会影响其他实例，无法向父构造函数传参。

- **构造函数继承（借用call/apply）**：优点是避免引用类型共享，可向父类传参；缺点是只能继承实例属性/方法，无法继承原型上的方法，函数无法复用，每次创建实例都会重新创建方法。

- **组合继承（原型链+构造函数）**：优点是兼顾实例属性隔离和原型方法复用，是早期常用继承方式；缺点是父构造函数会被调用两次（一次创建原型，一次创建实例），存在冗余属性，原型链上会有多余属性。

- **寄生组合继承**：最优ES5继承方式，通过寄生方式修复组合继承的缺陷，只调用一次父构造函数，避免冗余属性，实现完整继承且性能最优；缺点是实现稍复杂。

- **ES6 Class继承**：优点是语法简洁、语义清晰，支持super调用父类、静态方法、私有属性，兼容寄生组合继承底层逻辑，是现代JS标准继承方式；缺点是本质是语法糖，底层仍基于原型链，需理解原型原理避免误用。

**2. Class继承底层实现原理**：ES6 Class是ES5构造函数+原型继承的语法糖，底层通过**寄生组合继承**实现；子类通过extends关键字继承父类，super()等价于调用父类构造函数，子类的__proto__指向父类，子类prototype的__proto__指向父类prototype，完整实现实例和原型的双重继承。

**3. 原型链污染成因及防范**：

成因：攻击者或代码通过修改Object.prototype、Array.prototype等原型对象，为原型添加恶意属性/方法，所有继承该原型的实例都会被污染；常见于用户可控的对象合并、深拷贝、JSON解析场景。

防范措施：① 避免直接修改原生对象原型；② 使用Object.create(null)创建无原型对象，切断原型链；③ 对用户输入的对象做严格校验，禁止直接修改原型；④ 深拷贝时跳过原型属性，只拷贝自身属性；⑤ 禁用with语句，避免作用域污染。

### 题目3：解释事件循环（Event Loop）机制，区分浏览器和Node.js事件循环的差异，详细说明宏任务、微任务的执行顺序，结合Promise、async/await、setTimeout、process.nextTick写出复杂代码的执行结果。

**标准答案**：

**1. 事件循环本质**：JavaScript是单线程语言，为了避免阻塞，通过事件循环机制处理异步任务，协调同步任务、异步任务的执行顺序，保证代码非阻塞执行。

**2. 浏览器与Node.js事件循环核心差异**：

- **执行环境**：浏览器基于HTML标准实现，Node.js基于libuv库实现。

- **宏任务队列**：浏览器宏任务包括script整体代码、setTimeout、setInterval、I/O、UI渲染；Node.js宏任务分为timers、pending callbacks、idle/prepare、poll、check、close callbacks六个阶段，每个阶段对应独立队列。

- **微任务执行时机**：浏览器每执行完一个宏任务，清空所有微任务队列；Node.js（v11及以上）趋于浏览器一致，v10及以前是每个阶段结束后清空微任务，process.nextTick优先级高于Promise微任务。

- **特殊任务**：Node.js独有process.nextTick、setImmediate，浏览器独有UI渲染任务。

**3. 宏任务与微任务执行顺序**：

① 执行全局同步代码，形成执行栈；② 执行过程中遇到异步任务，宏任务推入宏任务队列，微任务推入微任务队列；③ 同步代码执行完毕，清空当前微任务队列（所有微任务依次执行）；④ 微任务清空后，取出一个宏任务执行；⑤ 重复上述循环，直到所有任务执行完毕。

**优先级**：同步代码 > process.nextTick（Node）> Promise微任务/async/await > 宏任务（setTimeout/setInterval）。

**4. 代码执行示例**：

```javascript
async function async1() {
  console.log('async1 start');
  await async2();
  console.log('async1 end');
}
async function async2() {
  console.log('async2');
}
console.log('script start');
setTimeout(() => {
  console.log('setTimeout');
}, 0);
async1();
new Promise(resolve => {
  console.log('Promise1');
  resolve();
}).then(() => {
  console.log('Promise2');
});
console.log('script end');
// 浏览器执行结果：script start → async1 start → async2 → Promise1 → script end → async1 end → Promise2 → setTimeout
// Node.js v11+结果与浏览器一致，v10及以前process.nextTick优先度更高
```

### 题目4：深入分析Promise的A+规范，手写Promise核心源码（包含then、catch、resolve、reject、all、race方法），说明Promise的状态流转、值穿透、异常捕获机制，以及Promise.allSettled、Promise.any的使用场景。

**标准答案**：

**1. Promise A+核心规范**：

- Promise有三种状态：pending（等待态）、fulfilled（成功态）、rejected（失败态），状态一旦改变，不可逆（pending→fulfilled 或 pending→rejected）。

- Promise必须提供then方法，then接收onFulfilled、onRejected两个回调，返回新Promise，支持链式调用。

- 回调函数必须异步执行，onFulfilled接收成功值，onRejected接收失败原因。

- 支持值穿透、异常冒泡捕获，未捕获的异常会一直传递到最后一个catch。

**2. 状态流转**：初始为pending，调用resolve()变为fulfilled，调用reject()变为rejected，状态变更后无法再次修改，回调只会执行一次。

**3. 值穿透机制**：then方法中如果传入非函数参数，会忽略该参数，将当前Promise的结果直接传递给下一个then，实现值穿透。

**4. 异常捕获机制**：Promise内部异常会自动捕获，传递给最近的onRejected回调或catch方法，链式调用中任意环节报错，都会冒泡到最后一个catch，避免代码阻塞。

**5. 核心方法使用场景**：

- Promise.all：批量执行Promise，所有成功才返回结果数组，任意一个失败则整体失败，适用于并行请求、依赖全部结果的场景。

- Promise.race：多个Promise竞争，返回第一个完成的结果（无论成功失败），适用于超时控制、优先获取最快结果场景。

- Promise.allSettled：批量执行Promise，返回所有结果（含成功/失败状态），适用于需要获取所有请求结果，不关心成败的场景。

- Promise.any：多个Promise竞争，返回第一个成功的结果，全部失败才报错，适用于取最快有效结果场景。

**6. 手写Promise核心源码**：

```javascript
class MyPromise {
  static PENDING = 'pending';
  static FULFILLED = 'fulfilled';
  static REJECTED = 'rejected';
  constructor(executor) {
    this.status = MyPromise.PENDING;
    this.value = undefined;
    this.reason = undefined;
    this.onFulfilledCallbacks = [];
    this.onRejectedCallbacks = [];
    const resolve = (value) => {
      if (this.status === MyPromise.PENDING) {
        this.status = MyPromise.FULFILLED;
        this.value = value;
        this.onFulfilledCallbacks.forEach(cb => cb());
      }
    };
    const reject = (reason) => {
      if (this.status === MyPromise.PENDING) {
        this.status = MyPromise.REJECTED;
        this.reason = reason;
        this.onRejectedCallbacks.forEach(cb => cb());
      }
    };
    try {
      executor(resolve, reject);
    } catch (err) {
      reject(err);
    }
  }
  then(onFulfilled, onRejected) {
    onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : value => value;
    onRejected = typeof onRejected === 'function' ? onRejected : reason => { throw reason };
    return new MyPromise((resolve, reject) => {
      if (this.status === MyPromise.FULFILLED) {
        setTimeout(() => {
          try {
            const res = onFulfilled(this.value);
            resolve(res);
          } catch (err) {
            reject(err);
          }
        });
      }
      if (this.status === MyPromise.REJECTED) {
        setTimeout(() => {
          try {
            const res = onRejected(this.reason);
            resolve(res);
          } catch (err) {
            reject(err);
          }
        });
      }
      if (this.status === MyPromise.PENDING) {
        this.onFulfilledCallbacks.push(() => {
          setTimeout(() => {
            try {
              const res = onFulfilled(this.value);
              resolve(res);
            } catch (err) {
              reject(err);
            }
          });
        });
        this.onRejectedCallbacks.push(() => {
          setTimeout(() => {
            try {
              const res = onRejected(this.reason);
              resolve(res);
            } catch (err) {
              reject(err);
            }
          });
        });
      }
    });
  }
  catch(onRejected) {
    return this.then(undefined, onRejected);
  }
  static all(promises) {
    return new MyPromise((resolve, reject) => {
      const result = [];
      let count = 0;
      promises.forEach((p, index) => {
        MyPromise.resolve(p).then(res => {
          result[index] = res;
          count++;
          if (count === promises.length) resolve(result);
        }, err => reject(err));
      });
    });
  }
  static race(promises) {
    return new MyPromise((resolve, reject) => {
      promises.forEach(p => {
        MyPromise.resolve(p).then(resolve, reject);
      });
    });
  }
}
```

### 题目5：什么是函数柯里化和偏函数？二者的区别是什么？手写实现柯里化函数，说明其在前端业务中的实际应用。

**标准答案**：

**1. 函数柯里化**：把接受多个参数的函数，转换成接受单一参数的函数，并且返回接受余下参数、最终返回结果的新函数，核心是**分步接收参数，延迟执行**，直到参数接收完毕才执行原函数。

**2. 偏函数**：固定函数的部分参数，生成一个接受剩余参数的新函数，核心是**预设部分参数，简化后续调用**，无需等所有参数接收完毕，可直接执行。

**3. 核心区别**：柯里化是将多参函数拆分为多个单参函数，分步传参；偏函数是固定部分参数，直接生成新函数，传参次数更少；柯里化可实现偏函数，偏函数是柯里化的特殊场景。

**4. 手写通用柯里化函数**：

```javascript
function curry(fn) {
  return function curried(...args) {
    // 参数接收完毕，执行原函数
    if (args.length >= fn.length) {
      return fn.apply(this, args);
    }
    // 继续接收参数
    return (...nextArgs) => curried.apply(this, [...args, ...nextArgs]);
  };
}
// 测试
function add(a, b, c) { return a + b + c }
const curriedAdd = curry(add);
console.log(curriedAdd(1)(2)(3)); // 6
console.log(curriedAdd(1,2)(3)); // 6
```

**5. 前端业务应用场景**：

- **参数复用**：封装通用请求函数，固定baseURL、请求头，后续调用只传接口参数。

- **延迟执行**：表单校验、事件触发逻辑，分步接收校验规则和数据。

- **函数复用**：封装通用工具函数，固定部分配置，适配不同业务场景。

- **防抖节流定制**：固定延迟时间，生成不同业务的防抖节流函数。

### 题目6：讲解this的绑定规则（默认绑定、隐式绑定、显式绑定、new绑定），分析箭头函数的this特性，结合复杂场景代码判断this指向，说明bind方法的底层实现和多次bind的效果。

**标准答案**：

**1. this四大绑定规则（优先级：new绑定 > 显式绑定 > 隐式绑定 > 默认绑定）**：

- **默认绑定**：函数独立调用，非严格模式下this指向window/global，严格模式下指向undefined。

- **隐式绑定**：函数作为对象方法调用，this指向调用该方法的对象（谁调用指向谁）。

- **显式绑定**：通过call、apply、bind强制绑定this，指向指定的对象，绑定后无法修改。

- **new绑定**：通过new关键字调用构造函数，this指向新创建的实例对象。

**2. 箭头函数this特性**：

- 箭头函数没有自己的this，其this继承自**定义时所在作用域的this**（词法this），而非执行时。

- 无法通过call、apply、bind修改箭头函数的this，new关键字也无法调用箭头函数。

- 箭头函数没有arguments、super、原型，不适合作为构造函数、对象方法。

**3. bind方法底层实现**：bind是Function原型方法，用于永久绑定this和预设参数，返回一个新函数，新函数调用时执行原函数，核心是利用闭包保留this和参数。

```javascript
Function.prototype.myBind = function(context, ...args) {
  const fn = this;
  return function(...newArgs) {
    return fn.apply(context, [...args, ...newArgs]);
  };
}
```

**4. 多次bind效果**：bind方法只会生效第一次绑定的this，后续多次bind无法修改this指向，因为bind返回的新函数内部已经固定了this，再次bind只是嵌套闭包，无法覆盖原有this。

**5. 复杂场景this判断**：对象方法嵌套函数、定时器、回调函数中，普通函数会丢失隐式绑定，指向window/undefined；箭头函数则继承外层this，可解决this指向混乱问题。

### 题目7：阐述垃圾回收机制（标记清除、引用计数）的原理，分析前端常见的内存泄漏场景（闭包、定时器、DOM引用、事件监听未移除等），如何通过Chrome DevTools定位和解决内存泄漏问题。

**标准答案**：

**1. 垃圾回收机制原理**：JavaScript引擎自动回收不再使用的内存，避免内存溢出，主流回收算法为标记清除和引用计数。

- **标记清除（主流）**：从全局对象（根对象）开始，递归标记所有可达对象，未标记的对象视为垃圾，直接回收；解决了循环引用问题，是V8引擎核心算法。

- **引用计数**：为每个对象维护引用计数器，对象被引用一次计数+1，引用解除计数-1，计数为0时回收；缺点是无法处理循环引用（如对象相互引用），会导致内存泄漏。

**2. 前端常见内存泄漏场景**：

- 意外全局变量：未用var/let/const声明的变量，挂载到window，长期驻留内存。

- 闭包滥用：长期持有DOM、大型数据引用，作用域无法销毁。

- 定时器/回调未清理：setTimeout、setInterval、事件监听、订阅模式未及时移除。

- DOM引用残留：删除DOM节点后，仍有JS变量持有该DOM引用，导致DOM无法回收。

- 缓存未限制：无限增长的缓存对象，未做过期清理。

- Console日志：开发环境console打印大型对象，生产环境未清除，阻碍垃圾回收。

**3. Chrome DevTools定位与解决**：

- **Performance面板**：录制页面操作，观察内存走势，持续上升无回落则存在泄漏。

- **Memory面板**：
       

    - 堆快照（Heap snapshot）：抓取内存快照，查找未回收的DOM、对象，定位泄漏源。

    - 分配时间线（Allocation instrumentation on timeline）：实时监控内存分配，定位泄漏代码位置。

- **解决方法**：及时清理定时器、事件监听；解除DOM引用赋值为null；避免滥用闭包；全局变量模块化管理；缓存设置过期策略；生产环境清除console。

### 题目8：解释深拷贝和浅拷贝的区别，手写实现一个支持正则、Date、Map、Set、函数、循环引用的完整深拷贝函数，对比JSON.parse(JSON.stringify)的缺陷。

**标准答案**：

**1. 深拷贝与浅拷贝核心区别**：

- **浅拷贝**：只拷贝对象的第一层属性，引用类型属性仅拷贝引用地址，修改拷贝后的引用属性，原对象会同步改变；常用方法：Object.assign、展开运算符...、数组slice/concat。

- **深拷贝**：递归拷贝对象所有层级属性，完全开辟新内存，拷贝对象与原对象无任何引用关联，修改拷贝对象不影响原对象；常用方法：手写深拷贝、Lodash.cloneDeep。

**2. JSON.parse(JSON.stringify)缺陷**：

- 无法拷贝undefined、Symbol、函数，会直接忽略。

- 无法拷贝RegExp、Date对象，会转为空对象或字符串。

- 无法处理循环引用，会直接报错。

- 无法拷贝Map、Set、原型属性，会丢失数据。

**3. 完整版深拷贝手写实现**：

```javascript
function deepClone(target, map = new WeakMap()) {
  // 处理基础数据类型
  if (typeof target !== 'object' || target === null) {
    return target;
  }
  // 处理循环引用
  if (map.has(target)) {
    return map.get(target);
  }
  // 处理特殊对象
  let cloneTarget;
  const constructor = target.constructor;
  switch (constructor) {
    case Date:
      cloneTarget = new Date(target);
      break;
    case RegExp:
      cloneTarget = new RegExp(target.source, target.flags);
      break;
    case Map:
      cloneTarget = new Map();
      map.set(target, cloneTarget);
      target.forEach((val, key) => cloneTarget.set(deepClone(key, map), deepClone(val, map)));
      return cloneTarget;
    case Set:
      cloneTarget = new Set();
      map.set(target, cloneTarget);
      target.forEach(val => cloneTarget.add(deepClone(val, map)));
      return cloneTarget;
    case Function:
      return target;
    default:
      cloneTarget = new constructor();
  }
  map.set(target, cloneTarget);
  // 递归拷贝普通对象/数组
  Reflect.ownKeys(target).forEach(key => {
    cloneTarget[key] = deepClone(target[key], map);
  });
  return cloneTarget;
}
```

### 题目9：什么是异步编程？对比回调函数、Promise、Generator、async/await四种异步方案的演进和优缺点，分析async/await的底层实现原理（Generator+Promise）。

**标准答案**：

**1. 异步编程本质**：解决JavaScript单线程阻塞问题，允许程序在等待异步任务（I/O、定时器、网络请求）时，继续执行其他代码，任务完成后通过回调或同步写法处理结果。

**2. 四种异步方案对比**：

- **回调函数**：最早异步方案，通过回调函数处理异步结果；优点是实现简单，兼容低版本；缺点是嵌套过深形成**回调地狱**，代码可读性差、异常捕获困难、难以维护。

- **Promise**：解决回调地狱，链式调用，状态管理清晰；优点是代码扁平化，支持异常捕获、并行/竞争执行；缺点是无法取消，错误捕获繁琐，仍有then链，语义不够直观。

- **Generator**：ES6引入，可暂停/恢复执行的函数，通过yield关键字分割异步任务；优点是异步代码同步写法，可控制执行流程；缺点是需要手动执行器（co库），使用繁琐，语法复杂。

- **async/await**：ES7引入，基于Promise和Generator的语法糖，是现代最优异步方案；优点是语法极简、语义清晰，同步写法处理异步，支持try/catch异常捕获，可取消、可并发；缺点是需兼容ES7+，本质依赖Promise。

**3. async/await底层原理**：

- async函数本质是Generator函数的语法糖，内置自动执行器，无需手动调用next()。

- async函数返回一个Promise对象，await关键字等价于yield，后面只能跟Promise（非Promise会转为立即resolve的Promise）。

- 执行流程：async函数执行时，遇到await暂停执行，等待Promise状态变更，Promise resolve后恢复执行，返回结果；reject则抛出异常，通过try/catch捕获。

- 底层实现：将async函数编译为Generator函数，配合Promise和自动执行器，实现异步流程同步化。

### 题目10：讲解变量提升、函数提升的机制，分析var、let、const的区别，说明暂时性死区的形成原因，以及块级作用域的实现原理。

**标准答案**：

**1. 变量提升与函数提升机制**：

- **变量提升（var）**：JS代码执行前，编译器会扫描所有var声明的变量，将变量声明提升到当前作用域顶部，只提升声明，不提升赋值，初始值为undefined。

- **函数提升**：函数声明（function fn(){}）会整体提升到当前作用域顶部，优先级高于变量提升，可在声明前调用；函数表达式（var fn=function(){}）仅变量提升，赋值不提升。

**2. var、let、const核心区别**：

|特性|var|let|const|
|---|---|---|---|
|作用域|函数作用域|块级作用域|块级作用域|
|变量提升|有，初始值undefined|有（编译阶段提升），无初始值|有（编译阶段提升），无初始值|
|重复声明|允许|不允许|不允许|
|重新赋值|允许|允许|不允许（引用类型可修改属性）|
|暂时性死区|无|有|有|
**3. 暂时性死区（TDZ）形成原因**：let/const声明的变量，在块级作用域内，从作用域开始到变量声明语句之间的区域，无法访问该变量，称为暂时性死区；本质是JS引擎编译时会提升let/const变量，但不会初始化，只有执行到声明语句时才会初始化，期间访问会报错ReferenceError。

**4. 块级作用域实现原理**：ES6通过let/const实现块级作用域（{}包裹的区域，如if、for、while），底层通过词法作用域和执行上下文栈实现，块级作用域内的变量不会泄露到外部，解决了var变量泄露、循环变量污染问题。

## 二、浏览器原理与网络通信（高阶必问）

### 题目1：从输入URL到页面渲染完成，整个过程发生了什么？详细拆解DNS解析、TCP三次握手、HTTP请求、响应处理、浏览器渲染流程。

**标准答案**：

1. **DNS域名解析**：将域名转换为IP地址，依次查询浏览器缓存、系统缓存、路由器缓存、ISP DNS服务器、根DNS服务器、顶级域名服务器、权威DNS服务器，最终获取目标服务器IP。

2. **TCP三次握手**：客户端与服务器建立可靠TCP连接，① 客户端发送SYN包请求连接；② 服务器返回SYN+ACK包同意连接；③ 客户端发送ACK包确认连接，连接建立成功。

3. **发送HTTP/HTTPS请求**：客户端构建请求头、请求体，发送请求到服务器，HTTPS会额外进行TLS/SSL握手，完成加密通信。

4. **服务器处理请求并响应**：服务器接收请求，处理业务逻辑，返回HTTP响应（状态码、响应头、响应体HTML）。

5. **TCP四次挥手**：数据传输完毕，客户端与服务器断开连接，释放资源。

6. **浏览器解析HTML构建DOM树**：逐行解析HTML，生成DOM树，遇到CSS阻塞解析，遇到JS阻塞DOM渲染。

7. **解析CSS构建CSSOM树**：解析CSS样式，生成CSSOM树，包含所有样式规则和优先级。

8. **合成渲染树（Render Tree）**：将DOM树和CSSOM树合并，只包含可见节点，剔除display:none、head等不可见元素。

9. **布局（Layout/Reflow）**：计算渲染树节点的位置、大小，生成布局树。

10. **绘制（Paint）**：遍历渲染树，绘制节点的颜色、图片、边框等像素信息。

11. **合成（Composite）**：将绘制的图层合成，最终显示到页面，合成层可避免重排重绘，提升性能。

### 题目2：阐述浏览器缓存机制，区分强缓存（Expires、Cache-Control）和协商缓存（Last-Modified/If-Modified-Since、ETag/If-None-Match）的优先级、原理和应用场景，如何配置缓存策略优化页面加载。

**标准答案**：

**1. 浏览器缓存整体流程**：请求资源时，先检查强缓存，命中则直接使用本地缓存，不请求服务器；未命中则发送请求，检查协商缓存，命中则服务器返回304，使用本地缓存；未命中则返回200和新资源，更新缓存。

**2. 强缓存（本地缓存，无需请求服务器）**：

- **Expires**：HTTP1.0字段，值为绝对时间，浏览器对比本地时间，未过期则命中；缺点是依赖本地时间，本地时间修改会失效。

- **Cache-Control**：HTTP1.1字段，优先级高于Expires，常用值：max-age=xxx（相对过期时间，单位秒）、no-cache（跳过强缓存，走协商缓存）、no-store（不缓存）、public（客户端+代理服务器缓存）、private（仅客户端缓存）。

- 应用场景：静态资源（图片、CSS、JS），设置长缓存，提升加载速度。

**3. 协商缓存（需请求服务器，304命中）**：

- **Last-Modified/If-Modified-Since**：服务器返回资源最后修改时间，下次请求携带If-Modified-Since，服务器对比时间，未修改则304；缺点是精度到秒，秒内修改无法识别，文件修改但内容不变也会更新。

- **ETag/If-None-Match**：优先级高于Last-Modified，服务器根据资源内容生成唯一标识，下次请求携带If-None-Match，服务器对比标识，未修改则304；精度高，不受时间影响。

- 应用场景：HTML、频繁更新的接口，设置短缓存或no-cache，保证资源实时性。

**4. 缓存优化策略**：

- 静态资源（CSS/JS/图片）：配置Cache-Control: max-age=31536000，添加hash后缀，内容更新则hash变化，强制刷新缓存。

- HTML页面：配置Cache-Control: no-cache，走协商缓存，保证页面实时更新。

- 接口数据：根据业务设置合理缓存时间，频繁变动接口设置no-store，不变接口设置长缓存。

### 题目3：什么是跨域？浏览器同源策略的限制范围有哪些？列举所有跨域解决方案，说明每种方案的原理、优缺点和适用场景，重点分析CORS的简单请求和复杂请求区别。

**标准答案**：

**1. 同源策略与跨域定义**：

同源：协议、域名、端口三者完全一致；跨域：不同源之间的请求、资源访问，浏览器同源策略限制跨域行为，保障Web安全。

**2. 同源策略限制范围**：

- AJAX/ Fetch跨域请求无法发送/接收响应。

- 无法访问跨域页面的DOM、Cookie、LocalStorage、SessionStorage。

- 无法读取跨域Cookie、表单数据。

**3. 跨域解决方案汇总**：

- **CORS（跨域资源共享，主流）**：服务器设置响应头，允许跨域访问，分为简单请求和复杂请求；优点是原生支持、配置简单、功能完善；缺点是低版本IE不支持；适用场景：前后端分离项目、AJAX跨域请求。

- **JSONP**：利用script标签无跨域限制，通过回调函数获取数据；优点是兼容所有浏览器；缺点是仅支持GET请求、无异常捕获、安全性差；适用场景：兼容低版本IE的简单GET请求。

- **代理服务器**：前端请求同源代理服务器，由代理转发请求到目标服务器；优点是无浏览器限制、支持所有请求方式；缺点是增加服务器成本；适用场景：开发环境（Webpack DevServer）、生产环境Nginx代理。

- **Nginx反向代理**：Nginx配置路由规则，将跨域请求转发为同源请求；优点是性能高、配置简单；适用场景：生产环境跨域处理。

- **postMessage**：HTML5 API，用于iframe、窗口之间跨域通信；优点是安全、支持双向通信；适用场景：跨域页面嵌套、多窗口通信。

- **document.domain+iframe**：主域名相同、子域名不同场景，设置document.domain为主域名；适用场景：子域名跨域。

- **WebSocket**：无同源策略限制，实现全双工通信；适用场景：实时通信场景。

**4. CORS简单请求与复杂请求区别**：

**简单请求条件**：① 请求方法为GET、POST、HEAD；② 请求头仅包含Accept、Accept-Language、Content-Language、Content-Type（值为application/x-www-form-urlencoded、multipart/form-data、text/plain）；满足条件直接发送请求，服务器返回Access-Control-Allow-Origin即可。

**复杂请求**：不满足简单请求条件，会先发送OPTIONS预检请求，询问服务器是否允许跨域、允许的请求方法/请求头，预检通过后才发送实际请求；需服务器配置Access-Control-Allow-Methods、Access-Control-Allow-Headers、Access-Control-Max-Age等响应头。

### 题目4：讲解虚拟DOM的核心原理，虚拟DOM的优势是什么？diff算法的核心流程（树diff、组件diff、元素diff），key值的作用和不合理使用key的弊端。

**标准答案**：

**1. 虚拟DOM核心原理**：虚拟DOM是用JS对象模拟真实DOM节点的结构、属性、子节点，本质是真实DOM的JS映射，操作虚拟DOM后，通过diff算法对比新旧虚拟DOM，找出差异，批量更新真实DOM，减少DOM操作次数。

**2. 虚拟DOM优势**：

- 减少频繁DOM操作：DOM操作性能极低，虚拟DOM将多次DOM操作合并为一次批量更新，提升性能。

- 跨平台兼容：虚拟DOM基于JS，可适配Web、小程序、App等多平台，实现一次编写多端运行。

- 简化开发：无需手动操作DOM，专注数据逻辑，实现数据驱动视图。

- 容错性高：diff算法自动处理DOM更新，避免手动操作DOM导致的bug。

**3. diff算法核心流程**：

- **树diff**：逐层对比新旧虚拟DOM树，只对比同层级节点，跨层级节点不对比，降低算法复杂度（O(n)）。

- **组件diff**：同层级组件，类型不同直接销毁旧组件，创建新组件；类型相同则对比组件属性，更新属性即可。

- **元素diff**：同层级元素，通过key标识唯一节点，对比key、标签、属性，找出新增、删除、修改、移动的节点，精准更新。

**4. key值作用与弊端**：

作用：作为元素唯一标识，diff算法通过key快速定位节点，判断节点是否复用、移动，提升diff效率，避免节点错乱。

弊端：① 用index作为key：列表顺序变化、增删时，index会改变，导致diff算法误判，节点复用错误，出现数据错乱、视图不同步问题；② key重复：导致diff算法混淆，渲染异常；③ key不稳定：随机生成key，无法复用节点，性能变差。

### 题目5：分析浏览器重排（回流）和重绘的原理，哪些操作会触发重排重绘？如何通过代码优化减少重排重绘。

**标准答案**：

**1. 重排与重绘原理**：

- **重排（回流/Reflow）**：DOM节点的位置、大小、布局发生变化，浏览器重新计算节点几何信息，重新生成布局树，重排开销极大，会触发后续重绘。

- **重绘（Repaint）**：DOM节点样式改变（颜色、背景、边框），但布局未变，浏览器重新绘制节点样式，开销比重排小。

**2. 触发重排的操作**：

- 添加/删除/修改DOM节点。

- 修改元素尺寸（宽高、边距、边框）、位置、display属性。

- 修改窗口大小、滚动页面。

- 获取offsetWidth、offsetHeight、clientWidth等布局属性（浏览器强制刷新布局队列）。

**3. 触发重绘的操作**：修改color、background、visibility、box-shadow等不影响布局的样式。

**4. 优化方案**：

- 批量修改DOM：使用文档碎片（DocumentFragment），先将DOM添加到碎片，再一次性插入页面。

- 离线操作DOM：先将元素display:none，修改完毕后恢复显示，减少重排次数。

- 避免频繁获取布局属性：将布局属性缓存到变量，避免多次读取触发强制重排。

- CSS合成层：将频繁变动的元素提升为独立合成层（will-change、transform），重排重绘只影响当前层。

- 使用CSS类替换样式修改：批量修改样式类，而非逐行修改style。

- 避免table布局：table元素重排开销极大，改用flex、grid布局。

### 题目6：阐述HTTP1.0、HTTP1.1、HTTP2、HTTP3的核心区别，HTTP2的多路复用、头部压缩、服务器推送原理，HTTPS的加密流程（对称加密+非对称加密）、SSL/TLS握手过程。

**标准答案**：

### 一、HTTP1.0、HTTP1.1、HTTP2、HTTP3核心区别

|协议版本|核心特性|缺陷|
|---|---|---|
|**HTTP1.0**|短连接，每次请求新建TCP连接；无缓存、长连接机制；仅支持GET/POST/HEAD|连接开销大，并发能力极差，性能低下|
|**HTTP1.1**|长连接（Connection:keep-alive），连接复用；管道化请求；新增缓存、断点续传、PUT/DELETE等方法|队头阻塞（单连接请求排队）；头部冗余；并发请求受限（浏览器同域名6-8个）|
|**HTTP2**|二进制分帧；多路复用；头部压缩（HPACK）；服务器推送；优先级排序|基于TCP，仍存在TCP队头阻塞，握手延迟高|
|**HTTP3**|基于QUIC协议（UDP实现）；彻底解决队头阻塞；0-RTT握手；连接迁移；加密更安全|UDP易被防火墙拦截，部署成本高，兼容性待提升|
### 二、HTTP2核心特性原理

1. **二进制分帧**：将请求/响应数据拆分为二进制帧，每个帧对应一个流，打破文本协议限制，实现有序传输。

2. **多路复用**：单个TCP连接可并行传输多个请求/响应流，流之间相互独立，彻底解决HTTP1.1队头阻塞问题，大幅提升并发效率。

3. **头部压缩HPACK**：客户端和服务器维护头部索引表，传输重复头部时仅发送索引，减少头部冗余数据，降低传输体积。

4. **服务器推送**：服务器主动将客户端需要的资源（如CSS、JS）提前推送给客户端，无需客户端主动请求，减少请求往返次数。

### 三、HTTPS加密流程与SSL/TLS握手

**1. 加密原理**：采用**对称加密+非对称加密**结合的混合加密方式，兼顾安全性和效率：

- **非对称加密**（RSA）：用于加密传输对称加密密钥，解决密钥传输安全问题，公钥加密、私钥解密，密钥无需传输。

- **对称加密**（AES）：用于实际数据传输加密，加密解密速度快，适合大量数据传输。

**2. SSL/TLS握手流程**：

1. 客户端发送Client Hello：携带TLS版本、支持的加密套件、随机数Client Random。

2. 服务器回复Server Hello：确认TLS版本、加密套件，发送随机数Server Random，返回数字证书（含公钥）。

3. 客户端验证证书合法性，生成预主密钥Pre-master Secret，用服务器公钥加密后发送给服务器。

4. 服务器用私钥解密预主密钥，双方通过Client Random、Server Random、Pre-master Secret生成相同的会话密钥（对称密钥）。

5. 双方发送握手完成消息，后续数据传输均用会话密钥加密解密。

### 题目7：什么是Web安全？详细说明XSS攻击（存储型、反射型、DOM型）的原理、危害和防范措施，CSRF攻击的原理和防范方案，以及SQL注入、点击劫持、中间人攻击的防护策略。

**标准答案**：

**1. Web安全定义**：Web安全是防范Web应用被攻击、数据泄露、篡改、非法访问的安全体系，核心防范XSS、CSRF、SQL注入、中间人攻击等常见漏洞，保障用户数据和业务系统安全。

### 一、XSS跨站脚本攻击

**原理**：攻击者在Web页面注入恶意JS代码，用户浏览时浏览器执行恶意代码，窃取用户信息、劫持会话、篡改页面。

**类型、危害与防范**：

- **存储型XSS**：恶意代码存入服务器数据库，所有访问该页面的用户都会执行，危害极大（如评论区、留言板）；防范：服务端+客户端双重转义，过滤恶意脚本。

- **反射型XSS**：恶意代码拼接在URL中，诱导用户点击，服务端反射到页面执行，非持久化（如搜索页、跳转页）；防范：URL参数转义，禁止直接渲染URL参数。

- **DOM型XSS**：恶意代码直接修改前端DOM，不经过服务器，前端JS直接执行（如innerHTML、document.write）；防范：避免使用不安全DOM操作，用textContent替代innerHTML，前端过滤输入。

**通用防范措施**：输入校验、输出转义（转义<、>、&、"、'等字符）、设置CSP内容安全策略、HttpOnly Cookie禁止JS读取Cookie。

### 二、CSRF跨站请求伪造

**原理**：攻击者诱导用户访问恶意网站，利用用户已登录的会话身份，在恶意网站发起跨站请求，伪造用户操作（如转账、改密、发帖）。

**防范方案**：

- 使用Token验证：接口请求携带CSRF Token，服务器校验Token合法性。

- 设置SameSite Cookie：Strict/Lax模式，限制Cookie跨站携带。

- 验证来源：校验Referer/Origin请求头，仅允许可信域名请求。

- 敏感操作二次验证：短信验证码、密码二次确认。

### 三、其他常见攻击防护

- **SQL注入**：原理：攻击者在输入框拼接SQL语句，非法操作数据库；防范：使用预编译语句（Prepared Statement）、参数化查询，禁止直接拼接SQL，输入校验，权限最小化。

- **点击劫持**：原理：攻击者用透明iframe覆盖页面，诱导用户点击隐藏按钮；防范：设置X-Frame-Options响应头（DENY/SAMEORIGIN），禁止iframe嵌套，JS顶层跳转防护。

- **中间人攻击**：原理：攻击者拦截客户端与服务器通信，窃取、篡改数据；防范：使用HTTPS，禁用HTTP，校验证书合法性，启用HSTS强制HTTPS，防止SSL剥离。

### 题目8：讲解浏览器的同源策略，iframe跨域通信的实现方式，postMessage的使用注意事项，如何实现不同子域名、主域名之间的跨域数据共享。

**标准答案**：

**1. 同源策略**：浏览器核心安全策略，要求协议、域名、端口三者完全一致，限制跨域DOM访问、Cookie/Storage读取、AJAX请求，防止恶意网站窃取数据。

**2. iframe跨域通信方式**：

- **postMessage（推荐）**：HTML5官方API，支持跨协议、跨域名通信，安全可控。

- **document.domain**：适用于主域名相同、子域名不同场景，设置相同主域名实现跨域。

- **location.hash**：通过URL hash值传递数据，兼容性好，数据量小。

- **window.name**：利用window.name跨页面持久化特性传递数据，数据量较大。

**3. postMessage使用注意事项**：

- 发送数据：targetWindow.postMessage(data, targetOrigin)，targetOrigin必须指定具体域名，禁止用*，防止数据泄露。

- 接收数据：监听message事件，校验event.origin来源，仅处理可信域名消息。

- 数据序列化：传输复杂对象用JSON.stringify序列化，避免传输敏感数据。

- 防止恶意监听：避免接收不可信域名消息，做好数据校验。

**4. 不同域名跨域数据共享方案**：

- **子域名共享**：document.domain = '主域名'，实现Cookie、LocalStorage共享。

- **主域名跨域**：使用postMessage双向通信，或通过服务端代理、共享Cookie（父域名Cookie）。

- **全局数据共享**：借助中间页面、localStorage+postMessage、服务端接口同步实现数据互通。

### 题目9：分析Service Worker的原理、生命周期，PWA的核心特性，Service Worker实现离线缓存、消息推送的流程，以及注册和使用Service Worker的注意事项。

**标准答案**：

**1. Service Worker原理**：独立于主线程的后台脚本线程，运行在浏览器后台，可拦截、代理、缓存网络请求，实现离线访问、消息推送、后台同步，无DOM操作权限，生命周期独立。

**2. 生命周期流程**：

1. 注册（register）：主线程调用navigator.serviceWorker.register()注册，返回Promise。

2. 安装（install）：首次注册触发，缓存核心静态资源，安装成功进入等待态。

3. 等待（waiting）：等待旧Service Worker销毁，可调用skipWaiting()直接激活。

4. 激活（activate）：清理旧缓存，接管页面，可处理fetch、push事件。

5. 废弃（redundant）：注册失败、版本更新时触发，Service Worker失效。

**3. PWA核心特性**：离线访问、添加到主屏幕、消息推送、后台同步、沉浸式体验、加载速度快，兼具Web和原生App优势。

**4. 离线缓存实现流程**：

1. install事件中，通过Cache API缓存核心静态资源（HTML、CSS、JS、图片）。

2. 监听fetch事件，拦截网络请求，优先读取缓存资源，无缓存则发起网络请求。

3. activate事件中，清理过期缓存，避免缓存冗余。

**5. 消息推送流程**：

1. 用户授权推送权限，Service Worker注册推送服务，获取推送订阅ID。

2. 服务器通过订阅ID向推送服务发送推送消息。

3. 浏览器监听push事件，Service Worker接收消息，调用registration.showNotification()展示通知。

**6. 使用注意事项**：

- 必须在HTTPS环境下运行（localhost开发环境除外）。

- 缓存资源需合理管理，避免缓存过大、过期资源占用。

- 处理好版本更新，及时激活新Service Worker。

- 异常捕获，避免Service Worker报错导致功能失效。

### 题目10：什么是内存溢出和内存泄漏？二者的区别是什么？在前端单页应用中如何监控和优化内存使用？

**标准答案**：

**1. 内存溢出（OOM）**：程序运行过程中，申请的内存超出系统剩余可用内存，导致程序崩溃、页面卡死，是内存使用超限的结果。

**2. 内存泄漏**：程序中已不再使用的内存，因意外引用无法被垃圾回收机制回收，长期累积导致内存占用持续升高，是内存溢出的主要原因。

**3. 核心区别**：内存泄漏是“无用内存无法回收”的过程，内存溢出是“内存不足”的结果；内存泄漏长期积累会引发内存溢出。

**4. 单页应用内存监控方法**：

- Chrome DevTools Performance面板：录制操作流程，观察内存趋势，判断是否存在泄漏。

- Chrome DevTools Memory面板：堆快照、分配时间线，定位泄漏对象、DOM节点。

- 监控内存指标：通过window.performance.memory获取内存使用数据，异常上报。

**5. 内存优化方案**：

- 及时清理定时器、事件监听、订阅、WebSocket连接。

- 避免全局变量滥用，模块化管理变量，无用变量赋值为null。

- 组件销毁时，解除DOM引用、闭包引用、第三方实例引用。

- 虚拟列表渲染长数据，避免大量DOM节点占用内存。

- 合理使用缓存，设置缓存过期机制，避免无限增长。

- 避免频繁创建大型对象、闭包，优化递归、循环逻辑。

## 三、前端框架原理与实战（Vue/React 二选一深度）

### Vue 方向

### 题目1：分析Vue2和Vue3的核心差异，Vue3的Composition API相比Options API的优势，Vue3响应式原理（Proxy vs Object.defineProperty）的区别，Proxy的优势和缺陷。

**标准答案**：

**1. Vue2与Vue3核心差异**：

- **响应式原理**：Vue2用Object.defineProperty劫持对象属性，Vue3用Proxy代理整个对象。

- **API设计**：Vue2用Options API（data/methods/mounted），Vue3主推Composition API（setup）。

- **性能优化**：Vue3编译优化（静态提升、补丁标记、事件缓存），打包体积更小，渲染速度更快。

- **TS支持**：Vue3基于TS重构，原生支持TS，类型推导更完善。

- **新特性**：Teleport、Suspense、Fragment、Pinia状态管理，移除filter、$on等废弃API。

**2. Composition API相比Options API优势**：

- 逻辑复用：将分散的业务逻辑封装为独立钩子函数，避免mixin命名冲突、来源不明问题。

- 代码组织：复杂组件逻辑集中管理，可读性、可维护性大幅提升。

- 类型支持：完美适配TS，类型推导更精准。

- 按需引入：Tree-shaking友好，减小打包体积。

- 逻辑共享：自定义钩子跨组件复用，更灵活、更可控。

**3. Proxy与Object.defineProperty区别**：

|特性|Object.defineProperty（Vue2）|Proxy（Vue3）|
|---|---|---|
|劫持方式|劫持对象单个属性，需递归遍历|代理整个对象，无需递归，深层对象懒劫持|
|新增/删除属性|无法监听，需用Vue.set/Vue.delete|可监听对象新增、删除属性|
|数组监听|重写数组7个方法，无法监听索引修改、length变更|可正常监听数组索引、length、增删操作|
|性能|递归劫持，初始渲染性能低|懒劫持，仅访问时劫持，性能更优|
|兼容性|兼容IE8及以上|不支持IE，兼容现代浏览器|
**4. Proxy优势与缺陷**：

优势：可监听对象/数组全操作，无需递归，性能更好，支持13种拦截方法，功能更强大；缺陷：不兼容IE浏览器，无法代理基础数据类型，部分特殊对象（Map/Set）需额外处理。

### 题目2：详细讲解Vue的响应式原理，数据劫持、依赖收集、派发更新的完整流程，computed和watch的底层实现原理，以及二者的区别和使用场景。

**标准答案**：

**1. Vue响应式完整流程**：

1. **数据劫持**：初始化时，通过Proxy（Vue3）/Object.defineProperty（Vue2）劫持data对象的get/set方法，监听数据读写。

2. **依赖收集**：组件渲染时，访问data属性触发get方法，将当前渲染Watcher收集到属性的Dep（依赖管理器）中，建立数据与Watcher的关联。

3. **派发更新**：修改data属性触发set方法，Dep通知所有关联Watcher执行更新，重新渲染组件。

**2. computed底层原理**：

- 本质是惰性求值的Watcher，具备缓存特性。

- 初始化时创建computed Watcher，默认不执行求值，依赖数据未变更时，直接返回缓存结果。

- 依赖数据变更时，标记为脏数据，下次访问时重新求值，更新缓存。

**3. watch底层原理**：

- 本质是普通Watcher，监听指定数据，数据变更时立即执行回调。

- 支持深度监听（deep）、立即执行（immediate），可监听对象、数组、基础数据类型。

**4. computed与watch区别及使用场景**：

- **computed**：有缓存，依赖多个数据，返回计算结果，无副作用；场景：数据渲染、数据格式化、多数据联动计算。

- **watch**：无缓存，监听单个/少数数据，执行异步/复杂逻辑，可有副作用；场景：数据变更发起请求、监听路由变化、复杂业务逻辑处理。

### 题目3：Vue的虚拟DOM和diff算法实现细节，Vue2和Vue3 diff算法的优化点，Vue的key值为什么不能用index，v-for和v-if为什么不能连用。

**标准答案**：

**1. Vue虚拟DOM与diff算法细节**：

Vue通过h函数生成虚拟DOM，diff算法采用**同层级比对**，复杂度优化为O(n)，核心是双端比对：

- 新旧节点首尾双指针遍历，优先比对头头、尾尾、头尾、尾尾节点，快速找到可复用节点。

- 无匹配节点时，通过key查找对应节点，复用或新增节点。

- 比对完成后，删除多余旧节点，新增未匹配新节点。

**2. Vue3 diff算法优化点**：

- 新增静态提升，静态节点不参与diff，减少比对开销。

- 补丁标记（Patch Flag）：仅标记动态属性、动态文本，diff时只比对动态部分。

- 事件缓存：绑定事件缓存复用，避免重复创建。

- 长列表优化：快速区分新增、删除、移动节点，提升比对效率。

**3. key值不能用index原因**：

index是数组索引，列表增删、排序时index会同步变更，key失去唯一性，diff算法无法精准识别节点，导致节点复用错误、视图错乱、数据绑定异常，甚至引发性能问题，必须用唯一且稳定的id作为key。

**4. v-for和v-if不能连用原因**：

Vue2中v-for优先级高于v-if，会先循环所有节点，再逐个判断v-if，造成性能浪费；Vue3中v-if优先级高于v-if，会导致无法访问v-for中的循环变量，逻辑异常，正确做法是用computed过滤列表后再渲染。

### 题目4：Vue组件通信的所有方式，分析每种方式的适用场景和底层原理。

**标准答案**：

- **props/$emit**：父子组件通信，父传子props，子传父$emit触发事件；适用：父子单向数据流，最常用。

- **$parent/$children**：父子组件直接访问实例；适用：简单父子通信，不推荐复杂场景，耦合度高。

- **provide/inject**：祖孙/跨级组件通信，父provide提供数据，后代inject注入；适用：跨级深层组件，无需中间组件传递。

- **eventBus**：全局事件总线，$on监听、$emit触发；适用：任意组件简单通信，Vue3移除，推荐用mitt库。

- **Vuex/Pinia**：全局状态管理；适用：大型项目多组件共享复杂状态。

- **$attrs/$listeners**：父传子属性/事件，子组件未接收的props/事件自动收录；适用：跨级属性透传、组件封装。

- **ref/$refs**：父组件获取子组件实例/DOM；适用：父调用子方法、操作子组件数据。

- **slot/作用域插槽**：父子组件内容传递，子向父传递数据；适用：组件内容定制、列表项定制。

### 题目5：Vuex和Pinia的核心原理，Pinia相比Vuex的优势，手写简易版Vuex/Pinia。

**标准答案**：

**1. Vuex核心原理**：基于Vue响应式原理，全局单例模式，包含state、mutations、actions、getters、modules；state为响应式数据，mutations同步修改state，actions异步操作，getters计算属性，modules模块化拆分。

**2. Pinia核心原理**：基于Vue3响应式（reactive/ref），去除mutations，state直接响应式修改，actions支持同步/异步，模块化天然支持，无需namespaced，完整适配TS。

**3. Pinia相比Vuex优势**：

- API简洁，去除mutations，写法更直观。

- 完美支持TS，类型推导自动完成。

- 模块化无需命名空间，天然拆分，无命名冲突。

- 体积更小，性能更优，支持Vue2/Vue3。

- 支持插件扩展，数据持久化更简单。

**4. 简易版Pinia手写示例**：

```javascript
// 简易Pinia实现
import { reactive, computed } from 'vue'
class Pinia {
  constructor() {
    this.store = {}
  }
  useStore(id, store) {
    if (this.store[id]) return this.store[id]
    const { state, getters, actions } = store
    const _state = reactive(state())
    const _getters = {}
    Object.keys(getters).forEach(key => {
      _getters[key] = computed(() => getters[key](_state))
    })
    const _actions = {}
    Object.keys(actions).forEach(key => {
      _actions[key] = (...args) => actions[key].call({ state: _state, ..._getters }, ...args)
    })
    this.store[id] = { ..._state, ..._getters, ..._actions }
    return this.store[id]
  }
}
export const pinia = new Pinia()
export function defineStore(id, store) {
  return () => pinia.useStore(id, store)
}
```

### 题目6：Vue的生命周期钩子函数执行流程，父子组件生命周期执行顺序，异步组件和keep-alive的原理及应用场景。

**标准答案**：

**1. Vue组件完整生命周期（Vue3 Options）**：

创建阶段：beforeCreate → created → beforeMount → mounted

更新阶段：beforeUpdate → updated

销毁阶段：beforeUnmount → unmounted

Vue3 Composition API：setup（替代beforeCreate/created）、onBeforeMount、onMounted、onBeforeUpdate、onUpdated、onBeforeUnmount、onUnmounted

**2. 父子组件生命周期执行顺序**：

挂载：父beforeCreate → 父created → 父beforeMount → 子beforeCreate → 子created → 子beforeMount → 子mounted → 父mounted

更新：父beforeUpdate → 子beforeUpdate → 子updated → 父updated

销毁：父beforeUnmount → 子beforeUnmount → 子unmounted → 父unmounted

**3. 异步组件原理**：通过defineAsyncComponent实现，组件懒加载，仅在需要渲染时才加载对应代码，分割代码包，减小首屏体积，提升加载速度；适用：路由组件、不常用组件、大型组件。

**4. keep-alive原理**：内置抽象组件，缓存组件实例，避免重复创建销毁，提升切换性能；生命周期新增activated（激活）、deactivated（失活）；适用：列表页、表单页、频繁切换的组件，结合include/exclude/max控制缓存范围。

### 题目7：Vue的自定义指令、插件机制的实现原理，如何封装可复用的Vue组件和指令。

**标准答案**：

**1. 自定义指令原理**：全局指令通过app.directive注册，局部指令在组件内directives配置，包含生命周期钩子：created、beforeMount、mounted、beforeUpdate、updated、beforeUnmount、unmounted，指令绑定到DOM，在对应钩子执行逻辑，用于底层DOM操作、权限控制、表单处理。

**2. 插件机制原理**：插件是包含install方法的对象，接收app实例作为参数，可注册全局组件、指令、混入、挂载全局方法，通过app.use()安装，实现功能扩展、全局复用。

**3. 可复用组件封装原则**：

- props参数化，支持配置化，避免硬编码。

- slot插槽定制内容，提升灵活性。

- 事件$emit向外通信，遵循单向数据流。

- 样式隔离，避免全局污染，支持主题定制。

- 边界处理，兼容异常场景，添加默认值。

**4. 可复用指令封装**：提取通用DOM逻辑（如防抖、权限、复制、懒加载），通过指令复用，减少重复代码，统一逻辑规范。

### 题目8：Vue3的Teleport、Suspense组件的原理和使用场景，Vue3的编译优化做了哪些改进。

**标准答案**：

**1. Teleport（传送门）**：

原理：将组件内容渲染到指定DOM节点，脱离父组件DOM结构，不影响组件逻辑嵌套；适用：模态框、弹窗、提示框、全局加载，解决DOM层级嵌套、样式覆盖问题。

**2. Suspense（悬念组件）**：

原理：等待异步组件/setup异步函数加载完成，展示fallback兜底内容，优化异步加载体验；适用：异步路由组件、异步数据加载组件，实现优雅的加载态展示。

**3. Vue3编译优化改进**：

- 静态提升：静态节点、静态属性提升到render函数外，仅创建一次，不参与diff。

- 补丁标记：为动态节点添加Patch Flag，diff时仅比对动态内容，跳过静态内容。

- 事件缓存：绑定事件缓存复用，避免每次渲染创建新函数。

- Fragment碎片：支持多根节点组件，无需额外根节点包裹。

- 树摇优化：未使用的API、组件自动剔除，减小打包体积。

### React 方向

### 题目1：讲解React的Fiber架构原理，为什么要引入Fiber，Fiber的调和（Reconciliation）流程，时间分片的实现机制，解决了React15的什么问题。

**标准答案**：

**1. Fiber架构核心原理**：Fiber是React16推出的虚拟DOM重构架构，将虚拟DOM节点转为Fiber节点，形成链表结构，每个Fiber节点包含child（子节点）、sibling（兄弟节点）、return（父节点），实现可中断、可恢复、可优先级调度的调和流程。

**2. 引入Fiber原因**：React15采用栈调和，递归遍历虚拟DOM，一旦开始无法中断，大量DOM操作时主线程阻塞，导致页面卡顿、掉帧，影响用户体验。

**3. Fiber调和流程**：

1. 渲染阶段（Render）：可中断，遍历Fiber树，对比新旧Fiber节点，标记更新、删除、新增节点，生成Effect List，时间分片控制执行时长。

2. 提交阶段（Commit）：不可中断，遍历Effect List，批量更新真实DOM，保证视图一致性。

**4. 时间分片机制**：将长时间任务拆分为多个小任务，每个任务执行时间控制在16ms（一帧）内，执行完一个任务后，让出主线程给浏览器渲染、事件响应，避免阻塞，通过requestIdleCallback/MessageChannel实现。

**5. 解决React15问题**：彻底解决递归调和无法中断导致的主线程阻塞问题，实现任务优先级调度，提升页面流畅度，支持并发渲染、异步更新。

### 题目2：React的Hooks原理，useState、useEffect、useCallback、useMemo、useRef的底层实现，Hooks的链式调用规则，为什么Hooks不能在条件语句中使用。

**标准答案**：

**1. Hooks核心原理**：Hooks基于链表结构存储，函数组件渲染时，按顺序执行Hooks，每个Hook对应链表节点，保存状态、依赖、回调，组件更新时按相同顺序复用链表节点，实现状态持久化。

**2. 核心Hook底层实现**：

- **useState**：维护状态链表，首次渲染初始化状态，更新时调用dispatch，触发组件重新渲染，返回最新状态和更新函数。

- **useEffect**：存储回调函数和依赖数组，渲染阶段标记副作用，提交阶段执行，依赖变更时重新执行，组件卸载时执行清理函数。

- **useCallback**：缓存函数引用，依赖不变时返回同一函数，避免子组件不必要渲染。

- **useMemo**：缓存计算结果，依赖不变时复用结果，避免重复计算。

- **useRef**：返回可变ref对象，current属性持久化，不随渲染变化，可存储DOM、变量、定时器。

**3. Hooks链式调用规则**：必须在函数组件顶层、自定义Hooks顶层调用，保证每次渲染执行顺序完全一致，依赖链表顺序存储状态，不可中断、不可嵌套。

**4. 不能在条件语句使用原因**：条件语句会导致Hooks执行顺序改变，链表节点错位，状态错乱、报错，React依赖固定执行顺序实现状态复用，强制要求顺序调用。

### 题目3：React类组件和函数组件的区别，React的虚拟DOM和diff算法，React的key值作用，列表渲染的优化。

**标准答案**：

**1. 类组件与函数组件区别**：

- 类组件：继承React.Component，有生命周期、this、state实例状态，代码冗余，逻辑复用难，性能开销大。

- 函数组件：无this、无生命周期，基于Hooks实现状态和副作用，代码简洁，逻辑复用灵活，性能更优，是React推荐写法。

**2. React虚拟DOM与diff算法**：

虚拟DOM：JS对象描述DOM结构，对比差异后批量更新；diff算法：同层级比对，类型不同直接替换，类型相同对比属性，列表通过key优化，复杂度O(n)。

**3. key值作用**：标识列表唯一节点，diff算法快速定位节点，判断节点复用、移动、删除，提升diff效率，避免节点错乱，禁止用index作为key。

**4. 列表渲染优化**：使用唯一稳定key；配合React.memo缓存组件；用useMemo/useCallback缓存数据和函数；长列表用虚拟列表（react-window/react-virtualized）。

### 题目4：useEffect的依赖项原理，如何避免useEffect无限循环，useEffect和useLayoutEffect的执行时机和区别。

**标准答案**：

**1. useEffect依赖项原理**：依赖项数组用于判断副作用是否需要重新执行，React通过Object.is浅比较依赖值，浅比较相等则复用上次副作用，不等则重新执行。

**2. 避免无限循环方法**：

- 依赖项传入稳定值，避免直接传入对象、数组、函数。

- 用useCallback缓存函数，useMemo缓存对象/数组。

- 无需依赖的副作用，清空依赖数组。

- 状态更新时，判断值是否变更，避免重复更新。

**3. useEffect与useLayoutEffect区别**：

- **useEffect**：异步执行，在DOM渲染完成后、浏览器绘制前执行，不阻塞渲染，适用大部分副作用（请求、定时器）。

- **useLayoutEffect**：同步执行，在DOM更新后、浏览器绘制前执行，阻塞渲染，适用DOM操作、样式计算，避免视图闪烁。

### 题目5：React组件通信方式，React Context的原理和性能优化，状态管理库的选型和原理。

**标准答案**：

**1. 组件通信方式**：props父子通信、Context跨级通信、状态管理库（Redux/Zustand/Jotai）、事件订阅、ref父子通信。

**2. Context原理**：创建全局上下文，Provider提供数据，Consumer/useContext消费数据，数据变更时，所有消费组件重新渲染。

**3. Context性能优化**：拆分Context，按业务模块分离；配合useMemo缓存Provider value；使用状态管理库替代大体积Context；避免频繁更新Context。

**4. 状态管理库选型**：

- Redux：单向数据流，适合大型复杂项目，生态完善，上手难。

- Zustand：轻量、简洁，无Provider，性能优，适合中小项目。

- Jotai：原子状态，细粒度更新，性能极佳，适合复杂状态场景。

### 题目6：React的合成事件机制，为什么要设计合成事件，合成事件和原生事件的区别，事件冒泡和捕获在React中的处理。

**标准答案**：

**1. 合成事件机制**：React基于事件委托，将所有事件绑定到document，原生事件触发后，React封装为SyntheticEvent合成事件，统一分发给对应组件处理。

**2. 设计合成事件原因**：抹平浏览器事件差异，实现跨浏览器兼容；事件委托减少内存占用；支持批量更新、事件池复用；实现React事件优先级调度。

**3. 合成事件与原生事件区别**：合成事件是React封装对象，非原生事件，有统一API；原生事件直接绑定DOM，兼容性差；合成事件阻止冒泡用e.stopPropagation，原生用e.stopPropagation，但二者冒泡机制独立。

**4. 事件冒泡处理**：React合成事件冒泡与原生事件冒泡分离，先执行原生事件，再执行合成事件；阻止合成事件冒泡不影响原生事件，阻止原生事件冒泡会阻断合成事件。

### 题目7：React的性能优化手段，原理和使用场景。

**标准答案**：

- **React.memo**：缓存函数组件，props浅比较不变则不复用，优化子组件渲染。

- **useCallback**：缓存函数，避免子组件不必要渲染。

- **useMemo**：缓存计算结果，避免重复计算。

- **useRef**：存储不变值，避免渲染触发。

- **代码分割**：React.lazy+Suspense懒加载组件，减小首屏体积。

- **虚拟列表**：渲染可视区域DOM，优化长列表性能。

- **避免内联函数/对象**：防止props引用变化导致重渲染。

### 题目8：React18的新特性，核心原理和业务应用。

**标准答案**：

- **自动批处理**：所有更新（事件、Promise、定时器）自动批处理，减少渲染次数。

- **并发渲染**：可中断、可优先级调度更新，提升页面流畅度。

- **Suspense增强**：支持数据获取、异步组件，优化加载体验。

- **Transitions**：useTransition标记非紧急更新，优先响应紧急任务。

- **SSR流式渲染**：边渲染边发送，提升首屏加载速度。

## 四、前端工程化与构建工具

### 题目1：什么是前端工程化？包含哪些核心模块，如何搭建一套完整的前端工程化体系。

**标准答案**：

**1. 前端工程化定义**：将模块化、组件化、规范化、自动化、工具化思想融入前端开发，解决传统开发混乱、复用性差、效率低、难以维护的问题，实现标准化、高效化、可扩展的开发流程。

**2. 核心模块**：

- 模块化：JS/CSS/资源模块化，隔离作用域，复用代码。

- 组件化：UI拆分独立组件，复用UI和逻辑。

- 规范化：代码规范、Git规范、文档规范、提交规范。

- 自动化：构建、编译、压缩、部署、测试自动化。

- 构建优化：代码分割、tree-shaking、压缩、缓存。

- 监控体系：错误监控、性能监控、用户行为监控。

**3. 搭建完整工程化体系**：

1. 基础搭建：选择框架，配置构建工具（Webpack/Vite），配置Babel、PostCSS。

2. 规范体系：ESLint+Prettier+Stylelint代码校验，Commitlint+husky提交规范，JS Doc文档规范。

3. 模块化组件：封装公共组件、工具函数、自定义Hooks。

4. 构建优化：代码分割、懒加载、图片压缩、CDN配置、缓存策略。

5. 自动化部署：CI/CD流程（GitHub Actions/Jenkins），自动化构建、测试、部署。

6. 监控体系：接入Sentry错误监控，性能监控，日志上报。

### 题目2：对比Webpack、Vite、Rollup、Parcel构建工具的核心差异，Vite的底层原理，相比Webpack的优势。

**标准答案**：

|工具|核心定位|原理|适用场景|
|---|---|---|---|
|**Webpack**|全能型构建工具|依赖打包，递归分析依赖，打包为bundle，开发环境dev-server热更新|大型项目、复杂工程化、多资源处理|
|**Vite**|新一代前端构建工具|开发环境ESBuild预构建，浏览器原生ES模块，HMR极速更新；生产环境Rollup打包|现代框架项目、快速开发、中小型/大型项目|
|**Rollup**|库文件打包工具|基于ES模块，tree-shaking优秀，打包体积小|JS库、组件库、工具库|
|**Parcel**|零配置构建工具|零配置，自动处理依赖，多线程编译|小型项目、快速原型开发|
**Vite底层原理**：

- 开发环境：依赖预构建（ESBuild），将CommonJS转为ES模块；基于浏览器原生ES Module，无需打包，按需加载；极速HMR，仅更新修改模块。

- 生产环境：基于Rollup打包，保证打包体积和性能。

**Vite相比Webpack优势**：启动速度极快，无需打包；热更新极速，不随项目体积变慢；配置简洁，开箱即用；原生支持ES模块，性能更优；构建速度更快。

### 题目3：Webpack的核心原理，Loader和Plugin的区别，常用Loader和Plugin的作用，手写简易Webpack Loader和Plugin，Webpack的打包流程。

**标准答案**：

**1. Webpack核心原理**：基于模块化的依赖打包工具，从入口文件出发，递归分析项目所有依赖文件，通过Loader转换非JS资源，通过Plugin扩展构建流程，最终将多模块资源打包为浏览器可识别的静态资源，核心流程分为初始化、编译、输出三大阶段。

**2. Loader与Plugin核心区别**：

- **Loader**：转换器，专注于文件编译转换，处理非JavaScript模块（如CSS、图片、TS、Vue文件），在模块编译阶段执行，遵循“从右到左、从下到上”执行顺序，单一职责，只做文件转换。

- **Plugin**：扩展器，基于事件钩子机制，贯穿整个Webpack构建周期，负责打包优化、资源管理、环境变量注入、代码压缩等，功能更全面，无执行顺序限制，监听Webpack事件触发逻辑。

**3. 常用Loader与Plugin汇总**：

- **常用Loader**：babel-loader（编译ES6+）、css-loader（解析CSS）、style-loader（注入CSS到页面）、less/sass-loader（预编译CSS）、file-loader（处理图片/字体）、url-loader（base64转码小资源）、vue-loader（解析Vue单文件组件）、ts-loader（编译TypeScript）。

- **常用Plugin**：HtmlWebpackPlugin（生成HTML并自动引入打包资源）、MiniCssExtractPlugin（抽离CSS为单独文件）、CleanWebpackPlugin（清理打包目录）、TerserWebpackPlugin（压缩JS）、OptimizeCssAssetsWebpackPlugin（压缩CSS）、DefinePlugin（注入全局环境变量）、CopyWebpackPlugin（复制静态资源）。

**4. 手写简易Webpack Loader**（以去除console.log的loader为例）

```javascript
// remove-console-loader.js
module.exports = function (content) {
  // content 为文件源码，通过正则替换 console 语句
  return content.replace(/console\.log\(.*\);?/g, '');
};
```

**5. 手写简易Webpack Plugin**（以打包完成提示插件为例）

```javascript
// BuildTipPlugin.js
class BuildTipPlugin {
  apply(compiler) {
    compiler.hooks.done.tap('BuildTipPlugin', (stats) => {
      console.log('✅ 项目打包完成，耗时：' + stats.time + 'ms');
    });
  }
}
module.exports = BuildTipPlugin;
```

**6. Webpack完整打包流程**：

1. 初始化：读取webpack.config.js配置，实例化Compiler编译器，挂载所有Plugin。

2. 编译启动：从entry入口文件开始，调用Loader编译对应模块，递归处理所有依赖。

3. 模块解析：解析模块依赖路径，查找依赖模块，重复编译步骤直至所有依赖处理完毕。

4. 代码优化：通过Plugin进行代码压缩、分割、Tree-Shaking等优化。

5. 资源输出：将编译后的模块打包为chunk，生成最终静态资源，输出到output指定目录。

### 题目4：Tree-Shaking原理、适用场景及优化配置，如何实现Webpack/Vite打包体积优化

**标准答案**：

**1. Tree-Shaking核心原理**：基于ES6模块化（import/export）的静态分析特性，在编译阶段检测未被使用的代码（死代码），将其剔除，减少打包体积，仅支持ES模块，不支持CommonJS（require）。

**2. 适用场景**：剔除工具库未使用方法、组件库未引入组件、业务中废弃代码，搭配ES模块使用，生产环境默认开启。

**3. 开启与优化配置**：

- Webpack：配置mode:production（默认开启），确保模块为ES6模块，sideEffects设置为false（标记无副作用文件，允许全量Tree-Shaking），避免使用CommonJS。

- Vite：基于ESBuild和Rollup，生产环境默认开启Tree-Shaking，无需额外配置。

**4. 打包体积全方位优化方案**：

- 代码层面：开启Tree-Shaking，剔除无用代码；采用按需引入，避免全量引入第三方库（如lodash改为lodash-es）；拆分业务代码，提取公共模块。

- 资源层面：图片压缩，小资源转base64，大资源采用WebP/AVIF格式；CSS代码压缩，抽离公共样式；第三方库采用CDN引入，不打入打包包体。

- 构建配置：开启代码分割（Code Splitting），拆分入口包、第三方依赖包、业务包；开启Gzip/Brotli压缩，配置服务器支持；使用ESBuild替代Babel提升编译速度并减小体积。

- 第三方库优化：选用轻量化库替代重型库（如Day.js替代Moment.js）；对大型库做外部扩展（externals），排除打包。

### 题目5：前端模块化演进历程，对比CommonJS、AMD、CMD、ES6 Module的区别

**标准答案**：

**1. 模块化演进阶段**：全局函数命名空间（污染严重）→ IIFE立即执行函数（闭包隔离）→ 模块化规范（CommonJS/AMD/CMD/ES6）→ 原生ES Module（现代标准）。

**2. 四大模块化规范核心对比**：

- **CommonJS（Node.js专用）**：同步加载模块，require导入，module.exports导出，运行时加载，不支持浏览器，模块缓存，适用于服务端。

- **AMD（RequireJS）**：异步加载模块，define定义模块，require导入，依赖前置，提前执行，适用于浏览器端，早期前端异步模块化方案。

- **CMD（SeaJS）**：异步加载模块，define定义模块，require导入，依赖就近，延迟执行，贴近CommonJS写法，已淘汰。

- **ES6 Module（现代标准）**：静态加载，import导入，export导出，编译时解析，支持Tree-Shaking，浏览器和Node.js双支持，支持异步导入（import()），是当前主流规范。

## 五、前端性能优化（高频综合题）

### 题目1：前端性能优化全方案（从网络、渲染、代码、资源、构建五大维度拆解）

**标准答案**：

### 一、网络层面优化

- 减少请求次数：合并CSS/JS文件，合并小图片为Sprite图，采用接口合并、批量请求，避免冗余请求。

- 优化请求体积：开启Gzip/Brotli压缩，压缩图片、JS、CSS资源，采用HTTP2多路复用，减少请求阻塞。

- 缓存优化：配置强缓存+协商缓存，本地存储（LocalStorage/SessionStorage）缓存静态数据，Service Worker离线缓存。

- DNS与TCP优化：DNS预解析（dns-prefetch），TCP预连接（preconnect），减少握手延迟。

### 二、渲染层面优化

- 减少重排重绘：批量操作DOM，使用DocumentFragment，避免频繁读取布局属性，采用CSS合成层（transform/opacity）。

- 优化渲染流程：CSS放头部，JS放底部，避免阻塞渲染；采用懒加载（图片、组件、路由），优先渲染首屏内容。

- 长列表优化：使用虚拟列表、虚拟滚动，只渲染可视区域DOM，避免大量DOM节点占用内存。

### 三、代码层面优化

- 逻辑优化：避免死循环、递归溢出，减少嵌套层级，优化算法复杂度，及时清理定时器、事件监听。

- 内存优化：避免内存泄漏，合理使用闭包，及时解除DOM引用，组件销毁时清理副作用。

- 框架优化：Vue/React中合理使用缓存（computed、useMemo、useCallback），避免不必要渲染，优化diff效率。

### 四、资源层面优化

- 图片优化：选用合适图片格式，压缩图片，懒加载，响应式图片（srcset），小图转base64。

- 字体优化：采用字体子集化，避免引入多余字体，字体懒加载，使用font-display优化字体渲染。

- 第三方资源：精简第三方脚本，异步加载第三方SDK，避免阻塞首屏渲染。

### 五、构建层面优化

- 代码分割：按路由、业务模块拆分代码，实现按需加载。

- Tree-Shaking：剔除无用代码，减小包体积。

- 压缩混淆：压缩JS/CSS/HTML，移除注释、空格，混淆代码。

- CDN加速：静态资源、第三方库部署CDN，就近访问，提升加载速度。

### 题目2：如何做前端性能监控与指标分析，核心性能指标有哪些

**标准答案**：

**1. 核心性能指标（Web Vitals）**：

- **LCP（最大内容绘制）**：衡量加载性能，目标≤2.5s，页面最大元素渲染完成时间。

- **FID/INP（首次输入延迟/交互延迟）**：衡量交互性能，目标≤100ms，用户首次交互到浏览器响应时间。

- **CLS（累积布局偏移）**：衡量视觉稳定性，目标≤0.1，页面无预期布局偏移总和。

**2. 其他关键指标**：FP（首次绘制）、FCP（首次内容绘制）、TTI（可交互时间）、TBT（总阻塞时间）。

**3. 性能监控手段**：

- 工具监控：Chrome DevTools（Performance、Lighthouse）、WebPageTest、LightHouse自动化检测。

- API监控：Performance API获取性能数据，Navigation API、Resource API采集请求、加载指标。

- 埋点上报：自定义埋点采集首屏时间、接口响应时间、卡顿数据，通过Sentry、Fundebug上报分析。

## 六、手写代码高频题（高级工程师必背）

### 题目1：手写防抖（Debounce）、节流（Throttle）函数（立即执行+立即取消版）

```javascript
// 防抖：触发后延迟执行，频繁触发重新计时
function debounce(fn, delay, immediate = false) {
  let timer = null;
  const debounced = function (...args) {
    const context = this;
    if (timer) clearTimeout(timer);
    // 立即执行
    if (immediate && !timer) {
      fn.apply(context, args);
      timer = setTimeout(null, delay);
    } else {
      timer = setTimeout(() => {
        fn.apply(context, args);
        timer = null;
      }, delay);
    }
  };
  // 取消防抖
  debounced.cancel = function () {
    clearTimeout(timer);
    timer = null;
  };
  return debounced;
}

// 节流：固定时间内只执行一次
function throttle(fn, delay) {
  let lastTime = 0;
  return function (...args) {
    const now = Date.now();
    const context = this;
    if (now - lastTime >= delay) {
      fn.apply(context, args);
      lastTime = now;
    }
  };
}
```

### 题目2：手写instanceof原理

```javascript
function myInstanceof(left, right) {
  // 基础类型直接返回 false
  if (typeof left !== 'object' || left === null) return false;
  // 获取原型对象
  let proto = Object.getPrototypeOf(left);
  while (proto) {
    if (proto === right.prototype) return true;
    proto = Object.getPrototypeOf(proto);
  }
  return false;
}
```

### 题目3：手写数组去重（多种方案）

```javascript
// 方案1：ES6 Set（最简洁）
function uniqueArr(arr) {
  return [...new Set(arr)];
}

// 方案2：遍历 + Map
function uniqueArr(arr) {
  const map = new Map();
  const res = [];
  arr.forEach((item) => {
    if (!map.has(item)) {
      map.set(item, true);
      res.push(item);
    }
  });
  return res;
}

// 方案3：遍历 + includes
function uniqueArr(arr) {
  const res = [];
  arr.forEach((item) => {
    if (!res.includes(item)) res.push(item);
  });
  return res;
}
```

### 题目4：手写数组flat扁平化函数（支持深度控制）

```javascript
function myFlat(arr, depth = 1) {
  const res = [];
  const fn = (arr, depth) => {
    arr.forEach((item) => {
      if (Array.isArray(item) && depth > 0) {
        fn(item, depth - 1);
      } else {
        res.push(item);
      }
    });
  };
  fn(arr, depth);
  return res;
}
```

## 七、项目实战与场景题（高阶面试必问）

### 题目1：大型前端项目如何做权限控制（路由权限、按钮权限、接口权限）

**标准答案**：

**1. 路由权限控制**：

- 方案1：静态路由+权限过滤，前端定义完整路由表，登录后获取用户角色，过滤无权限路由，动态注册路由。

- 方案2：动态路由，后端返回权限路由列表，前端解析生成路由表，动态添加路由，适配复杂权限场景。

- 路由守卫：全局路由守卫校验权限，无权限跳转403/登录页，避免非法访问。

**2. 按钮权限控制**：

- 自定义指令：封装v-permission指令，传入权限标识，无权限隐藏/禁用按钮。

- 函数封装：封装权限判断函数，在模板中通过v-if判断，适配复杂逻辑。

- 全局混入：将权限方法混入全局，方便全组件调用，统一权限判断逻辑。

**3. 接口权限控制**：

- 请求头携带token，后端校验接口权限，无权限返回401/403状态码。

- 前端封装响应拦截器，统一处理无权限响应，跳转登录页或提示无权限。

- 敏感接口增加二次校验，结合角色、部门做细粒度权限控制。

### 题目2：前端单点登录（SSO）实现原理及方案

**标准答案**：

**1. 单点登录核心原理**：一处登录，多系统共享登录状态，基于Token/Cookie共享实现，核心分为认证中心、子系统两部分，认证中心统一处理登录、注销、token分发。

**2. 实现方案**：

- 同域名SSO：父域名下设置Cookie，子域名共享Cookie，实现登录态同步。

- 跨域名SSO：基于OAuth2.0、JWT协议，登录跳转认证中心，认证通过后返回token，子系统通过token校验登录态，token存储在LocalStorage，通过postMessage跨域传递。

**3. 流程步骤**：子系统未登录→跳转认证中心登录页→登录成功生成token→重定向回子系统并携带token→子系统校验token→存储token并保持登录态→注销时通知认证中心销毁token，所有子系统同步注销。

### 题目3：前端大数据量渲染卡顿解决方案

**标准答案**：

- 虚拟列表/虚拟滚动：只渲染可视区域DOM，滚动时动态替换DOM内容，适配万级以上数据列表。

- 分页加载：后端分页接口，前端分页渲染，分步加载数据，避免一次性渲染大量数据。

- 懒加载+时间分片：将数据分块，利用requestIdleCallback/setTimeout分批次渲染，不阻塞主线程。

- Web Worker：将大数据计算逻辑放入Web Worker，避免计算阻塞UI渲染，分离计算线程与渲染线程。

- 数据预处理：后端做数据聚合、过滤，减少前端数据量，前端只渲染必要字段。

## 八、高频面试逻辑题与开放题

### 题目1：实现一个函数，将驼峰命名字符串转为短横线连接（如camelCase → camel-case）

```javascript
function camelToKebab(str) {
  return str.replace(/([A-Z])/g, (match) => `-${match.toLowerCase()}`);
}
```

### 题目2：如何实现前端文件上传、断点续传、大文件分片上传

**标准答案**：

- 文件上传：通过input[type=file]获取文件，FormData封装，AJAX/Fetch上传。

- 大文件分片：将文件按固定大小切片，生成唯一hash标识，逐个上传分片，后端接收合并。

- 断点续传：上传前查询已上传分片，跳过已上传部分，上传失败重试，支持暂停/继续。

- 进度展示：通过xhr.upload.onprogress实时获取上传进度，渲染进度条。

### 题目3：你平时如何排查前端线上bug，有哪些排查思路

**标准答案**：

- 日志排查：通过Sentry等监控平台获取错误堆栈、用户环境、报错信息，定位代码位置。

- 复现bug：模拟用户环境、操作步骤，本地复现问题，区分是代码bug、兼容性问题还是接口问题。

- 调试工具：Chrome DevTools断点调试、Sources面板查看源码，Network面板排查接口问题，Console查看日志。

- 兼容性排查：测试不同浏览器、设备、版本，定位兼容性bug，针对性修复。

- 线上排查：开启source-map定位源码，临时加日志埋点，回滚版本快速止损。
