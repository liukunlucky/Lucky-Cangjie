import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'

class ArticleData {
  id: number = 0
  title: string = ''
  summary: string = ''
  content: string = ''
  author: string = ''
  publishDate: string = ''
  readCount: number = 0
  likeCount: number = 0
  category: string = ''
  tags: string[] = []
  coverImage?: string
  hasCode: boolean = false
  difficulty: string = 'beginner'
  estimatedReadTime: number = 0
}

@Entry
@Component
struct ArticlePage {
  @State articles: ArticleData[] = []
  @State filteredArticles: ArticleData[] = []
  @State selectedCategory: string = '全部'
  @State searchText: string = ''
  @State isLoading: boolean = true


  private categories: string[] = ['全部', '基础语法', '面向对象', '函数编程', '并发编程', '性能优化', '实战项目', '最佳实践']

  aboutToAppear() {
    this.loadArticles()
  }

  loadArticles() {
    // Mock 仓颉技术文章数据
    this.articles = [
      {
        id: 1,
        title: '仓颉语言入门指南：从零开始学习华为自研编程语言',
        summary: '本文将带你从零开始学习仓颉语言，了解其基本语法、特性和开发环境搭建。',
        content: `# 仓颉语言入门指南

仓颉语言是华为公司自主研发的新一代编程语言，旨在为开发者提供高效、安全、易用的编程体验。作为一门现代化的编程语言，仓颉在设计理念上充分吸收了当前主流编程语言的优秀特性，同时结合了华为在软件开发领域的深厚积累。

## 语言特性与优势

仓颉语言的设计哲学体现在多个方面。首先是**类型安全**，通过静态类型系统在编译时就能发现潜在的类型错误，大大减少了运行时错误的可能性。这种设计让开发者能够更早地发现问题，提高代码质量。

在**内存安全**方面，仓颉采用了自动内存管理机制，开发者无需手动管理内存的分配和释放，有效避免了内存泄漏、野指针等常见问题。这种设计既保证了程序的稳定性，又降低了开发难度。

**高性能**是仓颉语言的另一大特色。作为编译型语言，仓颉代码会被编译成高效的机器码，运行效率接近C/C++等传统编译型语言。同时，编译器还会进行各种优化，进一步提升程序性能。

在语法设计上，仓颉追求**现代化和简洁性**。语法结构清晰明了，既保持了足够的表达能力，又避免了过度复杂的语法糖，让代码更易读、易写、易维护。

## 基础语法概览

仓颉的变量声明非常直观，使用 \`let\` 关键字声明变量，\`static let\` 声明常量。类型注解采用冒号语法，与许多现代语言保持一致：

\`\`\`cangjie
let name: String = "仓颉"
static let PI: Float = 3.14159
\`\`\`

函数定义同样简洁明了，使用 \`func\` 关键字，支持参数类型注解和返回值类型声明：

\`\`\`cangjie
func greet(name: String): String {
    return "Hello, \${name}!"
}
\`\`\`

## 开发环境与生态

要开始仓颉编程之旅，首先需要搭建开发环境。华为提供了完整的开发工具链，包括编译器、调试器、包管理工具等。开发环境的搭建过程相对简单，只需下载官方提供的开发工具包，配置相应的环境变量即可。

仓颉语言的生态系统正在快速发展中，官方和社区都在积极贡献各种库和工具。无论是系统编程、应用开发还是数据处理，都能找到相应的解决方案。

总的来说，仓颉语言代表了华为在编程语言领域的创新尝试，它不仅继承了现有语言的优秀特性，还在安全性、性能和易用性方面有所突破，值得开发者深入学习和实践。`,
        author: '华为技术专家',
        publishDate: '2024-01-15',
        readCount: 1250,
        likeCount: 89,
        category: '基础语法',
        tags: ['入门', '语法', '环境搭建'],
        coverImage: 'https://example.com/cangjie-intro.jpg',
        hasCode: true,
        difficulty: 'beginner',
        estimatedReadTime: 8
      },
      {
        id: 2,
        title: '深入理解仓颉语言的类型系统',
        summary: '探索仓颉语言强大的类型系统，包括泛型、约束和类型推导等高级特性。',
        content: `# 深入理解仓颉语言的类型系统

类型系统是编程语言的核心组成部分，它决定了语言的表达能力、安全性和性能特征。仓颉语言设计了一套强大而灵活的类型系统，既保证了类型安全，又提供了足够的表达能力来处理复杂的编程场景。

## 类型系统的设计理念

仓颉的类型系统采用静态类型检查，这意味着所有的类型错误都会在编译时被发现，而不是等到程序运行时才暴露。这种设计大大提高了程序的可靠性，让开发者能够更有信心地编写和维护代码。

与传统的静态类型语言相比，仓颉在保持类型安全的同时，还提供了类型推导功能。编译器能够根据上下文自动推断变量的类型，减少了冗余的类型注解，让代码更加简洁。

## 基本类型体系

仓颉提供了丰富的基本类型来满足不同的编程需求。整数类型 \`Int\` 用于处理整数运算，浮点类型 \`Float\` 处理小数计算，布尔类型 \`Bool\` 表示逻辑值，字符串类型 \`String\` 处理文本数据。

\`\`\`cangjie
let intValue: Int = 42
let floatValue: Float = 3.14
let stringValue: String = "Hello"
\`\`\`

这些基本类型不仅提供了基础的数据表示能力，还配备了丰富的操作方法，能够满足大部分编程场景的需求。

## 泛型编程的威力

泛型是现代编程语言的重要特性，它允许编写可重用的代码组件。仓颉的泛型系统设计得既强大又易用，支持泛型函数、泛型类和泛型约束。

通过泛型，我们可以编写一次代码，然后在多种类型上复用。比如一个交换函数，可以同时处理整数、字符串或任何其他类型的数据：

\`\`\`cangjie
func swap<T>(a: T, b: T): (T, T) {
    return (b, a)
}
\`\`\`

泛型约束进一步增强了类型系统的表达能力，允许我们对泛型参数施加特定的限制，确保类型具有某些特定的能力或属性。

## Option类型与空值安全

空指针异常是许多编程语言中的常见问题，仓颉通过 Option 类型优雅地解决了这个问题。Option 类型明确表示一个值可能存在也可能不存在，强制开发者在编译时就考虑空值的情况。

这种设计不仅消除了空指针异常的可能性，还让代码的意图更加明确。当函数返回 Option 类型时，调用者必须显式处理值不存在的情况，这大大提高了程序的健壮性。

\`\`\`cangjie
match findUser(123) {
    case Some(user) => println("找到用户: \${user.name}")
    case None => println("用户不存在")
}
\`\`\`

通过模式匹配，我们可以优雅地处理 Option 类型的不同情况，代码既安全又清晰。

## 类型推导与开发体验

仓颉的类型推导系统能够在保持类型安全的前提下，显著减少样板代码。编译器会根据赋值、函数调用、返回值等上下文信息，自动推断出变量和表达式的类型。

这种设计让开发者能够专注于业务逻辑的实现，而不是被繁琐的类型声明所困扰。同时，IDE 和编辑器也能够提供更好的代码补全和错误提示，进一步提升开发效率。

总的来说，仓颉的类型系统在安全性、表达能力和易用性之间找到了很好的平衡点，为开发者提供了强大而友好的编程体验。`,
        author: '仓颉核心开发者',
        publishDate: '2024-01-20',
        readCount: 890,
        likeCount: 67,
        category: '基础语法',
        tags: ['类型系统', '泛型', 'Option'],
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 12
      },
      {
        id: 3,
        title: '仓颉语言面向对象编程实践',
        summary: '学习如何在仓颉语言中使用类、接口和继承来构建面向对象的程序。',
        content: `# 仓颉语言面向对象编程实践

面向对象编程（OOP）是现代软件开发的重要编程范式，它通过封装、继承和多态等机制，帮助开发者构建更加模块化、可维护的软件系统。仓颉语言在设计时充分考虑了面向对象编程的需求，提供了完整而现代的面向对象特性。

## 面向对象设计理念

仓颉的面向对象设计遵循了现代编程语言的最佳实践。它强调**封装性**，通过访问控制修饰符来保护对象的内部状态；支持**继承机制**，允许子类复用和扩展父类的功能；实现了**多态性**，让同一接口可以有不同的实现。

与传统的面向对象语言相比，仓颉在保持核心概念不变的同时，简化了语法结构，减少了样板代码，让面向对象编程变得更加直观和高效。

## 类的设计与实现

在仓颉中，类是对象的蓝图，定义了对象的属性和行为。类的设计需要考虑数据的封装和方法的组织。一个设计良好的类应该具有清晰的职责边界，提供简洁的接口，隐藏实现细节。

以 Person 类为例，我们可以看到仓颉如何优雅地实现封装：

\`\`\`cangjie
class Person {
    private var name: String
    private var age: Int
    
    public init(name: String, age: Int) {
        this.name = name
        this.age = age
    }
    
    public func introduce(): String {
        return "我是\${this.name}，今年\${this.age}岁"
    }
}
\`\`\`

这个例子展示了仓颉类定义的基本结构：私有属性保护内部状态，公共构造函数提供对象创建接口，公共方法暴露对象的行为。

## 继承与代码复用

继承是面向对象编程中实现代码复用的重要机制。通过继承，子类可以获得父类的所有非私有成员，并可以添加新的功能或重写现有的方法。

仓颉的继承机制设计得既强大又安全。子类不仅可以继承父类的属性和方法，还可以通过方法重写来定制特定的行为。这种设计让代码复用变得自然而安全。

继承关系的建立需要仔细考虑，它应该反映真实世界中的"是一个"关系。比如 Student 是一个 Person，Employee 也是一个 Person，这样的继承关系是合理和自然的。

## 接口与抽象

接口定义了一组方法的契约，实现接口的类必须提供这些方法的具体实现。这种设计让我们可以定义抽象的行为规范，而不关心具体的实现细节。

仓颉的接口机制支持多重实现，一个类可以实现多个接口，这提供了比单继承更大的灵活性。通过接口，我们可以实现真正的多态性，让不同的类以统一的方式被使用。

## 多态性的应用

多态性是面向对象编程的核心特性之一，它允许同一个接口有不同的实现。在仓颉中，多态性通过继承和接口实现来支持，让程序能够在运行时根据对象的实际类型来调用相应的方法。

这种设计让代码更加灵活和可扩展。当需要添加新的类型时，只要它们实现了相同的接口或继承自相同的基类，就可以无缝地集成到现有的代码中，而不需要修改使用这些对象的代码。

## 最佳实践与设计模式

在使用仓颉进行面向对象编程时，遵循一些最佳实践可以让代码更加健壮和可维护。比如优先使用组合而不是继承，保持类的单一职责，使用接口来定义抽象等。

仓颉的语法设计也鼓励这些最佳实践的应用。清晰的访问控制、简洁的继承语法、强大的接口机制，都让开发者能够更容易地编写高质量的面向对象代码。

通过合理运用仓颉的面向对象特性，开发者可以构建出结构清晰、易于维护和扩展的软件系统，充分发挥面向对象编程的优势。`,
        author: '面向对象专家',
        publishDate: '2024-01-25',
        readCount: 756,
        likeCount: 54,
        category: '面向对象',
        tags: ['类', '继承', '接口'],
        coverImage: 'https://example.com/oop-cangjie.jpg',
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 15
      },
      {
        id: 4,
        title: '函数式编程在仓颉语言中的应用',
        summary: '探索仓颉语言的函数式编程特性，包括高阶函数、闭包和函数组合。',
        content: `# 函数式编程在仓颉语言中的应用

函数式编程是一种重要的编程范式，它将计算视为数学函数的求值，强调函数的纯粹性和不可变性。仓颉语言在设计时融入了丰富的函数式编程特性，为开发者提供了强大的函数式编程工具和概念。

## 函数式编程的核心理念

函数式编程的核心在于将函数视为一等公民，这意味着函数可以像其他数据类型一样被传递、存储和操作。这种设计理念带来了许多优势：代码更加简洁、逻辑更加清晰、更容易进行并行处理，同时也减少了副作用带来的问题。

仓颉语言对函数式编程的支持体现在多个方面。它支持高阶函数，允许函数接受其他函数作为参数或返回函数作为结果；提供了丰富的Lambda表达式语法，让匿名函数的定义变得简洁优雅；还支持函数组合，让复杂的数据处理流程可以通过简单函数的组合来实现。

## 高阶函数的威力

高阶函数是函数式编程的基石，它们接受函数作为参数或返回函数作为结果。这种设计让代码具有了更高的抽象层次和复用性。通过高阶函数，我们可以将通用的算法逻辑与具体的业务逻辑分离，创建出更加灵活和可重用的代码组件。

以数组处理为例，map、filter、reduce等高阶函数提供了强大的数据变换能力。它们不仅让代码更加简洁，还让数据处理的意图更加明确：

\`\`\`cangjie
let numbers = [1, 2, 3, 4, 5]
let doubled = map(numbers, { x => x * 2 })
\`\`\`

这种声明式的编程风格让我们专注于"做什么"而不是"怎么做"，大大提高了代码的可读性和维护性。

## Lambda表达式与简洁性

Lambda表达式（也称为匿名函数）是函数式编程中的重要工具，它允许我们在需要的地方直接定义简短的函数，而无需为每个小功能都创建命名函数。

仓颉的Lambda语法设计得既简洁又表达力强。简单的Lambda可以用于基本的数学运算，复杂的Lambda可以实现完整的数据处理流水线。这种灵活性让开发者能够根据具体场景选择最合适的表达方式。

## 函数组合与模块化

函数组合是函数式编程中的另一个重要概念，它允许我们将简单的函数组合成更复杂的函数。这种方式不仅提高了代码的模块化程度，还让复杂的逻辑变得更加清晰和可测试。

通过函数组合，我们可以构建出强大的数据处理管道。每个函数都专注于一个特定的转换操作，然后通过组合来实现复杂的业务逻辑。这种设计方式让代码更容易理解、测试和维护。

## 不可变性与纯函数

函数式编程强调不可变性和纯函数的概念。不可变性意味着数据一旦创建就不能被修改，而纯函数则是指没有副作用且对于相同输入总是产生相同输出的函数。

这些概念在并发编程中特别有价值，因为不可变数据天然是线程安全的，而纯函数的行为是可预测的。仓颉语言通过类型系统和语言特性来支持这些概念，帮助开发者编写更加安全和可靠的代码。

## 实际应用与最佳实践

在实际开发中，函数式编程特别适合数据处理、算法实现和业务逻辑的抽象。通过合理运用函数式编程的概念，我们可以创建出更加优雅和高效的解决方案。

仓颉语言的函数式特性为开发者提供了强大的工具集，无论是简单的数据变换还是复杂的业务逻辑，都可以通过函数式的方式来实现，让代码更加清晰、简洁和可维护。`,
        author: '函数式编程爱好者',
        publishDate: '2024-02-01',
        readCount: 623,
        likeCount: 45,
        category: '函数编程',
        tags: ['高阶函数', 'Lambda', '函数组合'],
        hasCode: true,
        difficulty: 'advanced',
        estimatedReadTime: 10
      },
      {
        id: 5,
        title: '仓颉语言并发编程指南',
        summary: '学习仓颉语言的并发编程模型，包括协程、Channel和并发安全。',
        content: `# 仓颉语言并发编程指南

并发编程是现代软件开发中的重要主题，它让程序能够同时处理多个任务，充分利用多核处理器的计算能力。仓颉语言提供了现代化的并发编程模型，包括协程、Channel通信和并发安全机制，为开发者构建高性能并发应用提供了强大的工具。

## 并发编程的重要性

在当今的软件开发环境中，用户对应用程序的响应速度和处理能力有着越来越高的要求。传统的单线程程序往往无法满足这些需求，而并发编程则能够让程序同时处理多个任务，显著提升用户体验和系统吞吐量。

仓颉语言的并发模型设计充分考虑了现代应用的需求，它不仅提供了高效的并发执行机制，还通过类型系统和语言特性来保证并发程序的安全性和正确性。

## 协程：轻量级的并发单元

协程是仓颉并发编程的核心概念，它们比传统线程更加轻量级，创建和切换的开销更小。协程让异步编程变得像同步编程一样直观，开发者可以用顺序的思维来编写异步代码。

通过async/await语法，仓颉让异步操作的编写变得非常自然。开发者不需要处理复杂的回调函数或Promise链，就能编写出清晰易懂的异步代码：

\`\`\`cangjie
async func fetchData(url: String): String {
    await sleep(1000)  // 模拟网络请求
    return "数据来自: \${url}"
}
\`\`\`

这种设计让并发编程的学习曲线变得更加平缓，同时也减少了并发编程中常见的错误。

## Channel：安全的通信机制

Channel是仓颉提供的另一个重要并发原语，它为不同的协程之间提供了安全的通信机制。通过Channel，协程可以安全地传递数据，而不需要担心数据竞争或同步问题。

Channel的设计遵循了"不要通过共享内存来通信，而要通过通信来共享内存"的原则。这种设计让并发程序更加安全和可预测，减少了传统并发编程中常见的死锁和竞态条件问题。

## 并发安全与数据保护

在并发环境中，数据安全是一个关键问题。仓颉提供了多种机制来保护共享数据，包括互斥锁、原子操作等。这些机制让开发者能够在需要共享状态的场景中保证数据的一致性和完整性。

仓颉的类型系统也为并发安全提供了额外的保障。通过编译时检查，许多并发相关的错误可以在开发阶段就被发现和修复，而不是等到运行时才暴露。

## 性能优化与最佳实践

仓颉的并发模型不仅注重安全性，也非常关注性能。协程的轻量级特性让程序可以创建大量的并发任务而不会消耗过多的系统资源。同时，智能的调度器能够高效地管理这些协程的执行。

在实际开发中，合理设计并发架构是获得最佳性能的关键。这包括选择合适的并发模式、避免不必要的同步操作、合理使用Channel进行通信等。

## 实际应用场景

仓颉的并发特性在许多实际场景中都能发挥重要作用，比如Web服务器的请求处理、数据处理管道、实时系统等。通过合理运用这些并发特性，开发者可以构建出既高效又可靠的并发应用程序。

总的来说，仓颉语言的并发编程模型为开发者提供了强大而安全的工具，让并发编程变得更加简单和可靠。`,
        author: '并发编程专家',
        publishDate: '2024-02-05',
        readCount: 892,
        likeCount: 78,
        category: '并发编程',
        tags: ['协程', 'Channel', '并发安全'],
        coverImage: 'https://example.com/concurrent-cangjie.jpg',
        hasCode: true,
        difficulty: 'advanced',
        estimatedReadTime: 18
      },
      {
        id: 6,
        title: '仓颉语言性能优化技巧',
        summary: '掌握仓颉语言的性能优化技巧，让你的程序运行得更快更高效。',
        content: `# 仓颉语言性能优化技巧

## 内存优化

### 避免不必要的对象创建

\`\`\`cangjie
// 不好的做法
func processStrings(strings: Array<String>): String {
    var result = ""
    for (str in strings) {
        result = result + str + " " // 每次都创建新字符串
    }
    return result
}

// 好的做法
func processStrings(strings: Array<String>): String {
    let builder = StringBuilder()
    for (str in strings) {
        builder.append(str).append(" ")
    }
    return builder.toString()
}
\`\`\`

## 算法优化

### 使用合适的数据结构

\`\`\`cangjie
// 频繁查找时使用Map而不是Array
let userMap = Map<String, User>()
for (user in users) {
    userMap.put(user.getId(), user)
}

// O(1)查找而不是O(n)
let user = userMap.get(userId)
\`\`\`

## 编译器优化

### 内联函数

\`\`\`cangjie
inline func square(x: Int): Int {
    return x * x
}

// 编译器会将函数调用替换为实际代码
let result = square(5) // 编译后变成: let result = 5 * 5
\`\`\`

### 延迟初始化

\`\`\`cangjie
class ExpensiveResource {
    private lazy var data: Array<String> = {
        // 只有在第一次访问时才会执行
        return loadExpensiveData()
    }()
    
    public func getData(): Array<String> {
        return this.data
    }
}
\`\`\``,
        author: '性能优化专家',
        publishDate: '2024-02-10',
        readCount: 1045,
        likeCount: 92,
        category: '性能优化',
        tags: ['内存优化', '算法优化', '编译器优化'],
        hasCode: true,
        difficulty: 'advanced',
        estimatedReadTime: 14
      },
      {
        id: 7,
        title: '用仓颉语言构建Web API服务',
        summary: '从零开始使用仓颉语言构建一个完整的Web API服务，包括路由、中间件和数据库操作。',
        content: `# 用仓颉语言构建Web API服务

## 项目结构

\`\`\`
web-api/
├── src/
│   ├── main.cj
│   ├── routes/
│   │   ├── user.cj
│   │   └── auth.cj
│   ├── models/
│   │   └── user.cj
│   └── middleware/
│       └── auth.cj
└── package.cj
\`\`\`

## 基础服务器

\`\`\`cangjie
import http.Server
import json.Json

func main() {
    let server = Server()
    
    server.get("/", { req, res =>
        res.json(Json.object([
            ("message", Json.string("欢迎使用仓颉API"))
        ]))
    })
    
    server.listen(8080)
    println("服务器运行在 http://localhost:8080")
}
\`\`\`

## 用户模型

\`\`\`cangjie
class User {
    public let id: String
    public let name: String
    public let email: String
    public let createdAt: DateTime
    
    public init(id: String, name: String, email: String) {
        this.id = id
        this.name = name
        this.email = email
        this.createdAt = DateTime.now()
    }
    
    public func toJson(): Json {
        return Json.object([
            ("id", Json.string(this.id)),
            ("name", Json.string(this.name)),
            ("email", Json.string(this.email)),
            ("createdAt", Json.string(this.createdAt.toString()))
        ])
    }
}
\`\`\`

## 路由处理

\`\`\`cangjie
func setupUserRoutes(server: Server) {
    // 获取所有用户
    server.get("/users", { req, res =>
        let users = UserService.getAllUsers()
        let jsonUsers = users.map({ user => user.toJson() })
        res.json(Json.array(jsonUsers))
    })
    
    // 创建用户
    server.post("/users", { req, res =>
        let body = req.getJsonBody()
        let name = body.getString("name")
        let email = body.getString("email")
        
        let user = UserService.createUser(name, email)
        res.status(201).json(user.toJson())
    })
    
    // 获取单个用户
    server.get("/users/:id", { req, res =>
        let userId = req.getParam("id")
        match UserService.getUserById(userId) {
            case Some(user) => res.json(user.toJson())
            case None => res.status(404).json(Json.object([
                ("error", Json.string("用户不存在"))
            ]))
        }
    })
}
\`\`\``,
        author: 'Web开发工程师',
        publishDate: '2024-02-15',
        readCount: 1340,
        likeCount: 156,
        category: '实战项目',
        tags: ['Web API', 'HTTP服务器', 'RESTful'],
        coverImage: 'https://example.com/web-api-cangjie.jpg',
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 25
      },
      {
        id: 8,
        title: '仓颉语言最佳实践与代码规范',
        summary: '总结仓颉语言开发中的最佳实践和代码规范，帮助你写出更优雅的代码。',
        content: `# 仓颉语言最佳实践与代码规范

## 命名规范

### 变量和函数命名

\`\`\`cangjie
// 使用驼峰命名法
let userName: String = "张三"
let maxRetryCount: Int = 3

func calculateTotalPrice(items: Array<Item>): Float {
    // 函数实现
}
\`\`\`

### 类和接口命名

\`\`\`cangjie
// 类名使用大驼峰
class UserManager {
    // 类实现
}

// 接口名使用大驼峰
interface Serializable {
    func serialize(): String
}
\`\`\`

## 错误处理

### 使用Result类型

\`\`\`cangjie
func parseNumber(str: String): Result<Int, ParseError> {
    try {
        let number = Int.parse(str)
        return Ok(number)
    } catch (e: ParseError) {
        return Err(e)
    }
}

// 使用
match parseNumber("123") {
    case Ok(number) => println("解析成功: \${number}")
    case Err(error) => println("解析失败: \${error.message}")
}
\`\`\`

## 代码组织

### 模块化设计

\`\`\`cangjie
// user/model.cj
package user.model

public class User {
    // 用户模型
}

// user/service.cj
package user.service

import user.model.User

public class UserService {
    public static func createUser(name: String): User {
        return User(name)
    }
}
\`\`\`

## 性能考虑

### 合理使用缓存

\`\`\`cangjie
class DataCache<K, V> {
    private let cache: Map<K, V> = Map()
    private let maxSize: Int
    
    public init(maxSize: Int) {
        this.maxSize = maxSize
    }
    
    public func get(key: K, loader: () -> V): V {
        if (let cached = this.cache.get(key)) {
            return cached
        }
        
        let value = loader()
        if (this.cache.size() >= this.maxSize) {
            this.evictOldest()
        }
        this.cache.put(key, value)
        return value
    }
}
\`\`\``,
        author: '代码规范专家',
        publishDate: '2024-02-20',
        readCount: 987,
        likeCount: 123,
        category: '最佳实践',
        tags: ['代码规范', '最佳实践', '错误处理'],
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 16
      },
      {
        id: 9,
        title: '仓颉语言数据结构与算法实现',
        summary: '使用仓颉语言实现常见的数据结构和算法，提升编程能力。',
        content: `# 仓颉语言数据结构与算法实现

## 链表实现

\`\`\`cangjie
class ListNode<T> {
    public var data: T
    public var next: Option<ListNode<T>>
    
    public init(data: T) {
        this.data = data
        this.next = None
    }
}

class LinkedList<T> {
    private var head: Option<ListNode<T>> = None
    private var size: Int = 0
    
    public func append(data: T) {
        let newNode = ListNode(data)
        match this.head {
            case None => this.head = Some(newNode)
            case Some(headNode) => {
                var current = headNode
                while (let nextNode = current.next) {
                    current = nextNode
                }
                current.next = Some(newNode)
            }
        }
        this.size += 1
    }
    
    public func get(index: Int): Option<T> {
        if (index < 0 || index >= this.size) {
            return None
        }
        
        var current = this.head
        for (i in 0..<index) {
            match current {
                case Some(node) => current = node.next
                case None => return None
            }
        }
        
        match current {
            case Some(node) => return Some(node.data)
            case None => return None
        }
    }
}
\`\`\`

## 二叉搜索树

\`\`\`cangjie
class TreeNode<T where T: Comparable> {
    public var data: T
    public var left: Option<TreeNode<T>>
    public var right: Option<TreeNode<T>>
    
    public init(data: T) {
        this.data = data
        this.left = None
        this.right = None
    }
}

class BinarySearchTree<T where T: Comparable> {
    private var root: Option<TreeNode<T>> = None
    
    public func insert(data: T) {
        this.root = this.insertNode(this.root, data)
    }
    
    private func insertNode(node: Option<TreeNode<T>>, data: T): TreeNode<T> {
        match node {
            case None => return TreeNode(data)
            case Some(currentNode) => {
                if (data < currentNode.data) {
                    currentNode.left = Some(this.insertNode(currentNode.left, data))
                } else if (data > currentNode.data) {
                    currentNode.right = Some(this.insertNode(currentNode.right, data))
                }
                return currentNode
            }
        }
    }
    
    public func search(data: T): Bool {
        return this.searchNode(this.root, data)
    }
    
    private func searchNode(node: Option<TreeNode<T>>, data: T): Bool {
        match node {
            case None => return false
            case Some(currentNode) => {
                if (data == currentNode.data) {
                    return true
                } else if (data < currentNode.data) {
                    return this.searchNode(currentNode.left, data)
                } else {
                    return this.searchNode(currentNode.right, data)
                }
            }
        }
    }
}
\`\`\``,
        author: '算法工程师',
        publishDate: '2024-02-25',
        readCount: 734,
        likeCount: 67,
        category: '基础语法',
        tags: ['数据结构', '算法', '链表', '二叉树'],
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 20
      },
      {
        id: 11,
        title: '仓颉语言测试驱动开发实践',
        summary: '学习如何在仓颉语言项目中实践测试驱动开发，编写高质量的测试代码。',
        content: `# 仓颉语言测试驱动开发实践

## 单元测试基础

\`\`\`cangjie
import test.Assert

class Calculator {
    public static func add(a: Int, b: Int): Int {
        return a + b
    }
    
    public static func divide(a: Int, b: Int): Result<Int, String> {
        if (b == 0) {
            return Err("除数不能为零")
        }
        return Ok(a / b)
    }
}

// 测试用例
@Test
func testAdd() {
    let result = Calculator.add(2, 3)
    Assert.assertEquals(5, result)
}

@Test
func testDivide() {
    match Calculator.divide(10, 2) {
        case Ok(result) => Assert.assertEquals(5, result)
        case Err(_) => Assert.fail("不应该出现错误")
    }
}

@Test
func testDivideByZero() {
    match Calculator.divide(10, 0) {
        case Ok(_) => Assert.fail("应该返回错误")
        case Err(message) => Assert.assertEquals("除数不能为零", message)
    }
}
\`\`\`

## Mock和Stub

\`\`\`cangjie
interface UserRepository {
    func findById(id: String): Option<User>
    func save(user: User): Bool
}

class MockUserRepository <: UserRepository {
    private var users: Map<String, User> = Map()
    
    public func findById(id: String): Option<User> {
        return this.users.get(id)
    }
    
    public func save(user: User): Bool {
        this.users.put(user.id, user)
        return true
    }
    
    public func addUser(user: User) {
        this.users.put(user.id, user)
    }
}

class UserService {
    private let repository: UserRepository
    
    public init(repository: UserRepository) {
        this.repository = repository
    }
    
    public func getUserName(id: String): Option<String> {
        match this.repository.findById(id) {
            case Some(user) => return Some(user.name)
            case None => return None
        }
    }
}

@Test
func testGetUserName() {
    let mockRepo = MockUserRepository()
    let user = User("123", "张三", "zhang@example.com")
    mockRepo.addUser(user)
    
    let service = UserService(mockRepo)
    let name = service.getUserName("123")
    
    Assert.assertEquals(Some("张三"), name)
}
\`\`\``,
        author: '测试工程师',
        publishDate: '2024-03-01',
        readCount: 567,
        likeCount: 43,
        category: '最佳实践',
        tags: ['测试', 'TDD', 'Mock', '单元测试'],
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 18
      },
      {
        id: 12,
        title: '仓颉语言微服务架构设计',
        summary: '探索如何使用仓颉语言构建可扩展的微服务架构，包括服务发现、负载均衡和容错处理。',
        content: `# 仓颉语言微服务架构设计

## 服务注册与发现

\`\`\`cangjie
interface ServiceRegistry {
    func register(service: ServiceInfo): Bool
    func discover(serviceName: String): Array<ServiceInfo>
    func unregister(serviceId: String): Bool
}

class ServiceInfo {
    public let id: String
    public let name: String
    public let host: String
    public let port: Int
    public let healthCheckUrl: String
    
    public init(id: String, name: String, host: String, port: Int) {
        this.id = id
        this.name = name
        this.host = host
        this.port = port
        this.healthCheckUrl = "http://\${host}:\${port}/health"
    }
}

class EtcdServiceRegistry <: ServiceRegistry {
    private let etcdClient: EtcdClient
    
    public init(etcdEndpoints: Array<String>) {
        this.etcdClient = EtcdClient(etcdEndpoints)
    }
    
    public func register(service: ServiceInfo): Bool {
        let key = "/services/\${service.name}/\${service.id}"
        let value = Json.stringify(service.toJson())
        return this.etcdClient.put(key, value)
    }
    
    public func discover(serviceName: String): Array<ServiceInfo> {
        let prefix = "/services/\${serviceName}/"
        let kvPairs = this.etcdClient.getByPrefix(prefix)
        return kvPairs.map({ kv => ServiceInfo.fromJson(Json.parse(kv.value)) })
    }
}
\`\`\`

## 负载均衡

\`\`\`cangjie
interface LoadBalancer {
    func selectService(services: Array<ServiceInfo>): Option<ServiceInfo>
}

class RoundRobinLoadBalancer <: LoadBalancer {
    private var currentIndex: Int = 0
    
    public func selectService(services: Array<ServiceInfo>): Option<ServiceInfo> {
        if (services.isEmpty()) {
            return None
        }
        
        let service = services[this.currentIndex % services.size()]
        this.currentIndex += 1
        return Some(service)
    }
}

class WeightedLoadBalancer <: LoadBalancer {
    public func selectService(services: Array<ServiceInfo>): Option<ServiceInfo> {
        if (services.isEmpty()) {
            return None
        }
        
        // 基于权重的选择算法
        let totalWeight = services.map({ s => s.weight }).sum()
        let random = Random.nextInt(totalWeight)
        
        var currentWeight = 0
        for (service in services) {
            currentWeight += service.weight
            if (random < currentWeight) {
                return Some(service)
            }
        }
        
        return services.last()
    }
}
\`\`\``,
        author: '微服务架构师',
        publishDate: '2024-03-05',
        readCount: 892,
        likeCount: 78,
        category: '实战项目',
        tags: ['微服务', '架构设计', '服务发现', '负载均衡'],
        coverImage: 'https://example.com/microservices-cangjie.jpg',
        hasCode: true,
        difficulty: 'advanced',
        estimatedReadTime: 22
      },
      {
        id: 13,
        title: '仓颉语言数据库操作与ORM设计',
        summary: '学习如何在仓颉语言中进行数据库操作，设计简洁高效的ORM框架。',
        content: `# 仓颉语言数据库操作与ORM设计

## 数据库连接

\`\`\`cangjie
class DatabaseConfig {
    public let host: String
    public let port: Int
    public let database: String
    public let username: String
    public let password: String
    public let maxConnections: Int
    
    public init(host: String, port: Int, database: String, username: String, password: String, maxConnections: Int = 10) {
        this.host = host
        this.port = port
        this.database = database
        this.username = username
        this.password = password
        this.maxConnections = maxConnections
    }
}

class ConnectionPool {
    private let config: DatabaseConfig
    private var connections: Array<Connection> = []
    private let mutex = Mutex()
    
    public init(config: DatabaseConfig) {
        this.config = config
        this.initializePool()
    }
    
    public func getConnection(): Result<Connection, DatabaseError> {
        this.mutex.lock()
        defer { this.mutex.unlock() }
        
        if (this.connections.isEmpty()) {
            return this.createConnection()
        }
        
        return Ok(this.connections.removeLast())
    }
    
    public func returnConnection(conn: Connection) {
        this.mutex.lock()
        defer { this.mutex.unlock() }
        
        if (this.connections.size() < this.config.maxConnections) {
            this.connections.append(conn)
        } else {
            conn.close()
        }
    }
}
\`\`\`

## ORM实体映射

\`\`\`cangjie
@Table("users")
class User {
    @Id
    @Column("id")
    public var id: Option<Int> = None
    
    @Column("name")
    public var name: String = ""
    
    @Column("email")
    public var email: String = ""
    
    @Column("created_at")
    public var createdAt: DateTime = DateTime.now()
    
    public init() {}
    
    public init(name: String, email: String) {
        this.name = name
        this.email = email
    }
}

class Repository<T> {
    private let connectionPool: ConnectionPool
    private let entityClass: Class<T>
    
    public init(connectionPool: ConnectionPool, entityClass: Class<T>) {
        this.connectionPool = connectionPool
        this.entityClass = entityClass
    }
    
    public func save(entity: T): Result<T, DatabaseError> {
        match this.connectionPool.getConnection() {
            case Ok(conn) => {
                defer { this.connectionPool.returnConnection(conn) }
                
                let sql = this.generateInsertSql(entity)
                match conn.execute(sql) {
                    case Ok(result) => {
                        entity.setId(result.getGeneratedId())
                        return Ok(entity)
                    }
                    case Err(error) => return Err(error)
                }
            }
            case Err(error) => return Err(error)
        }
    }
    
    public func findById(id: Int): Result<Option<T>, DatabaseError> {
        match this.connectionPool.getConnection() {
            case Ok(conn) => {
                defer { this.connectionPool.returnConnection(conn) }
                
                let sql = "SELECT * FROM \${this.getTableName()} WHERE id = ?"
                match conn.query(sql, [id]) {
                    case Ok(resultSet) => {
                        if (resultSet.hasNext()) {
                            let entity = this.mapResultToEntity(resultSet.next())
                            return Ok(Some(entity))
                        } else {
                            return Ok(None)
                        }
                    }
                    case Err(error) => return Err(error)
                }
            }
            case Err(error) => return Err(error)
        }
    }
}
\`\`\``,
        author: '数据库专家',
        publishDate: '2024-03-10',
        readCount: 1156,
        likeCount: 89,
        category: '实战项目',
        tags: ['数据库', 'ORM', '连接池', '实体映射'],
        hasCode: true,
        difficulty: 'advanced',
        estimatedReadTime: 18
      },
      {
        id: 14,
        title: '仓颉语言响应式编程模式',
        summary: '探索仓颉语言中的响应式编程模式，学习如何处理异步数据流和事件。',
        content: `# 仓颉语言响应式编程模式

## Observable模式

\`\`\`cangjie
interface Observer<T> {
    func onNext(value: T): Unit
    func onError(error: Exception): Unit
    func onComplete(): Unit
}

class Observable<T> {
    private var observers: Array<Observer<T>> = []
    
    public func subscribe(observer: Observer<T>): Subscription {
        this.observers.append(observer)
        return Subscription({ => this.unsubscribe(observer) })
    }
    
    public func emit(value: T) {
        for (observer in this.observers) {
            observer.onNext(value)
        }
    }
    
    public func error(error: Exception) {
        for (observer in this.observers) {
            observer.onError(error)
        }
    }
    
    public func complete() {
        for (observer in this.observers) {
            observer.onComplete()
        }
    }
    
    public func map<R>(transform: (T) -> R): Observable<R> {
        let mapped = Observable<R>()
        this.subscribe({
            onNext: { value => mapped.emit(transform(value)) },
            onError: { error => mapped.error(error) },
            onComplete: { => mapped.complete() }
        })
        return mapped
    }
    
    public func filter(predicate: (T) -> Bool): Observable<T> {
        let filtered = Observable<T>()
        this.subscribe({
            onNext: { value => 
                if (predicate(value)) {
                    filtered.emit(value)
                }
            },
            onError: { error => filtered.error(error) },
            onComplete: { => filtered.complete() }
        })
        return filtered
    }
}
\`\`\`

## 事件流处理

\`\`\`cangjie
class EventStream<T> {
    private let observable: Observable<T>
    
    public init() {
        this.observable = Observable<T>()
    }
    
    public func publish(event: T) {
        this.observable.emit(event)
    }
    
    public func subscribe(handler: (T) -> Unit): Subscription {
        return this.observable.subscribe({
            onNext: handler,
            onError: { error => println("事件流错误: \${error.message}") },
            onComplete: { => println("事件流完成") }
        })
    }
    
    public func debounce(timeMs: Int): EventStream<T> {
        let debounced = EventStream<T>()
        var lastEmitTime: Option<DateTime> = None
        
        this.subscribe({ event =>
            let now = DateTime.now()
            lastEmitTime = Some(now)
            
            Timer.schedule(timeMs, {
                match lastEmitTime {
                    case Some(time) => {
                        if (now.equals(time)) {
                            debounced.publish(event)
                        }
                    }
                    case None => {}
                }
            })
        })
        
        return debounced
    }
}
\`\`\``,
        author: '响应式编程专家',
        publishDate: '2024-03-15',
        readCount: 678,
        likeCount: 56,
        category: '函数编程',
        tags: ['响应式编程', 'Observable', '事件流', '异步'],
        hasCode: true,
        difficulty: 'advanced',
        estimatedReadTime: 16
      },
      {
        id: 15,
        title: '仓颉语言移动应用开发实战',
        summary: '使用仓颉语言开发跨平台移动应用，掌握UI组件、状态管理和原生交互。',
        content: `# 仓颉语言移动应用开发实战

## 组件化开发

\`\`\`cangjie
@Component
struct CustomButton {
    @Prop text: String = ""
    @Prop onClick: () -> Unit = { => }
    @Prop disabled: Bool = false
    @State isPressed: Bool = false
    
    build() {
        Button(this.text)
            .enabled(!this.disabled)
            .backgroundColor(this.getBackgroundColor())
            .fontColor(this.disabled ? Color.Gray : Color.White)
            .borderRadius(8)
            .padding({ left: 16, right: 16, top: 12, bottom: 12 })
            .onTouch({ event =>
                if (event.type == TouchType.Down) {
                    this.isPressed = true
                } else if (event.type == TouchType.Up) {
                    this.isPressed = false
                    if (!this.disabled) {
                        this.onClick()
                    }
                }
            })
    }
    
    private func getBackgroundColor(): Color {
        if (this.disabled) {
            return Color.Gray
        } else if (this.isPressed) {
            return Color.Blue.darker()
        } else {
            return Color.Blue
        }
    }
}
\`\`\`

## 状态管理

\`\`\`cangjie
class AppState {
    @State var user: Option<User> = None
    @State var isLoading: Bool = false
    @State var errorMessage: String = ""
    
    public func login(username: String, password: String) {
        this.isLoading = true
        this.errorMessage = ""
        
        AuthService.login(username, password)
            .then({ user =>
                this.user = Some(user)
                this.isLoading = false
            })
            .catch({ error =>
                this.errorMessage = error.message
                this.isLoading = false
            })
    }
    
    public func logout() {
        this.user = None
        AuthService.logout()
    }
}

@Entry
@Component
struct LoginPage {
    @State username: String = ""
    @State password: String = ""
    @StorageLink("appState") appState: AppState = AppState()
    
    build() {
        Column() {
            TextInput({ placeholder: "用户名", text: this.username })
                .onChange({ value => this.username = value })
                .margin({ bottom: 16 })
            
            TextInput({ placeholder: "密码", text: this.password })
                .type(InputType.Password)
                .onChange({ value => this.password = value })
                .margin({ bottom: 24 })
            
            CustomButton({
                text: this.appState.isLoading ? "登录中..." : "登录",
                disabled: this.appState.isLoading,
                onClick: { => this.handleLogin() }
            })
            
            if (this.appState.errorMessage.isNotEmpty()) {
                Text(this.appState.errorMessage)
                    .fontColor(Color.Red)
                    .margin({ top: 16 })
            }
        }
        .padding(24)
    }
    
    private func handleLogin() {
        if (this.username.isEmpty() || this.password.isEmpty()) {
            this.appState.errorMessage = "请输入用户名和密码"
            return
        }
        
        this.appState.login(this.username, this.password)
    }
}
\`\`\``,
        author: '移动开发工程师',
        publishDate: '2024-03-20',
        readCount: 1234,
        likeCount: 98,
        category: '实战项目',
        tags: ['移动开发', 'UI组件', '状态管理', '跨平台'],
        coverImage: 'https://example.com/mobile-dev-cangjie.jpg',
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 20
      },
      {
        id: 16,
        title: '仓颉语言编译器原理与实现',
        summary: '深入了解仓颉语言编译器的工作原理，学习词法分析、语法分析和代码生成。',
        content: `# 仓颉语言编译器原理与实现

## 词法分析器

\`\`\`cangjie
enum TokenType {
    IDENTIFIER,
    NUMBER,
    STRING,
    KEYWORD,
    OPERATOR,
    DELIMITER,
    EOF
}

class Token {
    public let type: TokenType
    public let value: String
    public let line: Int
    public let column: Int
    
    public init(type: TokenType, value: String, line: Int, column: Int) {
        this.type = type
        this.value = value
        this.line = line
        this.column = column
    }
}

class Lexer {
    private let source: String
    private var position: Int = 0
    private var line: Int = 1
    private var column: Int = 1
    
    public init(source: String) {
        this.source = source
    }
    
    public func nextToken(): Token {
        this.skipWhitespace()
        
        if (this.position >= this.source.length()) {
            return Token(TokenType.EOF, "", this.line, this.column)
        }
        
        let char = this.currentChar()
        
        if (char.isLetter() || char == '_') {
            return this.readIdentifier()
        } else if (char.isDigit()) {
            return this.readNumber()
        } else if (char == '"') {
            return this.readString()
        } else {
            return this.readOperatorOrDelimiter()
        }
    }
    
    private func readIdentifier(): Token {
        let start = this.position
        let startColumn = this.column
        
        while (this.position < this.source.length() && 
               (this.currentChar().isAlphaNumeric() || this.currentChar() == '_')) {
            this.advance()
        }
        
        let value = this.source.substring(start, this.position)
        let type = this.isKeyword(value) ? TokenType.KEYWORD : TokenType.IDENTIFIER
        
        return Token(type, value, this.line, startColumn)
    }
    
    private func readNumber(): Token {
        let start = this.position
        let startColumn = this.column
        
        while (this.position < this.source.length() && 
               (this.currentChar().isDigit() || this.currentChar() == '.')) {
            this.advance()
        }
        
        let value = this.source.substring(start, this.position)
        return Token(TokenType.NUMBER, value, this.line, startColumn)
    }
}
\`\`\`

## 语法分析器

\`\`\`cangjie
abstract class ASTNode {
    public abstract func accept<T>(visitor: ASTVisitor<T>): T
}

class BinaryExpression <: ASTNode {
    public let left: ASTNode
    public let operator: Token
    public let right: ASTNode
    
    public init(left: ASTNode, operator: Token, right: ASTNode) {
        this.left = left
        this.operator = operator
        this.right = right
    }
    
    public override func accept<T>(visitor: ASTVisitor<T>): T {
        return visitor.visitBinaryExpression(this)
    }
}

class Parser {
    private let tokens: Array<Token>
    private var current: Int = 0
    
    public init(tokens: Array<Token>) {
        this.tokens = tokens
    }
    
    public func parse(): ASTNode {
        return this.expression()
    }
    
    private func expression(): ASTNode {
        return this.addition()
    }
    
    private func addition(): ASTNode {
        var expr = this.multiplication()
        
        while (this.match(["+", "-"])) {
            let operator = this.previous()
            let right = this.multiplication()
            expr = BinaryExpression(expr, operator, right)
        }
        
        return expr
    }
    
    private func multiplication(): ASTNode {
        var expr = this.primary()
        
        while (this.match(["*", "/"])) {
            let operator = this.previous()
            let right = this.primary()
            expr = BinaryExpression(expr, operator, right)
        }
        
        return expr
    }
}
\`\`\``,
        author: '编译器专家',
        publishDate: '2024-03-25',
        readCount: 456,
        likeCount: 34,
        category: '基础语法',
        tags: ['编译器', '词法分析', '语法分析', 'AST'],
        hasCode: true,
        difficulty: 'advanced',
        estimatedReadTime: 25
      },
      {
        id: 10,
        title: '仓颉语言数据结构与算法实现',
        summary: '深入学习仓颉语言中的数据结构实现，包括链表、树、图等经典算法。',
        content: `# 仓颉语言数据结构与算法实现

## 链表实现

\`\`\`cangjie
class ListNode<T> {
    public var data: T
    public var next: Option<ListNode<T>>
    
    public init(data: T) {
        this.data = data
        this.next = None
    }
}

class LinkedList<T> {
    private var head: Option<ListNode<T>> = None
    private var size: Int = 0
    
    public func append(data: T) {
        let newNode = ListNode(data)
        match this.head {
            case None => this.head = Some(newNode)
            case Some(headNode) => {
                var current = headNode
                while (let nextNode = current.next) {
                    current = nextNode
                }
                current.next = Some(newNode)
            }
        }
        this.size += 1
    }
    
    public func get(index: Int): Option<T> {
        if (index < 0 || index >= this.size) {
            return None
        }
        
        var current = this.head
        for (i in 0..<index) {
            match current {
                case Some(node) => current = node.next
                case None => return None
            }
        }
        
        match current {
            case Some(node) => return Some(node.data)
            case None => return None
        }
    }
}
\`\`\`

## 二叉搜索树

\`\`\`cangjie
class TreeNode<T where T: Comparable> {
    public var data: T
    public var left: Option<TreeNode<T>>
    public var right: Option<TreeNode<T>>
    
    public init(data: T) {
        this.data = data
        this.left = None
        this.right = None
    }
}

class BinarySearchTree<T where T: Comparable> {
    private var root: Option<TreeNode<T>> = None
    
    public func insert(data: T) {
        this.root = this.insertNode(this.root, data)
    }
    
    private func insertNode(node: Option<TreeNode<T>>, data: T): TreeNode<T> {
        match node {
            case None => return TreeNode(data)
            case Some(currentNode) => {
                if (data < currentNode.data) {
                    currentNode.left = Some(this.insertNode(currentNode.left, data))
                } else if (data > currentNode.data) {
                    currentNode.right = Some(this.insertNode(currentNode.right, data))
                }
                return currentNode
            }
        }
    }
    
    public func search(data: T): Bool {
        return this.searchNode(this.root, data)
    }
    
    private func searchNode(node: Option<TreeNode<T>>, data: T): Bool {
        match node {
            case None => return false
            case Some(currentNode) => {
                if (data == currentNode.data) {
                    return true
                } else if (data < currentNode.data) {
                    return this.searchNode(currentNode.left, data)
                } else {
                    return this.searchNode(currentNode.right, data)
                }
            }
        }
    }
}
\`\`\``,
        author: '算法工程师',
        publishDate: '2024-02-25',
        readCount: 734,
        likeCount: 67,
        category: '基础语法',
        tags: ['数据结构', '算法', '链表', '二叉树'],
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 20
      },
      {
        id: 17,
        title: '仓颉语言测试驱动开发实践',
        summary: '学习如何在仓颉语言项目中实践测试驱动开发，编写高质量的测试代码。',
        content: `# 仓颉语言测试驱动开发实践

## 单元测试基础

\`\`\`cangjie
import test.Assert

class Calculator {
    public static func add(a: Int, b: Int): Int {
        return a + b
    }
    
    public static func divide(a: Int, b: Int): Result<Int, String> {
        if (b == 0) {
            return Err("除数不能为零")
        }
        return Ok(a / b)
    }
}

// 测试用例
@Test
func testAdd() {
    let result = Calculator.add(2, 3)
    Assert.assertEquals(5, result)
}

@Test
func testDivide() {
    match Calculator.divide(10, 2) {
        case Ok(result) => Assert.assertEquals(5, result)
        case Err(_) => Assert.fail("不应该出现错误")
    }
}

@Test
func testDivideByZero() {
    match Calculator.divide(10, 0) {
        case Ok(_) => Assert.fail("应该返回错误")
        case Err(message) => Assert.assertEquals("除数不能为零", message)
    }
}
\`\`\`

## Mock和Stub

\`\`\`cangjie
interface UserRepository {
    func findById(id: String): Option<User>
    func save(user: User): Bool
}

class MockUserRepository <: UserRepository {
    private var users: Map<String, User> = Map()
    
    public func findById(id: String): Option<User> {
        return this.users.get(id)
    }
    
    public func save(user: User): Bool {
        this.users.put(user.id, user)
        return true
    }
    
    public func addUser(user: User) {
        this.users.put(user.id, user)
    }
}

class UserService {
    private let repository: UserRepository
    
    public init(repository: UserRepository) {
        this.repository = repository
    }
    
    public func getUserName(id: String): Option<String> {
        match this.repository.findById(id) {
            case Some(user) => return Some(user.name)
            case None => return None
        }
    }
}

@Test
func testGetUserName() {
    let mockRepo = MockUserRepository()
    let user = User("123", "张三", "zhang@example.com")
    mockRepo.addUser(user)
    
    let service = UserService(mockRepo)
    let name = service.getUserName("123")
    
    Assert.assertEquals(Some("张三"), name)
}
\`\`\``,
        author: '测试工程师',
        publishDate: '2024-03-01',
        readCount: 567,
        likeCount: 43,
        category: '最佳实践',
        tags: ['测试', 'TDD', 'Mock', '单元测试'],
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 12
      },
      {
        id: 18,
        title: '仓颉语言游戏开发入门',
        summary: '使用仓颉语言开发2D游戏，学习游戏循环、碰撞检测和动画系统。',
        content: `# 仓颉语言游戏开发入门

## 游戏引擎基础

\`\`\`cangjie
class GameEngine {
    private var isRunning: Bool = false
    private var scenes: Map<String, Scene> = Map()
    private var currentScene: Option<Scene> = None
    private let renderer: Renderer
    private let inputManager: InputManager
    
    public init() {
        this.renderer = Renderer()
        this.inputManager = InputManager()
    }
    
    public func start() {
        this.isRunning = true
        this.gameLoop()
    }
    
    private func gameLoop() {
        let targetFPS = 60
        let frameTime = 1000 / targetFPS
        
        while (this.isRunning) {
            let startTime = Time.now()
            
            this.update()
            this.render()
            
            let elapsed = Time.now() - startTime
            if (elapsed < frameTime) {
                Thread.sleep(frameTime - elapsed)
            }
        }
    }
    
    private func update() {
        this.inputManager.update()
        match this.currentScene {
            case Some(scene) => scene.update()
            case None => {}
        }
    }
    
    private func render() {
        this.renderer.clear()
        match this.currentScene {
            case Some(scene) => scene.render(this.renderer)
            case None => {}
        }
        this.renderer.present()
    }
}
\`\`\`

## 游戏对象系统

\`\`\`cangjie
class GameObject {
    public var position: Vector2
    public var velocity: Vector2
    public var size: Vector2
    public var active: Bool = true
    private var components: Array<Component> = []
    
    public init(x: Float, y: Float) {
        this.position = Vector2(x, y)
        this.velocity = Vector2(0, 0)
        this.size = Vector2(32, 32)
    }
    
    public func addComponent<T where T: Component>(component: T) {
        this.components.append(component)
        component.setOwner(this)
    }
    
    public func getComponent<T where T: Component>(): Option<T> {
        for (component in this.components) {
            if (component is T) {
                return Some(component as T)
            }
        }
        return None
    }
    
    public func update(deltaTime: Float) {
        if (!this.active) return
        
        this.position.x += this.velocity.x * deltaTime
        this.position.y += this.velocity.y * deltaTime
        
        for (component in this.components) {
            component.update(deltaTime)
        }
    }
}

class Player <: GameObject {
    private let speed: Float = 200.0
    
    public init(x: Float, y: Float) {
        super(x, y)
        this.addComponent(SpriteRenderer("player.png"))
        this.addComponent(Collider(this.size))
    }
    
    public override func update(deltaTime: Float) {
        this.handleInput()
        super.update(deltaTime)
    }
    
    private func handleInput() {
        this.velocity.x = 0
        this.velocity.y = 0
        
        if (Input.isKeyPressed(Key.LEFT)) {
            this.velocity.x = -this.speed
        }
        if (Input.isKeyPressed(Key.RIGHT)) {
            this.velocity.x = this.speed
        }
        if (Input.isKeyPressed(Key.UP)) {
            this.velocity.y = -this.speed
        }
        if (Input.isKeyPressed(Key.DOWN)) {
            this.velocity.y = this.speed
        }
    }
}
\`\`\``,
        author: '游戏开发者',
        publishDate: '2024-03-30',
        readCount: 1089,
        likeCount: 134,
        category: '实战项目',
        tags: ['游戏开发', '2D游戏', '游戏引擎', '碰撞检测'],
        coverImage: 'https://example.com/game-dev-cangjie.jpg',
        hasCode: true,
        difficulty: 'intermediate',
        estimatedReadTime: 24
      },
      {
        id: 19,
        title: '仓颉语言区块链开发实战',
        summary: '学习使用仓颉语言开发区块链应用，包括智能合约、共识算法和加密技术。',
        content: `# 仓颉语言区块链开发实战

## 区块链基础结构

\`\`\`cangjie
class Block {
    public let index: Int
    public let timestamp: DateTime
    public let data: String
    public let previousHash: String
    public let hash: String
    public let nonce: Int
    
    public init(index: Int, data: String, previousHash: String) {
        this.index = index
        this.timestamp = DateTime.now()
        this.data = data
        this.previousHash = previousHash
        let (hash, nonce) = this.mineBlock()
        this.hash = hash
        this.nonce = nonce
    }
    
    private func calculateHash(nonce: Int): String {
        let input = "\${this.index}\${this.timestamp}\${this.data}\${this.previousHash}\${nonce}"
        return SHA256.hash(input)
    }
    
    private func mineBlock(): (String, Int) {
        let difficulty = 4
        let target = "0".repeat(difficulty)
        var nonce = 0
        
        while (true) {
            let hash = this.calculateHash(nonce)
            if (hash.startsWith(target)) {
                return (hash, nonce)
            }
            nonce += 1
        }
    }
    
    public func isValid(): Bool {
        let calculatedHash = this.calculateHash(this.nonce)
        return calculatedHash == this.hash
    }
}

class Blockchain {
    private var chain: Array<Block> = []
    
    public init() {
        this.chain.append(this.createGenesisBlock())
    }
    
    private func createGenesisBlock(): Block {
        return Block(0, "Genesis Block", "0")
    }
    
    public func getLatestBlock(): Block {
        return this.chain.last()
    }
    
    public func addBlock(data: String) {
        let previousBlock = this.getLatestBlock()
        let newBlock = Block(
            previousBlock.index + 1,
            data,
            previousBlock.hash
        )
        this.chain.append(newBlock)
    }
    
    public func isChainValid(): Bool {
        for (i in 1..<this.chain.size()) {
            let currentBlock = this.chain[i]
            let previousBlock = this.chain[i - 1]
            
            if (!currentBlock.isValid()) {
                return false
            }
            
            if (currentBlock.previousHash != previousBlock.hash) {
                return false
            }
        }
        return true
    }
}
\`\`\`

## 智能合约

\`\`\`cangjie
abstract class SmartContract {
    protected var state: Map<String, Any> = Map()
    protected let owner: String
    
    public init(owner: String) {
        this.owner = owner
    }
    
    public abstract func execute(method: String, params: Map<String, Any>): Result<Any, String>
    
    protected func requireOwner(caller: String): Result<Unit, String> {
        if (caller != this.owner) {
            return Err("只有合约所有者可以执行此操作")
        }
        return Ok(())
    }
}

class TokenContract <: SmartContract {
    public init(owner: String, totalSupply: Int) {
        super(owner)
        this.state.put("totalSupply", totalSupply)
        this.state.put("balances", Map<String, Int>())
        
        let balances = this.state.get("balances") as Map<String, Int>
        balances.put(owner, totalSupply)
    }
    
    public override func execute(method: String, params: Map<String, Any>): Result<Any, String> {
        match method {
            case "transfer" => return this.transfer(params)
            case "balanceOf" => return this.balanceOf(params)
            case "mint" => return this.mint(params)
            default => return Err("未知方法: \${method}")
        }
    }
    
    private func transfer(params: Map<String, Any>): Result<Any, String> {
        let from = params.get("from") as String
        let to = params.get("to") as String
        let amount = params.get("amount") as Int
        
        let balances = this.state.get("balances") as Map<String, Int>
        let fromBalance = balances.get(from).getOrElse(0)
        
        if (fromBalance < amount) {
            return Err("余额不足")
        }
        
        balances.put(from, fromBalance - amount)
        let toBalance = balances.get(to).getOrElse(0)
        balances.put(to, toBalance + amount)
        
        return Ok(true)
    }
    
    private func balanceOf(params: Map<String, Any>): Result<Any, String> {
        let address = params.get("address") as String
        let balances = this.state.get("balances") as Map<String, Int>
        let balance = balances.get(address).getOrElse(0)
        return Ok(balance)
    }
}
\`\`\``,
        author: '区块链开发者',
        publishDate: '2024-04-05',
        readCount: 567,
        likeCount: 45,
        category: '实战项目',
        tags: ['区块链', '智能合约', '加密技术', '共识算法'],
        hasCode: true,
        difficulty: 'advanced',
        estimatedReadTime: 28
      },
      {
        id: 20,
        title: '仓颉语言机器学习基础',
        summary: '探索仓颉语言在机器学习领域的应用，实现基础的机器学习算法。',
        content: `# 仓颉语言机器学习基础

## 线性回归实现

\`\`\`cangjie
class Matrix {
    private let data: Array<Array<Float>>
    public let rows: Int
    public let cols: Int
    
    public init(rows: Int, cols: Int) {
        this.rows = rows
        this.cols = cols
        this.data = Array<Array<Float>>()
        for (i in 0..<rows) {
            let row = Array<Float>()
            for (j in 0..<cols) {
                row.append(0.0)
            }
            this.data.append(row)
        }
    }
    
    public func get(row: Int, col: Int): Float {
        return this.data[row][col]
    }
    
    public func set(row: Int, col: Int, value: Float) {
        this.data[row][col] = value
    }
    
    public func multiply(other: Matrix): Matrix {
        if (this.cols != other.rows) {
            throw Exception("矩阵维度不匹配")
        }
        
        let result = Matrix(this.rows, other.cols)
        for (i in 0..<this.rows) {
            for (j in 0..<other.cols) {
                var sum: Float = 0.0
                for (k in 0..<this.cols) {
                    sum += this.get(i, k) * other.get(k, j)
                }
                result.set(i, j, sum)
            }
        }
        return result
    }
    
    public func transpose(): Matrix {
        let result = Matrix(this.cols, this.rows)
        for (i in 0..<this.rows) {
            for (j in 0..<this.cols) {
                result.set(j, i, this.get(i, j))
            }
        }
        return result
    }
}

class LinearRegression {
    private var weights: Option<Matrix> = None
    private var bias: Float = 0.0
    
    public func fit(X: Matrix, y: Array<Float>, learningRate: Float = 0.01, epochs: Int = 1000) {
        let m = X.rows
        let n = X.cols
        
        // 初始化权重
        this.weights = Some(Matrix(n, 1))
        for (i in 0..<n) {
            this.weights!.set(i, 0, Random.nextFloat() * 0.01)
        }
        
        // 梯度下降
        for (epoch in 0..<epochs) {
            let predictions = this.predict(X)
            let cost = this.calculateCost(predictions, y)
            
            // 计算梯度
            let dw = Matrix(n, 1)
            var db: Float = 0.0
            
            for (i in 0..<m) {
                let error = predictions[i] - y[i]
                db += error
                for (j in 0..<n) {
                    let currentDw = dw.get(j, 0)
                    dw.set(j, 0, currentDw + error * X.get(i, j))
                }
            }
            
            // 更新参数
            for (j in 0..<n) {
                let currentWeight = this.weights!.get(j, 0)
                this.weights!.set(j, 0, currentWeight - learningRate * dw.get(j, 0) / m)
            }
            this.bias -= learningRate * db / m
            
            if (epoch % 100 == 0) {
                println("Epoch \${epoch}, Cost: \${cost}")
            }
        }
    }
    
    public func predict(X: Matrix): Array<Float> {
        match this.weights {
            case Some(w) => {
                let predictions = Array<Float>()
                for (i in 0..<X.rows) {
                    var prediction: Float = this.bias
                    for (j in 0..<X.cols) {
                        prediction += X.get(i, j) * w.get(j, 0)
                    }
                    predictions.append(prediction)
                }
                return predictions
            }
            case None => throw Exception("模型尚未训练")
        }
    }
    
    private func calculateCost(predictions: Array<Float>, actual: Array<Float>): Float {
        var cost: Float = 0.0
        for (i in 0..<predictions.size()) {
            let error = predictions[i] - actual[i]
            cost += error * error
        }
        return cost / (2.0 * predictions.size())
    }
}
\`\`\`

## 神经网络基础

\`\`\`cangjie
class NeuralNetwork {
    private let layers: Array<Int>
    private var weights: Array<Matrix> = []
    private var biases: Array<Matrix> = []
    
    public init(layers: Array<Int>) {
        this.layers = layers
        this.initializeWeights()
    }
    
    private func initializeWeights() {
        for (i in 0..<this.layers.size() - 1) {
            let inputSize = this.layers[i]
            let outputSize = this.layers[i + 1]
            
            let weight = Matrix(inputSize, outputSize)
            for (j in 0..<inputSize) {
                for (k in 0..<outputSize) {
                    weight.set(j, k, Random.nextGaussian() * 0.1)
                }
            }
            this.weights.append(weight)
            
            let bias = Matrix(1, outputSize)
            for (k in 0..<outputSize) {
                bias.set(0, k, 0.0)
            }
            this.biases.append(bias)
        }
    }
    
    public func forward(input: Matrix): Matrix {
        var activation = input
        
        for (i in 0..<this.weights.size()) {
            let z = activation.multiply(this.weights[i])
            // 添加偏置
            for (j in 0..<z.rows) {
                for (k in 0..<z.cols) {
                    let value = z.get(j, k) + this.biases[i].get(0, k)
                    z.set(j, k, this.sigmoid(value))
                }
            }
            activation = z
        }
        
        return activation
    }
    
    private func sigmoid(x: Float): Float {
        return 1.0 / (1.0 + Math.exp(-x))
    }
}
\`\`\``,
        author: '机器学习工程师',
        publishDate: '2024-04-10',
        readCount: 789,
        likeCount: 67,
        category: '高级特性',
        tags: ['机器学习', '线性回归', '神经网络', '算法'],
        hasCode: true,
        difficulty: 'advanced',
        estimatedReadTime: 22
      }
    ]

    this.filterArticles()
    this.isLoading = false
  }

