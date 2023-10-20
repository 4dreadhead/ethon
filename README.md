# intercom-support

## Production

Loogs of an app

```shell script
docker compose -f /var/www/intercom-support/docker-compose.yml logs -f app
```

## Development

1. Set envs

```shell script
export $(cat .env | xargs)
```

2. Run server

```shell script
bundle exec puma
```
