# Models Tests
## Overview
* Model Responsibilities
* Test Validations
* Test Associations and Use Should-matchers gem
* Test Instance Methods
* Test DB Queries

---

### Model Responsibilities
> ActiveRecord Model
* Validations
* Associations
* DB Queries
* Business Logic

Example:
```ruby
class Achievement < ApplicationRecord
  belongs_to :user, optional: true # Association
  validates :title, presence: true # Validation
  
  enum privacy: [ :public_access, :private_access, :friends_access ]

  # Instance method
    # would be better to extract this method to a seperate class somewhere else.
  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end
end
```

---

### Testing Validations

#### Requires a title

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  
  describe 'validations' do
    it 'requires title' do
      achievement = Achievement.new(title: '')
      achievement.valid?
      expect(achievement.errors[:title]).to include("can't be blank")
    end
  end
end
```
even better:
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  
  describe 'validations' do
    it 'requires title' do
      achievement = Achievement.new(title: '')
      expect(achievement.valid?).to be_falsey
    end
  end
end
```
```
$ rspec spec/models

Achievement
  validations
    requires title

Finished in 0.0268 seconds (files took 2.11 seconds to load)
1 example, 0 failures
```

#### Requires unique titles for one user

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  
  describe 'validations' do
    it 'requires title' do
      achievement = Achievement.new(title: '')
      expect(achievement.valid?).to be_falsey
    end

    it 'requires title to be unique for one user' do
      user = FactoryGirl.create(:user)
      first_achievement = FactoryGirl.create(:public_achievement, title: 'First Achievement', user: user)
      new_achievement = Achievement.new(title: 'First Achievement', user: user)
      expect(new_achievement.valid?).to be_falsey
    end
  end
end
```
```
$ rspec

Failures:

  1) Achievement validations requires title to be unique for one user
     Failure/Error: expect(new_achievement.valid?).to be_falsey

       expected: falsey value
            got: true
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord
  belongs_to :user, optional: true

  validates :title, presence: true
  validates :title, uniqueness: true
  
  enum privacy: [ :public_access, :private_access, :friends_access ]

  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end
end
```
```
$ rspec spec/models

Achievement
  validations
    requires title
    requires title to be unique for one user

Finished in 0.07104 seconds (files took 2.1 seconds to load)
2 examples, 0 failures
```

#### Allows different users to have identical titles

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  
  describe 'validations' do
    it 'requires title' do
      achievement = Achievement.new(title: '')
      expect(achievement.valid?).to be_falsey
    end

    it 'requires title to be unique for one user' do
      user = FactoryGirl.create(:user)
      first_achievement = FactoryGirl.create(:public_achievement, title: 'First Achievement', user: user)
      new_achievement = Achievement.new(title: 'First Achievement', user: user)
      expect(new_achievement.valid?).to be_falsey
    end

    it 'allows different users to have achievements with identical titles' do
      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      first_achievement = FactoryGirl.create(:public_achievement, title: 'First Achievement', user: user1)
      new_achievement = Achievement.new(title: 'First Achievement', user: user2)
      expect(new_achievement.valid?).to be_truthy
    end
  end
end
```
```
$ rspec

Failures:

  1) Achievement validations allows different users to have achievements with identical titles
     Failure/Error: expect(new_achievement.valid?).to be_truthy

       expected: truthy value
            got: false
```

Create a custom validator.

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord
  belongs_to :user, optional: true

  validates :title, presence: true
  # validates :title, uniqueness: true
  validate :unique_title_for_one_user
  
  enum privacy: [ :public_access, :private_access, :friends_access ]

  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end

  private

  def unique_title_for_one_user
    existing_achievement = Achievement.find_by(title: title)
    if existing_achievement && existing_achievement.user == user
      errors.add(:title, "you can't have two achievements with same title")
    end
  end
end
```
```
$ rspec spec/models

Achievement
  validations
    requires title
    requires title to be unique for one user
    allows different users to have achievements with identical titles

