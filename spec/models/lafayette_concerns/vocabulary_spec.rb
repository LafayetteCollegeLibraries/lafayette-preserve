require 'spec_helper'

describe LafayetteConcerns::Vocabulary do

  it 'has a label' do
    subject.label = ['foo']
    expect(subject.label).to eq ['foo']
  end

  context 'referencing child terms' do
    before do
      subject.uri = 'http://authority.localhost.localdomain/ns/newVocabulary'
      
      @term = LafayetteConcerns::Term.new('http://authority.localhost.localdomain/ns/newVocabulary/testTerm')
      @term.persist!

      @second_term = LafayetteConcerns::Term.new('http://authority.localhost.localdomain/ns/newVocabulary/testTerm2')
      @second_term.persist!

      @foreign_term = LafayetteConcerns::Term.new('http://authority.localhost.localdomain/ns/anotherVocabulary/testTerm')
    end

    after do
      @term.destroy
    end

    it 'can detemine if it has a child term' do

      expect(subject.include?(@term)).to be true
      expect(subject.include?(@foreign_term)).to be false
    end

    it 'can have multiple child terms' do

      expect(subject.children).to include(@term)
      expect(subject.children).to include(@second_term)
    end
  end
end
