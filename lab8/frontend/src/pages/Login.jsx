import { useState } from "react";

import {
  AuthenticationDetails,
  CognitoUser,
  CognitoUserPool,
} from "amazon-cognito-identity-js";

import { cognitoConfig } from "../config/cognito";

function Login({ setToken }) {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [loading, setLoading] = useState(false);

  const poolData = {
    UserPoolId: cognitoConfig.userPoolId,
    ClientId: cognitoConfig.clientId,
  };

  const userPool = new CognitoUserPool(poolData);

  const login = () => {
    if (!email || !password) {
      alert("Todos los campos son obligatorios");
      return;
    }

    setLoading(true);

    const authenticationDetails = new AuthenticationDetails({
      Username: email,
      Password: password,
    });

    const cognitoUser = new CognitoUser({
      Username: email,
      Pool: userPool,
    });

    cognitoUser.authenticateUser(authenticationDetails, {
      onSuccess(result) {
        const token = result.getIdToken().getJwtToken();

        localStorage.setItem("token", token);
        localStorage.setItem("user", email);

        setToken(token);
        setLoading(false);
      },

      onFailure(error) {
        setLoading(false);
        alert(error.message);
      },
    });
  };

  return (
    <div className="container mt-5">
      <div
        className="card p-4 mx-auto"
        style={{ maxWidth: "500px" }}
      >
        <div className="text-center mb-3">
          <h2 className="mb-1">CloudBox Enterprise</h2>
          <p className="text-muted">
            Ingrese sus credenciales corporativas
          </p>
        </div>

        <input
          id="email"
          type="email"
          className="form-control mb-3"
          placeholder="Correo electrónico"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
        />

        <input
          id="password"
          type="password"
          className="form-control mb-3"
          placeholder="Contraseña"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />

        <button
          id="btn-login"
          className="btn btn-primary w-100"
          onClick={login}
          disabled={loading}
        >
          {loading ? "Autenticando..." : "Iniciar Sesión"}
        </button>
      </div>
    </div>
  );
}

export default Login;
