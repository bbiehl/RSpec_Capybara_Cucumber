require 'rails_helper'

RSpec.describe Achievement, type: :model do

  describe 'associations' do
    it { should belong_to(:user) }  
  end
  
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title).scoped_to(:user_id).with_message("you can't have two achievements with same title") }
    it { should validate_presence_of(:user) }
  end

  describe 'instance methods' do
    it 'converts markdown to HTML' do
      achievement = Achievement.new(description: 'Awesome **thing** I *actually* did')
      expect(achievement.description_html).to include('<strong>thing</strong>')
      expect(achievement.description_html).to include('<em>actually</em>')
    end

    it "has a silly title concatenated with user's email" do
      achievement = Achievement.new(title: 'New Achievement', user: FactoryGirl.create(:user, email: 'foo@bar.com'))
      expect(achievement.silly_achievement).to eq('New Achievement by foo@bar.com')
    end
  end
end