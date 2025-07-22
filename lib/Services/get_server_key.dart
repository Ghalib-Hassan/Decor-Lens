import 'package:googleapis_auth/auth_io.dart';

class GetServerKey {
  Future<String> getServerKeyToken() async {
    // final scopes = [
    //   'https://www.googleapis.com/auth/userinfo.email',
    //   'https://www.googleapis.com/auth/firebase.messaging',
    //   'https://www.googleapis.com/auth/cloud-firebase.database',
    // ];

    final accountCredentials = ServiceAccountCredentials.fromJson({
      "type": "service_account",
      "project_id": "decor-lens",
      "private_key_id": "d3f0b999dc962279e57a4c79095f8cd90ef9a5dd",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDcypWqmLph9oGC\nVkXjhslnTcT8joTJwQZwDsvE1VENZDx+t/F5nxgVr5XH/wFr0qCbROZ30JmavXhE\n/vf2NQ8IPhzDBEo51U/NOn4PFigHI/AEE9JtTT4Pub5F35xEXJxmQi0U0oz6apM3\nH476XqQpetlo8BnHSO4dGRLjKqhv776m4FDg4+NWOHIGNqOlfq5iLugCppE35Jeq\nohfTeVGD6qbIEqcZft1okAWfq1IWVLb+ikrUdkt9agSQz1tY2nZuQ6Pk2GnSsGfy\nAb+slbG4WddClUgEH0C/4x3GOQQlNF4yFymeAb4bspdYwWC6MwLU8eF+dAHeGBvR\ndnWOcoX5AgMBAAECggEAAhDT0/vy084lHw2PQNY21dnDQTj/eA3ExtFJ9HD/KE4V\nnM/mw/m06tBbk+VIY58IXqYx4SbD+8/QVhZBRqiaF+cmM2g7s40nM9HbcmkFfdpH\nDsVgCiLCCmP1VPJceW1DugHeKcbgh8qYea24vjyax5fn0dSxQQ08dmw7d4GjgCHs\nezUwIUohu+vAosA+bbJNYnV+avC/XgOi0uaF+vUZfbs1G992Zt0xqybelKuo3pvD\ntj05qwfyRUlBqv+wI8ihNQCEjNHv2fDLBewboU2lScKWOSV9kvvak2PGRBYuCWXj\nH6St+8T4E+YFuMLkXiPiAI+3c51+DwsVvMQrDyYN6QKBgQD2znOqalg1oQKwU56X\nAyj+cQ8HxFrwAMA/gfNIHe7hKwdYjbn6+DlBRIyKPVLMQXZKuRkpTttqMk30barR\nuu6ubwymQIy+k9cgHtenUIXRKlRPuOux1bf9+t6Og7b0Hx3KXIHtVGLdNB42JS1s\nJ9fDsfKUwxb5WbmPKvavA64iVQKBgQDlBA11EVSgrHKwTNe2py3IHiBqHfB8Of5Z\ndzzQEKmiT0WgBnn1RAYitg4H/zoq17xDNxBynpuE/1I3+NN72dwPIGHVNiY7DrSx\nx/nryxKfUv80SY5JgqFWtUjlUuIJhRxp3MM/TQzQ0P4Y7J/M5TIzv4ovKMXkvGTn\nT6DDAAnhFQKBgQC2IH+GYFebq6d6SxqawcA8k13OE34v4b38n37R1xTyoHgZRuzZ\nYNePbHBxivNQu3X5ikIhE4ojAeA44bzObC26F0S0Yqn58MstbtUhKPC2+4+gDQwQ\n/W97Qud9L4GRAG1RaZaPdlhGeDFbL3Angfdc+DHUyWpos2eVWNUVLZgQyQKBgBJM\nBJc5zz0XCgKz4Pgi2zGF1qkjwzbpmzyiniUxb5wcIT/rxIqn6KWVTgGtjoQlwFDO\ncW325g32KCd4pczbVw2OVMKoFN3bCuy5QWppSw+XnfQbfFa7LRC0YyKPQKfqDp8W\nmDLSgRed2u862HmSRjSENRIXe9gOhTFF1148/o0RAoGBAOmEcSVgM9iGRoRrol9N\nCRfs9GLJlLrL7YZeEKteKK2ZDJfTDK5RAhmkVGJRNgxJpPF8PiQfv8Q6bLacus/7\nXotqWSx21DQy40G0M592HaaMKUXdOtv4IYtwrzE7q9CaOqxDjhPZhZCE8+OGo4BS\nKzNVpkolTRffJBknI9M451RY\n-----END PRIVATE KEY-----\n",
      "client_email":
          "firebase-adminsdk-fbsvc@decor-lens.iam.gserviceaccount.com",
      "client_id": "112359486558818290756",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-fbsvc%40decor-lens.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    });
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await clientViaServiceAccount(accountCredentials, scopes);
    final accessServerKey = client.credentials.accessToken.data;
    print('✅ Token: ${client.credentials.accessToken.data}');
    return accessServerKey;
  }
}
