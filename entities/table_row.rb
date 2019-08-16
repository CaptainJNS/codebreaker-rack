class TableRow
  attr_accessor :name, :difficulty, :att_total, :att_used, :hints_total, :hints_used, :date

  def initialize(options)
    @name = options[:name]
    @difficulty = options[:difficulty]
    @att_total = options[:att_total]
    @att_used = options[:att_used]
    @hints_total = options[:hints_total]
    @hints_used = options[:hints_used]
    @date = options[:date]
  end
end
