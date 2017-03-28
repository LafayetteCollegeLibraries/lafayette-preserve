require 'spec_helper'

RSpec.describe TermWithChildren do
  let(:vocabulary) { LafayetteConcerns::Vocabulary.new(uri) }
  let(:uri) { "http://authority.localhost.localdomain/ns/foo" }
  let(:injector) { TermInjector.new }
  subject { TermWithChildren.new(vocabulary, injector.child_node_finder) }

  describe "#children" do
    let(:result) { subject.children }
    context "with no children exist" do
      it "should return nothing" do
        expect(subject.children).to eq []
      end
    end
    context "with children" do
      let(:child) do
        child = LafayetteConcerns::Term.new(uri+"/term1")
      end
      let(:child_2) do
        child_2 = LafayetteConcerns::Term.new(uri+"bar/term2")
      end
      before do
        child.persist!
        child_2.persist!
      end
      after do
        child.destroy
        child_2.destroy
      end
      it "should return children" do
        expect(subject.children.map(&:rdf_subject)).to eq [child.rdf_subject]
      end
    end
  end

  describe "#full_graph" do
    context "with no children" do
      it "should be the resource" do
        expect(subject.full_graph.statements.to_a).to eq subject.statements.to_a
      end
    end
    context "with children" do
      let(:child) do
        child = LafayetteConcerns::Term.new(uri+"/term1")
      end
      let(:unrelated_term) do
        unrelated_term = LafayetteConcerns::Term.new(uri+"bar/term2")
      end
      before do
        child.persist!
        unrelated_term.persist!
      end
      after do
        child.destroy
        unrelated_term.destroy
      end
      it "should have terms of itself and its children" do
        expect(subject.full_graph.count).to eq 2
      end
    end
  end

  describe "#sort_stringify" do
   it "should return a sorted stringified graph" do
     expect(subject.sort_stringify(subject.full_graph)).to be_a String
   end
  end
end
