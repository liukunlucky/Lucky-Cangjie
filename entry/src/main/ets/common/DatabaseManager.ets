import relationalStore from '@ohos.data.relationalStore'
import { Context } from '@ohos.abilityAccessCtrl'
import { AchievementModel } from './models/AchievementModel'
import { DiaryEntryModel } from './models/DiaryEntryModel'
import { GoalModel } from './models/GoalModel'
import util from '@ohos.util'
import { JobType, OfferModel, OfferStatus, WorkMode } from '../model/OfferModel'

interface Question {
  id: number
  type: string
  category: string
  difficulty: string
  question: string
  options: Record<string, string>
  answer: string[]
  explanation: string
}

interface FavoriteRecord {
  id: number
  time: string
}

interface WrongRecord {
  id: number
  wrongCount: number
  lastWrongDate: string
  isMastered: boolean
}

interface WrongQuestion {
  questionId: number
  type: string
  category: string
  difficulty: string
  question: string
  options: Record<string, string>
  correctAnswer: string
  explanation: string
  userAnswer: string
  wrongCount: number
  lastWrongTime: string
  isResolved: boolean
}

interface TestRecord {
  questionId: number;
  userAnswer: string;
  correctAnswer: string;
  isCorrect: boolean;
  category: string;
  difficulty: string;
}

interface AnswerRecord {
  questionId: number;
  userAnswer: string;
  correctAnswer: string;
  isCorrect: boolean;
  answerTime: number;
  questionType: string;
  category: string;
  difficulty: string;
  createdAt: string;
}

interface FavoriteQuestion {
  questionId: number;
  type: string;
  category: string;
  difficulty: string;
  question: string;
  options: Record<string, string>;
  answer: string[];
  explanation: string;
  favoriteTime: string;
}

interface UserStats {
  totalQuestions: number;
  correctAnswers: number;
  accuracy: number;
  streakDays: number;
  totalStudyTime: number;
  level: number;
  experience: number;
}

export interface OfferStatistics {
  total: number;
  pending: number;
  accepted: number;
  rejected: number;
  expired: number;
  avgSalary: number;
  maxSalary: number;
}

export interface GroupedOffers {
  urgent: OfferModel[];      // 紧急处理
  received: OfferModel[];    // 已收到
  pending: OfferModel[];     // 待定
  accepted: OfferModel[];    // 已接受
  rejected: OfferModel[];    // 已拒绝
  expired: OfferModel[];     // 已过期
}

export class DatabaseManager {
  private static instance: DatabaseManager
  private rdbStore: relationalStore.RdbStore | null = null
  private readonly DB_NAME = 'cangjie_learning.db'
  private readonly DB_VERSION = 1

  private constructor() {}

  static getInstance(): DatabaseManager {
    if (!DatabaseManager.instance) {
      DatabaseManager.instance = new DatabaseManager()
    }
    return DatabaseManager.instance
  }

  async initDatabase(context: Context): Promise<void> {
    try {
      const config: relationalStore.StoreConfig = {
        name: this.DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S1
      }

      this.rdbStore = await relationalStore.getRdbStore(context, config)
      await this.rebuildAchievementsTable()
      await this.createTables()
      console.info('数据库初始化成功')
    } catch (error) {
      console.error('数据库初始化失败:', error)
      throw new Error('数据库初始化失败')
    }
  }

  private async rebuildAchievementsTable(): Promise<void> {
    if (!this.rdbStore) return

    try {
      // 删除旧的achievements表
      await this.rdbStore.executeSql('DROP TABLE IF EXISTS achievements')
      console.info('已删除旧的achievements表')
    } catch (error) {
      console.error('删除旧achievements表失败:', error)
    }
  }

  private async createTables(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化')
    }

    // 用户统计表
    const createUserStatsTable = `
      CREATE TABLE IF NOT EXISTS user_stats (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total_questions INTEGER DEFAULT 0,
        correct_answers INTEGER DEFAULT 0,
        accuracy REAL DEFAULT 0.0,
        streak_days INTEGER DEFAULT 0,
        total_study_time INTEGER DEFAULT 0,
        level INTEGER DEFAULT 1,
        experience INTEGER DEFAULT 0,
        last_study_date TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 答题记录表
    const createAnswerRecordsTable = `
      CREATE TABLE IF NOT EXISTS answer_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        user_answer TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        is_correct INTEGER NOT NULL,
        answer_time INTEGER NOT NULL,
        question_type TEXT NOT NULL,
        category TEXT NOT NULL,
        difficulty TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 收藏表
    const createFavoritesTable = `
      CREATE TABLE IF NOT EXISTS favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL UNIQUE,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 错题本表
    const createWrongQuestionsTable = `
      CREATE TABLE IF NOT EXISTS wrong_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL,
        wrong_count INTEGER DEFAULT 1,
        last_wrong_date TEXT DEFAULT CURRENT_TIMESTAMP,
        is_mastered INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 考核记录表
    const createExamRecordsTable = `
      CREATE TABLE IF NOT EXISTS exam_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exam_id TEXT NOT NULL,
        exam_title TEXT NOT NULL,
        total_questions INTEGER NOT NULL,
        correct_answers INTEGER NOT NULL,
        score REAL NOT NULL,
        time_spent INTEGER NOT NULL,
        passed INTEGER NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 学习路线进度表
    const createLearningProgressTable = `
      CREATE TABLE IF NOT EXISTS learning_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL UNIQUE,
        completed_questions INTEGER DEFAULT 0,
        total_questions INTEGER DEFAULT 0,
        progress_percentage REAL DEFAULT 0.0,
        last_study_date TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 成就表
    const createAchievementsTable = `
      CREATE TABLE IF NOT EXISTS achievements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        icon TEXT NOT NULL,
        is_unlocked INTEGER DEFAULT 0,
        unlocked_date TEXT,
        progress INTEGER DEFAULT 0,
        max_progress INTEGER DEFAULT 1,
        category TEXT NOT NULL,
        rarity TEXT DEFAULT 'common',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 题目笔记表
    const createQuestionNotesTable = `
      CREATE TABLE IF NOT EXISTS question_notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER NOT NULL UNIQUE,
        note_content TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 每日一题记录表
    const createDailyQuestionTable = `
      CREATE TABLE IF NOT EXISTS daily_question_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        question_id INTEGER NOT NULL,
        is_completed INTEGER DEFAULT 0,
        is_correct INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 目标表
    const createGoalsTable = `
      CREATE TABLE IF NOT EXISTS goals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        category TEXT NOT NULL,
        target_value INTEGER NOT NULL,
        current_value INTEGER DEFAULT 0,
        unit TEXT NOT NULL,
        deadline TEXT,
        is_completed INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 日记表
    const createDiaryTable = `
      CREATE TABLE IF NOT EXISTS diary_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        mood TEXT NOT NULL,
        study_time REAL DEFAULT 0,
        questions_answered INTEGER DEFAULT 0,
        achievements TEXT,
        tags TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        updated_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `

