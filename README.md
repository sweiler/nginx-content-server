uucs - user uploaded content server
====================

This is a small server, built using docker, nginx and ruby, used to store user uploads and quickly deliver them via HTTP.

The server runs as a Docker container and exposes two ports: 80 and 8080. You should link your app's docker container
to the nginx container, so you can use port 8080, which is an "administrative" port. Port 80 is public and should be exposed
to the open internet, preferably under a domain such as `files.example.com` or `images.example.com` or whatever you like.
Your app then uses the admin port 8080 to grant users upload access to single files.

The picture below shows how it works:

1. **Step 1**: *user 1* wants to upload a file and asks your application server.
2. **Step 2**: Your app server checks the permissions and semantics. If it is okay with the upload, it requests an upload
token for a specific filename from the uucs through the admin port 8080. This port is internally connected to 
a ruby app.
3. **Step 3**: The ruby app generates a random access token and a random filename obfuscation token. The latter is used to
prevent unauthorized access to files through exploration of common filenames. Then the app stores access token and filename
(incl. the obfuscation token) in a redis in-memory database.
4. **Step 4**: Access token and the obfuscated filename are sent back to your application server, which passes them to the user.
5. **Step 5**: The user now can upload his/her file to the uucs via port 80 as a HTTP POST. The url for this is
`http://files.example.com/upload/filename.jpg/obfuscation.jpg`. The nginx, which is beyond port 80 sees that this is a upload, so
it passes the request to the ruby app.
6. **Step 6**: The ruby app checks if the access token is given in the request and is correct (this is obviously checked
by talking to the redis) and finally stores the uploaded image to the filesystem.
7. **Step 7**: Now another user (*user 2*) can access the uploaded file directly via the url `http://files.example.com/filename.jpg/obfuscation.jpg`,
only talking with the nginx. This is what makes the server so fast, since all requests from now on only require a nginx to read from
hard disk.


![Schematic of a typical use case](doc/schematic.svg)

Get started
-----------

There is a [./go](go) script in the root directory of the project, which requires ruby >= 1.9. If you run `./go checkdeps` it will check that all needed things are installed.
You can build the app with `./go build` and start it afterwards with `./go up`. If you run `./go` the script will tell you what else it can do for you.

