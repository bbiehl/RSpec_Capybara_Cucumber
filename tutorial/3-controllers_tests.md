# Controllers Tests
## Overview
* Controller's resposibilities
* Test 7 standard actions
* Deal with authentication and authorization

---

### Controllers responsibilities
> What do we need to test?

#### What does a Controller do?
* Authenticate and Authorize requests
* Handle Models
* Create response
  * Render template
  * Respond with required format and headers (i.e. JSON)
  * Redirect to another route

---

### Test New and Show actions

#### Test New action
Create folder:
```
$ mkdir spec/controllers
```

Create file:

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  describe 'GET new' do
    it 'renders :new template' do
      get :new
      expect(response).to render_template(:new)
    end
    
    it 'assigns new Achievement to @achievement'
  end
end
```
```
$ rspec

Failures:

  1) AchievementsController GET new renders :new template
     Failure/Error: expect(response).to render_template(:new)

     NoMethodError:
       assert_template has been extracted to a gem. To continue using it,
               add `gem 'rails-controller-testing'` to your Gemfile.
```

_Gemfile_ (what it looks likd so far)
```ruby
source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.0.1'
gem 'sqlite3'
gem 'puma', '~> 3.0'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.2'
gem 'jquery-rails'
gem 'turbolinks', '~> 5'
gem 'jbuilder', '~> 2.5'
gem 'bootstrap-sass'
gem 'simple_form'
gem 'redcarpet'

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'capybara'
  gem 'cucumber-rails', require: false
  gem 'database_cleaner'
  gem 'rails-controller-testing'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-commands-cucumber'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
```
```
$ bundle
.
.
.
Installing rails-controller-testing 1.0.1
Bundle complete! 26 Gemfile dependencies, 88 gems now installed.
Use `bundle show [gemname]` to see where a bundled gem is installed.
```
```
$ rspec

AchievementsController
  GET new
    renders :new template
    assigns new Achievement to @achievement (PENDING: Not yet implemented)

Achievement Page
  Achievement Public Page
  Render Markdown Description

create new achievement
  create new achievement with valid data
  cannot create new achievement with invalid data

home page
  welcome message

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) AchievementsController GET new assigns new Achievement to @achievement
     # Not yet implemented
     # ./spec/controllers/achievements_controller_spec.rb:10


Finished in 0.45526 seconds (files took 1.79 seconds to load)
7 examples, 0 failures, 1 pending
```

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  describe 'GET new' do
    it 'renders :new template' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'assigns new Achievement to @achievement' do
      get :new
      expect(assigns(:achievement)).to be_a_new(Achievement) 
    end
  end
end
```
```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  GET new
    renders :new template
    assigns new Achievement to @achievement

Finished in 0.0266 seconds (files took 1.79 seconds to load)
2 examples, 0 failures
```

#### Test Show action
_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  describe 'GET new' do
    it 'renders :new template' do
      get :new
      expect(response).to render_template(:new)
    end

    it 'assigns new Achievement to @achievement' do
      get :new
      expect(assigns(:achievement)).to be_a_new(Achievement) 
    end
  end

  describe 'Get show' do
    let(:achievement) { FactoryGirl.create(:public_achievement) }
    it 'renders :show template' do
      get :show, params: { id: achievement }
      expect(response).to render_template(:show)
    end

    it 'assigns requested achievement to @achievement' do
      get :show, params: { id: achievement }
      expect(assigns(:achievement)).to eq(achievement)
    end
  end
end
```
```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  GET new
    renders :new template
    assigns new Achievement to @achievement
  Get show
    renders :show template
    assigns requested achievement to @achievement

Finished in 0.05513 seconds (files took 1.84 seconds to load)
4 examples, 0 failures
```

#### Refactor

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  def new
    @achievement = Achievement.new
  end

  def create
    @achievement = Achievement.new(achievement_params)
    if @achievement.save
      redirect_to root_url, notice: 'Achievement has been created'
    else
      render :new
    end
  end

  def show
    @achievement = Achievement.find(params[:id])
  end

  private

  def achievement_params
    params.require(:achievement).permit(:title, :description, :privacy, :cover_image, :featured)
  end
end
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord
  validates :title, presence: true
  
  enum privacy: [ :public_access, :private_access, :friends_access ]

  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end
end
```

_/app/views/achievements/show.html.erb_
```ruby
<h1><%= @achievement.title %></h1>
<div><%= @achievement.description_html.html_safe %></div>
```

Check all specs to make sure we haven't regressed.

```
$ rspec

AchievementsController
  GET new
    renders :new template
    assigns new Achievement to @achievement
  Get show
    renders :show template
    assigns requested achievement to @achievement

Achievement Page
  Achievement Public Page
  Render Markdown Description

create new achievement
  create new achievement with valid data
  cannot create new achievement with invalid data

home page
  welcome message

Finished in 0.49806 seconds (files took 1.82 seconds to load)
9 examples, 0 failures
```
---

### Test Create action

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'POST create' do
    it 'redirects to achievements#show' do
      post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement) }
      expect(response).to redirect_to(achievement_path(assigns[:achievement]))
    end

    it 'creates new achievement in the database'
  end
