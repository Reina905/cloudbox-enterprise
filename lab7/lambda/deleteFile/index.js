const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  GetCommand,
  UpdateCommand,
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  console.log("Evento recibido");
  console.log(JSON.stringify(event, null, 2));

  // ── Extraer ownerId del JWT ────────────────────────────────
  const claims = event.requestContext.authorizer.claims;
  const ownerId = claims.sub;

  // ── Obtener el id del path ─────────────────────────────────
  const fileId = event.pathParameters.id;

  // ── Verificar que el archivo existe y pertenece al usuario ─
  const existing = await docClient.send(
    new GetCommand({
      TableName: "Files",
      Key: { fileId },
    })
  );

  if (!existing.Item || existing.Item.ownerId !== ownerId) {
    return {
      statusCode: 403,
      body: JSON.stringify({ message: "Forbidden" }),
    };
  }

  if (existing.Item.status === "DELETED") {
    return {
      statusCode: 404,
      body: JSON.stringify({ message: "Archivo no encontrado" }),
    };
  }

  // ── Eliminación lógica: status = "DELETED" ─────────────────
  await docClient.send(
    new UpdateCommand({
      TableName: "Files",
      Key: { fileId },
      UpdateExpression: "SET #s = :deleted, deletedAt = :da",
      ExpressionAttributeNames: {
        "#s": "status",
      },
      ExpressionAttributeValues: {
        ":deleted": "DELETED",
        ":da":      new Date().toISOString(),
      },
    })
  );

  console.log("Archivo eliminado (lógico):", fileId);

  return {
    statusCode: 200,
    body: JSON.stringify({ message: "Archivo eliminado correctamente", fileId }),
  };
};
