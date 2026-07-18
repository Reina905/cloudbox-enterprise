import json
import boto3
import os

dynamodb = boto3.resource("dynamodb")

TABLE_NAME = os.environ["TABLE_NAME"]

table = dynamodb.Table(TABLE_NAME)


def lambda_handler(event, context):
    """
    Lambda Consumidora: lee mensajes de SQS y los almacena en DynamoDB.
    Invocada automáticamente por el Event Source Mapping.
    """
    print("Consumer invocado. Registros recibidos:", len(event["Records"]))

    for record in event["Records"]:
        body = json.loads(record["body"])
        print("Procesando fileId:", body.get("fileId", "N/A"))

        table.put_item(Item=body)
        print("Registro almacenado en DynamoDB:", body.get("fileId"))

    return {
        "statusCode": 200
    }
