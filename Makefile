# Local settings
BINARY_NAME=discord-sui-bot
EXTRA_DIR=./deploy/extra
DEPLOY_DIR=./deploy/packages/pi

# For deploying to raspberry pi
PI_USER=pi
PI_PASS=UrienMainAegisReflector
PI_DEPLOY_DIR=/home/pi/Projects/discord-sui-bot
PI_IP=192.168.1.5
PI_SUPERVISOR_ID=$(BINARY_NAME)
PI_TARGET=armv7-unknown-linux-gnueabihf
PI_CC=arm-linux-gnueabihf-gcc
PI_CC_PACKAGE=gcc-arm-linux-gnueabihf

all-pi: pack-pi stop-pi deploy-pi start-pi
init-pi: 
	rustup target add $(PI_TARGET)
	sudo apt-get install $(PI_CC_PACKAGE)
pack-pi:
	mkdir -p $(DEPLOY_DIR)
	mkdir -p $(EXTRA_DIR)
	rm -f $(DEPLOY_DIR)/*
	cp -f $(EXTRA_DIR)/* $(DEPLOY_DIR)
	cargo build --target  $(PI_TARGET) --release
	cp -f target/$(PI_TARGET)/release/$(BINARY_NAME) $(DEPLOY_DIR)/$(BINARY_NAME).exe
stop-pi:
	plink $(PI_IP) -l $(PI_USER) -pw $(PI_PASS) 'sudo supervisorctl stop $(PI_SUPERVISOR_ID)'
start-pi:
	plink $(PI_IP) -l $(PI_USER) -pw $(PI_PASS) 'sudo supervisorctl start $(PI_SUPERVISOR_ID)'
deploy-pi:
	plink $(PI_IP) -l $(PI_USER) -pw $(PI_PASS) 'mkdir -p $(PI_DEPLOY_DIR)'
	pscp -r -pw $(PI_PASS) $(DEPLOY_DIR)/* $(PI_USER)@$(PI_IP):$(PI_DEPLOY_DIR)
	plink $(PI_IP) -l $(PI_USER) -pw $(PI_PASS) 'sudo chmod 700 -f $(PI_DEPLOY_DIR)/*'