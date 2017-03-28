require 'spec_helper'

RSpec.describe ActiveTriplesAdapter do
  before do
    class ExampleResource < ActiveTriples::Resource
      include ActiveTriplesAdapter
      configure :repository => :default
      configure :type => RDF::URI("http://purl.org/dc/dcam/VocabularyEncodingScheme")
      configure :base_uri => "http://authority.localhost.localdomain/ns/"
      def self.repository
        :default
      end
    end
  end
  after do
    Object.send(:remove_const, "ExampleResource")
  end
  let(:resource) { ExampleResource.new(uri) }
  let(:uri) { "http://authority.localhost.localdomain/ns/bla" }
  let(:id) { "bla" }
  let(:repository) { RDF::Blazegraph::Repository.new(ENV['TRIPLESTORE_URL']) }
  before do
    stub_repository
  end
  
  describe "#new" do
    context "when there's nothing in the repository" do
      it "should not be persisted" do
        expect(resource).not_to be_persisted
      end
    end
    context "when there's something in the repository" do
      before do
        repository << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, "bla")
      end
      it "should not be persisted" do
        expect(resource).not_to be_persisted
      end
      it "should have no triples" do
        expect(resource.statements.to_a.length).to eq 1
      end
    end
    context "and then triples are persisted" do
      before do
        resource << RDF::Statement.new(RDF::URI(uri), RDF::DC.title, "bla")
        resource.persist!
      end
      it "should be persisted" do
        expect(resource).to be_persisted
      end
    end
  end

  describe "#find" do
    context "when there's nothing in the repository" do
      let(:resource) { ExampleResource.find("http://authority.localhost.localdomain/ns/noexist") }
      
      it "should raise an exception" do
        expect{resource}.to raise_error(ActiveTriples::NotFound)
      end
    end
    context "when there's something in the repository" do
      before do
        @resource = ExampleResource.new("http://authority.localhost.localdomain/ns/noexist")
        @resource.persist!
        repository << RDF::Statement.new(RDF::URI("http://authority.localhost.localdomain/ns/foo1"), RDF::DC.title, "bla")
      end
      after do
        @resource.destroy
      end
      it "should be persisted" do
        expect(@resource).to be_persisted
      end
      it "should have statements" do
        expect(@resource.statements.to_a.length).not_to eq 0
      end
    end
  end
  
  describe "#exists?" do
    let(:result) { ExampleResource.exists?(id) }
    context "when there's nothing in the repository" do
      it "should return false" do
        expect(result).to eq false
      end
    end
    context "when asking for a blank string" do
      let(:id) { "" }
      it "should be false" do
        expect(result).to eq false
      end
    end
    context "when asking for a blank node" do
      let(:uri) { RDF::Node.new.to_s }
      it "should be false" do
        expect(result).to eq false
      end
    end
    context "when there's something in the repository" do
      before do
        @resource = ExampleResource.new("http://authority.localhost.localdomain/ns/foo2")
        @resource.persist!
        repository << RDF::Statement.new(RDF::URI("http://authority.localhost.localdomain/ns/foo2"), RDF::DC.title, "bla")
      end
      after do
        @resource.destroy
      end      
      it "should be true" do
        expect(ExampleResource.exists?("http://authority.localhost.localdomain/ns/foo2")).to eq true
      end
    end
  end
end
