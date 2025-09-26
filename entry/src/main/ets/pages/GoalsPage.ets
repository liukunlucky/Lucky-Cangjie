import router from '@ohos.router'
import { promptAction } from '@kit.ArkUI'
import { AppTheme } from '../common/AppTheme'
import { DatabaseManager } from '../common/DatabaseManager'
import { GoalModel } from '../common/models/GoalModel'

interface SampleGoalData {
  title: string
  description: string
  category: string
  targetValue: number
  unit: string
  deadline: string
  priority: string
}

@Entry
@Component
struct GoalsPage {
  @State goals: GoalModel[] = []
  @State selectedCategory: string = '全部'
  @State categories: string[] = ['全部', '学习目标', '考核目标', '时间目标', '技能目标']
  @State showAddGoal: boolean = false
  @State newGoalTitle: string = ''
  @State newGoalDescription: string = ''
  @State newGoalTarget: string = ''
  @State newGoalUnit: string = '题'
  @State newGoalCategory: string = '学习目标'
  @State newGoalDeadline: string = ''
  @State newGoalPriority: string = 'medium'
  private databaseManager: DatabaseManager = DatabaseManager.getInstance()

  aboutToAppear() {
    this.loadGoals()
  }

  async loadGoals() {
    try {
      this.goals = await this.databaseManager.getAllGoals()
      
      // 如果没有数据，显示mock数据（不添加到数据库）
      if (this.goals.length === 0) {
        this.loadMockGoals()
      }
    } catch (error) {
      console.error('Failed to load goals:', error)
      // 如果数据库加载失败，使用mock数据
      this.loadMockGoals()
    }
  }

  private async addSampleGoals() {
    const sampleGoals: SampleGoalData[] = [
      {
        title: '每日答题',
        description: '每天完成至少10道题目',
        category: '学习目标',
        targetValue: 10,
        unit: '题',
        deadline: '2024-12-31',
        priority: 'high'
      },
      {
        title: '周学习时长',
        description: '每周学习时间达到5小时',
        category: '时间目标',
        targetValue: 5,
        unit: '小时',
        deadline: '2024-12-31',
        priority: 'medium'
      },
      {
        title: '考核成绩',
        description: '在基础考核中获得90分以上',
        category: '考核目标',
        targetValue: 90,
        unit: '分',
        deadline: '2024-02-29',
        priority: 'high'
      },
      {
        title: '连续学习',
        description: '连续学习30天不间断',
        category: '学习目标',
        targetValue: 30,
        unit: '天',
        deadline: '2024-03-15',
        priority: 'medium'
      },
      {
        title: '基础语法掌握',
        description: '完成所有基础语法相关题目',
        category: '技能目标',
        targetValue: 100,
        unit: '题',
        deadline: '2024-02-15',
        priority: 'medium'
      }
    ]

    for (const goalData of sampleGoals) {
      const goal = new GoalModel()
      goal.title = goalData.title
      goal.description = goalData.description
      goal.category = goalData.category
      goal.targetValue = goalData.targetValue
      goal.unit = goalData.unit
      goal.deadline = goalData.deadline
      goal.priority = goalData.priority
      
      await this.databaseManager.addGoal(goal)
    }
  }

  private loadMockGoals() {
    // 显示mock数据，不保存到数据库
    const mockGoals: GoalModel[] = []
    
    const goal1 = new GoalModel()
    goal1.id = -1 // 使用负数ID标识mock数据
    goal1.title = '每日答题目标'
    goal1.description = '每天完成至少10道编程题目，提升编程能力'
    goal1.category = '学习目标'
    goal1.targetValue = 10
    goal1.currentValue = 7
    goal1.unit = '题'
    goal1.deadline = '2024-12-31'
    goal1.priority = 'high'
    mockGoals.push(goal1)

    const goal2 = new GoalModel()
    goal2.id = -2
    goal2.title = '周学习时长'
    goal2.description = '每周学习时间达到5小时，保持学习节奏'
    goal2.category = '时间目标'
    goal2.targetValue = 5
    goal2.currentValue = 3.5
    goal2.unit = '小时'
    goal2.deadline = '2024-12-31'
    goal2.priority = 'medium'
    mockGoals.push(goal2)

    const goal3 = new GoalModel()
    goal3.id = -3
    goal3.title = '考核成绩目标'
    goal3.description = '在基础考核中获得90分以上的优秀成绩'
    goal3.category = '考核目标'
    goal3.targetValue = 90
    goal3.currentValue = 85
    goal3.unit = '分'
    goal3.deadline = '2024-02-29'
    goal3.priority = 'high'
    mockGoals.push(goal3)

    this.goals = mockGoals
  }

