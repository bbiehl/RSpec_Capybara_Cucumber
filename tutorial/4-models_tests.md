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

--- 

### Testing Instance Methods

---

### Testing DB Queries