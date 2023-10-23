# intercom-support

## Production

* [t.me/evo_support_bot](t.me/evo_support_bot)
* [intercom-bot.evosoft.xyz](https://intercom-bot.evosoft.xyz)
* [Intercom Developer Hub](https://app.intercom.com/a/apps/efm7fqqz/developer-hub)
* [Web for EvoSoft](https://app.intercom.com/a/apps/efm7fqqz/settings/web)

Loogs of an app

```shell script
docker compose -f /var/www/intercom-support/docker-compose.yml logs -f app
```

### Set telegram bot webhook

```ruby
require_relative "lib/telegram_api"
require_relative "lib/logging"
TelegramApi.new(logger: Logging.logger).set_webhook "https://intercom-bot.evosoft.xyz/webhook/telegram"
```

### Set intercome webhook

* [Webhooks](https://app.intercom.com/a/apps/efm7fqqz/developer-hub/app-packages/105181/webhooks/edit)

* Production: "https://intercom-bot.evosoft.xyz/webhook/intercom"
* Development: "https://283e-188-187-128-246.ngrok-free.app/webhook/intercom"

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

* __SERVER_URL__: `https://intercom-bot.evosoft.xyz`;
* __INTERCOM_APP_ID__: `efm7fqqz`, look for in the `Developer Hub`, https://app.intercom.com/a/apps/`efm7fqqz`/developer-hub;
* __TELEGRAM_TOKEN__: look for in `gitlab.evosoft.xyz/reklama/chat-bots/intercom-support` -> `Settings`, -> `CI/CD` -> `Variables`;
* __SENTRY_DSN__, look for [chat-bots-intercom-support](https://sentry.evosoft.xyz/organizations/evosoft/projects/chat-bots-intercom-support/?project=90).
