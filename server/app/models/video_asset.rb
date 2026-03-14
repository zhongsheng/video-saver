class VideoAsset < ApplicationRecord
  TRANSITION_GRAPH = {
    "received" => %w[downloading failed deleted],
    "downloading" => %w[ready failed deleted],
    "ready" => %w[downloaded deleted failed],
    "downloaded" => %w[deleted],
    "deleted" => [],
    "failed" => %w[received deleted]
  }.freeze

  belongs_to :user
  has_many :download_tokens, dependent: :destroy

  enum :status,
       {
         received: "received",
         downloading: "downloading",
         ready: "ready",
         downloaded: "downloaded",
         deleted: "deleted",
         failed: "failed"
       },
       validate: true

  validates :source_message_id, :source_url, presence: true
  validates :file_size, :duration_ms,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validate :ensure_transition_is_allowed, if: -> { persisted? && will_save_change_to_status? }
  validate :ensure_status_data_consistency

  def mark_downloading!
    transition_to!("downloading")
  end

  def mark_ready!(storage_path:, file_size:, duration_ms:, expires_at:)
    self.storage_path = storage_path
    self.file_size = file_size
    self.duration_ms = duration_ms
    self.expires_at = expires_at
    self.failure_reason = nil

    transition_to!("ready")
  end

  def mark_downloaded!(downloaded_at: Time.current)
    self.downloaded_at = downloaded_at
    transition_to!("downloaded")
  end

  def mark_deleted!(deleted_at: Time.current)
    self.deleted_at = deleted_at
    transition_to!("deleted")
  end

  def mark_failed!(reason:)
    self.failure_reason = reason
    transition_to!("failed")
  end

  private

  def transition_to!(next_status)
    self.status = next_status
    save!
  end

  def ensure_transition_is_allowed
    previous_status = status_change_to_be_saved.first
    next_status = status_change_to_be_saved.last

    return if previous_status.blank? || previous_status == next_status
    return if TRANSITION_GRAPH.fetch(previous_status, []).include?(next_status)

    errors.add(:status, "cannot transition from #{previous_status} to #{next_status}")
  end

  def ensure_status_data_consistency
    if ready? || downloaded?
      errors.add(:storage_path, "can't be blank") if storage_path.blank?
      errors.add(:file_size, "can't be blank") if file_size.blank?
      errors.add(:duration_ms, "can't be blank") if duration_ms.blank?
      errors.add(:expires_at, "can't be blank") if expires_at.blank?
    end

    errors.add(:downloaded_at, "can't be blank") if downloaded? && downloaded_at.blank?
    errors.add(:deleted_at, "can't be blank") if deleted? && deleted_at.blank?
    errors.add(:failure_reason, "can't be blank") if failed? && failure_reason.blank?
  end
end