end
```
```
$ rspec

Failures:

  1) AchievementsController POST create redirects to achievements#show
     Failure/Error: @achievement = Achievement.new(achievement_params)

     ArgumentError:
       '0' is not a valid privacy
```

_/spec/factories/achievements.rb_
```ruby
FactoryGirl.define do
  factory :achievement do
    sequence(:title) { |n| "Achievement #{n}"}
    description "description"
    featured false
    cover_image "some_image.png"

    factory :public_achievement do
      privacy :public_access
    end

    factory :private_achievement do
      privacy :private_access
    end
  end
end
```
```
$ rspec

Failures:

  1) AchievementsController POST create redirects to achievements#show
     Failure/Error: expect(response).to redirect_to(achievement_path(assigns[:achievement]))

       Expected response to be a redirect to <http://test.host/achievements/1> but was a redirect to <http://test.host/>.
       Expected "http://test.host/achievements/1" to be === "http://test.host/".
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def create
    @achievement = Achievement.new(achievement_params)
    if @achievement.save
      # redirect_to root_url, notice: 'Achievement has been created'
      redirect_to achievement_url(@achievement), notice: 'Achievement has been created'
    else
      render :new
    end
  end

  .
  .
  .
end
```
```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  GET new
    renders :new template
    assigns new Achievement to @achievement
  GET show
    renders :show template
    assigns requested achievement to @achievement
  POST create
    redirects to achievements#show
    creates new achievement in the database (PENDING: Not yet implemented)

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) AchievementsController POST create creates new achievement in the database
     # Not yet implemented
     # ./spec/controllers/achievements_controller_spec.rb:34


Finished in 0.06642 seconds (files took 1.81 seconds to load)
6 examples, 0 failures, 1 pending
```

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'POST create' do
    it 'redirects to achievements#show' do
      post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement) }
      expect(response).to redirect_to(achievement_path(assigns[:achievement]))
    end

    it 'creates new achievement in the database' do
      expect {
        post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement) }
      }.to change(Achievement, :count).by(1)
    end
  end
end
```
```
$ rspec

AchievementsController
  GET new
    renders :new template
    assigns new Achievement to @achievement
  GET show
    renders :show template
    assigns requested achievement to @achievement
  POST create
    redirects to achievements#show
    creates new achievement in the database

Achievement Page
  Achievement Public Page
  Render Markdown Description

create new achievement
  create new achievement with valid data
  cannot create new achievement with invalid data

home page
  welcome message

Finished in 0.49748 seconds (files took 1.81 seconds to load)
11 examples, 0 failures
```

#### Testing against invalid data in a POST request


_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'POST create' do
    context 'valid data' do
      it 'redirects to achievements#show' do
        post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement) }
        expect(response).to redirect_to(achievement_path(assigns[:achievement]))
      end

      it 'creates new achievement in the database' do
        expect {
          post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement) }
        }.to change(Achievement, :count).by(1)
      end
    end

    context 'invalid data' do
      it 'renders :new template' do
        post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement, title: '') }
        expect(response).to render_template(:new)
      end

      it 'does not create a new achievement in the database' do
        expect {
          post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement, title: '') }
        }.to_not change(Achievement, :count)
      end
      
    end
  end
end
```
```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  GET new
    renders :new template
    assigns new Achievement to @achievement
  GET show
    renders :show template
    assigns requested achievement to @achievement
  POST create
    valid data
      redirects to achievements#show
      creates new achievement in the database
    invalid data
      renders :new template
      does not create a new achievement in the database

Finished in 0.09109 seconds (files took 1.8 seconds to load)
8 examples, 0 failures
```

#### Refactor

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'POST create' do
    context 'valid data' do
      let(:valid_data) { FactoryGirl.attributes_for(:public_achievement) }
      
      it 'redirects to achievements#show' do
        post :create, params: { achievement: valid_data }
        expect(response).to redirect_to(achievement_path(assigns[:achievement]))
      end

      it 'creates new achievement in the database' do
        expect {
          post :create, params: { achievement: valid_data }
        }.to change(Achievement, :count).by(1)
      end
    end

    context 'invalid data' do
      let(:invalid_data) { FactoryGirl.attributes_for(:public_achievement, title: '') }

      it 'renders :new template' do
        post :create, params: { achievement: invalid_data }
        expect(response).to render_template(:new)
      end

      it 'does not create a new achievement in the database' do
        expect {
          post :create, params: { achievement: invalid_data }
        }.to_not change(Achievement, :count)
      end
      
    end
  end
end
```
```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  GET new
    renders :new template
    assigns new Achievement to @achievement
  GET show
    renders :show template
    assigns requested achievement to @achievement
  POST create
    valid data
      redirects to achievements#show
      creates new achievement in the database
    invalid data
      renders :new template
      does not create a new achievement in the database

Finished in 0.08879 seconds (files took 1.82 seconds to load)
8 examples, 0 failures
```
---

### Test Index and Edit actions

---

### Install and setup Devise gem

---

### Test Authentication

---

### Test Authorization