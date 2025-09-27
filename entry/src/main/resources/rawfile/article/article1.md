仓颉语言工具链设计与实现
**
发布时间：2024-09-09 19:30:00
副标题：仓颉编程语言 Cangjie programming language
欢迎试用与参与
欢迎试用仓颉编程语言
欢迎报名 HarmonyOS NEXT
欢迎使用及参与贡献 Cangjie-TPC
通用版本 SDK、仓颉语言开发者预览版（仓颉编程语言三方库）
工具链定义与仓颉工具链概述
在软件开发中，工具链是一组编程工具，用于执行复杂的软件开发任务或创建软件产品（该软件产品通常是另一个计算机程序或一组相关程序）[1]。通常包括包管理、调试器、静态检查、格式化、自动化测试工具等，核心目的是提高开发效率、简化开发流程，帮助开发人员更好地完成项目。
仓颉规划了完整的工具链，覆盖软件开发、编译、调试调优全流程，以下为工具链全景图：
图 1：仓颉工具链全景
工具类别
具体工具 / 能力
状态
编程开发
IDE 语言服务 LSP、代码格式化 qfmt、文档生成 qjdoc
已支持
编译构建
增量编译 / 全量编译、串行编译 / 并行编译、动态 / 静态库编译、交叉编译
交叉编译待构建
静态检查度量
编程规范静态检查 cjint、代码度量 cjmetrics
已支持
程序跟踪 / 调试
AOT 调试工具 cjdb、跨语言调试、远程调试、图形化调试
图形化调试待构建
程序分析 / 调优
性能分析工具 cjprof、程序调用分析、热点函数分析、线程运行检查、内存分析 / 诊断（内存实时查看与快照、内存分析）
已支持
测试
单元测试 unittest、覆盖率统计 cjcov
已支持
包管理与版本
仓颉包管理 cpm（中心仓管理）、版本管理 cjenv
已支持
Cangjie SDK
-
已构建 / 持续构建中

本篇重点介绍仓颉工具链中的三大核心工具：包管理工具（cjpm）、静态检查工具（cjlint）、调试工具（cjdb）。
一、包管理工具 (cjpm)
cjpm 是仓颉语言的包管理工具，为开发者提供简易的编译、测试和运行入口，其功能设计如下图所示：
图 2：cjpm 架构图
功能分类
具体能力
已有功能
init (模块初始化)、check (依赖检查)、update (更新依赖)、tree (依赖展示)、build (编译)、run (运行)、test (单元测试)、install (安装)、uninstall (卸载)、clean (产物清理)
规划功能
增量编译、交叉编译、覆盖率统计、静态检查、publish (发布)、load (下载)
选项功能
控制编译选项、产物路径等
中心仓能力
（待完善，未来支持包发布 / 下载）
配置文件
toml 格式配置、工作空间管理、跨平台管理、依赖管理、构建脚本

1. 基础功能
   1.1 模块初始化
   通过 cjpm init 命令初始化新仓颉模块，自动生成包含 cjpm.toml（配置文件） 和 src（源码目录） 的工程结构。
   cjpm.toml：采用 toml 格式，包含模块名、版本号、依赖模块等基础信息，支持自定义透传编译命令、导入依赖、管理工作空间 [2]。
   图 3：模块初始化 演示
# 执行初始化命令
> cjpm init
cjpm init success

# 查看生成的工程结构
> tree
.
├── cjpm.toml  # 模块配置文件
└── src
└── main.cj # 入口源码文件

1 directory, 2 files

# 查看cjpm.toml内容
> cat cjpm.toml
[dependencies]  # 依赖配置（当前无依赖）

[package]       # 模块公共配置
cjc-version = "0.55.1"  # 编译器版本
compile-option = ""      # 编译选项（透传编译器）
description = "nothing here"  # 模块描述
name = "demo"            # 模块名
output-type = "executable"  # 产物类型（可执行文件）
src-dir = ""             # 源码目录（默认src）
target-dir = ""          # 产物目录（默认target）
version = "1.0.0"        # 模块版本

1.2 依赖检查和源码构建
通过 cjpm build 命令一键式构建仓颉项目，执行流程如下：
读取 cjpm.toml，汇总所有模块信息；
扫描源码目录，汇总包信息；
用拓扑排序算法分析包依赖关系；
调用 cjc 编译器完成并行编译。
图 4：模块编译演示
# 执行编译命令（-V显示详细日志）
> cjpm build -V
compile package demo: cjc --import-path=/root/demo/target/release --no-sub-pkg --output-dir=/root/demo/target/release/bin -p /root/demo/src --output-type=exe -o=main
cjpm build success  # 编译成功

1.3 运行和测试
运行项目：cjpm run（自动构建并执行）；
单元测试：cjpm test（运行项目中定义的单元测试，输出测试结果）[3]。
图 5：模块运行和单元测试演示
# 运行项目
> cjpm run
hello cangjie  # 程序输出
cjpm run finished

