export class GoalModel {
  id: number = 0
  title: string = ''
  description: string = ''
  category: string = ''
  targetValue: number = 0
  currentValue: number = 0
  unit: string = ''
  deadline: string = ''
  isCompleted: boolean = false
  createdAt: string = ''
  priority: string = 'medium'

  constructor() {
    this.createdAt = new Date().toISOString().split('T')[0]
  }

  // 获取进度百分比
  getProgressPercentage(): number {
    if (this.targetValue === 0) return 0
    return Math.round((this.currentValue / this.targetValue) * 100)
  }

  // 检查是否已完成
  checkCompletion(): boolean {
    return this.currentValue >= this.targetValue
  }

  // 更新进度
  updateProgress(newValue: number): void {
    this.currentValue = newValue
    this.isCompleted = this.checkCompletion()
  }

  // 获取优先级颜色
  getPriorityColor(): string {
    switch (this.priority) {
      case 'high': return '#FF4444'
      case 'medium': return '#FF9800'
      case 'low': return '#4CAF50'
      default: return '#666666'
    }
  }

  // 获取优先级名称
  getPriorityName(): string {
    switch (this.priority) {
      case 'high': return '高'
      case 'medium': return '中'
      case 'low': return '低'
      default: return '未知'
    }
  }
}