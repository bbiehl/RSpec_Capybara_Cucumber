# Testing in Isolation
## Overview
* Dependency Injection, Stubs, and Mocks
* non-Rails example
* Testing a Controller in Isolation

---

### Dependency Injection, Stubs, and Mocks
> Dependency Injection: replacing real objects with fake objects for the purpose of testing.

---

### non-Rails example

We'll start in an empty folder `mocks-and-stubs-example` and create a new _Gemfile_

```
$ mkdir mocks-and-stubs-example
$ mocks-and-stubs-example/
$ touch Gemfile
```

_Gemfile_
```ruby
source 'http://rubygems.org'

gem 'rspec'
```
```
$ bundle
Fetching gem metadata from http://rubygems.org/..........
Fetching version metadata from http://rubygems.org/.
Resolving dependencies...
Using diff-lcs 1.3
Using rspec-support 3.5.0
Using bundler 1.13.7
Using rspec-core 3.5.4
Using rspec-expectations 3.5.0
Using rspec-mocks 3.5.0
Using rspec 3.5.0
Bundle complete! 1 Gemfile dependency, 7 gems now installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.
```

Create _game.rb_
```
$ touch game.rb
```

#### Stubs example

_game.rb_
```ruby
class Character
end

describe Character do
  describe 'climbing check skill' do
    it 'succeeds when (roll + strength) > climb difficulty'

    it 'fails when (roll + strength) < climb difficulty'
  end
end
```
```
$ spec game.rb
**

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) Character climbing check skill succeeds when (roll + strength) > climb difficulty
     # Not yet implemented
     # ./game.rb:6

  2) Character climbing check skill fails when (roll + strength) < climb difficulty
     # Not yet implemented
     # ./game.rb:8

Finished in 0.00059 seconds (files took 0.07696 seconds to load)
2 examples, 0 failures, 2 pending
```

_game.rb_
```ruby
class Character
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:character) { Character.new(strength: 5, die: die) }
    
    it 'succeeds when (roll + strength) > climb difficulty' do
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    # it 'fails when (roll + strength) < climb difficulty'
  end
end
```
```
$ rspec

Failures:

  1) Character climbing check skill succeeds when (roll + strength) > climb difficulty
     Failure/Error: let(:character) { Character.new(strength: 5, die: die) }

     ArgumentError:
       wrong number of arguments (given 1, expected 0)
```

_game.rb_
```ruby
class Character
  def initialize(strength: 1, die: Die.new)
    @strength = strength
    @die = die
  end
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:character) { Character.new(strength: 5, die: die) }
    
    it 'succeeds when (roll + strength) > climb difficulty' do
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    # it 'fails when (roll + strength) < climb difficulty'
  end
end
```
```
$ rspec
Failures:

  1) Character climbing check skill succeeds when (roll + strength) > climb difficulty
     Failure/Error: expect(character.climb(difficulty: 15)).to be_truthy

     NoMethodError:
       undefined method `climb' for #<Character:0x007fa1aa2284d8>
```

_game.rb_
```ruby
class Character
  def initialize(strength: 1, die: Die.new)
    @strength = strength
    @die = die
  end

  def climb
  end
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:character) { Character.new(strength: 5, die: die) }

    it 'succeeds when (roll + strength) > climb difficulty' do
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    # it 'fails when (roll + strength) < climb difficulty'
  end
end
```
```
$ rspec

Failures:

  1) Character climbing check skill succeeds when (roll + strength) > climb difficulty
     Failure/Error:
       def climb
         # die.roll + strength >= difficulty
       end

     ArgumentError:
       wrong number of arguments (given 1, expected 0)
```

_game.rb_
```ruby
class Character
  def initialize(strength: 1, die: Die.new)
    @strength = strength
    @die = die
  end

  def climb(difficulty: 10)
  end
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:character) { Character.new(strength: 5, die: die) }

    it 'succeeds when (roll + strength) > climb difficulty' do
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    # it 'fails when (roll + strength) < climb difficulty'
  end
end
```
```
$ rspec

Failures:

  1) Character climbing check skill succeeds when (roll + strength) > climb difficulty
     Failure/Error: expect(character.climb(difficulty: 15)).to be_truthy

       expected: truthy value
            got: nil
```

_game.rb_
```ruby
class Character
  def initialize(strength: 1, die: Die.new)
    @strength = strength
    @die = die
  end

  def climb(difficulty: 10)
    die.roll + strength >= difficulty
  end

  private

  attr_reader :die, :strength
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:character) { Character.new(strength: 5, die: die) }

    it 'succeeds when (roll + strength) > climb difficulty' do
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    # it 'fails when (roll + strength) < climb difficulty'
  end
end
```
```
$ rspec

Failures:

  1) Character climbing check skill succeeds when (roll + strength) > climb difficulty
     Failure/Error: die.roll + strength >= difficulty
       #<Double (anonymous)> received unexpected message :roll with (no args)
```

_game.rb_
```ruby
class Character
  def initialize(strength: 1, die: Die.new)
    @strength = strength
    @die = die
  end

  def climb(difficulty: 10)
    die.roll + strength >= difficulty
  end

  private

  attr_reader :die, :strength
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:character) { Character.new(strength: 5, die: die) }

    it 'succeeds when (roll + strength) > climb difficulty' do
      allow(die).to receive(:roll) { 11 }
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    # it 'fails when (roll + strength) < climb difficulty'
  end
end
```
```
$ rspec game.rb --color --format doc

Character
  climbing check skill
    succeeds when (roll + strength) > climb difficulty