# 执行单元测试
> cjpm test
TP: demo, time elapsed: 404958 ns, RESULT:
TCS: TestM, time elapsed: 404958 ns, RESULT: [ PASSED ]
CASE: sayhi(37406 ns)
Summary: TOTAL: 1 PASSED: 1, SKIPPED: 0, ERROR: 0 FAILED: 0

Project tests finished, time elapsed: 15022135 ns, RESULT:
TP: demo.*, time elapsed: 14993025 ns, RESULT: PASSED:
TP: demo, time elapsed: 404958 ns, RESULT:
Summary: TOTAL: 1 PASSED: 1, SKIPPED: 0, ERROR: 0 FAILED: 0
cjpm test success  # 测试成功

1.4 依赖管理
在 cjpm.toml 的 dependencies 字段中配置构建依赖，当前支持：
本地源码依赖模块；
Git 依赖模块；
（未来支持）中心仓依赖模块。
此外，还支持单元测试依赖、构建脚本依赖、二进制依赖、互操作依赖等字段，简化编译流程。
1.5 多平台兼容
cjpm 已支持 Windows、Linux、macOS，后续将扩展更多平台 / 架构。
cjpm.toml 是平台无关文件，可直接跨平台使用；
平台差异配置：通过 target 字段定义不同平台的行为。
图 6：toml 文件的 target 字段使用示例
# 为 x86_64-unknown-linux-gnu 平台配置源码依赖
[target.x86_64-unknown-linux-gnu.dependencies]
demo1 = { git = "...", branch = "dev" }  # 导入Git模块（指定分支）
demo2 = { path = "..." }                 # 导入本地源码模块

# 为 x86_64-w64-mingw32 平台配置二进制依赖
[target.x86_64-w64-mingw32.bin-dependencies]
path-option = ["..."]  # 导入仓颉二进制依赖

1.6 命令扩展和构建脚本机制
（1）命令扩展
开发者可编写自定义代码，构建名为 cjpm-cmd 的可执行文件，通过 cjpm cmd 间接调用扩展功能，适配个性化构建场景。
（2）构建脚本
支持定制 cjpm 操作的前序 / 后序任务，例如编译前处理、编译后清理。通过编写 build.cj 脚本定义 stagePreBuild（编译前）和 stagePostBuild（编译后）函数。
图 7：构建脚本功能演示
执行流程：
项目初始：cjpm init
编译前自定义处理：stagePreBuild（如编译 CFFI 模块）
编译构建：cjpm build
编译后自定义处理：stagePostBuild（如删除 CFFI 源码）
功能测试：cjpm test
模块发布：cjpm publish（规划功能）
脚本示例（build.cj）：
// Case of pre/post codes for 'cjpm build'
/*
编译前执行（stagePreBuild）
- 成功返回0，失败返回非0值
  */
  func stagePreBuild(): Int64 {
  // 编译cffi模块（执行系统命令）
  exec("cd \${workspace}/cffi && cmake && make install")
  return 0
  }

/*
编译后执行（stagePostBuild）
*/
func stagePostBuild(): Int64 {
// 删除cffi源码（清理临时文件）
exec("rm -rf \${workspace}/cffi")
return 0
}

2. 未来规划
   提供仓颉语言中心仓，支持开发者发布 / 下载仓颉软件；
   支持语义化版本控制、依赖替换，提升复杂项目管理能力；
   优化构建缓存、增量构建机制，提升构建效率。
   二、静态检查工具 (cjlint)
   静态检查的核心是不执行程序，通过源码分析发现潜在问题（如代码错误、安全漏洞），提升代码质量。cjlint 基于仓颉编译器提供的 AST（抽象语法树） 和 CHIR（仓颉高级中间表示） 实现分析。
1. 基础功能
   1.1 分析依赖的中间产物
   AST（抽象语法树）：贴近源码，承载语法信息，适用于快速分析（如编程风格、命名规范、语法模式识别）；
   CHIR（仓颉高级中间表示）：具备数据流分析能力，适用于深度分析（如性能问题、安全漏洞）。
   通过编译器前端处理，源码会被映射为 basic block（基本块），块间跳转形成 CFG（控制流图）。cjlint 通过分析 CFG 中的所有路径，检查变量使用、资源分配 / 释放、条件判断等，实现规则告警。
   1.2 基于 CHIR 的静态检查核心原理
   利用 CHIR 的结构化信息，通过以下技术实现全面分析：
   技术手段
   核心作用
   数据流分析
   追踪变量的定义与使用，检测未初始化变量等问题
   控制流分析
   检查程序执行路径，识别死代码、资源泄露等
   抽象解释
   在抽象域上模拟程序执行，避免遗漏边缘场景
   符号执行
   用符号值探索程序路径，覆盖多条件分支

