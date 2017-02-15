class Character
  def initialize(strength: 1, die: Die.new, logger: Logger.new)
    @strength = strength
    @die = die
    @logger = logger
  end

  def climb(difficulty: 10)
    roll = die.roll + strength
    logger.log("Climbing Check. Difficulty: #{difficulty}, Roll: #{roll}")
    roll >= difficulty
  end

  private

  attr_reader :die, :strength, :logger
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:logger) { double('Logger', log: nil) }
    let(:character) { Character.new(strength: 5, die: die, logger: logger) }

    it 'succeeds when (roll + strength) > climb difficulty' do
      allow(die).to receive(:roll) { 11 }
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    it 'fails when (roll + strength) < climb difficulty' do
      allow(die).to receive(:roll) { 9 }
      expect(character.climb(difficulty: 15)).to be_falsy
    end

    it 'commands logger to log climb skill check' do
      allow(die).to receive(:roll) { 7 }
      expect(logger).to receive(:log).with('Climbing Check. Difficulty: 10, Roll: 12')
      character.climb(difficulty: 10)
    end
  end
end