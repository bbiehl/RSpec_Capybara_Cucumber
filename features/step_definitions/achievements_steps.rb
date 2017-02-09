Given(/^I am a guest user$/) do
  # empty step
end

Given(/^there is a public achievement$/) do
  @achievement = FactoryGirl.create(:public_achievement, title: 'I did it')
end

When(/^I go to the achievements page$/) do
  visit(achievement_path(@achievement.id))
end

Then(/^I must see achievements content$/) do
  expect(page).to have_content('I did it')
end