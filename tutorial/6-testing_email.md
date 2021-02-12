# Testing Email

> notice in: _/config/environments/test.rb_
```ruby
  config.action_mailer.delivery_method = :test
```

_/spec/features/create_achievement_spec.rb_
```ruby
require 'rails_helper'
require_relative '../support/login_form'
require_relative '../support/new_achievement_form'

feature 'create new achievement' do
  let(:new_achievement_form) { NewAchievementForm.new }
  let(:login_form) { LoginForm.new }
  let(:user) { FactoryGirl.create(:user) }

  scenario 'create new achievement with valid data' do
    login_form.visit_page.login_as(user)
    new_achievement_form.visit_page.fill_in_with(title: 'Worked out today').submit

    expect(ActionMailer::Base.deliveries.count).to eq(1)
    expect(ActionMailer::Base.deliveries.last.to).to include(user.email)
    expect(page).to have_content('Achievement has been created')
    expect(Achievement.last.title).to eq('Worked out today')
  end

  scenario 'cannot create new achievement with invalid data' do
    login_form.visit_page.login_as(user)
    new_achievement_form.visit_page.submit

    expect(page).to have_content("can't be blank")
  end
end
```
```
$ rspec

Failures:

  1) create new achievement create new achievement with valid data
     Failure/Error: expect(ActionMailer::Base.deliveries.count).to eq(1)

       expected: 1
            got: 0

       (compared using ==)
```

```
$ rails g mailer UserMailer
Running via Spring preloader in process 57650
Expected string default value for '--jbuilder'; got true (boolean)
      create  app/mailers/user_mailer.rb
      invoke  erb
      create    app/views/user_mailer
   identical    app/views/layouts/mailer.text.erb
   identical    app/views/layouts/mailer.html.erb
      invoke  rspec
      create    spec/mailers/user_mailer_spec.rb
      create    spec/mailers/previews/user_mailer_preview.rb
```

_/spec/mailers/user_mailer_spec.rb_
```ruby
require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  it 'sends "Achievment Created" email to author' do
    email = UserMailer.achievement_created('author@example.com').deliver_now
    expect(email.to).to include('author@example.com')
  end
end
```
```
$ rspec spec/mailers

UserMailer
  sends "Achievment Created" email to author (FAILED - 1)

Failures:

  1) UserMailer sends "Achievment Created" email to author
     Failure/Error: email = UserMailer.achievement_created('author@example.com').deliver_now

     NoMethodError:
       undefined method `achievement_created' for UserMailer:Class
```

_/app/mailers/user_mailer.rb_
```ruby
class UserMailer < ApplicationMailer
  def achievement_created(email)
    mail to: email
  end
end
```
```
$ rspec spec/mailers

UserMailer
  sends "Achievment Created" email to author (FAILED - 1)

Failures:

  1) UserMailer sends "Achievment Created" email to author
     Failure/Error: mail to: email

     ActionView::MissingTemplate:
       Missing template user_mailer/achievement_created with "mailer". Searched in:
         * "user_mailer"
```
Create file:
```
$ touch app/views/user_mailer/achievement_created.text.erb
```
```
$ rspec spec/mailers

UserMailer
  sends "Achievment Created" email to author

Finished in 0.16457 seconds (files took 2.08 seconds to load)
1 example, 0 failures
```

#### Testing subject line

_/spec/mailers/user_mailer_spec.rb_
```ruby
require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  let(:email) { UserMailer.achievement_created('author@example.com').deliver_now }

  it 'sends "Achievment Created" email to author' do
    expect(email.to).to include('author@example.com')
  end

  it 'has correct subject' do
    expect(email.subject).to eq('Congratulations') 
  end
end
```
```
$ rspec

Failures:

  1) UserMailer has correct subject
     Failure/Error: expect(email.subject).to eq('Congratulations')

       expected: "Congratulations"
            got: "Achievement created"

       (compared using ==)
```

_/app/mailers/user_mailer.rb_
```ruby
class UserMailer < ApplicationMailer
  def achievement_created(email)
    mail to: email,
      subject: 'Congratulations'
  end
end
```
```
$ rspec spec/mailers

UserMailer
  sends "Achievment Created" email to author
  has correct subject

Finished in 0.16323 seconds (files took 2.15 seconds to load)
2 examples, 0 failures
```

#### Testing email content

_/spec/mailers/user_mailer_spec.rb_
```ruby
require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  include Rails.application.routes.url_helpers
  
  let(:achievement_id) { 1 }
  let(:email) { UserMailer.achievement_created('author@example.com', achievement_id).deliver_now }

  it 'sends "Achievment Created" email to author' do
    expect(email.to).to include('author@example.com')
  end

  it 'has correct subject' do
    expect(email.subject).to eq('Congratulations') 
  end

  it 'has achievement link in body of message' do
    expect(email.body.to_s).to include(achievement_url(achievement_id)) 
  end
end
```
```
$ rspec

  3) UserMailer has achievement link in body of message
     Failure/Error:
       def achievement_created(email)
         mail to: email,
           subject: 'Congratulations'
       end

     ArgumentError:
       wrong number of arguments (given 2, expected 1)
```

_/app/mailers/user_mailer.rb_
```ruby
class UserMailer < ApplicationMailer
  def achievement_created(email, achievement_id)
    mail to: email,
      subject: 'Congratulations'
  end
end
```
```
$ rspec

Failures:

  1) UserMailer has achievement link in body of message
     Failure/Error: expect(email.body.to_s).to include(achievement_url(achievement_id))
       expected "" to include "http://localhost:3000/achievements/1"
```

_/app/views/user_mailer/achievement_created.text.erb_
```ruby
<%= achievement_url(@achievement_id) %>
```

And

_/app/mailers/user_mailer.rb_
```ruby
class UserMailer < ApplicationMailer
  def achievement_created(email, achievement_id)
    @achievement_id = achievement_id
    mail to: email,
      subject: 'Congratulations'
  end
end
```
```
$ rspec spec/mailers

UserMailer
  sends "Achievment Created" email to author
  has correct subject
  has achievement link in body of message

Finished in 0.16695 seconds (files took 2.23 seconds to load)
3 examples, 0 failures
```

#### Go back to acceptance test
```
$ rspec spec/features/create_achievement_spec.rb

create new achievement
  create new achievement with valid data (FAILED - 1)
  cannot create new achievement with invalid data

Failures:

  1) create new achievement create new achievement with valid data
     Failure/Error: expect(ActionMailer::Base.deliveries.count).to eq(1)

       expected: 1
            got: 0

       (compared using ==)
     # ./spec/features/create_achievement_spec.rb:14:in `block (2 levels) in <top (required)>'

Finished in 0.61218 seconds (files took 2.01 seconds to load)
2 examples, 1 failure
```

_/app/controllers/achievements_controller.rb_
```ruby




















































