class User
  include DataMapper::Resource
  property :id, Serial

  has n, :pub_keys

  property :username, String, :length => 255

  property :created_at, DateTime
  property :updated_at, DateTime
end
