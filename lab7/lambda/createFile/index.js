const { SQSClient, SendMessageCommand } = require("@aws-sdk/client-sqs");
const { randomUUID } = require("crypto");

const sqsClient = new SQSClient({});
const QUEUE_URL = process.env.QUEUE_URL;

exports.handler = async (event) => {
  console.log("Evento recibido (Producer → SQS)");
  console.log(JSON.stringify(event, null, 2));

  // ── Extraer claims del Cognito Authorizer ──────────────────
  const claims = event.requestContext.authorizer.claims;
  const ownerId = claims.sub;
  const email = claims.email;

  // ── Parsear body ───────────────────────────────────────────
  let body;
  try {
    body = JSON.parse(event.body);
  } catch {
    return {
      statusCode: 400,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ message: "Body inválido: debe ser JSON" }),
    };
  }

  const { fileName, category, size } = body;

  // ── Validaciones obligatorias ──────────────────────────────
  if (!fileName || fileName.trim() === "") {
    return {
      statusCode: 400,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ message: "fileName es requerido y no puede estar vacío" }),
    };
  }

  if (!category || category.trim() === "") {
    return {
      statusCode: 400,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ message: "category es requerida y no puede estar vacía" }),
    };
  }

  if (size === undefined || size === null || typeof size !== "number" || size < 0) {
    return {
      statusCode: 400,
      headers: { "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ message: "size debe ser un número mayor o igual a 0" }),
    };
  }

  // ── Construir item ─────────────────────────────────────────
  const file = {
    fileId: randomUUID(),
    ownerId: ownerId,
    email: email,
    fileName: fileName.trim(),
    category: category.trim(),
    size: size,
    status: "ACTIVE",
    uploadDate: new Date().toISOString(),
  };

  // ── Enviar a SQS (en lugar de guardar directamente en DynamoDB) ──
  await sqsClient.send(
    new SendMessageCommand({
      QueueUrl: QUEUE_URL,
      MessageBody: JSON.stringify(file),
    })
  );

  console.log("Mensaje encolado en SQS:", file.fileId);

  return {
    statusCode: 200,
    headers: { "Access-Control-Allow-Origin": "*" },
    body: JSON.stringify({
      message: "Message queued",
      fileId: file.fileId,
    }),
  };
};
