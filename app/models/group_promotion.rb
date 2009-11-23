class GroupPromotion < ProductPromotion
  def eligible?(order)
    super == 1.0
  end
end