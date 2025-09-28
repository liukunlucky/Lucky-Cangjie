/**
 * Offer状态枚举
 */
export enum OfferStatus {
  PENDING = 'pending',       // 待定
  RECEIVED = 'received',     // 已收到
  ACCEPTED = 'accepted',     // 已接受
  REJECTED = 'rejected',     // 已拒绝
  EXPIRED = 'expired'        // 已过期
}

/**
 * 工作类型枚举
 */
export enum JobType {
  FULL_TIME = 'full_time',   // 全职
  PART_TIME = 'part_time',   // 兼职
  INTERN = 'intern',         // 实习
  CONTRACT = 'contract'      // 合同工
}

/**
 * 工作模式枚举
 */
export enum WorkMode {
  ONSITE = 'onsite',         // 现场办公
  REMOTE = 'remote',         // 远程办公
  HYBRID = 'hybrid'          // 混合办公
}

/**
 * Offer模型
 */
export class OfferModel {
  id: number = 0;
  company: string = '';              // 公司名称
  position: string = '';             // 职位名称
  department: string = '';           // 部门
  location: string = '';             // 工作地点
  
  // 薪资信息
  baseSalary: number = 0;            // 基本工资（月薪，单位：元）
  annualSalary: number = 0;          // 年薪（单位：元）
  bonus: number = 0;                 // 年终奖（单位：元）
  stockOptions: string = '';         // 股票期权
  
  // 福利信息
  benefits: string = '';             // 福利待遇
  workingHours: string = '';         // 工作时间
  vacationDays: number = 0;          // 年假天数
  
  // Offer详情
  jobType: JobType = JobType.FULL_TIME;        // 工作类型
  workMode: WorkMode = WorkMode.ONSITE;        // 工作模式
  status: OfferStatus = OfferStatus.PENDING;   // Offer状态
  
  // 重要日期
  offerDate: string = '';            // Offer发放日期
  expiryDate: string = '';           // Offer截止日期
  startDate: string = '';            // 入职日期
  responseDate: string = '';         // 回复日期
  
  // 联系信息
  hrContact: string = '';            // HR联系方式
  hrName: string = '';               // HR姓名
  
  // 备注信息
  notes: string = '';                // 备注
  pros: string = '';                 // 优点
  cons: string = '';                 // 缺点
  
  // 评分
  satisfactionScore: number = 0;     // 满意度评分（1-5）
  
  // 时间戳
  createdAt: string = '';
  updatedAt: string = '';

  constructor() {
    const now = new Date().toISOString();
    this.createdAt = now;
    this.updatedAt = now;
  }

  /**
   * 获取Offer状态显示文本
   */
  getStatusText(): string {
    switch (this.status) {
      case OfferStatus.PENDING:
        return '待定';
      case OfferStatus.RECEIVED:
        return '已收到';
      case OfferStatus.ACCEPTED:
        return '已接受';
      case OfferStatus.REJECTED:
        return '已拒绝';
      case OfferStatus.EXPIRED:
        return '已过期';
      default:
        return '未知';
    }
  }

  /**
   * 获取工作类型显示文本
   */
  getJobTypeText(): string {
    switch (this.jobType) {
      case JobType.FULL_TIME:
        return '全职';
      case JobType.PART_TIME:
        return '兼职';
      case JobType.INTERN:
        return '实习';
      case JobType.CONTRACT:
        return '合同工';
      default:
        return '未知';
    }
  }

  /**
   * 获取工作模式显示文本
   */
  getWorkModeText(): string {
    switch (this.workMode) {
      case WorkMode.ONSITE:
        return '现场办公';
      case WorkMode.REMOTE:
        return '远程办公';
      case WorkMode.HYBRID:
        return '混合办公';
      default:
        return '未知';
    }
  }

