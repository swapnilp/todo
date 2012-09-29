class TasksMail < ActionMailer::Base
  default :from => "from@example.com"
  
  def create_task(user, task)
    @task = task
    @user = user
    mail(:to => user.email, :subject => "Your task been created")
  end
  
  def schedule(task)
    @task = task
    mail(:to => task.user.email, :subject => "Task reminder")
  end
end
