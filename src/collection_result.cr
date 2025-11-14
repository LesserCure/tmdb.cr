require "./collection"
require "./image_urls"

class Tmdb::CollectionResult
  include ImageUrls

  getter id : Int64
  getter backdrop_path : String?
  getter poster_path : String?
  getter name : String
  getter original_language : String
  getter original_name : String
  getter overview : String

  def initialize(data : JSON::Any)
    @id = data["id"].as_i64
    @backdrop_path = data["backdrop_path"].as_s?
    @poster_path = data["poster_path"].as_s?
    @name = data["name"].as_s
    @original_language = data["original_language"].as_s
    @original_name = data["original_name"].as_s
    @overview = data["overview"].as_s
  end

  def collection_detail : Collection
    Collection.detail(id)
  end

  def translations : Array(Translation)
    Collection.translations(id)
  end
end
