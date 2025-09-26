import { DatabaseManager } from './DatabaseManager'
import { AchievementModel } from './models/AchievementModel'

export class AchievementManager {
  private static instance: AchievementManager
  private databaseManager: DatabaseManager

  private constructor() {
    this.databaseManager = DatabaseManager.getInstance()
  }

  static getInstance(): AchievementManager {
    if (!AchievementManager.instance) {
      AchievementManager.instance = new AchievementManager()
    }
    return AchievementManager.instance
  }

  // 初始化默认成就到数据库
  async initializeDefaultAchievements(): Promise<void> {
    try {
      const existingAchievements = await this.databaseManager.getAllAchievements()
      if (existingAchievements.length === 0) {
        const defaultAchievements = this.getDefaultAchievements()
        for (const achievement of defaultAchievements) {
          await this.databaseManager.addAchievement(achievement)
        }
        console.info('默认成就初始化完成')
      }
    } catch (error) {
      console.error('初始化默认成就失败:', error)
    }
  }

  // 检查并更新成就进度
  async checkAndUpdateAchievements(): Promise<void> {
    try {
      const userStats = await this.databaseManager.getUserStats()
      const examRecords = await this.databaseManager.getExamRecords()
      const achievements = await this.databaseManager.getAllAchievements()

      for (const achievement of achievements) {
        if (achievement.isUnlocked) continue

        let shouldUpdate = false
        let newProgress = achievement.progress

        switch (achievement.id) {
          case 'first_question':
            if (userStats.totalQuestions > 0) {
              newProgress = 1
              shouldUpdate = true
            }
            break

          case 'answer_10':
            newProgress = Math.min(userStats.correctAnswers, 10)
            shouldUpdate = newProgress !== achievement.progress
            break

          case 'answer_50':
            newProgress = Math.min(userStats.correctAnswers, 50)
            shouldUpdate = newProgress !== achievement.progress
            break

          case 'answer_100':
            newProgress = Math.min(userStats.correctAnswers, 100)
            shouldUpdate = newProgress !== achievement.progress
            break

          case 'first_exam':
            if (examRecords.length > 0) {
              newProgress = 1
              shouldUpdate = true
            }
            break

          case 'exam_perfect':
            const perfectExams = examRecords.filter(exam => exam.score === 100)
            if (perfectExams.length > 0) {
              newProgress = 1
              shouldUpdate = true
            }
            break

          case 'exam_pass_5':
            const passedExams = examRecords.filter(exam => exam.passed)
            newProgress = Math.min(passedExams.length, 5)
            shouldUpdate = newProgress !== achievement.progress
            break

          case 'high_accuracy':
            if (userStats.accuracy >= 90 && userStats.totalQuestions >= 20) {
              newProgress = 1
              shouldUpdate = true
            }
            break
        }

        if (shouldUpdate) {
          achievement.updateProgress(newProgress)
          await this.databaseManager.updateAchievement(achievement)
          
          if (achievement.isUnlocked) {
            console.info(`成就解锁: ${achievement.title}`)
            // 这里可以添加成就解锁的通知逻辑
          }
        }
      }
    } catch (error) {
      console.error('检查成就进度失败:', error)
    }
  }

  // 获取默认成就列表
  private getDefaultAchievements(): AchievementModel[] {
    const achievements: AchievementModel[] = []

    // 学习成就
    achievements.push(new AchievementModel('first_question', '初学者', '完成第一道题目', '🎯', '学习成就', 1, 'common'))
    achievements.push(new AchievementModel('answer_10', '小试牛刀', '累计答对10道题目', '📚', '学习成就', 10, 'common'))
    achievements.push(new AchievementModel('answer_50', '勤学苦练', '累计答对50道题目', '🏆', '学习成就', 50, 'rare'))
    achievements.push(new AchievementModel('answer_100', '学霸', '累计答对100道题目', '👑', '学习成就', 100, 'epic'))

    // 考核成就
    achievements.push(new AchievementModel('first_exam', '考核新手', '完成第一次考核', '📝', '考核成就', 1, 'common'))
    achievements.push(new AchievementModel('exam_perfect', '完美答卷', '在考核中获得满分', '⭐', '考核成就', 1, 'epic'))
    achievements.push(new AchievementModel('exam_pass_5', '考核达人', '通过5次考核', '🎖️', '考核成就', 5, 'rare'))

    // 准确率成就
    achievements.push(new AchievementModel('high_accuracy', '精准射手', '答题准确率达到90%（至少20题）', '🎯', '准确率成就', 1, 'rare'))

    return achievements
  }

  // 在答题后调用
  async onQuestionAnswered(isCorrect: boolean): Promise<void> {
    await this.checkAndUpdateAchievements()
  }

  // 在考核完成后调用
  async onExamCompleted(score: number, passed: boolean): Promise<void> {
    await this.checkAndUpdateAchievements()
  }
}