该框架可检测：未初始化变量、空指针引用、缓冲区溢出等错误；识别死代码消除、常量传播等优化机会；且独立于源语言和目标平台，通用性强。
1.3 示例：资源泄露检测
以 “临时文件是否被删除” 为例，cjlint 通过 CFG 分析路径分支，发现未释放资源的场景并告警。
仓颉源码示例
// 打开临时文件（CreateOrAppend模式）
let file: File = File(pathName, OpenOption.CreateOrAppend)
if (condition) {
File.delete(pathName)  # 分支1：删除文件
return 0
} else {
return 1  # 分支2：未删除文件（资源泄露）
}

图 8：CFG（控制流图）信息
[返回节点]
%2: Int64& = Allocate(Int64)  # 分配Int64变量（存储返回值）
%7: Class-_ZN6std.fs4FileE& = Allocate(Class-_ZN6std.fs4FileE)  # 分配File对象
%8: void = Apply(fs::OpenOptionE, %7, %3, ...)  # 打开文件（CreateOrAppend模式）
[readOnly] %8: Unit = Debug(%7, file)  # 绑定File对象到变量file
Branch(%0_2 #B #C)  # 根据condition分支到Block B或Block C
%10: Nothing& = Allocate(Nothing)

# Block A（对应if分支：删除文件）
%11: Unit = Apply(@_ZN6std.fs4File5deleteEv, %3)  # 执行文件删除
%12: Int64 = Constant(0)  # 返回值0
%13: Unit = Store(%12, %2)  # 存储返回值
Exit  # 退出

# Block B（if分支后续）
Exit

# Block C（对应else分支：未删除文件）
%15: Int64 = Constant(1)  # 返回值1
%16: Unit = Store(%15, %2)  # 存储返回值
Exit  # 退出（文件未删除，触发资源泄露告警）

分析结果：else 分支（Block C）未执行文件删除操作，cjlint 触发 “资源泄露” 告警。
2. 未来规划
   智能化：引入机器学习 / AI 技术，理解代码上下文与开发者意图，提升检测准确性、降低漏报率；
   跨语言：扩展支持多编程语言，满足复杂项目的跨语言代码质量检查需求；
   效率提升：支持增量代码检查，减少大型工程的分析时间。
   三、调试工具 (cjdb)
   调试是开发核心环节，cjdb 为仓颉提供统一调试能力，屏蔽不同编译模式的差异，支持跨语言调试，提供无感知的调试体验。
1. 整体架构（静态编译模式）
   cjdb 基于开源 LLDB 开发，架构如下：
   图 9：仓颉调试器整体架构
   CJDB调试器
   ├── 调试接口层
   │   ├── Debug API（编程接口）
   │   └── Debug CLI（命令行接口）
   ├── 核心调试层
   │   └── LLDB + 仓颉扩展
   │       ├── 仓颉类型支持
   │       ├── 轻量线程支持
   │       ├── demangle（名称还原）
   │       └── LLDB原生调试能力（如断点、单步）
   ├── 调试适配层
   │   └── GDB-STUB
   │       ├── lldb-server（调试服务）
   │       ├── 本地调试支持
   │       └── 调试信息加载解析（仓颉/C/C++）
   └── 跨语言层
   ├── APP（待调试应用）
   ├── 仓颉调试信息
   └── C/C++调试信息
   └── Target OS（目标操作系统）

2. 基础能力
   cjdb 具备仓颉语言的核心调试能力：
   断点：源码断点、函数断点、条件断点（breakpoint）；
   观察点：监控变量修改（watchpoint）；
   单步调试：s（step in，进入函数）、n（step over，跳过函数）、finish（跳出函数）、continue（继续运行）；
   变量操作：查看（print）、修改（set）；
   表达式计算：实时执行表达式（expr）；
   线程管理：查看仓颉线程（cjthread）。
   此外，支持C 语言跨语言调试，无需切换调试器，提升效率。
3. 跨语言调试（仓颉 ↔ C）
   3.1 原理
   仓颉与 C 语言通过 wrapper 函数 实现调用，调试时自动跳过 wrapper，实现无缝切换。
   图 10：跨语言调试原理
# 调用流程（step in）
Cangjie Func（仓颉函数） → Wrapper FuncA（中间包装函数） → Foreign C Func（C函数）

# 返回流程（step out）
Cangjie Func（仓颉函数） ← Wrapper FuncB（中间包装函数） ← Foreign C Func（C函数）

3.2 调试体验
在仓颉函数中执行 step in，直接进入 C 函数（跳过 wrapper）；
在 C 函数中可正常操作：查看调用栈、修改变量、单步调试；
在 C 函数中执行 finish，自动返回到仓颉函数（无感知 wrapper）。
4. 未来规划
   提升图形化调试能力，降低入门门槛；
   增强并发调试能力，支持高效调试并发问题；
   提供仓颉与 ArkTS 的跨语言调试能力。
