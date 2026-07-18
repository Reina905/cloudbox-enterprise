
# Sufijo unico para evitar colisión de nombres de bucket 


resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

#Generar .env.production con las variables del Lab 7.

resource "local_file" "env" {
  filename = "${path.root}/../frontend/.env.production"

  content = <<EOF
VITE_API_URL=${var.api_url}
VITE_USER_POOL_ID=${var.user_pool_id}
VITE_CLIENT_ID=${var.client_id}
VITE_REGION=${var.region}
EOF
}


# Build automático del frontend React.

resource "null_resource" "react_build" {
  depends_on = [local_file.env]

  provisioner "local-exec" {
    command     = "npm install && npm run build"
    working_dir = "${path.root}/../frontend"

    # cmd /C soporta && en Windows (PowerShell no lo soporta)
    interpreter = ["cmd", "/C"]
  }
}


# ucket S3 principal para el hosting del frontend.

resource "aws_s3_bucket" "frontend" {
  bucket = "${var.project_name}-frontend-${random_string.suffix.result}"

  tags = {
    Project     = var.project_name
    Environment = "lab"
    ManagedBy   = "Terraform"
    Owner       = "Cloud Team"
  }

 
  # esto evita destruccion accidental

  # lifecycle {
  #   prevent_destroy = true
  # }
}

# Versionamiento de objetos en el bucket.

resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}


# Configuración de Static Website Hosting en S3.

resource "aws_s3_bucket_website_configuration" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

# Deshabilitar el bloqueo de acceso público para permitirque CloudFront lea los objetos vía URL pública del bucket.

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}


# politica del bucket: permite lectura publica de objetos.

resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  depends_on = [aws_s3_bucket_public_access_block.frontend]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicRead"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource  = ["${aws_s3_bucket.frontend.arn}/*"]
      }
    ]
  })
}


# Subir dist/ completo al bucket usando aws s3 sync.
#
# NOTA: Se usa aws s3 sync en lugar de aws_s3_object con fileset()
# porque fileset() se evalúa en tiempo de PLAN y dist/ no existe
# todavía (se crea durante el build en APPLY). s3 sync resuelve
# esto ejecutándose en tiempo de APPLY, después del build.

resource "null_resource" "upload_frontend" {
  depends_on = [
    null_resource.react_build,
    aws_s3_bucket_policy.frontend,
  ]

  provisioner "local-exec" {
    command     = "aws s3 sync ../frontend/dist s3://${aws_s3_bucket.frontend.bucket} --delete"
    interpreter = ["cmd", "/C"]
  }
}


# Distribución CloudFront para servir el frontend con HTTPSa nivel global.

resource "aws_cloudfront_distribution" "frontend" {
  enabled             = true
  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket_website_configuration.frontend.website_endpoint
    origin_id   = "frontend-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "frontend-origin"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # SPA fallback: rutas no encontradas regresan a index.html
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Project     = var.project_name
    Environment = "lab"
    ManagedBy   = "Terraform"
  }
}

# Invalidación automática de caché CloudFront tras cada deploy.
#
# NOTA: En Windows cmd, las comillas en paths de CloudFront deben
# omitirse — /* sin comillas funciona correctamente con la AWS CLI.

resource "null_resource" "cloudfront_invalidation" {
  depends_on = [
    null_resource.upload_frontend,
    aws_cloudfront_distribution.frontend,
  ]

  provisioner "local-exec" {
    command     = "aws cloudfront create-invalidation --distribution-id ${aws_cloudfront_distribution.frontend.id} --paths /*"
    interpreter = ["cmd", "/C"]
  }
}
