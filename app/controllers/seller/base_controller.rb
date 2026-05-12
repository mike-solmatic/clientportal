class Seller::BaseController < ApplicationController
  before_action :require_seller!
  layout "seller"
end
