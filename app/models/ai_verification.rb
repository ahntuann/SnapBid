class AiVerification < ApplicationRecord
  belongs_to :listing
  enum :status, { verified: 0, rejected: 1, uncertain: 2 }
end