    // 创建Offer表
    const createOffersTable = `
      CREATE TABLE IF NOT EXISTS offers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company TEXT NOT NULL,
        position TEXT NOT NULL,
        base_salary REAL NOT NULL,
        bonus REAL DEFAULT 0,
        stock_options REAL DEFAULT 0,
        other_benefits TEXT,
        work_type INTEGER NOT NULL,
        work_mode INTEGER NOT NULL,
        work_location TEXT,
        offer_date TEXT NOT NULL,
        response_deadline TEXT,
        start_date TEXT,
        hr_contact TEXT,
        hr_name TEXT,
        hr_phone TEXT,
        hr_email TEXT,
        notes TEXT,
        satisfaction_score INTEGER DEFAULT 0,
        status INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    `;

    try {
      await this.rdbStore.executeSql(createUserStatsTable)
      await this.rdbStore.executeSql(createAnswerRecordsTable)
      await this.rdbStore.executeSql(createFavoritesTable)
      await this.rdbStore.executeSql(createWrongQuestionsTable)
      await this.rdbStore.executeSql(createExamRecordsTable)
      await this.rdbStore.executeSql(createLearningProgressTable)
      await this.rdbStore.executeSql(createAchievementsTable)
      await this.rdbStore.executeSql(createQuestionNotesTable)
      await this.rdbStore.executeSql(createDailyQuestionTable)
      await this.rdbStore.executeSql(createGoalsTable)
      await this.rdbStore.executeSql(createDiaryTable)
      await this.rdbStore.executeSql(createOffersTable)


      // 初始化用户统计数据
      await this.initUserStats()
      
      console.info('数据库表创建成功')
    } catch (error) {
      console.error('创建数据库表失败:', error)
      throw new Error('创建数据库表失败')
    }
  }

  private async initUserStats(): Promise<void> {
    if (!this.rdbStore) return

    try {
      const resultSet = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM user_stats')
      if (resultSet.goToFirstRow()) {
        const count = resultSet.getLong(0)
        if (count === 0) {
          await this.rdbStore.executeSql(`
            INSERT INTO user_stats (total_questions, correct_answers, accuracy, streak_days, total_study_time, level, experience)
            VALUES (0, 0, 0.0, 0, 0, 1, 0)
          `)
        }
      }
      resultSet.close()
    } catch (error) {
      console.error('初始化用户统计失败:', error)
    }
  }

  // 获取用户统计数据
  async getUserStats(): Promise<UserStats> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化')
    }

    try {
      const resultSet = await this.rdbStore.querySql('SELECT * FROM user_stats LIMIT 1')
      console.info('getUserStats - 查询结果行数:', resultSet.rowCount)
      
      if (resultSet.goToFirstRow()) {
        const stats: UserStats = {
          totalQuestions: resultSet.getLong(resultSet.getColumnIndex('total_questions')),
          correctAnswers: resultSet.getLong(resultSet.getColumnIndex('correct_answers')),
          accuracy: resultSet.getDouble(resultSet.getColumnIndex('accuracy')),
          streakDays: resultSet.getLong(resultSet.getColumnIndex('streak_days')),
          totalStudyTime: resultSet.getLong(resultSet.getColumnIndex('total_study_time')),
          level: resultSet.getLong(resultSet.getColumnIndex('level')),
          experience: resultSet.getLong(resultSet.getColumnIndex('experience'))
        }
        resultSet.close()
        console.info('getUserStats - 返回统计数据:', JSON.stringify(stats))
        return stats
      }
      resultSet.close()
      const defaultStats: UserStats = {
        totalQuestions: 0,
        correctAnswers: 0,
        accuracy: 0,
        streakDays: 0,
        totalStudyTime: 0,
        level: 1,
        experience: 0
      }
      console.info('getUserStats - 返回默认统计数据:', JSON.stringify(defaultStats))
      return defaultStats
    } catch (error) {
      console.error('获取用户统计失败:', error)
      const errorStats: UserStats = {
        totalQuestions: 0,
        correctAnswers: 0,
        accuracy: 0,
        streakDays: 0,
        totalStudyTime: 0,
        level: 1,
        experience: 0
      }
      return errorStats
    }
  }

  // 记录答题
  async recordAnswer(questionId: number, userAnswer: string, correctAnswer: string, 
                    isCorrect: boolean, answerTime: number, questionType: string, 
                    category: string, difficulty: string): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化')
    }

    try {
      console.info(`记录答题: 题目${questionId}, 是否正确: ${isCorrect}`)
      
      // 插入答题记录
      await this.rdbStore.executeSql(`
        INSERT INTO answer_records (question_id, user_answer, correct_answer, is_correct, answer_time, question_type, category, difficulty)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `, [questionId, userAnswer, correctAnswer, isCorrect ? 1 : 0, answerTime, questionType, category, difficulty])

      // 更新用户统计
      console.info('开始更新用户统计数据')
      await this.updateUserStats(isCorrect)
      console.info('用户统计数据更新完成')

      // 如果答错，添加到错题本
      if (!isCorrect) {
        await this.addToWrongQuestions(questionId)
      }

      // 更新学习进度
      await this.updateLearningProgress(category)

    } catch (error) {
      console.error('记录答题失败:', error)
      throw new Error('记录答题失败')
    }
  }

  // 更新用户统计
  private async updateUserStats(isCorrect: boolean): Promise<void> {
    if (!this.rdbStore) return

    try {
      const stats: UserStats = await this.getUserStats()
      console.info(`更新前统计: 总题数=${stats.totalQuestions}, 正确数=${stats.correctAnswers}, 连续天数=${stats.streakDays}`)
      
      const newTotalQuestions: number = stats.totalQuestions + 1
      const newCorrectAnswers: number = stats.correctAnswers + (isCorrect ? 1 : 0)
      const newAccuracy: number = (newCorrectAnswers / newTotalQuestions) * 100

      // 计算连续天数
      const newStreakDays = await this.calculateStreakDays()
      
      console.info(`更新后统计: 总题数=${newTotalQuestions}, 正确数=${newCorrectAnswers}, 准确率=${newAccuracy}%, 连续天数=${newStreakDays}`)

      await this.rdbStore.executeSql(`
        UPDATE user_stats SET 
          total_questions = ?,
          correct_answers = ?,
          accuracy = ?,
          streak_days = ?,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = 1
      `, [newTotalQuestions, newCorrectAnswers, newAccuracy, newStreakDays])

      console.info('用户统计数据库更新成功')

    } catch (error) {
      console.error('更新用户统计失败:', error)
    }
  }

  // 计算连续学习天数
  private async calculateStreakDays(): Promise<number> {
    if (!this.rdbStore) return 0

    try {
      // 获取所有答题记录，按日期分组
      const resultSet = await this.rdbStore.querySql(`
        SELECT DISTINCT DATE(created_at) as answer_date
        FROM answer_records 
        ORDER BY answer_date DESC
      `)

      const answerDates: string[] = []
      while (resultSet.goToNextRow()) {
        const dateStr = resultSet.getString(resultSet.getColumnIndex('answer_date'))
        answerDates.push(dateStr)
      }
      resultSet.close()

      if (answerDates.length === 0) {
        return 0
      }

      console.info(`[DatabaseManager] 所有答题日期:`, answerDates)

      // 计算连续天数
      let streakDays = 0
      const today = new Date()
      const todayStr = today.toISOString().split('T')[0] // YYYY-MM-DD格式

      // 从今天开始检查连续天数
      let currentDate = new Date(today)
      
      // 无限循环检查连续天数，直到找到没有答题的日期
      while (true) {
        const checkDateStr = currentDate.toISOString().split('T')[0]
        console.info(`[DatabaseManager] 检查日期: ${checkDateStr}`)
        
        if (answerDates.includes(checkDateStr)) {
          streakDays++
          console.info(`[DatabaseManager] 找到答题日期: ${checkDateStr}, 连续天数: ${streakDays}`)
          // 往前推一天
          currentDate.setDate(currentDate.getDate() - 1)
        } else {
          console.info(`[DatabaseManager] 未找到答题日期: ${checkDateStr}, 停止计算`)
          break
        }
      }

      console.info(`[DatabaseManager] 最终计算连续天数: ${streakDays}天`)
      return streakDays

    } catch (error) {
      console.error('计算连续天数失败:', error)
      return 0
    }
  }

  // 更新学习时长
  async updateStudyTime(totalStudyTime: number): Promise<void> {
    if (!this.rdbStore) return

    try {
      await this.rdbStore.executeSql(`
        UPDATE user_stats SET 
          total_study_time = ?,
          updated_at = CURRENT_TIMESTAMP
        WHERE id = 1
      `, [totalStudyTime])

      console.info(`[DatabaseManager] 学习时长更新成功: ${totalStudyTime}分钟`)
    } catch (error) {
      console.error('[DatabaseManager] 更新学习时长失败:', error)
    }
  }

  // 添加到错题本
  async addToWrongQuestions(questionId: number): Promise<void> {
    if (!this.rdbStore) return

    try {
      // 检查是否已存在
      const resultSet = await this.rdbStore.querySql(
        'SELECT * FROM wrong_questions WHERE question_id = ?', [questionId]
      )

      if (resultSet.goToFirstRow()) {
        // 更新错误次数
        const wrongCount = resultSet.getLong(resultSet.getColumnIndex('wrong_count'))
        await this.rdbStore.executeSql(`
          UPDATE wrong_questions SET 
            wrong_count = ?,
            last_wrong_date = CURRENT_TIMESTAMP
          WHERE question_id = ?
        `, [wrongCount + 1, questionId])
      } else {
        // 插入新记录
        await this.rdbStore.executeSql(`
          INSERT INTO wrong_questions (question_id, wrong_count, last_wrong_date)
          VALUES (?, 1, CURRENT_TIMESTAMP)
        `, [questionId])
      }
      resultSet.close()

    } catch (error) {
      console.error('添加错题失败:', error)
    }
  }

  // 更新学习进度
  private async updateLearningProgress(category: string): Promise<void> {
    if (!this.rdbStore) return

    try {
      // 检查是否已存在该分类的进度记录
      const resultSet = await this.rdbStore.querySql(
        'SELECT * FROM learning_progress WHERE category = ?', [category]
      )

      if (resultSet.goToFirstRow()) {
        // 更新进度
        const completedQuestions = resultSet.getLong(resultSet.getColumnIndex('completed_questions'))
        await this.rdbStore.executeSql(`
          UPDATE learning_progress SET 
            completed_questions = ?,
            last_study_date = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
          WHERE category = ?
        `, [completedQuestions + 1, category])
      } else {
        // 插入新记录
        await this.rdbStore.executeSql(`
          INSERT INTO learning_progress (category, completed_questions, total_questions, last_study_date)
          VALUES (?, 1, 0, CURRENT_TIMESTAMP)
        `, [category])
      }
      resultSet.close()

    } catch (error) {
      console.error('更新学习进度失败:', error)
    }
  }

  // 添加收藏
  async addToFavorites(questionId: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化')
    }

    try {
      await this.rdbStore.executeSql(`
        INSERT OR IGNORE INTO favorites (question_id) VALUES (?)
      `, [questionId])
    } catch (error) {
      console.error('添加收藏失败:', error)
      throw new Error('添加收藏失败')
    }
  }

  // 移除收藏
  async removeFromFavorites(questionId: number): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化')
    }

    try {
      await this.rdbStore.executeSql(`
        DELETE FROM favorites WHERE question_id = ?
      `, [questionId])
    } catch (error) {
      console.error('移除收藏失败:', error)
      throw new Error('移除收藏失败')
    }
  }

  // 获取收藏列表
  async getFavorites(): Promise<number[]> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化')
    }

    try {
      const resultSet = await this.rdbStore.querySql('SELECT question_id FROM favorites ORDER BY created_at DESC')
      const favorites: number[] = []
      
      while (resultSet.goToNextRow()) {
        favorites.push(resultSet.getLong(0))
      }
      
      resultSet.close()
      return favorites
    } catch (error) {
      console.error('获取收藏列表失败:', error)
      return []
    }
  }

  // 检查是否已收藏
  async isFavorite(questionId: number): Promise<boolean> {
    if (!this.rdbStore) {
      return false
    }

    try {
      const resultSet = await this.rdbStore.querySql(
        'SELECT COUNT(*) as count FROM favorites WHERE question_id = ?', [questionId]
      )
      
      if (resultSet.goToFirstRow()) {
        const count = resultSet.getLong(0)
        resultSet.close()
        return count > 0
      }
      
      resultSet.close()
      return false
    } catch (error) {
      console.error('检查收藏状态失败:', error)
      return false
    }
  }

  // 保存题目笔记
  async saveQuestionNote(questionId: number, noteContent: string): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化')
    }

    try {
      await this.rdbStore.executeSql(`
        INSERT OR REPLACE INTO question_notes (question_id, note_content, updated_at)
        VALUES (?, ?, CURRENT_TIMESTAMP)
      `, [questionId, noteContent])
    } catch (error) {
      console.error('保存笔记失败:', error)
      throw new Error('保存笔记失败')
    }
  }

  // 获取题目笔记
  async getQuestionNote(questionId: number): Promise<string> {
    if (!this.rdbStore) {
      return ''
    }

    try {
      const resultSet = await this.rdbStore.querySql(
        'SELECT note_content FROM question_notes WHERE question_id = ?', [questionId]
      )
      
      if (resultSet.goToFirstRow()) {
        const note = resultSet.getString(0)
        resultSet.close()
        return note
      }
      
      resultSet.close()
      return ''
    } catch (error) {
      console.error('获取笔记失败:', error)
      return ''
    }
  }

  // 记录考核结果
  async recordExamResult(examId: string, examTitle: string, totalQuestions: number, 
                        correctAnswers: number, score: number, timeSpent: number, 
                        passed: boolean): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化')
    }

    try {
      await this.rdbStore.executeSql(`
        INSERT INTO exam_records (exam_id, exam_title, total_questions, correct_answers, score, time_spent, passed)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `, [examId, examTitle, totalQuestions, correctAnswers, score, timeSpent, passed ? 1 : 0])
    } catch (error) {
      console.error('记录考核结果失败:', error)
      throw new Error('记录考核结果失败')
    }
  }

  // 清除所有数据
  async clearAllData(): Promise<void> {
    if (!this.rdbStore) {
      throw new Error('数据库未初始化')
    }

    try {
      const tables = [
        'answer_records', 'favorites', 'wrong_questions', 'exam_records',
        'learning_progress', 'achievements', 'question_notes', 'daily_question_records'
      ]

      for (const table of tables) {
        await this.rdbStore.executeSql(`DELETE FROM ${table}`)
      }

      // 重置用户统计
      await this.rdbStore.executeSql(`
        UPDATE user_stats SET 
          total_questions = 0,
          correct_answers = 0,
          accuracy = 0.0,
          streak_days = 0,
          total_study_time = 0,
          level = 1,
          experience = 0,
          updated_at = CURRENT_TIMESTAMP
      `)

    } catch (error) {
      console.error('清除数据失败:', error)
      throw new Error('清除数据失败')
    }
  }

  // 获取收藏的题目
  async getFavoriteQuestions(): Promise<FavoriteQuestion[]> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      // 获取收藏的题目ID列表
      const resultSet = await this.rdbStore.querySql(
        'SELECT question_id, created_at FROM favorites ORDER BY created_at DESC'
      )

      const favoriteIds: FavoriteRecord[] = []
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow()
        do {
          favoriteIds.push({
            id: resultSet.getLong(0),
            time: resultSet.getString(1)
          })
        } while (resultSet.goToNextRow())
      }
      resultSet.close()

      if (favoriteIds.length === 0) {
        return []
      }

      // 从题库文件中加载题目详情
      const favoriteQuestions: FavoriteQuestion[] = []
      try {
        const context = getContext(this)
        const fileData = await context.resourceManager.getRawFileContent('cangjie.json')
        const decoder = new util.TextDecoder('utf-8')
        const jsonStr = decoder.decodeWithStream(new Uint8Array(fileData.buffer))
        const allQuestions: Question[] = JSON.parse(jsonStr)

        // 匹配收藏的题目
        for (const favoriteId of favoriteIds) {
          const question = allQuestions.find(q => q.id === favoriteId.id)
          if (question) {
            const favoriteQuestion: FavoriteQuestion = {
              questionId: question.id,
              type: question.type,
              category: question.category,
              difficulty: question.difficulty,
              question: question.question,
              options: question.options,
              answer: question.answer,
              explanation: question.explanation,
              favoriteTime: favoriteId.time
            }
            favoriteQuestions.push(favoriteQuestion)
          }
        }
      } catch (error) {
        console.error('加载题库文件失败:', error)
      }

      return favoriteQuestions
    } catch (error) {
      console.error('获取收藏题目失败:', error)
      return []
    }
  }

  // 移除收藏
  async removeFavorite(questionId: number): Promise<void> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(
        'DELETE FROM favorites WHERE question_id = ?',
        [questionId]
      )
    } catch (error) {
      console.error('移除收藏失败:', error)
      throw new Error('移除收藏失败')
    }
  }

  // 获取错题
  async getWrongQuestions(): Promise<WrongQuestion[]> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      // 获取错题记录
      const resultSet = await this.rdbStore.querySql(`
        SELECT question_id, wrong_count, last_wrong_date, is_mastered 
        FROM wrong_questions 
        ORDER BY last_wrong_date DESC
      `)

      const wrongRecords: WrongRecord[] = []
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow()
        do {
          wrongRecords.push({
            id: resultSet.getLong(0),
            wrongCount: resultSet.getLong(1),
            lastWrongDate: resultSet.getString(2),
            isMastered: resultSet.getLong(3) === 1
          })
        } while (resultSet.goToNextRow())
      }
      resultSet.close()

      if (wrongRecords.length === 0) {
        return []
      }

      // 从题库文件中加载题目详情
      const wrongQuestions: WrongQuestion[] = []
      try {
        const context = getContext(this)
        const fileData = await context.resourceManager.getRawFileContent('cangjie.json')
        const decoder = new util.TextDecoder('utf-8')
        const jsonStr = decoder.decodeWithStream(new Uint8Array(fileData.buffer))
        const allQuestions: Question[] = JSON.parse(jsonStr)

        // 匹配错题
        for (const wrongRecord of wrongRecords) {
          const question = allQuestions.find(q => q.id === wrongRecord.id)
          if (question) {
            // 获取用户的错误答案（从答题记录中查询最近一次的错误答案）
            let userAnswer = ''
            try {
              const answerResultSet = await this.rdbStore.querySql(
                'SELECT user_answer FROM answer_records WHERE question_id = ? AND is_correct = 0 ORDER BY created_at DESC LIMIT 1',
                [wrongRecord.id]
              )
              if (answerResultSet.rowCount > 0) {
                answerResultSet.goToFirstRow()
                userAnswer = answerResultSet.getString(0)
              }
              answerResultSet.close()
            } catch (error) {
              console.error('获取用户答案失败:', error)
            }

            const wrongQuestion: WrongQuestion = {
              questionId: question.id,
              type: question.type,
              category: question.category,
              difficulty: question.difficulty,
              question: question.question,
              options: question.options,
              correctAnswer: question.answer.join(','),
              explanation: question.explanation,
              userAnswer: userAnswer,
              wrongCount: wrongRecord.wrongCount,
              lastWrongTime: wrongRecord.lastWrongDate,
              isResolved: wrongRecord.isMastered
            }
            wrongQuestions.push(wrongQuestion)
          }
        }
      } catch (error) {
        console.error('加载题库文件失败:', error)
      }

      return wrongQuestions
    } catch (error) {
      console.error('获取错题失败:', error)
      return []
    }
  }

  // 检查数据库表状态
  async checkDatabaseStatus(): Promise<void> {
    if (!this.rdbStore) {
      console.error('[DatabaseManager] 数据库未初始化')
      return
    }

    try {
      // 检查answer_records表的记录数量
      const answerRecordsResult = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM answer_records')
      if (answerRecordsResult.goToFirstRow()) {
        const answerRecordsCount = answerRecordsResult.getLong(0)
        console.info(`[DatabaseManager] answer_records表中有 ${answerRecordsCount} 条记录`)
      }
      answerRecordsResult.close()

      // 检查user_stats表的数据
      const userStatsResult = await this.rdbStore.querySql('SELECT * FROM user_stats LIMIT 1')
      if (userStatsResult.goToFirstRow()) {
        const totalQuestions = userStatsResult.getLong(userStatsResult.getColumnIndex('total_questions'))
        const correctAnswers = userStatsResult.getLong(userStatsResult.getColumnIndex('correct_answers'))
        console.info(`[DatabaseManager] user_stats: 总题数=${totalQuestions}, 正确数=${correctAnswers}`)
      }
      userStatsResult.close()

      // 检查最近的几条答题记录
      const recentRecordsResult = await this.rdbStore.querySql(`
        SELECT question_id, category, difficulty, is_correct, created_at 
        FROM answer_records 
        ORDER BY created_at DESC 
        LIMIT 5
      `)
      
      console.info(`[DatabaseManager] 最近的答题记录:`)
      if (recentRecordsResult.rowCount > 0) {
        recentRecordsResult.goToFirstRow()
        let index = 1
        do {
          const questionId = recentRecordsResult.getLong(0)
          const category = recentRecordsResult.getString(1)
          const difficulty = recentRecordsResult.getString(2)
          const isCorrect = recentRecordsResult.getLong(3) === 1
          const createdAt = recentRecordsResult.getString(4)
          console.info(`[DatabaseManager] ${index}. 题目${questionId}, 分类:${category}, 难度:${difficulty}, 正确:${isCorrect}, 时间:${createdAt}`)
          index++
        } while (recentRecordsResult.goToNextRow())
      } else {
        console.info(`[DatabaseManager] 没有找到任何答题记录`)
      }
      recentRecordsResult.close()

    } catch (error) {
      console.error('[DatabaseManager] 检查数据库状态失败:', error)
    }
  }

  // 获取答题记录
  async getAnswerRecords(): Promise<AnswerRecord[]> {
    try {
      console.info('[DatabaseManager] 开始获取答题记录...')
      
      if (!this.rdbStore) {
        console.error('[DatabaseManager] 数据库未初始化')
        throw new Error('数据库未初始化')
      }

      const resultSet = await this.rdbStore.querySql(`
        SELECT question_id, user_answer, correct_answer, is_correct, 
               answer_time, question_type, category, difficulty, created_at
        FROM answer_records 
        ORDER BY created_at DESC
      `)

      console.info(`[DatabaseManager] 查询到 ${resultSet.rowCount} 条答题记录`)

      const records: AnswerRecord[] = []
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow()
        do {
          const record: AnswerRecord = {
            questionId: resultSet.getLong(0),
            userAnswer: resultSet.getString(1),
            correctAnswer: resultSet.getString(2),
            isCorrect: resultSet.getLong(3) === 1,
            answerTime: resultSet.getLong(4),
            questionType: resultSet.getString(5),
            category: resultSet.getString(6),
            difficulty: resultSet.getString(7),
            createdAt: resultSet.getString(8)
          }
          records.push(record)
          
          // 打印前3条记录的详细信息
          if (records.length <= 3) {
            console.info(`[DatabaseManager] 记录${records.length}: questionId=${record.questionId}, category=${record.category}, difficulty=${record.difficulty}, isCorrect=${record.isCorrect}`)
          }
        } while (resultSet.goToNextRow())
      }
      resultSet.close()

      console.info(`[DatabaseManager] 返回 ${records.length} 条答题记录`)
      return records
    } catch (error) {
      console.error('[DatabaseManager] 获取答题记录失败:', error)
      return []
    }
  }

  // ==================== 目标管理方法 ====================
  
  // 添加目标
  async addGoal(goal: GoalModel): Promise<boolean> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(`
        INSERT INTO goals (title, description, category, target_value, current_value, unit, deadline)
        VALUES (?, ?, ?, ?, ?, ?, ?)
      `, [goal.title, goal.description, goal.category, goal.targetValue, goal.currentValue, goal.unit, goal.deadline])

      return true
    } catch (error) {
      console.error('添加目标失败:', error)
      return false
    }
  }

  // 获取所有目标
  async getAllGoals(): Promise<GoalModel[]> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      const resultSet = await this.rdbStore.querySql(`
        SELECT id, title, description, category, target_value, current_value, unit, deadline, is_completed, created_at
        FROM goals 
        ORDER BY created_at DESC
      `)

      const goals: GoalModel[] = []
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow()
        do {
          const goal = new GoalModel()
          goal.id = resultSet.getLong(0)
          goal.title = resultSet.getString(1)
          goal.description = resultSet.getString(2)
          goal.category = resultSet.getString(3)
          goal.targetValue = resultSet.getLong(4)
          goal.currentValue = resultSet.getLong(5)
          goal.unit = resultSet.getString(6)
          goal.deadline = resultSet.getString(7)
          goal.isCompleted = resultSet.getLong(8) === 1
          goal.createdAt = resultSet.getString(9)
          goals.push(goal)
        } while (resultSet.goToNextRow())
      }
      resultSet.close()

      return goals
    } catch (error) {
      console.error('获取目标列表失败:', error)
      return []
    }
  }

  // 更新目标进度
  async updateGoalProgress(goalId: number, currentValue: number): Promise<boolean> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(`
        UPDATE goals 
        SET current_value = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `, [currentValue, goalId])

      return true
    } catch (error) {
      console.error('更新目标进度失败:', error)
      return false
    }
  }

  // 完成目标
  async completeGoal(goalId: number): Promise<boolean> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(`
        UPDATE goals 
        SET is_completed = 1, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `, [goalId])

      return true
    } catch (error) {
      console.error('完成目标失败:', error)
      return false
    }
  }

  // 删除目标
  async deleteGoal(goalId: number): Promise<boolean> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(`
        DELETE FROM goals WHERE id = ?
      `, [goalId])

      return true
    } catch (error) {
      console.error('删除目标失败:', error)
      return false
    }
  }

  // ==================== 日记管理方法 ====================
  
  // 添加日记
  async addDiaryEntry(entry: DiaryEntryModel): Promise<boolean> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(`
        INSERT INTO diary_entries (date, title, content, mood, study_time, questions_answered, achievements, tags)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `, [entry.date, entry.title, entry.content, entry.mood, entry.studyTime, entry.questionsAnswered, 
          JSON.stringify(entry.achievements), JSON.stringify(entry.tags)])

      return true
    } catch (error) {
      console.error('添加日记失败:', error)
      return false
    }
  }

  // 获取所有日记
  async getAllDiaryEntries(): Promise<DiaryEntryModel[]> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      const resultSet = await this.rdbStore.querySql(`
        SELECT id, date, title, content, mood, study_time, questions_answered, achievements, tags, created_at
        FROM diary_entries 
        ORDER BY date DESC
      `)

      const entries: DiaryEntryModel[] = []
      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow()
        do {
          const entry = new DiaryEntryModel()
          entry.id = resultSet.getLong(0)
          entry.date = resultSet.getString(1)
          entry.title = resultSet.getString(2)
          entry.content = resultSet.getString(3)
          entry.mood = resultSet.getString(4)
          entry.studyTime = resultSet.getDouble(5)
          entry.questionsAnswered = resultSet.getLong(6)
          
          const achievementsStr = resultSet.getString(7)
          entry.achievements = achievementsStr ? JSON.parse(achievementsStr) : []
          
          const tagsStr = resultSet.getString(8)
          entry.tags = tagsStr ? JSON.parse(tagsStr) : []
          
          entry.createdAt = resultSet.getString(9)
          entries.push(entry)
        } while (resultSet.goToNextRow())
      }
      resultSet.close()

      return entries
    } catch (error) {
      console.error('获取日记列表失败:', error)
      return []
    }
  }

  // 根据日期获取日记
  async getDiaryByDate(date: string): Promise<DiaryEntryModel | null> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      const resultSet = await this.rdbStore.querySql(`
        SELECT id, date, title, content, mood, study_time, questions_answered, achievements, tags, created_at
        FROM diary_entries 
        WHERE date = ?
      `, [date])

      if (resultSet.rowCount > 0) {
        resultSet.goToFirstRow()
        const entry = new DiaryEntryModel()
        entry.id = resultSet.getLong(0)
        entry.date = resultSet.getString(1)
        entry.title = resultSet.getString(2)
        entry.content = resultSet.getString(3)
        entry.mood = resultSet.getString(4)
        entry.studyTime = resultSet.getDouble(5)
        entry.questionsAnswered = resultSet.getLong(6)
        
        const achievementsStr = resultSet.getString(7)
        entry.achievements = achievementsStr ? JSON.parse(achievementsStr) : []
        
        const tagsStr = resultSet.getString(8)
        entry.tags = tagsStr ? JSON.parse(tagsStr) : []
        
        entry.createdAt = resultSet.getString(9)
        resultSet.close()
        return entry
      }
      
      resultSet.close()
      return null
    } catch (error) {
      console.error('根据日期获取日记失败:', error)
      return null
    }
  }

  // 更新日记
  async updateDiaryEntry(entry: DiaryEntryModel): Promise<boolean> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(`
        UPDATE diary_entries 
        SET title = ?, content = ?, mood = ?, study_time = ?, questions_answered = ?, 
            achievements = ?, tags = ?, updated_at = CURRENT_TIMESTAMP
        WHERE id = ?
      `, [entry.title, entry.content, entry.mood, entry.studyTime, entry.questionsAnswered,
          JSON.stringify(entry.achievements), JSON.stringify(entry.tags), entry.id])

      return true
    } catch (error) {
      console.error('更新日记失败:', error)
      return false
    }
  }

  // 删除日记
  async deleteDiaryEntry(entryId: number): Promise<boolean> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(`
        DELETE FROM diary_entries WHERE id = ?
      `, [entryId])

      return true
    } catch (error) {
      console.error('删除日记失败:', error)
      return false
    }
  }

  // 成就相关方法
  async getAllAchievements(): Promise<AchievementModel[]> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      const resultSet = await this.rdbStore.querySql(`
        SELECT * FROM achievements ORDER BY created_at DESC
      `)

      const achievements: AchievementModel[] = []
      if (resultSet.rowCount > 0) {
        for (let i = 0; i < resultSet.rowCount; i++) {
          resultSet.goToRow(i)
          const achievement = new AchievementModel()
          achievement.id = resultSet.getLong(0).toString()
          achievement.title = resultSet.getString(1)
          achievement.description = resultSet.getString(2)
          achievement.icon = resultSet.getString(3)
          achievement.isUnlocked = resultSet.getLong(4) === 1
          achievement.unlockedDate = resultSet.getString(5)
          achievement.progress = resultSet.getLong(6)
          achievement.maxProgress = resultSet.getLong(7)
          achievement.category = resultSet.getString(8)
          const rarityStr = resultSet.getString(9)
          achievement.rarity = (rarityStr === 'common' || rarityStr === 'rare' || rarityStr === 'epic' || rarityStr === 'legendary') ? rarityStr : 'common'
          achievement.createdAt = resultSet.getString(10)
          achievements.push(achievement)
        }
      }
      resultSet.close()
      return achievements
    } catch (error) {
      console.error('获取成就列表失败:', error)
      return []
    }
  }

  async addAchievement(achievement: AchievementModel): Promise<boolean> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(`
        INSERT INTO achievements (title, description, icon, is_unlocked, unlocked_date, 
                                progress, max_progress, category, rarity, created_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      `, [achievement.title, achievement.description, achievement.icon, 
          achievement.isUnlocked ? 1 : 0, achievement.unlockedDate,
          achievement.progress, achievement.maxProgress, achievement.category,
          achievement.rarity, achievement.createdAt])

      return true
    } catch (error) {
      console.error('添加成就失败:', error)
      return false
    }
  }

  async updateAchievement(achievement: AchievementModel): Promise<boolean> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      await this.rdbStore.executeSql(`
        UPDATE achievements SET 
          progress = ?, 
          is_unlocked = ?, 
          unlocked_date = ?
        WHERE title = ?
      `, [achievement.progress, achievement.isUnlocked ? 1 : 0, 
          achievement.unlockedDate, achievement.title])

      return true
    } catch (error) {
      console.error('更新成就失败:', error)
      return false
    }
  }

  // 获取考核记录
  async getExamRecords(): Promise<ExamRecord[]> {
    try {
      if (!this.rdbStore) {
        throw new Error('数据库未初始化')
      }

      const resultSet = await this.rdbStore.querySql(`
        SELECT id, exam_id, exam_title, total_questions, correct_answers, 
               score, time_spent, passed, created_at
        FROM exam_records 
        ORDER BY created_at DESC
      `)

      const records: ExamRecord[] = []
      if (resultSet.rowCount > 0) {
        for (let i = 0; i < resultSet.rowCount; i++) {
          resultSet.goToRow(i)
          const record: ExamRecord = {
            id: resultSet.getLong(0),
            examTitle: resultSet.getString(2),
            score: resultSet.getLong(5),
            totalQuestions: resultSet.getLong(3),
            correctAnswers: resultSet.getLong(4),
            examDate: resultSet.getString(8),
            duration: resultSet.getLong(6),
            passed: resultSet.getLong(7) === 1
          }
          records.push(record)
        }
      }
      resultSet.close()
      return records
    } catch (error) {
      console.error('获取考核记录失败:', error)
      return []
    }
  }

  // 获取指定分类的正确答案数量
  async getCorrectAnswersByCategory(category: string): Promise<number> {
    if (!this.rdbStore) return 0

    try {
      const resultSet = await this.rdbStore.querySql(
        'SELECT COUNT(*) FROM answer_records WHERE category = ? AND is_correct = 1',
        [category]
      )

      let count = 0
      if (resultSet.goToFirstRow()) {
        count = resultSet.getLong(0)
      }
      resultSet.close()
      return count
    } catch (error) {
      console.error('获取分类正确答案数量失败:', error)
      return 0
    }
  }

  // 获取所有题目
  async getAllQuestions(): Promise<Question[]> {
    try {
      const context = getContext(this)
      const fileData = await context.resourceManager.getRawFileContent('cangjie.json')
      const decoder = new util.TextDecoder('utf-8')
      const jsonStr = decoder.decodeWithStream(new Uint8Array(fileData.buffer))
      const allQuestions: Question[] = JSON.parse(jsonStr)
      
      console.info(`[DatabaseManager] 从题库文件加载了 ${allQuestions.length} 道题目`)
      return allQuestions
    } catch (error) {
      console.error('[DatabaseManager] 加载题库文件失败:', error)
      return []
    }
  }
  // 插入Offer
  async insertOffer(offer: OfferModel): Promise<number> {
    if (!this.rdbStore) return 0

    const sql = `
      INSERT INTO offers (
        company, position, base_salary, bonus, stock_options, other_benefits,
        work_type, work_mode, work_location, offer_date, response_deadline,
        start_date, hr_contact, hr_name, hr_phone, hr_email, notes, satisfaction_score,
        status, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `;

    const now = new Date().toISOString();
    await this.rdbStore.executeSql(sql, [
      offer.company,
      offer.position,
      offer.baseSalary,
      offer.bonus,
      offer.stockOptions,
      offer.benefits,
      offer.jobType,
      offer.workMode,
      offer.location || '',
      offer.offerDate,
      offer.responseDate || '',
      offer.startDate || '',
      offer.hrContact || '',
      offer.hrName || '',
      '', // hr_phone - 暂时为空字符串，因为OfferModel中没有此字段
      '', // hr_email - 暂时为空字符串，因为OfferModel中没有此字段
      offer.notes || '',
      offer.satisfactionScore,
      offer.status,
      now,
      now
    ]);

    return 1;
  }

  // 更新Offer
  async updateOffer(offer: OfferModel): Promise<boolean> {
    if (!this.rdbStore) return false

    const sql = `
      UPDATE offers SET
        company = ?, position = ?, base_salary = ?, bonus = ?, stock_options = ?,
        other_benefits = ?, work_type = ?, work_mode = ?, work_location = ?,
        offer_date = ?, response_deadline = ?, start_date = ?, hr_contact = ?,
        hr_name = ?, hr_phone = ?, hr_email = ?, notes = ?, satisfaction_score = ?,
        status = ?, updated_at = ?
      WHERE id = ?
    `;

    await this.rdbStore.executeSql(sql, [
      offer.company,
      offer.position,
      offer.baseSalary,
      offer.bonus,
      offer.stockOptions,
      offer.benefits,
      offer.jobType,
      offer.workMode,
      offer.location || '',
      offer.offerDate,
      offer.responseDate || '',
      offer.startDate || '',
      offer.hrContact || '',
      offer.hrName || '',
      '', // hr_phone - 暂时为空字符串，因为OfferModel中没有此字段
      '', // hr_email - 暂时为空字符串，因为OfferModel中没有此字段
      offer.notes || '',
      offer.satisfactionScore,
      offer.status,
      new Date().toISOString(),
      offer.id
    ]);

    return true;
  }

  // 删除Offer
  async deleteOffer(id: number): Promise<boolean> {
    if (!this.rdbStore) return false

    const sql = 'DELETE FROM offers WHERE id = ?';
    await this.rdbStore.executeSql(sql, [id]);
    return true;
  }

  // 根据ID获取Offer
  async getOfferById(id: number): Promise<OfferModel | null> {
    if (!this.rdbStore) return null

    const sql = 'SELECT * FROM offers WHERE id = ?';
    const result = await this.rdbStore.querySql(sql, [id]);

    if (result.rowCount === 0) {
      return null;
    }

    result.goToRow(0);
    return this.mapResultToModel(result);
  }

  // 获取所有Offer
  async getAllOffers(): Promise<OfferModel[]> {
    if (!this.rdbStore) return []

    const sql = 'SELECT * FROM offers ORDER BY offer_date DESC, created_at DESC';
    const result = await this.rdbStore.querySql(sql);

    const offers: OfferModel[] = [];
    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      offers.push(this.mapResultToModel(result));
    }

    return offers;
  }

  // 根据状态筛选Offer
  async getOffersByStatus(status: OfferStatus): Promise<OfferModel[]> {
    if (!this.rdbStore) return []

    const sql = 'SELECT * FROM offers WHERE status = ? ORDER BY offer_date DESC';
    const result = await this.rdbStore.querySql(sql, [status]);

    const offers: OfferModel[] = [];
    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      offers.push(this.mapResultToModel(result));
    }

    return offers;
  }

  // 根据工作类型筛选Offer
  async getOffersByWorkType(workType: JobType): Promise<OfferModel[]> {
    if (!this.rdbStore) return []

    const sql = 'SELECT * FROM offers WHERE work_type = ? ORDER BY offer_date DESC';
    const result = await this.rdbStore.querySql(sql, [workType]);

    const offers: OfferModel[] = [];
    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      offers.push(this.mapResultToModel(result));
    }

    return offers;
  }

  // 搜索Offer
  async searchOffers(keyword: string): Promise<OfferModel[]> {
    if (!this.rdbStore) return []

    const sql = `
      SELECT * FROM offers
      WHERE company LIKE ? OR position LIKE ? OR notes LIKE ?
      ORDER BY offer_date DESC
    `;
    const searchTerm = `%${keyword}%`;
    const result = await this.rdbStore.querySql(sql, [searchTerm, searchTerm, searchTerm]);

    const offers: OfferModel[] = [];
    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      offers.push(this.mapResultToModel(result));
    }

    return offers;
  }

  // 获取即将过期的Offer
  async getExpiringOffers(days: number = 7): Promise<OfferModel[]> {
    if (!this.rdbStore) return []

    const futureDate = new Date();
    futureDate.setDate(futureDate.getDate() + days);
    const futureDateStr = futureDate.toISOString().split('T')[0];

    const sql = `
      SELECT * FROM offers
      WHERE status = ? AND response_deadline <= ? AND response_deadline != ''
      ORDER BY response_deadline ASC
    `;
    const result = await this.rdbStore.querySql(sql, [OfferStatus.PENDING, futureDateStr]);

    const offers: OfferModel[] = [];
    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      offers.push(this.mapResultToModel(result));
    }

    return offers;
  }

  // 获取Offer统计数据
  async getOfferStats(): Promise<OfferStatistics> {
    if (!this.rdbStore) {
      throw new Error('数据库为初始化！！')
    }

    const totalResult = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM offers');
    totalResult.goToRow(0);
    const total = totalResult.getLong(totalResult.getColumnIndex('count'));

    const pendingResult = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM offers WHERE status = ?', [OfferStatus.PENDING]);
    pendingResult.goToRow(0);
    const pending = pendingResult.getLong(pendingResult.getColumnIndex('count'));

    const acceptedResult = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM offers WHERE status = ?', [OfferStatus.ACCEPTED]);
    acceptedResult.goToRow(0);
    const accepted = acceptedResult.getLong(acceptedResult.getColumnIndex('count'));

    const rejectedResult = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM offers WHERE status = ?', [OfferStatus.REJECTED]);
    rejectedResult.goToRow(0);
    const rejected = rejectedResult.getLong(rejectedResult.getColumnIndex('count'));

    const expiredResult = await this.rdbStore.querySql('SELECT COUNT(*) as count FROM offers WHERE status = ?', [OfferStatus.EXPIRED]);
    expiredResult.goToRow(0);
    const expired = expiredResult.getLong(expiredResult.getColumnIndex('count'));

    const salaryResult = await this.rdbStore.querySql('SELECT AVG(base_salary + bonus) as avg_salary, MAX(base_salary + bonus) as max_salary FROM offers');
    salaryResult.goToRow(0);
    const avgSalary = salaryResult.getDouble(salaryResult.getColumnIndex('avg_salary'));
    const maxSalary = salaryResult.getDouble(salaryResult.getColumnIndex('max_salary'));

    return {
      total: Number(total),
      pending: Number(pending),
      accepted: Number(accepted),
      rejected: Number(rejected),
      expired: Number(expired),
      avgSalary: Number(avgSalary) || 0,
      maxSalary: Number(maxSalary) || 0
    };
  }

  // 按薪资排序获取Offer
  async getOffersSortedBySalary(ascending: boolean = false): Promise<OfferModel[]> {
    if (!this.rdbStore) return []

    const order = ascending ? 'ASC' : 'DESC';
    const sql = `SELECT * FROM offers ORDER BY (base_salary + bonus) ${order}`;
    const result = await this.rdbStore.querySql(sql);

    const offers: OfferModel[] = [];
    for (let i = 0; i < result.rowCount; i++) {
      result.goToRow(i);
      offers.push(this.mapResultToModel(result));
    }

    return offers;
  }

  private mapResultToModel(result: relationalStore.ResultSet): OfferModel {
    const offer = new OfferModel();

    offer.id = result.getLong(result.getColumnIndex('id'));
    offer.company = result.getString(result.getColumnIndex('company'));
    offer.position = result.getString(result.getColumnIndex('position'));
    offer.baseSalary = result.getDouble(result.getColumnIndex('base_salary'));
    offer.bonus = result.getDouble(result.getColumnIndex('bonus'));
    offer.stockOptions = result.getString(result.getColumnIndex('stock_options'));

    const benefitsStr = result.getString(result.getColumnIndex('other_benefits'));
    offer.benefits = benefitsStr ? benefitsStr : '';

    offer.jobType = result.getString(result.getColumnIndex('work_type')) as JobType;
    offer.workMode = result.getString(result.getColumnIndex('work_mode')) as WorkMode;
    offer.location = result.getString(result.getColumnIndex('work_location'));
    offer.offerDate = result.getString(result.getColumnIndex('offer_date'));
    offer.responseDate = result.getString(result.getColumnIndex('response_deadline'));
    offer.startDate = result.getString(result.getColumnIndex('start_date'));
    offer.hrContact = result.getString(result.getColumnIndex('hr_contact'));
    offer.hrName = result.getString(result.getColumnIndex('hr_name'));
    offer.notes = result.getString(result.getColumnIndex('notes'));
    offer.satisfactionScore = result.getLong(result.getColumnIndex('satisfaction_score'));
    offer.status = result.getString(result.getColumnIndex('status')) as OfferStatus;

    return offer;
  }
}

// ExamRecord接口定义
interface ExamRecord {
  id: number
  examTitle: string
  score: number
  totalQuestions: number
  correctAnswers: number
  examDate: string
  duration: number
  passed: boolean
}