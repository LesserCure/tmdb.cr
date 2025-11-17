require "./external_ids"
require "../filter_factory"
require "../poster_urls"
require "../change"

class Tmdb::Tv::Season
  include PosterUrls

  getter air_date : Time?
  getter episodes : Array(Tv::Episode)?
  getter poster_path : String?
  getter season_number : Int32
  getter id : Int64
  getter name : String
  getter overview : String
  getter show_id : Int64
  getter vote_average : Float64

  # Get the TV season details by id.
  def self.detail(show_id : Int64, season_number : Int32, language : String? = nil) : Season
    res = Resource.new("/tv/#{show_id}/season/#{season_number}", FilterFactory.create_language(language))
    Season.new(res.get, show_id)
  end

  # Get the aggregate credits for TV season.
  #
  # This call differs from the main `#credits` call in that it does not only
  # return the season credits, but rather is a view of all the cast & crew for
  # all of the episodes belonging to a season.
  def self.aggregated_credits(show_id : Int64, season_number : Int32, language : String? = nil) : Array(AggregatedCast | AggregatedCrew)
    url = "/tv/#{show_id}/season/#{season_number}/aggregate_credits"
    res = Resource.new(url, FilterFactory.create_language(language))
    data = res.get
    ret = [] of AggregatedCast | AggregatedCrew

    data["cast"].as_a.reduce(ret) { |ret, cast| ret << AggregatedCast.new(cast) }
    data["crew"].as_a.reduce(ret) { |ret, crew| ret << AggregatedCrew.new(crew) }

    ret
  end

  # Get the credits for TV season.
  def self.credits(show_id : Int64, season_number : Int32, language : String? = nil) : Array(Tv::Cast | Tv:: Crew)
    filters = FilterFactory.create_language(language)

    res = Resource.new("/tv/#{show_id}/season/#{season_number}/credits", filters)
    data = res.get
    ret = [] of Tv::Cast | Tv::Crew

    data["cast"].as_a.reduce(ret) { |ret, cast| ret << Tv::Cast.new(cast) }
    data["crew"].as_a.reduce(ret) { |ret, crew| ret << Tv::Crew.new(crew) }

    ret
  end

  def self.external_ids(show_id : Int64, season_number : Int32, language : String? = nil) : ExternalIds
    ExternalIds.new(Resource.new("/tv/#{show_id}/season/#{season_number}/external_ids").get)
  end

  def self.translations(show_id : Int64, season_number : Int32, language : String? = nil) : Array(Translation)
    res = Resource.new("/tv/#{show_id}/season/#{season_number}/translations", FilterFactory.create_language(language))
    data = res.get

    data["translations"].as_a.map { |tr| Translation.new(tr) }
  end

  def initialize(data : JSON::Any, @show_id : Int64)
    @air_date = Tmdb.parse_date(data["air_date"])
    @episodes = data["episodes"].as_a.map { |episode| Episode.new(episode, show_id) } if data["episodes"]?
    @poster_path = data["poster_path"].as_s?
    @season_number = data["season_number"].as_i
    @id = data["id"].as_i64
    @name = data["name"].as_s
    @overview = data["overview"].as_s
    @vote_average = data["vote_average"].as_f
  end

  # Get the aggregate credits for TV season.
  #
  # This call differs from the main `#credits` call in that it does not only
  # return the season credits, but rather is a view of all the cast & crew for
  # all of the episodes belonging to a season.
  def aggregated_credits(language : String? = nil) : Array(AggregatedCast | AggregatedCrew)
    self.class.aggregated_credits(show_id, season_number, language)
  end

  # Get the changes for a movie. By default only the last 24 hours are returned.
  #
  # You can query up to 14 days in a single query by using the `start_date` and
  # `end_date` query parameters.
  def changes(start_date : Time? = nil, end_date : Time? = nil) : Array(Change)
    filters = FilterFactory::Filter.new
    filters[:start_date] = start_date.to_s("%Y-%m-%d") unless start_date.nil?
    filters[:end_date] = end_date.to_s("%Y-%m-%d") unless end_date.nil?

    res = Resource.new("/tv/season/#{id}/changes", filters)
    data = res.get

    data["changes"].as_a.map { |change| Change.new(change) }
  end

  # Get the credits for TV season.
  def credits(language : String? = nil) : Array(Tv::Cast | Tv:: Crew)
    self.class.credits(show_id, season_number, language)
  end

  # Get the external ids for a TV season. We currently support the following
  # external sources.
  #
  # * TVDB ID
  # * Freebase MID\*
  # * Freebase ID\*
  # * TVRage ID\*
  #
  # \*Defunct or no longer available as a service.
  def external_ids(language : String? = nil) : ExternalIds
    self.class.external_ids(show_id, season_number, language)
  end

  # Get the images that belong to a TV season.
  #
  # Querying images with a `language` parameter will filter the results. If you
  # want to include a fallback language (especially useful for backdrops) you
  # can use the `include_image_language` parameter. This should be a comma
  # seperated value like so: `include_image_language=en,null`.
  def images(language : String? = nil) : Array(Image)
    res = Resource.new("/tv/#{show_id}/season/#{season_number}/images", FilterFactory.create_language(language))
    data = res.get

    data["posters"].as_a.map { |poster| Image.new(poster) }
  end

  # See `#images`
  def posters(language : String? = nil) : Array(Poster)
    images(language)
  end

  # Get the credits for TV season.
  def translations(language : String? = nil) : Array(Translation)
    self.class.translations(show_id, season_number, language)
  end

  # Get the videos that have been added to a TV season.
  def videos(language : String? = nil) : Array(Video)
    res = Resource.new("/tv/#{show_id}/season/#{season_number}/videos", FilterFactory.create_language(language))
    data = res.get

    data["results"].as_a.map { |video| Video.new(video) }
  end
end
