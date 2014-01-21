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
    if match = pubkey.match(/ssh-rsa [^ ]+/)
      keydata = match[0]
      "#{keydata} #{user.username}@#{aws_account.name}"
    else
      pubkey
    end
  end
end
