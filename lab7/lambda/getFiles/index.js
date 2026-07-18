const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const { DynamoDBDocumentClient, ScanCommand } = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);

exports.handler = async (event) => {
  console.log("Evento recibido");
  console.log(JSON.stringify(event, null, 2));

  // ── Extraer ownerId del JWT ────────────────────────────────
  const claims = event.requestContext.authorizer.claims;
  const ownerId = claims.sub;

  // ── Escanear tabla y filtrar por propietario ───────────────
  const result = await docClient.send(
    new ScanCommand({ TableName: "Files" })
  );

  // Solo devolver archivos activos que pertenezcan al usuario autenticado
  const files = result.Items.filter(
    (item) => item.ownerId === ownerId && item.status === "ACTIVE"
  );

  console.log(`Archivos encontrados para ${ownerId}:`, files.length);

  return {
    statusCode: 200,
    body: JSON.stringify(files),
  };
};
