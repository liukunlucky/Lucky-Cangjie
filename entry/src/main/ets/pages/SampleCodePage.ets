import { promptAction, router } from "@kit.ArkUI";
import { pasteboard } from '@kit.BasicServicesKit';

interface CodeSample {
  id: number;
  title: string;
  description: string;
  category: string;
  code: string;
  language: string;
}

@Entry
@Component
struct SampleCodePage {
  @State selectedCategory: string = '全部';
  @State filteredSamples: CodeSample[] = [];
  @State searchText: string = '';
  @State categories: string[] = ['全部', '基础语法', '数据类型', '函数', '面向对象', '并发编程', '高级特性'];

  // 示例代码数据
  @State codeSamples: CodeSample[] = [
    {
      id: 1,
      title: 'Hello World',
      description: '最基本的仓颉程序示例',
      category: '基础语法',
      code: `main() {
    println("Hello, World!")
}`,
      language: 'cangjie'
    },
    {
      id: 2,
      title: '变量声明',
      description: '展示仓颉中的变量声明和初始化',
      category: '基础语法',
      code: `main() {
    // 可变变量
    var name: String = "仓颉"
    var age: Int64 = 25
    
    // 不可变变量
    let pi: Float64 = 3.14159
    let isActive: Bool = true
    
    println("姓名: \${name}, 年龄: \${age}")
    println("π的值: \${pi}, 状态: \${isActive}")
}`,
      language: 'cangjie'
    },
    {
      id: 3,
      title: '数组操作',
      description: '数组的创建、访问和操作',
      category: '数据类型',
      code: `main() {
    // 创建数组
    var numbers: Array<Int64> = [1, 2, 3, 4, 5]
    let fruits: Array<String> = ["苹果", "香蕉", "橙子"]
    
    // 访问元素
    println("第一个数字: \${numbers[0]}")
    println("水果数量: \${fruits.size}")
    
    // 添加元素
    numbers.append(6)
    
    // 遍历数组
    for (fruit in fruits) {
        println("水果: \${fruit}")
    }
}`,
      language: 'cangjie'
    },
    {
      id: 4,
      title: '函数定义',
      description: '函数的定义和调用示例',
      category: '函数',
      code: `// 计算两个数的和
func add(a: Int64, b: Int64): Int64 {
    return a + b
}

// 带默认参数的函数
func greet(name: String, greeting: String = "你好"): String {
    return "\${greeting}, \${name}!"
}

main() {
    let result = add(10, 20)
    println("10 + 20 = \${result}")
    
    println(greet("张三"))
    println(greet("李四", "欢迎"))
}`,
      language: 'cangjie'
    },
    {
      id: 5,
      title: '类和对象',
      description: '面向对象编程基础',
      category: '面向对象',
      code: `class Person {
    var name: String
    var age: Int64
    
    init(name: String, age: Int64) {
        this.name = name
        this.age = age
    }
    
    func introduce(): String {
        return "我是\${this.name}，今年\${this.age}岁"
    }
    
    func birthday() {
        this.age += 1
        println("\${this.name}过生日了，现在\${this.age}岁")
    }
}

main() {
    let person = Person("小明", 20)
    println(person.introduce())
    person.birthday()
}`,
      language: 'cangjie'
    },
    {
      id: 6,
      title: '异步编程',
      description: '使用async/await进行异步编程',
      category: '并发编程',
      code: `import std.sync.*

async func fetchData(id: Int64): String {
    // 模拟网络请求延迟
    sleep(Duration.millisecond * 1000)
    return "数据\${id}"
}

async func processData(): Unit {
    println("开始获取数据...")
    
    let data1 = await fetchData(1)
    let data2 = await fetchData(2)
    
    println("获取到: \${data1}")
    println("获取到: \${data2}")
}

main() {
    spawn {
        await processData()
    }
    
    println("主线程继续执行...")
    sleep(Duration.second * 3)
}`,
      language: 'cangjie'
    },
    {
      id: 7,
      title: '泛型函数',
      description: '泛型的使用示例',
      category: '高级特性',
      code: `// 泛型函数
func swap<T>(a: T, b: T): (T, T) {
    return (b, a)
}

// 泛型类
class Box<T> {
    var value: T
    
    init(value: T) {
        this.value = value
    }
    
    func getValue(): T {
        return this.value
    }
    
    func setValue(newValue: T) {
        this.value = newValue
    }
}

main() {
    let (x, y) = swap(10, 20)
    println("交换后: x=\${x}, y=\${y}")
    
    let stringBox = Box("Hello")
    println("字符串盒子: \${stringBox.getValue()}")
    
    let intBox = Box(42)
    println("整数盒子: \${intBox.getValue()}")
}`,
      language: 'cangjie'
    },
    {
      id: 8,
      title: '错误处理',
      description: '使用Result类型进行错误处理',
      category: '高级特性',
      code: `import std.collection.*

func divide(a: Float64, b: Float64): Result<Float64, String> {
    if (b == 0.0) {
        return Err("除数不能为零")
    }
    return Ok(a / b)
}

func parseNumber(str: String): Result<Int64, String> {
    try {
        return Ok(Int64.parse(str))
    } catch (e: Exception) {
        return Err("无法解析数字: \${str}")
    }
}

main() {
    // 处理除法结果
    match (divide(10.0, 2.0)) {
        case Ok(result) => println("结果: \${result}")
        case Err(error) => println("错误: \${error}")
    }
    
    // 处理解析结果
    match (parseNumber("123")) {
        case Ok(num) => println("解析成功: \${num}")
        case Err(error) => println("解析失败: \${error}")
    }
}`,
      language: 'cangjie'
    },
    
    // 更多基础语法示例
    {
      id: 9,
      title: '条件语句',
      description: '展示if-else条件判断的使用',
      category: '基础语法',
      code: `main() {
    let score: Int64 = 85
    
    // 基本if-else
    if (score >= 90) {
        println("优秀")
    } else if (score >= 80) {
        println("良好")
    } else if (score >= 60) {
        println("及格")
    } else {
        println("不及格")
    }
    
    // 三元运算符
    let result = score >= 60 ? "通过" : "未通过"
    println("考试结果: \${result}")
    
    // when表达式
    let grade = when (score) {
        case 90..100 => "A"
        case 80..89 => "B"
        case 70..79 => "C"
        case 60..69 => "D"
        case _ => "F"
    }
    println("等级: \${grade}")
}`,
      language: 'cangjie'
    },
    {
      id: 10,
      title: '循环语句',
      description: '各种循环结构的使用方法',
      category: '基础语法',
      code: `main() {
    // for循环
    println("=== for循环 ===")
    for (i in 1..5) {
        println("数字: \${i}")
    }
    
    // while循环
    println("=== while循环 ===")
    var count: Int64 = 0
    while (count < 3) {
        println("计数: \${count}")
        count += 1
    }
    
    // do-while循环
    println("=== do-while循环 ===")
    var num: Int64 = 0
    do {
        println("执行: \${num}")
        num += 1
    } while (num < 2)
    
    // 遍历数组
    println("=== 遍历数组 ===")
    let colors = ["红色", "绿色", "蓝色"]
    for (color in colors) {
        println("颜色: \${color}")
    }
    
    // 带索引的遍历
    for ((index, color) in colors.enumerate()) {
        println("\${index}: \${color}")
    }
}`,
      language: 'cangjie'
    },
    {
      id: 11,
      title: '字符串操作',
      description: '字符串的各种操作方法',
      category: '基础语法',
      code: `main() {
    let text: String = "Hello, 仓颉语言!"
    
    // 字符串长度
    println("长度: \${text.size}")
    
    // 字符串拼接
    let greeting = "你好" + ", " + "世界"
    println("拼接: \${greeting}")
    
    // 字符串插值
    let name = "张三"
    let age = 25
    println("我是\${name}，今年\${age}岁")
    
    // 字符串方法
    println("大写: \${text.toUpperCase()}")
    println("小写: \${text.toLowerCase()}")
    println("包含'仓颉': \${text.contains("仓颉")}")
    println("以'Hello'开头: \${text.startsWith("Hello")}")
    println("以'!'结尾: \${text.endsWith("!")}")
    
    // 字符串分割
    let sentence = "苹果,香蕉,橙子"
    let fruits = sentence.split(",")
    for (fruit in fruits) {
        println("水果: \${fruit}")
    }
    
    // 字符串替换
    let replaced = text.replace("Hello", "Hi")
    println("替换后: \${replaced}")
}`,
      language: 'cangjie'
    },
    
    // 更多数据类型示例
    {
      id: 12,
      title: 'Map字典操作',
      description: 'Map数据结构的创建和操作',
      category: '数据类型',
      code: `import std.collection.*

main() {
    // 创建Map
    var scores: HashMap<String, Int64> = HashMap<String, Int64>()
    
    // 添加元素
    scores["张三"] = 85
    scores["李四"] = 92
    scores["王五"] = 78
    
    // 访问元素
    println("张三的分数: \${scores["张三"]}")
    
    // 检查键是否存在
    if (scores.contains("李四")) {
        println("李四的分数: \${scores["李四"]}")
    }
    
    // 遍历Map
    println("=== 所有分数 ===")
    for ((name, score) in scores) {
        println("\${name}: \${score}分")
    }
    
    // Map大小
    println("总人数: \${scores.size}")
    
    // 删除元素
    scores.remove("王五")
    println("删除王五后，总人数: \${scores.size}")
    
    // 获取所有键和值
    let names = scores.keys()
    let allScores = scores.values()
    println("所有姓名: \${names}")
    println("所有分数: \${allScores}")
}`,
      language: 'cangjie'
    },
    {
      id: 13,
      title: 'Set集合操作',
      description: 'Set数据结构的使用方法',
      category: '数据类型',
      code: `import std.collection.*

main() {
    // 创建Set
    var uniqueNumbers: HashSet<Int64> = HashSet<Int64>()
    
    // 添加元素
    uniqueNumbers.put(1)
    uniqueNumbers.put(2)
    uniqueNumbers.put(3)
    uniqueNumbers.put(2) // 重复元素不会被添加
    
    println("Set大小: \${uniqueNumbers.size}")
    
    // 检查元素是否存在
    if (uniqueNumbers.contains(2)) {
        println("包含数字2")
    }
    
    // 遍历Set
    println("=== Set中的元素 ===")
    for (num in uniqueNumbers) {
        println("数字: \${num}")
    }
    
    // 创建另一个Set
    var otherNumbers: HashSet<Int64> = HashSet<Int64>()
    otherNumbers.put(3)
    otherNumbers.put(4)
    otherNumbers.put(5)
    
    // Set操作
    let union = uniqueNumbers.union(otherNumbers)
    println("并集: \${union}")
    
    let intersection = uniqueNumbers.intersect(otherNumbers)
    println("交集: \${intersection}")
    
    // 删除元素
    uniqueNumbers.remove(1)
    println("删除1后的Set: \${uniqueNumbers}")
}`,
      language: 'cangjie'
    },
    {
      id: 14,
      title: '元组和结构体',
      description: '元组和结构体的定义与使用',
      category: '数据类型',
      code: `// 定义结构体
struct Point {
    var x: Float64
    var y: Float64
    
    init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }
    
    func distance(): Float64 {
        return Math.sqrt(this.x * this.x + this.y * this.y)
    }
}

struct Rectangle {
    var width: Float64
    var height: Float64
    
    init(width: Float64, height: Float64) {
        this.width = width
        this.height = height
    }
    
    func area(): Float64 {
        return this.width * this.height
    }
    
    func perimeter(): Float64 {
        return 2.0 * (this.width + this.height)
    }
}

main() {
    // 使用元组
    let coordinates: (Float64, Float64) = (3.0, 4.0)
    println("坐标: (\${coordinates.0}, \${coordinates.1})")
    
    // 元组解构
    let (x, y) = coordinates
    println("x: \${x}, y: \${y}")
    
    // 使用结构体
    let point = Point(3.0, 4.0)
    println("点到原点的距离: \${point.distance()}")
    
    let rect = Rectangle(5.0, 3.0)
    println("矩形面积: \${rect.area()}")
    println("矩形周长: \${rect.perimeter()}")
    
    // 命名元组
    let person: (name: String, age: Int64) = (name: "小明", age: 20)
    println("姓名: \${person.name}, 年龄: \${person.age}")
}`,
      language: 'cangjie'
    },
    
    // 更多函数示例
    {
      id: 15,
      title: '高阶函数',
      description: '函数作为参数和返回值的使用',
      category: '函数',
      code: `// 函数类型定义
type BinaryOperation = (Int64, Int64) -> Int64
type UnaryOperation = (Int64) -> Int64

// 高阶函数：接受函数作为参数
func calculate(a: Int64, b: Int64, operation: BinaryOperation): Int64 {
    return operation(a, b)
}

// 返回函数的函数
func getOperation(op: String): BinaryOperation {
    return when (op) {
        case "add" => { (a, b) => a + b }
        case "multiply" => { (a, b) => a * b }
        case "subtract" => { (a, b) => a - b }
        case _ => { (a, b) => 0 }
    }
}

// 函数组合
func compose(f: UnaryOperation, g: UnaryOperation): UnaryOperation {
    return { x => f(g(x)) }
}

main() {
    // 使用lambda表达式
    let add = { (a: Int64, b: Int64) => a + b }
    let multiply = { (a: Int64, b: Int64) => a * b }
    
    println("5 + 3 = \${calculate(5, 3, add)}")
    println("5 * 3 = \${calculate(5, 3, multiply)}")
    
    // 使用返回的函数
    let operation = getOperation("add")
    println("使用返回的函数: \${operation(10, 20)}")
    
    // 函数组合
    let double = { x: Int64 => x * 2 }
    let addOne = { x: Int64 => x + 1 }
    let doubleAndAddOne = compose(addOne, double)
    
    println("(5 * 2) + 1 = \${doubleAndAddOne(5)}")
}`,
      language: 'cangjie'
    },
    {
      id: 16,
      title: '递归函数',
      description: '递归函数的实现和优化',
      category: '函数',
      code: `// 计算阶乘
func factorial(n: Int64): Int64 {
    if (n <= 1) {
        return 1
    }
    return n * factorial(n - 1)
}

// 尾递归优化的阶乘
func factorialTailRec(n: Int64, acc: Int64 = 1): Int64 {
    if (n <= 1) {
        return acc
    }
    return factorialTailRec(n - 1, acc * n)
}

// 斐波那契数列
func fibonacci(n: Int64): Int64 {
    if (n <= 1) {
        return n
    }
    return fibonacci(n - 1) + fibonacci(n - 2)
}

// 优化的斐波那契（记忆化）
var fibCache: HashMap<Int64, Int64> = HashMap<Int64, Int64>()

func fibonacciMemo(n: Int64): Int64 {
    if (fibCache.contains(n)) {
        return fibCache[n]!
    }
    
    let result = if (n <= 1) {
        n
    } else {
        fibonacciMemo(n - 1) + fibonacciMemo(n - 2)
    }
    
    fibCache[n] = result
    return result
}

// 二分查找
func binarySearch(arr: Array<Int64>, target: Int64, left: Int64 = 0, right: Int64 = -1): Int64 {
    let r = if (right == -1) { arr.size - 1 } else { right }
    
    if (left > r) {
        return -1
    }
    
    let mid = (left + r) / 2
    
    if (arr[mid] == target) {
        return mid
    } else if (arr[mid] > target) {
        return binarySearch(arr, target, left, mid - 1)
    } else {
        return binarySearch(arr, target, mid + 1, r)
    }
}

main() {
    // 测试阶乘
    println("5! = \${factorial(5)}")
    println("5! (尾递归) = \${factorialTailRec(5)}")
    
    // 测试斐波那契
    println("第10个斐波那契数: \${fibonacci(10)}")
    println("第10个斐波那契数(记忆化): \${fibonacciMemo(10)}")
    
    // 测试二分查找
    let sortedArray = [1, 3, 5, 7, 9, 11, 13, 15]
    let index = binarySearch(sortedArray, 7)
    println("数字7在数组中的位置: \${index}")
}`,
      language: 'cangjie'
    },
    {
      id: 17,
      title: '闭包和作用域',
      description: '闭包的创建和使用，作用域的理解',
      category: '函数',
      code: `// 创建闭包
func createCounter(start: Int64): () -> Int64 {
    var count = start
    return {
        count += 1
        return count
    }
}

// 创建带参数的闭包
func createMultiplier(factor: Int64): (Int64) -> Int64 {
    return { x => x * factor }
}

// 闭包捕获外部变量
func createAccumulator(): (Int64) -> Int64 {
    var total: Int64 = 0
    return { value =>
        total += value
        return total
    }
}

main() {
    // 使用计数器闭包
    let counter1 = createCounter(0)
    let counter2 = createCounter(10)
    
    println("计数器1: \${counter1()}")  // 1
    println("计数器1: \${counter1()}")  // 2
    println("计数器2: \${counter2()}")  // 11
    println("计数器1: \${counter1()}")  // 3
    
    // 使用乘法器闭包
    let double = createMultiplier(2)
    let triple = createMultiplier(3)
    
    println("5的两倍: \${double(5)}")
    println("5的三倍: \${triple(5)}")
    
    // 使用累加器闭包
    let accumulator = createAccumulator()
    println("累加10: \${accumulator(10)}")  // 10
    println("累加20: \${accumulator(20)}")  // 30
    println("累加5: \${accumulator(5)}")    // 35
    
    // 闭包作为参数
    let numbers = [1, 2, 3, 4, 5]
    let doubled = numbers.map(double)
    println("数组翻倍: \${doubled}")
}`,
      language: 'cangjie'
    },
    
    // 更多面向对象示例
    {
      id: 18,
      title: '继承和多态',
      description: '类的继承、方法重写和多态性',
      category: '面向对象',
      code: `// 基类
abstract class Animal {
    var name: String
    var age: Int64
    
    init(name: String, age: Int64) {
        this.name = name
        this.age = age
    }
    
    // 抽象方法
    abstract func makeSound(): String
    
    // 具体方法
    func introduce(): String {
        return "我是\${this.name}，\${this.age}岁"
    }
    
    // 虚方法，可以被重写
    open func sleep(): String {
        return "\${this.name}正在睡觉"
    }
}

// 派生类
class Dog extends Animal {
    var breed: String
    
    init(name: String, age: Int64, breed: String) {
        super(name, age)
        this.breed = breed
    }
    
    // 实现抽象方法
    override func makeSound(): String {
        return "汪汪汪！"
    }
    
    // 重写虚方法
    override func sleep(): String {
        return "\${this.name}蜷缩着睡觉"
    }
    
    // 新增方法
    func wagTail(): String {
        return "\${this.name}摇尾巴"
    }
}

class Cat extends Animal {
    var isIndoor: Bool
    
    init(name: String, age: Int64, isIndoor: Bool) {
        super(name, age)
        this.isIndoor = isIndoor
    }
    
    override func makeSound(): String {
        return "喵喵喵！"
    }
    
    override func sleep(): String {
        return "\${this.name}蜷成一团睡觉"
    }
    
    func climb(): String {
        return "\${this.name}爬树"
    }
}

main() {
    let dog = Dog("旺财", 3, "金毛")
    let cat = Cat("咪咪", 2, true)
    
    // 多态性：使用基类引用
    let animals: Array<Animal> = [dog, cat]
    
    for (animal in animals) {
        println(animal.introduce())
        println(animal.makeSound())
        println(animal.sleep())
        println("---")
    }
    
    // 类型检查和转换
    for (animal in animals) {
        if (animal is Dog) {
            let d = animal as Dog
            println(d.wagTail())
        } else if (animal is Cat) {
            let c = animal as Cat
            println(c.climb())
        }
    }
}`,
      language: 'cangjie'
    },
    {
      id: 19,
      title: '接口和实现',
      description: '接口的定义和实现，多重继承',
      category: '面向对象',
      code: `// 定义接口
interface Drawable {
    func draw(): String
}

interface Movable {
    func move(x: Float64, y: Float64): Unit
}

interface Resizable {
    func resize(scale: Float64): Unit
}

// 实现多个接口的类
class Circle implements Drawable, Movable, Resizable {
    var x: Float64
    var y: Float64
    var radius: Float64
    
    init(x: Float64, y: Float64, radius: Float64) {
        this.x = x
        this.y = y
        this.radius = radius
    }
    
    // 实现Drawable接口
    override func draw(): String {
        return "绘制圆形，中心(\${this.x}, \${this.y})，半径\${this.radius}"
    }
    
    // 实现Movable接口
    override func move(x: Float64, y: Float64): Unit {
        this.x = x
        this.y = y
    }
    
    // 实现Resizable接口
    override func resize(scale: Float64): Unit {
        this.radius *= scale
    }
    
    func area(): Float64 {
        return 3.14159 * this.radius * this.radius
    }
}

class Rectangle implements Drawable, Movable, Resizable {
    var x: Float64
    var y: Float64
    var width: Float64
    var height: Float64
    
    init(x: Float64, y: Float64, width: Float64, height: Float64) {
        this.x = x
        this.y = y
        this.width = width
        this.height = height
    }
    
    override func draw(): String {
        return "绘制矩形，位置(\${this.x}, \${this.y})，大小\${this.width}x\${this.height}"
    }
    
    override func move(x: Float64, y: Float64): Unit {
        this.x = x
        this.y = y
    }
    
    override func resize(scale: Float64): Unit {
        this.width *= scale
        this.height *= scale
    }
    
    func area(): Float64 {
        return this.width * this.height
    }
}

// 使用接口作为参数类型
func drawShape(shape: Drawable): Unit {
    println(shape.draw())
}

func moveShape(shape: Movable, x: Float64, y: Float64): Unit {
    shape.move(x, y)
    println("形状已移动到(\${x}, \${y})")
}

main() {
    let circle = Circle(0.0, 0.0, 5.0)
    let rectangle = Rectangle(10.0, 10.0, 8.0, 6.0)
    
    // 使用接口
    let shapes: Array<Drawable> = [circle, rectangle]
    
    for (shape in shapes) {
        drawShape(shape)
    }
    
    // 移动形状
    moveShape(circle, 5.0, 5.0)
    moveShape(rectangle, 20.0, 15.0)
    
    // 缩放形状
    circle.resize(1.5)
    rectangle.resize(0.8)
    
    println("缩放后:")
    println(circle.draw())
    println(rectangle.draw())
}`,
      language: 'cangjie'
    },
    {
      id: 20,
      title: '属性和访问器',
      description: '属性的getter和setter，计算属性',
      category: '面向对象',
      code: `class Temperature {
    private var _celsius: Float64
    
    init(celsius: Float64) {
        this._celsius = celsius
    }
    
    // 计算属性：华氏度
    prop fahrenheit: Float64 {
        get() {
            return this._celsius * 9.0 / 5.0 + 32.0
        }
        set(value) {
            this._celsius = (value - 32.0) * 5.0 / 9.0
        }
    }
    
    // 计算属性：开尔文
    prop kelvin: Float64 {
        get() {
            return this._celsius + 273.15
        }
        set(value) {
            this._celsius = value - 273.15
        }
    }
    
    // 只读属性
    prop description: String {
        get() {
            return "\${this._celsius}°C (\${this.fahrenheit}°F, \${this.kelvin}K)"
        }
    }
    
    // 带验证的属性
    prop celsius: Float64 {
        get() {
            return this._celsius
        }
        set(value) {
            if (value < -273.15) {
                throw Exception("温度不能低于绝对零度")
            }
            this._celsius = value
        }
    }
}

class BankAccount {
    private var _balance: Float64
    private var _transactions: Array<String>
    
    init(initialBalance: Float64) {
        this._balance = initialBalance
        this._transactions = Array<String>()
    }
    
    // 只读属性
    prop balance: Float64 {
        get() {
            return this._balance
        }
    }
    
    prop transactionHistory: Array<String> {
        get() {
            return this._transactions.clone()
        }
    }
    
    func deposit(amount: Float64): Unit {
        if (amount > 0) {
            this._balance += amount
            this._transactions.append("存款: +\${amount}")
        }
    }
    
    func withdraw(amount: Float64): Bool {
        if (amount > 0 && amount <= this._balance) {
            this._balance -= amount
            this._transactions.append("取款: -\${amount}")
            return true
        }
        return false
    }
}

main() {
    // 使用温度类
    let temp = Temperature(25.0)
    println("初始温度: \${temp.description}")
    
    // 通过华氏度设置温度
    temp.fahrenheit = 100.0
    println("设置为100°F后: \${temp.description}")
    
    // 通过开尔文设置温度
    temp.kelvin = 300.0
    println("设置为300K后: \${temp.description}")
    
    // 使用银行账户
    let account = BankAccount(1000.0)
    println("初始余额: \${account.balance}")
    
    account.deposit(500.0)
    println("存款后余额: \${account.balance}")
    
    account.withdraw(200.0)
    println("取款后余额: \${account.balance}")
    
    println("交易历史:")
    for (transaction in account.transactionHistory) {
        println("  \${transaction}")
    }
}`,
      language: 'cangjie'
    },
    
    // 更多并发编程示例
    {
      id: 21,
      title: '线程和同步',
      description: '线程创建、同步机制和线程安全',
      category: '并发编程',
      code: `import std.sync.*
import std.time.*

// 线程安全的计数器
class SafeCounter {
    private var _count: Int64
    private let _mutex: Mutex
    
    init() {
        this._count = 0
        this._mutex = Mutex()
    }
    
    func increment(): Unit {
        this._mutex.lock()
        defer { this._mutex.unlock() }
        this._count += 1
    }
    
    func decrement(): Unit {
        this._mutex.lock()
        defer { this._mutex.unlock() }
        this._count -= 1
    }
    
    func getValue(): Int64 {
        this._mutex.lock()
        defer { this._mutex.unlock() }
        return this._count
    }
}

// 生产者-消费者模式
class Buffer<T> {
    private var _items: Array<T>
    private let _mutex: Mutex
    private let _notEmpty: ConditionVariable
    private let _notFull: ConditionVariable
    private let _capacity: Int64
    
    init(capacity: Int64) {
        this._items = Array<T>()
        this._mutex = Mutex()
        this._notEmpty = ConditionVariable()
        this._notFull = ConditionVariable()
        this._capacity = capacity
    }
    
    func put(item: T): Unit {
        this._mutex.lock()
        defer { this._mutex.unlock() }
        
        while (this._items.size >= this._capacity) {
            this._notFull.wait(this._mutex)
        }
        
        this._items.append(item)
        this._notEmpty.notifyOne()
    }
    
    func take(): T {
        this._mutex.lock()
        defer { this._mutex.unlock() }
        
        while (this._items.isEmpty()) {
            this._notEmpty.wait(this._mutex)
        }
        
        let item = this._items.removeAt(0)
        this._notFull.notifyOne()
        return item
    }
}

func producer(buffer: Buffer<Int64>, id: Int64): Unit {
    for (i in 1..5) {
        let item = id * 10 + i
        buffer.put(item)
        println("生产者\${id}生产了: \${item}")
        sleep(Duration.millisecond * 100)
    }
}

func consumer(buffer: Buffer<Int64>, id: Int64): Unit {
    for (i in 1..5) {
        let item = buffer.take()
        println("消费者\${id}消费了: \${item}")
        sleep(Duration.millisecond * 150)
    }
}

main() {
    // 测试线程安全计数器
    let counter = SafeCounter()
    let threads = Array<Thread>()
    
    // 创建多个线程同时操作计数器
    for (i in 1..5) {
        let thread = Thread.spawn {
            for (j in 1..100) {
                counter.increment()
            }
        }
        threads.append(thread)
    }
    
    // 等待所有线程完成
    for (thread in threads) {
        thread.join()
    }
    
    println("最终计数: \${counter.getValue()}")
    
    // 测试生产者-消费者
    let buffer = Buffer<Int64>(3)
    
    let producer1 = Thread.spawn { producer(buffer, 1) }
    let producer2 = Thread.spawn { producer(buffer, 2) }
    let consumer1 = Thread.spawn { consumer(buffer, 1) }
    let consumer2 = Thread.spawn { consumer(buffer, 2) }
    
    producer1.join()
    producer2.join()
    consumer1.join()
    consumer2.join()
    
    println("生产者-消费者演示完成")
}`,
      language: 'cangjie'
    },
    {
      id: 22,
      title: '协程和通道',
      description: '协程的使用和通道通信',
      category: '并发编程',
      code: `import std.sync.*
import std.time.*

// 协程通信示例
async func sendNumbers(ch: Channel<Int64>): Unit {
    for (i in 1..10) {
        await ch.send(i)
        println("发送: \${i}")
        sleep(Duration.millisecond * 100)
    }
    ch.close()
}

async func receiveNumbers(ch: Channel<Int64>): Unit {
    while (true) {
        match (await ch.receive()) {
            case Some(num) => {
                println("接收: \${num}")
                sleep(Duration.millisecond * 150)
            }
            case None => {
                println("通道已关闭")
                break
            }
        }
    }
}

// 工作池模式
async func worker(id: Int64, jobs: Channel<Int64>, results: Channel<Int64>): Unit {
    while (true) {
        match (await jobs.receive()) {
            case Some(job) => {
                println("工作者\${id}处理任务\${job}")
                sleep(Duration.millisecond * 200) // 模拟工作
                let result = job * job
                await results.send(result)
            }
            case None => {
                println("工作者\${id}退出")
                break
            }
        }
    }
}

// 扇出模式：一个生产者，多个消费者
async func fanOutExample(): Unit {
    let jobs = Channel<Int64>(5)
    let results = Channel<Int64>(5)
    
    // 启动3个工作者
    for (i in 1..3) {
        spawn { await worker(i, jobs, results) }
    }
    
    // 发送任务
    spawn {
        for (job in 1..9) {
            await jobs.send(job)
        }
        jobs.close()
    }
    
    // 收集结果
    for (i in 1..9) {
        match (await results.receive()) {
            case Some(result) => println("结果: \${result}")
            case None => break
        }
    }
}

// 管道模式
async func stage1(input: Channel<Int64>, output: Channel<Int64>): Unit {
    while (true) {
        match (await input.receive()) {
            case Some(num) => {
                let processed = num * 2
                await output.send(processed)
            }
            case None => {
                output.close()
                break
            }
        }
    }
}

async func stage2(input: Channel<Int64>, output: Channel<Int64>): Unit {
    while (true) {
        match (await input.receive()) {
            case Some(num) => {
                let processed = num + 10
                await output.send(processed)
            }
            case None => {
                output.close()
                break
            }
        }
    }
}

async func pipelineExample(): Unit {
    let ch1 = Channel<Int64>(2)
    let ch2 = Channel<Int64>(2)
    let ch3 = Channel<Int64>(2)
    
    // 启动管道阶段
    spawn { await stage1(ch1, ch2) }
    spawn { await stage2(ch2, ch3) }
    
    // 发送数据到管道
    spawn {
        for (i in 1..5) {
            await ch1.send(i)
        }
        ch1.close()
    }
    
    // 从管道接收最终结果
    while (true) {
        match (await ch3.receive()) {
            case Some(result) => println("管道结果: \${result}")
            case None => break
        }
    }
}

main() {
    // 基本通道通信
    let ch = Channel<Int64>(3)
    
    spawn { await sendNumbers(ch) }
    spawn { await receiveNumbers(ch) }
    
    sleep(Duration.second * 2)
    
    // 工作池示例
    println("=== 工作池示例 ===")
    spawn { await fanOutExample() }
    
    sleep(Duration.second * 3)
    
    // 管道示例
    println("=== 管道示例 ===")
    spawn { await pipelineExample() }
    
    sleep(Duration.second * 2)
}`,
      language: 'cangjie'
    },
    {
      id: 23,
      title: '原子操作和无锁编程',
      description: '原子操作的使用和无锁数据结构',
      category: '并发编程',
      code: `import std.sync.*
import std.time.*

// 使用原子操作的计数器
class AtomicCounter {
    private var _count: Atomic<Int64>
    
    init() {
        this._count = Atomic<Int64>(0)
    }
    
    func increment(): Int64 {
        return this._count.fetchAdd(1) + 1
    }
    
    func decrement(): Int64 {
        return this._count.fetchSub(1) - 1
    }
    
    func getValue(): Int64 {
        return this._count.load()
    }
    
    func compareAndSwap(expected: Int64, desired: Int64): Bool {
        return this._count.compareExchange(expected, desired).0
    }
}

// 无锁栈
class LockFreeStack<T> {
    private struct Node {
        var data: T
        var next: Atomic<Node?>
        
        init(data: T) {
            this.data = data
            this.next = Atomic<Node?>(None)
        }
    }
    
    private var _head: Atomic<Node?>
    
    init() {
        this._head = Atomic<Node?>(None)
    }
    
    func push(data: T): Unit {
        let newNode = Node(data)
        
        while (true) {
            let currentHead = this._head.load()
            newNode.next.store(currentHead)
            
            if (this._head.compareExchange(currentHead, Some(newNode)).0) {
                break
            }
        }
    }
    
    func pop(): Option<T> {
        while (true) {
            let currentHead = this._head.load()
            
            match (currentHead) {
                case None => return None
                case Some(node) => {
                    let nextNode = node.next.load()
                    if (this._head.compareExchange(currentHead, nextNode).0) {
                        return Some(node.data)
                    }
                }
            }
        }
    }
}

// 自旋锁实现
class SpinLock {
    private var _locked: Atomic<Bool>
    
    init() {
        this._locked = Atomic<Bool>(false)
    }
    
    func lock(): Unit {
        while (!this._locked.compareExchange(false, true).0) {
            // 自旋等待
            Thread.yield()
        }
    }
    
    func unlock(): Unit {
        this._locked.store(false)
    }
    
    func tryLock(): Bool {
        return this._locked.compareExchange(false, true).0
    }
}

func testAtomicCounter(): Unit {
    let counter = AtomicCounter()
    let threads = Array<Thread>()
    
    // 创建多个线程并发操作
    for (i in 1..10) {
        let thread = Thread.spawn {
            for (j in 1..1000) {
                counter.increment()
            }
        }
        threads.append(thread)
    }
    
    // 等待所有线程完成
    for (thread in threads) {
        thread.join()
    }
    
    println("原子计数器最终值: \${counter.getValue()}")
}

func testLockFreeStack(): Unit {
    let stack = LockFreeStack<Int64>()
    let pushThreads = Array<Thread>()
    let popThreads = Array<Thread>()
    
    // 推送线程
    for (i in 1..5) {
        let thread = Thread.spawn {
            for (j in 1..100) {
                stack.push(i * 100 + j)
            }
        }
        pushThreads.append(thread)
    }
    
    // 弹出线程
    for (i in 1..3) {
        let thread = Thread.spawn {
            var count = 0
            while (count < 100) {
                match (stack.pop()) {
                    case Some(value) => {
                        count += 1
                        if (count % 50 == 0) {
                            println("线程\${i}弹出了\${count}个元素")
                        }
                    }
                    case None => {
                        Thread.yield()
                    }
                }
            }
        }
        popThreads.append(thread)
    }
    
    // 等待推送完成
    for (thread in pushThreads) {
        thread.join()
    }
    
    // 等待弹出完成
    for (thread in popThreads) {
        thread.join()
    }
    
    println("无锁栈测试完成")
}

func testSpinLock(): Unit {
    let spinLock = SpinLock()
    var sharedResource: Int64 = 0
    let threads = Array<Thread>()
    
    for (i in 1..5) {
        let thread = Thread.spawn {
            for (j in 1..1000) {
                spinLock.lock()
                sharedResource += 1
                spinLock.unlock()
            }
        }
        threads.append(thread)
    }
    
    for (thread in threads) {
        thread.join()
    }
    
    println("自旋锁保护的共享资源值: \${sharedResource}")
}

main() {
    println("=== 原子计数器测试 ===")
    testAtomicCounter()
    
    println("=== 无锁栈测试 ===")
    testLockFreeStack()
    
    println("=== 自旋锁测试 ===")
    testSpinLock()
}`,
      language: 'cangjie'
    },
    
    // 更多高级特性示例
    {
      id: 24,
      title: '模式匹配',
      description: '强大的模式匹配功能和应用',
      category: '高级特性',
      code: `// 枚举类型
enum Shape {
    | Circle(radius: Float64)
    | Rectangle(width: Float64, height: Float64)
    | Triangle(a: Float64, b: Float64, c: Float64)
}

enum Option<T> {
    | Some(value: T)
    | None
}

enum Result<T, E> {
    | Ok(value: T)
    | Err(error: E)
}

// 计算面积
func calculateArea(shape: Shape): Float64 {
    return match (shape) {
        case Circle(radius) => 3.14159 * radius * radius
        case Rectangle(width, height) => width * height
        case Triangle(a, b, c) => {
            let s = (a + b + c) / 2.0
            Math.sqrt(s * (s - a) * (s - b) * (s - c))
        }
    }
}

// 处理Option类型
func processOption<T>(opt: Option<T>): String {
    return match (opt) {
        case Some(value) => "有值: \${value}"
        case None => "无值"
    }
}

// 处理Result类型
func processResult<T, E>(result: Result<T, E>): String {
    return match (result) {
        case Ok(value) => "成功: \${value}"
        case Err(error) => "错误: \${error}"
    }
}

// 复杂的模式匹配
func analyzeData(data: (String, Int64, Bool)): String {
    return match (data) {
        case ("admin", age, true) if age >= 18 => "管理员用户，已激活"
        case ("admin", age, false) => "管理员用户，未激活"
        case ("user", age, true) if age >= 18 => "普通用户，已激活"
        case ("user", age, true) if age < 18 => "未成年用户，已激活"
        case (role, _, false) => "\${role}用户，未激活"
        case _ => "未知用户类型"
    }
}

// 列表模式匹配
func processList(list: Array<Int64>): String {
    return match (list) {
        case [] => "空列表"
        case [x] => "单元素列表: \${x}"
        case [x, y] => "两元素列表: \${x}, \${y}"
        case [first, ...rest] => "列表首元素: \${first}，剩余\${rest.size}个元素"
    }
}

// 嵌套模式匹配
enum Tree<T> {
    | Leaf(value: T)
    | Node(left: Tree<T>, right: Tree<T>)
}

func treeDepth<T>(tree: Tree<T>): Int64 {
    return match (tree) {
        case Leaf(_) => 1
        case Node(left, right) => {
            let leftDepth = treeDepth(left)
            let rightDepth = treeDepth(right)
            1 + Math.max(leftDepth, rightDepth)
        }
    }
}

func treeSum(tree: Tree<Int64>): Int64 {
    return match (tree) {
        case Leaf(value) => value
        case Node(left, right) => treeSum(left) + treeSum(right)
    }
}

main() {
    // 测试形状面积计算
    let shapes = [
        Shape.Circle(5.0),
        Shape.Rectangle(4.0, 6.0),
        Shape.Triangle(3.0, 4.0, 5.0)
    ]
    
    for (shape in shapes) {
        let area = calculateArea(shape)
        println("形状面积: \${area}")
    }
    
    // 测试Option处理
    let options = [
        Option.Some(42),
        Option.None
    ]
    
    for (opt in options) {
        println(processOption(opt))
    }
    
    // 测试Result处理
    let results = [
        Result.Ok("成功数据"),
        Result.Err("错误信息")
    ]
    
    for (result in results) {
        println(processResult(result))
    }
    
    // 测试复杂模式匹配
    let userData = [
        ("admin", 25, true),
        ("admin", 30, false),
        ("user", 20, true),
        ("user", 16, true),
        ("guest", 22, false)
    ]
    
    for (data in userData) {
        println(analyzeData(data))
    }
    
    // 测试列表模式匹配
    let lists = [
        [],
        [1],
        [1, 2],
        [1, 2, 3, 4, 5]
    ]
    
    for (list in lists) {
        println(processList(list))
    }
    
    // 测试树结构
    let tree = Tree.Node(
        Tree.Node(Tree.Leaf(1), Tree.Leaf(2)),
        Tree.Node(Tree.Leaf(3), Tree.Leaf(4))
    )
    
    println("树的深度: \${treeDepth(tree)}")
    println("树的和: \${treeSum(tree)}")
}`,
      language: 'cangjie'
    }
  ];

