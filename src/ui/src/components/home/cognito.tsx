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
      userPoolId: 'us-east-1_KNXECmyfq', // USER_POOL_ID_PLACEHOLDER
      identityPoolId: 'us-east-1:1c4a9aaf-6d4f-4a7a-ab35-c666bb6b15e0', // IDENTITY_POOL_ID_PLACEHOLDER
      userPoolWebClientId: '1iihtdvo37cpjjq3e6dgq8p1u8', // WEB_CLIENT_ID_PLACEHOLDER
      oauth: {
        domain: 'crf-remittance-terraform.auth.us-east-1.amazoncognito.com',
        redirectSignIn: 'http://d2ve44te6khtee.cloudfront.net',
        redirectSignOut: 'http://d2ve44te6khtee.cloudfront.net',
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