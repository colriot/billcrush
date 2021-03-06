class Group < ActiveRecord::Base
  validates :name, :presence => true
  before_save :canonicalize_name
  has_many :members
  has_many :transactions

  def best_way_to_settle
    settlement = []
    balances = members.map { |m| {:balance => m.balance, :member => m} }
    Timeout.timeout(1) do
      while balances.size > 0
        balances = sort_and_filter(balances)
        break if balances.size == 0
        most_in_debt = balances.first
        most_positive = balances.last
        amount = [most_in_debt[:balance].abs, most_positive[:balance].abs].min.to_i
        settlement << {:payer => most_in_debt[:member], :payee => most_positive[:member], :amount => amount}
        most_in_debt[:balance] += amount
        most_positive[:balance] -= amount
      end
    end
    settlement
  end

  def to_param
    canonicalized_name
  end

  private
  def canonicalize_name
    self.canonicalized_name = name.parameterize
  end

  def sort_and_filter(balances)
    result = balances.sort_by { |b| b[:balance] }
    result.reject { |b| b[:balance] == 0 }
  end
end