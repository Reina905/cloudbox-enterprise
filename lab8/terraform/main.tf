module "frontend" {

  source = "./modules/frontend"

  project_name = var.project_name
  region       = var.aws_region
  api_url      = var.api_url
  user_pool_id = var.user_pool_id
  client_id    = var.client_id

}
