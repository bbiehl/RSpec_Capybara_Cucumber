# Acceptance Tests
## Overview
* Rails app setup
* Capybara helpers
* Page Object pattern
* Factory Girl
* Cucumber 101


### Setup and simple welcome page

_Gemfile_
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

group :development, :test do
  gem 'byebug', platform: :mri
  gem 'rspec-rails'
  gem 'factory_girl_rails'
end

group :test do
  gem 'capybara'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '~> 3.0.5'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]

```

Run bundle.
```
$ bundle
```

Generate some files
```
$ rails g rspec:install
Running via Spring preloader in process 4223
Expected string default value for '--jbuilder'; got true (boolean)
      create  .rspec
      create  spec
      create  spec/spec_helper.rb
      create  spec/rails_helper.rb
```

```
$ bundle exec spring binstub --all
* bin/rake: spring already present
* bin/rspec: generated with spring
* bin/rails: spring already present
```

Create Folder: _/spec/features_

Create File: _/spec/features/home_page_spec.rb_
```ruby
require 'rails_helper'

feature 'home page' do
  scenario 'welcome message' do
    visit('/')
    expect(page).to have_content('Welcome')
  end
end
```

#### Red

Spec Fails: (abridged text here, what's important is the failure message)
```
$ rspec

home page
  welcome message (FAILED - 1)

Failures:

  1) home page welcome message
     Failure/Error: visit('/')

     ActionController::RoutingError:
       No route matches [GET] "/"
```

#### Green
_/config/routes.rb_
```ruby
Rails.application.routes.draw do
  root to: 'welcome#index'
end
```
```
$ rspec

home page
  welcome message (FAILED - 1)

Failures:

  1) home page welcome message
     Failure/Error: visit('/')

     ActionController::RoutingError:
       uninitialized constant WelcomeController
```

We need WelcomeController

Create:
_/app/controllers/welcome_controller.rb_
```ruby
class WelcomeController < ApplicationController
  
end
```
```
$ rspec

home page
  welcome message (FAILED - 1)

Failures:

  1) home page welcome message
     Failure/Error: visit('/')

     AbstractController::ActionNotFound:
       The action 'index' could not be found for WelcomeController
```

We need action 'index'

_/app/controllers/welcome_controller.rb_
```ruby
class WelcomeController < ApplicationController
  def index
  end
end
```
```
$ rspec

home page
  welcome message (FAILED - 1)

Failures:

  1) home page welcome message
     Failure/Error: visit('/')

     ActionController::UnknownFormat:
       WelcomeController#index is missing a template for this request format and variant.
```

We're missing a template. Create: _/app/views/welcome/index.html.erb_

```
$ rspec

home page
  welcome message (FAILED - 1)

Failures:

  1) home page welcome message
     Failure/Error: expect(page).to have_content('Welcome')
       expected to find text "Welcome" in ""
     # ./spec/features/home_page_spec.rb:6:in `block (2 levels) in <top (required)>'

Finished in 0.3308 seconds (files took 3.56 seconds to load)
1 example, 1 failure
```

Add welcome text:
_/app/views/welcome/index.html.erb_
```
Welcome
```
```
$ rspec

home page
  welcome message

Finished in 0.18298 seconds (files took 3.51 seconds to load)
1 example, 0 failures
```

We can visually verify:
```
$ rails s
```
http://localhost:3000/
![Welcome](./img/2-welcome.png)

### Bootstrap Styling

Create File: _/app/assets/stylesheets/main.css.scss_
```css
@import 'bootstrap-sprockets';
@import 'bootstrap';
```















