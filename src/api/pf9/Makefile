#
# Upstream monocular uses TravisCI to set up test dependendies (redis + mysql)
# Use this script as a substitute
#

SRC_DIR := ${CURDIR}
BUILD_DIR := ${CURDIR}/build

all: mysql-server-init redis-server-create

.PHONY: mysql-server-create mysql-server-init mysql-server-clean
# Start mysql server docker container
mysql-server-create: mysql-version
	bash -c "source $(SRC_DIR)/mysql.sh && \
	mysql::create_server $(MYSQL_VERSION)"

# Drop the database if it exists, create it, and apply all migrations
mysql-server-init: migrate mysql-server-create
	bash -c "source $(SRC_DIR)/mysql.sh && \
	mysql::init_mysql $(MIGRATE)"

# Stop and remove mysql server docker container
mysql-server-clean:
	bash -c "source $(SRC_DIR)/mysql.sh && \
	mysql::cleanup_server"

.PHONY: mysql-version
mysql-version:
ifndef PF9DEPLOY_DIR
	$(error PF9DEPLOY_DIR is undefined)
endif
	$(eval MYSQL_VERSION := $(shell PYTHONPATH="${PF9DEPLOY_DIR}:$${PYTHONPATH}" \
	  python $(SRC_DIR)/get-mysql-version.py))

# MySQL migration tool
.PHONY: migrate migrate-clean
MIGRATE_VERSION := v3.0.1
MIGRATE_PLATFORM := linux
MIGRATE_ARCH := amd64
MIGRATE_URL := https://github.com/mattes/migrate/releases/download/$(MIGRATE_VERSION)/migrate.$(MIGRATE_PLATFORM)-$(MIGRATE_ARCH).tar.gz
MIGRATE := $(BUILD_DIR)/migrate

migrate: $(MIGRATE)

$(MIGRATE): $(BUILD_DIR)
	cd $< && \
	curl --silent --show-error -L $(MIGRATE_URL) | tar xz && \
	mv migrate.$(MIGRATE_PLATFORM)-$(MIGRATE_ARCH) $@

migrate-clean:
	rm -f $(MIGRATE)

.PHONY: redis-server-create redis-init redis-server-clean
# Start redis server docker container
redis-server-create:
	bash -c "source $(SRC_DIR)/redis.sh && \
	redis::create_server $(MYSQL_VERSION)"

# Stop and remove redis server docker container
redis-server-clean:
	bash -c "source $(SRC_DIR)/redis.sh && \
	redis::cleanup_server"

$(BUILD_DIR):
	mkdir -p $@

.PHONY: clean
clean: mysql-server-clean migrate-clean redis-server-clean
	rm -rf $(BUILD_DIR)