  getFilteredGoals(): GoalModel[] {
    if (this.selectedCategory === '全部') {
      return this.goals
    }
    return this.goals.filter(g => g.category === this.selectedCategory)
  }

  getPriorityColor(priority: string): string {
    switch (priority) {
      case 'high': return '#FF4444'
      case 'medium': return '#FF9800'
      case 'low': return '#4CAF50'
      default: return '#666666'
    }
  }

  getPriorityName(priority: string): string {
    switch (priority) {
      case 'high': return '高'
      case 'medium': return '中'
      case 'low': return '低'
      default: return '未知'
    }
  }

  async addNewGoal() {
    if (!this.newGoalTitle.trim()) {
      promptAction.showToast({
        message: '请输入目标标题',
        duration: 2000
      })
      return
    }

    if (!this.newGoalTarget.trim() || isNaN(Number(this.newGoalTarget))) {
      promptAction.showToast({
        message: '请输入有效的目标数值',
        duration: 2000
      })
      return
    }

    try {
      const goal = new GoalModel()
      goal.title = this.newGoalTitle
      goal.description = this.newGoalDescription || '暂无描述'
      goal.category = this.newGoalCategory
      goal.targetValue = Number(this.newGoalTarget)
      goal.unit = this.newGoalUnit
      goal.deadline = this.newGoalDeadline || '2024-12-31'
      goal.priority = this.newGoalPriority
      
      await this.databaseManager.addGoal(goal)

      // 重新加载数据
      await this.loadGoals()
      
      this.resetAddGoalForm()
      this.showAddGoal = false

      promptAction.showToast({
        message: '目标添加成功！',
        duration: 2000
      })
    } catch (error) {
      console.error('Failed to add goal:', error)
      promptAction.showToast({
        message: '添加目标失败，请重试',
        duration: 2000
      })
    }
  }

  resetAddGoalForm() {
    this.newGoalTitle = ''
    this.newGoalDescription = ''
    this.newGoalTarget = ''
    this.newGoalUnit = '题'
    this.newGoalCategory = '学习目标'
    this.newGoalDeadline = ''
    this.newGoalPriority = 'medium'
  }

  async deleteGoal(goalId: number) {
    try {
      await this.databaseManager.deleteGoal(goalId)
      // 重新加载数据
      await this.loadGoals()
      
      promptAction.showToast({
        message: '目标已删除',
        duration: 2000
      })
    } catch (error) {
      console.error('Failed to delete goal:', error)
      promptAction.showToast({
        message: '删除目标失败，请重试',
        duration: 2000
      })
    }
  }

  async updateGoalProgress(goalId: number, newProgress: number) {
    try {
      await this.databaseManager.updateGoalProgress(goalId, newProgress)
      // 重新加载数据
      await this.loadGoals()
      
      promptAction.showToast({
        message: '进度更新成功',
        duration: 2000
      })
    } catch (error) {
      console.error('Failed to update goal progress:', error)
      promptAction.showToast({
        message: '更新进度失败，请重试',
        duration: 2000
      })
    }
  }

  build() {
    Stack() {
      Column() {
        this.HeaderSection()
        this.StatsSection()
        this.CategorySection()
        this.GoalsList()
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#F5F5F5')
      .justifyContent(FlexAlign.Start)

      if (this.showAddGoal) {
        this.AddGoalDialog()
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
      
      Text('我的目标')
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
          this.showAddGoal = true
        })
    }
    .width('100%')
    .height(56)
    .padding({ left: 16, right: 16 })
    .backgroundColor('#FFFFFF')
    .shadow({ radius: 2, color: '#1A000000', offsetX: 0, offsetY: 1 })
  }