Finished in 0.08922 seconds (files took 2.07 seconds to load)
3 examples, 0 failures
```

--- 

### Testing Associations

#### Testing that an achievement belongs to a user

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  
  describe 'validations' do

    .
    .
    .

    it 'belongs to user' do
      achievement = Achievement.new(title: 'title', user: nil)
      expect(achievement.valid?).to be_falsey
    end
  end
end
```
```
$ rspec

Failures:

  1) Achievement associations belongs to user
     Failure/Error: expect(achievement.valid?).to be_falsey

       expected: falsey value
            got: true
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord
  belongs_to :user, optional: true

  validates :title, presence: true
  validates :user, presence: true
  # validates :title, uniqueness: true
  validate :unique_title_for_one_user
  
  enum privacy: [ :public_access, :private_access, :friends_access ]

  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end

  private

  def unique_title_for_one_user
    existing_achievement = Achievement.find_by(title: title)
    if existing_achievement && existing_achievement.user == user
      errors.add(:title, "you can't have two achievements with same title")
    end
  end
end
```
```
$ rspec spec/models

Achievement
  validations
    requires title
    requires title to be unique for one user
    allows different users to have achievements with identical titles
    belongs to user

Finished in 0.08913 seconds (files took 2.07 seconds to load)
4 examples, 0 failures
```

#### Testing belongs_to user association

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  
  describe 'validations' do

    .
    .
    .

    it 'has belongs_to user association' do
      # 1st method
      user = FactoryGirl.create(:user)
      achievement = FactoryGirl.create(:public_achievement, user: user)
      expect(achievement.user).to eq(user)

      # 2nd method
      u = Achievement.reflect_on_association(:user)
      expect(u.macro).to eq(:belongs_to)
    end
  end
end
```
```
$ rspec spec/models

Achievement
  validations
    requires title
    requires title to be unique for one user
    allows different users to have achievements with identical titles
    belongs to user
    has belongs_to user association

Finished in 0.11504 seconds (files took 2.11 seconds to load)
5 examples, 0 failures
```

#### Using Should-matchers Gem
> https://github.com/thoughtbot/shoulda-matchers
* in _Gemfile_ add `gem 'shoulda-matchers', require: false` to test group
* in iTerm `$ bundle`
* include `require 'shoulda/matchers'` in _/spec/rails_helper_ after `require 'rspec/rails'`
```ruby
require 'shoulda/matchers'
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
```

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  
  describe 'validations' do
    .
    .
    .
  end

  it { should belong_to(:user) }  
end
```
```
$ spec spec/models

Achievement
  should belong to user
  validations
    requires title
    requires title to be unique for one user
    allows different users to have achievements with identical titles
    belongs to user

Finished in 0.08602 seconds (files took 1.99 seconds to load)
5 examples, 0 failures
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord
  belongs_to :user, optional: true

  validates :title, presence: true
  validates :user, presence: true
  validates :title, uniqueness: {
    scope: :user_id,
    message: "you can't have two achievements with same title"
  }
  
  enum privacy: [ :public_access, :private_access, :friends_access ]

  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end
end
```

#### Refactor with Shoulda-matchers

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do
  
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title).scoped_to(:user_id).with_message("you can't have two achievements with same title") }
    it { should validate_presence_of(:user) }
  end

  it { should belong_to(:user) }  
end
```
```
$  rspec spec/models

Achievement
  should belong to user
  validations
    should validate that :title cannot be empty/falsy
    should validate that :title is case-sensitively unique within the scope of :user_id, producing a custom validation error on failure
    should validate that :user cannot be empty/falsy

Finished in 0.06793 seconds (files took 1.96 seconds to load)
4 examples, 0 failures
```

--- 

### Testing Instance Methods

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do

  .
  .
  .

  describe 'instance methods' do
    it 'converts markdown to HTML' do
      achievement = Achievement.new(description: 'Awesome **thing** I *actually* did')
      expect(achievement.description_html).to include('<strong>thing</strong>')
      expect(achievement.description_html).to include('<em>actually</em>')
    end
  end
end
```
```
$ rspec spec/models

Achievement
  associations
    should belong to user
  validations
    should validate that :title cannot be empty/falsy
    should validate that :title is case-sensitively unique within the scope of :user_id, producing a custom validation error on failure
    should validate that :user cannot be empty/falsy
  instance methods
    converts markdown to HTML

Finished in 0.06517 seconds (files took 1.98 seconds to load)
5 examples, 0 failures
```

#### Concat a silly title

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do

  .
  .
  .

  describe 'instance methods' do
    .
    .
    .

    it "has a silly title concatenated with user's email" do
      achievement = Achievement.new(title: 'New Achievement', user: FactoryGirl.create(:user, email: 'foo@bar.com'))
      expect(achievement.silly_achievement).to eq('New Achievement by foo@bar.com')
    end
  end
end
```
```
$ rspec

