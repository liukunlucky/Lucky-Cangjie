export class DiaryEntryModel {
  id: number = 0
  date: string = ''
  title: string = ''
  content: string = ''
  mood: string = '😊'
  studyTime: number = 0
  questionsAnswered: number = 0
  achievements: string[] = []
  tags: string[] = []
  createdAt: string = ''

  constructor() {
    const now = new Date()
    this.date = now.toISOString().split('T')[0]
    this.createdAt = now.toISOString()
  }

  // 获取心情表情
  getMoodEmoji(): string {
    return this.mood
  }

  // 获取心情名称
  getMoodName(): string {
    switch (this.mood) {
      case '😊': return '开心'
      case '😐': return '一般'
      case '😔': return '沮丧'
      case '😴': return '疲惫'
      case '🤔': return '思考'
      case '😤': return '努力'
      case '🎉': return '兴奋'
      default: return '未知'
    }
  }

  // 获取学习时长文本
  getStudyTimeText(): string {
    if (this.studyTime === 0) return '未记录'
    if (this.studyTime < 1) {
      return `${Math.round(this.studyTime * 60)}分钟`
    }
    return `${this.studyTime.toFixed(1)}小时`
  }

  // 获取答题数量文本
  getQuestionsText(): string {
    return this.questionsAnswered > 0 ? `${this.questionsAnswered}题` : '未答题'
  }

  // 添加标签
  addTag(tag: string): void {
    if (tag.trim() && !this.tags.includes(tag.trim())) {
      this.tags.push(tag.trim())
    }
  }

  // 移除标签
  removeTag(tag: string): void {
    const index = this.tags.indexOf(tag)
    if (index > -1) {
      this.tags.splice(index, 1)
    }
  }

  // 添加成就
  addAchievement(achievement: string): void {
    if (achievement.trim() && !this.achievements.includes(achievement.trim())) {
      this.achievements.push(achievement.trim())
    }
  }

  // 获取格式化的日期
  getFormattedDate(): string {
    const date = new Date(this.date)
    const year = date.getFullYear()
    const month = date.getMonth() + 1
    const day = date.getDate()
    return `${year}年${month}月${day}日`
  }

  // 获取星期几
  getWeekday(): string {
    const date = new Date(this.date)
    const weekdays = ['周日', '周一', '周二', '周三', '周四', '周五', '周六']
    return weekdays[date.getDay()]
  }
}