  aboutToAppear() {
    this.filterSamples();
  }

  // 过滤示例代码
  filterSamples() {
    let filtered = this.codeSamples;

    // 按分类过滤
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(sample => sample.category === this.selectedCategory);
    }

    // 按搜索文本过滤
    if (this.searchText.trim() !== '') {
      const searchLower = this.searchText.toLowerCase();
      filtered = filtered.filter(sample => 
        sample.title.toLowerCase().includes(searchLower) ||
        sample.description.toLowerCase().includes(searchLower) ||
        sample.category.toLowerCase().includes(searchLower)
      );
    }

    this.filteredSamples = filtered;
  }

  // 复制代码到剪贴板
  async copyCode(code: string) {
    try {
      const pasteData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, code);
      const systemPasteboard = pasteboard.getSystemPasteboard();
      await systemPasteboard.setData(pasteData);
      // 显示成功提示
      promptAction.showToast({
        message: '代码已复制到剪贴板',
        duration: 2000
      });
      // 这里可以添加提示消息
      console.info('代码已复制到剪贴板');
    } catch (error) {
      console.error('复制失败:', error);
    }
  }

  build() {
    Column() {
      // 顶部导航栏
      this.HeaderSection()
      
      // 搜索栏
      this.SearchSection()
      
      // 分类筛选
      this.CategoryFilterSection()
      
      // 示例代码总数提示
      this.CodeCountSection()
      
      // 示例代码列表
      this.CodeListSection()
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder HeaderSection() {
    Row() {
      Image($r('app.media.ic_back'))
        .width(24)
        .height(24)
        .fillColor('#333333')
        .onClick(() => {
          router.back()
        })

      Text('示例代码')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)

      Blank().width(24)
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
  }

  @Builder SearchSection() {
    Row() {
      TextInput({ placeholder: '搜索示例代码...' })
        .width('100%')
        .height(40)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.searchText = value
          this.filterSamples()
        })
        .onSubmit(() => {
          this.filterSamples()
        })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 16 })
  }

  @Builder CategoryFilterSection() {
    Scroll() {
      Row() {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .fontSize(14)
            .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#007AFF')
            .backgroundColor(this.selectedCategory === category ? '#007AFF' : '#FFFFFF')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .borderRadius(16)
            .border({
              width: 1,
              color: '#007AFF'
            })
            .margin({ right: 12 })
            .onClick(() => {
              this.selectedCategory = category
              this.filterSamples()
            })
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .margin({ bottom: 8 })
  }

  @Builder CodeCountSection() {
    Row() {
      Text(`共 ${this.filteredSamples.length} 个示例`)
        .fontSize(14)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 12 })
    .justifyContent(FlexAlign.Start)
  }

  @Builder CodeListSection() {
    if (this.filteredSamples.length === 0) {
      Column() {
        Text('暂无示例代码')
          .fontSize(16)
          .fontColor('#666666')
      }
      .width('100%')
      .height('60%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.filteredSamples, (sample: CodeSample) => {
          ListItem() {
            this.CodeSampleItem(sample)
          }
        })
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16, bottom: 16 })
      .divider({
        strokeWidth: 1,
        color: '#E0E0E0',
        startMargin: 16,
        endMargin: 16
      })
    }
  }

  @Builder CodeSampleItem(sample: CodeSample) {
    Column() {
      // 标题和分类
      Row() {
        Column() {
          Text(sample.title)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
          
          Text(sample.description)
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        
        // 分类标签
        Text(sample.category)
          .fontSize(12)
          .fontColor('#007AFF')
          .backgroundColor('#E3F2FD')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderRadius(8)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: 16 })

      // 代码区域
      Column() {
        // 代码头部
        Row() {
          Text('仓颉代码')
            .fontSize(12)
            .fontColor('#666666')
          
          Blank()
          
          Button('复制')
            .fontSize(12)
            .fontColor('#007AFF')
            .backgroundColor('transparent')
            .border({ width: 1, color: '#007AFF' })
            .borderRadius(4)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .onClick(() => {
              this.copyCode(sample.code)
            })
        }
        .width('100%')
        .padding({ left: 12, right: 12, top: 8, bottom: 8 })
        .backgroundColor('#F8F9FA')
        
        // 代码内容
        Text(sample.code)
          .fontSize(12)
          .fontColor('#333333')
          .fontFamily('monospace')
          .width('100%')
          .padding(12)
          .backgroundColor('#FFFFFF')
          .textAlign(TextAlign.Start)
      }
      .width('100%')
      .borderRadius(8)
      .border({ width: 1, color: '#E0E0E0' })
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 2, color: '#E0E0E0', offsetX: 0, offsetY: 1 })
    .margin({ bottom: 16 })
  }
}