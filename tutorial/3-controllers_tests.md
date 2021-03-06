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

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  describe 'GET index' do
    it 'renders :index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns only public achievements to the template'
  end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController GET index renders :index template
     Failure/Error: get :index

     ActionController::UrlGenerationError:
       No route matches {:action=>"index", :controller=>"achievements"}
```

_/config/routes_
```ruby
Rails.application.routes.draw do
  resources :achievements
  root to: 'welcome#index'
end
```
``` 
$ rspec

Failures:

  1) AchievementsController GET index renders :index template
     Failure/Error: get :index

     AbstractController::ActionNotFound:
       The action 'index' could not be found for AchievementsController
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  def index
  end

  .
  .
  .
end
```

And create File: _/app/views/achievements/index.html.erb_

```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  GET index
    renders :index template
    assigns only public achievements to the template (PENDING: Not yet implemented)
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

Pending: (Failures listed here are expected and do not affect your suite's status)

  1) AchievementsController GET index assigns only public achievements to the template
     # Not yet implemented
     # ./spec/controllers/achievements_controller_spec.rb:11


Finished in 0.09384 seconds (files took 1.83 seconds to load)
10 examples, 0 failures, 1 pending
```

_/spec/controllers/achievements_controller_spec.rb_
```ruby

describe AchievementsController do
  describe 'GET index' do
    it 'renders :index template' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'assigns only public achievements to the template' do
      public_achievement = FactoryGirl.create(:public_achievement)
      private_achievement = FactoryGirl.create(:private_achievement)
      get :index
      expect(assigns(:achievements)).to match_array([public_achievement])
    end
  end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController GET index assigns only public achievements to the template
     Failure/Error: expect(assigns(:achievements)).to match_array([public_achievement])
       expected a collection that can be converted to an array with `#to_ary` or `#to_a`, but got nil
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  def index
    @achievements = Achievement.all
  end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController GET index assigns only public achievements to the template
     Failure/Error: expect(assigns(:achievements)).to match_array([public_achievement])

       expected collection contained:  [#<Achievement id: 1, title: "Achievement 1", description: "description", privacy: "public_access", f...over_image: "some_image.png", created_at: "2017-02-09 21:36:28", updated_at: "2017-02-09 21:36:28">]
       actual collection contained:    [#<Achievement id: 1, title: "Achievement 1", description: "description", privacy: "public_access", f...over_image: "some_image.png", created_at: "2017-02-09 21:36:28", updated_at: "2017-02-09 21:36:28">]
       the extra elements were:        [#<Achievement id: 2, title: "Achievement 2", description: "description", privacy: "private_access", ...over_image: "some_image.png", created_at: "2017-02-09 21:36:28", updated_at: "2017-02-09 21:36:28">]
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  def index
    @achievements = Achievement.public_access
  end

  .
  .
  .
end
```
```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  GET index
    renders :index template
    assigns only public achievements to the template
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

Finished in 0.11069 seconds (files took 1.8 seconds to load)
10 examples, 0 failures
```

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'GET edit' do
    let(:achievement) { FactoryGirl.create(:public_achievement) }

    it 'renders :edit template' do
      get :edit, params: { id: achievement }
      expect(response).to render_template(:edit)
    end

    it 'assigns the requested achievement to the template'
  end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController GET edit renders :edit template
     Failure/Error: get :edit, params: { id: achievement }

     AbstractController::ActionNotFound:
       The action 'edit' could not be found for AchievementsController
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def edit
  end

  .
  .
  .
end
```

And, create new file: _/app/views/achievements/edit.html.erb_

```
$ rspec

12 examples, 0 failures, 1 pending
```

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'GET edit' do
    let(:achievement) { FactoryGirl.create(:public_achievement) }

    it 'renders :edit template' do
      get :edit, params: { id: achievement }
      expect(response).to render_template(:edit)
    end

    it 'assigns the requested achievement to the template' do
      get :edit, params: { id: achievement }
      expect(assigns(:achievement)).to eq(achievement)
    end
  end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController GET edit assigns the requested achievement to the template
     Failure/Error: expect(assigns(:achievement)).to eq(achievement)

       expected: #<Achievement id: 1, title: "Achievement 4", description: "description", privacy: "public_access", fe...cover_image: "some_image.png", created_at: "2017-02-09 21:51:37", updated_at: "2017-02-09 21:51:37">
            got: nil

       (compared using ==)
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def edit
    @achievement = Achievement.find(params[:id])
  end

  .
  .
  .
end
```
```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  GET index
    renders :index template
    assigns only public achievements to the template
  GET edit
    renders :edit template
    assigns the requested achievement to the template
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

Finished in 0.13 seconds (files took 1.85 seconds to load)
12 examples, 0 failures
```

---

### Test Update and Destroy actions
#### Test Update action

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'PUT update' do
    let(:achievement) { FactoryGirl.create(:public_achievement) }

    context 'valid data' do
      let(:valid_data) { FactoryGirl.attributes_for(:public_achievement, title: 'New Title') }
      
      it 'redirects to achievements#show' do
        put :update, params: { id: achievement, achievement: valid_data }
        expect(reponse).to redirect_to(achievement)
      end

      it 'updates the achievement in the database'
    end

    context 'invalid data' do
      
    end
  end
end
```
```
$ rspec

Failures:

  1) AchievementsController PUT update valid data redirects to achievements#show
     Failure/Error: put :update, params: { id: achievement, achievement: valid_data }

     AbstractController::ActionNotFound:
       The action 'update' could not be found for AchievementsController
```

_/app/controllers/achievements_controller.rb_ (after `def edit`)
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def update
    
  end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController PUT update valid data redirects to achievements#show
     Failure/Error: expect(response).to redirect_to(achievement)
       Expected response to be a <3XX: redirect>, but was a <204: No Content>
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def update
    render nothing: true
  end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController PUT update valid data redirects to achievements#show
     Failure/Error: expect(response).to redirect_to(achievement)
       Expected response to be a <3XX: redirect>, but was a <200: OK>
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def update
    @achievement = Achievement.find(params[:id])
    redirect_to achievement_path(@achievement)
  end

  .
  .
  .
end
```
```
$ rspec

Finished in 0.1226 seconds (files took 1.84 seconds to load)
14 examples, 0 failures, 1 pending
```

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'PUT update' do
    let(:achievement) { FactoryGirl.create(:public_achievement) }

    context 'valid data' do
      let(:valid_data) { FactoryGirl.attributes_for(:public_achievement, title: 'New Title') }
      
      it 'redirects to achievements#show' do
        put :update, params: { id: achievement, achievement: valid_data }
        expect(response).to redirect_to(achievement)
      end

      it 'updates the achievement in the database' do
        put :update, params: { id: achievement, achievement: valid_data }
        achievement.reload
        expect(achievement.title).to eq('New Title')
      end
    end

    context 'invalid data' do
      
    end
  end
end
```
```
$ rspec

Failures:

  1) AchievementsController PUT update valid data updates the achievement in the database
     Failure/Error: expect(achievement.title).to eq('New Title')

       expected: "New Title"
            got: "Achievement 6"

       (compared using ==)
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def update
    @achievement = Achievement.find(params[:id])
    if @achievement.update_attributes(achievement_params)
      redirect_to achievement_path(@achievement)
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
  GET index
    renders :index template
    assigns only public achievements to the template
  GET edit
    renders :edit template
    assigns the requested achievement to the template
  PUT update
    valid data
      redirects to achievements#show
      updates the achievement in the database
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

Finished in 0.14568 seconds (files took 1.86 seconds to load)
14 examples, 0 failures
```

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'PUT update' do
    let(:achievement) { FactoryGirl.create(:public_achievement) }

    .
    .
    .

    context 'invalid data' do
      let(:invalid_data) { FactoryGirl.attributes_for(:public_achievement, title: '', description: 'new description') }

      it 'renders :edit template' do
        put :update, params: { id: achievement, achievement: invalid_data }
        expect(response).to render_template(:edit)
      end

      it 'does not update the achievement in the database'
    end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController PUT update invalid data renders :edit template
     Failure/Error: expect(response).to render_template(:edit)
       expecting <"edit"> but rendering with <[]>
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def update
    @achievement = Achievement.find(params[:id])
    if @achievement.update_attributes(achievement_params)
      redirect_to achievement_path(@achievement)
    else
      render :edit
    end
  end

  .
  .
  .
end
```
```
$ rspec

Finished in 0.16105 seconds (files took 1.85 seconds to load)
16 examples, 0 failures, 1 pending
```

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'PUT update' do
    let(:achievement) { FactoryGirl.create(:public_achievement) }

    .
    .
    .

    context 'invalid data' do
      let(:invalid_data) { FactoryGirl.attributes_for(:public_achievement, title: '', description: 'new description') }

      it 'renders :edit template' do
        put :update, params: { id: achievement, achievement: invalid_data }
        expect(response).to render_template(:edit)
      end

      it 'does not update the achievement in the database' do
        put :update, params: { id: achievement, achievement: invalid_data }
        achievement.reload
        expect(achievement.description).to_not eq('new description')
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
  GET index
    renders :index template
    assigns only public achievements to the template
  GET edit
    renders :edit template
    assigns the requested achievement to the template
  PUT update
    valid data
      redirects to achievements#show
      updates the achievement in the database
    invalid data
      renders :edit template
      does not update the achievement in the database
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

Finished in 0.16546 seconds (files took 1.85 seconds to load)
16 examples, 0 failures
```

#### Test Destroy action

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'DELETE destroy' do
    let(:achievement) { FactoryGirl.create(:public_achievement) }

    it 'redirects to achievements#index' do
      delete :destroy, params: { id: achievement }
      expect(response).to redirect_to(achievements_path)  
    end

    it 'deletes the achievement from the database'
  end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController DELETE destroy redirects to achievements#index
     Failure/Error: delete :destroy, id: achievement

     AbstractController::ActionNotFound:
       The action 'destroy' could not be found for AchievementsController
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def destroy
    redirect_to achievements_path
  end

  .
  .
  .
end
```
```
$ rspec

Finished in 0.1875 seconds (files took 1.89 seconds to load)
18 examples, 0 failures, 1 pending
```

_/spec/controllers/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do
  .
  .
  .

  describe 'DELETE destroy' do
    let(:achievement) { FactoryGirl.create(:public_achievement) }

    it 'redirects to achievements#index' do
      delete :destroy, params: { id: achievement }
      expect(response).to redirect_to(achievements_path)  
    end

    it 'deletes the achievement from the database' do
      delete :destroy, params: { id: achievement }
      expect(Achievement.exists?(achievement.id)).to be_falsey
    end
  end

  .
  .
  .
end
```
```
$ rspec

Failures:

  1) AchievementsController DELETE destroy deletes the achievement from the database
     Failure/Error: expect(Achievement.exists?(achievement.id)).to be_falsy

       expected: falsey value
            got: true
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  .
  .
  .

  def destroy
    Achievement.destroy(params[:id])
    redirect_to achievements_path
  end

  .
  .
  .
end
```
```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  GET index
    renders :index template
    assigns only public achievements to the template
  GET edit
    renders :edit template
    assigns the requested achievement to the template
  PUT update
    valid data
      redirects to achievements#show
      updates the achievement in the database
    invalid data
      renders :edit template
      does not update the achievement in the database
  DELETE destroy
    redirects to achievements#index
    deletes the achievement from the database
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

Finished in 0.20014 seconds (files took 1.87 seconds to load)
18 examples, 0 failures
```

---

### Install and setup Devise gem
> basic setup

Install `gem 'devise'` per usual process via Gemfile and `bundle`


Then install Devise.
```
$ rails g devise:install
Running via Spring preloader in process 23827
Expected string default value for '--jbuilder'; got true (boolean)
      create  config/initializers/devise.rb
      create  config/locales/devise.en.yml
===============================================================================

Some setup you must do manually if you haven't yet:

  1. Ensure you have defined default url options in your environments files. Here
     is an example of default_url_options appropriate for a development environment
     in config/environments/development.rb:

       config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }

     In production, :host should be set to the actual host of your application.

  2. Ensure you have defined root_url to *something* in your config/routes.rb.
     For example:

       root to: "home#index"

  3. Ensure you have flash messages in app/views/layouts/application.html.erb.
     For example:

       <p class="notice"><%= notice %></p>
       <p class="alert"><%= alert %></p>

  4. You can copy Devise views (for customization) to your app by running:

       rails g devise:views

===============================================================================
```

Here I added `config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }` to files:

* _/config/environments/development.rb_
* _/config/environments/test.rb_

#### Create a user
```
$ rails g devise user
Running via Spring preloader in process 23972
Expected string default value for '--jbuilder'; got true (boolean)
      invoke  active_record
      create    db/migrate/20170213153020_devise_create_users.rb
      create    app/models/user.rb
      invoke    rspec
      create      spec/models/user_spec.rb
      invoke      factory_girl
      create        spec/factories/users.rb
      insert    app/models/user.rb
       route  devise_for :users

$ rails db:migrate
== 20170213153020 DeviseCreateUsers: migrating ================================
-- create_table(:users)
   -> 0.0120s
-- add_index(:users, :email, {:unique=>true})
   -> 0.0013s
-- add_index(:users, :reset_password_token, {:unique=>true})
   -> 0.0009s
== 20170213153020 DeviseCreateUsers: migrated (0.0145s) =======================
```

FYI for later:
```
$ rails routes
                  Prefix Verb   URI Pattern                      Controller#Action
        new_user_session GET    /users/sign_in(.:format)         devise/sessions#new
            user_session POST   /users/sign_in(.:format)         devise/sessions#create
    destroy_user_session DELETE /users/sign_out(.:format)        devise/sessions#destroy
       new_user_password GET    /users/password/new(.:format)    devise/passwords#new
      edit_user_password GET    /users/password/edit(.:format)   devise/passwords#edit
           user_password PATCH  /users/password(.:format)        devise/passwords#update
                         PUT    /users/password(.:format)        devise/passwords#update
                         POST   /users/password(.:format)        devise/passwords#create
cancel_user_registration GET    /users/cancel(.:format)          devise/registrations#cancel
   new_user_registration GET    /users/sign_up(.:format)         devise/registrations#new
  edit_user_registration GET    /users/edit(.:format)            devise/registrations#edit
       user_registration PATCH  /users(.:format)                 devise/registrations#update
                         PUT    /users(.:format)                 devise/registrations#update
                         DELETE /users(.:format)                 devise/registrations#destroy
                         POST   /users(.:format)                 devise/registrations#create
            achievements GET    /achievements(.:format)          achievements#index
                         POST   /achievements(.:format)          achievements#create
         new_achievement GET    /achievements/new(.:format)      achievements#new
        edit_achievement GET    /achievements/:id/edit(.:format) achievements#edit
             achievement GET    /achievements/:id(.:format)      achievements#show
                         PATCH  /achievements/:id(.:format)      achievements#update
                         PUT    /achievements/:id(.:format)      achievements#update
                         DELETE /achievements/:id(.:format)      achievements#destroy
                    root GET    /                                welcome#index
```

_/spec/factories/users.rb_
```ruby
FactoryGirl.define do
  factory :user do
    sequence(:email) { |n| "email#{n}@email.com"}
    password 'secretsecret'
  end
end
```

_/spec/rails_helper.rb_
```ruby
require 'devise' #below require 'rspec/rails'

  .
  .
  .

  config.include Devise::Test::ControllerHelpers, type: :controller
end
```

---

### Test Authentication
> Guest, User, and Owner roles (could also have Admin, etc.)

#### Features
* Guest can access: index and show views.
* User has all Guest access, and can create new achievements.
* Owner has all User access, and can update and destroy their own achievements.

#### Testing for Guest
_/spec/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do

  describe 'Guest' do
    describe 'GET index' do
      it 'renders :index template' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'assigns only public achievements to the template' do
        public_achievement = FactoryGirl.create(:public_achievement)
        private_achievement = FactoryGirl.create(:private_achievement)
        get :index
        expect(assigns(:achievements)).to match_array([public_achievement])
      end
    end

    describe 'GET show' do
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

    describe 'GET new' do
      it 'redirects to login page' do
        get :new
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    describe 'POST create' do
      it 'redirects to login page' do
        post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    describe 'GET edit' do
      it 'redirects to login page' do
        get :edit, params: { id: FactoryGirl.attributes_for(:public_achievement) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    describe 'PUT update' do
      it 'redrects to login page' do
        put :update, params: { id: FactoryGirl.attributes_for(:public_achievement) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    describe 'DELETE destroy' do
      it 'redrects to login page' do
        delete :destroy, params: { id: FactoryGirl.attributes_for(:public_achievement) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  .
  .
  .
end
```

_/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]

  .
  .
  .
```
```
$ rspec spec/controllers/achievements_controller_spec.rb

AchievementsController
  Guest
    GET index
      renders :index template
      assigns only public achievements to the template
    GET show
      renders :show template
      assigns requested achievement to @achievement
    GET new
      redirects to login page
    POST create
      redirects to login page
    GET edit
      redirects to login page
    PUT update
      redrects to login page
    DELETE destroy
      redrects to login page
```

but
```
Finished in 0.34196 seconds (files took 2.59 seconds to load)
23 examples, 12 failures
```

Our specs for Guest pass, the rest are now not passing because of Authentication.  We'll fix this with Authorization.

---

### Test Authorization

_/spec/achievements_controller_spec.rb_
```ruby
require 'rails_helper'

describe AchievementsController do

  shared_examples "public access to achievements" do
    describe "GET index" do
      it "renders :index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "assigns only public achievements to template" do
        public_achievement = FactoryGirl.create(:public_achievement)
        private_achievement = FactoryGirl.create(:private_achievement)
        get :index
        expect(assigns(:achievements)).to match_array([public_achievement])
      end
    end

    describe "GET show" do
      let(:achievement) { FactoryGirl.create(:public_achievement)}

      it "renders :show template" do
        get :show, params: { id: achievement }
        expect(response).to render_template(:show)
      end

      it "assigns requested achievement to @achievement" do
        get :show, params: { id: achievement }
        expect(assigns(:achievement)).to eq(achievement)
      end
    end
  end

  describe "Guest User" do

    it_behaves_like "public access to achievements"

    describe "GET new" do
      it "redirects to login page" do
        get :new
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    describe "POST create" do
      it "redirects to login page" do
        post :create, params: { achievement: FactoryGirl.attributes_for(:public_achievement) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    describe "GET edit" do
      it "redirects to login page" do
        get :edit, params: { id: FactoryGirl.create(:public_achievement) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    describe "PUT update" do
      it "redirects to login page" do
        put :update, params: { id: FactoryGirl.create(:public_achievement), achievement: FactoryGirl.attributes_for(:public_achievement) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end

    describe "DELETE destroy" do
      it "redirects to login page" do
        delete :destroy, params: { id: FactoryGirl.create(:public_achievement) }
        expect(response).to redirect_to(new_user_session_url)
      end
    end
  end

  describe "Authenticated User" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in(user)
    end

    it_behaves_like "public access to achievements"

    describe "GET index" do
      it "renders :index template" do
        get :index
        expect(response).to render_template(:index)
      end

      it "assigns only public achievements to template" do
        public_achievement = FactoryGirl.create(:public_achievement)
        private_achievement = FactoryGirl.create(:private_achievement)
        get :index
        expect(assigns(:achievements)).to match_array([public_achievement])
      end
    end

    describe "GET show" do
      let(:achievement) { FactoryGirl.create(:public_achievement)}

      it "renders :show template" do
        get :show, params: { id: achievement }
        expect(response).to render_template(:show)
      end

      it "assigns requested achievement to @achievement" do
        get :show, params: { id: achievement }
        expect(assigns(:achievement)).to eq(achievement)
      end
    end

    describe "GET new" do
      it "renders :new template" do
        get :new
        expect(response).to render_template(:new)
      end

      it "assigns new Achievement to @achievement" do
        get :new
        expect(assigns(:achievement)).to be_a_new(Achievement)
      end
    end

    describe "POST create" do
      let(:valid_data) { FactoryGirl.attributes_for(:public_achievement) }

      context "valid data" do
        it "redirects to achievements#show" do
          post :create, params: { achievement: valid_data }
          expect(response).to redirect_to(achievement_path(assigns[:achievement]))
        end
        it "creates new achievement in database" do
          expect {
            post :create, params: { achievement: valid_data }
          }.to change(Achievement, :count).by(1)
        end
      end

      context "invalid data" do
        let(:invalid_data) { FactoryGirl.attributes_for(:public_achievement, title: '') }

        it "renders :new template" do
          post :create, params: { achievement: invalid_data }
          expect(response).to render_template(:new)
        end
        it "doesn't create new achievement in the database" do
          expect {
            post :create, params: { achievement: invalid_data }
          }.not_to change(Achievement, :count)
        end
      end
    end

    context "is not the owner of the achievement" do
      describe "GET edit" do
        it "redirects to achievements page" do
          get :edit, params: { id: FactoryGirl.create(:public_achievement) }
          expect(response).to redirect_to(achievements_path)
        end
      end

      describe "PUT update" do
        it "redirects to achievements page" do
          put :update, params: { id: FactoryGirl.create(:public_achievement), achievement: FactoryGirl.attributes_for(:public_achievement) }
          expect(response).to redirect_to(achievements_path)
        end
      end

      describe "DELETE destroy" do
        it "redirects to achievements page" do
          delete :destroy, params: { id: FactoryGirl.create(:public_achievement) }
          expect(response).to redirect_to(achievements_path)
        end
      end
    end

    context "is the owner of the achievement" do
      let(:achievement) { FactoryGirl.create(:public_achievement, user: user) }

      describe "GET edit" do
        it "renders :edit template" do
          get :edit, params: { id: achievement }
          expect(response).to render_template(:edit)
        end

        it "assigns the requested achievement to template" do
          get :edit, params: { id: achievement }
          expect(assigns(:achievement)).to eq(achievement)
        end
      end

      describe "PUT update" do
        context "valid data" do
          let(:valid_data) { FactoryGirl.attributes_for(:public_achievement, title: "New Title") }

          it "redirects to achievements#show" do
            put :update, params: { id: achievement, achievement: valid_data }
            expect(response).to redirect_to(achievement)
          end
          it "updates achievement in the database" do
            put :update, params: { id: achievement, achievement: valid_data }
            achievement.reload
            expect(achievement.title).to eq("New Title")
          end
        end

        context "invalid data" do
          let(:invalid_data) { FactoryGirl.attributes_for(:public_achievement, title: "", description: 'new') }

          it "renders :edit template" do
            put :update, params: { id: achievement, achievement: invalid_data }
            expect(response).to render_template(:edit)
          end
          it "doesn't update achievement in the database" do
            put :update, params: { id: achievement, achievement: invalid_data }
            achievement.reload
            expect(achievement.description).not_to eq('new')
          end
        end
      end

      describe "DELETE destroy" do
        it "redirects to achievements#index" do
          delete :destroy, params: { id: achievement }
          expect(response).to redirect_to(achievements_path)
        end

        it "deletes achievements from database" do
          delete :destroy, params: { id: achievement }
          expect(Achievement.exists?(achievement.id)).to be_falsy
        end
      end
    end
  end
end
```

_/app/controllers/achievements_controller.rb_
```ruby
class AchievementsController < ApplicationController
  before_action :authenticate_user!, only: [ :new, :create, :edit, :update, :destroy ]
  before_action :owners_only, only: [ :edit, :update, :destroy ]

  def index
    @achievements = Achievement.public_access
  end

  def new
    @achievement = Achievement.new
  end

  def create
    @achievement = Achievement.new(achievement_params)
    if @achievement.save
      redirect_to achievement_url(@achievement), notice: 'Achievement has been created'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @achievement.update_attributes(achievement_params)
      redirect_to achievement_path(@achievement)
    else
      render :edit
    end
  end

  def show
    @achievement = Achievement.find(params[:id])
  end

  def destroy
    @achievement.destroy
    redirect_to achievements_path
  end

  private

  def achievement_params
    params.require(:achievement).permit(:title, :description, :privacy, :cover_image, :featured)
  end

  def owners_only
    @achievement = Achievement.find(params[:id])
    if current_user != @achievement.user
      redirect_to achievements_path
    end
  end

end
```

_/app/models/achievement.rb_
```ruby
class Achievement < ApplicationRecord
  belongs_to :user, optional: true
  validates :title, presence: true
  
  enum privacy: [ :public_access, :private_access, :friends_access ]

  def description_html
    Redcarpet::Markdown.new(Redcarpet::Render::HTML).render(description)
  end
end
```

```
$ rspec

AchievementsController
  Guest User
    behaves like public access to achievements
      GET index
        renders :index template
        assigns only public achievements to template
      GET show
        renders :show template
        assigns requested achievement to @achievement
    GET new
      redirects to login page
    POST create
      redirects to login page
    GET edit
      redirects to login page
    PUT update
      redirects to login page
    DELETE destroy
      redirects to login page
  Authenticated User
    behaves like public access to achievements
      GET index
        renders :index template
        assigns only public achievements to template
      GET show
        renders :show template
        assigns requested achievement to @achievement
    GET index
      renders :index template
      assigns only public achievements to template
    GET show
      renders :show template
      assigns requested achievement to @achievement
    GET new
      renders :new template
      assigns new Achievement to @achievement
    POST create
      valid data
        redirects to achievements#show
        creates new achievement in database
      invalid data
        renders :new template
        doesn't create new achievement in the database
    is not the owner of the achievement
      GET edit
        redirects to achievements page
      PUT update
        redirects to achievements page
      DELETE destroy
        redirects to achievements page
    is the owner of the achievement
      GET edit
        renders :edit template
        assigns the requested achievement to template
      PUT update
        valid data
          redirects to achievements#show
          updates achievement in the database
        invalid data
          renders :edit template
          doesn't update achievement in the database
      DELETE destroy
        redirects to achievements#index
        deletes achievements from database

Achievement Page
  Achievement Public Page
  Render Markdown Description

create new achievement
  create new achievement with valid data
  cannot create new achievement with invalid data

home page
  welcome message

Finished in 1.35 seconds (files took 2.25 seconds to load)
39 examples, 0 failures
```