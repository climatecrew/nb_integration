build: server client

test: server-test client-test

server:
	bundle

server-test:
	rake

client:
	cd assets && yarn

client-test-packages:
	cd assets/tests && yarn run elm-package install -y

client-test:
	cd assets && yarn test
