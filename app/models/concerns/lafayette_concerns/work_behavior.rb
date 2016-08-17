module LafayetteConcerns
  module WorkBehavior
    extend ActiveSupport::Concern
    include LafayetteConcerns::Works::Metadata

=begin
    def remote_files=(*args)
      # super(*args)
      nil
    end

    def uploaded_files=(*args)
      # super(*args)
      nil
    end
=end
  end
end
