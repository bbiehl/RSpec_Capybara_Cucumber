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
