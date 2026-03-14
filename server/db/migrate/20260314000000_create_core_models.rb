class CreateCoreModels < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :wechat_openid, null: false
      t.string :nickname
      t.string :avatar_url
      t.datetime :last_seen_at

      t.timestamps
    end
    add_index :users, :wechat_openid, unique: true

    create_table :video_assets do |t|
      t.references :user, null: false, foreign_key: true
      t.string :source_message_id, null: false
      t.string :source_url, null: false
      t.string :storage_path
      t.bigint :file_size
      t.integer :duration_ms
      t.string :status, null: false, default: "received"
      t.datetime :expires_at
      t.datetime :downloaded_at
      t.datetime :deleted_at
      t.text :failure_reason

      t.timestamps
    end
    add_index :video_assets, :status
    add_index :video_assets, :expires_at

    create_table :download_tokens do |t|
      t.references :video_asset, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.datetime :used_at

      t.timestamps
    end
    add_index :download_tokens, :token, unique: true
  end
end
