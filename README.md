# What is traefik

[Official Website](https://doc.traefik.io/traefik/)

## Usage

1. Clone this repository
1. create a local `.env` file</br>
    `cp .env-example .env`
1. Create the traefik network</br>
    `docker network create traefik_ext` 
1. Start the service via `docker-compose up -d`
1. Visit the dashboard to see if it is up and running
   (default) [http://localhost:8080/dashbaord/](http://localhost:8080/dashbaord/)</br>
   Replace `localhost` with the IP address or domain name of your choice, if necessary

## Using basic traefik (HTTP only)

The `docker-compose.yml` file is the main file and contains all basic informations which are necessary to start the service via http only.

## Using override files for enabling HTTPS

I've provided two examples for how to enable HTTPS. Copy the example file you want to use and rename it to `dockercompose.override.yml`. This will overwrite the configuration blocks specified in the `docker-compose.yml`. If you want to change settings related to the HTTPS examples, modify them within the override file instead of the basic `docker-compose.yml`.

### `example.https-http-letsencrypt.docker-compose.override.yml`

Receive your SSL certificate from LetsEncrypt via [http-01 challenge](https://letsencrypt.org/docs/challenge-types/#http-01-challenge). 

This is more convenient to most of poeple who want to receive an SSL certificate quickly and easily. Traefik will order an ssl certificate for each domain name, which will be described via lables within each service where the label `traefik.enable=true` has been set.

### `example.https-dns-cloudflare.docker-compose.override.yml`

Receive your (wildcard) SSL certificate from LetsEncrypt via [dns-01 challenge](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge). In this example, we are using [Cloudflare](https://www.cloudflare.com/) as [dns challenge provider](https://doc.traefik.io/traefik/https/acme/#providers). 

This is a bit more complex than the HTTP-01 challenge.

1. [Create an API token](https://dash.cloudflare.com/profile/api-tokens) with the following specs: 
    - "All zones - **Zone Settings:Read, Zone:Read, DNS:Edit**"
1. Add the token and your cloudflare email address in your local `.env` file
1. Start the container

## Test if traefik is serving other services

1. Copy the file `test-traefik-docker-compose.yml` to another location outside of this repository and rename it to `docker-compose.yml`.
1. Modify `CUSTOM_HOSTNAME` to fit your needs.
1. Modify the entrypoint label from `websecure` to `web` if you want to test HTTP isntead of HTTPS.
1. Start the container.
1. Open a browser and visit the container's URL.
