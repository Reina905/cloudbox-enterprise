const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, GetCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  console.log("Evento recibido");
  console.log(JSON.stringify(event, null, 2));

  // ── Extraer ownerId del JWT ────────────────────────────────
  const claims = event.requestContext.authorizer.claims;
  const ownerId = claims.sub;

  // ── Obtener el id del path /v1/files/{id} ──────────────────
  const fileId = event.pathParameters.id;

  // ── Buscar en DynamoDB ─────────────────────────────────────
  const result = await docClient.send(
    new GetCommand({
      TableName: "Files",
      Key: { fileId },
    })
  );

  // ── Validar existencia y propiedad ─────────────────────────
  if (!result.Item || result.Item.ownerId !== ownerId) {
    return {
      statusCode: 403,
      body: JSON.stringify({ message: "Forbidden" }),
    };
  }

  // ── Verificar que el archivo esté activo ───────────────────
  if (result.Item.status !== "ACTIVE") {
    return {
      statusCode: 404,
      body: JSON.stringify({ message: "Archivo no encontrado" }),
    };
  }

  return {
    statusCode: 200,
    body: JSON.stringify(result.Item),
  };
};
