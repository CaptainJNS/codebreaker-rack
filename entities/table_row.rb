class TableRow
  attr_accessor :name, :difficulty, :att_total, :att_used, :hints_total, :hints_used, :date

  def initialize(name:, difficulty:, att_total:, att_used:, hints_total:, hints_used:, date:)
    @name = name
    @difficulty = difficulty
    @att_total = att_total
    @att_used = att_used
    @hints_total = hints_total
    @hints_used = hints_used
    @date = date
  end
end
