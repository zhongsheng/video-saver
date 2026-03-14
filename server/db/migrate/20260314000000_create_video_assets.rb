class CreateVideoAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :video_assets do |t|
      t.string :wechat_openid, null: false
      t.string :source_message_id, null: false
      t.string :source_url
      t.string :media_id
      t.integer :status, null: false, default: 0
      t.datetime :download_started_at
      t.datetime :downloaded_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :video_assets, %i[wechat_openid source_message_id], unique: true
    add_index :video_assets, :status
  end
end
