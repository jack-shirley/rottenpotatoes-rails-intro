class MoviesController < ApplicationController

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end




  def index
    @movies = Movie.all
    @all_ratings = @movies.pluck(:rating).uniq.sort
    @hilite_title = false
    @hilite_release_date = false
    
    if !params[:ratings].nil? || !session[:ratings].nil?
      @ratings_to_show = params[:ratings] || session[:ratings]
    end
    
    if !params[:sorted].nil? || !session[:sorted].nil?
      @sorted_by = params[:sorted] || session[:sorted]
    end
    
    
    if @ratings_to_show.nil?
      @ratings_to_show = []
      @movies = Movie.all
    else
      temp = []
      if @ratings_to_show.kind_of?(Array)
        temp = @ratings_to_show
      else
        temp = @ratings_to_show.keys
      end
      @movies = Movie.where(rating: temp )
    end
    
    
    if !(@sorted_by.nil?)
      if !(@ratings_to_show.nil? || @ratings_to_show.empty?)
        temp = []
        if @ratings_to_show.kind_of?(Array)
          temp = @ratings_to_show
        else
          temp = @ratings_to_show.keys
        end
        @movies = Movie.where(rating: temp )
        session[:ratings] = params[:ratings]
      else
        @movies = Movie.all
      end
      
      @movies = @movies.order(@sorted_by)
      
      if @sorted_by == "title"
        @hilite_title = true
      elsif @sorted_by == "release_date"
        @hilite_release_date = true
      end
      session[:sorted] = params[:sorted]
    end
      
  end




  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end
  
  

  private
  # Making "internal" methods private is not required, but is a common practice.
  # This helps make clear which methods respond to requests, and which ones do not.
  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end
end
