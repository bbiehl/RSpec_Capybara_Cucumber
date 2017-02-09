require 'rails_helper'

feature 'Achievement Page' do
  scenario 'Achievement Public Page' do
    achievement = FactoryGirl.create(:achievement, title: 'just did it')
    visit("/achievements/#{achievement.id}")

    expect(page).to have_content('just did it')
  end

  scenario 'Render Markdown Description' do
    achievement = FactoryGirl.create(:achievement, description: 'it was *cool*')
    visit("/achievements/#{achievement.id}")

    expect(page).to have_css('em', text: 'cool')
  end
end