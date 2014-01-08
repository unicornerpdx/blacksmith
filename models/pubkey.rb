class PubKey
  include DataMapper::Resource
  property :id, Serial

  belongs_to :user
  belongs_to :aws_account

  property :pubkey, Text

  property :created_at, DateTime
  property :updated_at, DateTime

  def name
    "#{user.username}@#{aws_account.name}"
  end

  def key_with_comment
    keydata = pubkey.match(/ssh-rsa [^ ]+/)[0]
    "#{keydata} #{user.username}@#{aws_account.name}"
  end
end
