class AwsRegion
  include DataMapper::Resource
  property :id, Serial

  belongs_to :aws_account

  property :region, String, :length => 255
end