  @Builder StatsSection() {
    Column() {
      Row() {
        Column() {
          Text(this.goals.filter(g => g.isCompleted).length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4CAF50')
          
          Text('已完成')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.goals.filter(g => !g.isCompleted).length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FF9800')
          
          Text('进行中')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(this.goals.length.toString())
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          
          Text('总目标')
            .fontSize(14)
            .fontColor('#666666')
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .padding(20)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .margin({ top: 8, bottom: 8 })
  }

  @Builder CategorySection() {
    Scroll() {
      Row({ space: 12 }) {
        ForEach(this.categories, (category: string) => {
          Text(category)
            .fontSize(14)
            .fontColor(this.selectedCategory === category ? '#FFFFFF' : '#666666')
            .padding({ left: 16, right: 16, top: 8, bottom: 8 })
            .backgroundColor(this.selectedCategory === category ? '#007AFF' : '#F0F0F0')
            .borderRadius(16)
            .onClick(() => {
              this.selectedCategory = category
            })
        }, (category: string) => category)
      }
      .padding({ left: 16, right: 16 })
    }
    .scrollable(ScrollDirection.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .backgroundColor('#FFFFFF')
    .padding({ top: 12, bottom: 12 })
    .margin({ bottom: 8 })
  }

  @Builder GoalsList() {
    Scroll() {
      Column({ space: 12 }) {
        ForEach(this.getFilteredGoals(), (goal: GoalModel) => {
          this.GoalCard(goal)
        }, (goal: GoalModel) => goal.id.toString())
      }
      .padding(16)
    }
    .layoutWeight(1)
  }

  @Builder GoalCard(goal: GoalModel) {
    Column() {
      Row() {
        Column() {
          Text(goal.title)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
          
          Text(goal.description)
            .fontSize(14)
            .fontColor('#666666')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ top: 4 })
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)

        Row() {
          // 示例标签（仅对mock数据显示）
          if (goal.id < 0) {
            Text('示例')
              .fontSize(12)
              .fontColor('#FFFFFF')
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
              .backgroundColor('#FF9800')
              .borderRadius(8)
              .margin({ right: 8 })
          }
          
          Text(goal.getPriorityName())
            .fontSize(12)
            .fontColor('#FFFFFF')
            .padding({ left: 8, right: 8, top: 2, bottom: 2 })
            .backgroundColor(goal.getPriorityColor())
            .borderRadius(8)
          
          // 只有真实数据才显示删除按钮
          if (goal.id > 0) {
            Image($r('app.media.ic_delete'))
              .width(20)
              .height(20)
              .fillColor('#FF4444')
              .margin({ left: 8 })
              .onClick(() => {
                AlertDialog.show({
                  title: '确认删除',
                  message: `确定要删除目标"${goal.title}"吗？`,
                  primaryButton: {
                    value: '删除',
                    action: () => {
                      this.deleteGoal(goal.id)
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
      .margin({ bottom: 16 })

      // 进度信息
      Row() {
        Text(`${goal.currentValue}/${goal.targetValue} ${goal.unit}`)
          .fontSize(14)
          .fontColor('#333333')
        
        Blank()
        
        Text(`${goal.getProgressPercentage()}%`)
          .fontSize(14)
          .fontColor('#007AFF')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .margin({ bottom: 8 })

      // 进度条
      Progress({
        value: goal.currentValue,
        total: goal.targetValue,
        type: ProgressType.Linear
      })
      .width('100%')
      .height(6)
      .color(goal.isCompleted ? '#4CAF50' : '#007AFF')
      .margin({ bottom: 12 })

      // 进度更新按钮（只对真实数据显示）
      if (!goal.isCompleted && goal.id > 0) {
        Row() {
          Button('+1')
            .fontSize(12)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#007AFF')
            .borderRadius(4)
            .onClick(() => {
              this.updateGoalProgress(goal.id, goal.currentValue + 1)
            })
          
          Button('+5')
            .fontSize(12)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#007AFF')
            .borderRadius(4)
            .margin({ left: 8 })
            .onClick(() => {
              this.updateGoalProgress(goal.id, goal.currentValue + 5)
            })
          
          Blank()
          
          Button('自定义')
            .fontSize(12)
            .padding({ left: 8, right: 8, top: 4, bottom: 4 })
            .backgroundColor('#FF9800')
            .borderRadius(4)
            .onClick(() => {
              // 这里可以添加自定义进度输入对话框
              AlertDialog.show({
                title: '更新进度',
                message: `当前进度：${goal.currentValue}/${goal.targetValue} ${goal.unit}`,
                primaryButton: {
                  value: '确定',
                  action: () => {
                    // 简单示例：增加10
                    this.updateGoalProgress(goal.id, Math.min(goal.currentValue + 10, goal.targetValue))
                  }
                },
                secondaryButton: {
                  value: '取消',
                  action: () => {}
                }
              })
            })
        }
        .width('100%')
        .margin({ bottom: 8 })
      } else if (goal.id < 0) {
        // 对于mock数据，显示提示信息
        Text('添加真实目标后可更新进度')
          .fontSize(12)
          .fontColor('#999999')
          .width('100%')
          .textAlign(TextAlign.Center)
          .margin({ bottom: 8 })
      }

      // 截止日期
      Row() {
        Text(`截止日期：${goal.deadline}`)
          .fontSize(12)
          .fontColor('#666666')
        
        Blank()
        
        Text(goal.category)
          .fontSize(12)
          .fontColor('#007AFF')
      }
      .width('100%')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 4, color: '#1A000000', offsetX: 0, offsetY: 2 })
  }

  @Builder AddGoalDialog() {
    Column() {
      // 遮罩层
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('#80000000')
        .onClick(() => {
          this.showAddGoal = false
          this.resetAddGoalForm()
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)

    // 对话框内容
    Column() {
      Text('添加新目标')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#333333')
        .margin({ bottom: 20 })

      // 目标标题
      Column() {
        Text('目标标题')
          .fontSize(14)
          .fontColor('#333333')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 8 })
        
        TextInput({ placeholder: '请输入目标标题' })
          .width('100%')
          .height(40)
          .fontSize(14)
          .onChange((value: string) => {
            this.newGoalTitle = value
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 目标描述
      Column() {
        Text('目标描述')
          .fontSize(14)
          .fontColor('#333333')
          .width('100%')
          .textAlign(TextAlign.Start)
          .margin({ bottom: 8 })
        
        TextInput({ placeholder: '请输入目标描述（可选）' })
          .width('100%')
          .height(40)
          .fontSize(14)
          .onChange((value: string) => {
            this.newGoalDescription = value
          })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 目标数值和单位
      Row() {
        Column() {
          Text('目标数值')
            .fontSize(14)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })
          
          TextInput({ placeholder: '100' })
            .width('100%')
            .height(40)
            .fontSize(14)
            .type(InputType.Number)
            .onChange((value: string) => {
              this.newGoalTarget = value
            })
        }
        .layoutWeight(2)

        Column() {
          Text('单位')
            .fontSize(14)
            .fontColor('#333333')
            .width('100%')
            .textAlign(TextAlign.Start)
            .margin({ bottom: 8 })
          
          Select([
            { value: '题' },
            { value: '分' },
            { value: '小时' },
            { value: '天' },
            { value: '次' }
          ])
          .selected(0)
          .value('题')
          .font({ size: 14 })
          .onSelect((index: number, value: string) => {
            this.newGoalUnit = value
          })
        }
        .layoutWeight(1)
        .margin({ left: 12 })
      }
      .width('100%')
      .margin({ bottom: 16 })

      // 操作按钮
      Row() {
        Button('取消')
          .width('45%')
          .height(40)
          .backgroundColor('#F0F0F0')
          .fontColor('#666666')
          .onClick(() => {
            this.showAddGoal = false
            this.resetAddGoalForm()
          })

        Button('添加')
          .width('45%')
          .height(40)
          .backgroundColor('#007AFF')
          .fontColor('#FFFFFF')
          .onClick(() => {
            this.addNewGoal()
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('80%')
    .padding(20)
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({ radius: 8, color: '#1A000000', offsetX: 0, offsetY: 4 })
    .position({ x: '10%', y: '30%' })
  }
}