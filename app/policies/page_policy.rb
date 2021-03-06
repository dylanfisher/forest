class PagePolicy < BlockRecordPolicy
  def show?
    if @record.statusable?
      @record.published? || view_hidden?
    else
      true
    end
  end
end
