require 'spec_helper'

describe 'Routes', type: :routing do

  describe 'Vocabulary' do
    it 'routes to index' do
      expect(get: 'vocabularies', format: 'json').to route_to(controller: 'lafayette_concerns/vocabularies', action: 'index')
    end

    it 'routes to create' do
      expect(post: 'vocabularies', format: 'json').to route_to(controller: 'lafayette_concerns/vocabularies', action: 'create')
    end

    it 'routes to show' do
      expect(get: 'vocabularies/testVocabulary', format: 'json').to route_to(controller: 'lafayette_concerns/vocabularies', action: 'show', id: 'testVocabulary')
    end

    it 'routes to update' do

      expect(put: 'vocabularies/testVocabulary', format: 'json').to route_to(controller: 'lafayette_concerns/vocabularies', action: 'update', id: 'testVocabulary')
      expect(patch: 'vocabularies/testVocabulary', format: 'json').to route_to(controller: 'lafayette_concerns/vocabularies', action: 'update', id: 'testVocabulary')
    end

    it 'routes to destroy' do
      expect(delete: 'vocabularies/testVocabulary', format: 'json').to route_to(controller: 'lafayette_concerns/vocabularies', action: 'destroy', id: 'testVocabulary')
    end
  end

  describe 'Terms' do
    it 'routes to show' do
      expect(get: 'terms/testVocabulary/testTerm', format: 'json').to route_to(controller: 'lafayette_concerns/terms', action: 'show', vocabulary_id: 'testVocabulary', id: 'testTerm')
    end
  end
end
