require "./tv/show_result"
require "./movie_result"
require "./person"
require "./profile_urls"

class Tmdb::PersonResult
  include ProfileUrls

  getter profile_path : String?
  getter adult : Bool
  getter gender : Person::Gender
  getter id : Int64
  getter known_for_department : String?
  getter name : String
  getter original_name : String
  getter popularity : Float64
  getter known_for : Array(MovieResult | Tv::ShowResult)

  def initialize(data : JSON::Any)
    @profile_path = data["profile_path"].as_s?
    @adult = data["adult"].as_bool
    @gender = Person::Gender.from_value(data["gender"].as_i)
    @id = data["id"].as_i64
    @known_for_department = data["known_for_department"].as_s?
    @name = data["name"].as_s
    @original_name = data["original_name"].as_s
    @popularity = data["popularity"]? ? Tmdb.resilient_parse_float64(data["popularity"]) : 0.0

    begin
      known_for = data["known_for"].as_a.map do |item|
        if item["media_type"].as_s == "tv"
          Tv::ShowResult.new(item)
        else
          MovieResult.new(item)
        end
      end
    rescue TypeCastError
      known_for = [] of MovieResult | Tv::ShowResult
    end

    @known_for = known_for || [] of MovieResult | Tv::ShowResult
  end

  def person_detail : Person
    Person.detail(id)
  end

  def movie_credits(language : String? = nil) : Array(Person::Cast | Person::Crew)
    Person.movie_credits(id, language)
  end

  def tv_credits(language : String? = nil) : Array(Person::Cast | Person::Crew)
    Person.tv_credits(id, language)
  end

  def combined_credits(language : String? = nil) : Array(Person::CombinedCast | Person::CombinedCrew)
    Person.combined_credits(id, language)
  end

  def external_ids(language : String? = nil) : ExternalIds
    Person.external_ids(id, language)
  end

  def translations(language : String? = nil) : Array(Translation)
    Person.translations(id, language)
  end
end
