require_relative 'spec_helper'
require_relative '../dependency'

RSpec.describe DataUtils do
  let(:dummy_class) { Class.new { extend DataUtils } }
  let(:summary) do
    {
      name: 'Rspec',
      difficulty: 'Easy',
      att_total: 15,
      att_used: 1,
      hints_total: 3,
      hints_used: 1,
      date: Time.now
    }
  end

  describe '#load' do
    it 'loads a TableRow object array from file' do
      dummy_class.save(summary)
      expect(dummy_class.load[0].is_a?(TableRow)).to eq(true)
    end
  end
end
