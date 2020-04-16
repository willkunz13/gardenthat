require 'rails_helper'

RSpec.describe "As a registered user " , type: :feature do

  describe "Interacting with MyGarden" do

    before(:each) do
      @user1 = User.create!( email: 'gardenthat@gmail.com',
                            name: 'gardenthat',
                            zip_code: '02300',
                            google_token: 'temp',
                            google_refresh_token: 'temp'
                          )
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(@user1)
			@garden = Garden.create(name: 'Garden 1', user: @user1)
			@plant = Plant.new(name: 'tomato', image: "https://www.almanac.com/sites/default/files/image_nodes/tomatoes_helios4eos_gettyimages-edit.jpeg")
    end

    it "View Garden Plants" do
			@garden.plants << @plant
      visit "/user/mygardens"
      click_link "Garden 1"
      expect(current_path).to eq("/user/mygardens/#{@garden.id}")
      expect(page).to have_content("#{@garden.name}")
      expect(page).to have_link("Tomato")
    end

		it "Catch no plants" do
			visit "/user/mygardens"
      click_link "Garden 1"
      expect(current_path).to eq("/user/mygardens/#{@garden.id}")
      expect(page).to have_content('plants in this garden. Find something you would like to grow and add them to keep track of what you have')
		end

		it "Add plant", :vcr do
			visit '/'
			fill_in "search", with: "tomato"
			click_on "Search"
			click_on "Tomato"
			click_on "Add to MyGarden"
			plant = Plant.last
			expect(current_path).to eq("/user/plants/#{plant.id}/mygardens")
			click_link 'Garden 1'
			expect(page).to have_content("tomato")
		end
  end
end
