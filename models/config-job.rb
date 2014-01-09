class ConfigJob
  include DataMapper::Resource
  property :id, Serial

  belongs_to :user
  belongs_to :aws_region

  property :token, String, :length => 255
  property :config, Text
  property :status, String, :length => 255

  property :created_at, DateTime
  property :updated_at, DateTime
end