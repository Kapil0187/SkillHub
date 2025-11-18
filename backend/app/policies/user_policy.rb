class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end
  
  def create?
    user.admin?
  end

  def show?
    user.admin? || user == record
  end
end
