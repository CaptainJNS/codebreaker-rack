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

  OVERRIDABLE_FILENAME = 'spec/stats.yml'.freeze

  describe '#save' do
    it 'saves a TableRow object to a new file' do
      random_file = 'random_file_name.yaml'
      dummy_class.save(summary, random_file)
      expect(File.exist?(random_file)).to eq(true)
      File.delete(random_file)
    end

    it 'saves a TableRow object to exists file' do
      old_size = File.new(OVERRIDABLE_FILENAME, 'a').size
      dummy_class.save(summary, OVERRIDABLE_FILENAME)
      new_size = File.new(OVERRIDABLE_FILENAME).size
      expect(new_size).to be > old_size
    end
  end

  describe '#load' do
    it 'loads a TableRow object array from file' do
      dummy_class.save(summary, OVERRIDABLE_FILENAME)
      expect(dummy_class.load(OVERRIDABLE_FILENAME)[0].is_a?(TableRow)).to eq(true)
    end
  end
end