  /**
   * 获取状态颜色
   */
  getStatusColor(): string {
    switch (this.status) {
      case OfferStatus.PENDING:
        return '#faad14';
      case OfferStatus.RECEIVED:
        return '#1890ff';
      case OfferStatus.ACCEPTED:
        return '#52c41a';
      case OfferStatus.REJECTED:
        return '#ff4d4f';
      case OfferStatus.EXPIRED:
        return '#d9d9d9';
      default:
        return '#d9d9d9';
    }
  }

  /**
   * 格式化薪资显示
   */
  getFormattedSalary(): string {
    if (this.annualSalary > 0) {
      return `${this.annualSalary.toFixed(1)}万/年`;
    } else if (this.baseSalary > 0) {
      return `${this.baseSalary.toFixed(1)}万/年`;
    }
    return '面议';
  }

  /**
   * 获取总包薪资
   */
  getTotalCompensation(): number {
    let total = this.annualSalary || this.baseSalary;
    total += this.bonus;
    return total;
  }

  /**
   * 格式化总包薪资显示
   */
  getFormattedTotalCompensation(): string {
    const total = this.getTotalCompensation();
    if (total > 0) {
      return `${total.toFixed(1)}万/年`;
    }
    return '面议';
  }

  /**
   * 检查Offer是否即将过期（3天内）
   */
  isExpiringSoon(): boolean {
    if (!this.expiryDate || this.status !== OfferStatus.RECEIVED) return false;
    const expiryTime = new Date(this.expiryDate).getTime();
    const now = new Date().getTime();
    const threeDaysLater = now + 3 * 24 * 60 * 60 * 1000;
    return expiryTime <= threeDaysLater && expiryTime > now;
  }

  /**
   * 检查Offer是否已过期
   */
  isExpired(): boolean {
    if (!this.expiryDate) return false;
    const expiryTime = new Date(this.expiryDate).getTime();
    const now = new Date().getTime();
    return expiryTime < now;
  }

  /**
   * 获取剩余天数
   */
  getRemainingDays(): number {
    if (!this.expiryDate) return -1;
    const expiryTime = new Date(this.expiryDate).getTime();
    const now = new Date().getTime();
    const diffTime = expiryTime - now;
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }

  /**
   * 获取剩余天数显示文本
   */
  getRemainingDaysText(): string {
    const days = this.getRemainingDays();
    if (days < 0) return '已过期';
    if (days === 0) return '今天到期';
    if (days === 1) return '明天到期';
    return `${days}天后到期`;
  }

  /**
   * 获取满意度星级显示
   */
  getSatisfactionStars(): string {
    return '★'.repeat(this.satisfactionScore) + '☆'.repeat(5 - this.satisfactionScore);
  }

  /**
   * 格式化日期显示
   */
  getFormattedDate(dateString: string): string {
    if (!dateString) return '';
    const date = new Date(dateString);
    return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
  }

  /**
   * 获取Offer优先级（用于排序）
   */
  getPriority(): number {
    switch (this.status) {
      case OfferStatus.RECEIVED:
        return this.isExpiringSoon() ? 5 : 4;
      case OfferStatus.PENDING:
        return 3;
      case OfferStatus.ACCEPTED:
        return 2;
      case OfferStatus.REJECTED:
        return 1;
      case OfferStatus.EXPIRED:
        return 0;
      default:
        return 0;
    }
  }

  /**
   * 检查是否需要紧急处理
   */
  needsUrgentAction(): boolean {
    return this.status === OfferStatus.RECEIVED && this.isExpiringSoon();
  }

  /**
   * 获取薪资竞争力等级
   */
  getSalaryLevel(): string {
    const total = this.getTotalCompensation();
    if (total >= 50) return '顶级';
    if (total >= 30) return '优秀';
    if (total >= 20) return '良好';
    if (total >= 10) return '一般';
    return '待议';
  }

  /**
   * 获取薪资竞争力颜色
   */
  getSalaryLevelColor(): string {
    const level = this.getSalaryLevel();
    switch (level) {
      case '顶级':
        return '#722ed1';
      case '优秀':
        return '#52c41a';
      case '良好':
        return '#1890ff';
      case '一般':
        return '#faad14';
      default:
        return '#d9d9d9';
    }
  }
}