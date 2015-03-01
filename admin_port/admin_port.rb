class AdminPort < Sinatra::Base

	r = Redis.new(:host => "redis", :port => 6379)



	get '/' do
		"Nginx-Content-Server Admin Interface<br />\n" +
		"Only to use by a main application.<br />\n" +
		"Use POST /files/filename to get a new access token." 
	end
	
	post '/files/:filename/:obfuscation' do
	  response.headers['Access-Control-Allow-Origin'] = '*'
	  response.headers['Access-Control-Allow-Methods'] = 'GET, PUT, POST, DELETE, OPTIONS'
	  response.headers['Access-Control-Max-Age'] = '1000'
		token = params[:token]
    if token.nil?
      answer = {:ok => false, :msg => 'You must provide an access token!'}
      return (JSON.generate answer) + "\n"
    end
    filename = params[:filename] + '#' + params[:obfuscation]
    saved_token = r.get "files:#{filename}"

    if saved_token.nil? || saved_token != token
      answer = {:ok => false, :msg => 'Wrong access token!'}
      return (JSON.generate answer) + "\n"
    end

    if params[:file].nil?
      answer = {:ok => false, :msg => 'No file data contained.'}
      return (JSON.generate answer) + "\n"
    end

    system 'mkdir', '-p', "/data/www/#{params[:filename]}"

    File.open("/data/www/#{params[:filename]}/#{params[:obfuscation]}", "w") do |f|
      f.write(params[:file][:tempfile].read)
    end
    r.del "files:#{filename}"
    answer = {:ok => true, :msg => 'File successfully uploaded', :obfuscation => params[:obfuscation]}
    return (JSON.generate answer) + "\n"
	end
	
	post '/tokens/:filename' do
    extension = File.extname params[:filename]
    token = Helper.generate_token
    filename_obfuscation = Helper.generate_token + extension
    filename = params[:filename] + '#' + filename_obfuscation
    r.set "files:#{filename}", token
    answer = {:ok => true, :uri => "/#{params[:filename]}/#{filename_obfuscation}", :token => token}
    return (JSON.generate answer) + "\n"

	end
end
