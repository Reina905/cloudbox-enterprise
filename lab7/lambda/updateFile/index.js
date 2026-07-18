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

  // ── Parsear body ───────────────────────────────────────────
  let body;
  try {
    body = JSON.parse(event.body);
  } catch {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "Body inválido: debe ser JSON" }),
    };
  }

  const { fileName, category, size } = body;

  // ── Validaciones ───────────────────────────────────────────
  if (!fileName || fileName.trim() === "") {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "fileName es requerido y no puede estar vacío" }),
    };
  }

  if (!category || category.trim() === "") {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "category es requerida y no puede estar vacía" }),
    };
  }

  if (size === undefined || size === null || typeof size !== "number" || size < 0) {
    return {
      statusCode: 400,
      body: JSON.stringify({ message: "size debe ser un número mayor o igual a 0" }),
    };
  }

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

  if (existing.Item.status !== "ACTIVE") {
    return {
      statusCode: 404,
      body: JSON.stringify({ message: "Archivo no encontrado" }),
    };
  }

  // ── Actualizar solo los campos permitidos ──────────────────
  const result = await docClient.send(
    new UpdateCommand({
      TableName: "Files",
      Key: { fileId },
      UpdateExpression:
        "SET fileName = :fn, category = :cat, #sz = :sz, updatedAt = :ua",
      ExpressionAttributeNames: {
        "#sz": "size", // size es palabra reservada en DynamoDB
      },
      ExpressionAttributeValues: {
        ":fn":  fileName.trim(),
        ":cat": category.trim(),
        ":sz":  size,
        ":ua":  new Date().toISOString(),
      },
      ReturnValues: "ALL_NEW",
    })
  );

  console.log("Archivo actualizado:", fileId);

  return {
    statusCode: 200,
    body: JSON.stringify(result.Attributes),
  };
};
