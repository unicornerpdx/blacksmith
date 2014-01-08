class AwsAccount
  include DataMapper::Resource
  property :id, Serial

  has n, :pub_keys

  property :name, String, :length => 255
  property :region, String, :length => 255

  property :access_key, String, :length => 255
  property :secret_key, String, :length => 255

end
