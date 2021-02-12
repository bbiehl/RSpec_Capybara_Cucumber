require 'rails_helper'

feature 'home page' do
  scenario 'welcome message' do
    visit('/')
    expect(page).to have_content('Welcome')
  end

  scenario 'has correct page title' do
    visit('/')
    expect(page).to have_title('RSpecCapybaraCucumber')
  end
end