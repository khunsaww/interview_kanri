server ENV.fetch("DEPLOY_HOST", "example.com"), user: ENV.fetch("DEPLOY_USER", "deploy"), roles: %w[app db web]
