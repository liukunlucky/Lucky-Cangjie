import router from '@ohos.router'
import { util } from '@kit.ArkTS'

interface QuestionOptions {
  A: string
  B: string
  C: string
  D: string
}

interface Question {
  id: number
  question: string
  options: QuestionOptions
  answer: string
  explanation: string
  category: string
  difficulty: string
  type: string
}

interface RouterParams {
  question: Question
  questionList: Question[]
  currentIndex: number
}

interface DifficultyColor {
  bg: string
  text: string
}

@Entry
@Component
export struct QuestionBankPage {
  @State questions: Question[] = []
  @State filteredQuestions: Question[] = []
  @State searchText: string = ''
  @State selectedCategory: string = '全部'
  @State categories: string[] = ['全部']
  @State isLoading: boolean = true

  aboutToAppear() {
    // 处理路由参数
    const params = router.getParams() as Record<string, string>
    if (params && params.category) {
      this.selectedCategory = params.category
    }
    this.loadQuestions()
  }

  async loadQuestions() {
    try {
      const context = getContext(this)
      const fileData = await context.resourceManager.getRawFileContent('cangjie.json')
      const decoder = new util.TextDecoder('utf-8')
      const jsonStr = decoder.decodeWithStream(new Uint8Array(fileData.buffer))
      this.questions = JSON.parse(jsonStr)
      this.filteredQuestions = this.questions
      
      console.info(`题库页面 - 加载了 ${this.questions.length} 个题目`)
      console.info(`题库页面 - 当前选择的分类: ${this.selectedCategory}`)
      
      // 提取所有分类
      const categorySet = new Set(['全部'])
      this.questions.forEach(q => categorySet.add(q.category))
      this.categories = Array.from(categorySet)
      
      console.info(`题库页面 - 所有分类: ${JSON.stringify(this.categories)}`)
      
      // 应用过滤
      this.filterQuestions()
      
      this.isLoading = false
    } catch (error) {
      console.error('加载题库失败:', error)
      this.isLoading = false
    }
  }

  filterQuestions() {
    let filtered = this.questions
    console.info(`题库页面 - 过滤前题目数量: ${filtered.length}`)

    // 按分类筛选
    if (this.selectedCategory !== '全部') {
      filtered = filtered.filter(q => q.category === this.selectedCategory)
      console.info(`题库页面 - 按分类 "${this.selectedCategory}" 过滤后题目数量: ${filtered.length}`)
    }

    // 按搜索文本筛选
    if (this.searchText.trim()) {
      const searchLower = this.searchText.toLowerCase()
      filtered = filtered.filter(q => 
        q.question.toLowerCase().includes(searchLower) ||
        q.category.toLowerCase().includes(searchLower) ||
        q.difficulty.toLowerCase().includes(searchLower)
      )
      console.info(`题库页面 - 按搜索文本 "${this.searchText}" 过滤后题目数量: ${filtered.length}`)
    }

    this.filteredQuestions = filtered
    console.info(`题库页面 - 最终过滤后题目数量: ${this.filteredQuestions.length}`)
  }

  build() {
    Column() {
      // 搜索栏
      this.SearchSection()
      
      // 分类筛选
      this.CategoryFilterSection()
      
      // 题目总数提示
      this.QuestionCountSection()
      
      // 题目列表
      if (this.isLoading) {
        this.LoadingSection()
      } else {
        this.QuestionListSection()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  @Builder SearchSection() {
    Row() {
      TextInput({ placeholder: '搜索题目、分类或难度...' })
        .width('100%')
        .height(40)
        .backgroundColor('#FFFFFF')
        .borderRadius(20)
        .padding({ left: 16, right: 16 })
        .onChange((value: string) => {
          this.searchText = value
          this.filterQuestions()
        })
        .onSubmit(() => {
          this.filterQuestions()
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
              this.filterQuestions()
            })
        })
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .margin({ bottom: 8 })
  }

  @Builder QuestionCountSection() {
    Row() {
      Text(`共 ${this.filteredQuestions.length} 题`)
        .fontSize(14)
        .fontColor('#666666')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .padding({ left: 16, right: 16, bottom: 12 })
    .justifyContent(FlexAlign.Start)
  }

  @Builder LoadingSection() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#007AFF')
      
      Text('加载中...')
        .fontSize(16)
        .fontColor('#666666')
        .margin({ top: 16 })
    }
    .width('100%')
    .height('60%')
    .justifyContent(FlexAlign.Center)
  }

  @Builder QuestionListSection() {
    if (this.filteredQuestions.length === 0) {
      Column() {
        Text('暂无题目')
          .fontSize(16)
          .fontColor('#666666')
      }
      .width('100%')
      .height('60%')
      .justifyContent(FlexAlign.Center)
    } else {
      List() {
        ForEach(this.filteredQuestions, (question: Question, index: number) => {
          ListItem() {
            this.QuestionItem(question, index)
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

  @Builder QuestionItem(question: Question, index: number) {
    Column() {
      Row() {
        Text(`${question.id}.`)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#007AFF')
          .margin({ right: 8 })
        
        Text(question.question)
          .fontSize(16)
          .fontColor('#333333')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
      .margin({ bottom: 12 })

      Row() {
        this.TagChip(question.category, '#E3F2FD', '#1976D2')
        this.TagChip(question.difficulty, this.getDifficultyColor(question.difficulty).bg, this.getDifficultyColor(question.difficulty).text)
        this.TagChip(question.type === 'single' ? '单选' : '多选', '#F3E5F5', '#7B1FA2')
        
        Blank()
        
        Image($r('app.media.ic_arrow_right'))
          .width(16)
          .height(16)
          .fillColor('#CCCCCC')
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ bottom: 12 })
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
    .onClick(() => {
      const params: RouterParams = {
        question: question,
        questionList: this.filteredQuestions,
        currentIndex: index
      }
      router.pushUrl({
        url: 'pages/QuestionDetailPage',
        params: params
      })
    })
  }

  @Builder TagChip(text: string, bgColor: string, textColor: string) {
    Text(text)
      .fontSize(12)
      .fontColor(textColor)
      .backgroundColor(bgColor)
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .borderRadius(8)
      .margin({ right: 8 })
  }

  getDifficultyColor(difficulty: string): DifficultyColor {
    switch (difficulty) {
      case '简单':
        const easyColor: DifficultyColor = { bg: '#E8F5E8', text: '#4CAF50' }
        return easyColor
      case '中等':
        const mediumColor: DifficultyColor = { bg: '#FFF3E0', text: '#FF9800' }
        return mediumColor
      case '困难':
        const hardColor: DifficultyColor = { bg: '#FFEBEE', text: '#F44336' }
        return hardColor
      default:
        const defaultColor: DifficultyColor = { bg: '#F5F5F5', text: '#666666' }
        return defaultColor
    }
  }
}