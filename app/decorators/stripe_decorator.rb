class StripeDecorator < Draper::Decorator
  delegate :email, :account_balance
end