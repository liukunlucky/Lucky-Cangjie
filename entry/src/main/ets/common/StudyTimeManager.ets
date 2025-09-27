import { DatabaseManager } from './DatabaseManager'

export class StudyTimeManager {
  private static instance: StudyTimeManager
  private startTime: number = 0
  private totalSessionTime: number = 0
  private updateInterval: number = 0
  private isTracking: boolean = false

  private constructor() {}

  static getInstance(): StudyTimeManager {
    if (!StudyTimeManager.instance) {
      StudyTimeManager.instance = new StudyTimeManager()
    }
    return StudyTimeManager.instance
  }

  // 开始学习时长统计
  startTracking(): void {
    if (this.isTracking) {
      return
    }

    this.isTracking = true
    this.startTime = Date.now()
    this.totalSessionTime = 0

    console.info('[StudyTimeManager] 开始学习时长统计')

    // 每分钟更新一次学习时长
    this.updateInterval = setInterval(() => {
      this.updateStudyTime()
    }, 60000) // 60秒 = 1分钟
  }

  // 停止学习时长统计
  stopTracking(): void {
    if (!this.isTracking) {
      return
    }

    this.isTracking = false
    
    if (this.updateInterval) {
      clearInterval(this.updateInterval)
      this.updateInterval = 0
    }

    // 最后更新一次学习时长
    this.updateStudyTime()

    console.info('[StudyTimeManager] 停止学习时长统计')
  }

  // 更新学习时长到数据库
  private async updateStudyTime(): Promise<void> {
    if (!this.isTracking || this.startTime === 0) {
      return
    }

    try {
      const currentTime = Date.now()
      const sessionTime = Math.floor((currentTime - this.startTime) / 1000 / 60) // 转换为分钟
      
      if (sessionTime > this.totalSessionTime) {
        const newMinutes = sessionTime - this.totalSessionTime
        this.totalSessionTime = sessionTime

        console.info(`[StudyTimeManager] 本次会话学习时长: ${sessionTime}分钟, 新增: ${newMinutes}分钟`)

        // 更新数据库中的学习时长
        const dbManager = DatabaseManager.getInstance()
        await this.addStudyTime(newMinutes)
      }
    } catch (error) {
      console.error('[StudyTimeManager] 更新学习时长失败:', error)
    }
  }

  // 添加学习时长到数据库
  private async addStudyTime(minutes: number): Promise<void> {
    try {
      const dbManager = DatabaseManager.getInstance()
      const stats = await dbManager.getUserStats()
      const newTotalStudyTime = stats.totalStudyTime + minutes

      console.info(`[StudyTimeManager] 更新学习时长: ${stats.totalStudyTime} + ${minutes} = ${newTotalStudyTime}分钟`)

      await dbManager.updateStudyTime(newTotalStudyTime)
    } catch (error) {
      console.error('[StudyTimeManager] 添加学习时长失败:', error)
    }
  }

  // 获取当前会话的学习时长（分钟）
  getCurrentSessionTime(): number {
    if (!this.isTracking || this.startTime === 0) {
      return 0
    }

    const currentTime = Date.now()
    return Math.floor((currentTime - this.startTime) / 1000 / 60)
  }

  // 暂停统计（应用进入后台时）
  pauseTracking(): void {
    if (this.isTracking) {
      this.updateStudyTime() // 保存当前进度
      console.info('[StudyTimeManager] 暂停学习时长统计')
    }
  }

  // 恢复统计（应用回到前台时）
  resumeTracking(): void {
    if (this.isTracking) {
      this.startTime = Date.now() - (this.totalSessionTime * 60 * 1000) // 重新计算开始时间
      console.info('[StudyTimeManager] 恢复学习时长统计')
    }
  }
}