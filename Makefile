build: server client

test: server-test client-test

server:
	bundle

server-test:
	rake

client:
	yarn

client-test-packages:
	cd assets/tests && yarn run elm-package install -y

client-test:
	yarn test
