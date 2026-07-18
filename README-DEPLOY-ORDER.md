
## PASO 1

El Laboratorio 7 crea la API Gateway, las Lambdas iniciales, Cognito y la tabla DynamoDB.

1. Abran la terminal y vayan a la carpeta del Lab 7:
2. Abran el archivo `terraform.tfvars` en esa carpeta.
3. Asegúrense de que la variable `queue_url` esté vacía por ahora (ya que la cola SQS aún no existe).
   ```hcl
   aws_region   = "us-east-1"
   project_name = "cloudbox"
   queue_url    = ""  # Déjenlo vacío temporalmente
   ```
4. Inicialicen y apliquen Terraform:
   ```
5. **Anoten los outputs:** el `api_url` y el `user_pool_id`.

---

## PASO 2

El Laboratorio 8 crea el bucket S3 y la distribución CloudFront para alojar la aplicación React.

1. Vayan a la carpeta de infraestructura del frontend:
   ```bash
   cd ../lab8-cloudbox-frontend/terraform
   ```
2. Inicialicen y apliquen Terraform:
   ```bash
   terraform init
   terraform apply 
   ```
3. Construyan el código React:
   - Vayan a la carpeta `lab8-cloudbox-frontend/frontend`.
   - Creen un archivo `.env.production` y peguen el `VITE_API_URL` y `VITE_USER_POOL_ID` obtenidos en el Paso 1.
   - Ejecuten `npm run build` y suban la carpeta `dist/` al bucket S3 que se acaba de crear.

---

## PASO 3

El Laboratorio 9 crea la cola SQS y la Lambda Consumer, leyendo automáticamente los recursos del Lab 7 (mediante `data.tf`).

1. Vayan a la carpeta del Lab 9:
   ```bash
   cd ../../lab9-cloudbox-sqs
   ```
2. Inicialicen y apliquen Terraform:
   ```bash
   terraform init
   terraform apply
   ```
   *(Nota: Terraform buscará automáticamente la tabla `Files` y el rol `cloudbox-lambda-role` creados en el Paso 1).*
3. **Copien el Output:** Cuando termine, verán un output llamado `documents_queue_url` que se ve parecido a esto:
   `https://sqs.us-east-1.amazonaws.com/123456789012/documents-queue`
   **¡Cópienlo!**

---

## PASO 4

Ahora debemos decirle a la Lambda Productora del Lab 7 a dónde enviar los mensajes.

1. Regresen a la carpeta del Lab 7:
   ```bash
   cd ../lab7-serverless-terraform
   ```
2. Abran nuevamente el archivo `terraform.tfvars`.
3. Reemplacen el valor de `queue_url` pegando la URL que copiaron en el Paso 3.
   ```hcl
   queue_url = "https://sqs.us-east-1.amazonaws.com/123456789012/documents-queue"
   ```
4. Apliquen Terraform una última vez para actualizar la variable de entorno de la Lambda:
   ```bash
   terraform apply 
   ```