Finished in 0.01321 seconds (files took 0.08973 seconds to load)
1 example, 0 failures
```

_game.rb_
```ruby
class Character
  def initialize(strength: 1, die: Die.new)
    @strength = strength
    @die = die
  end

  def climb(difficulty: 10)
    die.roll + strength >= difficulty
  end

  private

  attr_reader :die, :strength
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:character) { Character.new(strength: 5, die: die) }

    it 'succeeds when (roll + strength) > climb difficulty' do
      allow(die).to receive(:roll) { 11 }
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    it 'fails when (roll + strength) < climb difficulty' do
      allow(die).to receive(:roll) { 9 }
      expect(character.climb(difficulty: 15)).to be_falsy
    end
  end
end
```
```
$ rspec game.rb --color --format doc

Character
  climbing check skill
    succeeds when (roll + strength) > climb difficulty
    fails when (roll + strength) < climb difficulty

Finished in 0.00792 seconds (files took 0.08309 seconds to load)
2 examples, 0 failures
```

#### Mocks example

_game.rb_
```ruby
class Character
  def initialize(strength: 1, die: Die.new, logger: Logger.new)
    @strength = strength
    @die = die
    @logger = logger
  end

  .
  .
  .

  private

  attr_reader :die, :strength, :logger
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:logger) { double }
    let(:character) { Character.new(strength: 5, die: die, logger: logger) }

    .
    .
    .

    it 'commands logger to log climb skill check' do
      allow(die).to receive(:roll) { 7 }
      expect(logger).to receive(:log).with('Climbing Check. Difficulty: 10, Roll: 12')
      character.climb(difficulty: 10)
    end
  end
end
```
```
$ rspec

Failures:

  1) Character climbing check skill commands logger to log climb skill check
     Failure/Error: expect(logger).to receive(:log).with('Climbing Check. Difficulty: 10, Roll: 12')

       (Double (anonymous)).log("Climbing Check. Difficulty: 10, Roll: 12")
           expected: 1 time with arguments: ("Climbing Check. Difficulty: 10, Roll: 12")
           received: 0 times
```

_game.rb_
```ruby
class Character
  def initialize(strength: 1, die: Die.new, logger: Logger.new)
    @strength = strength
    @die = die
    @logger = logger
  end

  def climb(difficulty: 10)
    roll = die.roll
    logger.log("Climbing Check. Difficulty: #{difficulty}, Roll: #{roll}")
    roll >= difficulty
  end

  private

  attr_reader :die, :strength, :logger
end

describe Character do
  describe 'climbing check skill' do
    let(:die) { double }
    let(:logger) { double }
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
      expect(logger).to receive(:log).with('Climbing Check. Difficulty: 10, Roll: 7')
      character.climb(difficulty: 10)
    end
  end
end
```
New spec works, but old specs fail.
```
$ 
Character
  climbing check skill
    succeeds when (roll + strength) > climb difficulty (FAILED - 1)
    fails when (roll + strength) < climb difficulty (FAILED - 2)
    commands logger to log climb skill check

Failures:

  1) Character climbing check skill succeeds when (roll + strength) > climb difficulty
     Failure/Error: logger.log("Climbing Check. Difficulty: #{difficulty}, Roll: #{roll}")
       #<Double (anonymous)> received unexpected message :log with ("Climbing Check. Difficulty: 15, Roll: 11")
     # ./game.rb:10:in `climb'
     # ./game.rb:27:in `block (3 levels) in <top (required)>'

  2) Character climbing check skill fails when (roll + strength) < climb difficulty
     Failure/Error: logger.log("Climbing Check. Difficulty: #{difficulty}, Roll: #{roll}")
       #<Double (anonymous)> received unexpected message :log with ("Climbing Check. Difficulty: 15, Roll: 9")
     # ./game.rb:10:in `climb'
     # ./game.rb:32:in `block (3 levels) in <top (required)>'

Finished in 0.00755 seconds (files took 0.07987 seconds to load)
3 examples, 2 failures
```

_game.rb_
```ruby
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
    let(:logger) { double }
    let(:character) { Character.new(strength: 5, die: die, logger: logger) }

    it 'succeeds when (roll + strength) > climb difficulty' do
      allow(die).to receive(:roll) { 11 }
      allow(logger).to receive(:log)
      expect(character.climb(difficulty: 15)).to be_truthy
    end

    it 'fails when (roll + strength) < climb difficulty' do
      allow(die).to receive(:roll) { 9 }
      allow(logger).to receive(:log)
      expect(character.climb(difficulty: 15)).to be_falsy
    end

    it 'commands logger to log climb skill check' do
      allow(die).to receive(:roll) { 7 }
      expect(logger).to receive(:log).with('Climbing Check. Difficulty: 10, Roll: 12')
      character.climb(difficulty: 10)
    end
  end
end
```
```
$ rspec game.rb --color --format doc

Character
  climbing check skill
    succeeds when (roll + strength) > climb difficulty
    fails when (roll + strength) < climb difficulty
    commands logger to log climb skill check

Finished in 0.01007 seconds (files took 0.08458 seconds to load)
3 examples, 0 failures
```

#### Refactor

_game.rb_
```ruby
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
    let(:logger) { double }
    let(:character) { Character.new(strength: 5, die: die, logger: logger) }

    before do
      allow(logger).to receive(:log)
    end

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
```

or 

_game.rb_
```ruby
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
```
```
$ rspec game.rb --color --format doc

Character
  climbing check skill
    succeeds when (roll + strength) > climb difficulty
    fails when (roll + strength) < climb difficulty
    commands logger to log climb skill check

Finished in 0.00851 seconds (files took 0.08184 seconds to load)
3 examples, 0 failures
```



















---

### Testing a Controller in Isolation (Part 1)

---

### Testing a Controller in Isolation (Part 2)