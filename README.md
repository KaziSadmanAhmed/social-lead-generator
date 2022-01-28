# Social Lead Generator
## _A social media statistical tool_

Social Lead Generator is an analytical tool for analyzing Twitter post statistics. This supports trending posts statistics.


## Features
- View personal tweets statistics
- View public handle tweets statistics
- View trending posts
- Easy deployment using Docker
- Easy deployment on AWS
- Stack managed using Terraform

## Environment setup

Before you begin, you need to install and configure the following tools:
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [Terraform](https://www.terraform.io/downloads)


## Pre-deployment

```sh
git clone https://github.com/sadmanbd/social-lead-generator
cd social-lead-generator
```

## Deployment on Docker

### For local development

```sh
cp .env.sample .env
docker compose up --build --remove-orphans
```

### For production deployment

```sh
cp .env.prod.sample .env.prod
docker compose -f docker-compose.prod.yml --env-file .env.prod up --remove-orphans
```

## Deployment on AWS

### Deploy on AWS ECS (EC2)

```sh
terraform init
terraform apply
```


## License

MIT
