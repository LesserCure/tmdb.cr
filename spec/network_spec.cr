require "./spec_helper"

describe Tmdb::Network do
  context "#detail" do
    it "should get a network instance" do
      VCR.use_cassette("tmdb") do
        network = Tmdb::Network.detail(19)

        network.should be_a(Tmdb::Network)
      end
    end
  end

  context "#alternative_names" do
    it "should get a list" do
      VCR.use_cassette("tmdb") do
        network = Tmdb::Network.detail(19)
        alternative_names = network.alternative_names

        alternative_names.should be_a(Array(String))
        alternative_names.size.should eq(6)
      end
    end
  end

  context "#images" do
    it "should get a list" do
      VCR.use_cassette("tmdb") do
        network = Tmdb::Network.detail(19)
        images = network.images

        images.should be_a(Array(Tmdb::Image))
        images.size.should eq(2)
      end
    end
  end
end
