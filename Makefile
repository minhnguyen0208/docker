    PROJECT ?= $(shell grep ^PROJECT .env | cut -d= -f2)

    up:
		docker compose up -d --build

    down:
		docker compose down

    logs:
		docker compose logs -f web app node

    sh:
		docker compose exec app bash

    init:
		docker compose up -d --build
		docker compose exec -w /var/www/html app bash -lc "composer install --no-interaction --prefer-dist && php artisan key:generate && php artisan storage:link && php artisan migrate"
		docker compose exec -w /var/www/html app php artisan optimize:clear

    fe:
		docker compose --profile fe up -d node

    worker:
		docker compose --profile worker up -d queue scheduler
