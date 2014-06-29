class BacklogItemAssignment < ActiveRecord::Base
  default_scope { order(:priority, id: :asc) }
  scope :prioritized, -> { where.not(priority: nil) }
  scope :unprioritized, -> { where(priority: nil) }

  # -- Associations -----------------------------------

  belongs_to :backlog, polymorphic: true
  belongs_to :backlog_item

  # -- Validation -------------------------------------
  
  validates_uniqueness_of :backlog_item_id
  validates_uniqueness_of :priority, allow_nil: true, scope: :backlog_id
end # BacklogItemAssignment