  filterArticles() {
    let filtered = this.articles
    
    // 按分类筛选
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(article => article.category === this.selectedCategory)
    }
    
    // 按搜索文本筛选
    if (this.searchText.length > 0) {
      const searchLower = this.searchText.toLowerCase()
      filtered = filtered.filter(article => 
        article.title.toLowerCase().includes(searchLower) ||
        article.summary.toLowerCase().includes(searchLower) ||
        article.tags.some(tag => tag.toLowerCase().includes(searchLower))
      )
    }
    
    this.filteredArticles = filtered
  }

  getDifficultyColor(difficulty: string): string {
    switch (difficulty) {
      case 'beginner': return '#4CAF50'
      case 'intermediate': return '#FF9800'
      case 'advanced': return '#F44336'
      default: return '#666666'
    }
  }

  getDifficultyText(difficulty: string): string {
    switch (difficulty) {
      case 'beginner': return '入门'
      case 'intermediate': return '进阶'
      case 'advanced': return '高级'
      default: return '未知'
    }
  }

  build() {
    Column() {
      // 顶部搜索和筛选区域
      this.HeaderSection()
      
      if (this.isLoading) {
        this.LoadingSection()
      } else {
        // 网格内容区域
        this.GridSection()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder HeaderSection() {
    Column() {
      // 标题栏
      Row() {
        Image($r('app.media.ic_back'))
          .width(24)
          .height(24)
          .fillColor('#333333')
          .onClick(() => {
            router.back()
          })
        
        Text('知识库')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
        
        // 占位，保持标题居中
        Row().width(24).height(24)
      }
      .width('100%')
      .height(56)
      .padding({ left: 16, right: 16 })
      .backgroundColor('#FFFFFF')
      
      // 搜索框
      Row() {
        Image($r('app.media.ic_search'))
          .width(20)
          .height(20)
          .fillColor('#999999')
          .margin({ right: 8 })
        
        TextInput({ placeholder: '搜索技术文章...', text: this.searchText })
          .layoutWeight(1)
          .backgroundColor(Color.Transparent)
          .border({ width: 0 })
          .onChange((value: string) => {
            this.searchText = value
            this.filterArticles()
          })
      }
      .width('100%')
      .height(40)
      .padding({ left: 12, right: 12 })
      .backgroundColor('#F8F9FA')
      .borderRadius(20)
      .margin({ left: 16, right: 16, top: 12, bottom: 12 })
      
      // 分类筛选
      Scroll() {
        Row() {
          ForEach(this.categories, (category: string) => {
            Text(category)
              .fontSize(14)
              .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#666666')
              .backgroundColor(this.selectedCategory === category ? '#007AFF' : '#FFFFFF')
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(16)
              .border({ 
                width: 1, 
                color: this.selectedCategory === category ? '#007AFF' : '#E5E5E5' 
              })
              .margin({ right: 8 })
              .onClick(() => {
                this.selectedCategory = category
                this.filterArticles()
              })
          })
        }
        .padding({ left: 16, right: 16 })
      }
      .scrollable(ScrollDirection.Horizontal)
      .scrollBar(BarState.Off)
      .width('100%')
      .margin({ bottom: 12 })
    }
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder LoadingSection() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007AFF')
      
      Text('加载中...')
        .fontSize(14)
        .fontColor('#666666')
        .margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder GridSection() {
    Scroll() {
      Grid() {
        ForEach(this.filteredArticles, (article: ArticleData) => {
          GridItem() {
            this.ArticleCard(article)
          }
        })
      }
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 16 })
    }
    .layoutWeight(1)
    .scrollBar(BarState.Auto)
  }

  @Builder ArticleCard(article: ArticleData) {
    Column() {
      // 封面图片（如果有）
      if (article.coverImage) {
        Image(article.coverImage)
          .width('100%')
          .height(100)
          .objectFit(ImageFit.Cover)
          .borderRadius({ topLeft: 12, topRight: 12 })
          .alt('文章封面')
      }
      
      // 文章内容
      Column() {
        // 标题
        Text(article.title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(20)
          .width('100%')
          .margin({ bottom: 8 })
        
        // 摘要
        Text(article.summary)
          .fontSize(13)
          .fontColor('#666666')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .lineHeight(18)
          .width('100%')
          .margin({ bottom: 10 })
        
        // 标签
        if (article.tags.length > 0) {
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(article.tags.slice(0, 2), (tag: string) => {
              Text(`#${tag}`)
                .fontSize(11)
                .fontColor('#007AFF')
                .backgroundColor('#F0F8FF')
                .padding({ left: 6, right: 6, top: 3, bottom: 3 })
                .borderRadius(6)
                .margin({ right: 4, bottom: 4 })
            })
          }
          .width('100%')
          .margin({ bottom: 10 })
        }
        
        Blank()
        
        // 底部信息
        Row() {
          // 难度标识
          Text(this.getDifficultyText(article.difficulty))
            .fontSize(11)
            .fontColor('#FFFFFF')
            .backgroundColor(this.getDifficultyColor(article.difficulty))
            .padding({ left: 6, right: 6, top: 3, bottom: 3 })
            .borderRadius(8)
          
          Blank()
          
          // 阅读时间
          Row() {
            Image($r('app.media.ic_time'))
              .width(12)
              .height(12)
              .fillColor('#999999')
              .margin({ right: 3 })
            
            Text(`${article.estimatedReadTime}分钟`)
              .fontSize(11)
              .fontColor('#999999')
          }
        }
        .width('100%')
        .margin({ bottom: 8 })
        
        // 作者和阅读量
        Row() {
          Text(article.author)
            .fontSize(11)
            .fontColor('#666666')
            .layoutWeight(1)
          
          Row() {
            Image($r('app.media.ic_statistics'))
              .width(12)
              .height(12)
              .fillColor('#999999')
              .margin({ right: 3 })
            
            Text(article.readCount.toString())
              .fontSize(11)
              .fontColor('#999999')
          }
        }
        .width('100%')
      }
      .padding(12)
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height(280)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      // 跳转到文章详情页
      router.pushUrl({
        url: 'pages/ArticleDetailPage',
        params: { article: article }
      })
    })
  }
}