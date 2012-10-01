class Task < ActiveRecord::Base
  attr_accessible :name, :description, :user_id, :start_date, :end_date, :master_task_id, :status, :finished
  
  belongs_to :master_task,   :class_name => "Task", :foreign_key => "master_task_id", :counter_cache => true
  has_many   :sub_task,    :class_name => "Task", :foreign_key => "master_task_id", :dependent => :destroy
  belongs_to :user
  scope :master_tasks, lambda{|user| { :conditions => { :user_id => user, :master_task_id => nil } } }
  scope :master_tasks, lambda{ where(:master_task_id=> nil) }
  
  validates :name, :presence => true
  validates :description, :presence => true
  validates :user_id, :presence => true
  validates :start_date, :presence => true
  validates :end_date, :presence => true
  
  before_create :validates_date
  before_validation :validates_master_date, :if => :is_subtasks?
  after_create :send_mail
  
  def validates_date
    errors.add(:start_date, "must be greater than equal to #{Date.today}") if Date.today > self[:start_date]
    errors.add(:end_date, "is not less than start date #{self[:start_date]}") if self[:start_date] > self[:end_date]
    validates_master_date unless self[master_task_id].nil?
  end

  def validates_master_date
      master_task = Task.where(:id => self[:master_task_id]).first
      errors.add(:start_date, 'is not in master task date range') if self[:start_date] < master_task.start_date
      errors.add(:end_date, 'is not in master task range') if self[:end_date] > master_task.end_date
  end

  def is_subtasks?
    self.master_task_id.nil? ? false : true
  end

  def send_mail
    TasksMail.create_task(self.user, self).deliver
  end

  def self.mail_schedule
    task = Task.master_tasks.where(:end_date => Date.today - 1)
    task.each do |task|
      TasksMail.schedule(task).deliver
    end	      
  end
end
