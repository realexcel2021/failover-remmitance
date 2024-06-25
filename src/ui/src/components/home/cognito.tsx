import {Amplify, Auth} from "aws-amplify";
import React, { useEffect } from "react";
import {useSelector} from "react-redux";
import {useHistory} from "react-router-dom";
import {ReduxRoot} from "../../interfaces";

function Cognito (props: any) {

  const history = useHistory();

  const amplifyConfig = {
    Auth: {
      mandatorySignIn: true,
      region: 'us-east-1',
      userPoolId: 'us-east-1_Rq02gpU9t', // USER_POOL_ID_PLACEHOLDER
      identityPoolId: 'us-east-1:d77f8597-e306-403c-b518-bbcd815f25df', // IDENTITY_POOL_ID_PLACEHOLDER
      userPoolWebClientId: '1fs6c8t7lkjed54e5kc406i0d', // WEB_CLIENT_ID_PLACEHOLDER
      oauth: {
        domain: 'crf-remittance-terraform.auth.us-east-1.amazoncognito.com',
        redirectSignIn: 'http://d3e3aycezlxw2m.cloudfront.net/',
        redirectSignOut: 'http://d3e3aycezlxw2m.cloudfront.net/',
        responseType: 'code' // or 'token', note that REFRESH token will only be generated when the responseType is code
      }
    }
  };

  Amplify.configure(amplifyConfig);
  Auth.configure(amplifyConfig);

  const token = useSelector( (state:ReduxRoot) => {
    return state.reducerState.token
  });

  useEffect(() => {

    if (token === "") {
      history.push("/Login");
    }

  }, [history, token]);

  return (
      <div />
  );
}

export default Cognito;