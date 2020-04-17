class GardenPlant < ApplicationRecord
	belongs_to :garden
  belongs_to :plant
  
  has_many :events, dependent: :destroy
end
