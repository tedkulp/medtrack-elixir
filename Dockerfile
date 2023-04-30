# Use an official Elixir runtime as a parent image.
FROM elixir:1.14.4-otp-24-alpine

RUN apk add postgresql-client bash inotify-tools alpine-sdk nodejs npm
# RUN apt-get update && \
#   apt-get install -y postgresql-client

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install Hex package manager.
RUN mix local.hex --force

# I should probably see what rebar is
RUN mix local.rebar --force

# Grab packages from hex.pm.
RUN mix deps.get

# Compile the project.
RUN mix do compile --force

# Install Node.js dependencies
RUN npm install --prefix ./assets

RUN chmod 755 /app/entrypoint.sh
CMD ["/app/entrypoint.sh"]
