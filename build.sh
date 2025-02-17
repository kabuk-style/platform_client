docker build -t bundler .
docker run -d --name bundler_container -v $(pwd):/gem bundler
docker exec bundler_container bundle install
docker cp bundler_container:/gem/Gemfile.lock .
docker stop bundler_container
docker rm bundler_container
