require 'spec_helper'

RSpec.describe ChildNodeFinder do
  describe "#find_children" do
    subject { ChildNodeFinder.new(sparql_client) }
    let(:vocabulary) { LafayetteConcerns::Vocabulary.new("http://authority.localhost.localdomain/ns/barVocabulary") }
    let(:sparql_client) { VocabularyInjector.new.sparql_client }
    let(:result) { subject.find_children(vocabulary) }
    before do
      @term = LafayetteConcerns::Term.new("http://authority.localhost.localdomain/ns/barVocabulary/term1")
      @unrelated_term = LafayetteConcerns::Term.new("http://authority.localhost.localdomain/ns/quxVocabulary/term1")
      @term.persist!
      @unrelated_term.persist!
    end
    after do
      @term.destroy
      @unrelated_term.destroy
    end
    def statements_hash(graph)
      graph.statements.to_a.map{|x| x.to_hash}.sort_by{|x| x[:predicate]}
    end
    it "should return all children" do
      expect(result.length).to eq 1
      expect(statements_hash(result.first)).to eq statements_hash(@term)
    end
    context "when there are two children" do
      let(:sorted_result) { result.sort_by{|i| i.rdf_subject.to_s.downcase} }
      before do
        @another_term = LafayetteConcerns::Term.new("http://authority.localhost.localdomain/ns/barVocabulary/foo")
        @another_term2 = LafayetteConcerns::Term.new("http://authority.localhost.localdomain/ns/barVocabulary/blue")
        @another_term.persist!
        @another_term2.persist!
      end
      after do
        @another_term.destroy
        @another_term2.destroy
      end
      it "should be able to return them" do
        expect(result.length).to eq 3
        expect( sorted_result.map{|sorted_graph| statements_hash(sorted_graph)} ).to include(statements_hash(@term))
        expect( sorted_result.map{|sorted_graph| statements_hash(sorted_graph)} ).to include(statements_hash(@another_term))
      end
    end
  end
end
