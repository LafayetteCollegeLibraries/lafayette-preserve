require_relative 'metadb/common'
require_relative 'metadb/alsace'
require_relative 'metadb/beyond_steel'
require_relative 'metadb/biology'
require_relative 'metadb/east_asia'
require_relative 'metadb/geology_slides'
require_relative 'metadb/historical'
require_relative 'metadb/marquis_de_lafayette'
require_relative 'metadb/mckelvy_house'
require_relative 'metadb/silk_road'
require_relative 'metadb/war_casualties'

module Vocabularies
  module MetaDB

    DATES = [:dateOriginal,
             :dateArtifactLower,
             :dateArtifactUpper,
             :dateImageLower,
             :dateImageUpper,
             :dateSearch,
             :dateBirthDisplay,
             :dateBirthSearch,
             :dateDeathDisplay,
             :dateDeathSearch,
             :dateOriginalDisplay,
             :dateOriginalSearch,
             :dateApproximate,
             :dateRange,
             :dateDisplay,
             :dateSearch,
             :dateSemester,
             :dateImage,
             :datePeriod,
             :datePostmark]

    FACETS = [:formatAnalog,
              :formatDigital,
              :formatExtent,
              :formatMedium,
              :publisherDigital,
              :relationIsPartOf,
              :coverageLocation,
              :coverageLocationCountry,
              :creatorCompany,
              :creatorDigital,
              :creatorMaker,
              :subjectOcm,
              :contributorMilitaryUnit,
              :coveragePlaceBirth,
              :coveragePlaceDeath,
              :descriptionCauseDeath,
              :descriptionClass,
              :descriptionHonors,
              :descriptionMilitaryBranch,
              :descriptionMilitaryRank,
              :identifierItemnumber,
              :publisherOriginal,
              :subjectLcsh,
              :descriptionSize,
              :creatorPhotographer,
              :formatSize,
              :subjectLOC,
              :coverageLocation,
              :coverageLocationCountry,
              :coverageLocationState,
              :descriptionGeologicFeature,
              :descriptionGeologicProcess,
              :descriptionLocation,
              :descriptionVantagepoint,
              :relationSeealsoBook,
              :relationSeealsoImage,
              :creatorNetID,
              :descriptionAssignment,
              :descriptionCourseNumber,
              :identifierLocationBox,
              :identifierLocationFolder,
              :subjectTopical,
              :coverageLocationImage,
              :coverageLocationPostmark,
              :coverageLocationProducer,
              :coverageLocationRecipient,
              :coverageLocationSender,
              :subjectTheme]
  end
end
