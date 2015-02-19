class AdminPort < Sinatra::Base

	r = Redis.new(:host => "redis", :port => 6379)

	get '/' do
		"Nginx-Content-Server Admin Interface<br />\n" +
		"Only to use by a main application.<br />\n" +
		"Use POST /files/filename to get a new access token." 
	end
	
	get '/files' do
		"No files available. Sorry."
	end
	
	post '/files/:filename' do
    if r.get("files:#{params[:filename]}").nil?
      r.set "files:#{params[:filename]}", 'abcd'
      return 'abcd'
    end

    'file already has a token'
	end
end
