class App < Sinatra::Base

  @@hc = HTTPClient.new

  def require_login
    if session[:username] == nil
      session[:redirect] = request.path
      redirect "#{SiteConfig['base']}/auth/github"
    end
    @user = User.first :username => session[:username]
  end

  configure do
  end

  before do
    puts "#{request.env['REQUEST_METHOD']} #{request.path} (#{session[:username]})"
  end

  get '/' do
    erb :index
  end

  get '/logout' do
    session[:username] = nil
    redirect "#{SiteConfig['base']}/"
  end

  get '/keys' do
    require_login
    erb :keys
  end

  get '/ssh-config' do
    require_login
    if params[:job]
      @job = ConfigJob.first :token => params[:job]
      erb :ssh_config_status
    else
      erb :ssh_config
    end
  end

  get '/job-status' do
    require_login
    if params[:job]
      @job = ConfigJob.first :token => params[:job]
      {
        :status => @job.status,
        :config => @job.config
      }.to_json
    else
      {}.to_json
    end
  end

  get '/authorized-keys' do
    require_login
    if params[:account]
      @account = AwsAccount.get params[:account]
      erb :authorized_keys_list
    else
      erb :authorized_keys
    end
  end

  post '/add-key' do
    require_login

    account = AwsAccount.get params[:account]

    if account.nil?
      flash[:notice] = 'Invalid account specified'
    else
      @user.pub_keys.create :aws_account => account, :pubkey => params[:pubkey]
    end

    redirect '/keys'
  end

  post '/delete-key' do
    require_login

    key = PubKey.get params[:id]

    if key.nil?
      flash[:notice] = 'Key not found'
    else 
      if key.user.username != session[:username]
        flash[:notice] = 'Invalid key specified'
      else
        key.destroy
      end
    end

    redirect '/keys'
  end

  get '/auth/:provider/callback' do

    # Check if the user is a member of the required organization
    orgs = JSON.parse(@@hc.get("https://api.github.com/user/orgs", nil, {
      'Authorization' => "Bearer #{request.env['omniauth.auth']['credentials']['token']}",
      'User-Agent' => 'IRC Log Viewer'
    }).body)

    authorized = false

    if orgs 
      org_ids = orgs.map{|o| o['login']}
      if (org_ids & SiteConfig['github']['orgs']).length > 0
        authorized = true
      end
    end

    if authorized
      session[:username] = request.env['omniauth.auth']['extra']['raw_info']['login']
      User.first_or_create :username => session[:username]
      redirect = session[:redirect] || '/keys'
      session[:redirect] = nil
      redirect "#{SiteConfig['base']}#{redirect}"
    else
      erb "<h1>Not Authorized</h1>"
    end
  end

  post '/generate-ssh-config' do
    require_login

    token = rand(36**12).to_s(36)

    job = ConfigJob.create :token => token, :status => 'new', :user => @user, :aws_account => AwsAccount.get(params[:id])

    Thread.new do
      AwsJob.new.perform({
        token: token
      })
    end
    redirect "/ssh-config?job=#{token}"
  end

end
