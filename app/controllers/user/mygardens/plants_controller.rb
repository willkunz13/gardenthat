class User::Mygardens::PlantsController < User::BaseController
	def index
		@garden = Garden.find(params[:id])
	end

	def create
		garden = Garden.find(params[:garden_id])
		plant = Plant.find(params[:plant_id])
    garden.plants << plant
    garden.save
    Thread.new do
      add_notification(garden, plant)
    end
    flash[:notice] = "We're updating your calendar with the harvest time of your #{plant.name.downcase}"
		redirect_to("/user/mygardens/#{garden.id}")
  end

  def destroy
    garden_plant = GardenPlant.where("garden_id= #{params[:garden_id]} AND plant_id= #{params[:plant_id]}").first
    remove_notifications(garden_plant, current_user)
    garden_plant.destroy
    redirect_to("/user/mygardens/#{params[:garden_id]}")
  end
  
  private 
  
  def add_notification(garden, plant)
    title = plant.name.capitalize + " harvest time!"
    description = "It's time to harvest your #{plant.name} in #{garden.name}"
    harvest_date = plant.first_harvest.to_i.days.from_now.to_s[0..9]
    response = CalendarService.post_events(garden.user, title, description, harvest_date)
    garden_plant = GardenPlant.where("garden_id= #{params[:garden_id]} AND plant_id= #{params[:plant_id]}").first
    garden_plant.events.create(event_id: response[:id])
  end 

  def remove_notifications(garden_plant, user)
    garden_plant.events.each do |event|
      CalendarService.delete_event(user, event.event_id)
      event.destroy
    end
  end
end
