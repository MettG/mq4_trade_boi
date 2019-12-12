
secrets = {
	bot_token: 'YOUR_TOKEN_HERE',
	secret: 'YOUR_SIGNING_SECRET',
	password: 'CUSTOM_PASSWORD'
}

File.open("secrets.yml", "w") { |file| file.write(secrets.to_yaml)}