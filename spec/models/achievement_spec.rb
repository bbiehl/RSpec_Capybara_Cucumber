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

  describe 'DB queries' do
    it 'can filter titles by letter' do
      user = FactoryGirl.create(:user)
      achievement1 = FactoryGirl.create(:public_achievement, title: 'Read a book', user: user)
      achievement2 = FactoryGirl.create(:public_achievement, title: 'Passed an exam', user: user)
      expect(Achievement.by_letter('R')).to eq([achievement1])
    end

    it 'sorts achievements by user emails' do
      dutch = FactoryGirl.create(:user, email: 'dutch@example.com')
      maverick = FactoryGirl.create(:user, email: 'maverick@example.com')
      achievement1 = FactoryGirl.create(:public_achievement, title: "Didn't bite anyone", user: maverick)
      achievement2 = FactoryGirl.create(:public_achievement,title: "Didn't bark", user: dutch)
      expect(Achievement.by_letter('D')).to eq([achievement2, achievement1])
    end
  end
end