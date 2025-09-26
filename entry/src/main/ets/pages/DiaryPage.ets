import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import { DatabaseManager } from '../common/DatabaseManager'
import { DiaryEntryModel } from '../common/models/DiaryEntryModel'

interface SampleDiaryData {
  date: string
  title: string
  content: string
  mood: string
  studyTime: number
  questionsAnswered: number
}

@Entry
@Component
struct DiaryPage {
  @State diaryEntries: DiaryEntryModel[] = []
  @State selectedDate: string = ''
  @State showAddEntry: boolean = false
  @State showEntryDetail: boolean = false
  @State selectedEntry: DiaryEntryModel | null = null
  @State newEntryTitle: string = ''
  @State newEntryContent: string = ''
  @State newEntryMood: string = '😊'
  @State newEntryStudyTime: string = ''
  @State newEntryQuestions: string = ''
  @State currentMonth: string = ''
  private databaseManager: DatabaseManager = DatabaseManager.getInstance()

  aboutToAppear() {
    this.initCurrentMonth()
    this.loadDiaryEntries()
  }

  initCurrentMonth() {
    const now = new Date()
    this.currentMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`
    this.selectedDate = now.toISOString().split('T')[0]
  }

  async loadDiaryEntries() {
    try {
      this.diaryEntries = await this.databaseManager.getAllDiaryEntries()
      
      // 如果没有数据，显示mock数据（不添加到数据库）
      if (this.diaryEntries.length === 0) {
        this.loadMockDiaryEntries()
      }
    } catch (error) {
      console.error('Failed to load diary entries:', error)
      // 如果数据库加载失败，使用mock数据
      this.loadMockDiaryEntries()
    }
  }

  private async addSampleDiaryEntries() {
    const sampleEntries: SampleDiaryData[] = [
      {
        date: '2024-01-15',
        title: '开始学习仓颉语言',
        content: '今天开始学习仓颉语言，感觉语法和其他语言有些相似，但也有独特的地方。完成了基础语法的学习，答对了8道题目。',
        mood: '🎉',
        studyTime: 2.5,
        questionsAnswered: 8
      },
      {
        date: '2024-01-16',
        title: '函数和类的学习',
        content: '今天学习了函数定义和类的概念，做了一些练习题。有几道题目比较难，但最终都解决了。感觉进步很明显。',
        mood: '😊',
        studyTime: 3,
        questionsAnswered: 12
      },
      {
        date: '2024-01-17',
        title: '复习和巩固',
        content: '今天主要是复习前两天学的内容，做了一些综合练习。发现还有一些知识点不够熟练，需要继续加强。',
        mood: '😐',
        studyTime: 1.5,
        questionsAnswered: 6
      }
    ]

    for (const entryData of sampleEntries) {
      const entry = new DiaryEntryModel()
      entry.date = entryData.date
      entry.title = entryData.title
      entry.content = entryData.content
      entry.mood = entryData.mood
      entry.studyTime = entryData.studyTime
      entry.questionsAnswered = entryData.questionsAnswered
      
      await this.databaseManager.addDiaryEntry(entry)
    }
  }

  private loadMockDiaryEntries() {
    // 显示mock数据，不保存到数据库
    const mockEntries: DiaryEntryModel[] = []
    
    const entry1 = new DiaryEntryModel()
    entry1.id = -1 // 使用负数ID标识mock数据
    entry1.date = '2024-01-15'
    entry1.title = '开始学习仓颉语言'
    entry1.content = '今天开始学习仓颉语言，感觉语法和其他语言有些相似，但也有独特的地方。完成了基础语法的学习，答对了8道题目。学习过程中遇到了一些挑战，但通过查阅资料和练习逐步克服了。'
    entry1.mood = '🎉'
    entry1.studyTime = 2.5
    entry1.questionsAnswered = 8
    mockEntries.push(entry1)

    const entry2 = new DiaryEntryModel()
    entry2.id = -2
    entry2.date = '2024-01-16'
    entry2.title = '函数和类的学习'
    entry2.content = '今天学习了函数定义和类的概念，做了一些练习题。有几道题目比较难，但最终都解决了。感觉进步很明显，对面向对象编程有了更深的理解。'
    entry2.mood = '😊'
    entry2.studyTime = 3
    entry2.questionsAnswered = 12
    mockEntries.push(entry2)

    const entry3 = new DiaryEntryModel()
    entry3.id = -3
    entry3.date = '2024-01-17'
    entry3.title = '数据结构与算法练习'
    entry3.content = '今天专注于数据结构和算法的学习，完成了数组、链表相关的题目。虽然有些题目比较复杂，但通过反复练习和思考，逐渐掌握了解题思路。'
    entry3.mood = '🤔'
    entry3.studyTime = 4
    entry3.questionsAnswered = 15
    mockEntries.push(entry3)

    const entry4 = new DiaryEntryModel()
    entry4.id = -4
    entry4.date = '2024-01-18'
    entry4.title = '项目实战练习'
    entry4.content = '今天开始了一个小项目的开发，将之前学到的知识应用到实际项目中。遇到了一些实际开发中的问题，但通过查阅文档和调试解决了大部分问题。'
    entry4.mood = '😤'
    entry4.studyTime = 5
    entry4.questionsAnswered = 10
    mockEntries.push(entry4)

    this.diaryEntries = mockEntries
  }

  getMoodEmoji(mood: string): string {
    return mood
  }

  getMoodName(mood: string): string {
    switch (mood) {
      case '😊': return '开心'
      case '🎉': return '兴奋'
      case '😐': return '平静'
      case '😔': return '沮丧'
      case '😴': return '疲惫'
      case '🤔': return '思考'
      case '😤': return '努力'
      default: return '平静'
    }
  }

  async addNewEntry() {
    if (!this.newEntryTitle.trim()) {
      promptAction.showToast({
        message: '请输入日记标题',
        duration: 2000
      })
      return
    }

    if (!this.newEntryContent.trim()) {
      promptAction.showToast({
        message: '请输入日记内容',
        duration: 2000
      })
      return
    }

    try {
      const entry = new DiaryEntryModel()
      entry.date = this.selectedDate
      entry.title = this.newEntryTitle
      entry.content = this.newEntryContent
      entry.mood = this.newEntryMood
      entry.studyTime = Number(this.newEntryStudyTime) || 0
      entry.questionsAnswered = Number(this.newEntryQuestions) || 0
      
      await this.databaseManager.addDiaryEntry(entry)

      // 重新加载数据
      await this.loadDiaryEntries()
      
      this.resetAddEntryForm()
      this.showAddEntry = false

      promptAction.showToast({
        message: '日记添加成功！',
        duration: 2000
      })
    } catch (error) {
      console.error('Failed to add diary entry:', error)
      promptAction.showToast({
        message: '添加日记失败，请重试',
        duration: 2000
      })
    }
  }

  resetAddEntryForm() {
    this.newEntryTitle = ''
    this.newEntryContent = ''
    this.newEntryMood = '😊'
    this.newEntryStudyTime = ''
    this.newEntryQuestions = ''
  }

  async deleteEntry(entryId: number) {
    try {
      await this.databaseManager.deleteDiaryEntry(entryId)
      
      // 重新加载数据
      await this.loadDiaryEntries()
      
      promptAction.showToast({
        message: '日记删除成功',
        duration: 2000
      })
    } catch (error) {
      console.error('Failed to delete diary entry:', error)
      promptAction.showToast({
        message: '删除日记失败，请重试',
        duration: 2000
      })
    }
  }

  formatDate(dateStr: string): string {
    const date = new Date(dateStr)
    const month = date.getMonth() + 1
    const day = date.getDate()
    const weekdays = ['日', '一', '二', '三', '四', '五', '六']
    const weekday = weekdays[date.getDay()]
    return `${month}月${day}日 星期${weekday}`
  }

  build() {
    Stack() {
      Column() {
        this.HeaderSection()
        this.CalendarSection()
        this.DiaryList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
      .justifyContent(FlexAlign.Start)

      if (this.showAddEntry) {
        this.AddEntryDialog()
      }

      if (this.showEntryDetail && this.selectedEntry) {
        this.EntryDetailDialog()
      }
    }
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
      
      Text('我的日记')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#333333')
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
      
      Image($r('app.media.ic_add'))
        .width(24)
        .height(24)
        .fillColor('#007AFF')
        .onClick(() => {
          this.showAddEntry = true
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  @Builder CalendarSection() {
    Column() {
      Row() {
        Text(this.currentMonth)
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
        
        Blank()
        
        Text(`共${this.diaryEntries.length}篇日记`)
          .fontSize(14)
          .fontColor('#666666')
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 简化的日期选择
      Row() {
        Text('选择日期：')
          .fontSize(14)
          .fontColor('#666666')
        
        Button(this.formatDate(this.selectedDate))
          .fontSize(14)
          .fontColor('#007AFF')
          .backgroundColor('#F0F8FF')
          .border({ width: 1, color: '#007AFF' })
          .borderRadius(8)
          .padding({ left: 12, right: 12, top: 6, bottom: 6 })
          .onClick(() => {
            // 这里可以添加日期选择器
            promptAction.showToast({
              message: '日期选择功能开发中...',
              duration: 2000
            })
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder DiaryList() {
    Scroll() {
      Column({ space: 12 }) {
        if (this.diaryEntries.length === 0) {
          Column() {
            Text('📝')
              .fontSize(48)
              .margin({ bottom: 16 })
            
            Text('还没有日记记录')
              .fontSize(16)
              .fontColor('#666666')
              .margin({ bottom: 8 })
            
            Text('点击右上角"+"开始记录你的学习日记吧')
              .fontSize(14)
              .fontColor('#999999')
          }
          .width('100%')
          .padding({ top: 40 })
          .alignItems(HorizontalAlign.Center)
        } else {
          ForEach(this.diaryEntries, (entry: DiaryEntryModel) => {
            this.DiaryCard(entry)
          }, (entry: DiaryEntryModel) => entry.id.toString())
        }
      }
      .padding(16)
    }
    .layoutWeight(1)
  }

  @Builder DiaryCard(entry: DiaryEntryModel) {
    Column() {
      Row() {
        Column() {
          Text(entry.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
          
          Text(this.formatDate(entry.date))
            .fontSize(12)
            .fontColor('#666666')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Row() {
          Text(entry.mood)
            .fontSize(20)
          
          // 示例标签（仅对mock数据显示）
          if (entry.id < 0) {
            Text('示例')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor('#FF9800')
              .borderRadius(8)
              .margin({ left: 12 })
          }
          
          // 只有真实数据才显示删除按钮
          if (entry.id > 0) {
            Image($r('app.media.ic_delete'))
              .width(20)
              .height(20)
              .fillColor('#FF4444')
              .margin({ left: 12 })
              .onClick(() => {
                AlertDialog.show({
                  title: '确认删除',
                  message: `确定要删除日记"${entry.title}"吗？`,
                  primaryButton: {
                    value: '删除',
                    action: () => {
                      this.deleteEntry(entry.id)
                    }
                  },
                  secondaryButton: {
                    value: '取消',
                    action: () => {}
                  }
                })
              })
          }
        }
      }
      .width('100%')
      .margin({ bottom: 12 })

      Text(entry.content)
        .fontSize(14)
        .fontColor('#666666')
        .maxLines(3)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
        .textAlign(TextAlign.Start)
        .margin({ bottom: 12 })

      Row() {
        if (entry.studyTime > 0) {
          Text(`学习${entry.studyTime}小时`)
            .fontSize(12)
            .fontColor('#007AFF')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#F0F8FF')
            .borderRadius(8)
        }

        if (entry.questionsAnswered > 0) {
          Text(`答题${entry.questionsAnswered}道`)
            .fontSize(12)
            .fontColor('#4CAF50')
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#F0FFF0')
            .borderRadius(8)
            .margin({ left: 8 })
        }

        Blank()

        Text('查看详情')
          .fontSize(12)
          .fontColor('#007AFF')
          .onClick(() => {
            this.selectedEntry = entry
            this.showEntryDetail = true
          })
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder AddEntryDialog() {
    Column() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .onClick(() => {
          this.showAddEntry = false
          this.resetAddEntryForm()
        })
    }
    .width('100%')
    .height('100%')

    // 对话框内容
    Scroll() {
      Column() {
        Text('写日记')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')
          .margin({ bottom: 20 })

        // 标题
        Column() {
          Text('标题')
            .fontSize(14)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })
          
          TextInput({ placeholder: '今天学了什么？' })
            .width('100%')
            .height(40)
            .fontSize(14)
            .onChange((value: string) => {
              this.newEntryTitle = value
            })
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 内容
        Column() {
          Text('内容')
            .fontSize(14)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })
          
          TextArea({ placeholder: '记录今天的学习心得、遇到的问题、收获等...' })
            .width('100%')
            .height(120)
            .fontSize(14)
            .onChange((value: string) => {
              this.newEntryContent = value
            })
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 心情
        Column() {
          Text('今天的心情')
            .fontSize(14)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })
          
          Row() {
            ForEach(['😊', '🎉', '😐', '😴', '😔', '🤔', '😤'], (mood: string) => {
              Column() {
                Text(mood)
                  .fontSize(24)
                
                Text(this.getMoodName(mood))
                  .fontSize(12)
                  .fontColor(this.newEntryMood === mood ? '#007AFF' : '#666666')
                  .margin({ top: 4 })
              }
              .padding(8)
              .backgroundColor(this.newEntryMood === mood ? '#F0F8FF' : 'transparent')
              .borderRadius(8)
              .onClick(() => {
                this.newEntryMood = mood
              })
            }, (mood: string) => mood)
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
        .width('100%')
        .margin({ bottom: 16 })

        // 学习数据
        Row() {
          Column() {
            Text('学习时长(小时)')
              .fontSize(14)
              .fontColor('#333333')
              .width('100%')
              .textAlign(TextAlign.Start)
              .margin({ bottom: 8 })
            
            TextInput({ placeholder: '2.5' })
              .width('100%')
              .height(40)
              .fontSize(14)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.newEntryStudyTime = value
              })
          }
          .layoutWeight(1)

          Column() {
            Text('答题数量')
              .fontSize(14)
              .fontColor('#333333')
              .width('100%')
              .textAlign(TextAlign.Start)
              .margin({ bottom: 8 })
            
            TextInput({ placeholder: '10' })
              .width('100%')
              .height(40)
              .fontSize(14)
              .type(InputType.Number)
              .onChange((value: string) => {
                this.newEntryQuestions = value
              })
          }
          .layoutWeight(1)
          .margin({ left: 12 })
        }
        .width('100%')
        .margin({ bottom: 20 })

        // 操作按钮
        Row() {
          Button('取消')
            .width('45%')
            .height(40)
            .backgroundColor('#F0F0F0')
            .fontColor('#666666')
            .onClick(() => {
              this.showAddEntry = false
              this.resetAddEntryForm()
            })

          Button('保存')
            .width('45%')
            .height(40)
            .backgroundColor('#007AFF')
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.addNewEntry()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 4 })
    }
    .width('100%')
    .height('80%')
  }

  @Builder EntryDetailDialog() {
    if (this.selectedEntry) {
      Column() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .onClick(() => {
          this.showEntryDetail = false
          this.selectedEntry = null
        })
    }
    .width('100%')
    .height('100%')

    // 详情内容
    Scroll() {
      Column() {
        Row() {
          Text(this.selectedEntry!.title)
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
            .layoutWeight(1)
          
          Image($r('app.media.ic_close'))
            .width(24)
            .height(24)
            .fillColor('#666666')
            .onClick(() => {
              this.showEntryDetail = false
              this.selectedEntry = null
            })
        }
        .width('100%')
        .margin({ bottom: 16 })

        Text(this.formatDate(this.selectedEntry!.date))
          .fontSize(14)
          .fontColor('#666666')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 16 })

        Text(this.selectedEntry!.content)
          .fontSize(16)
          .fontColor('#333333')
          .lineHeight(24)
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 20 })

        // 心情和数据
        Column() {
          Row() {
            Text('心情：')
              .fontSize(14)
              .fontColor('#666666')
            
            Text(this.selectedEntry!.mood)
              .fontSize(20)
              .margin({ left: 8 })
            
            Text(this.getMoodName(this.selectedEntry!.mood))
              .fontSize(14)
              .fontColor('#333333')
              .margin({ left: 4 })
          }
          .width('100%')
          .margin({ bottom: 12 })

          if (this.selectedEntry!.studyTime > 0) {
            Row() {
              Text('学习时长：')
                .fontSize(14)
                .fontColor('#666666')
              
              Text(`${this.selectedEntry!.studyTime}小时`)
                .fontSize(14)
                .fontColor('#007AFF')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .margin({ bottom: 8 })
          }

          if (this.selectedEntry!.questionsAnswered > 0) {
            Row() {
              Text('答题数量：')
                .fontSize(14)
                .fontColor('#666666')
              
              Text(`${this.selectedEntry!.questionsAnswered}道`)
                .fontSize(14)
                .fontColor('#4CAF50')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
            .margin({ bottom: 8 })
          }

          if (this.selectedEntry!.achievements.length > 0) {
            Row() {
              Text('获得成就：')
                .fontSize(14)
                .fontColor('#666666')
              
              Text(this.selectedEntry!.achievements.join(', '))
                .fontSize(14)
                .fontColor('#FF9800')
                .fontWeight(FontWeight.Medium)
            }
            .width('100%')
          }
        }
        .width('100%')
        .padding(16)
        .backgroundColor('#F8F9FA')
        .borderRadius(8)
      }
      .width('90%')
      .padding(20)
      .backgroundColor('#FFFFFF')
      .borderRadius(12)
      .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 4 })
    }
    .width('100%')
    .height('80%')
    }
  }
}