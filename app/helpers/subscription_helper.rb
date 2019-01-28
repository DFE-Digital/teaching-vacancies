module SubscriptionHelper
  def hex?(reference)
    reference.match(/^\h+$/)
  end
end
