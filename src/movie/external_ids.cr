class Tmdb::Movie
  struct ExternalIds
    # Databases
    getter imdb_id : String?
    getter wikidata_id : String?
    # Social Media
    getter facebook_id : String?
    getter instagram_id : String?
    getter twitter_id : String?

    def initialize(@data : JSON::Any)
      @imdb_id = @data["imdb_id"].as_s?
      @wikidata_id = @data["wikidata_id"].as_s?
      @facebook_id = @data["facebook_id"].as_s?
      @instagram_id = @data["instagram_id"].as_s?
      @twitter_id = @data["twitter_id"].as_s?
    end
  end
end