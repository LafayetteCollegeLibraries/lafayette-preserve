require 'spec_helper'

describe LafayetteConcerns::Term do

  it 'has a label' do
    subject.label = ['foo']
    expect(subject.label).to eq ['foo']
  end

  context 'with a URI' do
    before do
      subject.uri = 'http://authority.localhost.localdomain/ns/newVocabulary/newTerm'
    end
    
    it 'has a namespace' do
      expect(subject.namespace).to eq('http://authority.localhost.localdomain/ns/')
    end
  end
end
