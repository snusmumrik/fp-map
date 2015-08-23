class PlacesController < ApplicationController
  before_action :set_place, only: [:show, :edit, :update, :destroy]

  # GET /places
  # GET /places.json
  def index
    @categories = Array.new
    Category.all.each do |c|
      @categories << [c.name, c.name]
    end

    keywords = Array.new
    keywords << params[:category] unless params[:category].blank?
    keywords << params[:keyword] unless params[:keyword].blank?
    @keyword = keywords.join(",")

    if params[:category].blank?
      if params[:keyword].blank?
        @places = Place.page params[:page]
      else
        @places = Place.search_with_keyword(params[:keyword]).page params[:page]
      end
    else
      if params[:keyword].blank?
        @places = Place.search_with_category(params[:category]).page params[:page]
      else
        @places = Place.search_with_category(params[:category]).search_with_keyword(params[:keyword]).page params[:page]
      end
    end

    @hash = Gmaps4rails.build_markers(@places) do |place, marker|
      marker.lat place.latitude
      marker.lng place.longitude
      marker.infowindow "#{place.name}<br>(#{place.category})<br>#{place.address}"
      marker.json({title: place.name})
    end
  end

  # GET /places/1
  # GET /places/1.json
  def show
  end

  # GET /places/new
  def new
    @place = Place.new
  end

  # GET /places/1/edit
  def edit
  end

  # POST /places
  # POST /places.json
  def create
    @place = Place.new(place_params)

    respond_to do |format|
      if @place.save
        format.html { redirect_to @place, notice: 'Place was successfully created.' }
        format.json { render :show, status: :created, location: @place }
      else
        format.html { render :new }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /places/1
  # PATCH/PUT /places/1.json
  def update
    respond_to do |format|
      if @place.update(place_params)
        format.html { redirect_to @place, notice: 'Place was successfully updated.' }
        format.json { render :show, status: :ok, location: @place }
      else
        format.html { render :edit }
        format.json { render json: @place.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /places/1
  # DELETE /places/1.json
  def destroy
    @place.destroy
    respond_to do |format|
      format.html { redirect_to places_url, notice: 'Place was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_place
      @place = Place.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def place_params
      params.require(:place).permit(:name, :category, :address, :latitude, :longitude, :tel, :url)
    end
end
