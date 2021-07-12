class Attendance < ApplicationRecord
  belongs_to :user

  validates :worked_on, presence: true
  validates :note, length: { maximum: 50 }

  # 出勤時間が存在しない場合、退勤時間は無効
  validate :finished_at_is_invalid_without_a_started_at
  
  # 退勤時間が存在しない場合、は無効

  validate :without_a_finished_at_or_started_at_invalid

  # 出勤・退勤時間どちらも存在する時、出勤時間より早い退勤時間は無効
  validate :started_at_than_finished_at_fast_if_invalid

  #退社時間もしくは出社時間のみ
  validate :only_change_time_started_or_change_time_finished

  def finished_at_is_invalid_without_a_started_at
    errors.add(:started_at, "が必要です") if started_at.blank? && finished_at.present?
  end
  
  def without_a_finished_at_or_started_at_invalid
    if worked_on < Date.current
      if !started_at.nil? && finished_at.blank?
        errors.add(:finished_at, "が必要です")
      end
    end
  end
  
  def started_at_than_finished_at_fast_if_invalid
    if started_at.present? && finished_at.present?
      errors.add(:started_at, "より早い退勤時間は無効です") if started_at > finished_at
    end
  end

  def only_change_time_started_or_change_time_finished
    #debugger
    if !change_application_stamp.blank?
      if change_application_next_day == 1

        if (change_application_started_time.hour * 60 + change_application_started_time.min) > ((change_application_finished_time.hour + 24) * 60 + change_application_finished_time.min)
        errors.add(:change_application_started_time, "より早い退勤時間は無効です1") 
        end
      elsif change_application_next_day == 0
        if (change_application_started_time.hour * 60 + change_application_started_time.min) > (change_application_finished_time.hour * 60 + change_application_finished_time.min)
        errors.add(:change_application_started_time, "より早い退勤時間は無効です2")
        #debugger
        end 
      end
    end
  end

end