export class AchievementModel {
  id: string = ''
  title: string = ''
  description: string = ''
  icon: string = ''
  isUnlocked: boolean = false
  unlockedDate: string = ''
  progress: number = 0
  maxProgress: number = 1
  category: string = ''
  rarity: 'common' | 'rare' | 'epic' | 'legendary' = 'common'
  createdAt: string = ''

  constructor(
    id?: string,
    title?: string,
    description?: string,
    icon?: string,
    category?: string,
    maxProgress?: number,
    rarity?: 'common' | 'rare' | 'epic' | 'legendary'
  ) {
    if (id) this.id = id
    if (title) this.title = title
    if (description) this.description = description
    if (icon) this.icon = icon
    if (category) this.category = category
    if (maxProgress) this.maxProgress = maxProgress
    if (rarity) this.rarity = rarity
    this.createdAt = new Date().toISOString()
  }

  // 获取进度百分比
  getProgressPercentage(): number {
    if (this.maxProgress === 0) return 0
    return Math.round((this.progress / this.maxProgress) * 100)
  }

  // 检查是否已完成
  isCompleted(): boolean {
    return this.progress >= this.maxProgress
  }

  // 更新进度
  updateProgress(newProgress: number): void {
    this.progress = Math.min(newProgress, this.maxProgress)
    if (this.isCompleted() && !this.isUnlocked) {
      this.unlock()
    }
  }

  // 增加进度
  addProgress(amount: number = 1): void {
    this.updateProgress(this.progress + amount)
  }

  // 解锁成就
  unlock(): void {
    this.isUnlocked = true
    this.unlockedDate = new Date().toISOString().split('T')[0] // YYYY-MM-DD格式
    this.progress = this.maxProgress
  }

  // 获取稀有度颜色
  getRarityColor(): string {
    switch (this.rarity) {
      case 'common': return '#4CAF50'
      case 'rare': return '#2196F3'
      case 'epic': return '#9C27B0'
      case 'legendary': return '#FF9800'
      default: return '#666666'
    }
  }

  // 获取稀有度名称
  getRarityName(): string {
    switch (this.rarity) {
      case 'common': return '普通'
      case 'rare': return '稀有'
      case 'epic': return '史诗'
      case 'legendary': return '传说'
      default: return '未知'
    }
  }

  // 获取格式化的解锁日期
  getFormattedUnlockedDate(): string {
    if (!this.unlockedDate) return ''
    const date = new Date(this.unlockedDate)
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`
  }

  // 检查是否可以显示进度条
  shouldShowProgress(): boolean {
    return !this.isUnlocked && this.maxProgress > 1
  }

  // 获取进度文本
  getProgressText(): string {
    return `${this.progress}/${this.maxProgress}`
  }

  // 静态方法：创建默认成就列表
  static getDefaultAchievements(): AchievementModel[] {
    const achievements: AchievementModel[] = []

    // 学习成就
    const firstQuestion = new AchievementModel('first_question', '初学者', '完成第一道题目', '🎯', '学习成就', 1, 'common')
    firstQuestion.unlock()
    achievements.push(firstQuestion)

    const answer10 = new AchievementModel('answer_10', '小试牛刀', '累计答对10道题目', '📚', '学习成就', 10, 'common')
    answer10.unlock()
    achievements.push(answer10)

    const answer50 = new AchievementModel('answer_50', '勤学苦练', '累计答对50道题目', '🏆', '学习成就', 50, 'rare')
    answer50.updateProgress(23)
    achievements.push(answer50)

    // 考核成就
    const firstExam = new AchievementModel('first_exam', '考核新手', '完成第一次考核', '📝', '考核成就', 1, 'common')
    achievements.push(firstExam)

    const examPerfect = new AchievementModel('exam_perfect', '完美答卷', '在考核中获得满分', '⭐', '考核成就', 1, 'epic')
    achievements.push(examPerfect)

    // 连续学习
    const streak7 = new AchievementModel('streak_7', '坚持不懈', '连续学习7天', '🔥', '连续学习', 7, 'rare')
    streak7.updateProgress(3)
    achievements.push(streak7)

    const streak30 = new AchievementModel('streak_30', '学习达人', '连续学习30天', '💎', '连续学习', 30, 'legendary')
    streak30.updateProgress(3)
    achievements.push(streak30)

    // 特殊成就
    const nightOwl = new AchievementModel('night_owl', '夜猫子', '在晚上11点后完成学习', '🦉', '特殊成就', 1, 'rare')
    achievements.push(nightOwl)

    return achievements
  }
}