Failures:

  1) Achievement instance methods has a silly title concatenated with user's email
     Failure/Error: expect(achievement.silly_achievement).to eq('New Achievement by foo@bar.com')

     NoMethodError:
       undefined method `silly_achievement' for #<Achievement:0x007fd339d98398>
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord

  .
  .
  .

  def silly_achievement
  end
end
```
```
$ rspec

Failures:

  1) Achievement instance methods has a silly title concatenated with user's email
     Failure/Error: expect(achievement.silly_achievement).to eq('New Achievement by foo@bar.com')

       expected: "New Achievement by foo@bar.com"
            got: nil

       (compared using ==)
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord

  .
  .
  .

  def silly_achievement
    "#{title} by #{user.email}"
  end
end
```
```
$ rspec spec/models

Achievement
  associations
    should belong to user
  validations
    should validate that :title cannot be empty/falsy
    should validate that :title is case-sensitively unique within the scope of :user_id, producing a custom validation error on failure
    should validate that :user cannot be empty/falsy
  instance methods
    converts markdown to HTML
    has a silly title concatenated with user's email

Finished in 0.09297 seconds (files took 1.98 seconds to load)
6 examples, 0 failures
```

---

### Testing DB Queries

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do

  .
  .
  .

  describe 'DB queries' do
    it 'can filter titles by letter' do
      user = FactoryGirl.create(:user)
      achievement1 = FactoryGirl.create(:public_achievement, title: 'Read a book', user: user)
      achievement2 = FactoryGirl.create(:public_achievement, title: 'Passed an exam', user: user)
      expect(Achievement.by_letter('R')).to eq([achievement1])
    end
  end
end
```
```
$ rspec

Failures:

  1) Achievement DB queries can filter titles by letter
     Failure/Error: expect(Achievement.by_letter('R')).to eq([achievement])

     NoMethodError:
       undefined method `by_letter' for #<Class:0x007fef18ef9520>
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord

  .
  .
  .

  def self.by_letter(letter)
    
  end
end
```
```
$ rspec

  1) Achievement DB queries can filter titles by letter
     Failure/Error: expect(Achievement.by_letter('R')).to eq([achievement1])

       expected: [#<Achievement id: 1, title: "Read a book", description: "description", privacy: "public_access", fea..."some_image.png", created_at: "2017-02-14 21:02:34", updated_at: "2017-02-14 21:02:34", user_id: 1>]
            got: nil

       (compared using ==)
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord
  
  .
  .
  .

  def self.by_letter(letter)
    where('title LIKE ?', "#{letter}%")
  end
end
```
```
$ rspec spec/models

Achievement
  associations
    should belong to user
  validations
    should validate that :title cannot be empty/falsy
    should validate that :title is case-sensitively unique within the scope of :user_id, producing a custom validation error on failure
    should validate that :user cannot be empty/falsy
  instance methods
    converts markdown to HTML
    has a silly title concatenated with user's email
  DB queries
    can filter titles by letter

Finished in 0.10945 seconds (files took 2.03 seconds to load)
7 examples, 0 failures
```

_/spec/models/achievement_spec.rb_
```ruby
require 'rails_helper'

RSpec.describe Achievement, type: :model do

  .
  .
  .

  describe 'DB queries' do

    .
    .
    .

    it 'sorts achievements by user emails' do
      dutch = FactoryGirl.create(:user, email: 'dutch@example.com')
      maverick = FactoryGirl.create(:user, email: 'maverick@example.com')
      achievement1 = FactoryGirl.create(:public_achievement, title: "Didn't bite anyone", user: maverick)
      achievement2 = FactoryGirl.create(:public_achievement,title: "Didn't bark", user: dutch)
      expect(Achievement.by_letter('D')).to eq([achievement2, achievement1])
    end
  end
end
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord

  .
  .
  .

  def self.by_letter(letter)
    includes(:user).where('title LIKE ?', "#{letter}%").order('users.email')
  end
end
```
```
$ rspec spec/models

Achievement
  associations
    should belong to user
  validations
    should validate that :title cannot be empty/falsy
    should validate that :title is case-sensitively unique within the scope of :user_id, producing a custom validation error on failure
    should validate that :user cannot be empty/falsy
  instance methods
    converts markdown to HTML
    has a silly title concatenated with user's email
  DB queries
    can filter titles by letter
    sorts achievements by user emails

Finished in 0.14182 seconds (files took 1.98 seconds to load)
8 examples, 0 failures
```