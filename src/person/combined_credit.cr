class Tmdb::Person
  module CombinedCredit
    getter media_type : Media::Type
    
    def initialize(data : JSON::Any)
      @media_type = case data["media_type"].as_s
        when "movie" then Media::Type::Movie
        when "tv" then Media::Type::Tv
        else raise "Unknown media type: #{data["media_type"].as_s}"
      end
    end
  end
end