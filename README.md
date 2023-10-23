# intercom-support

## Production

* [t.me/evo_support_bot](t.me/evo_support_bot)
* [intercom-bot.evosoft.xyz](https://intercom-bot.evosoft.xyz)

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

## ENvs

* __SERVER_URL__: `https://intercom-bot.evosoft.xyz`
* __INTERCOM_APP_ID__: `someid`
